# Building Mongrel #

## Checking out the Source Code ##
The Mongrel source code can be checked out from the subversion repository using svn
```
svn checkout http://mongrel.googlecode.com/svn/trunk/ mongrel
```


## Making and Packaging Mongrel ##
Under Linux, the **make\_mongrel.sh** bash script can be used to build the project
```
cd mongrel
./make_mongrel.sh
```
The bash script compiles the code, runs the unit tests, generates the API documents and creates a zip archive.


## Using Rebar to Build ##
After checking out the code, you can compile, test and generate the EDocs using rebar as
```
cd mongrel
rebar compile
rebar eunit
rebar doc
```

Also, see AddingMongrelAsRebarDependency for details on adding Mongrel as a rebar dependency.