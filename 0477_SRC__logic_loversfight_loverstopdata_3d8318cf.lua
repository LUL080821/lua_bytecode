------------------------------------------------
-- Author:
-- Date: 2021-07-15
-- File: LoversTopData.lua
-- Module: LoversTopData
-- Description: Fairy Couple Championship data
------------------------------------------------

local L_TeamInfo = require "Logic.LoversFight.LoversTeamInfo"
local LoversTopData = {
    Type = 0,
    -- Which round
    Round = 0,
    GroupDic = Dictionary:New(),
    -- Guess data
    GuessInfo = nil,
    TimeDic = nil,
    -- Current betting list
    GuessList = List:New(),
    -- Participation time
    L_JoinTime = nil,
    -- Time to participate in the Tianbang
    H_JoinTime = nil,
    H_IsMsgTishi = true,
    H_IsReceiveJinJi = false,
    H_MsgBoxActive = false,
    H_TimeDic = nil,
    H_IsTickTiShi = true,
    -- Place list
    L_IsMsgTishi = true,
    L_IsReceiveJinJi = false,
    L_MsgBoxActive = false,
    L_TimeDic = nil,
    L_IsTickTiShi = true,
}

function LoversTopData:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

function LoversTopData:ParseMsg(msg)
    if msg == nil then
        return
    end
    self.GroupDic:Clear()
    self.Type = msg.type
    self.Round = msg.round
    Debug.LogError("ttttttttttttttttttt----::"..msg.type)
    Debug.LogError("rrrrrrrrrrrrrrrrrrr----::"..msg.round)
    Debug.LogError("lllllllllllllllllll----::"..#msg.rounds.groups)
    if msg.rounds.groups ~= nil then
        for i = 1, #msg.rounds.groups do
            local _groupMsg = msg.rounds.groups[i]
            local _id = _groupMsg.id
            local _teamList = List:New()
            if _groupMsg.t1 ~= nil then
                local _team1 = L_TeamInfo:New()
                local _team_1 = _groupMsg.t1.team
                _team1:ParseTeam(_team_1)
                _teamList:Add({State = _groupMsg.t1.type, Team = _team1})
            end
            if _groupMsg.t2 ~= nil then
                local _team2 = L_TeamInfo:New()
                local _team_2 = _groupMsg.t2.team
                _team2:ParseTeam(_team_2)
                _teamList:Add({State = _groupMsg.t2.type, Team = _team2})
            end
            self.GroupDic:Add(_id, _teamList)
        end
    end
end

function LoversTopData:ParseGuessMsg(msg)
    if msg == nil then
        return
    end
    if msg.guess ~= nil then
        self.GuessInfo = {FightId = msg.guess.fightId, G1 = msg.guess.g1, G2 = msg.guess.g2 }
        for i = 1, #self.GuessList do
            local _guess = self.GuessList[i]
            if _guess.FightId == msg.guess.fightId then
                _guess.G1 = msg.guess.g1
                _guess.G2 = msg.guess.g2
                break
            end
        end
    end
end

function LoversTopData:ParseGuessListMsg(msg, type)
    if msg == nil then
        return
    end
    self.GuessList:Clear()
    if msg ~= nil then
        for i = 1, #msg do
            local _data = {FightId = msg[i].fightId, G1 = msg[i].g1, G2 = msg[i].g2, Type = type}
            self.GuessList:Add(_data)
        end
    end
end

function LoversTopData:GetGuessInfo(id)
    local _ret = nil
    for i = 1, #self.GuessList do
        local _guess = self.GuessList[id]
        if _guess ~= nil then
            _ret = _guess
            break
        end
    end
    return _ret
end

function LoversTopData:GetRound_L(sec)
    local _ret = -1
    local _timeDic = self:GetTimeDicL()
    local _keys = _timeDic:GetKeys()
    if _keys ~= nil then
        for i = 1, #_keys do
            local _key = _keys[i]
            local _time = _timeDic[_key]
            if _time ~= nil then
                if sec >= _time.PreStart * 60 and sec <= _time.End * 60 then
                    _ret = _key
                    break
                end
            end
        end
    end
    return _ret
end

function LoversTopData:GetRound_H(sec)
    local _ret = -1
    local _timeDic = self:GetTimeDicH()
    local _keys = _timeDic:GetKeys()
    if _keys ~= nil then
        for i = 1, #_keys do
            local _key = _keys[i]
            local _time = _timeDic[_key]
            if _time ~= nil then
                if sec >= _time.PreStart * 60 and sec <= _time.End * 60 then
                    _ret = _key
                    break
                end
            end
        end
    end
    return _ret
end

function LoversTopData:IsCrossFinalRound_H(preSec, sec)
    local _ret = false
    local _timeDic = self:GetTimeDicH()
    local _time = _timeDic[4]
    if _time ~= nil then
        if preSec <= _time.End * 60 and sec >= _time.End * 60 then
            _ret = true
        end
    end
    return _ret
end

function LoversTopData:IsCrossFinalRound_L(preSec, sec)
    local _ret = false
    local _timeDic = self:GetTimeDicL()
    local _time = _timeDic[4]
    if _time ~= nil then
        if preSec <= _time.End * 60 and sec >= _time.End * 60 then
            _ret = true
        end
    end
    return _ret
end

function LoversTopData:IsCrossFinalRound_L()
end

function LoversTopData:GetRoundTime(round)
    local _ret = nil
    if self.Type == 1 then
        _ret = self:GetRoundTime_H(round)
    elseif self.Type == 2 then
        _ret = self:GetRoundTime_L(round)
    end
    return _ret
end

function LoversTopData:GetRoundTime_L(round)
    local _ret = nil
    local _timeDic = self:GetTimeDicL()
    _ret = _timeDic[round]
    return _ret
end

function LoversTopData:GetRoundTime_H(round)
    local _ret = nil
    local _timeDic = self:GetTimeDicH()
    _ret = _timeDic[round]
    return _ret
end

-- Get team information for the championship match through team id
function LoversTopData:GetTeamInfo(teamId)
    local _ret = nil
    local _keys = self.GroupDic:GetKeys()
    if _keys ~= nil then
        for i = 1, #_keys do
            local _key = _keys[i]
            local _teamList = self.GroupDic[_key]
            if _teamList ~= nil then
                for m = 1, #_teamList do
                    local _team = _teamList[m].Team
                    if _team.Id == teamId then
                        _ret = _team
                        break
                    end
                end
            end
        end
    end
    return _ret
end

function LoversTopData:GetL_NextTime()
    local _ret = {Time = 0, Round = 0}
    local _curSec = GameCenter.HeartSystem.ServerZoneTime - GameCenter.LoversFightSystem.StartSec
    local function _Func(key, value)
        if value.Type == 3 then
            local _list = Utils.SplitNumber(value.StartTime, '_')
            local _time = _list[2]
            if _time > _curSec / 60 then
                _ret.Time = GameCenter.HeartSystem.ServerZoneTime + (_time * 60 - _curSec)
                _ret.Round = value.Game
                return true
            end
        end
    end
    DataConfig.DataMarryBattleTime:ForeachCanBreak(_Func)
    return _ret
end

function LoversTopData:GetH_NextTime()
    local _ret = {Time = 0, Round = 0}
    local _curSec = GameCenter.HeartSystem.ServerZoneTime - GameCenter.LoversFightSystem.StartSec
    local function _Func(key, value)
        if value.Type == 4 then
            local _list = Utils.SplitNumber(value.StartTime, '_')
            local _time = _list[2]
            if _time > _curSec / 60 then
                _ret.Time = GameCenter.HeartSystem.ServerZoneTime + (_time * 60 - _curSec)
                _ret.Round = value.Game
                return true
            end
        end
    end
    DataConfig.DataMarryBattleTime:ForeachCanBreak(_Func)
    return _ret
end

-- Get the participation time of the place list
function LoversTopData:GetJoinTimeL()
    if self.L_JoinTime == nil then
        local _cfg = DataConfig.DataGlobal[GlobalName.Marry_battle_time]
        if _cfg ~= nil then
            local _list = Utils.SplitStr(_cfg.Params, ';')
            local _values = Utils.SplitNumber(_list[3], '_')     
            local _week = _values[1]
            local _start = _values[2]
            local _end = _values[3]
            self.L_JoinTime = {Week = _week, Start = _start, End = _end}
        end
    end
    return self.L_JoinTime
end

function LoversTopData:CanJoinL(week, startTime)
    local _ret = false
    local _joinTime = self:GetJoinTimeL()
    if _joinTime ~= nil then
        if week == _joinTime.Week then
            local _curSec = GameCenter.HeartSystem.ServerZoneTime - startTime
            if _curSec >= _joinTime.Start * 60 and _curSec <= _joinTime.End * 60 then
                _ret = true
            end
        end
    end
    return _ret
end

function LoversTopData:IsOverL(week, startTime)
    local _ret = false
    local _joinTime = self:GetJoinTimeL()
    if _joinTime ~= nil then
        if week == _joinTime.Week then
            local _curSec = GameCenter.HeartSystem.ServerZoneTime - startTime
            if _curSec > _joinTime.End * 60 then
                _ret = true
            end
        end
    end
    return _ret
end

-- Get the Tianlist to participate
function LoversTopData:GetJoinTimeH()
    if self.H_JoinTime == nil then
        local _cfg = DataConfig.DataGlobal[GlobalName.Marry_battle_time]
        if _cfg ~= nil then
            local _list = Utils.SplitStr(_cfg.Params, ';')
            local _values = Utils.SplitNumber(_list[4], '_')     
            local _week = _values[1]
            local _start = _values[2]
            local _end = _values[3]
            self.H_JoinTime = {Week = _week, Start = _start, End = _end}
        end
    end
    return self.H_JoinTime
end

function LoversTopData:CanJoinH(week, startTime)
    local _ret = false
    local _joinTime = self:GetJoinTimeH()
    if _joinTime ~= nil then
        if week == _joinTime.Week then
            local _curSec = GameCenter.HeartSystem.ServerZoneTime - startTime
            if _curSec >= _joinTime.Start * 60 and _curSec <= _joinTime.End * 60 then
                _ret = true
            end
        end
    end
    return _ret
end

function LoversTopData:IsOverH(week, startTime)
    local _ret = false
    local _joinTime = self:GetJoinTimeH()
    if _joinTime ~= nil then
        if week == _joinTime.Week then
            local _curSec = GameCenter.HeartSystem.ServerZoneTime - startTime
            if _curSec > _joinTime.End * 60 then
                _ret = true
            end
        end
    end
    return _ret
end

function LoversTopData:CheckMsgTpisL(week, startSec)
    local _ret = false
    local _canJoin = self:CanJoinL(week, startSec)
    if _canJoin and not self.L_MsgBoxActive and GameCenter.MapLogicSystem.MapCfg ~= nil and GameCenter.MapLogicSystem.MapCfg.ReceiveType == 2 then
        -- Can participate in group competitions
        self.L_MsgBoxActive = true
        GameCenter.MsgPromptSystem:ShowSelectMsgBox(
            "The ranking list of the Immortal Couple Duel Championship has been opened. Do you want to enter automatically?", 
            --"仙侣对决冠军赛地榜开启了,是否自动进入",
            -- "ŇĨņ¢įśıÁŕþņňŨĸĨ½ĸřıĻŊĺĨħņœŊŇįŐŊōįŞ, ŊřįňĻőŊŉņŞŘļ½ŞĸŇśřþŎŇ¤Ŋĺ?",
            DataConfig.DataMessageString.Get("C_MSGBOX_CANCEL"),
            DataConfig.DataMessageString.Get("C_MSGBOX_OK"),
            function (code)
                if code == MsgBoxResultCode.Button2 then
                    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.LoversTopFight)
                end
                self.L_MsgBoxActive = false
            end,
            function (select)
                if select then
                    self.L_IsMsgTishi = false
                else
                    self.L_IsMsgTishi = true
                end
            end,
            DataConfig.DataMessageString.Get("MASTER_BENCILOGINNOTNOTICE"),
            false, false, 15, 4, 1, nil, nil, 0, true
        )
        _ret = true
    end
    return _ret
