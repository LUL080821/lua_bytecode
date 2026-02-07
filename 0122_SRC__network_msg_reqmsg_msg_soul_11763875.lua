local MSG_Soul = {
    Soul = {
       id = 0,
       dataId = 0,
       level = 0,
       exp = 0,
       location = 0,
    },
    ReqSmeltSoul = {
       soulID = 0,
       ids = List:New(),
    },
    ReqHuntSoul = {
    },
    ReqOneKeyHuntSoul = {
    },
    ReqActivateHunter = {
    },
    ReqWearSoul = {
       soulID = 0,
    },
}
local L_StrDic = {
    [MSG_Soul.ReqSmeltSoul] = "MSG_Soul.ReqSmeltSoul",
    [MSG_Soul.ReqHuntSoul] = "MSG_Soul.ReqHuntSoul",
    [MSG_Soul.ReqOneKeyHuntSoul] = "MSG_Soul.ReqOneKeyHuntSoul",
    [MSG_Soul.ReqActivateHunter] = "MSG_Soul.ReqActivateHunter",
    [MSG_Soul.ReqWearSoul] = "MSG_Soul.ReqWearSoul",
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

return MSG_Soul

