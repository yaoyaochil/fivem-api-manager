local QBCore = exports['qb-core'].GetCoreObject()
-- 使用新的API管理器注册路由
local API = exports['api']
local Response = exports['api'].getResponse()

-- 获取玩家工作
API:RegisterRoute("GET", "/userJob", function(req)
    local playerId = tonumber(req.params.playerId)
    if not playerId then
        return Response.failWithMsg("无效的玩家ID")
    end
    
    local player = QBCore.Functions.GetPlayer(playerId)
    if not player then
        return Response.failWithMsg("未找到玩家")
    end
    
    local job = JobService.GetPlayerJob(playerId)
    return Response.okWithData(job, "获取成功")
end)

-- 获取所有工作
API:RegisterRoute("GET", "/jobAllList", function(req)
    local jobs = JobService.GetAllJobs()
    return Response.okWithData(jobs, "获取成功")
end)

--[[
    分配工作
    请求示例:
    POST /assignJob
    {
        "playerId": 1,  // 玩家ID
        "jobName": "police", // 工作名称
        "jobGrade": 0 // 工作等级
    }
]]--
API:RegisterRoute("POST", "/assignJob", function(req)
    -- 参数验证
    local playerId = tonumber(req.body.playerId)
    local jobName = req.body.jobName
    local jobGrade = req.body.jobGrade

    if not playerId or not jobName or not jobGrade then
        return Response.failWithMsg("缺少必要参数")
    end

    -- 获取玩家对象
    local player = QBCore.Functions.GetPlayer(playerId)
    if not player then
        return Response.failWithMsg("未找到玩家")
    end

    -- 验证工作是否存在
    local jobs = QBCore.Shared.Jobs
    if not jobs[jobName] then
        return Response.failWithMsg("无效的工作名称")
    end

    -- 验证工作等级是否有效
    if not jobs[jobName].grades[jobGrade] then
        return Response.failWithMsg("无效的工作等级")
    end

    -- 分配工作
    local success = JobService.AssignJob(playerId, jobName, jobGrade)
    if not success then
        return Response.failWithMsg("分配工作失败")
    end

    -- 确保玩家在线时才发送通知
    if player.PlayerData.source then
        TriggerClientEvent("QBCore:Notify", player.PlayerData.source, "你被分配了" .. jobName .. "工作，等级为" .. jobGrade, "success")
    end

    return Response.okWithData({
        playerId = player.PlayerData.source,
        name = player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname,
        username = player.PlayerData.name,
        job = player.PlayerData.job.name,
        jobGrade = player.PlayerData.job.grade
    }, "分配成功")
end)