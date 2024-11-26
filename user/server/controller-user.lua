-- 使用新的API管理器注册路由
local API = exports['api']
local Response = exports['api'].getResponse()

-- 获取玩家信息路由
API:RegisterRoute("GET", "/userInfo", function(req)
    local playerId = tonumber(req.params.playerId)
    
    if not playerId then
        return Response.failWithMsg("无效的玩家ID")
    end

    local player = UserService.GetPlayerInfo(playerId)
    if not player then
        return Response.failWithMsg("玩家不存在")
    end

    return Response.okWithData(player)
end, {
    auth_required = true
})

-- 在线玩家列表路由
API:RegisterRoute("GET", "/userOnline", function(req)
    local players = UserService.GetOnlinePlayers()
    
    return Response.okWithData(players)
end, {
    auth_required = true
})

-- 踢出玩家路由
API:RegisterRoute("POST", "/userKick", function(req)
    local playerId = tonumber(req.body.playerId)
    local reason = req.body.reason or "被管理员踢出"
    
    if not playerId then
        return Response.failWithMsg("无效的玩家ID")
    end

    local success = UserService.KickPlayer(playerId, reason)
    
    return Response.okWithMsg(success and "玩家已被踢出" or "踢出玩家失败")
end, {
    auth_required = true
})