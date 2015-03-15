# Creating Documents #

There are two functions for creating documents:
  * `insert/1`
  * `insert_all/1`

The `book_database` module illustrates the use of `insert_all`.

## Inserting a Single Document ##
Our book database is missing the book "Biggles Combs his Hair". We can create this entry in the database by using the `mongrel:insert/1` function (as usual, make sure that **mongod** is running and that the database has been populated). The `insert` function returns the object identifier of the new record.

<pre>
7> {ok, Conn} = mongo:connect(localhost).<br>
{ok,{connection,{"localhost",27017},<0.63.0>,infinity}}<br>
8> rr(book_database).<br>
[author,book,review]<br>
9> mongrel:do(safe, master, Conn, mongrel_books, fun() -><br>
9> mongrel:insert(#book{title = <<"Biggles Combs his Hair">>}) end).<br>
{ok,{<<79,94,66,196,138,250,150,13,65,0,0,19>>}}<br>
</pre>

If we now query the database, we get the recently inserted book.

<pre>
10> book_database:get_all().<br>
{ok,[#book{<br>
'_id' = {<<79,94,66,114,138,250,150,13,65,0,0,11>>},<br>
title =<br>
<<"Thirty Days in the Samarkind Desert with the Duchess of Kent">>,<br>
isbn = undefined,<br>
author =<br>
#author{<br>
'_id' = {<<79,94,66,114,138,250,150,13,65,0,0,10>>},<br>
first_name = undefined,last_name = <<"Eliott">>},<br>
reviews = undefined},<br>
#book{<br>
'_id' = {<<79,94,66,114,138,250,150,13,65,0,0,12>>},<br>
title = <<"A Hundred and One Ways to start a Fight">>,<br>
isbn = undefined,author = undefined,<br>
reviews =<br>
[#review{<br>
star_rating = 5,<br>
comment =<br>
<<"By an Irish gentleman whose name eludes me">>}]},<br>
#book{<br>
'_id' = {<<79,94,66,114,138,250,150,13,65,0,0,14>>},<br>
title = <<"David Copperfield">>,isbn = undefined,<br>
author =<br>
#author{<br>
'_id' = {<<79,94,66,114,138,250,150,13,65,0,0,13>>},<br>
first_name = <<"Edmund">>,last_name = <<"Wells">>},<br>
reviews = undefined},<br>
#book{<br>
'_id' = {<<79,94,66,114,138,250,150,13,65,0,0,15>>},<br>
title = <<"Grate Expectations">>,isbn = undefined,<br>
author =<br>
#author{<br>
'_id' = {<<79,94,66,114,138,250,150,13,65,0,0,13>>},<br>
first_name = <<"Edmund">>,last_name = <<"Wells">>},<br>
reviews = undefined},<br>
#book{<br>
'_id' = {<<79,94,66,114,138,250,150,13,65,0,0,17>>},<br>
title = <<"Rarnaby Budge">>,isbn = undefined,<br>
author =<br>
#author{<br>
'_id' = {<<79,94,66,114,138,250,150,13,65,0,0,16>>},<br>
first_name = <<"Charles">>,last_name = <<"Dikkens">>},<br>
reviews = undefined},<br>
#book{<br>
'_id' = {<<79,94,66,114,138,250,150,13,65,0,0,18>>},<br>
title = <<"Olsen's Standard Book of British Birds">>,<br>
isbn = undefined,author = undefined,<br>
reviews =<br>
[#review{<br>
star_rating = undefined,<br>
comment = <<"Warning: Not the expurgated version.">>},<br>
#review{<br>
star_rating = 2,<br>
comment = <<"Might be interesting to bird-watchers.">>}]},<br>
#book{<br>
'_id' = {<<79,94,66,196,138,250,150,13,65,0,0,19>>},<br>
title = <<"Biggles Combs his Hair">>,isbn = undefined,<br>
author = undefined,reviews = undefined}]}<br>
11><br>
</pre>