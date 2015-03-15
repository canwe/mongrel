# Update Examples #

Mongrel has the following functions for updating zero or more documents:
  * `modify/2`
  * `replace/2`
  * `repsert/2`
  * `save/1`

## Replacing a Document ##
The simplest way to update a document, is to replace the entire document.

The code below shows how we can add a review for "Rarnaby Budge" by Charles Dikkens (with two "k"s). To update the document, we get the book record and then replace it with an updated book record containing a review.

<pre>
12> {ok,Conn}=mongo:connect(localhost).<br>
{ok,{connection,{"localhost",27017},<0.70.0>,infinity}}<br>
13> mongrel:do(safe, master, Conn, mongrel_books, fun() -><br>
13> Book = mongrel:find_one(#book{title= <<"Rarnaby Budge">>}),<br>
13> mongrel:replace(Book, Book#book{reviews = [#review{comment= <<"The well known Dutch author surpasses himself!">>}]})<br>
13> end).<br>
{ok,[ok]}<br>
</pre>

## Modifying Documents ##
If we only want to update part of a document, it is frequently possible to use an UpdateModifier to replace only part of the document. For example,
we misspelled the title of Edmund Wells' magnus opus as "David Copperfield" with two "p"s and want to correct it. We can use a regex to find the book (by searching for a book whose title starts case-insentively with "david cop")  and a '$set' modifier to correct its title.

<pre>
21> f().<br>
ok<br>
22> {ok,Conn}=mongo:connect(localhost).<br>
{ok,{connection,{"localhost",27017},<0.90.0>,infinity}}<br>
23> mongrel:do(safe, master, Conn, mongrel_books, fun() -><br>
23> mongrel:modify(#book{title={regex, <<"^david cop">>, <<"i">>}},{'$set', #book{title= <<"David Coperfield">>}})<br>
23> end).<br>
{ok,ok}<br>
</pre>

If we decide that the second review of "Olsen's Book of British Birds" is a waste of space, we can use the '$pop' modifier to remove it as follows (again, we locate the book using a regex)

<pre>
25> mongrel:do(safe, master, Conn, mongrel_books, fun() -><br>
25> mongrel:modify(#book{title={regex, <<"^olsen">>, <<"i">>}},{'$pop', #book{reviews= 1}})<br>
25> end).<br>
{ok,ok}<br>
</pre>

## Seeing our Changes ##
If we invoke `book_database:get_all()` we can see the updated list of books

<pre>
26> book_database:get_all().<br>
{ok,[#book{<br>
'_id' = {<<79,98,59,46,138,250,150,12,57,0,0,2>>},<br>
title =<br>
<<"Thirty Days in the Samarkind Desert with the Duchess of Kent">>,<br>
isbn = undefined,<br>
author =<br>
#author{<br>
'_id' = {<<79,98,59,46,138,250,150,12,57,0,0,1>>},<br>
first_name = undefined,last_name = <<"Eliott">>},<br>
reviews = undefined},<br>
#book{<br>
'_id' = {<<79,98,59,46,138,250,150,12,57,0,0,3>>},<br>
title = <<"A Hundred and One Ways to start a Fight">>,<br>
isbn = undefined,author = undefined,<br>
reviews =<br>
[#review{<br>
star_rating = 5,<br>
comment =<br>
<<"By an Irish gentleman whose name eludes me">>}]},<br>
#book{<br>
'_id' = {<<79,98,59,46,138,250,150,12,57,0,0,5>>},<br>
title = <<"David Coperfield">>,isbn = undefined,<br>
author =<br>
#author{<br>
'_id' = {<<79,98,59,46,138,250,150,12,57,0,0,4>>},<br>
first_name = <<"Edmund">>,last_name = <<"Wells">>},<br>
reviews = undefined},<br>
#book{<br>
'_id' = {<<79,98,59,46,138,250,150,12,57,0,0,6>>},<br>
title = <<"Grate Expectations">>,isbn = undefined,<br>
author =<br>
#author{<br>
'_id' = {<<79,98,59,46,138,250,150,12,57,0,0,4>>},<br>
first_name = <<"Edmund">>,last_name = <<"Wells">>},<br>
reviews = undefined},<br>
#book{<br>
'_id' = {<<79,98,59,46,138,250,150,12,57,0,0,9>>},<br>
title = <<"Olsen's Standard Book of British Birds">>,<br>
isbn = undefined,author = undefined,<br>
reviews =<br>
[#review{<br>
star_rating = undefined,<br>
comment = <<"Warning: Not the expurgated version.">>}]},<br>
#book{<br>
'_id' = {<<79,98,59,46,138,250,150,12,57,0,0,8>>},<br>
title = <<"Rarnaby Budge">>,isbn = undefined,<br>
author =<br>
#author{<br>
'_id' = {<<79,98,59,46,138,250,150,12,57,0,0,7>>},<br>
first_name = <<"Charles">>,last_name = <<"Dikkens">>},<br>
reviews =<br>
[#review{<br>
star_rating = undefined,<br>
comment =<br>
<<"The well known Dutch author surpasses himsel"...>>}]}]}<br>
27><br>
</pre>