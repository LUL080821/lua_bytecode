local MSG_Spirit = {
    spiritInfo = {
       id = 0,
       equipList = List:New(),
       isActive = false,
    },
    ReqCollectEquip = {
       id = 0,
       equipId = 0,
       Inherit = false,
    },
    ReqActiveSpirit = {
       id = 0,
    },
    ReqUpLevel = {
       cfgId = 0,
    },
    ReqUpStar = {
       starNum = 0,
    },
}
local L_StrDic = {
    [MSG_Spirit.ReqCollectEquip] = "MSG_Spirit.ReqCollectEquip",
    [MSG_Spirit.ReqActiveSpirit] = "MSG_Spirit.ReqActiveSpirit",
    [MSG_Spirit.ReqUpLevel] = "MSG_Spirit.ReqUpLevel",
    [MSG_Spirit.ReqUpStar] = "MSG_Spirit.ReqUpStar",
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

return MSG_Spirit

