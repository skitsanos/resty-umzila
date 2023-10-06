# resty-umzila

The `resty-umzila` module serves as a flexible and efficient routing solution for OpenResty applications written in Lua.
It allows developers to define routes using HTTP methods and URL patterns, with support for named parameters like :
userId as well as wildcard sub-paths designated by an asterisk *. Routes are compiled at the time of registration for
optimized performance. The module matches incoming requests to the defined routes, extracts parameters and sub-paths,
and invokes the corresponding handler functions, passing in any captured values. If no route matches, the module returns
a "Not Found" HTTP 404 response.

The following is a minimal `nginx.conf` configuration that demonstrates how to use the `resty-umzila` module within an
OpenResty setup. Make sure your `resty/umzila.lua` file is placed in a directory that is part of Lua's package path, or
adjust the `lua_package_path` directive accordingly

```
worker_processes  1;

events {
    worker_connections  1024;
}

http {
    server {
        listen       8080;
        server_name  localhost;

        location / {
            content_by_lua_block {
                local router = require "resty.umzila"

                router.register('GET', '/', function(params)
                    ngx.say("Welcome to the home page")
                end)

                router.register('GET', '/users/:userId', function(params)
                    ngx.say("User ID: " .. params.userId)
                end)

                router.register('GET', '/downloads/*', function(params)
                    ngx.say("Downloads, sub-path: " .. params.wildcard)
                end)

                router.handle_request()
            }
        }

        # Additional configuration and other locations
    }

    # Additional server blocks
}

```

Here's a quick rundown of the key parts:

- `worker_processes` and `events`: Basic Nginx setup.
- `listen 8080;`: The server listens on port 8080.
- `content_by_lua_block`: OpenResty's directive for inline Lua code.
- `local router = require "resty.umzila"`: Requires your resty-umzila Lua module.
- `router.register`: Register routes and their handler functions.
- `router.handle_request()`: Invokes the router to handle incoming requests.

- With this configuration, navigating to `http://localhost:8080/` would execute the function that says "Welcome to the home
page". Similarly, `http://localhost:8080/users/123` would display "User ID: 123",
and `http://localhost:8080/downloads/sub-path/example` would show "Downloads, sub-path: sub-path/example".