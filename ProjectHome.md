# Mongrel Mapper #

## Overview ##
Mongrel is a record/document mapper that maps Erlang records to MongoDB documents. The benefits of a mapper are:
  * More expressive code
  * Records can provide compile-time validity-checking that is not possible with tuples
  * Less code to handle associations between documents.

The Mongrel API is similar to the official MongoDB Erlang driver's API.

Mongrel aspires to be the Erlang equivalent of the MongoDB Object/Document mappers found in other languages, e.g. <a href='http://mongoengine.org/'>MongoEngine</a> for Python or <a href='http://code.google.com/p/morphia/'>Morphia</a> for Java.

## Installation ##
<a href='http://code.google.com/p/mongrel/downloads/list'>Download</a> the **mongrel-x.y.z.zip** archive. Unzip it to a location accessible from the Erlang environment, e.g. a directory referenced in the $ERL\_LIBS environment variable.

You will need to have installed the official MongoDB driver. You can download and build from the <a href='https://github.com/mongodb/mongodb-erlang'>official repository</a>. Alternatively, you can download a compiled binary from <a href='https://github.com/hammingweight/mongodb-erlang/downloads'>my fork</a>.

## Running Mongrel ##
Mongrel is an OTP application and can be started by executing `application:start(mongrel)`. Since Mongrel relies on the MongoDB driver, you will need to start the MongoDB driver application first (by running `application:start(mongodb)`).

## Documentation ##
The EDocs are included in the mongrel zip archive. The API is also documented <a href='http://mongrelmapper.appspot.com/api/index.html'>online</a>.

## A Mongrel Demo ##
### The MongoDB Driver ###
It's not essential to be familiar with the MongoDB driver but it may help. Two useful links are:
  * The MongoDB <a href='http://api.mongodb.org/erlang/mongodb/'>API</a>
  * A <a href='https://github.com/TonyGen/mongodb-erlang/blob/master/README.md'>readme</a> that illustrates the driver's use.

### Sample application ###
To demonstrate Mongrel Mapper, we'll populate a database with books from the Monty Python Bookshop Sketch.

<a href='http://www.youtube.com/watch?feature=player_embedded&v=eCM2nEBE0RY' target='_blank'><img src='http://img.youtube.com/vi/eCM2nEBE0RY/0.jpg' width='425' height=344 /></a>

The `book_database` module (below and included in the archive) exports three functions to:
  * Specify how to map records to documents
  * Populate the database
  * Read all books from the database.

```Erlang

-module(book_database).
-export([add_mappings/0, populate/0, get_all/0]).
-include_lib("mongrel/include/mongrel_macros.hrl").

% Our "domain objects" are books, authors and reviews
-record(book, {'_id', title, isbn, author, reviews}).
-record(author, {'_id', first_name, last_name}).
-record(review, {star_rating, comment}).

add_mappings() ->
% For mongrel to work, we need to specify how to map books, authors and reviews.
mongrel_mapper:add_mapping(?mapping(book)),
mongrel_mapper:add_mapping(?mapping(author)),
mongrel_mapper:add_mapping(?mapping(review)).

populate() ->
% Create some books, authors and reviews.
Author1 = #author{?id(), last_name = <<"Eliott">>},
Book1 = #book{?id(), title = <<"Thirty Days in the Samarkind Desert with the Duchess of Kent">>, author = Author1},
Review2 = #review{star_rating = 5, comment = <<"By an Irish gentleman whose name eludes me">>},
Book2 = #book{?id(),  title = <<"A Hundred and One Ways to start a Fight">>, reviews = [Review2]},
Author3 = #author{?id(), first_name = <<"Edmund">>, last_name = <<"Wells">>},
Book3 = #book{?id(), title = <<"David Copperfield">>, author = Author3},
Book4 = #book{?id(), title = <<"Grate Expectations">>, author = Author3},
Author5 = #author{?id(), first_name = <<"Charles">>, last_name = <<"Dikkens">>},
Book5 = #book{?id(), title = <<"Rarnaby Budge">>, author = Author5},
Review6a = #review{comment = <<"Warning: Not the expurgated version.">>},
Review6b = #review{star_rating = 2, comment = <<"Might be interesting to bird-watchers.">>},
Book6 = #book{?id(), title = <<"Olsen's Standard Book of British Birds">>, reviews = [Review6a, Review6b]},

{ok, Connection} = mongo:connect(localhost),
mongrel:do(safe, master, Connection, mongrel_books,
fun() ->
mongrel:delete(#author{}),
mongrel:delete(#book{}),
mongrel:insert_all([Book1, Book2, Book3, Book4, Book5, Book6])
end).

get_all() ->
{ok, Connection} = mongo:connect(localhost),
mongrel:do(safe, master, Connection, mongrel_books,
fun() ->
Cursor = mongrel:find(#book{}),
mongrel_cursor:rest(Cursor)
end).
```


