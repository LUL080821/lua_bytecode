local MSG_AlienBoss = {
    AlienBoss = {
       bossId = 0,
       monsterId = nil,
       hp = nil,
       killServerId = nil,
       time = nil,
    },
    AlienRole = {
       playerId = 0,
       name = nil,
       rank = nil,
       damage = nil,
    },
    AlienCity = {
       cityId = 0,
       serverId = 0,
       authEnterList = List:New(),
    },
    ReqEnterCrossAlien = {
       cityId = 0,
    },
    ReqCrossAlienCity = {
       cityId = 0,
    },
    ReqEnterCrossAlienGem = {
       cityId = 0,
    },
}
local L_StrDic = {
    [MSG_AlienBoss.ReqEnterCrossAlien] = "MSG_AlienBoss.ReqEnterCrossAlien",
    [MSG_AlienBoss.ReqCrossAlienCity] = "MSG_AlienBoss.ReqCrossAlienCity",
    [MSG_AlienBoss.ReqEnterCrossAlienGem] = "MSG_AlienBoss.ReqEnterCrossAlienGem",
}
local L_SendDic = setmetatable({},{__mode = "k"});

local mt = {}
mt.__index = mt
function mt:New()
    local _str = L_StrDic[self]
    local _clone = Utils.DeepCopy(self)
    L_SendDic[_clone] = _str
    return _clone
end
function mt:Send()
    GameCenter.Network.Send(L_SendDic[self], self)
end

for k,v in pairs(L_StrDic) do
    setmetatable(k, mt)
end

return MSG_AlienBoss

