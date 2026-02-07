-- Author: 
-- Date: 2019-04-17
-- File: NatureBaseDrugData.lua
-- Module: NatureBaseDrugData
-- Description: General data on taking medicine for fortune
------------------------------------------------
-- Quote
local BaseAttrData = require "Logic.Nature.NatureBaseAttrData"

local NatureBaseDrugData = {
    ItemID = 0,-- Prop ID
    Level = 0,-- grade
    PeiyangAtt = nil, -- Cultivation attribute percentage growth
    LeveLimit = 0, -- How many can you eat to upgrade
    EatNum = 0, -- How many ate
    AttrList = nil, -- Attribute list value storage NatureBaseAttrData
    Position = 0, -- Location information
}
NatureBaseDrugData.__index = NatureBaseDrugData

function NatureBaseDrugData:New(info,eatnum, total)
    local _M = Utils.DeepCopy(self)
    _M.AttrList = List:New()
    _M.Position = info.Position
    _M.ItemId = info.ItemId
    _M.EatNum = eatnum
    _M.Cfg = info
    if total then
        _M.Total = total
    else
        _M.Total = 0
    end
    _M:UpDateAttrData(info)
    return _M
end

-- Set properties
function NatureBaseDrugData:UpDateAttrData(info)
    local _cs = {';','_'}
    local _attr = Utils.SplitStrByTableS(info.Attribute,_cs)
    self.AttrList:Clear()
    for i=1,#_attr do
        local _data = BaseAttrData:New(_attr[i][1],_attr[i][2] * (self.Total + self.EatNum),0)
        self.AttrList:Add(_data)
    end
    self.LeveLimit = info.LeveLimit
    _attr = Utils.SplitStr(info.PeiyangAtt,"_")
    self.PeiyangAtt = {tonumber(_attr[1]),tonumber(_attr[2])}
    self.Level = info.Level
end
-- Set properties
function NatureBaseDrugData:UpDateAttr()
    if self.Cfg then
        local _cs = {';','_'}
        local _attr = Utils.SplitStrByTableS(self.Cfg.Attribute,_cs)
        self.AttrList:Clear()
        for i=1,#_attr do
            local _data = BaseAttrData:New(_attr[i][1],_attr[i][2] * (self.Total + self.EatNum),0)
            self.AttrList:Add(_data)
        end
    end
end

return NatureBaseDrugData