local MSG_UnrealEquip = {
    UnrealEquipItem = {
       itemId = 0,
       itemModelId = 0,
       isbind = false,
    },
    UnrealEquipPart = {
       part = 0,
       unrealEquipItem = nil,
    },
    UnrealSoulInfo = {
       itemId = 0,
       useNum = 0,
    },
    ReqInlayUnreal = {
       UID = 0,
    },
    UnrealSyncItem = {
       uid = 0,
       num = 0,
    },
    ReqCompoundUnreal = {
       id = 0,
       equipIds = List:New(),
       itemList = List:New(),
    },
    ReqUseUnreal = {
       itemId = 0,
       useNum = 0,
    },
    ReqResolveUnreal = {
       uid = 0,
    },
}
local L_StrDic = {
    [MSG_UnrealEquip.ReqInlayUnreal] = "MSG_UnrealEquip.ReqInlayUnreal",
    [MSG_UnrealEquip.ReqCompoundUnreal] = "MSG_UnrealEquip.ReqCompoundUnreal",
    [MSG_UnrealEquip.ReqUseUnreal] = "MSG_UnrealEquip.ReqUseUnreal",
    [MSG_UnrealEquip.ReqResolveUnreal] = "MSG_UnrealEquip.ReqResolveUnreal",
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

return MSG_UnrealEquip

