local MSG_WorldAnswer = {
    totalIntegral = {
       integral = 0,
       exp = 0,
       money = 0,
    },
    totalChooseNum = {
       chooseACount = 0,
       chooseBCount = 0,
       chooseCCount = 0,
       chooseDCount = 0,
    },
    ReqApplyAnswer = {
    },
    ReqAnswerResult = {
       resultIndex = 0,
    },
    ReqLeaveOutAnswer = {
    },
    itemReward = {
       itmeID = 0,
       itmeNum = 0,
       isBind = false,
    },
}
local L_StrDic = {
    [MSG_WorldAnswer.ReqApplyAnswer] = "MSG_WorldAnswer.ReqApplyAnswer",
    [MSG_WorldAnswer.ReqAnswerResult] = "MSG_WorldAnswer.ReqAnswerResult",
    [MSG_WorldAnswer.ReqLeaveOutAnswer] = "MSG_WorldAnswer.ReqLeaveOutAnswer",
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

return MSG_WorldAnswer

