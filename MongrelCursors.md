# Mongrel Cursors #

Mongrel cursors have two important attributes:
  * Retrieving a result from a cursor may result in a trip to the database.
  * Cursors cannot be used outside of the scope of the `mongrel:do/5` function unless a timeout is specifically set for the cursor.

## Cursors and Multiple Database Visits ##
The first attribute may be surprising since the point of cursors is to get several results in one read to reduce the overhead of making several visits to the database. The good news is that retrieving a result from a cursor's result set only involves hitting the database if a result references a nested document. If you don't want to hit the database to retrieve nested documents you have two choices:
  * Get a projection of the result that ignores nested documents
  * Get the underlying MongoDB cursor using the `mongrel_cursor:get_mongo_cursor/1` function and retrieve the result set from the MongoDB cursor.

## Cursors and Function Scope ##
We illustrate the difference between the `mongo_cursor` and `mongrel_cursor` behavior by means of an example that gets the authors of all books in the `mongrel_books` database.

Using the `mongodb` driver:

<pre>
15> f().<br>
ok<br>
16> {ok, Conn}=mongo:connect(localhost).<br>
{ok,{connection,{"localhost",27017},<0.76.0>,infinity}}<br>
17> {ok,Cursor}=mongo:do(safe,master,Conn,mongrel_books,fun()-><br>
17> mongo:find(author,{})<br>
17> end).<br>
{ok,<0.78.0>}<br>
18> mongo_cursor:rest(Cursor).<br>
[{'_id',{<<79,138,150,247,138,250,150,23,62,0,0,1>>},<br>
last_name,<<"Eliott">>},<br>
{'_id',{<<79,138,150,247,138,250,150,23,62,0,0,4>>},<br>
first_name,<<"Edmund">>,last_name,<<"Wells">>},<br>
{'_id',{<<79,138,150,247,138,250,150,23,62,0,0,7>>},<br>
first_name,<<"Charles">>,last_name,<<"Dikkens">>}]<br>
19><br>
</pre>
The cursor can be used outside the scope of the `mongo:do/5` function.

Now, using Mongrel:
<pre>
19> f().<br>
ok<br>
20> {ok, Conn}=mongo:connect(localhost).<br>
{ok,{connection,{"localhost",27017},<0.82.0>,infinity}}<br>
21> {ok,Cursor}=mongrel:do(safe,master,Conn,mongrel_books,fun()-><br>
21> mongrel:find(#author{})<br>
21> end).<br>
{ok,<0.86.0>}<br>
22> mongrel_cursor:rest(Cursor).<br>
** exception exit: {noproc,{gen_server,call,[<0.86.0>,rest,infinity]}}<br>
in function  gen_server:call/3<br>
23><br>
</pre>

Trying to use the cursor outside of the scope of the `do/5` funcfion throws a `noproc` exception. This is since the cursor process is terminated once the `do/5` function completes.

The reason that Mongrel terminates cursors is to avoid memory leaks if an application creates cursors but doesn't close the cursors either explicitly (by invoking the `close/1` function) or implicitly (by invoking the `rest/1` function). An alternative to preventing the problem of cursor processes never terminating is to explicitly set a timeout; if the cursor is not invoked in the specified time, the cursor terminates. This is illustrated below where the cursor is available outside of the mongrel:do/5 function but terminates after 30 seconds of inactivity.

<pre>
28> f().<br>
ok<br>
29> {ok,Conn}=mongo:connect(localhost).<br>
{ok,{connection,{"localhost",27017},<0.90.0>,infinity}}<br>
30> {ok,Cursor}=mongrel:do(safe,master,Conn,mongrel_books,fun()-><br>
30> Crsr=mongrel:find(#author{}),<br>
30> mongrel_cursor:set_timeout(Crsr,30000),<br>
30> Crsr<br>
30> end).<br>
{ok,<0.94.0>}<br>
31> mongrel_cursor:next(Cursor).<br>
#author{'_id' = {<<79,150,50,133,138,250,150,15,87,0,0,1>>},<br>
first_name = undefined,last_name = <<"Eliott">>}<br>
32> is_process_alive(Cursor).<br>
true<br>
33> timer:sleep(30000).<br>
ok<br>
34> is_process_alive(Cursor).<br>
false<br>
35> mongrel_cursor:next(Cursor).<br>
** exception exit: {noproc,{gen_server,call,[<0.94.0>,next,infinity]}}<br>
in function  gen_server:call/3<br>
36><br>
</pre>