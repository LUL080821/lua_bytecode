local MSG_FunctionTask = {
    FunctionTask = {
       id = 0,
       num = 0,
       maxNum = 0,
       get = false,
    },
    FunctionRechargeTask = {
       rechargeid = 0,
       num = 0,
       rewards = List:New(),
       get = false,
    },
    ReqFunctionTaskGetAward = {
       id = 0,
    },
}
local L_StrDic = {
    [MSG_FunctionTask.ReqFunctionTaskGetAward] = "MSG_FunctionTask.ReqFunctionTaskGetAward",
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

return MSG_FunctionTask

