------------------------------------------------
-- Author:
-- Date: 2021-03-01
-- File: GuildBaseInfo.lua
-- Module: GuildBaseInfo
-- Description: Gang basic data
------------------------------------------------
local GuildBaseInfo ={
    guildId = 0,                -- Guild id
    icon = 0,                   -- Guild icon
    name = nil,                 -- Guild name
    lv = 0,                     -- Guild Level
    memberNum = 0,              -- Number of members
    notice = nil,               -- Guild Declaration
    isApply = false,            -- Whether to apply
    limitLv = 0,                -- Restricted level addition
    limitFight = 0,             -- Restricted joining combat power
    RankNum = 1,                -- Ranking
    fighting = 0,               -- Guild battle power
    leaderName = nil,           -- Gang leader name
    guildMoney = 0,             -- Gang Funds
    isAutoJoin = true,
    recruitCd = 0,              -- One-click recruit CD
    Rate = 0,                   -- League level
    MaxNum = 0,                 -- Maximum number of people
    LeaderInfo = nil,
}

function GuildBaseInfo:New()
    local _m = Utils.DeepCopy(self)
    _m.guildId = 0
    _m.icon = 0
    _m.name = nil
    _m.lv = 0
    _m.memberNum = 0
    _m.notice = nil
    _m.isApply = false
    _m.limitLv = 0
    _m.limitFight = 0
    _m.RankNum = 1
    _m.fighting = 0
    _m.leaderName = nil
    _m.guildMoney = 0
    _m.isAutoJoin = true
    _m.recruitCd = 0
    _m.Rate = 0
    _m.MaxNum = 0
    _m.LeaderInfo = nil
    return _m
end

function GuildBaseInfo:GetShowGuildId()
    return tostring(self.guildId)
end
return GuildBaseInfo