------------------------------------------------
-- author:
-- Date: 2021-11-11
-- File: UnrealEquipPart.lua
-- Module: UnrealEquipPart
-- Description: Phantom installation part
------------------------------------------------

local UnrealEquipPart = {
    -- Part ID
    Part  = 0,
    -- Equipment example
    Equip = nil,
}

function UnrealEquipPart:New(info)
    local _m = Utils.DeepCopy(self)
    _m.Part = info.part
    if info.unrealEquipItem ~= nil then
        if info.unrealEquipItem.num == nil then
            info.unrealEquipItem.num = 1
        end
        _m.Equip = LuaItemBase.CreateItemBaseByMsg(info.unrealEquipItem)
        _m.Equip.ContainerType = ContainerType.ITEM_LOCATION_EQUIP
    else
        _m.Equip = nil
    end
    return _m
end

return UnrealEquipPart