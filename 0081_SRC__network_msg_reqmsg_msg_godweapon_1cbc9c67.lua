local MSG_GodWeapon = {
    godWeaponInfo = {
       groupId = 0,
       curLevel = 0,
       quality = 0,
       prss = 0,
       modelid = List:New(),
    },
    ReqGodWeaponInit = {
    },
    ReqGodWeaponLevelUp = {
       groupId = 0,
    },
    ReqGodWeaponQualityUp = {
       groupId = 0,
    },
    ReqGodWeaponEquipPartOrActive = {
       groupId = 0,
       modelId = 0,
       type = 0,
    },
}
local L_StrDic = {
    [MSG_GodWeapon.ReqGodWeaponInit] = "MSG_GodWeapon.ReqGodWeaponInit",
    [MSG_GodWeapon.ReqGodWeaponLevelUp] = "MSG_GodWeapon.ReqGodWeaponLevelUp",
    [MSG_GodWeapon.ReqGodWeaponQualityUp] = "MSG_GodWeapon.ReqGodWeaponQualityUp",
    [MSG_GodWeapon.ReqGodWeaponEquipPartOrActive] = "MSG_GodWeapon.ReqGodWeaponEquipPartOrActive",
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

return MSG_GodWeapon

