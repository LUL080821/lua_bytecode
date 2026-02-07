------------------------------------------------
-- author:
-- Date: 2021-03-12
-- File: TeamSystem.lua
-- Module: TeamSystem
-- Description: Team System
------------------------------------------------
local FreeDomerInfo = require "Logic.Team.FreeDomerInfo"
local TeamInfo = require "Logic.Team.TeamInfo"
local TeamMemberInfo = require "Logic.Team.TeamMemberInfo"

local TeamSystem = {
    -- Teaming function enable level
    TeamOpenLv = 0,
    -- Maximum number of team members
    MaxPlayerNum = 3,
    -- Team information
    MyTeamInfo = TeamInfo:New(),
    -- Invitation list information
    InviteInfos = List:New(),
    -- Application list information
    ApplyInfos = List:New(),
    -- All team information for fast team formation
    TeamInfos = List:New(),
    HanHuaCDTime = 0,
    CuiCuCDTime = 0,
    ApplyLeaderCDTime = 0,
    -- Matching
    IsMatching = false,
    -- The currently selected copy ID
    CurrSelectMapID = 0,
    DeltaTime = 0.0,
    CuiCuDeltaTime = 0.0,
    ApplyLeaderDeltaTime = 0.0,
}


-- Is the team full
function TeamSystem:IsMemberFull()
    return #self.MyTeamInfo.MemberList >= self.MaxPlayerNum
end

function TeamSystem:IsExitApply(playerId)
    local _count = #self.ApplyInfos
    for i = 1, _count do
        if self.ApplyInfos[i].PlayerID == playerId then
            return true
        end
    end
    return false
end

function TeamSystem:Initialize()
    self.MaxPlayerNum = tonumber(DataConfig.DataGlobal[1482].Params)
    local _cfg = DataConfig.DataFunctionStart[FunctionStartIdCode.Team]
    if _cfg ~= nil then
        local _param = Utils.SplitNumber(_cfg.StartVariables, '_')
        self.TeamOpenLv = _param[2]
    end
end

-- Request to create a team
function TeamSystem:ReqCreateTeam(cfgID, autoAccept)
    GameCenter.Network.Send("MSG_Team.ReqCreateTeam", {type = cfgID, autoAccept = autoAccept})
    if cfgID == 6002 then
        GameCenter.BISystem:ReqClickEvent(BiIdCode.XMHJCreatTeam)
    elseif cfgID == 6003 then
        GameCenter.BISystem:ReqClickEvent(BiIdCode.SLTCreatTeam)
    end
end

-- Request team information
function TeamSystem:ReqGetTeamInfo()
    GameCenter.Network.Send("MSG_Team.ReqGetTeamInfo")
end
-- Request to adjust the team
function TeamSystem:ReqAlterTeam(isNotice, inType)
    local _teamid = self.MyTeamInfo.TeamID
    GameCenter.Network.Send("MSG_Team.ReqAlterTeam", {isNotice = isNotice, type = inType})
    self.MyTeamInfo.IsNotice = isNotice
    self.MyTeamInfo.Type = inType
end
-- One-click call to win people
function TeamSystem:ReqOneHan(teamType)
    local _type = self.MyTeamInfo.Type
    if teamType ~= nil then
        _type = teamType
    end
    GameCenter.Network.Send("MSG_Team.ReqAlterTeam", {isNotice = true, type = _type, teamId = 0})
end

-- Urge the captain
function TeamSystem:ReqCuiChuLeader()
    GameCenter.Network.Send("MSG_Team.ReqTeamLeaderOpenState")
end

-- Get invitation list, 0 players around, 1 friends, 2 forces
function TeamSystem:ReqGetFreedomList(inType)
    GameCenter.Network.Send("MSG_Team.ReqGetFreedomList", {type = inType})
end

-- Invite someone to join
function TeamSystem:ReqInvite(playerId)
    GameCenter.Network.Send("MSG_Team.ReqInvite", {roleid = playerId})
end

-- Request to agree to join the team
function TeamSystem:ReqInviteRes(teamId, roleId, inType)
    GameCenter.Network.Send("MSG_Team.ReqInviteRes", {teamdId = teamId, roleId = roleId, type = inType})
end

-- Request to get the application list
function TeamSystem:ReqGetApplyList()
    GameCenter.Network.Send("MSG_Team.ReqGetApplyList")
end

