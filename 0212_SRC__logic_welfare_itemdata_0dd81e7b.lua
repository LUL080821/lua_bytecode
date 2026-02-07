------------------------------------------------
-- Author:
-- Date: 2019-07-09
-- File: ItemData.lua
-- Module: ItemData
-- Description: Data class of prop Item
------------------------------------------------
local ItemData = {
    Id = 0,
    Num = 0,
    IsBind = true,
}

function ItemData:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

return ItemData