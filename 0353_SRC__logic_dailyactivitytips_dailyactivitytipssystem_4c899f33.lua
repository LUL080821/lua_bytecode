------------------------------------------------
-- Author:
-- Date: 2020-10-16
-- File: DailyActivityTipsSystem.lua
-- Module: DailyActivityTipsSystem
-- Description: Daily activity reminder system
------------------------------------------------
local TimeUtils = CS.Thousandto.Core.Base.TimeUtils

local DailyActivityTipsSystem = {
    ShowList = nil,
    TimerID = nil,
    -- The iconid currently displayed
    CurShowIconID = nil,
    -- Currently automatic entry prompt type
    CurAutoEnterType = 0,
    -- Currently automatically enters the reminder activity
    CurAutoEnterCfg = nil,
    -- No more reminder activities
    NotTipsIds = nil,
    -- Automatically enter daily id
    AutoEnterID = nil,
    -- Goddess escort double time
    HuSongSBtime = nil,
}

function DailyActivityTipsSystem:Initialize()
    self.ShowList = List:New()
    self.NotTipsIds = {}
    if self.TimerID ~= nil then
        GameCenter.TimerEventSystem:RemoveTimerEvent(self.TimerID)
    end
    -- Add a timer to execute at 1 second every morning
    self.TimerID = GameCenter.TimerEventSystem:AddTimeStampDayEvent(1, 86400,
    true, nil, function(id, remainTime, param)
        self:CheckShowList()
    end)
    self.HuSongSBtime = Utils.SplitStrBySeps(DataConfig.DataGlobal[GlobalName.ConvoyDoubleExpTime].Params, {';', '_'})
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_FUNCTION_UPDATE, self.OnFuncUpdated, self)
end

function DailyActivityTipsSystem:UnInitialize()
    self.ShowList = nil
    -- Delete the timer
    GameCenter.TimerEventSystem:RemoveTimerEvent(self.TimerID)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_FUNCTION_UPDATE, self.OnFuncUpdated, self)
end

-- Set the server opening time
function DailyActivityTipsSystem:SetOpenServerTime(time)
    self:CheckShowList()
end

-- Function refresh
function DailyActivityTipsSystem:OnFuncUpdated(func, sender)
    if func.ID == FunctionStartIdCode.BaJiZhen then
        self:CheckShowList()
    end
end

function DailyActivityTipsSystem:CheckShowList()
    self.ShowList:Clear()
    local _serverTime = math.floor(GameCenter.HeartSystem.ServerZoneTime)
    local _serverOpenTime = math.floor(Time.GetOpenServerTime() + GameCenter.HeartSystem.ServerZoneOffset)
    local _openServerDay = TimeUtils.GetDayOffsetNotZone(_serverOpenTime, _serverTime) + 1
    -- Calculate the current week 1 - 7
    local week = TimeUtils.GetStampTimeWeeklyNotZone(_serverTime)
    if week == 0 then
        week = 7
    end
    -- Traverse the daily configuration table
    DataConfig.DataDaily:Foreach(function(k, v)
        if v.AddOnMenu == 1 then
            local _weekParams = Utils.SplitStr(v.OpenTime, "_")
            local _timeParams = Utils.SplitStrBySeps(v.Time, {';', '_'})
            local _isShow = false
            if k == 110 then
                -- Special treatment of the Immortal Alliance War
                if _openServerDay >= 3 then
                    for i = 1, #_weekParams do
                        local _day = tonumber(_weekParams[i])
                        if _day == 0 or _day == week then
                            -- This event is going to be held today
                            _isShow = true
                            break
                        end
                    end
                end
            elseif k == 21 then
                -- Special treatment for peak competition
                if _openServerDay >= 4 then
                    for i = 1, #_weekParams do
                        local _day = tonumber(_weekParams[i])
                        if _day == 0 or _day == week then
                            -- This event is going to be held today
                            _isShow = true
                            break
                        end
                    end
                end
            elseif k == 112 then
                -- Special treatment of swordsmanship in blessed land
                if _openServerDay == 2 then
                    -- The Blessed Sword Contest will only be opened on the 5th day
                    _isShow = true
                end
            elseif k == 106 then
                -- The Eight-Pole Array Diagram function will only be displayed after it is turned on
                if GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.BaJiZhen) then
                    for i = 1, #_weekParams do
                        local _day = tonumber(_weekParams[i])
                        if _day == 0 or _day == week then
                            -- This event is going to be held today
                            _isShow = true
                            break
                        end
                    end
                end
            elseif k == 114 then
                -- The ancient demon invasion will only be opened 11 days after
                if _openServerDay >= 11 then
                    for i = 1, #_weekParams do
                        local _day = tonumber(_weekParams[i])
                        if _day == 0 or _day == week then
                            -- This event is going to be held today
                            _isShow = true
                            break
                        end
                    end
                end
            elseif k == 209 then
                -- Special treatment for escorts for fairy couples
                for i = 1, #_weekParams do
                    local _day = tonumber(_weekParams[i])
                    if _day == 0 or _day == week then
                        -- This event is going to be held today
                        _isShow = true
                        break
                    end
                end
                _timeParams = self.HuSongSBtime
            else
                for i = 1, #_weekParams do
                    local _day = tonumber(_weekParams[i])
                    if _day == 0 or _day == week then
                        -- This event is going to be held today
                        _isShow = true
                        break
                    end
                end
            end
            if _isShow then
                local _timeList = List:New()
                for j = 1, #_timeParams do
                    local _endSime = tonumber(_timeParams[j][2]) * 60
                    local _startTime = tonumber(_timeParams[j][1]) * 60
                    _timeList:Add({StartTime = _startTime, EndTime = _endSime})
                end
                self.ShowList:Add({Cfg = v, TimeList = _timeList})
            end
        end
    end)
    self:RankShowList()
