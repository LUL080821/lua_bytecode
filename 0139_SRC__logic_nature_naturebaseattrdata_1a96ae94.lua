-- Author: 
-- Date: 2019-04-17
-- File: NatureBaseAttrData.lua
-- Module: NatureBaseAttrData
-- Description: Creation attributes display common data
------------------------------------------------
-- Quote

local NatureBaseAttrData = {
    AttrID = 0,-- Attribute ID
    Attr = 0,-- Current attributes
    AddAttr = 0, -- Upgrade properties
    AttrMin = 0, -- Minimum value for divine weapons
}
NatureBaseAttrData.__index = NatureBaseAttrData

function NatureBaseAttrData:New(attrid,attr,addattr)
    local _M = Utils.DeepCopy(self)
    _M.AttrID = attrid
    _M.Attr = attr
    _M.AddAttr = addattr
    _M.AttrMin = attr
    return _M
end

return NatureBaseAttrData