local QBCore = exports['qb-core'].GetCoreObject()

JobService = {}

-- 获取玩家工作
function JobService.GetPlayerJob(playerId)
    local Player = QBCore.Functions.GetPlayer(playerId)
    if not Player then
        return nil
    end
    return Player.PlayerData.job
end

-- 获取所有工作
function JobService.GetAllJobs()
    return QBCore.Shared.Jobs
end

-- 分配工作 playerId:玩家ID jobName:工作名称 jobGrade:工作等级
function JobService.AssignJob(playerId, jobName, jobGrade)
    local Player = QBCore.Functions.GetPlayer(playerId)
    if not Player then
        return false
    end
    
    -- 确保工作存在
    if not QBCore.Shared.Jobs[jobName] then
        return false
    end
    
    -- 确保工作等级有效
    if not QBCore.Shared.Jobs[jobName].grades[jobGrade] then
        return false
    end
    
    Player.Functions.SetJob(jobName, jobGrade)
    return true
end

return JobService