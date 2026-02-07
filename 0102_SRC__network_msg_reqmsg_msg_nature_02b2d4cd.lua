local MSG_Nature = {
    natureInfo = {
       curLevel = 0,
       curExp = nil,
       modelId = 0,
       haveActiveSkill = List:New(),
       fruitInfo = List:New(),
       outlineInfo = List:New(),
       WeaponsInfo = List:New(),
       haveActiveModel = List:New(),
       fight = 0,
    },
    natureSkillInfo = {
       SkillType = 0,
       Level = 0,
    },
    natureDrugInfo = {
       fruitId = 0,
       level = 0,
       eatnum = 0,
    },
    natureWeaponsInfo = {
       id = 0,
       value = 0,
    },
    natureOutlineInfo = {
       id = 0,
       level = 0,
       fight = 0,
    },
    ReqNatureInfo = {
       natureType = 0,
    },
    ReqNatureUpLevel = {
       natureType = 0,
       itemid = 0,
       isOneKeyUp = false,
    },
    ReqNatureDrug = {
       natureType = 0,
       itemid = 0,
    },
    ReqNatureModelSet = {
       natureType = 0,
       modelId = 0,
    },
    ReqNatureTaskModelSet = {
       natureType = 0,
       taskModelId = "",
    },
    ReqNatureFashionUpLevel = {
       natureType = 0,
       id = 0,
    },
    itemOnlyInfo = {
       itemOnlyId = 0,
       num = 0,
    },
    itemModelInfo = {
       itemModelId = 0,
       num = 0,
    },
}
local L_StrDic = {
    [MSG_Nature.ReqNatureInfo] = "MSG_Nature.ReqNatureInfo",
    [MSG_Nature.ReqNatureUpLevel] = "MSG_Nature.ReqNatureUpLevel",
    [MSG_Nature.ReqNatureDrug] = "MSG_Nature.ReqNatureDrug",
    [MSG_Nature.ReqNatureModelSet] = "MSG_Nature.ReqNatureModelSet",
    [MSG_Nature.ReqNatureTaskModelSet] = "MSG_Nature.ReqNatureTaskModelSet",
    [MSG_Nature.ReqNatureFashionUpLevel] = "MSG_Nature.ReqNatureFashionUpLevel",
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

return MSG_Nature