end

-- Get sorted values for sorting
local function GetRankValue(data, curSec, syncTime)
    local _minTimeDiff = -1
    local _syncTime = syncTime
    data.SyncTime = _syncTime
    for i = 1, #data.TimeList do
        local _time = data.TimeList[i]
        if curSec >= _time.StartTime and curSec < _time.EndTime then
            -- The event has been started, return to the remaining time of the event
            data.SortValue = _time.EndTime - curSec
            data.RemainTime = _time.EndTime - curSec
            data.IsOpen = true
            return data.SortValue
        elseif curSec < _time.StartTime then
            local _diff = _time.StartTime - curSec
            if _minTimeDiff < 0 or _minTimeDiff > _diff then
                _minTimeDiff = _diff
            end
        end
    end
    if _minTimeDiff < 0 then
        -- The event has ended
        data.SortValue = 86400 * 10 + data.Cfg.Id
        data.RemainTime = 0
    else
        data.SortValue = 86400 + _minTimeDiff
        data.RemainTime = _minTimeDiff
    end
    data.ShowRemainTime = data.RemainTime
    data.IsOpen = false
end

-- Activity sorting
function DailyActivityTipsSystem:RankShowList()
    local _serverTime = math.floor(GameCenter.HeartSystem.ServerZoneTime)
    -- Get the current number of seconds
    local _h, _m, _s = TimeUtils.GetStampTimeHHMMSSNotZone(_serverTime)
    local _curSec = _h * 3600 + _m * 60 + _s
    local _openCount = 0
    for i = 1, #self.ShowList do
        GetRankValue(self.ShowList[i], _curSec, _serverTime)
        if self.ShowList[i].IsOpen then
            _openCount = _openCount + 1
        end
    end
    self.ShowList:Sort(function(x, y)
        return x.SortValue < y.SortValue
    end)

    self.CurAutoEnterCfg = nil
    -- Set the currently displayed activity
    local _showData = nil
    if #self.ShowList > 0 and self.ShowList[1].SortValue < 86400 * 10 then
        _showData = self.ShowList[1]
    end
    if self.CurShowIconID ~= nil then
        GameCenter.MainCustomBtnSystem:RemoveBtn(self.CurShowIconID)
    end
    if _showData ~= nil then
        local _formatStr = nil
        local _showEffect = false
        local _isRemainTimeStart = false
        if _showData.SortValue < 86400 then
            -- The event has started
            _formatStr = DataConfig.DataMessageString.Get("C_FUNCTION_TIME_GUANBI")
            _showEffect = true
            _isRemainTimeStart = false
            if _showData.Cfg.Isremind ~= 0 then
                self.CurAutoEnterCfg = _showData
            end
        else
            _formatStr = DataConfig.DataMessageString.Get("C_FUNCTION_TIME_KAIQI")
            _showEffect = false
            _isRemainTimeStart = true
        end
        local _showCfg = _showData.Cfg
        self.CurShowIconID = GameCenter.MainCustomBtnSystem:AddLimitBtn(_showData.Cfg.Icon, _showData.Cfg.Name, _showData.RemainTime, nil,
            function(data)
                if _openCount == 1 then
                    if string.len(_showCfg.OpenUI) > 0 then
                        local _funcId = 0
                        local _funcParam = nil
                        local _openUICfg = Utils.SplitStr(_showCfg.OpenUI, "_")
                        _funcId = tonumber(_openUICfg[1])
                        if #_openUICfg >= 2 then
                            _funcParam = tonumber(_openUICfg[2])
                        end
                        GameCenter.MainFunctionSystem:DoFunctionCallBack(_funcId, _funcParam)
                    end
                else
                    GameCenter.PushFixEvent(UILuaEventDefine.UIDailyActivityTipsForm_OPEN, data.ClickTrans)
                end
            end,
            _showEffect, false, _formatStr, true, nil, nil, _isRemainTimeStart
        )
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_ACTIVITY_LIST)
    else
        -- No data displayed, just close the interface
        GameCenter.PushFixEvent(UILuaEventDefine.UIDailyActivityTipsForm_CLOSE)
    end
