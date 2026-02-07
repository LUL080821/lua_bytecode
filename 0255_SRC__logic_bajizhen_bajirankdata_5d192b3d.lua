
------------------------------------------------
-- Author:
-- Date: 2019-09-23
-- File: BaJiRankData.lua
-- Module: BaJiRankData
-- Description: Level 8 array chart ranking data
------------------------------------------------
-- Quote
local BaJiRankData = {
    Rank = 0,
    Name = nil,
    Score = nil,
    ItemStr = nil,
    ColorId = 0,
    Sid = 0,
}

function BaJiRankData:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

function BaJiRankData:Parase(msg, index, rankType)
    self.Rank = index
    self.Name = msg.name
    self.Score = msg.integral
    self.ColorId = msg.colorCamp
    self.Sid = msg.serverid
    -- Set reward string
    DataConfig.DataEightCityReward:Foreach(function(k, v)
        if v.Type == rankType then
            local list = Utils.SplitStr(v.Rank,'_')
            local min = tonumber(list[1])
            local max = tonumber(list[2])
            if index<= max and index >= min then
                self.ItemStr = v.Reward
                return
            end
        end
    end)
end

function BaJiRankData:Clear()
    self.Rank = 0
    self.Name = nil
    self.Score = 0
end

return BaJiRankData