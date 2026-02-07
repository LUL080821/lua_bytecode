
------------------------------------------------
-- Author:
-- Date: 2019-10-29
-- File: LingTiCel.lua
-- Module: LingTiCel
-- Description: Spiritual equipment grid data
------------------------------------------------
-- Quote
local LingTiCel = {
    -- Equipment ID
    EquipId = 0,
    -- Quality frame name
    IconName = 0,
}

function LingTiCel:New()
    local _m = Utils.DeepCopy(self)
    _m.StarNum = 0
    return _m
end

function LingTiCel:Parase()
end

return LingTiCel