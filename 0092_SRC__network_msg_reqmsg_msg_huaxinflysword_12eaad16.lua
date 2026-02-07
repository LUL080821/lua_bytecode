local MSG_HuaxinFlySword = {
    huaxinInfo = {
       modelID = List:New(),
       starLevel = 0,
       steps = 0,
       type = 0,
    },
    ReqUseHuxin = {
       huaxinID = 0,
       type = 0,
    },
    ReqSwordSoulPannel = {
    },
    ReqGetHookReward = {
    },
    ReqSoulCopyGoOnChallenge = {
    },
    ReqQuickEarn = {
    },
    ReqSkipSoulCopy = {
    },
    ReqSwordTombPannel = {
    },
    ReqSwordTombWakeUp = {
       id = 0,
    },
}
local L_StrDic = {
    [MSG_HuaxinFlySword.ReqUseHuxin] = "MSG_HuaxinFlySword.ReqUseHuxin",
    [MSG_HuaxinFlySword.ReqSwordSoulPannel] = "MSG_HuaxinFlySword.ReqSwordSoulPannel",
    [MSG_HuaxinFlySword.ReqGetHookReward] = "MSG_HuaxinFlySword.ReqGetHookReward",
    [MSG_HuaxinFlySword.ReqSoulCopyGoOnChallenge] = "MSG_HuaxinFlySword.ReqSoulCopyGoOnChallenge",
    [MSG_HuaxinFlySword.ReqQuickEarn] = "MSG_HuaxinFlySword.ReqQuickEarn",
    [MSG_HuaxinFlySword.ReqSkipSoulCopy] = "MSG_HuaxinFlySword.ReqSkipSoulCopy",
    [MSG_HuaxinFlySword.ReqSwordTombPannel] = "MSG_HuaxinFlySword.ReqSwordTombPannel",
    [MSG_HuaxinFlySword.ReqSwordTombWakeUp] = "MSG_HuaxinFlySword.ReqSwordTombWakeUp",
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

return MSG_HuaxinFlySword

