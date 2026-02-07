local MSG_Welfare = {
    ReqWelfareData = {
       typ = 0,
    },
    ReqLoginGiftReward = {
       day = 0,
    },
    ReqDayCheckIn = {
       cfgID = 0,
       typ = 0,
    },
    CardInfo = {
       id = 0,
       remain = 0,
       receive = false,
    },
    ReqExclusiveCard = {
       id = 0,
    },
    ReqExclusiveCardReward = {
       id = 0,
    },
    ReqFeelingExp = {
       times = 0,
       typ = 0,
    },
    ReqGrowthFundBuy = {
       gear = 0,
    },
    ReqGrowthGetAward = {
       cfgID = 0,
    },
    ReqGrowthFundServer = {
       cfgID = 0,
    },
    ReqDayGiftRecharge = {
       id = 0,
    },
    ReqExchangeGift = {
       id = "",
    },
    ItemInfo = {
       itemID = 0,
       num = 0,
       bind = false,
    },
    LevelGiftInfo = {
       level = 0,
       remain = 0,
       receive = false,
       vipReceive = false,
    },
    ReqReceiveLevelGift = {
       level = 0,
    },
    RetrieveRes = {
       type = 0,
       remain = 0,
       vipCount = nil,
       vipCountMax = nil,
    },
    ReqRetrieveRes = {
       type = 0,
       rrType = 0,
       count = nil,
    },
    ReqOneKeyRetrieveRes = {
       rrType = 0,
       baseTpe = 0,
    },
    ReqGetUpdateNoticeAward = {
    },
    ReqInvestPeakBuy = {
       gear = 0,
    },
    ReqInvestPeakGetAward = {
       cfgID = 0,
    },
    ReqInvestPeakServer = {
       cfgID = 0,
    },
    ReqWelfareFreeGift = {
    },
}
local L_StrDic = {
    [MSG_Welfare.ReqWelfareData] = "MSG_Welfare.ReqWelfareData",
    [MSG_Welfare.ReqLoginGiftReward] = "MSG_Welfare.ReqLoginGiftReward",
    [MSG_Welfare.ReqDayCheckIn] = "MSG_Welfare.ReqDayCheckIn",
    [MSG_Welfare.ReqExclusiveCard] = "MSG_Welfare.ReqExclusiveCard",
    [MSG_Welfare.ReqExclusiveCardReward] = "MSG_Welfare.ReqExclusiveCardReward",
    [MSG_Welfare.ReqFeelingExp] = "MSG_Welfare.ReqFeelingExp",
    [MSG_Welfare.ReqGrowthFundBuy] = "MSG_Welfare.ReqGrowthFundBuy",
    [MSG_Welfare.ReqGrowthGetAward] = "MSG_Welfare.ReqGrowthGetAward",
    [MSG_Welfare.ReqGrowthFundServer] = "MSG_Welfare.ReqGrowthFundServer",
    [MSG_Welfare.ReqDayGiftRecharge] = "MSG_Welfare.ReqDayGiftRecharge",
    [MSG_Welfare.ReqExchangeGift] = "MSG_Welfare.ReqExchangeGift",
    [MSG_Welfare.ReqReceiveLevelGift] = "MSG_Welfare.ReqReceiveLevelGift",
    [MSG_Welfare.ReqRetrieveRes] = "MSG_Welfare.ReqRetrieveRes",
    [MSG_Welfare.ReqOneKeyRetrieveRes] = "MSG_Welfare.ReqOneKeyRetrieveRes",
    [MSG_Welfare.ReqGetUpdateNoticeAward] = "MSG_Welfare.ReqGetUpdateNoticeAward",
    [MSG_Welfare.ReqInvestPeakBuy] = "MSG_Welfare.ReqInvestPeakBuy",
    [MSG_Welfare.ReqInvestPeakGetAward] = "MSG_Welfare.ReqInvestPeakGetAward",
    [MSG_Welfare.ReqInvestPeakServer] = "MSG_Welfare.ReqInvestPeakServer",
    [MSG_Welfare.ReqWelfareFreeGift] = "MSG_Welfare.ReqWelfareFreeGift",
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

return MSG_Welfare

