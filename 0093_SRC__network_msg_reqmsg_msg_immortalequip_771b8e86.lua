local MSG_ImmortalEquip = {
    ImmortalEquipPart = {
       part = 0,
       equip = nil,
    },
    ReqInlayImmortalEquip = {
       UID = 0,
    },
    ReqCompoundImmortal = {
       part = 0,
    },
    ReqResolveImmortal = {
       uid = 0,
    },
    ReqExchangeImmortal = {
       modelID = 0,
    },
    ReqChangeImmEquipAppearance = {
       partType = 0,
       part = 0,
    },
}
local L_StrDic = {
    [MSG_ImmortalEquip.ReqInlayImmortalEquip] = "MSG_ImmortalEquip.ReqInlayImmortalEquip",
    [MSG_ImmortalEquip.ReqCompoundImmortal] = "MSG_ImmortalEquip.ReqCompoundImmortal",
    [MSG_ImmortalEquip.ReqResolveImmortal] = "MSG_ImmortalEquip.ReqResolveImmortal",
    [MSG_ImmortalEquip.ReqExchangeImmortal] = "MSG_ImmortalEquip.ReqExchangeImmortal",
    [MSG_ImmortalEquip.ReqChangeImmEquipAppearance] = "MSG_ImmortalEquip.ReqChangeImmEquipAppearance",
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

return MSG_ImmortalEquip

