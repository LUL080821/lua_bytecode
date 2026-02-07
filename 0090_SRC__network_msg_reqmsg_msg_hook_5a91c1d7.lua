local MSG_Hook = {
    hookExpAddRateInfo = {
       type = 0,
       rate = 0,
    },
    ReqHookSetInfo = {
    },
    ReqOfflineHookFindTime = {
       isfind = false,
    },
    ReqStartSitDown = {
    },
    ReqEndSitDown = {
    },
    ReqLeaderSitDown = {
       isTrue = false,
    },
}
local L_StrDic = {
    [MSG_Hook.ReqHookSetInfo] = "MSG_Hook.ReqHookSetInfo",
    [MSG_Hook.ReqOfflineHookFindTime] = "MSG_Hook.ReqOfflineHookFindTime",
    [MSG_Hook.ReqStartSitDown] = "MSG_Hook.ReqStartSitDown",
    [MSG_Hook.ReqEndSitDown] = "MSG_Hook.ReqEndSitDown",
    [MSG_Hook.ReqLeaderSitDown] = "MSG_Hook.ReqLeaderSitDown",
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

return MSG_Hook

