local QBCore = exports['qb-core']:GetCoreObject()

UserService = {}

-- 获取玩家信息
function UserService.GetPlayerInfo(playerId)
    local Player = QBCore.Functions.GetPlayer(playerId)
    return Player
end

-- 获取在线玩家列表
function UserService.GetOnlinePlayers()
    local players = QBCore.Functions.GetPlayers()
    local playerList = {}
    
    for _, playerId in ipairs(players) do
        local Player = QBCore.Functions.GetPlayer(playerId)
        if Player then
            table.insert(playerList, {
                id = Player.PlayerData.id,
                account = Player.PlayerData.name, -- 账号名称
                job = Player.PlayerData.job,
                bank = Player.PlayerData.money.bank,
                cash = Player.PlayerData.money.cash,
                onlineCharacter = {
                    id = playerId,
                    username = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
                }
            })
        end
    end
    
    return playerList
end

-- 踢出玩家
function UserService.KickPlayer(playerId, reason)
    local Player = QBCore.Functions.GetPlayer(playerId)
    if Player then
        DropPlayer(playerId, reason)
        return true
    end
    return false
end

return UserService