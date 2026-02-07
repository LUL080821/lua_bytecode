local MSG_SoulBeast = {
    SoulCostItem = {
       id = 0,
       count = 0,
    },
    ReqSoulBeastFight = {
       soulId = 0,
    },
    ReqSoulBeastEquipWear = {
       soulBeastId = 0,
       equipIds = List:New(),
    },
    ReqSoulBeastEquipDown = {
       soulBeastId = 0,
       equipIds = List:New(),
    },
    ReqSoulBeastEquipUp = {
       soulId = 0,
       fixEquipId = 0,
       costs = List:New(),
       needDouble = false,
    },
    ReqAddGrid = {
    },
    ReqSell = {
       id = List:New(),
    },
    SoulBeast = {
       soulId = 0,
       fight = false,
       equips = List:New(),
    },
    SoulBeastEquip = {
       itemId = 0,
       itemModelId = 0,
       level = 0,
       curExp = 0,
    },
    itemModel = {
       itemModelId = 0,
       num = 0,
       itemId = 0,
    },
}
local L_StrDic = {
    [MSG_SoulBeast.ReqSoulBeastFight] = "MSG_SoulBeast.ReqSoulBeastFight",
    [MSG_SoulBeast.ReqSoulBeastEquipWear] = "MSG_SoulBeast.ReqSoulBeastEquipWear",
    [MSG_SoulBeast.ReqSoulBeastEquipDown] = "MSG_SoulBeast.ReqSoulBeastEquipDown",
    [MSG_SoulBeast.ReqSoulBeastEquipUp] = "MSG_SoulBeast.ReqSoulBeastEquipUp",
    [MSG_SoulBeast.ReqAddGrid] = "MSG_SoulBeast.ReqAddGrid",
    [MSG_SoulBeast.ReqSell] = "MSG_SoulBeast.ReqSell",
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

return MSG_SoulBeast