-- Application application object, 0 agree to join -1 refuse to join
function TeamSystem:ReqApplyOpt(id, inType)
    GameCenter.Network.Send("MSG_Team.ReqApplyOpt", {id = id, type = inType})
end

-- Get a list of waiting teams
function TeamSystem:ReqGetWaitList(inType)
    GameCenter.Network.Send("MSG_Team.ReqGetWaitList", {type = inType})
end

-- Apply to join
function TeamSystem:ReqApplyEnter(teamId)
    if self:IsTeamExist() then
        Utils.ShowPromptByEnum("TEAM_YOUHAVEDTEAM")
        return
    end
    GameCenter.Network.Send("MSG_Team.ReqApplyEnter", {teamId = teamId})
end

-- Operation team 1 Promote captain 2 Kick out of the team 3 Exit out of the team 4 Disband the team 5 Automatically accept application (reflexive) 6 Apply to become captain 7 Reject team members to become captain
function TeamSystem:ReqTeamOpt(playerId, inType)
    GameCenter.Network.Send("MSG_Team.ReqTeamOpt", {targetId = playerId, opt = inType})
end

-- Summon team members
function TeamSystem:ReqCallAllMember()
    GameCenter.Network.Send("MSG_Team.ReqCallAllMember")
end

-- Teleport to the captain
function TeamSystem:ReqTransport2Leader()
    GameCenter.Network.Send("MSG_Team.ReqTransport2Leader")
end

-- Request to clear the application list
function TeamSystem:ReqCleanApplyList()
    GameCenter.Network.Send("MSG_Team.ReqCleanApplyList")
end

-- Automatic matching
function TeamSystem:ReqMatchAll(inType, match)
    self.IsMatching = match
    GameCenter.Network.Send("MSG_Team.ReqMatchAll", {type = inType, match = match})
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_UITEAMFORM_UPDATE)
    if match then
        if inType == 6002 then
            GameCenter.BISystem:ReqClickEvent(BiIdCode.XMHJTeamAutoMatch)
        elseif inType == 6003 then
            GameCenter.BISystem:ReqClickEvent(BiIdCode.SLTTeamAutoMatch)
        end
    end
end

-- Agree to summon
function TeamSystem:ReqAgreeCall(callid)
    GameCenter.Network.Send("MSG_Team.ReqAgreeCall", {callId = callid})
end

-- Return to team information
function TeamSystem:ResTeamInfo(result)
    if result.teamId == 0 then
        return
    end
    local _noTeam = (#self.MyTeamInfo.MemberList <= 0)
    self.MyTeamInfo.MemberList:Clear()
    self.MyTeamInfo.TeamID = result.teamId
    self.MyTeamInfo.Type = result.type
    self.MyTeamInfo.IsAutoAcceptApply = result.autoAccept
    for i = 1, #result.members do
        local _index = TeamMemberInfo:New(result.members[i])
        self.MyTeamInfo.MemberList:Add(_index)
        local _player = GameCenter.GameSceneSystem:FindPlayer(_index.PlayerID)
        if _player ~= nil then
            _player:UpdateNameColor()
        end
    end
    self:MyTeamMemberSort()
    self:OnTeamChanged()
    if _noTeam then
        if self.MyTeamInfo:IsLeader() then
            Utils.ShowPromptByEnum("TEAM_CREATE_SUCCESS")
        else
            Utils.ShowPromptByEnum("TEAM_ADD_SUCCESS")
        end
    end
end

-- Update information about a player in the team
function TeamSystem:ResUpdateTeamMemberInfo(result)
    local _isExistPlayer = false
    local _info = nil
    for i = 1, #self.MyTeamInfo.MemberList do
        _info = self.MyTeamInfo.MemberList[i]
        if _info.PlayerID == result.member.roleId then
            _isExistPlayer = true
            break
        end
    end
    if not _isExistPlayer then
        Utils.ShowPromptByEnum("TEAM_PLAYERENTERTEAM", result.member.name)
        _info = TeamMemberInfo:New()
        self.MyTeamInfo.MemberList:Add(_info)
    end
    _info:Parse(result.member)
    self:MyTeamMemberSort()
    self:OnTeamChanged()
    local _player = GameCenter.GameSceneSystem:FindPlayer(_info.PlayerID)
    if _player ~= nil then
        _player:UpdateNameColor()
    end
    self:UpdateApplyList(result.member.roleId)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UITEAM_TEAM_SUCC)
