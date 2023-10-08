local umzila = require('resty.umzila')

print(umzila.version)

umzila.router('get', '/', function ()
    -- Your logic here
    ngx.say('It works!')
end)

--router('get', '/users/:userId', function (params)
--    local userId = params.userId
--    -- Your logic here
--    ngx.say('UserID: '.. userId)
--end)
--
--router('get', '/downloads/*', function (params)
--    local wildcard = params.wildcard
--    -- Your logic here
--    ngx.say('Path to download: '.. wildcard)
--end)

umzila.load_routes('app/api', '/api')

umzila.handle_request()