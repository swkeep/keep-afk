--                _
--               | |
--   _____      _| | _____  ___ _ __
--  / __\ \ /\ / / |/ / _ \/ _ \ '_ \
--  \__ \\ V  V /|   <  __/  __/ |_) |
--  |___/ \_/\_/ |_|\_\___|\___| .__/
--                             | |
--                             |_|
-- https://github.com/swkeep

local QBCore = exports['qb-core']:GetCoreObject()

-- class
Player = {
    data = {}
}

function Player:add(o)
    if not self.data[o.citizenid] then
        self.data[o.citizenid] = {
            source = o.source,
            afk_timer = Config.settings.kick_timer,
            prev_position = o.pos,
        }
    else
        Player:update_position(o.source, o.citizenid)
    end
end

function Player:remove(citizenid)
    self.data[citizenid] = nil
end

function Player:checkForKick(citizenid)
    if (self.data[citizenid].afk_timer == 0) then
        DropPlayer(self.data[citizenid].source, 'You Have Been Kicked For Being AFK')
        Player:remove(citizenid)
    end
end

function Player:afk_notification(citizenid)
    for _, time in pairs(Config.settings.notifications) do
        if self.data[citizenid].afk_timer == time then
            local msg = 'You are AFK and will be kicked in ' .. math.ceil(time / 60) .. ' minutes!'
            TriggerClientEvent('QBCore:Notify', self.data[citizenid].source, msg, "error")
            return true
        end
    end
    return false
end

function Player:update_position(source, citizenid)
    local current_coord = GetEntityCoords(GetPlayerPed(source))
    if current_coord == self.data[citizenid].prev_position then
        self.data[citizenid].afk_timer = self.data[citizenid].afk_timer - Config.settings.update_interval
        if self.data[citizenid].afk_timer <= 0 then
            self.data[citizenid].afk_timer = 0
        end
    else
        self.data[citizenid].prev_position = current_coord
        self.data[citizenid].afk_timer = Config.settings.kick_timer
    end
    self:afk_notification(citizenid)
    self:checkForKick(citizenid)
end

function Player:afkThread()
    CreateThread(function()
        while true do
            local players = QBCore.Functions.GetPlayers()
            for _, player in pairs(players) do
                local qb_player = QBCore.Functions.GetPlayer(player)
                self:add({
                    citizenid = qb_player.PlayerData.citizenid,
                    source = player,
                    pos = GetEntityCoords(GetPlayerPed(player))
                })
            end
            Wait(Config.settings.update_interval * 1000)
        end
    end)
end

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    Player:afkThread()
end)