end

-- Return to the invitation member list
function TeamSystem:ResFreedomList(result)
    self.InviteInfos:Clear()
    if result.members ~= nil then
        for i = 1, #result.members do
            if not self:IsExitApply(result.members[i].roleId) then
                local _info = FreeDomerInfo:New(result.members[i])
                self.InviteInfos:Add(_info)
            end
        end
    end
    self.InviteInfos:Sort(function(x, y)
        return x.Honey > y.Honey
    end)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UITEAMINVITEFORM_UPDATE)
end

-- Return to the invitation
function TeamSystem:ResInviteInfo(result)
    local _teamId = result.teamdId
    local _playerId = result.roleId
    local _name = result.name

    if GameCenter.GameSetting:GetSetting(GameSettingKeyCode.MandateAutoJoinTeam) > 0 then
        self:ReqInviteRes(_teamId, _playerId, 0)
    else
        Utils.ShowMsgBoxAndBtn(function(x)
            if x == MsgBoxResultCode.Button1 then
                self:ReqInviteRes(_teamId, _playerId, -1)
            elseif x == MsgBoxResultCode.Button2 then
                self:ReqInviteRes(_teamId, _playerId, 0)
            end
        end, "TEAM_REFUSE", "TEAM_JOIN", "TEAM_0INVITEYOU", _name)
    end
end

-- Return to the application list
function TeamSystem:ResApplyList(result)
    self.ApplyInfos:Clear()
    if result.members ~= nil then
        for i =1, #result.members do
            if not self:IsExitApply(result.members[i].roleId) then
                local _info = FreeDomerInfo:New(result.members[i])
                self.ApplyInfos:Add(_info)
            end
        end
    end
    self:SetTeamNotice()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UITEAMAPPLYFORM_UPDATE)
end

-- Add applicant
function TeamSystem:ResAddApplyer(result)
    local _state = self.MyTeamInfo.IsAutoAcceptApply
    if _state then
        self:ReqApplyOpt(result.member.roleId, 0)
    else
        if not self:IsExitApply(result.member.roleId) then
            Utils.ShowPromptByEnum("TEAM_NEWPLAYER_JOIN")
            local _info = FreeDomerInfo:New(result.member)
            self.ApplyInfos:Add(_info)
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UITEAMAPPLYFORM_UPDATE)
            self:SetTeamNotice()
        end
    end
end

-- Return to the waiting team
function TeamSystem:ResWaitList(result)
    self.TeamInfos:Clear()
    if result.teams ~= nil then
        for i = 1, #result.teams do
            local _info = TeamInfo:New()
            _info.TeamID = result.teams[i].teamId
            _info.Type = result.teams[i].type
            for j = 1, #result.teams[i].members do
                local _index = TeamMemberInfo:New(result.teams[i].members[j])
                _info.MemberList:Add(_index)
            end
            self.TeamInfos:Add(_info)
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UITEAMMATCHFORM_UPDATE)
end

-- Delete team members
function TeamSystem:ResDeleteTeamMember(result)
    local _roleId = result.roleId
    local _ownId = GameCenter.GameSceneSystem:GetLocalPlayerID()
    if _ownId ~= _roleId then
        for i = 1, #self.MyTeamInfo.MemberList do
            local _playerId = self.MyTeamInfo.MemberList[i].PlayerID
            if _playerId == _roleId then
                Utils.ShowPromptByEnum("TEAM_PLAYERLEAVETEAM", self.MyTeamInfo.MemberList[i].PlayerName)
                self.MyTeamInfo.MemberList:RemoveAt(i)
                break
            end
        end
        self:MyTeamMemberSort()
        local _player = GameCenter.GameSceneSystem:FindPlayer(_roleId)
        if _player ~= nil then
            _player:UpdateNameColor()
        end
    else
        self.MyTeamInfo.Type = 0
        self.MyTeamInfo.TeamID = 0
        self.HanHuaCDTime = 0
        for i = #self.MyTeamInfo.MemberList, 1, -1 do
            local _playerID = self.MyTeamInfo.MemberList[i].PlayerID
            self.MyTeamInfo.MemberList:RemoveAt(i)
            local _player = GameCenter.GameSceneSystem:FindPlayer(_playerID)
            if _player ~= nil then
                _player:UpdateNameColor()
            end
        end
        self.ApplyInfos:Clear()
        self:SetTeamNotice()
    end
    self:OnTeamChanged()
