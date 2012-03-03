-module(insert_test).

-export([test/0]).

-include("mongrel_macros.hrl").

% Our "domain objects" are a book, an author and a review
-record(book, {'_id', title, isbn, author, reviews}).
-record(author, {'_id', first_name, last_name}).
-record(review, {star_rating, comment}).

test() ->
	application:start(mongodb),
	application:start(mongrel),
	
	% For mongrel to work, we need to specify how to map books, authors and reviews.
	mongrel_mapper:add_mapping(?mapping(book)),
	mongrel_mapper:add_mapping(?mapping(author)),
	mongrel_mapper:add_mapping(?mapping(review)),
	
	% Create sample authors and a book records with reviews.
	% Notice we use a macro for assigning  _id's to books and authors
	Author1 = #author{?id(), last_name= <<"Dickens">>},
	Author2 = #author{?id(), last_name= <<"Wells">>, first_name= <<"Edmund">>},
	Book1 = #book{?id(), title= <<"David Copperfield">>, author=Author1},
	Book1WithReviews = Book1#book{reviews = [#review{star_rating=1, comment= <<"Turgid old nonsense">>}, 
										   #review{star_rating=4}]},
	Book2 = #book{?id(), title= <<"David Copperfield">>, author=Author2},
	Book2WithReviews = Book2#book{reviews = [#review{star_rating=5, comment= <<"More thorough than Dickens">>}]},
	Book3 = #book{?id(), title= <<"Grate Expectations">>, author=Author2},
	
	% Connect to MongoDB
	Host = {localhost, 27017},
	{ok, Conn} = mongo:connect(Host),
	
	% Use the mongrel insert_all function and the MongoDB driver to write the book records to the database
	{ok, _} = mongo:do(safe, master, Conn, mongrel_test, fun() ->
													   mongrel:insert_all([Book1WithReviews, Book2WithReviews, Book3])
			 end),
	
	mongo:do(safe, master, Conn, mongrel_test, fun() ->
													   mongrel:find(#book{})
			 end).

	%mongo:do(safe, master, Conn, mongrel_test, fun() ->
	%												   mongrel:delete(#book{title= {'$ne', <<"Grate Expectations">>}}),
	%												   mongrel:delete(#author{})
	%		 end).