end

function LoversTopData:CheckMsgTpisH(week, startSec)
    local _ret = false
    local _canJoin = self:CanJoinH(week, startSec)
    if _canJoin and not self.H_MsgBoxActive and GameCenter.MapLogicSystem.MapCfg and GameCenter.MapLogicSystem.MapCfg.ReceiveType == 2 then
        -- Can participate in group competitions
        self.H_MsgBoxActive = true
        GameCenter.MsgPromptSystem:ShowSelectMsgBox(
            "The Immortal Couple Duel Championship is now open. Do you want to enter automatically?",
            -- "仙侣对决冠军赛天榜开启了,是否自动进入",
            -- "ការប្រកួតជើងឯកគូទេពបានបើកហើយ, តើចូលដោយស្វ័យប្រវត្តិឬទេ?",
            DataConfig.DataMessageString.Get("C_MSGBOX_CANCEL"),
            DataConfig.DataMessageString.Get("C_MSGBOX_OK"),
            function (code)
                if code == MsgBoxResultCode.Button2 then
                    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.LoversTopFight)
                end
                self.H_MsgBoxActive = false
            end,
            function (select)
                if select then
                    self.H_IsMsgTishi = false
                else
                    self.H_IsMsgTishi = true
                end
            end,
            DataConfig.DataMessageString.Get("MASTER_BENCILOGINNOTNOTICE"),
            false, false, 15, 4, 1, nil, nil, 0, true
        )
        _ret = true
    end
    return _ret
