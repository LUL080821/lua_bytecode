------------------------------------------------
-- author:
-- Date: 2021-09-27
-- File: TodayFuncSystem.lua
-- Module: TodayFuncSystem
-- Description: Today's functional system
------------------------------------------------
local RedPointCustomCondition = CS.Thousandto.Code.Logic.RedPointCustomCondition
local TimeUtils = CS.Thousandto.Core.Base.TimeUtils

local TodayFuncSystem = {
    -- Service opening time, used to calculate service opening days
    ServerOpenTime = nil,
    -- Show the main mission
    ShowFuncList = List:New(),
    -- List of tasks displayed
    ShowTaskList = List:New(),
    -- Task data
    TaskData = nil,
    -- Recharge data
    RechargeData = nil,
    -- Current service days
    CurOpenServerDay = 0,
}

function TodayFuncSystem:Initialize()
    self.ShowFuncList:Clear()
    -- Perform at 10 seconds every day
    self.TimerID = GameCenter.TimerEventSystem:AddTimeStampDayEvent(10, 86400,
    true, nil, function(id, remainTime, param)
        self:ReInitTodyTask()
    end)
end

function TodayFuncSystem:UnInitialize()
end

function TodayFuncSystem:SetOpenServerTime(time)
    -- Check the opening status
    self.ServerOpenTime = math.floor(math.floor(time / 1000) + GameCenter.HeartSystem.ServerZoneOffset)
    self:ReInitTodyTask()
end

-- Reinitialize today's event
function TodayFuncSystem:ReInitTodyTask()
    self.ShowFuncList:Clear()
    local _serverTime = math.floor(GameCenter.HeartSystem.ServerZoneTime)
    -- Refresh today's mission
    local _openDay = TimeUtils.GetDayOffsetNotZone(self.ServerOpenTime, math.floor(_serverTime)) + 1
    self.CurOpenServerDay = _openDay
    -- Calculate the current week 1 - 7
    local week = TimeUtils.GetStampTimeWeeklyNotZone(_serverTime)
    if week == 0 then
        week = 7
    end
    local _openCountTable = {}
    DataConfig.DataTodayFunction:Foreach(function(k, cfg)
        local _dayParam = Utils.SplitNumber(cfg.OpenDay, '_')
        if _openDay >= _dayParam[1] and _openDay <= _dayParam[2] then
            if string.len(cfg.WeekDay) > 0 then
                local _weekParam = Utils.SplitNumber(cfg.WeekDay, '_')
                if _weekParam:Contains(week) then
                    local _rOpenDay = _openDay - _dayParam[1]
                    local _startWeek = TimeUtils.GetStampTimeWeeklyNotZone(_serverTime - _rOpenDay * 86400)
                    if _startWeek == 0 then
                        _startWeek = 7
                    end
                    -- Calculate how many times the activity has been started
                    local _rOpenCount = 0
                    for i = 0, _rOpenDay do
                        if _weekParam:Contains(_startWeek) then
                            _rOpenCount = _rOpenCount + 1
                        end
                        _startWeek = _startWeek + 1
                        if _startWeek > 7 then
                            _startWeek = 1
                        end
                    end
                    -- Start the event today
                    self.ShowFuncList:Add(cfg)
                    _openCountTable[k] = _rOpenCount
                end
            else
                self.ShowFuncList:Add(cfg)
                _openCountTable[k] = _openDay - _dayParam[1] + 1
            end
        end
    end)
    self.ShowTaskList:Clear()
    DataConfig.DataTodayFunctionTask:Foreach(function(k, cfg)
        local _ownerParams = Utils.SplitNumber(cfg.TodayFunctionID, '_')
        local _isShow = false
        for i = 1, #_ownerParams do
            local _openCount = _openCountTable[_ownerParams[i]]
            if _openCount ~= nil and (cfg.ShowCount == nil or cfg.ShowCount == 0 or cfg.ShowCount >= _openCount) then
                _isShow = true
                break
            end
        end
        if _isShow then
            self.ShowTaskList:Add(cfg)
        end
    end)
    if self.ShowTaskList == nil or #self.ShowTaskList <= 0 then
        GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.ToDayFunc, false)
    else
        GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.ToDayFunc, true)
        self:CheckAllRedPoint()
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_TODAYFUNC_INFO)
end

-- Check all tasks red dots
function TodayFuncSystem:CheckAllRedPoint()
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.ToDayFunc)
    -- Add the first red dot
    GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.ToDayFunc, 0, RedPointCustomCondition(true))
    if self.TaskData == nil then
        return
    end
    for i = 1, #self.ShowTaskList do
        self:CheckSingleRedPoint(self.ShowTaskList[i].Id, false)
    end
end

-- Check individual tasks red dots
function TodayFuncSystem:CheckSingleRedPoint(taskId, needClear)
    if needClear then
        GameCenter.RedPointSystem:RemoveFuncCondition(FunctionStartIdCode.ToDayFunc, taskId)
    end
    if self.TaskData == nil then
        return
    end
    local _taskData = self.TaskData[taskId]
    if _taskData == nil then
        return
    end
    if _taskData.IsGet then
        return
    end
    if _taskData.Num < _taskData.MaxNum then
        return
    end
    GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.ToDayFunc, taskId, RedPointCustomCondition(true))
end

-- All task list data
function TodayFuncSystem:ResAllFunctionTask(msg)
    self.TaskData = {}
    if msg.tasks ~= nil then
        for i = 1, #msg.tasks do
            local _msgTask = msg.tasks[i]
            self.TaskData[_msgTask.id] = {
                Id = _msgTask.id,
                Num = _msgTask.num,-- Current quantity
                MaxNum = _msgTask.maxNum,-- Maximum number
                IsGet = _msgTask.get,-- Whether to receive it
            }
        end
    end
    self.RechargeData = nil
    if msg.rechargeTask ~= nil then
        self.RechargeData = {
            RechargeId = msg.rechargeTask.rechargeid,-- Recharge ID
            ZheKou = msg.rechargeTask.num,-- Discount
            ItemList = msg.rechargeTask.rewards,-- Item List
            IsGet = msg.rechargeTask.get,-- Whether to receive it
        }
    end
    self:CheckAllRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_TODAYFUNC_INFO)
end

-- Task refresh
function TodayFuncSystem:ResFunctionTaskUpdate(msg)
    if self.TaskData == nil then
        self.TaskData = {}
    end
    if msg.tasks ~= nil then
        local _taskData = self.TaskData[msg.tasks.id]
        if _taskData == nil then
            _taskData = {}
            self.TaskData[msg.tasks.id] = _taskData
        end
        _taskData.Id = msg.tasks.id
        _taskData.Num = msg.tasks.num -- Current quantity
        _taskData.MaxNum = msg.tasks.maxNum-- Maximum number
        _taskData.IsGet = msg.tasks.get -- Whether to receive it
        self:CheckSingleRedPoint(_taskData.Id, true)
    end
    if msg.rechargeTask ~= nil then
        self.RechargeData = {
            RechargeId = msg.rechargeTask.rechargeid,-- Recharge ID
            ZheKou = msg.rechargeTask.num,-- Discount
            ItemList = msg.rechargeTask.rewards,-- Item List
            IsGet = msg.rechargeTask.get,-- Whether to receive it
        }
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_TODAYFUNC_INFO)
end

return TodayFuncSystem