
------------------------------------------------
-- Author:
-- Date: 2019-05-18
-- File: FuDiDuoBaoDamage.lua
-- Module: FuDiDuoBaoDamage
-- Description: Blessed Treasure Hunt Duplicate Damage Data
------------------------------------------------
-- Quote
local FuDiDuoBaoDamage = {
    Rank = 0,
    Damage = 0,
    Name = nil,
}

function FuDiDuoBaoDamage:New()
    local _m = Utils.DeepCopy(self)
    return _m
end
return FuDiDuoBaoDamage