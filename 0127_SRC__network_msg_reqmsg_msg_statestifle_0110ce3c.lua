local MSG_StateStifle = {
    LevelCondition = {
       conditionId = 0,
       progress = 0,
       total = 0,
    },
    StateStifleLevel = {
       level = 0,
       star = 0,
    },
    soulSpirit = {
       state = 0,
       promoteLv = 0,
       promotePorgress = 0,
       evolveLv = 0,
       id = 0,
    },
    ReqOpenStateStiflePanle = {
    },
    ReqUpLevel = {
       oneKey = false,
    },
    ReqUpPromoteLevel = {
       id = 0,
    },
    ReqUpEvolveLevel = {
       id = 0,
    },
    ReqActiveSoulSpirit = {
       id = 0,
    },
}
local L_StrDic = {
    [MSG_StateStifle.ReqOpenStateStiflePanle] = "MSG_StateStifle.ReqOpenStateStiflePanle",
    [MSG_StateStifle.ReqUpLevel] = "MSG_StateStifle.ReqUpLevel",
    [MSG_StateStifle.ReqUpPromoteLevel] = "MSG_StateStifle.ReqUpPromoteLevel",
    [MSG_StateStifle.ReqUpEvolveLevel] = "MSG_StateStifle.ReqUpEvolveLevel",
    [MSG_StateStifle.ReqActiveSoulSpirit] = "MSG_StateStifle.ReqActiveSoulSpirit",
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

return MSG_StateStifle

