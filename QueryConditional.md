# Mongrel and Query Conditionals #

MongoDB supports "query operators" or "query conditionals" in read, update and delete functions to restrict the number of affected documents. You can use the following conditionals with Mongrel

  * $all
  * $and
  * $exists
  * $gt and $gte
  * $lt and $lte
  * $in
  * $mod
  * $nin
  * $not
  * $or
  * $size

A query conditional is expressed as a tuple of {key, value} pairs where the key is one of the above operators. For example, {'$in', [1,2,4]} limits results so that only documents where some value is 1, 2 or 4 will be read, updated or deleted. Similarly {'$gt', 7, '$lte', 10} will ensure that some value is greater than 7 but less than or equal to 10.

Query operators allow for some quite powerful queries to be written concisely. For example, the code below finds all books that have precisely two reviews.

<pre>
29> {ok,Conn}=mongo:connect(localhost).<br>
{ok,{connection,{"localhost",27017},<0.127.0>,infinity}}<br>
30> mongrel:do(safe, master, Conn, mongrel_books, fun() -><br>
30> Cursor=mongrel:find(#book{reviews={'$size', 2}}),<br>
30> mongrel_cursor:rest(Cursor)<br>
30> end).<br>
{ok,[#book{<br>
'_id' = {<<79,100,63,164,138,250,150,17,130,0,0,9>>},<br>
title = <<"Olsen's Standard Book of British Birds">>,<br>
isbn = undefined,author = undefined,<br>
reviews =<br>
[#review{<br>
star_rating = undefined,<br>
comment = <<"Warning: Not the expurgated version.">>},<br>
#review{<br>
star_rating = 2,<br>
comment = <<"Might be interesting to bird-watchers.">>}]}]}<br>
31><br>
</pre>

## Query Conditionals and Nested Documents ##
Query operators can get messy when referencing nested documents; i.e if there is an association between documents. When wanting to restrict a result set based on the value in a nested document, you might find it easier to use the `mongo` module directly rather than `mongrel`. If you use `mongo`, you might lose some validity-checking associated with records but improve readability. For example

<pre>
mongrel:count(#book{author=#author{'_id'={'$ne', EdmundWells#author.'_id'}}})<br>
</pre>
is more verbose and consequently less readable than
<pre>
mongo:count(book, {'author.#id', {'$ne', EdmundWells#author.'_id'}})<br>
</pre>