end

-- Get the Time Dictionary of the Championship Sky List
function LoversTopData:GetTimeDicH()
    if self.H_TimeDic == nil then
        local _startTime = 0
        self.H_TimeDic = Dictionary:New()
        local _foreach = function(key, value)
            if value ~= nil and value.Type == 4 then
                local _list1 = Utils.SplitNumber(value.StartTime, "_")
                local _list2 = Utils.SplitNumber(value.OverTime, "_")
                local _time = nil
                if _startTime == 0 then
                    _time = {PreStart = _list1[2], Start = _list1[2], End = _list2[2]}
                    _startTime = _list2[2]
                else
                    _time = {PreStart = _startTime, Start = _list1[2], End = _list2[2]}
                    _startTime = _list2[2]
                end
                self.H_TimeDic:Add(value.Game, _time)
            end
        end
        DataConfig.DataMarryBattleTime:Foreach(_foreach)
    end
    return self.H_TimeDic
end

-- Get the time dictionary of the championship game chart
function LoversTopData:GetTimeDicL()
    if self.L_TimeDic == nil then
        local _startTime = 0
        self.L_TimeDic = Dictionary:New()
        local _foreach = function(key, value)
            if value ~= nil and value.Type == 3 then
                local _list1 = Utils.SplitNumber(value.StartTime, "_")
                local _list2 = Utils.SplitNumber(value.OverTime, "_")
                local _time = nil
                if _startTime == 0 then
                    _time = {PreStart = _list1[2], Start = _list1[2], End = _list2[2]}
                    _startTime = _list2[2]
                else
                    _time = {PreStart = _startTime, Start = _list1[2], End = _list2[2]}
                    _startTime = _list2[2]
                end
                self.L_TimeDic:Add(value.Game, _time)
            end
        end
        DataConfig.DataMarryBattleTime:Foreach(_foreach)
    end
    return self.L_TimeDic
end

function LoversTopData:IsFight(round, type)
    local _ret = false
    local _timeDic = nil
    if Type == 1 then
        -- Sky List
        _timeDic = self:GetTimeDicH()
    else
        -- Place list
        _timeDic = self:GetTimeDicL()
    end
    if _timeDic ~= nil then
        local _time = _timeDic[round]
        if _time ~= nil then
            local _curSec = GameCenter.HeartSystem.ServerZoneTime - GameCenter.LoversFightSystem.StartSec
            if _curSec >= _time.Start * 60 and _curSec <= _time.End then
                _ret = true
            end
        end
    end
    return _ret
end

return LoversTopData