### Domain Objects ###
The objects in our domain are:
  * Books
  * Authors
  * Reviews

These objects are specified in the records declared near the top of the source file. The most important feature to note of the records is
  * Book and author records have an '`_`id' field
  * Review records do not have an '`_`id' field.

If a record has an '`_`id' field, Mongrel assumes that the record must be stored in its own collection. A book review can only be associated with one book, so a book review can reasonably be stored as an attribute of a book in a collection of books, so we do not assign an '`_`id' attribute to a review.

### Code Overview ###
The code illustrates:
  * How to register record mappings (using the `mongrel_mapper:add_mapping/1` function and the `?mapping` macro). This is shown in the `add_mappings/0` function.
  * How to establish a connection to a database use the `mongo:connect/1` function. Note that this is function is exported by the MongoDB driver and is not part of mongrel.
  * How to invoke CRUD operations in an anonymous function invoked by the `mongrel:do/5` function. The `do/5` function specifies connection parameters (e.g., in this case writes are **safe**). The `mongrel:do/5` function has the same semantics as the `mongo:do/5` function but, you should use the mongrel function rather than the mongo function otherwise cursors will not be handled correctly.
  * How to do deletes using the `mongrel:delete/1` function. This function is similar to the driver's `mongo:delete/2` function.
  * How to do creates using the `mongrel:insert_all/1` function. This function is similar to the `mongo:insert_all/2` function.
  * How to do reads using the `mongrel:find/1` function. The `find/1` function returns a mongrel\_cursor:cursor() type. The `mongo:find/2` function is similar except that it returns a `mongo_cursor:cursor()` type.
  * How to retrieve results from a cursor, using the `mongrel_cursor:rest/1` function. The results are returned as a list of records. The driver's corresponding function, `mongo_cursor:rest/1`, returns a list where the elements are of type `bson:document()` rather than records.

### Running the Code ###
Make sure that the **mongod** server is running on localhost.

#### Adding the Record Mappings ####
To run the `book_database` code, you need to ensure that the `mongodb` and `mongrel` applications are started. Then execute `book_database:add_mappings()` as in the trace below.

<pre>
1> c(book_database).<br>
{ok,book_database}<br>
2> application:start(mongodb).<br>
ok<br>
3> application:start(mongrel).<br>
ok<br>
4> book_database:add_mappings().<br>
ok<br>
5><br>
</pre>

The `add_mappings/0` function invokes the `mongrel_mapper:add_mapping/1` function that stores {key, value} pairs where the key is the record name (e.g. book or author) and the value is a list of field identifiers (e.g. `_`id, title, isbn and author for a book record).

#### Populating the Database ####
The `book_database:populate/0` function creates some author, book and review records. Notice in particular, the use of the `?id()` macro that populates the `_id` fields of the book and author records. For example, `Author1 = #author{?id(), last_name = <<"Eliott">>}`. The `?id()` macro is defined as `'_id'=mongodb_app:gen_objectid()` and its purpose is to save time typing a commonly needed snippet of code.

