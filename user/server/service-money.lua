local QBCore = exports['qb-core']:GetCoreObject()

-- 创建全局服务对象
MoneyService = {}

-- 给玩家发放金钱的函数
function MoneyService.GiveMoneyToPlayer(playerId, amount)
    local Player = QBCore.Functions.GetPlayer(playerId)
    if not Player then
        return false, "Player not found"
    end

    -- 添加金钱
    Player.Functions.AddMoney("cash", amount, "API request")
    -- 发送通知给客户端
    TriggerClientEvent('QBCore:Notify', playerId, '充值到账 $' .. amount .. ' 现金', 'success')
    print(string.format("已给玩家 ID %d 发放 $%d 现金, 玩家帐户余额 $%d", playerId, amount, Player.Functions.GetMoney("cash")))
    return true, "Money sent successfully"
end

-- 服务端事件（保留用于其他地方调用）
RegisterNetEvent("api:giveMoney", function(playerId, amount)
    MoneyService.GiveMoneyToPlayer(tonumber(playerId), tonumber(amount))
end)

-- 返回服务
return MoneyService