end

-- Summon the team members back
function TeamSystem:ResCallAllMemberRes(result)
    local _callId = result.callId
    local _mapName = string.gsub(result.name, "2&_", "")
    _mapName = GameCenter.LanguageConvertSystem:ConvertLan(_mapName)
    local _posX = math.floor(result.x)
    local _posY = math.floor(result.y)
    Utils.ShowMsgBoxAndBtn(function(x)
        if x == MsgBoxResultCode.Button2 then
            self:ReqAgreeCall(_callId)
        end
    end, "C_MSGBOX_CANEL", "C_MSGBOX_AGREE", "TEAM_LEADER_ZHAOJI", _posX, _posY)
end

-- Return to real-time update of player map and health
function TeamSystem:ResUpdateHPAndMapKey(result)
    local _info = nil
    for i= 1, #self.MyTeamInfo.MemberList do
        _info = self.MyTeamInfo.MemberList[i]
        if _info.PlayerID == result.roleId then
            _info.CurMapID = result.mapKey
            _info.HpPro = result.hpPro
        end
    end
    self:OnTeamChanged(1)
end

function TeamSystem:OnTeamChanged(param)
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_UITEAMFORM_UPDATE, param)
end

function TeamSystem:ResMatchAll(result)
    self.IsMatching = false
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UITEAMAUTOMATCH_OVER)
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_UITEAMFORM_UPDATE)
    if result.success then
        Utils.ShowPromptByEnum("TEAM_AUTOMATCHSUCEESS")
        GameCenter.PushFixEvent(UIEventDefine.UITeamForm_CLOSE)
    else
        Utils.ShowPromptByEnum("TEAM_HAVENOTEAMCREATETEAM")
    end
end

function TeamSystem:ResTeamLeaderOpenState(result)
    if result.state == 0 then
        local _id = GameCenter.GameSceneSystem:GetLocalPlayerID()
        if _id == result.leaderId then
            Utils.ShowPromptByEnum("TEAM_CUICHULEADERDADAO", self:GetTeamTargetTypeName())
        else
            self.CuiCuCDTime = 10
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UITEAMCUICUCD)
        end
    elseif result.state == 1 then
        Utils.ShowPromptByEnum("TEAM_LEADERNOTONLINE")
    else
        Utils.ShowPromptByEnum("TEAM_NOTHAVETEAMCUNZAI")
    end
end

function TeamSystem:ResBecomeLeader(result)
    local _player = self.MyTeamInfo:GetMemderInfo(result.targetId)
    if _player ~= nil then
        Utils.ShowMsgBoxAndBtn(function(x)
            if x == MsgBoxResultCode.Button1 or x == MsgBoxResultCode.None then
                self:ReqTeamOpt(result.targetId, 7)
            else
                self:ReqTeamOpt(result.targetId, 1)
            end
        end, "TEAM_REFUSE", "agree", "TEAM_0APPLYLEADER", _player.PlayerName)
    end
end

-- Set up application tips
function TeamSystem:SetTeamNotice()
    local _state = (#self.ApplyInfos > 0)
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.TeamInfo, state)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UITEAMREDPOINT)
end

-- Determine whether the player has a team
function TeamSystem:IsTeamExist()
    return #self.MyTeamInfo.MemberList > 0
end

-- Determine whether a player is a member
function TeamSystem:IsTeamMember(ID)
    return self.MyTeamInfo:IsTeamMember(ID)
end

-- Sorting members of your own team
function TeamSystem:MyTeamMemberSort()
    local _lpId = GameCenter.GameSceneSystem:GetLocalPlayerID()
    if #self.MyTeamInfo.MemberList > 1 then
        for i = 1, #self.MyTeamInfo.MemberList do
            if self.MyTeamInfo.MemberList[i].PlayerID == _lpId and i ~= 1 then
                local _info = self.MyTeamInfo.MemberList[1]
                self.MyTeamInfo.MemberList[1] = self.MyTeamInfo.MemberList[i]
                self.MyTeamInfo.MemberList[i] = _info
                break
            end
        end
    end
end

-- Clear a request from a player in the application list
function TeamSystem:ClearApplyPlayer(playerId)
    for i = 1, #self.ApplyInfos do
        if self.ApplyInfos[i].PlayerID == playerId then
            self.ApplyInfos:RemoveAt(i)
            break
        end
    end
end

