% Licensed under the Apache License, Version 2.0 (the "License"); you may not
% use this file except in compliance with the License. You may obtain a copy of
% the License at
%
%   http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
% WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
% License for the specific language governing permissions and limitations under
% the License.

%%% @author CA Meijer
%%% @copyright 2012 CA Meijer
%%% @doc Mongrel API. This module provides CRUD operations.
%%% @end

-module(mongrel).

-behaviour(gen_server).

%% API
-export([count/1,
		 count/2,
		 delete/1,
		 delete_one/1,
		 do/5,
		 find/1,
		 find/2,
		 find/3,
		 find/4,
		 find_one/1,
		 find_one/2,
		 find_one/3,
		 insert/1,
		 insert_all/1,
		 modify/2,
		 replace/2,
		 repsert/2,
		 save/1]).

%% gen_server callbacks
-export([init/1, 
		 handle_call/3, 
		 handle_cast/2, 
		 handle_info/2, 
		 terminate/2, 
		 code_change/3]).

-record(state, {}).

%% External functions
count(RecordSelector) ->
	Collection = mongrel_mapper:get_type(RecordSelector),
	Selector = mongrel_mapper:map_selector(RecordSelector),
	mongo:count(Collection, Selector).

count(RecordSelector, Limit) ->
	Collection = mongrel_mapper:get_type(RecordSelector),
	Selector = mongrel_mapper:map_selector(RecordSelector),
	mongo:count(Collection, Selector, Limit).
	
delete(RecordSelector) ->
	Collection = mongrel_mapper:get_type(RecordSelector),
	Selector = mongrel_mapper:map_selector(RecordSelector),
	mongo:delete(Collection, Selector).

delete_one(RecordSelector) ->
	Collection = mongrel_mapper:get_type(RecordSelector),
	Selector = mongrel_mapper:map_selector(RecordSelector),
	mongo:delete_one(Collection, Selector).

do(WriteMode, ReadMode, Connection, Database, Action) ->
	{ok, Pid} = gen_server:start_link(?MODULE, [WriteMode, ReadMode, Connection, Database], []),
	gen_server:call(Pid, {do, WriteMode, ReadMode, Connection, Database, Action}, infinity).

find(RecordSelector) ->
	find(RecordSelector, []).

find(RecordSelector, RecordProjector) ->
	find(RecordSelector, RecordProjector, 0).

find(RecordSelector, RecordProjector, Skip) ->
	find(RecordSelector, RecordProjector, Skip, 0).

find(RecordSelector, RecordProjector, Skip, BatchSize) ->
	Collection = mongrel_mapper:get_type(RecordSelector),
	Selector = mongrel_mapper:map_selector(RecordSelector),
	Projector = mongrel_mapper:map_projection(RecordProjector),
	MongoCursor = mongo:find(Collection, Selector, Projector, Skip, BatchSize),
	WriteMode = get(write_mode),
	ReadMode = get(read_mode),
	Connection = get(connection),
	Database = get(database),
	mongrel_cursor:cursor(MongoCursor, WriteMode, ReadMode, Connection, Database, Collection).

find_one(RecordSelector) ->
	find_one(RecordSelector, []).

find_one(RecordSelector, RecordProjector) ->
	find_one(RecordSelector, RecordProjector, 0).

find_one(RecordSelector, RecordProjector, Skip) ->
	Collection = mongrel_mapper:get_type(RecordSelector),
	Selector = mongrel_mapper:map_selector(RecordSelector),
	Projector = mongrel_mapper:map_projection(RecordProjector),
	{Res} = mongo:find_one(Collection, Selector, Projector, Skip),
	CallbackFunc = fun(Coll, Id) ->
						   {Reference} = mongo:find_one(Coll, {'_id', Id}),
						   Reference
				   end,
	{mongrel_mapper:unmap(Collection, Res, CallbackFunc)}.

insert(Record) ->
	{{Collection, Document}, ChildDocuments} = mongrel_mapper:map(Record),
	[mongo:save(ChildCollection, ChildDocument) || {ChildCollection, ChildDocument} <- ChildDocuments],
	mongo:insert(Collection, Document).

insert_all(Records) ->
	[insert(Record) || Record <- Records].
	
modify(RecordSelector, RecordModifier) ->
	Collection = mongrel_mapper:get_type(RecordSelector),
	Selector = mongrel_mapper:map_selector(RecordSelector),
	Modifier = mongrel_mapper:map_modifier(RecordModifier),
	mongo:modify(Collection, Selector, Modifier).

replace(RecordSelector, NewRecord) ->
	{{Collection, NewDocument}, ChildDocuments} = mongrel_mapper:map(NewRecord),
	Selector = mongrel_mapper:map_selector(RecordSelector),
	mongo:replace(Collection, Selector, NewDocument),
	[mongo:save(ChildCollection, ChildDocument) || {ChildCollection, ChildDocument} <- ChildDocuments].
	
repsert(RecordSelector, NewRecord) ->
	{{Collection, NewDocument}, ChildDocuments} = mongrel_mapper:map(NewRecord),
	Selector = mongrel_mapper:map_selector(RecordSelector),
	mongo:repsert(Collection, Selector, NewDocument),
	[mongo:save(ChildCollection, ChildDocument) || {ChildCollection, ChildDocument} <- ChildDocuments].
	
save(Record) ->
	{{Collection, Document}, ChildDocuments} = mongrel_mapper:map(Record),
	[mongo:save(ChildCollection, ChildDocument) || {ChildCollection, ChildDocument} <- ChildDocuments],
	mongo:save(Collection, Document).
	

%% Server functions

%% @doc Initializes the server with a MongoDB connection.
%% @spec init(MongoDbConnection) -> {ok, State::tuple()}
%% @end
init([WriteMode, ReadMode, Connection, Database]) ->
	put(write_mode, WriteMode),
	put(read_mode, ReadMode),
	put(connection, Connection),
	put(database, Database),
    {ok, #state{}}.

%% @doc Responds synchronously to server calls.
%% @spec handle_call(Message::tuple(), From::pid(), State::tuple()) -> {stop, normal, Reply::any(), NewState::tuple()}
%% @end
handle_call({do, WriteMode, ReadMode, Connection, Database, Action}, _From, State) ->
    Reply = mongo:do(WriteMode, ReadMode, Connection, Database, Action),
    {stop, normal, Reply, State}.

%% @doc Responds asynchronously to messages.
%% @spec handle_cast(any(), tuple()) -> {no_reply, State}
%% @end
handle_cast(_Message, State) ->
	{noreply, State}.

%% @doc Responds to non-OTP messages.
%% @spec handle_info(any(), tuple()) -> {no_reply, State}
%% @end
handle_info(_Info, State) ->
	{noreply, State}.

%% @doc Handles the shutdown of the server.
%% @spec terminate(any(), any()) -> ok
%% @end
terminate(_Reason, _State) ->
	ok.

%% @doc Responds to code changes.
%% @spec code_change(any(), any(), any()) -> {ok, State}
%% @end
code_change(_OldVersion, State, _Extra) ->
	{ok, State}.


%%% Internal functions

