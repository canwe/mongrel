# Prequisites #

The following trace shows how to compile the `book_database` and start the mongodb and mongrel applications from the shell. You will need to have started the mongod daemon on localhost.

<pre>
Eshell V5.8.3  (abort with ^G)<br>
1> c(book_database).<br>
{ok,book_database}<br>
2> application:start(mongodb).<br>
ok<br>
3> application:start(mongrel).<br>
ok<br>
4> rr(book_database).<br>
[author,book,review]<br>
5> book_database:add_mappings().<br>
ok<br>
6> book_database:populate().<br>
{ok,[{<<79,101,245,132,138,250,150,16,247,0,0,2>>},<br>
{<<79,101,245,132,138,250,150,16,247,0,0,3>>},<br>
{<<79,101,245,132,138,250,150,16,247,0,0,5>>},<br>
{<<79,101,245,132,138,250,150,16,247,0,0,6>>},<br>
{<<79,101,245,132,138,250,150,16,247,0,0,8>>},<br>
{<<79,101,245,132,138,250,150,16,247,0,0,9>>}]}<br>
7><br>
</pre>

If everything worked, you should be able to see book and author collections in the MongoDB mongrel\_books database.

From the erlang shell, you can check that the database was populated

<pre>
7> book_database:get_all().<br>
{ok,[#book{<br>
'_id' = {<<79,101,245,132,138,250,150,16,247,0,0,2>>},<br>
title =<br>
<<"Thirty Days in the Samarkind Desert with the Duchess of Kent">>,<br>
isbn = undefined,<br>
author =<br>
#author{<br>
'_id' = {<<79,101,245,132,138,250,150,16,247,0,0,1>>},<br>
first_name = undefined,last_name = <<"Eliott">>},<br>
reviews = undefined},<br>
#book{<br>
'_id' = {<<79,101,245,132,138,250,150,16,247,0,0,3>>},<br>
title = <<"A Hundred and One Ways to start a Fight">>,<br>
isbn = undefined,author = undefined,<br>
reviews =<br>
[#review{<br>
star_rating = 5,<br>
comment =<br>
<<"By an Irish gentleman whose name eludes me">>}]},<br>
#book{<br>
'_id' = {<<79,101,245,132,138,250,150,16,247,0,0,5>>},<br>
title = <<"David Copperfield">>,isbn = undefined,<br>
author =<br>
#author{<br>
'_id' = {<<79,101,245,132,138,250,150,16,247,0,0,4>>},<br>
first_name = <<"Edmund">>,last_name = <<"Wells">>},<br>
reviews = undefined},<br>
#book{<br>
'_id' = {<<79,101,245,132,138,250,150,16,247,0,0,6>>},<br>
title = <<"Grate Expectations">>,isbn = undefined,<br>
author =<br>
#author{<br>
'_id' = {<<79,101,245,132,138,250,150,16,247,0,0,4>>},<br>
first_name = <<"Edmund">>,last_name = <<"Wells">>},<br>
reviews = undefined},<br>
#book{<br>
'_id' = {<<79,101,245,132,138,250,150,16,247,0,0,8>>},<br>
title = <<"Rarnaby Budge">>,isbn = undefined,<br>
author =<br>
#author{<br>
'_id' = {<<79,101,245,132,138,250,150,16,247,0,0,7>>},<br>
first_name = <<"Charles">>,last_name = <<"Dikkens">>},<br>
reviews = undefined},<br>
#book{<br>
'_id' = {<<79,101,245,132,138,250,150,16,247,0,0,9>>},<br>
title = <<"Olsen's Standard Book of British Birds">>,<br>
isbn = undefined,author = undefined,<br>
reviews =<br>
[#review{<br>
star_rating = undefined,<br>
comment = <<"Warning: Not the expurgated version.">>},<br>
#review{<br>
star_rating = 2,<br>
comment = <<"Might be interesting to bird-watchers.">>}]}]}<br>
8><br>
</pre>