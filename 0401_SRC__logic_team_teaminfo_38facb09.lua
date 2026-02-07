------------------------------------------------
-- author:
-- Date: 2021-03-12
-- File: TeamInfo.lua
-- Module: TeamInfo
-- Description: Team Information
------------------------------------------------
local TeamInfo = {
    TeamID = 0,
    Type = 0,
    IsNotice = false,
    IsAutoAcceptApply = false,
    MemberList = List:New(),
}

function TeamInfo:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

function TeamInfo:IsTeamMember(id)
    for i = 1, #self.MemberList do
        if id == self.MemberList[i].PlayerID then
            return true
        end
    end
    return false
end
function TeamInfo:GetMemderInfo(id)
    for i = 1, #self.MemberList do
        if id == self.MemberList[i].PlayerID then
            return self.MemberList[i]
        end
    end
    return nil
end

-- Get the captain
function TeamInfo:GetLeader()
    for i = 1, #self.MemberList do
        if self.MemberList[i].IsLeader then
            return self.MemberList[i]
        end
    end
    return nil
end

-- Determine whether you are the captain
function TeamInfo:IsLeader()
    local _lpId = GameCenter.GameSceneSystem:GetLocalPlayerID()
    local _lpMem = self:GetMemderInfo(_lpId)
    if _lpMem ~= nil then
        return _lpMem.IsLeader
    end
    return false
end
-- Determine whether a playerid is the captain
function TeamInfo:PlayerIsLeader(playerId)
    local _men = self:GetMemderInfo(playerId)
    if _men ~= nil then
        return _men.IsLeader
    end
    return false
end
-- Get your own mapid
function TeamInfo:GetSelfMapID()
    local _lpId = GameCenter.GameSceneSystem:GetLocalPlayerID()
    local _lpMem = self:GetMemderInfo(_lpId)
    if _lpMem ~= nil then
        return _lpMem.CurMapID
    end
    return ""
end

return TeamInfo