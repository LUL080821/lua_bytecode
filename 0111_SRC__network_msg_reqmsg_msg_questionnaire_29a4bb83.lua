local MSG_Questionnaire = {
    answerInfo = {
       id = 0,
       answer = "",
    },
    ReqOpenPanel = {
    },
    ReqSubmitAnswer = {
       answers = List:New(),
    },
    ReqGetReward = {
    },
    ReqDownloadOver = {
    },
}
local L_StrDic = {
    [MSG_Questionnaire.ReqOpenPanel] = "MSG_Questionnaire.ReqOpenPanel",
    [MSG_Questionnaire.ReqSubmitAnswer] = "MSG_Questionnaire.ReqSubmitAnswer",
    [MSG_Questionnaire.ReqGetReward] = "MSG_Questionnaire.ReqGetReward",
    [MSG_Questionnaire.ReqDownloadOver] = "MSG_Questionnaire.ReqDownloadOver",
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

return MSG_Questionnaire

