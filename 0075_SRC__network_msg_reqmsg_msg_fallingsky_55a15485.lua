local MSG_FallingSky = {
    FallSkyTaskData = {
       taskID = 0,
       progress = 0,
       state = false,
    },
    FallSkyLevelData = {
       levelId = 0,
       isGetfeelReward = false,
       isGetpayReward = false,
    },
    ReqGetFallSkyTaskReward = {
       taskID = 0,
    },
    ReqGetFallSkyLevelReward = {
       levelId = 0,
       isFree = false,
    },
    ReqOnekeyGetFallSkyLevelReward = {
    },
    ReqOnekeyGetFallSkyTaskReward = {
    },
}
local L_StrDic = {
    [MSG_FallingSky.ReqGetFallSkyTaskReward] = "MSG_FallingSky.ReqGetFallSkyTaskReward",
    [MSG_FallingSky.ReqGetFallSkyLevelReward] = "MSG_FallingSky.ReqGetFallSkyLevelReward",
    [MSG_FallingSky.ReqOnekeyGetFallSkyLevelReward] = "MSG_FallingSky.ReqOnekeyGetFallSkyLevelReward",
    [MSG_FallingSky.ReqOnekeyGetFallSkyTaskReward] = "MSG_FallingSky.ReqOnekeyGetFallSkyTaskReward",
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

return MSG_FallingSky