The anonymous function passed as a parameter to the `mongrel:do/5` function deletes all book and author records from the `'mongrel_books'` database before populating it with the list of books passed to the `mongrel:insert_all/1` function.

Executing `book_database:populate()` will produce a result similar to that below where a list of six object identifiers is returned; the six ID's are the identifiers created for the six books.

<pre>
5> book_database:populate().<br>
{ok,[{<<79,92,226,190,138,250,150,9,38,0,0,2>>},<br>
{<<79,92,226,190,138,250,150,9,38,0,0,3>>},<br>
{<<79,92,226,190,138,250,150,9,38,0,0,5>>},<br>
{<<79,92,226,190,138,250,150,9,38,0,0,6>>},<br>
{<<79,92,226,190,138,250,150,9,38,0,0,8>>},<br>
{<<79,92,226,190,138,250,150,9,38,0,0,9>>}]}<br>
6><br>
</pre>

#### Reading the Database from the Mongo Shell ####
The `book_example:get_all/0` function retrieves all the books from the 'mongrel\_books' database. First, though, it's instructive to use the `mongo` shell to see what was written by the previous code execution. Switching to the `'mongrel_books'` database shows that author and book collections were added.

<pre>
> use mongrel_books<br>
switched to db mongrel_books<br>
> show collections<br>
author<br>
book<br>
system.indexes<br>
><br>
</pre>

Executing `db.book.find()` in the mongo shell produces output as below. There are a couple of points to note:
  * The `_`id attributes of the books are as returned by the execution of `book_database:populate()` execution from the Erlang shell
  * The author field of a book is populated with nested documents containing '#type' and '#id' fields (since author records have an '`_`id' field).
  * Review fields of a book are populated with the reviews (since review records do not have an '`_`id' field) but with the additional '#type' field.

<pre>
{ "_id" : ObjectId("4f5ce2be8afa960926000002"), "title" : "Thirty Days in the Samarkind Desert with the Duchess of Kent", "author" : { "#type" : "author", "#id" : ObjectId("4f5ce2be8afa960926000001") } }<br>
{ "_id" : ObjectId("4f5ce2be8afa960926000003"), "title" : "A Hundred and One Ways to start a Fight", "reviews" : [<br>
{<br>
"#type" : "review",<br>
"star_rating" : 5,<br>
"comment" : "By an Irish gentleman whose name eludes me"<br>
}<br>
] }<br>
{ "_id" : ObjectId("4f5ce2be8afa960926000005"), "title" : "David Copperfield", "author" : { "#type" : "author", "#id" : ObjectId("4f5ce2be8afa960926000004") } }<br>
{ "_id" : ObjectId("4f5ce2be8afa960926000006"), "title" : "Grate Expectations", "author" : { "#type" : "author", "#id" : ObjectId("4f5ce2be8afa960926000004") } }<br>
{ "_id" : ObjectId("4f5ce2be8afa960926000008"), "title" : "Rarnaby Budge", "author" : { "#type" : "author", "#id" : ObjectId("4f5ce2be8afa960926000007") } }<br>
{ "_id" : ObjectId("4f5ce2be8afa960926000009"), "title" : "Olsen's Standard Book of British Birds", "reviews" : [<br>
{<br>
"#type" : "review",<br>
"comment" : "Warning: Not the expurgated version."<br>
},<br>
{<br>
"#type" : "review",<br>
"star_rating" : 2,<br>
"comment" : "Might be interesting to bird-watchers."<br>
}<br>
] }<br>
</pre>

A similar query, `db.author.find()`, returns all authors

