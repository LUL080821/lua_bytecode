local MSG_heart = {
    ReqHeart = {
       time = 0,
    },
    ReqReconnect = {
       playerId = 0,
       sign = "",
    },
    ReqSetReconnectSignSuccess = {
    },
    ReqReallyHeart = {
    },
}
local L_StrDic = {
    [MSG_heart.ReqHeart] = "MSG_heart.ReqHeart",
    [MSG_heart.ReqReconnect] = "MSG_heart.ReqReconnect",
    [MSG_heart.ReqSetReconnectSignSuccess] = "MSG_heart.ReqSetReconnectSignSuccess",
    [MSG_heart.ReqReallyHeart] = "MSG_heart.ReqReallyHeart",
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

return MSG_heart

