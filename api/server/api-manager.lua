-- API Manager Configuration
local API_CONFIG = {
    static_token = "!@#19970405", -- 静态访问令牌
    enable_auth = true,
    whitelist_ips = {
        ["127.0.0.1"] = true,
        ["192.168.2.50"] = true,
        -- 添加其他后端服务器IP
    }
}

-- 路由存储
local routes = {}

-- 响应模板
local Response = {
    -- 成功响应，带数据
    okWithData = function(data, msg)
        return {
            code = 0,
            msg = msg or "",
            data = data
        }
    end,

    -- 成功响应，仅消息
    okWithMsg = function(msg)
        return {
            code = 0,
            msg = msg or "",
            data = null
        }
    end,

    -- 失败响应
    failWithMsg = function(msg)
        return {
            code = 7,
            msg = msg or "操作失败",
            data = null
        }
    end
}

-- 标准响应构造器
local function createResponse(result, headers)
    return {
        status = result.code == 0 and 200 or 400,
        data = result,
        headers = headers or {
            ["Content-Type"] = "application/json"
        }
    }
end

-- 路由参数解析
local function parseRoute(path)
    local parts = {}
    local pattern = ""
    local params = {}
    
    for part in path:gmatch("[^/]+") do
        if part:sub(1,1) == ":" then
            -- 这是一个参数
            local paramName = part:sub(2)
            params[#params + 1] = paramName
            pattern = pattern .. "/([^/]+)"
        else
            pattern = pattern .. "/" .. part
        end
        parts[#parts + 1] = part
    end
    
    return {
        original = path,
        pattern = "^" .. pattern .. "/?$",
        params = params
    }
end

-- 匹配路由
local function matchRoute(requestPath, routes)
    for routePath, route in pairs(routes) do
        -- 如果路由定义中包含参数（:标记）
        if routePath:find(":") then
            local routeInfo = route.routeInfo
            local matches = {requestPath:match(routeInfo.pattern)}
            
            if #matches > 0 then
                local params = {}
                for i, paramName in ipairs(routeInfo.params) do
                    params[paramName] = matches[i]
                end
                return route, params
            end
        else
            -- 精确匹配
            if requestPath == routePath or requestPath .. "/" == routePath or routePath .. "/" == requestPath then
                return route, {}
            end
        end
    end
    return nil
end

-- 修改 RegisterRoute 函数
function RegisterRoute(method, path, handler, options)
    if not routes[method] then
        routes[method] = {}
    end

    local routeInfo = nil
    if path:find(":") then
        routeInfo = parseRoute(path)
    end

    routes[method][path] = {
        handler = handler,
        routeInfo = routeInfo,
        options = options or {
            auth_required = API_CONFIG.enable_auth
        }
    }
end

-- 解析查询字符串
local function parseQueryString(path)
    local queryStart = path:find("?")
    if not queryStart then
        return path, {}
    end

    local pathPart = path:sub(1, queryStart - 1)
    local queryPart = path:sub(queryStart + 1)
    local params = {}

    for pair in queryPart:gmatch("[^&]+") do
        local key, value = pair:match("([^=]+)=?(.*)")
        if key then
            -- URL decode the value
            value = value:gsub("%%20", " "):gsub("%%(%x%x)", function(h)
                return string.char(tonumber(h, 16))
            end)
            params[key] = value
        end
    end

    return pathPart, params
end

-- 修改请求处理器
local function handleRequest(req, res)
    -- 解析路径和查询参数
    local cleanPath, queryParams = parseQueryString(req.path)
    local method = req.method

    print(string.format("Received request: %s %s from %s", method, req.path, req.address))

    -- 查找匹配的路由
    local route = routes[method] and routes[method][cleanPath]
    if not route then
        return createResponse(Response.failWithMsg("Route not found"))
    end

    -- IP白名单检查
    local clientIP = req.address:match("([^:]+)") or req.address
    local isWhitelisted = API_CONFIG.whitelist_ips[clientIP] or false

    if not isWhitelisted then
        print(string.format("IP not whitelisted: %s", clientIP))
        return createResponse(Response.failWithMsg("IP not whitelisted"))
    end

    -- 令牌验证
    if route.options.auth_required then
        local auth_header = req.headers["Authorization"]
        if not auth_header then
            return createResponse(Response.failWithMsg("No authorization token provided"))
        end

        local token = auth_header:gsub("Bearer ", "")
        if token ~= API_CONFIG.static_token then
            return createResponse(Response.failWithMsg("Invalid token"))
        end
    end

    -- 处理请求体
    if method == "POST" or method == "PUT" then
        local bodyPromise = promise.new()

        req.setDataHandler(function(body)
            local success, decodedBody = pcall(json.decode, body)
            if success then
                req.body = decodedBody
            else
                req.body = nil
            end
            bodyPromise:resolve()
        end)

        Citizen.Await(bodyPromise)
    end

    -- 添加查询参数到请求对象
    req.params = queryParams

    -- 执行路由处理器
    local success, result = pcall(function()
        return route.handler(req)
    end)

    if not success then
        return createResponse(Response.failWithMsg(result and result or "request error"))
    end

    return createResponse(result)
end

-- 设置HTTP处理器
SetHttpHandler(function(req, res)
    local response = handleRequest(req, res)
    res.writeHead(response.status, response.headers)
    res.send(json.encode(response.data))
end)

-- 示例路由注册
RegisterRoute("GET", "/server/status", function(req)
    return Response.okWithData({
        status = "online",
        timestamp = os.time()
    }, "获取成功")
end, {
    auth_required = false
})

-- 示例受保护路由
RegisterRoute("POST", "/server/protected", function(req)
    return Response.okWithData({
        message = "Access granted to protected route",
        requestBody = req.body
    }, "访问成功")
end, {
    auth_required = true
})

-- 导出 Response 的获取函数
local function getResponse()
    return Response
end

-- 导出API管理器函数和响应模板
exports('RegisterRoute', RegisterRoute)
exports('getResponse', getResponse)
