------------------------------------------------
-- Author:
-- Date: 2019-06-18
-- File: PetEatInfo.lua
-- Module: PetEatInfo
-- Description: Pet Pill Eating Data
------------------------------------------------

local PetSoulInfo = {
    ID = 0,
    -- Configuration data
    Cfg = nil,
    -- Basic properties
    BasePros = nil,
    -- Current number
    CurLevel = 0,
    -- Maximum number
    MaxLevel = 0,
    -- Current attributes
    CurPros = nil,
};

function PetSoulInfo:New(cfg)
    local _m = Utils.DeepCopy(self)
    _m.ID = cfg.Id
    _m.Cfg = cfg
    _m.BasePros = Utils.SplitStrByTableS(cfg.Attribute, {';','_'})
    _m.CurLevel = 0
    _m.MaxLevel = cfg.ConsumptionMax
    _m:CalculatePros()
    return _m
end

-- Set the number of currently activated
function PetSoulInfo:SetCurLevel(level)
    if self.CurLevel ~= level then
        self.CurLevel = level
        self:CalculatePros()
    end
end

-- Calculate the current attribute
function PetSoulInfo:CalculatePros()
    self.CurPros = List:New()
    for i = 1, #self.BasePros do
        self.CurPros:Add({self.BasePros[i][1], self.BasePros[i][2] * self.CurLevel})
    end
end

return PetSoulInfo