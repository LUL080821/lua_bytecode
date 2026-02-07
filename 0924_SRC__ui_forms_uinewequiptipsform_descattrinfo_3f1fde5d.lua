------------------------------------------------
-- author:
-- Date: 2019-04-22
-- File: DescAttrInfo.lua
-- Module: DescAttrInfo
-- Description: Equipped with a single attribute data model on TIPS
------------------------------------------------

local DescAttrInfo = {
    ID    = nil,
    Value = nil
}

function DescAttrInfo:New(id, value, col, placeholder, extra)
    local _m = Utils.DeepCopy(self)
    _m.ID = id
    _m.Value = value
    _m.Color = col
    _m.Placeholder = placeholder
    _m.ExtraData = extra
    return _m
end
return DescAttrInfo