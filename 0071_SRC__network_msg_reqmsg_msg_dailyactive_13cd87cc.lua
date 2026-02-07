local MSG_Dailyactive = {
    dailyActiveInfo = {
       activeId = 0,
       open = nil,
       conditionOpen = nil,
       remainCount = 0,
       canBuyCount = 0,
    },
    ReqDailyActivePanel = {
    },
    ReqGetActiveReward = {
       id = 0,
    },
    ReqDailyPushIds = {
       activeIdList = List:New(),
    },
    ReqJoinDaily = {
       dailyId = 0,
       param = nil,
    },
    ReqCrossServerMatch = {
    },
    ServerMatchInfo = {
       serverid = 0,
       serverWroldLv = 0,
       openTime = 0,
       rankName_1 = nil,
       rankName_2 = nil,
       rankName_3 = nil,
    },
    ReqLeaderPreachEnter = {
    },
    ReqLeaveLeaderPreach = {
    },
}
local L_StrDic = {
    [MSG_Dailyactive.ReqDailyActivePanel] = "MSG_Dailyactive.ReqDailyActivePanel",
    [MSG_Dailyactive.ReqGetActiveReward] = "MSG_Dailyactive.ReqGetActiveReward",
    [MSG_Dailyactive.ReqDailyPushIds] = "MSG_Dailyactive.ReqDailyPushIds",
    [MSG_Dailyactive.ReqJoinDaily] = "MSG_Dailyactive.ReqJoinDaily",
    [MSG_Dailyactive.ReqCrossServerMatch] = "MSG_Dailyactive.ReqCrossServerMatch",
    [MSG_Dailyactive.ReqLeaderPreachEnter] = "MSG_Dailyactive.ReqLeaderPreachEnter",
    [MSG_Dailyactive.ReqLeaveLeaderPreach] = "MSG_Dailyactive.ReqLeaveLeaderPreach",
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

return MSG_Dailyactive

