local MSG_CrossHorseBoss = {
    HorseBossInfo = {
       bossId = 0,
       refreshTime = 0,
       isFollowed = nil,
    },
    ReqCrossHorseBossPanel = {
       level = 0,
    },
    ReqFollowCrossHorseBoss = {
       bossId = 0,
       followValue = false,
    },
    ReqCancelAffiliation = {
       cfgId = 0,
    },
}
local L_StrDic = {
    [MSG_CrossHorseBoss.ReqCrossHorseBossPanel] = "MSG_CrossHorseBoss.ReqCrossHorseBossPanel",
    [MSG_CrossHorseBoss.ReqFollowCrossHorseBoss] = "MSG_CrossHorseBoss.ReqFollowCrossHorseBoss",
    [MSG_CrossHorseBoss.ReqCancelAffiliation] = "MSG_CrossHorseBoss.ReqCancelAffiliation",
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

return MSG_CrossHorseBoss

