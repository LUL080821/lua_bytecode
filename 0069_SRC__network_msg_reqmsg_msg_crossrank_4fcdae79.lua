local MSG_CrossRank = {
    CrossRankInfo = {
       roleId = 0,
       rank = 0,
       roleName = "",
       serverId = 0,
       career = 0,
       stateVip = 0,
       level = 0,
       fightPower = 0,
       rankData = nil,
       facade = {
            fashionBody = nil,
            fashionWeapon = nil,
            fashionHalo = nil,
            fashionMatrix = nil,
            wingId = nil,
            spiritId = nil,
            soulArmorId = nil,
        },

    },
    CrossTypeRankInfo = {
       type = 0,
       crossRankList = List:New(),
    },
    ReqCrossRankInfo = {
    },
}
local L_StrDic = {
    [MSG_CrossRank.ReqCrossRankInfo] = "MSG_CrossRank.ReqCrossRankInfo",
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

return MSG_CrossRank

