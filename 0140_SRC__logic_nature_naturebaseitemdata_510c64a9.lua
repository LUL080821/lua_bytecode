-- Author: 
-- Date: 2019-04-17
-- File: NatureBaseItemData.lua
-- Module: NatureBaseItemData
-- Description: The creation props display common data
------------------------------------------------
-- Quote

local NatureBaseItemData = {
    ItemID = 0,-- Prop ID
    ItemExp = 0,-- Experience in using props to improve, some systems do not need to read this thing, some express the number of props
}
NatureBaseItemData.__index = NatureBaseItemData

function NatureBaseItemData:New(itemid,exp)
    local _M = Utils.DeepCopy(self)
    _M.ItemID = itemid
    _M.ItemExp = exp
    return _M
end

return NatureBaseItemData