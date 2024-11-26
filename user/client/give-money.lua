-- 客户端只需要处理通知，移除所有金钱操作
local QBCore = exports['qb-core']:GetCoreObject()

-- 监听服务端触发的 api:giveMoney 事件
RegisterNetEvent('api:giveMoney', function(playerId, amount)
    -- 检查是否是发给当前客户端的消息
    if playerId == GetPlayerServerId(PlayerId()) then
        -- 播放音效或其他特效
        PlaySoundFrontend("CHARACTER_CHANGE_UP_MASTER", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", true, 0)
        -- 通知已经在服务端发送，这里不需要重复发送
        -- 如果需要其他客户端特效，可以在这里添加
    end
end)