-- Create a team and set team goals
function TeamSystem:CreateTeamAndSetTarget(cfg)
    if not self:IsTeamExist() then
        self:ReqCreateTeam(cfg.Id, self.MyTeamInfo.IsAutoAcceptApply)
    end
    self:SetTeamTarget(cfg)
end

-- Set the current team target
function TeamSystem:SetTeamTarget(cfg)
    self:ReqAlterTeam(false, cfg.Id)
end

-- Update the team application list
function TeamSystem:UpdateApplyList(playerId)
    for i= 1, #self.ApplyInfos do
        if self.ApplyInfos[i].PlayerID == playerId then
            self.ApplyInfos:RemoveAt(i)
            break
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UITEAMREDPOINT)
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.TeamInfo, #self.ApplyInfos > 0)
end

-- Check whether the invited players have reached the team level
function TeamSystem:CheckInviteIsOpenTeam(playerId)
    for i = 1, #self.InviteInfos do
        local _info = self.InviteInfos[i]
        if _info.PlayerID == playerId then
            return _info.Level >= self.TeamOpenLv, _info.PlayerName
        end
    end
    return false, nil
end

-- Invite players to team up
function TeamSystem:InviteJoinTeam(playerId, mapId, isOneHan)
    local _lpId = GameCenter.GameSceneSystem:GetLocalPlayerID()
    -- Existing team
    if self:IsTeamExist() then
        -- Only yourself
        if #self.MyTeamInfo.MemberList == 1 then
            -- Switch target map
            self:ReqAlterTeam(false, mapId)
            -- Invite to join the team
            if playerId > 0 then
                self:ReqInvite(playerId)
            end
        else -- There are two people
            local _otherPlayerId = 0
            for i = 1, #self.MyTeamInfo.MemberList do
                if self.MyTeamInfo.MemberList[i].PlayerID ~= _lpId then
                    _otherPlayerId = self.MyTeamInfo.MemberList[i].PlayerID
                end
            end
            -- If the other happens to be the invitation
            if playerId > 0 and playerId == _otherPlayerId then
                -- Switch the target map (If you are a team member, the switch will fail)
                self:ReqAlterTeam(false, mapId)
            else
                Utils.ShowPromptByEnum("C_TEAM_HAVE_TEAM")
            end
        end
    else-- No team exists
        -- Create a team
        self:ReqCreateTeam(mapId, self.MyTeamInfo.IsAutoAcceptApply)
        -- Invite to join the team
        if playerId > 0 then
            self:ReqInvite(playerId)
        end
    end
    -- One-click shout
    if isOneHan then
        self:ReqOneHan(mapId)
    end
end

function TeamSystem:GetTeamTargetTypeName()
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return ""
    end
    local _memberList = self.MyTeamInfo.MemberList
    if #_memberList > 0 then
        if self.MyTeamInfo.Type == -1 then
            return DataConfig.DataMessageString.Get("TEAM_ALL_ACTIVITY")
        elseif self.MyTeamInfo.Type == -2 then
            return DataConfig.DataMessageString.Get("TEAM_JINGYINGBOSS")
        end
    else
        return DataConfig.DataMessageString.Get("TEAM_WU")
    end
    return ""
end

-- renew
function TeamSystem:Update(dt)
    if self.HanHuaCDTime > 0 then
        self.DeltaTime = self.DeltaTime + dt
        if self.DeltaTime >= 1 then
            self.DeltaTime = self.DeltaTime - 1
            self.HanHuaCDTime = self.HanHuaCDTime - 1
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UITEAMHANHUACD)
        end
    end
    if self.CuiCuCDTime > 0 then
        self.CuiCuDeltaTime = self.CuiCuDeltaTime - dt
        if self.CuiCuDeltaTime >= 1.0 then
            self.CuiCuDeltaTime = self.CuiCuDeltaTime - 1
            self.CuiCuCDTime = self.CuiCuCDTime - 1
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UITEAMCUICUCD)
        end
    end
    
    if self.ApplyLeaderCDTime > 0 then
        self.ApplyLeaderDeltaTime = self.ApplyLeaderDeltaTime + dt
        if self.ApplyLeaderDeltaTime >= 1.0 then
            self.ApplyLeaderDeltaTime = self.ApplyLeaderDeltaTime - 1
            self.ApplyLeaderCDTime = self.ApplyLeaderCDTime - 1
        end
    end
end

return TeamSystem