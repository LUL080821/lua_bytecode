------------------------------------------------
-- Author: 
-- Date: 2020-08-20
-- File: YYHDItem.lua
-- Module: YYHDItem
-- Description: Operating active items
------------------------------------------------

local YYHDItemData = {
    -- Item ID
    ItemID = 0,
    -- Quantity of items
    ItemCount = 0,
    -- Need a career
    Occ = 0,
    -- Whether to bind
    IsBind = false,
}

function YYHDItemData:New(itemTable)
    local _m = Utils.DeepCopy(self)
    _m.ItemID = itemTable.i
    _m.ItemCount = itemTable.n
    _m.Occ = itemTable.c
    _m.IsBind = itemTable.b ~= 0
    return _m
end

return YYHDItemData