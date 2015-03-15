# Adding Mongrel as a Rebar Dependency #

If you want to include Mongrel as a dependency in a rebar.config file, include the following

```
{deps, [
    ...
    {mongrel, ".*", {svn, "http://mongrel.googlecode.com/svn/trunk/", "HEAD"}},
    ...
]}
```