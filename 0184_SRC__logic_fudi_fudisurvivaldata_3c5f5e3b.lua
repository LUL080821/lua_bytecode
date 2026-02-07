
------------------------------------------------
-- Author:
-- Date: 2019-05-13
-- File: FuDiSurvivalData.lua
-- Module: FuDiSurvivalData
-- Description: Blessed Boss Data
------------------------------------------------
-- Quote
local FuDiSurvivalData = {
    MonsterType = 0,
    Count = 0,
}

function FuDiSurvivalData:New(msg)
    local _m = Utils.DeepCopy(self)
    _m.MonsterType = msg.type
    _m.Count = msg.num
    return _m
end

function FuDiSurvivalData:SetData(msg)
    self.MonsterType = msg.type
    self.Count = msg.num
end
return FuDiSurvivalData