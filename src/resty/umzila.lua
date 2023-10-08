local M = {
    version = '1.0.1'
}

-- Private variables
local routes = {}

-- Private function
local function compile_path(path)
    local params = {}
    local pattern = path:gsub('(:%w+)', function(param)
        table.insert(params, param:sub(2))
        return '([%w-_]+)'
    end)
    pattern = pattern:gsub('%*', '(.*)')
    return '^' .. pattern .. '$', params
end

local function ensure_starts_with_slash(str)
    if string.sub(str, 1, 1) ~= "/" then
        return "/" .. str
    end
    return str
end

-- Public function
function M.router(method, path, handler)
    method = string.upper(method)
    if not routes[method] then
        routes[method] = {}
    end
    local pattern, params_keys = compile_path(path)
    routes[method][path] = { handler = handler, pattern = pattern, params_keys = params_keys }
end

-- Public function
function M.handle_request()
    local method = ngx.req.get_method()
    local uri = ngx.var.uri
    print("Handling request: ", method, uri) -- Debug statement

    if routes[method] then
        for path, route_data in pairs(routes[method]) do
            print(path)
            print("Checking against route pattern: ", route_data.pattern) -- Debug statement
            local matches = { string.match(uri, route_data.pattern) }

            if #matches > 0 then
                local params = {}

                for i, k in ipairs(route_data.params_keys) do
                    params[k] = matches[i]
                end

                if path:find('%*') then
                    params["wildcard"] = matches[#matches]
                end

                local handler = route_data.handler
                if type(handler) == "table" then
                    handler = handler[1]  -- Assuming the function is always the first element in the table
                end

                handler(params)
                return
            end
        end
    end

    ngx.status = ngx.HTTP_NOT_FOUND
    ngx.say("Not found")
end

-- Private function
local function get_route_method(file)
    return file:match("^.+/(.+).lua$")
end

-- Private function
local function scan_routes(directory)
    local i, t, popen = 0, {}, io.popen
    local p_files = popen('find "' .. directory .. '" -type f')

    for filename in p_files:lines() do
        i = i + 1
        t[i] = filename:gsub("%./", "/")
    end

    p_files:close()

    return t
end

-- Public function
function M.load_routes(directory, mount)
    local files = scan_routes(directory)

    if mount == nil or mount == '/' then
        mount = ''
    end

    for _, v in ipairs(files) do
        local url_raw = v:gsub('%$', ":")
        local handler_raw = v:gsub("%/", "."):sub(1):match('(.+).lua$')

        local modified_url_raw = url_raw:gsub("^" .. directory, mount):sub(1)
        print(modified_url_raw)

        local route_item = {
            path = v,
            handler = handler_raw,
            routePath = modified_url_raw:gsub(url_raw:match('^.+(/.+)$'), ''),
            method = get_route_method(v):upper()
        }

        -- Initialize the method routes if not already initialized
        if not routes[route_item.method] then
            routes[route_item.method] = {}
        end

        if (routes[route_item.method][route_item.routePath] == nil) then
            print('\n' .. route_item.method .. '\n' .. ensure_starts_with_slash(route_item.routePath) .. '\n')  -- Debug statement
            M.router(route_item.method, ensure_starts_with_slash(route_item.routePath), require(route_item.handler))
        end
    end
end

return M
