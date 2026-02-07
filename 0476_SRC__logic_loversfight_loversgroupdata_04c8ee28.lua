------------------------------------------------
-- Author:
-- Date: 2021-08-03
-- File: LoversGroupData.lua
-- Module: LoversGroupData
-- Description: Xianlian group match data
------------------------------------------------
local L_TeamInfo = require "Logic.LoversFight.LoversTeamInfo"
local L_RankInfo = require "Logic.LoversFight.LoversRankInfo"
local L_TimeUtils = CS.Thousandto.Core.Base.TimeUtils
local LoversGroupData = {
    -- My group Id
    MyGroup = 0,
    -- Whether to enter the group competition
    IsJoin = false,
    -- Start time
    StartTime = 0,
    -- End time
    EndTime = 0,
    Week = -1,
    -- Grouping
    GroupDic = Dictionary:New(),
    -- Current group ranking
    CurRankList = List:New(),
    -- Ranking Rewards
    RewardList = nil,
    -- Time to attend
    JoinTime = nil,
    -- Is it prompted
    IsMsgTishi = true,
    -- Have you received a promotion notice
    IsReceiveJinJi = false,
    MsgBoxActive = false,
    IsTickTiShi = true,
}

function LoversGroupData:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

function LoversGroupData:ParseMsg(msg)
    if msg.mygroup == nil then
        self.MyGroup = 0
    else
        self.MyGroup = msg.mygroup
    end
    self.IsJoin = msg.join
    self.GroupDic:Clear()
    if msg.group ~= nil then
        for i = 1, #msg.group do
            local _groupMsg = msg.group[i]
            if _groupMsg ~= nil then
                local _groupId = _groupMsg.id
                local _teamList = List:New()
                for m = 1, #_groupMsg.team do
                    local _teamMsg = _groupMsg.team[m]
                    local _team = L_TeamInfo:New()
                    _team:ParseTeam(_teamMsg)
                    _teamList:Add(_team)
                end
                self.GroupDic:Add(_groupId, _teamList)
            end
        end
    end
end

function LoversGroupData:ParseCurRankMsg(msg)
    self.CurRankList:Clear()
    local _teamList = self.GroupDic[msg.groupId]
    if _teamList ~= nil then
        for i = 1, #_teamList do
            local _team = _teamList[i]
            for m = 1, #msg.team do
                local _teamMsg = msg.team[m]
                if _team.Id == _teamMsg.teamId then
                    _team:ParseRank(_teamMsg)
                    local _rank = L_RankInfo:New()
                    _rank.TeamInfo = _team
                    self.CurRankList:Add(_rank)
                    break
                end
            end
        end
    end
end

function LoversGroupData:GetStartTime()
    if self.StartTime == 0 then
        local _time = 999999999
        local function _Func(key, value)
            if value.Type == 2 then
                local _list = Utils.SplitNumber(value.StartTime, '_')
                if self.Week == -1 then
                    self.Week = _list[1]
                end
                if _list[2] < _time then
                    _time = _list[2]
                end
            end
            self.StartTime = _time
        end
        DataConfig.DataMarryBattleTime:Foreach(_Func)
    end
    return self.StartTime
end

function LoversGroupData:GetEndTime()
    if self.EndTime == 0 then
        local _time = 0
        local function _Func(key, value)
            if value.Type == 2 then
                local _list = Utils.SplitNumber(value.OverTime, '_')
                if _list[2] > _time then
                    _time = _list[2]
                end
            end
            self.EndTime = _time
        end
        DataConfig.DataMarryBattleTime:Foreach(_Func)
    end
    return self.EndTime
end

function LoversGroupData:GetNextTime()
    local _ret = {Time = 0, Round = 0}
    local _curSec = GameCenter.HeartSystem.ServerZoneTime - GameCenter.LoversFightSystem.StartSec
    local function _Func(key, value)
        if value.Type == 2 then
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

-- Obtain group stage ranking rewards
function LoversGroupData:GetRankReward()
    if self.RewardList == nil then
        self.RewardList = List:New()
        local function _Func(key, value)
            if value.Type == 5 then
                local _list = Utils.SplitNumber(value.Parm, '_')
                local _minLv = _list[1]
                local _maxLv = _list[2]
                _list = Utils.SplitStr(value.RewardItem, ';')
                local _itemList = List:New()
                for i = 1, #_list do
                    local _itemStr = Utils.SplitNumber(_list[i], '_')
                    local _id = _itemStr[1]
                    local _num = _itemStr[2]
                    _itemList:Add({Id = _id, Num = _num, IsBind = false})
                end
                self.RewardList:Add({MinLv = _minLv, MaxLv = _maxLv, ItemList = _itemList})
            end
        end
        DataConfig.DataMarryBattleReward:Foreach(_Func)
    end
    return self.RewardList
end

-- Get the time to participate
function LoversGroupData:GetJoinTime()
    if self.JoinTime == nil then
        local _cfg = DataConfig.DataGlobal[GlobalName.Marry_battle_time]
        if _cfg ~= nil then
            local _list = Utils.SplitStr(_cfg.Params, ';')
            local _values = Utils.SplitNumber(_list[2], '_')     
            local _week = _values[1]
            local _start = _values[2]
            local _end = _values[3]
            self.JoinTime = {Week = _week, Start = _start, End = _end}
        end
    end
    return self.JoinTime
end

function LoversGroupData:CanJoin(week, startSec)
    local _ret = false
    local _joinTime = self:GetJoinTime()
    if _joinTime ~= nil then
        if week == _joinTime.Week then
            local _curSec = GameCenter.HeartSystem.ServerZoneTime - startSec
            if _curSec >= _joinTime.Start * 60 and _curSec <= _joinTime.End * 60 then
                local function _Func(key, value)
                    if value.Type == 2 then
                        local _list = Utils.SplitNumber(value.StartTime, '_')
                        local _time = _list[2]
                        if _time > _curSec / 60 then
                            _ret = true
                            return true
                        end
                    end
                end
                DataConfig.DataMarryBattleTime:ForeachCanBreak(_Func)
            end
        end
    end
    return _ret
end

function LoversGroupData:CheckMsgTpis(week, startSec)
    local _ret = false
    local _canJoin = self:CanJoin(week, startSec)
    if _canJoin and not self.MsgBoxActive and GameCenter.MapLogicSystem.MapCfg ~= nil and GameCenter.MapLogicSystem.MapCfg.ReceiveType == 2 then
        -- Can participate in group competitions
        self.MsgBoxActive = true
        GameCenter.MsgPromptSystem:ShowSelectMsgBox(
            "ŐņŗĸŇŐĿřśıÁŊĩįŌÉŐıĻŊĺĨħņœŊŇįŐŊōįŞ, ŊřįňĻőŊŉņŞŘļ½ŞĸŇśřþŎŇ¤Ŋĺ?",
            DataConfig.DataMessageString.Get("C_MSGBOX_CANCEL"),
            DataConfig.DataMessageString.Get("C_MSGBOX_OK"),
            function (code)
                if code == MsgBoxResultCode.Button2 then
                    GameCenter.LoversFightSystem:ReqGroupPrepareMapEnter()
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

return LoversGroupData