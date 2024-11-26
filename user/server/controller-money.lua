-- 使用新的API管理器注册路由
local API = exports['api']
local Response = exports['api'].getResponse()

-- 给玩家金钱的路由
API:RegisterRoute("POST", "/giveMoney", function(req)
    -- 验证请求体是否存在
    if not req.body then
        return Response.failWithMsg("请求体为空")
    end

    -- 验证请求参数
    local playerId = tonumber(req.body.playerId)
    local amount = tonumber(req.body.amount)
    
    if not playerId or not amount then
        return Response.failWithMsg("无效的参数")
    end

    -- 调用 service 层处理业务逻辑
    local success, message = MoneyService.GiveMoneyToPlayer(playerId, amount)
    
    if not success then
        return Response.failWithMsg(message or "操作失败")
    end
    
    return Response.okWithData({
        playerId = playerId,
        amount = amount
    }, message or "操作成功")
end, {
    auth_required = true
})

-- 获取玩家金钱的路由
API:RegisterRoute("GET", "/getUserMoney", function(req)
    -- 验证查询参数是否存在
    if not req.query then
        return Response.failWithMsg("缺少查询参数")
    end

    local playerId = tonumber(req.query.playerId)
    
    if not playerId then
        return Response.failWithMsg("无效的玩家ID")
    end

    local balance = MoneyService.GetPlayerBalance(playerId)
    if not balance then
        return Response.failWithMsg("获取余额失败")
    end
    
    return Response.okWithData({
        playerId = playerId,
        balance = balance
    })
end, {
    auth_required = true
})
