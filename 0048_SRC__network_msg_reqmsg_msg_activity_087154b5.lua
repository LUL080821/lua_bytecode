local MSG_Activity = {
    Activity = {
       type = 0,
       actConfig = nil,
       actData = nil,
    },
    ReqActivity = {
       type = 0,
    },
    ReqActivityDeal = {
       type = 0,
       data = nil,
    },
}
local L_StrDic = {
    [MSG_Activity.ReqActivity] = "MSG_Activity.ReqActivity",
    [MSG_Activity.ReqActivityDeal] = "MSG_Activity.ReqActivityDeal",
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

return MSG_Activity

