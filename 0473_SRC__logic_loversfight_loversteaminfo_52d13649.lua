------------------------------------------------
-- Author:
-- Date: 2021-07-15
-- File: LoversTeamInfo.lua
-- Module: LoversTeamInfo
-- Description: Immortal Couple Team Information
------------------------------------------------

local L_PlayerInfo = require "Logic.LoversFight.LoverInfo"

local LoversTeamInfo = {
    -- Showdown stage
    --Step = LoverFightStep.Default,
    Id = 0,
    -- Register or not
    IsJoin = false,
    -- Team name
    Name = nil,
    -- Winning rate
    WinPercent = 0,
    -- Number of contests
    FightCount = 0,
    -- Current ranking
    Rank = 0,
    -- integral
    Score = 0,
    -- Number of remaining times
    LeftCount = 0,
    -- Player information
    Player_1 = nil,
    Player_2 = nil,
    -- Time to attend
    JoinTime = nil,
    -- Is it prompted
    IsMsgTishi = true,
    IsTickTiShi = true,
    MsgBoxActive = false,
}

function LoversTeamInfo:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

function LoversTeamInfo:ParseMsg(msg)
    self.IsJoin = msg.isApply
    if msg.team ~= nil then
        self.Id = msg.team.id
        self.Name = msg.team.name
        if msg.team.roles ~= nil then
            for i = 1, #msg.team.roles do
                if i == 1 then
                    self.Player_1 = L_PlayerInfo:New()
                    self.Player_1:ParseMsg(msg.team.roles[1])
                elseif i == 2 then
                    self.Player_2 = L_PlayerInfo:New()
                    self.Player_2:ParseMsg(msg.team.roles[2])
                end
            end
        end
    end
    if msg.trials ~= nil then
        local _trials = msg.trials
        self.FightCount = _trials.count
        self.WinPercent = _trials.rate
        self.Rank = _trials.rank
        self.Score = _trials.score
    end
end

function LoversTeamInfo:ParseMsgEx(msg)
    if msg.team ~= nil then
        self.Id = msg.team.id
        self.Name = msg.team.name
        if msg.team.roles ~= nil then
            for i = 1, #msg.team.roles do
                if i == 1 then
                    self.Player_1 = L_PlayerInfo:New()
                    self.Player_1:ParseMsg(msg.team.roles[1])
                elseif i == 2 then
                    self.Player_2 = L_PlayerInfo:New()
                    self.Player_2:ParseMsg(msg.team.roles[2])
                end
            end
        end
    end
    if msg.trials ~= nil then
        local _trials = msg.trials
        self.FightCount = _trials.count
        self.WinPercent = _trials.rate
        self.Rank = _trials.rank
        self.Score = _trials.score
    end
end

function LoversTeamInfo:ParseTeam(team)
    if team ~= nil then
        self.Id = team.id
        self.Name = team.name
        if team.roles ~= nil then
            for i = 1, #team.roles do
                if i == 1 then
                    self.Player_1 = L_PlayerInfo:New()
                    self.Player_1:ParseMsg(team.roles[1])
                elseif i == 2 then
                    self.Player_2 = L_PlayerInfo:New()
                    self.Player_2:ParseMsg(team.roles[2])
                end
            end
        end
    end
end

function LoversTeamInfo:ParaseTrials(trials)
    if trials ~= nil then
        self.FightCount = trials.count
        self.WinPercent = trials.rate
        self.Rank = trials.rank
        self.Score = trials.score
    end
end

function LoversTeamInfo:ParseRank(msg)
    self.WinPercent = msg.rate
    self.Rank = msg.rank
    self.Score = msg.score
end

-- Get the time to participate
function LoversTeamInfo:GetJoinTime()
    if self.JoinTime == nil then
        local _cfg = DataConfig.DataGlobal[GlobalName.Marry_battle_time]
        if _cfg ~= nil then
            local _list = Utils.SplitStr(_cfg.Params, ';')
            local _values = Utils.SplitNumber(_list[1], '_')     
            local _week = _values[1]
            local _start = _values[2]
            local _end = _values[3]
            self.JoinTime = {Week = _week, Start = _start, End = _end}
        end
    end
    return self.JoinTime
end

function LoversTeamInfo:CanJoin(week, startSec)
    local _ret = false
    local _joinTime = self:GetJoinTime()
    if _joinTime ~= nil then
        if week == _joinTime.Week then
            local _curSec = GameCenter.HeartSystem.ServerZoneTime - startSec
            if _curSec >= _joinTime.Start * 60 and _curSec <= _joinTime.End * 60 then
                local _funcInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.LoversFreeFight)
                if _funcInfo ~= nil and _funcInfo.IsVisible then
                    _ret = true
                end
            end
        end
    end
    return _ret
end

function LoversTeamInfo:CheckMsgTpis(week, startSec)
    local _ret = false
    local _canJoin = self:CanJoin(week, startSec)
    if _canJoin and not self.MsgBoxActive and GameCenter.MapLogicSystem.MapCfg ~= nil and GameCenter.MapLogicSystem.MapCfg.ReceiveType == 2 then
        -- Can participate in group competitions
        self.MsgBoxActive = true
        GameCenter.MsgPromptSystem:ShowSelectMsgBox(
            "ŐņŗĸŇŐĿřśıÁĩĸŒúĮıĻŊĺĨħņœŊŇįŐŊōįŞ",
            DataConfig.DataMessageString.Get("C_MSGBOX_CANCEL"),
            DataConfig.DataMessageString.Get("C_MSGBOX_OK"),
            function (code)
                if code == MsgBoxResultCode.Button2 then
                    -- Open the fairy couple duel interface
                    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.LoversFight)
                end
                self.MsgBoxActive = false
            end,
            function (select)
                if select then
                    self.IsMsgTishi = false
                else
                    self.IsMsgTishi = true
                end
            end,
            DataConfig.DataMessageString.Get("MASTER_BENCILOGINNOTNOTICE"),
            false, false, 15, 4, 1, nil, nil, 0, true
        )
        _ret = true
    end
    return _ret
end

return LoversTeamInfo