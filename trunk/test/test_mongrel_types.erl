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

-module(test_mongrel_types).

%%
%% Include files
%%
-include_lib("eunit/include/eunit.hrl").
-include_lib("mongrel_types.hrl").

%%
%% Exported Functions
%%
-export([]).

to_binary_test() ->
	{bin, bin, <<1,2,3>>} = mongrel_types:binary(<<1,2,3>>),
	{bin, bin, <<>>} = ?binary(<<>>).

