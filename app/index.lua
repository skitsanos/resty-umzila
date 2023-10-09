local umzila = require('resty.umzila')

ngx.log(ngx.INFO, 'resty-umzila v.' .. umzila.version)

umzila.route('get', '/', function()
    -- Your logic here
    ngx.say('It works!')
end)

umzila.route('get', '/users/:userId', function(params)
    local userId = params.userId
    -- Your logic here
    ngx.say('UserID: ' .. userId)
end)

umzila.route('get', '/downloads/*', function(params)
    local wildcard = params.wildcard
    -- Your logic here
    ngx.say('Path to download: ' .. wildcard)
end)

umzila.load_routes('app/api', '/api')

umzila.handle_request()