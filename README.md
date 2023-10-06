# resty-umzila

The `resty-umzila` module serves as a flexible and efficient routing solution for OpenResty applications written in Lua.
It allows developers to define routes using HTTP methods and URL patterns, with support for named parameters like :
userId as well as wildcard sub-paths designated by an asterisk *. Routes are compiled at the time of registration for
optimized performance. The module matches incoming requests to the defined routes, extracts parameters and sub-paths,
and invokes the corresponding handler functions, passing in any captured values. If no route matches, the module returns
a "Not Found" HTTP 404 response.