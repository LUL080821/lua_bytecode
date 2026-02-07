------------------------------------------------
-- author:
-- Date: 2021-03-12
-- File: FreeDomerInfo.lua
-- Module: FreeDomerInfo
-- Description: Information about the applicant member
------------------------------------------------
local FreeDomerInfo = {
    Career = 0,
    PlayerID = 0,
    PlayerName = nil,
    Level = 0,
    Power = 0,
    Honey = 0,
    GuildName = nil,
    Card = 0,
    Camp = 0,
    Head = nil,
}

function FreeDomerInfo:New(member)
    local _m = Utils.DeepCopy(self)
    _m.Career = member.career
    _m.PlayerID = member.roleId
    _m.PlayerName = member.name
    _m.GuildName = member.guildName
    _m.Power = member.power
    _m.Level = member.level
    _m.Honey = member.honey
    _m.Card = member.moonandOver
    _m.Camp = member.birthGroup
    _m.Head = member.head
    return _m
end

return FreeDomerInfo