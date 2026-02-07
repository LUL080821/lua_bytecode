------------------------------------------------
-- Author:
-- Date: 2019-04-30
-- File: RankAttrData.lua
-- Module: RankAttrData
-- Description: Ranking attribute script
------------------------------------------------
-- Quote
local RankAttrData = {
    -- Attribute Id
    Id = 0,
    -- Icon Id
    IconId = nil,
    -- The corresponding function id is opened
    FuncId = 0,
    Sort = 0,
    Name = nil,
    -- Your own attribute value
    OwenParam = 0,
    -- Opposite attribute value
    OtherParam = 0,
}

function RankAttrData:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

function RankAttrData:SetData(data)
    self.Id = data.id
    local cfg = DataConfig.DataRankCompare[data.id]
    if cfg ~= nil then
        self.IconId = cfg.Pic
        self.Name = cfg.Name
        self.FuncId = cfg.Promote
        self.Sort = cfg.Sort
    end
    self.OwenParam = data.owenValue
    self.OtherParam = data.otherValue
end
return RankAttrData