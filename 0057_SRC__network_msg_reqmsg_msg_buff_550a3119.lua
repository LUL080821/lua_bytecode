local MSG_Buff = {
    ReqAddbuff = {
       id = 0,
    },
    ReqRemovebuff = {
       id = 0,
    },
}
local L_StrDic = {
    [MSG_Buff.ReqAddbuff] = "MSG_Buff.ReqAddbuff",
    [MSG_Buff.ReqRemovebuff] = "MSG_Buff.ReqRemovebuff",
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

return MSG_Buff

