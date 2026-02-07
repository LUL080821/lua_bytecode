------------------------------------------------
-- author:
-- Date: 2021-03-12
-- File: TeamMemberInfo.lua
-- Module: TeamMemberInfo
-- Description: Information about team members
------------------------------------------------

local TeamMemberInfo = {
    -- Profession
    Career = 0,
    -- Player ID
    PlayerID = 0,
    -- Player name
    PlayerName = nil,
    -- grade
    Level = 0,
    -- Is it the captain?
    IsLeader = false,
    -- Is it online or not
    IsOnline = false,
    -- Map
    CurMapID = nil,
    -- Combat power
    Power = 0,
    -- Realm level
    StateLevel = 0,
    -- Percentage of blood volume
    HpPro = 0,
    -- Visualize data
    VisualInfo = nil,
    -- Avatar data
    Head = nil,
}

function TeamMemberInfo:New(member)
    local _m = Utils.DeepCopy(self)
    if member ~= nil then
        _m:Parse(member)
    end
    return _m
end

function TeamMemberInfo:Parse(member)
    self.PlayerID = member.roleId
    self.PlayerName = member.name
    self.Level = member.level
    self.Career = member.career
    self.Power = member.power
    self.IsLeader = member.isLeader
    self.IsOnline = member.isOnline
    self.CurMapID = member.mapKey
    self.StateLevel = member.stateLv
    self.HpPro = member.hpPro
    self.VisualInfo = GameCenter.PlayerVisualSystem:GetVisualInfo(self.PlayerID)
    self.Head = member.head
end

return TeamMemberInfo