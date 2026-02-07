
------------------------------------------------
-- Author:
-- Date: 2019-05-10
-- File: FuDiRankData.lua
-- Module: FuDiRankData
-- Description: Blessed Land Ranking Data
------------------------------------------------
-- Quote
local PersonData = require "Logic.FuDi.FuDiPersonRankData"
local FuDiGuildRankData = {
    GuildId = 0,
    MyRank = -1,
    GuildName = nil,
    PersonList = List:New()
}

function FuDiGuildRankData:New(msg)
    local _m = Utils.DeepCopy(self)
    _m.GuildId = msg.guildId
    if msg.myRank == nil then
        _m.MyRank = -1
    else
        _m.MyRank = msg.myRank
    end
    _m.GuildName = msg.name
    if msg.menberRank ~= nil then
        for i = 1,#msg.menberRank do
            local rankInfo = PersonData:New(msg.menberRank[i])
            _m.PersonList:Add(rankInfo)
        end
    end
    _m.PersonList:Sort(function(a,b)
        return a.Rank < b.Rank
     end )
    return _m
end
return FuDiGuildRankData