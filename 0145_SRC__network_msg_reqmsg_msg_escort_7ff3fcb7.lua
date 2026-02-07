local MSG_Escort = {
    EscortReward = {
       id = 0,
       num = 0,
    },
    ReqEnterEscort = {
       type = 0,
    },
    ReqInfoEscort = {
    },
    ReqEscortOver = {
       type = 0,
    },
}
local L_StrDic = {
    [MSG_Escort.ReqEnterEscort] = "MSG_Escort.ReqEnterEscort",
    [MSG_Escort.ReqInfoEscort] = "MSG_Escort.ReqInfoEscort",
    [MSG_Escort.ReqEscortOver] = "MSG_Escort.ReqEscortOver",
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

return MSG_Escort

