
------------------------------------------------
-- Author:
-- Date: 2019-05-10
-- File: FuDiPersonRankData.lua
-- Module: FuDiPersonRankData
-- Description: Fudi personal ranking data
------------------------------------------------
-- Quote
local FuDiPersonRankData = {
    -- Ranking
    Rank = 0,
    -- realm
    Vip = 0,
    -- grade
    Level = 0,
    -- Combat power
    FightPoint = 0,
    -- name
    Name = nil,
}

function FuDiPersonRankData:New(msg)
    local _m = Utils.DeepCopy(self)
    _m.Rank = msg.rank
    _m.Vip = msg.realm
    _m.Level = msg.level
    _m.FightPoint = msg.fight
    _m.Name = msg.name
    return _m
end
return FuDiPersonRankData