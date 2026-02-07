local MSG_Horse = {
    ReqChangeHorse = {
       horseLayer = 0,
    },
    ReqChangeRideState = {
       rideState = 0,
    },
    ReqFlyAction = {
       fly = false,
       x = nil,
       y = nil,
    },
    ReqUpdateHight = {
       high = 0,
    },
    ReqInviteOtherPlayerForRide = {
       invitedPlayerId = 0,
    },
    ReqInviteResult = {
       agreeOrRefuse = false,
       invitePlayerId = 0,
    },
    HorseEquipInfo = {
       assistantId = 0,
       petId = nil,
       cellList = List:New(),
       strengthActiveId = nil,
       soulActiveId = nil,
       open = nil,
    },
    HorseEquipPart = {
       id = 0,
       equip = nil,
       strengthLv = nil,
       soulLv = nil,
       open = nil,
    },
    ReqMountChangeAssi = {
       mountModelId = 0,
       assistantId = 0,
    },
    ReqMountEquipWear = {
       equipId = 0,
       assistantId = 0,
       cellId = 0,
    },
    ReqMountEquipUnWear = {
       assistantId = 0,
       cellId = 0,
    },
    ReqMountEquipStrength = {
       assistantId = 0,
       cellId = 0,
    },
    ReqMountEquipSoul = {
       assistantId = 0,
       cellId = 0,
    },
    ReqMountEquipActiveInten = {
       assistantId = 0,
       strengthActiveId = 0,
    },
    ReqMountEquipActiveSoul = {
       assistantId = 0,
       soulActiveId = 0,
    },
    ReqMountEquipSynthesis = {
       assistantId = 0,
       cellId = 0,
       equips = List:New(),
    },
    ReqMountEquipDecompose = {
       equipId = List:New(),
    },
    ReqMountEquipDecomposeSetting = {
       set = false,
    },
    ReqActiveMountEquipSlot = {
       slotId = 0,
    },
}
local L_StrDic = {
    [MSG_Horse.ReqChangeHorse] = "MSG_Horse.ReqChangeHorse",
    [MSG_Horse.ReqChangeRideState] = "MSG_Horse.ReqChangeRideState",
    [MSG_Horse.ReqFlyAction] = "MSG_Horse.ReqFlyAction",
    [MSG_Horse.ReqUpdateHight] = "MSG_Horse.ReqUpdateHight",
    [MSG_Horse.ReqInviteOtherPlayerForRide] = "MSG_Horse.ReqInviteOtherPlayerForRide",
    [MSG_Horse.ReqInviteResult] = "MSG_Horse.ReqInviteResult",
    [MSG_Horse.ReqMountChangeAssi] = "MSG_Horse.ReqMountChangeAssi",
    [MSG_Horse.ReqMountEquipWear] = "MSG_Horse.ReqMountEquipWear",
    [MSG_Horse.ReqMountEquipUnWear] = "MSG_Horse.ReqMountEquipUnWear",
    [MSG_Horse.ReqMountEquipStrength] = "MSG_Horse.ReqMountEquipStrength",
    [MSG_Horse.ReqMountEquipSoul] = "MSG_Horse.ReqMountEquipSoul",
    [MSG_Horse.ReqMountEquipActiveInten] = "MSG_Horse.ReqMountEquipActiveInten",
    [MSG_Horse.ReqMountEquipActiveSoul] = "MSG_Horse.ReqMountEquipActiveSoul",
    [MSG_Horse.ReqMountEquipSynthesis] = "MSG_Horse.ReqMountEquipSynthesis",
    [MSG_Horse.ReqMountEquipDecompose] = "MSG_Horse.ReqMountEquipDecompose",
    [MSG_Horse.ReqMountEquipDecomposeSetting] = "MSG_Horse.ReqMountEquipDecomposeSetting",
    [MSG_Horse.ReqActiveMountEquipSlot] = "MSG_Horse.ReqActiveMountEquipSlot",
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

return MSG_Horse

