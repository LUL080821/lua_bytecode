local MSG_Backend = {
    FuncOpenInfo = {
       id = 0,
       state = 0,
    },
    ReqFuncOpenRoleInfo = {
    },
    ReqFuncOpenReward = {
       id = 0,
    },
    ActivityInfo = {
       id = 0,
       type = 0,
       tag = 0,
       name = "",
       bigLabel = 0,
       smallLabel = 0,
       numLimit = 0,
       beginTime = 0,
       endTime = 0,
       panelImageId = 0,
       panelText = nil,
       help = nil,
       actionBegin = nil,
       actionEnd = nil,
       conditionList = "",
       rewardList = nil,
       otherList = nil,
       isDelete = 0,
       rowText = nil,
    },
    ActivityClientInfo = {
       id = 0,
       type = 0,
       name = "",
       beginTime = 0,
       endTime = 0,
       rewardList = "",
       numLimit = 0,
       panelImageId = 0,
       bigPanel = 0,
       smallPanel = 0,
       getNum = 0,
       panelText = nil,
       needNum = nil,
       haveNum = nil,
       needItemList = List:New(),
       canGet = nil,
       sendItemModelId = nil,
       rankList = List:New(),
       condition = nil,
       bossList = List:New(),
       DayRewardList = List:New(),
       rewardAgain = nil,
       rewardAgainState = nil,
       rowText = nil,
    },
    ReqGetActivityList = {
    },
    ReqGetActivityReward = {
       id = 0,
       type = 0,
       num = 0,
    },
    ActivetyExchangeNeed = {
       itemModelId = 0,
       num = 0,
    },
    ActivetyRankInfo = {
       top = 0,
       name = "",
       limit = 0,
       rewardList = "",
       roleId = nil,
       userId = nil,
    },
    BossInfo = {
       bossId = 0,
       needKillNum = 0,
       hasKillNum = 0,
    },
    DayReward = {
       day = 0,
       reward = "",
       getState = 0,
    },
    ReqActivitySendToFriend = {
       playerid = 0,
       itemModelId = 0,
       num = 0,
    },
    CrossRankData = {
       id = 0,
       name = "",
       top = 0,
       serverId = 0,
    },
    PaySendItemClientInfo = {
       key = "",
       startTime = 0,
       endTime = 0,
       totalTimes = 0,
       buyTimes = 0,
       canBuy = false,
       panelImageId = 0,
       panelOrder = 0,
    },
    ReqClosePopWindow = {
    },
    ReqGetDailyRechargeReward = {
       id = 0,
       getType = 0,
       getDay = nil,
    },
    ReqRemainTimeActivity = {
       type = 0,
       id = 0,
    },
    ReqBuyTimeLimitGift = {
       lv = 0,
       id = 0,
    },
    LevelGift = {
       lv = 0,
       itemList = "",
       isBuy = false,
    },
    ReqCloudBuy = {
       id = 0,
    },
    ReqCloseCloudBuy = {
    },
}
local L_StrDic = {
    [MSG_Backend.ReqFuncOpenRoleInfo] = "MSG_Backend.ReqFuncOpenRoleInfo",
    [MSG_Backend.ReqFuncOpenReward] = "MSG_Backend.ReqFuncOpenReward",
    [MSG_Backend.ReqGetActivityList] = "MSG_Backend.ReqGetActivityList",
    [MSG_Backend.ReqGetActivityReward] = "MSG_Backend.ReqGetActivityReward",
    [MSG_Backend.ReqActivitySendToFriend] = "MSG_Backend.ReqActivitySendToFriend",
    [MSG_Backend.ReqClosePopWindow] = "MSG_Backend.ReqClosePopWindow",
    [MSG_Backend.ReqGetDailyRechargeReward] = "MSG_Backend.ReqGetDailyRechargeReward",
    [MSG_Backend.ReqRemainTimeActivity] = "MSG_Backend.ReqRemainTimeActivity",
    [MSG_Backend.ReqBuyTimeLimitGift] = "MSG_Backend.ReqBuyTimeLimitGift",
    [MSG_Backend.ReqCloudBuy] = "MSG_Backend.ReqCloudBuy",
    [MSG_Backend.ReqCloseCloudBuy] = "MSG_Backend.ReqCloseCloudBuy",
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

return MSG_Backend

