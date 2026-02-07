local MSG_ActivityRanklist = {
    ActivityRankInfo = {
       rank = 0,
       rankData = 0,
       award = List:New(),
    },
    AwardInfo = {
       id = 0,
       residue = 0,
       get = false,
    },
    ReqActivityRankInfo = {
       rankKind = 0,
    },
    ReqGetRankAward = {
       rankKind = 0,
       awardId = 0,
    },
}
local L_StrDic = {
    [MSG_ActivityRanklist.ReqActivityRankInfo] = "MSG_ActivityRanklist.ReqActivityRankInfo",
    [MSG_ActivityRanklist.ReqGetRankAward] = "MSG_ActivityRanklist.ReqGetRankAward",
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

return MSG_ActivityRanklist

