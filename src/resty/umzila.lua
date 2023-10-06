local routes = {}
local ngx = ngx

local function compile_path(path)
    local params = {}
    local pattern = path:gsub('(:%w+)', function(param)
        table.insert(params, param:sub(2))
        return '([%w-_]+)'
    end)
    pattern = pattern:gsub('%*', '(.*)')
    return '^' .. pattern .. '$', params
end

function router(method, path, handler)
    method = string.upper(method)
    if not routes[method] then
        routes[method] = {}
    end
    local pattern, params_keys = compile_path(path)
    routes[method][path] = {handler=handler, pattern=pattern, params_keys=params_keys}
end

function handle_request()
    local method = ngx.req.get_method()
    local uri = ngx.var.uri
    if routes[method] then
        for path, route_data in pairs(routes[method]) do
            local matches = {string.match(uri, route_data.pattern)}
            if #matches > 0 then
                local params = {}
                for i, k in ipairs(route_data.params_keys) do
                    params[k] = matches[i]
                end
                if path:find('%*') then
                    params["wildcard"] = matches[#matches]
                end
                route_data.handler(params)
                return
            end
        end
    end
    ngx.status = ngx.HTTP_NOT_FOUND
    ngx.say("Not found")
end

return {
    register = router,
    handle_request = handle_request,
}
