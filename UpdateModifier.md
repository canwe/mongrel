# Update Modifiers #

MongoDB has the following modifiers for updating part of a document:

  * $set
  * $unset
  * $inc
  * $push
  * $pop
  * $pull
  * $each
  * $addToSet

The modifiers above can be used with Mongrel.

## Modifiers and Nested Documents ##
Updates using modifiers are atomic when used with the MongoDB driver. Updates using the `mongrel:modify/2` function are not atomic though when the update affects a nested reference document, i.e. if there is an _association_ between two documents and both are affected by the update.

For example, suppose we want to find all books for which we haven't specified an author and that we want to (bizarrely) specify the author of those books as anonymous as in the code below

<pre>
26> {ok, Conn}=mongo:connect(localhost).<br>
{ok,{connection,{"localhost",27017},<0.107.0>,infinity}}<br>
27> mongrel:do(safe, master, Conn, mongrel_books, fun() -><br>
27> Anon=#author{last_name= <<"Anonymous">>, '_id'=mongrel_types:id()},<br>
27> mongrel:modify(#book{author= {'$exists', false}}, {'$set', #book{author=Anon}})<br>
27> end).<br>
{ok,ok}<br>
</pre>

The code above would result in updates to both the book collection and an insert to the author collection to add the new (anonymous) author. The updates to the book collection and the author collection are obviously not atomic.