end

function DailyActivityTipsSystem:Update()
    local _reRank = false
    local _syncTime = math.floor(GameCenter.HeartSystem.ServerZoneTime)
    for i = 1, #self.ShowList do
        local _data = self.ShowList[i]
        if _data.RemainTime > 0 then
            _data.ShowRemainTime = _data.RemainTime - (_syncTime - _data.SyncTime)
            if _data.ShowRemainTime <= 0 then
                -- Timed out, reset the latest activity
                _reRank = true
            end
        end
    end
    if _reRank then
        self:RankShowList()
        -- Automatic pop-up prompt detection
        self:AutoEnterCheck()
    end
end

function DailyActivityTipsSystem:OnEnterScene(cfg)
    self.CurAutoEnterType = cfg.ReceiveType
    self:AutoEnterCheck()
end

function DailyActivityTipsSystem:ReqJoinActivity(dailyId)
    if dailyId == 111 then
        -- The leader of the Immortal Alliance
        GameCenter.Network.Send("MSG_Guild.ReqGuildBaseEnter", {})
    elseif dailyId == 104 then
        -- Mood game
        local _cfg = DataConfig.DataDaily[dailyId]
        if _cfg ~= nil then
            local _funcId = 0
            local _funcParam = nil
            local _openUICfg = Utils.SplitStr(_cfg.OpenUI, "_")
            _funcId = tonumber(_openUICfg[1])
            if #_openUICfg >= 2 then
                _funcParam = tonumber(_openUICfg[2])
            end
            GameCenter.MainFunctionSystem:DoFunctionCallBack(_funcId, _funcParam)
        end
    elseif dailyId == 106 then
        -- Eight-pole array diagram, open the Eight-pole array diagram interface
        GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.BaJiZhen)
    elseif dailyId == 114 then
        -- Ancient Demons invade, opening the expedition interface of all realms
        GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.CrossFuDi)
    elseif dailyId == 209 then
        -- Fairy escort
        GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.HuSong)
    elseif dailyId == 21 then
        -- Peak competition
        local _msg = ReqMsg.MSG_Peak.ReqEnterWaitScene:New()
        _msg:Send()
    else
        GameCenter.DailyActivitySystem:ReqJoinActivity(dailyId)
    end
end

function DailyActivityTipsSystem:CanEnterDaily(cfg)
    if cfg.Id == 111 or cfg.Id == 110 then
        -- The leader of the Immortal Alliance must join the Immortal Alliance
        local _myGuildID = GameCenter.GameSceneSystem:GetLocalPlayer().PropMoudle.GuildId
        if _myGuildID <= 0 then
            return false
        end
    elseif cfg.Id == 209 then
        -- The Goddess Parade doesn't play any prompts when there are no remaining times
        local _acInfo = GameCenter.DailyActivitySystem:GetActivityInfo(209)
        if _acInfo ~= nil and _acInfo.RemindCount <= 0 then
            return false
        end
    end
    if string.len(cfg.OpenUI) > 0 then
        local _funcId = 0
        local _openUICfg = Utils.SplitStr(cfg.OpenUI, "_")
        _funcId = tonumber(_openUICfg[1])
        -- Already enabled
        local _funcInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(_funcId)
        if _funcInfo ~= nil then
            if _funcInfo.SelfIsVisible and _funcInfo.IsEnable then
                return true
            else
                return false
            end
        end
    end
    return true
end

