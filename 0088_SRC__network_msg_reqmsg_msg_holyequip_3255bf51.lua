local MSG_HolyEquip = {
    HolyEquipItem = {
       uid = 0,
       itemId = 0,
       isBind = false,
    },
    HolyEquipPart = {
       part = 0,
       level = 0,
       holyEquipItem = nil,
    },
    HolySoulInfo = {
       itemId = 0,
       useNum = 0,
    },
    ReqInlayHoly = {
       UID = 0,
    },
    ReqCompoundHoly = {
       id = 0,
       equipIds = List:New(),
    },
    ReqIntensifyHolyPart = {
       part = 0,
    },
    ReqUseHolySoul = {
       itemId = 0,
       useNum = 0,
    },
    ReqResolveHoly = {
       uids = List:New(),
    },
    ReqSetAutoResolve = {
       isAuto = false,
       quality = 0,
       grade = 0,
    },
}
local L_StrDic = {
    [MSG_HolyEquip.ReqInlayHoly] = "MSG_HolyEquip.ReqInlayHoly",
    [MSG_HolyEquip.ReqCompoundHoly] = "MSG_HolyEquip.ReqCompoundHoly",
    [MSG_HolyEquip.ReqIntensifyHolyPart] = "MSG_HolyEquip.ReqIntensifyHolyPart",
    [MSG_HolyEquip.ReqUseHolySoul] = "MSG_HolyEquip.ReqUseHolySoul",
    [MSG_HolyEquip.ReqResolveHoly] = "MSG_HolyEquip.ReqResolveHoly",
    [MSG_HolyEquip.ReqSetAutoResolve] = "MSG_HolyEquip.ReqSetAutoResolve",
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

return MSG_HolyEquip

