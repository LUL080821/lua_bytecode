local MSG_Peak = {
    PeakReward = {
       itemId = 0,
       count = 0,
    },
    PeakRankRole = {
       roleId = 0,
       name = "",
       serverId = 0,
       score = 0,
       stageId = 0,
       power = 0,
       order = 0,
    },
    PeakStageReward = {
       stateId = 0,
       count = 0,
    },
    RewardInfo = {
       roleId = 0,
       id = List:New(),
    },
    ReqPeakRankInfo = {
    },
    ReqPeakInfo = {
    },
    ReqPeakStageInfo = {
    },
    ReqPeakTimesReward = {
       times = 0,
    },
    ReqPeakStageReward = {
       stageId = 0,
    },
    ReqEnterPeakMatch = {
    },
    ReqCancelPeakMatch = {
    },
    ReqEnterWaitScene = {
    },
    PeakCrossRole = {
       roleId = 0,
       name = "",
       platform = "",
       serverId = 0,
       power = 0,
    },
}
local L_StrDic = {
    [MSG_Peak.ReqPeakRankInfo] = "MSG_Peak.ReqPeakRankInfo",
    [MSG_Peak.ReqPeakInfo] = "MSG_Peak.ReqPeakInfo",
    [MSG_Peak.ReqPeakStageInfo] = "MSG_Peak.ReqPeakStageInfo",
    [MSG_Peak.ReqPeakTimesReward] = "MSG_Peak.ReqPeakTimesReward",
    [MSG_Peak.ReqPeakStageReward] = "MSG_Peak.ReqPeakStageReward",
    [MSG_Peak.ReqEnterPeakMatch] = "MSG_Peak.ReqEnterPeakMatch",
    [MSG_Peak.ReqCancelPeakMatch] = "MSG_Peak.ReqCancelPeakMatch",
    [MSG_Peak.ReqEnterWaitScene] = "MSG_Peak.ReqEnterWaitScene",
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

return MSG_Peak

