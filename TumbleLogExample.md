# Tumblelog Example #

The MongoEngine <a href='http://mongoengine.org/docs/v0.5/tutorial.html'>tutorial</a> illustrates mapping Python objects to MongoDB documents using a _tumblelog_ example. It's instructive to read the MongoEngine tutorial before reading further (in particular, the tutorial defines what a 'tumblelog' is).

## Differences between MongoEngine and MongrelMapper ##
### Mongrel's Limitations ###
The purpose of this example was to check that Mongrel can provide similar functionality to that of the MongoEngine mapper. Mongrel has certain limitations compared to MongoEngine at the moment
  1. Mongrel doesn't enforce that certain fields in a record must be defined
  1. Mongrel doesn't perform type-checking on the contents of fields
  1. Mongrel doesn't support cascading deletes
  1. Mongrel requires that if a document has an `_`id' field, that the `_`id field is populated by the user.

With varying levels of effort, the first three items above could probably be added to Mongrel.

### Embedded versus Reference Documents ###
Both MongoEngine and MongrelMapper allow documents to be nested either by reference or by embedding. MongoEngine requires that a document extend the EmbeddedDocument class if it must be embedded. MongrelMapper will embed a document unless it has an `_`id field.


## Tumblelog Module ##
The code below (found in the `tumblelog.erl` module in the `src_examples` directory) shows that we define six record types. We populate the body field of a
`post` record with the particular record type corresponding to the blog posting type
(text, image or link). By comparison, MongoEngine uses inheritance to support the three types of blog post.

Users and posts must be stored in their own collections (so they have `_`id fields) while comments must be embedded in `post` documents (and don't have object identifiers).

```

%% This example code is a rough port of the MongoEngine example at
%% http://mongoengine.org/docs/v0.5/tutorial.html
-module(tumblelog).
-include_lib("mongrel/include/mongrel_macros.hrl").
-export([add_mappings/0, populate/0]).

%% Users and posts are stored in collections so they have '_id' fields
-record(user, {'_id', email, first_name, last_name}).
-record(post, {'_id', title, author, tags, comments, body}).
-record(text_post, {content}).
-record(image_post, {image_path}).
-record(link_post, {link_url}).

%% Comments are embedded in posts so do not have an '_id' field.
-record(comment, {content, name}).

add_mappings() ->
?add_mapping(user),
?add_mapping(post),
?add_mapping(comment),
?add_mapping(text_post),
?add_mapping(image_post),
?add_mapping(link_post).

populate() ->
John = #user{?id(), email= <<"jdoe@example.com">>, first_name= <<"John">>, last_name= <<"Doe">>},
Post1 = #post{?id(), title= <<"Fun with MongoEngine">>, author=John, tags=[<<"mongodb">>, <<"mongoengine">>],
body=#text_post{content= <<"Took a look at mongoengine, looks pretty cool.">>}},
Post2 = #post{?id(), title= <<"MongoEngine Documentation">>, author=John, tags=[<<"mongoengine">>],
body=#link_post{link_url= <<"http://tractiondigital.com/labs/mongoengine/docs">>}},
{ok, Conn} = mongo:connect(localhost),
mongrel:do(safe, master, Conn, tumblelog,
fun() ->
mongrel:delete(#user{}),
mongrel:delete(#post{}),
mongrel:insert_all([Post1, Post2])
end),
mongo_connect:close(Conn).
```

## Running the sample code ##
We can compile and run the sample code to populate the `tumblelog` database from the shell as follows. We import the record definitions from the `tumblelog` module using the `rr` shell function.

<pre>
1> application:start(mongodb).<br>
ok<br>
2> application:start(mongrel).<br>
ok<br>
3> c(tumblelog).<br>
{ok,tumblelog}<br>
4> rr(tumblelog).<br>
[comment,image_post,link_post,post,text_post,user]<br>
5> tumblelog:add_mappings().<br>
ok<br>
6> tumblelog:populate().<br>
ok<br>
</pre>

## Reading from the Database ##
### Getting the titles of all posts ###
The following code shows how to retrieve the titles of all posts by getting a projection of the posts' title fields.

<pre>
7> f(Conn).<br>
ok<br>
8> {ok,Conn}=mongo:connect(localhost).<br>
{ok,{connection,{"localhost",27017},<0.66.0>,infinity}}<br>
9> mongrel:do(safe, master, Conn, tumblelog, fun()-><br>
9> Cursor=mongrel:find(#post{}, #post{'_id'=0, title=1}),<br>
9> mongrel_cursor:rest(Cursor)<br>
9> end).<br>
{ok,[#post{'_id' = undefined,<br>
title = <<"Fun with MongoEngine">>,author = undefined,<br>
tags = undefined,comments = undefined,body = undefined},<br>
#post{'_id' = undefined,<br>
title = <<"MongoEngine Documentation">>,author = undefined,<br>
tags = undefined,comments = undefined,body = undefined}]}<br>
</pre>

### Retrieving posts of only one type ###
The code snippet below shows how we can retrieve only text posts and then display (using a projection) the content of the text post.

<pre>
10> f(Conn).<br>
ok<br>
11> {ok,Conn}=mongo:connect(localhost).<br>
{ok,{connection,{"localhost",27017},<0.73.0>,infinity}}<br>
12> mongrel:do(safe, master, Conn, tumblelog, fun()-><br>
12> Cursor=mongrel:find(#post{body=#text_post{}}, #post{'_id'=0, body=#text_post{content=1}}),<br>
12> mongrel_cursor:rest(Cursor)<br>
12> end).<br>
{ok,[#post{'_id' = undefined,title = undefined,<br>
author = undefined,tags = undefined,comments = undefined,<br>
body = #text_post{content = <<"Took a look at mongoengine, looks pretty cool.">>}}]}<br>
</pre>

### Finding posts by tag ###
The code below shows how we can count all posts that have been tagged with 'mongodb'.

<pre>
13> f(Conn).<br>
ok<br>
14> {ok,Conn}=mongo:connect(localhost).<br>
{ok,{connection,{"localhost",27017},<0.80.0>,infinity}}<br>
15> mongrel:do(safe, master, Conn, tumblelog, fun()-><br>
15> mongrel:count(#post{tags= {'$in', [<<"mongodb">>]}})<br>
15> end).<br>
{ok,1}<br>
</pre>