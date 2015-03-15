# Read Examples #

Mongrel has the following functions for reading documents:
  * `count/1`
  * `count/2`
  * `find/1`
  * `find/2`
  * `find/3`
  * `find/4`
  * `find_one/1`
  * `find_one/2`
  * `find_one/3`

## Basic Finds ##
To find a single author, we can use the `find_one/1` function:

<pre>
10> {ok, Conn}=mongo:connect(localhost).<br>
{ok,{connection,{"localhost",27017},<0.64.0>,infinity}}<br>
11> mongrel:do(safe,master,Conn,mongrel_books,fun()-><br>
11> mongrel:find_one(#author{})<br>
11> end).<br>
{ok,#author{'_id' = {<<79,138,150,247,138,250,150,23,62,<br>
0,0,1>>},<br>
first_name = undefined,last_name = <<"Eliott">>}}<br>
12><br>
</pre>

To get all authors, we can use the `find/1` function that returns a `mongrel_cursor`. The `mongrel_cursor:rest/1` function returns all the results from the cursor. See the MongrelCursors page for some details of what you should know about Mongrel cursors; the most important point is that you **cannot** use a Mongrel cursor outside of the scope of the `mongrel:do/5` function.

<pre>
12> f().<br>
ok<br>
13> {ok, Conn}=mongo:connect(localhost).<br>
{ok,{connection,{"localhost",27017},<0.69.0>,infinity}}<br>
14> mongrel:do(safe,master,Conn,mongrel_books,fun()-><br>
14> Cursor=mongrel:find(#author{}),<br>
14> mongrel_cursor:rest(Cursor)<br>
14> end).<br>
{ok,[#author{'_id' = {<<79,138,150,247,138,250,150,23,62,<br>
0,0,1>>},<br>
first_name = undefined,last_name = <<"Eliott">>},<br>
#author{'_id' = {<<79,138,150,247,138,250,150,23,62,0,0,4>>},<br>
first_name = <<"Edmund">>,last_name = <<"Wells">>},<br>
#author{'_id' = {<<79,138,150,247,138,250,150,23,62,0,0,7>>},<br>
first_name = <<"Charles">>,last_name = <<"Dikkens">>}]}<br>
15><br>
</pre>

## Counting Documents ##
The example code below shows how to count all the books written by Edmund Wells.

<pre>
10> f().<br>
ok<br>
11> {ok,Conn}=mongo:connect(localhost).<br>
{ok,{connection,{"localhost",27017},<0.68.0>,infinity}}<br>
12> mongrel:do(safe, master, Conn, mongrel_books, fun() -><br>
12> EdmundWells = mongrel:find_one(#author{first_name= <<"Edmund">>, last_name= <<"Wells">>}),<br>
12> mongrel:count(#book{author=EdmundWells})<br>
12> end).<br>
{ok,2}<br>
</pre>

Using the Mongrel API to find all the books not written by Edmund Wells is more complicated, and we have to use a '$ne' QueryConditional

<pre>
10> mongrel:do(safe, master, Conn, mongrel_books, fun() -><br>
10> EdmundWells = mongrel:find_one(#author{first_name= <<"Edmund">>, last_name= <<"Wells">>}),<br>
10> mongrel:count(#book{author=#author{'_id'={'$ne', EdmundWells#author.'_id'}}})<br>
10> end).<br>
{ok,4}<br>
</pre>

That query may be seen as so complicated that it may be simpler use the `mongo` count/2 function instead. Contrast the above code with the code below.

<pre>
11> mongrel:do(safe, master, Conn, mongrel_books, fun() -><br>
11> EdmundWells=mongrel:find_one(#author{first_name= <<"Edmund">>, last_name= <<"Wells">>}),<br>
11> mongo:count(book, {'author.#id', {'$ne', EdmundWells#author.'_id'}})<br>
11> end).<br>
{ok,4}<br>
</pre>

## Finding Projections of Documents ##
Suppose that we want to find all book titles that don't have an upper- or lower-case 'H' anywhere in the title. The query below shows a suitable query. The second argument to the find/2 function gets a projection of only the book titles. We write a somewhat clumsy expression that uses both a regular expression and a QueryConditional ('$not') for illustrative purposes.

<pre>
18> {ok, Books}=mongrel:do(safe, master, Conn, mongrel_books, fun() -><br>
18> Cursor=mongrel:find(#book{title= {'$not', {regex, <<"h">>, <<"i">>}}}, #book{title=1}),<br>
18> mongrel_cursor:rest(Cursor)<br>
18> end).<br>
{ok,[#book{'_id' = {<<79,137,174,200,138,250,150,14,249,<br>
0,0,14>>},<br>
title = <<"David Copperfield">>,isbn = undefined,<br>
author = undefined,reviews = undefined},<br>
#book{'_id' = {<<79,137,174,200,138,250,150,14,249,0,0,15>>},<br>
title = <<"Grate Expectations">>,isbn = undefined,<br>
author = undefined,reviews = undefined},<br>
#book{'_id' = {<<79,137,174,200,138,250,150,14,249,0,0,17>>},<br>
title = <<"Rarnaby Budge">>,isbn = undefined,<br>
author = undefined,reviews = undefined}]}<br>
19><br>
</pre>

## Advanced Queries ##
MongoDB allows options to be passed with a query such as 'hint' of an index to use when executing the query or that the results must be ordered in some way. We issue queries with options using a tuple of key-value pairs where one key must be '$query' and the corresponding value is a record that we want to use when selecting results.

If we want to issue a query where we order our results we need to supply a document to the find function with '$query' and '$orderby' keys. For example, the code below finds all books with a "T" somewhere in the title and returns them in alphabetical order

<pre>
21> f().<br>
ok<br>
22> {ok,Conn}=mongo:connect(localhost).<br>
{ok,{connection,{"localhost",27017},<0.85.0>,infinity}}<br>
23> {ok, Books}=mongrel:do(safe, master, Conn, mongrel_books, fun() -><br>
23> Cursor=mongrel:find({'$orderby', #book{title=1}, '$query', #book{title= {regex, <<"t">>, <<"i">>}}}, #book{title=1, '_id'=0}),<br>
23> mongrel_cursor:rest(Cursor)<br>
23> end).<br>
{ok,[#book{'_id' = undefined,<br>
title = <<"A Hundred and One Ways to start a Fight">>,<br>
isbn = undefined,author = undefined,reviews = undefined},<br>
#book{'_id' = undefined,title = <<"Grate Expectations">>,<br>
isbn = undefined,author = undefined,reviews = undefined},<br>
#book{'_id' = undefined,<br>
title = <<"Olsen's Standard Book of British Birds">>,<br>
isbn = undefined,author = undefined,reviews = undefined},<br>
#book{'_id' = undefined,<br>
title = <<"Thirty Days in the Samarkind Desert with the Duchess of Kent">>,<br>
isbn = undefined,author = undefined,reviews = undefined}]}<br>
24><br>
<br>
</pre>