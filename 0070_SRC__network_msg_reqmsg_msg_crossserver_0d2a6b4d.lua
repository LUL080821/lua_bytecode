local MSG_CrossServer = {
    dropItemInfo = {
       itemModelId = 0,
       num = 0,
       isBind = false,
       notice = false,
    },
    fightEndScore = {
       roleId = 0,
       isSuccess = false,
       score = nil,
       time = nil,
       plat_sid = "",
       sortIndex = nil,
       starNum = nil,
       rewardtime = 0,
    },
}
local L_StrDic = {
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

return MSG_CrossServer

