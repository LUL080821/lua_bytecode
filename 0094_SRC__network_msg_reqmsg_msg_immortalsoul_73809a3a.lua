local MSG_ImmortalSoul = {
    immortalSoul = {
       uid = 0,
       itemId = 0,
       level = 0,
       exp = 0,
       location = 0,
    },
    ReqInlaySoul = {
       soulUID = 0,
       location = 0,
    },
    ReqResolveSoul = {
       uids = List:New(),
    },
    ReqDismountingSoul = {
       uid = 0,
    },
    ReqUpSoul = {
       location = 0,
    },
    ReqExchangeSoul = {
       itemId = 0,
       num = nil,
    },
    ReqCompoundSoul = {
       itemId = 0,
    },
    ReqGetOffSoul = {
       location = 0,
    },
    SoulCoreInfo = {
       type = 0,
       core = 0,
    },
}
local L_StrDic = {
    [MSG_ImmortalSoul.ReqInlaySoul] = "MSG_ImmortalSoul.ReqInlaySoul",
    [MSG_ImmortalSoul.ReqResolveSoul] = "MSG_ImmortalSoul.ReqResolveSoul",
    [MSG_ImmortalSoul.ReqDismountingSoul] = "MSG_ImmortalSoul.ReqDismountingSoul",
    [MSG_ImmortalSoul.ReqUpSoul] = "MSG_ImmortalSoul.ReqUpSoul",
    [MSG_ImmortalSoul.ReqExchangeSoul] = "MSG_ImmortalSoul.ReqExchangeSoul",
    [MSG_ImmortalSoul.ReqCompoundSoul] = "MSG_ImmortalSoul.ReqCompoundSoul",
    [MSG_ImmortalSoul.ReqGetOffSoul] = "MSG_ImmortalSoul.ReqGetOffSoul",
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

return MSG_ImmortalSoul

