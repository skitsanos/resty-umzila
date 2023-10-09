-- Collect HTTP method and URI
local method = ngx.req.get_method()
local uri = ngx.var.uri

ngx.log(ngx.INFO, string.upper(method) .. ' ' .. uri)