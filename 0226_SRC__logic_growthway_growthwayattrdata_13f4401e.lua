
------------------------------------------------
-- Author:
-- Date: 2019-07-15
-- File: GrowthWayAttrData.lua
-- Module: GrowthWayAttrData
-- Description: Attribute data of the road to growth
------------------------------------------------
-- Quote
local GrowthWayAttrData = {
    -- Attribute Type
    AttrType = 0,
    -- Attribute value
    AttrValue = 0,
}

function GrowthWayAttrData:New()
    local _m = Utils.DeepCopy(self)
    return _m
end
-- Analyze data
function GrowthWayAttrData:Parase(id,value)
    self.AttrType = id
    self.AttrValue = value
end

return GrowthWayAttrData 