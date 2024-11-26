dofile('server/give-money.lua')
dofile('client/give-money.lua')

PerformHttpRequest('/test', function(source, method, data, callback)
    callback(200, json.encode({ success = true, message = "Hello from FiveM!" }))
end, 'GET')