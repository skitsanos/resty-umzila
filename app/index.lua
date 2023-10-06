local router_module = require('resty.umzila')

local router = router_module.register
local handle_request = router_module.handle_request

router('get', '/', function ()
    -- Your logic here
    ngx.say('It works!')
end)

router('get', '/users/:userId', function (params)
    local userId = params.userId
    -- Your logic here
    ngx.say('UserID: '.. userId)
end)

router('get', '/downloads/*', function (params)
    local wildcard = params.wildcard
    -- Your logic here
    ngx.say('Path to download: '.. wildcard)
end)

handle_request()