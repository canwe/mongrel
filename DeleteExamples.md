# Delete Examples #

Mongrel has the following functions to delete entries from collections
  * delete/1
  * delete\_one/1

## Deleting ##
Supposing that we decide that we don't like the works of Edmund Wells, the following code shows the use of `delete/1` to delete his works from the books collection and the use of `delete_one/1` to delete him from the authors collection.

<pre>
6> {ok,Conn}=mongo:connect(localhost).<br>
{ok,{connection,{"localhost",27017},<0.57.0>,infinity}}<br>
7> mongrel:do(safe, master, Conn, mongrel_books, fun() -><br>
7> EdmundWells = mongrel:find_one(#author{first_name= <<"Edmund">>, last_name= <<"Wells">>}),<br>
7> mongrel:delete(#book{author=EdmundWells}),<br>
7> mongrel:delete_one(EdmundWells)<br>
7> end).<br>
{ok,ok}<br>
</pre>

If we query the database from the mongo shell we can see that Edmund Wells has been deleted from the author collection and his books deleted from the book collection

<pre>
> use mongrel_books<br>
switched to db mongrel_books<br>
> db.author.find()<br>
{ "_id" : ObjectId("4f62cb0c8afa961212000001"), "last_name" : "Eliott" }<br>
{ "_id" : ObjectId("4f62cb0c8afa961212000007"), "first_name" : "Charles", "last_name" : "Dikkens" }<br>
> db.book.find()<br>
{ "_id" : ObjectId("4f62cb0c8afa961212000002"), "title" : "Thirty Days in the Samarkind Desert with the Duchess of Kent",<br>
"author" : { "#type" : "author", "#id" : ObjectId("4f62cb0c8afa961212000001") } }<br>
{ "_id" : ObjectId("4f62cb0c8afa961212000003"), "title" : "A Hundred and One Ways to start a Fight", "reviews" : [<br>
{<br>
"#type" : "review",<br>
"star_rating" : 5,<br>
"comment" : "By an Irish gentleman whose name eludes me"<br>
}<br>
] }<br>
{ "_id" : ObjectId("4f62cb0c8afa961212000008"), "title" : "Rarnaby Budge",<br>
"author" : { "#type" : "author", "#id" : ObjectId("4f62cb0c8afa961212000007") } }<br>
{ "_id" : ObjectId("4f62cb0c8afa961212000009"), "title" : "Olsen's Standard Book of British Birds", "reviews" : [<br>
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
><br>
<br>
</pre>