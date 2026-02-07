local MSG_Setting = {
    setting = {
       type = 0,
       value = false,
    },
    feedback = {
       type = 0,
       time = 0,
       content = "",
    },
    ReqSendSetting = {
       list = List:New(),
    },
    ReqCommitFeedback = {
       type = 0,
       content = "",
    },
    ReqChangeServerName = {
       name = "",
    },
}
local L_StrDic = {
    [MSG_Setting.ReqSendSetting] = "MSG_Setting.ReqSendSetting",
    [MSG_Setting.ReqCommitFeedback] = "MSG_Setting.ReqCommitFeedback",
    [MSG_Setting.ReqChangeServerName] = "MSG_Setting.ReqChangeServerName",
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

return MSG_Setting

