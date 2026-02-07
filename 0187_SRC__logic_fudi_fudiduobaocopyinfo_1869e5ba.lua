
------------------------------------------------
-- Author:
-- Date: 2019-05-18
-- File: FuDiDuoBaoCopyInfo.lua
-- Module: FuDiDuoBaoCopyInfo
-- Description: Blessed Land Treasure Copy Info
------------------------------------------------
-- Quote
local FuDiDuoBaoDamage = require "Logic.FuDi.FuDiDuoBaoDamage"
local FuDiDuoBaoCopyInfo = {
    -- Wave count
    Degree = 0,
    MaxCount = 0,
    -- The number of monsters remaining
    ReMain = 0,
    -- My ranking
    MyRank = 0,
    -- My harm
    MyDamage = 0,
    DamageList = List:New(),
}
function FuDiDuoBaoCopyInfo:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

function FuDiDuoBaoCopyInfo:SetData(msg)
    self.Degree = msg.degree
    self.ReMain = msg.monsterRemain
    self.MaxCount = msg.maxDegree
end
function FuDiDuoBaoCopyInfo:SetDamage(msg)
    for i = 1,#msg.rank do
        local data = nil
        if i>#self.DamageList then
            data = FuDiDuoBaoDamage:New()
            self.DamageList:Add(data)
        else
            data = self.DamageList[i]
        end
        data.Rank = msg.rank[i].top
        data.Damage = msg.rank[i].harm
        data.Name = msg.rank[i].name
    end
    self.MyRank = msg.myRank
    self.MyDamage = msg.myHarm
end
return FuDiDuoBaoCopyInfo