<pre>
> db.author.find()<br>
{ "_id" : ObjectId("4f5ce2be8afa960926000001"), "last_name" : "Eliott" }<br>
{ "_id" : ObjectId("4f5ce2be8afa960926000004"), "first_name" : "Edmund", "last_name" : "Wells" }<br>
{ "_id" : ObjectId("4f5ce2be8afa960926000007"), "first_name" : "Charles", "last_name" : "Dikkens" }<br>
><br>
</pre>

#### Reading the Database from Erlang ####
Executing `book_database:get_all()` retrieves all the books by getting a cursor to a result set by executing `mongrel:find(#book{})`. Since no fields of the book record are set in the argument to the `mongrel:find/1` function, all books match our query and the cursor contains the complete result set. We invoke the `mongrel_cursor:rest/1` function to get our result set as a list of books.

The trace below shows the result of executing the query (note that we use the shell `rr/1` function to import the record definitions from the code).

<pre>
7> rr(book_database).<br>
[author,book,review]<br>
8> book_database:get_all().<br>
{ok,[#book{<br>
'_id' = {<<79,92,226,190,138,250,150,9,38,0,0,2>>},<br>
title =<br>
<<"Thirty Days in the Samarkind Desert with the Duchess of Kent">>,<br>
isbn = undefined,<br>
author =<br>
#author{<br>
'_id' = {<<79,92,226,190,138,250,150,9,38,0,0,1>>},<br>
first_name = undefined,last_name = <<"Eliott">>},<br>
reviews = undefined},<br>
#book{<br>
'_id' = {<<79,92,226,190,138,250,150,9,38,0,0,3>>},<br>
title = <<"A Hundred and One Ways to start a Fight">>,<br>
isbn = undefined,author = undefined,<br>
reviews =<br>
[#review{<br>
star_rating = 5,<br>
comment =<br>
<<"By an Irish gentleman whose name eludes me">>}]},<br>
#book{<br>
'_id' = {<<79,92,226,190,138,250,150,9,38,0,0,5>>},<br>
title = <<"David Copperfield">>,isbn = undefined,<br>
author =<br>
#author{<br>
'_id' = {<<79,92,226,190,138,250,150,9,38,0,0,4>>},<br>
first_name = <<"Edmund">>,last_name = <<"Wells">>},<br>
reviews = undefined},<br>
#book{<br>
'_id' = {<<79,92,226,190,138,250,150,9,38,0,0,6>>},<br>
title = <<"Grate Expectations">>,isbn = undefined,<br>
author =<br>
#author{<br>
'_id' = {<<79,92,226,190,138,250,150,9,38,0,0,4>>},<br>
first_name = <<"Edmund">>,last_name = <<"Wells">>},<br>
reviews = undefined},<br>
#book{<br>
'_id' = {<<79,92,226,190,138,250,150,9,38,0,0,8>>},<br>
title = <<"Rarnaby Budge">>,isbn = undefined,<br>
author =<br>
#author{<br>
'_id' = {<<79,92,226,190,138,250,150,9,38,0,0,7>>},<br>
first_name = <<"Charles">>,last_name = <<"Dikkens">>},<br>
reviews = undefined},<br>
#book{<br>
'_id' = {<<79,92,226,190,138,250,150,9,38,0,0,9>>},<br>
title = <<"Olsen's Standard Book of British Birds">>,<br>
isbn = undefined,author = undefined,<br>
reviews =<br>
[#review{<br>
star_rating = undefined,<br>
comment = <<"Warning: Not the expurgated version.">>},<br>
#review{<br>
star_rating = 2,<br>
comment = <<"Might be interesting to bird-watchers.">>}]}]}<br>
</pre>

Notice how in the above query the author fields are populated with an author's details; we don't simply get the reference to an identifier in the authors collection.

## More Examples ##
[More examples](MongrelExamples.md) of using Mongrel with the book database can be found on the wiki. The wiki also contains a second example, TumbleLogExample, that demonstrates similar functionality to a <a href='http://mongoengine.org/docs/v0.5/tutorial.html'>MongoEngine tutorial</a>