function DailyActivityTipsSystem:AutoEnterCheck()
    local _autoJoinActive = GameCenter.GameSetting:GetSetting(GameSettingKeyCode.AutoJoinActive)
    -- Determine whether to set automatic rejection to enter the event
    if _autoJoinActive == 1 then
        return
    end
    
    if self.CurAutoEnterCfg ~= nil and self:CanEnterDaily(self.CurAutoEnterCfg.Cfg) and self.CurAutoEnterType ~= 0 and self.NotTipsIds[self.CurAutoEnterCfg.Cfg.Id] == nil then
        local _serverTime = math.floor(GameCenter.HeartSystem.ServerZoneTime)
        -- Get the current number of seconds
        local _h, _m, _s = TimeUtils.GetStampTimeHHMMSSNotZone(_serverTime)
        local _curSec = _h * 3600 + _m * 60 + _s
        local _openTime = nil
        for i = 1, #self.CurAutoEnterCfg.TimeList do
            local _time = self.CurAutoEnterCfg.TimeList[i]
            if _curSec >= _time.StartTime and _curSec < _time.EndTime then
                -- Calculate the time the activity has been started
                _openTime = _curSec - _time.StartTime
                break
            end
        end
        if _openTime ~= nil and _openTime < 300 then
            local _mapId = GameCenter.MapLogicSystem.MapId
            local _noremindMaps = Utils.SplitNumber(self.CurAutoEnterCfg.Cfg.NoremindMap, '_')
            local _isNoremindMap = false
            for i = 1, #_noremindMaps do
                if _noremindMaps[i] == _mapId then
                    _isNoremindMap = true
                    break
                end
            end
            if _isNoremindMap then
                return
            end
            -- A prompt pops up within 5 minutes of the event opening
            local _dailyId = self.CurAutoEnterCfg.Cfg.Id
            if self.CurAutoEnterType == 1 and _dailyId ~= 104 and _dailyId ~= 209 then
                self.AutoEnterID = nil
                -- Pop-up exit copy prompt
                local _tipsMsg = "C_DAILY_AUTO_LEAVE_ASK"
                if _dailyId == 112 then
                    _tipsMsg = "C_FDLJ_AUTO_LEAVE_ASK"
                end
                GameCenter.MsgPromptSystem:ShowSelectMsgBox(
                    UIUtils.CSFormat(DataConfig.DataMessageString.Get(_tipsMsg), self.CurAutoEnterCfg.Cfg.TipsName),
                    DataConfig.DataMessageString.Get("C_MSGBOX_CANCEL"),
                    DataConfig.DataMessageString.Get("C_MSGBOX_OK"),
                    function (code)
                        if code == MsgBoxResultCode.Button2 then
                            self.AutoEnterID = _dailyId
                            GameCenter.MapLogicSystem:SendLeaveMapMsg(false);
                        end
                    end,
                    function (select)
                        if select then
                            self.NotTipsIds[_dailyId] = true
                        else
                            self.NotTipsIds[_dailyId] = nil
                        end
                    end,
                    DataConfig.DataMessageString.Get("MASTER_BENCILOGINNOTNOTICE"),
                    false, false, 15, 4, 1, nil, nil, 0, true
                )
            elseif self.CurAutoEnterType == 2 or (self.CurAutoEnterType == 1 and (_dailyId == 104 or _dailyId == 209)) then
                if self.AutoEnterID == _dailyId then
                    self:ReqJoinActivity(self.AutoEnterID)
                    self.AutoEnterID = nil
                else
                    self.AutoEnterID = nil
                    -- Pop up and enter the prompt
                    local _tipsMsg = "C_DAILY_AUTO_ENTER_ASK"
                    if _dailyId == 112 then
                        _tipsMsg = "C_FDLJ_AUTO_ENTER_ASK"
                    end
                    GameCenter.MsgPromptSystem:ShowSelectMsgBox(
                        UIUtils.CSFormat(DataConfig.DataMessageString.Get(_tipsMsg), self.CurAutoEnterCfg.Cfg.TipsName),
                        DataConfig.DataMessageString.Get("C_MSGBOX_CANCEL"),
                        DataConfig.DataMessageString.Get("C_MSGBOX_OK"),
                        function (code)
                            if code == MsgBoxResultCode.Button2 then
                                self:ReqJoinActivity(_dailyId)
                            end
                        end,
                        function (select)
                            if select then
                                self.NotTipsIds[_dailyId] = true
                            else
                                self.NotTipsIds[_dailyId] = nil
                            end
                        end,
                        DataConfig.DataMessageString.Get("MASTER_BENCILOGINNOTNOTICE"),
                        false, false, 15, 4, 1, nil, nil, 0, true
                    )
                end
            end
        end
    end
end

return DailyActivityTipsSystem