local MSG_Commercialize = {
    ReqCommercialize = {
       typ = 0,
    },
    ItemInfo = {
       itemID = 0,
       num = 0,
       bind = false,
    },
    DailyRechargeCfg = {
       awardId = 0,
       position = 0,
       day = 0,
       money = 0,
       items = List:New(),
    },
    ReqDailyRechargeCfg = {
    },
    ReqGetDailyRechargeAward = {
       awardId = 0,
    },
    DailyRechargeInfo = {
       awardId = 0,
       status = 0,
       day = 0,
    },
    FCChargeData = {
       cfgID = 0,
       goldCount = 0,
       isReward = false,
    },
    ReqFCChargeReward = {
       cfgID = 0,
    },
    ReqGetRechargeReward = {
       rewarId = 0,
    },
    ReqGetBoxReward = {
    },
}
local L_StrDic = {
    [MSG_Commercialize.ReqCommercialize] = "MSG_Commercialize.ReqCommercialize",
    [MSG_Commercialize.ReqDailyRechargeCfg] = "MSG_Commercialize.ReqDailyRechargeCfg",
    [MSG_Commercialize.ReqGetDailyRechargeAward] = "MSG_Commercialize.ReqGetDailyRechargeAward",
    [MSG_Commercialize.ReqFCChargeReward] = "MSG_Commercialize.ReqFCChargeReward",
    [MSG_Commercialize.ReqGetRechargeReward] = "MSG_Commercialize.ReqGetRechargeReward",
    [MSG_Commercialize.ReqGetBoxReward] = "MSG_Commercialize.ReqGetBoxReward",
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

return MSG_Commercialize

