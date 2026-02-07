------------------------------------------------
-- author:
-- Date: 2020-11-07
-- File: TianJinLingSystem.lua
-- Module: TianJinLingSystem
-- Description: The ban system
------------------------------------------------
-- Quote
local L_TaskData = require "Logic.TianJinLing.TianJinLingTaskData"
local L_LvRewardData = require "Logic.TianJinLing.TianJinLingLvData"
local TianJinLingSystem = {
    -- Day ban level
    CurLv = 0,
    -- Current rounds
    CurGroup = 1,
    -- time left
    LeftTime = 0,
    -- End time
    EndTime = 0,
    -- Configuration ID corresponding to the current level
    CurCfgId = 0,
    -- A round of activity life cycle
    LiveTime = 0,
    -- Whether to buy it
    IsBuy = false,
    -- Recharge ID
    RechargeId = 0,
    -- Purchase price
    Price = 0,
    -- Task Dictionary
    DicGroupTask = nil,
    -- Positioning data
    LocationList = nil,
    -- Level Reward Dictionary
    DicLvReward = nil,
    -- Have you clicked to buy
    IsClickBuy = false
}

function TianJinLingSystem:Initialize()
    GameCenter.RegFixEventHandle(LogicEventDefine.EVENT_COIN_CHANGE_UPDATE, self.CoinChange, self)
end

function TianJinLingSystem:UnInitialize()
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EVENT_COIN_CHANGE_UPDATE, self.CoinChange, self)
end

function TianJinLingSystem:CoinChange(obj, sender)
    if obj == ItemTypeCode.TianJinLingPoint then
        local point = GameCenter.ItemContianerSystem:GetEconomyWithType(ItemTypeCode.TianJinLingPoint)
        self:SetCurLv(point)
    end
end

-- Get the activity life cycle
function TianJinLingSystem:GetLiveTime()
    if self.LiveTime == 0 then
    end
    return self.LiveTime
end

-- Get the current event which round is
function TianJinLingSystem:GetGroup()
    -- Use the current server time zone time minus the activity start time
    local _disTime = GameCenter.HeartSystem.ServerTime - Time.GetOpenServerTime()
    local _liveTime = self:GetLiveTime()
    local _group = math.floor(_disTime / _liveTime) + 1
    return _group
end

-- Get the remaining time of the current round
function TianJinLingSystem:GetLeftTime()
    return self.EndTime - GameCenter.HeartSystem.ServerTime
end

-- ===================================================== Task-related --====================================================================

-- Get the task dictionary
function TianJinLingSystem:GetTaskDic()
    if self.DicGroupTask == nil then
        self.DicGroupTask = Dictionary:New()
        DataConfig.DataFallingSkyTask:Foreach(function(k, v)
            local _task = L_TaskData:New(v)
            local _dicTask = self.DicGroupTask[v.Group]
            if _dicTask == nil then
                _dicTask = Dictionary:New()
                local _list = List:New()
                _list:Add(_task)
                _dicTask[v.Type] = _list
                self.DicGroupTask[v.Group] = _dicTask
            else
                local _list = _dicTask[v.Type]
                if _list == nil then
                    _list = List:New()
                    _list:Add(_task)
                    _dicTask[v.Type] = _list
                else
                    _list:Add(_task)
                end
            end
        end)
    end
    return self.DicGroupTask
end

-- Get task type
function TianJinLingSystem:GetTaskTypeList()
    local _ret = nil
    local _dic = self:GetTaskDic()
    if _dic ~= nil then
        local _groups = _dic:GetKeys()
        local _gropu = _groups[1]
        if _gropu ~= nil then
            local _dicTask = _dic[_gropu]
            local _types = _dicTask:GetKeys()
            _ret = _types
        end
    end
    return _ret
end

function TianJinLingSystem:GetCurGroupTaskListByType(type)
    local _list = nil
    local _dic = self:GetCurGroupTaskDataList()
    if _dic ~= nil and _dic:ContainsKey(type) then
        _list = _dic[type]
        if _list ~= nil then
            _list:Sort(function(a, b)
                return a:GetState() * 100 + a:GetId() < b:GetState() * 100 + b:GetId()
            end)
        end
    end
    return _list
end

function TianJinLingSystem:GetCurGroupTaskDataList()
    local _dic = self:GetTaskDataDic(self.CurGroup)
    return _dic
end

-- Get the task list according to the group
function TianJinLingSystem:GetTaskDataDic(group)
    local _ret = nil
    local _dic = self:GetTaskDic()
    if _dic ~= nil then
        local _dic2 = _dic[group]
        if _dic2 ~= nil then
            _ret = _dic2
        end
    end
    return _ret
end

-- Get task data based on task ID and Group
function TianJinLingSystem:GetTaskDataById(group, id)
    local _ret = nil
    local _dic = self:GetTaskDataDic(group)
    if _dic ~= nil then
        local _keys = _dic:GetKeys()
        for i = 1, #_keys do
            local _list = _dic[_keys[i]]
            for m = 1, #_list do
                local _data = _list[m]
                if _data:GetId() == id then
                    _ret = _data
                end
            end
        end
    end
    return _ret
end

-- ===================================================== Task-related --====================================================================

-- ==================================================================================================================

-- Get level reward data
function TianJinLingSystem:GetLvDataDic()
    if self.DicLvReward == nil then
        self.DicLvReward = Dictionary:New()
        DataConfig.DataFallingSkyLevel:Foreach(function(k, v)
            local _data = L_LvRewardData:New(v)
            local _group = v.Goup
            local _list = self.DicLvReward[_group]
            if _list == nil then
                _list = List:New()
                _list:Add(_data)
                self.DicLvReward[_group] = _list
            else
                _list:Add(_data)
            end
        end)
    end
    return self.DicLvReward
end

function TianJinLingSystem:GetLocationList()
    if self.LocationList == nil then
        self.LocationList = List:New()
        local _index = 0
        local _dic = self:GetLvDataDic()
        local _list = _dic[self.CurGroup]
        if _list ~= nil then
            local _cacheLocation = nil
            for i = 1, #_list do
                local _data = _list[i]
                local _group = _data.Cfg.SubGroup
                local _location = nil
                if _index ~=  _group then
                    _location = {Data = nil, Index = i - 1}
                    _index = _group
                    _cacheLocation = _location
                    self.LocationList:Add(_location)
                else
                    _cacheLocation.Data = _data
                end
            end
        end
    end
    return self.LocationList
end

-- Get the current level reward list
function TianJinLingSystem:GetGroupLvDataList(group)
    local _ret = nil
    local _curGroup = group
    local _dic = self:GetLvDataDic()
    if _dic ~= nil then
        local _list = _dic[_curGroup]
        if _list ~= nil then
            _ret = _list
        end
    end
    return _ret
end

function TianJinLingSystem:GetCurGroupLvDataList()
    local _ret = nil
    local _dic = self:GetLvDataDic()
    if _dic ~= nil then
        local _list = _dic[self.CurGroup]
        if _list ~= nil then
            _ret = _list
        end
    end
    local _prePoint = 0
    if _ret ~= nil then
        for i = 1, #_ret do
            local _data = _ret[i]
            if i == 1 then
                _data.PrePoint = 0
                _prePoint = _data:GetPoint()
            else
                _data.PrePoint = _prePoint
                _prePoint = _data:GetPoint()
            end
        end
    end
    return _ret
end

-- Get the current round activity data corresponding to the incoming level
function TianJinLingSystem:GetGroupLvDataByLv(group, lv)
    local _ret = nil
    local _list = self:GetGroupLvDataList(group)
    if _list ~= nil then
        for i = 1, #_list do
            local _data = _list[i]
            if _data:GetId() == lv then
                _ret = _data
            end
        end
    end
    return _ret
end

-- Obtain the ban level
function TianJinLingSystem:SetCurLv(point)
    self.CurLv = 0
    self.CurCfgId = 0
    local _list = self:GetGroupLvDataList(self.CurGroup)
    for i = 1, #_list do
        local _data = _list[i]
        if point >= _data:GetPoint() then
            self.CurLv = _data:GetLv()
            self.CurCfgId = _data:GetId()
        else
            break
        end
    end
end

-- Obtain the ban points required at the next level
function TianJinLingSystem:GetNextPoint()
    local _ret = 0
    local _list = self:GetGroupLvDataList(self.CurGroup)
    local _isFind = false
    for i = 1, #_list do
        local _data = _list[i]
        if _isFind then
            _ret = _data:GetPoint()
            break
        end
        if self.CurCfgId == 0 then
            _ret = _data:GetPoint()
            break
        elseif self.CurCfgId == _data:GetId() then
            if i == #_list then
                _ret = _data:GetPoint()
                break
            else
                _isFind = true
            end
        end
        
    end
    return _ret
end

function TianJinLingSystem:CheckRedPoint()
    -- Check the task
    local _taskDic = self:GetTaskDataDic(self.CurGroup)
    if _taskDic ~= nil then
        local _keys = _taskDic:GetKeys()
        for i = 1, #_keys do
            local _key = _keys[i]
            local _funcId = 0
            if _key == TJLMenu.DailyTask then
                _funcId = FunctionStartIdCode.TJLDailyTask
            elseif _key == TJLMenu.StepTask then
                _funcId = FunctionStartIdCode.TJLStepTask
            elseif _key == TJLMenu.ChuMoTask then
                _funcId = FunctionStartIdCode.TJLChuMoTask
            end
            local _taskList = _taskDic[_key]
            local _isShow = false
            for m = 1, #_taskList do
                local _task = _taskList[m]
                if not _isShow and _task.Count >= _task:GetTCount() and _task:GetState() == 0 then
                    _isShow = true
                    break
                end
            end
            GameCenter.MainFunctionSystem:SetAlertFlag(_funcId, _isShow)
        end
    end
    -- Check level rewards
    local _lvRedPoint = false
    local _point = GameCenter.ItemContianerSystem:GetEconomyWithType(ItemTypeCode.TianJinLingPoint)
    local _lvList = self:GetCurGroupLvDataList()
    if _lvList ~= nil then
        for i = 1, #_lvList do
            local _data = _lvList[i]
            if not _lvRedPoint and _point >= _data:GetPoint() then
                if self.IsBuy then
                    -- If you bought it
                    if not _data.IsAwardFree or not _data.IsAwardPay then
                        _lvRedPoint = true
                        break
                    end
                else
                    -- If you haven't bought it
                    if not _data.IsAwardFree then
                        _lvRedPoint = true
                        break
                    end
                end
            end
        end
    end
    if not _lvRedPoint then
        if not self.IsClickBuy and not self.IsBuy then
            -- If you haven't clicked the Buy button
            _lvRedPoint = true
        end
    end
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.TJL, _lvRedPoint)
end

-- ==================================================================================================================

-- ===============================================Msg--===============================================

-- Request a task to receive a prize
function TianJinLingSystem:ReqGetFallSkyTaskReward(id)
    GameCenter.Network.Send("MSG_FallingSky.ReqGetFallSkyTaskReward", {
        taskID = id
    })
end

-- Receive the award at the level
function TianJinLingSystem:ReqGetFallSkyLevelReward(id, free)
    GameCenter.Network.Send("MSG_FallingSky.ReqGetFallSkyLevelReward", {
        levelId = id,
        isFree = free
    })
end

-- Request one click to receive the level reward
function TianJinLingSystem:ReqOnekeyGetFallSkyLevelReward()
    GameCenter.Network.Send("MSG_FallingSky.ReqOnekeyGetFallSkyLevelReward")
end

-- Request one-click reward for task
function TianJinLingSystem:ReqOnekeyGetFallSkyTaskReward()
    GameCenter.Network.Send("MSG_FallingSky.ReqOnekeyGetFallSkyTaskReward")
end

-- Push messages online
function TianJinLingSystem:ResOnlineFallSkyInfo(msg)
    -- Initialize the activation amount
    self.RechargeId = tonumber(DataConfig.DataGlobal[GlobalName.FallingSky_RechargeId].Params)
    if msg == nil then
        return
    end
    -- Set whether to buy
    self.IsBuy = msg.hasPay
    self.CurGroup = msg.round
    -- self.LeftTime = msg.lastTime
    self.EndTime = msg.lastTime / 1000
    -- Set level reward data
    if msg.levelDataList ~= nil then
        for i = 1, #msg.levelDataList do
            local _msgData = msg.levelDataList[i]
            local _data = self:GetGroupLvDataByLv(msg.round, _msgData.levelId)
            if _data ~= nil then
                _data.IsAwardFree = _msgData.isGetfeelReward
                _data.IsAwardPay = _msgData.isGetpayReward
            end
        end
    end
    -- Reset daily task data The server will not send daily tasks
    local _taskList = self:GetCurGroupTaskListByType(TJLMenu.DailyTask)
    if _taskList ~= nil then
        for i = 1, #_taskList do
            local _task = _taskList[i]
            _task.Count = 0
            _task.IsAward = false
        end
    end
    -- Set task data
    if msg.taskDataList ~= nil then
        for i = 1, #msg.taskDataList do
            local _msgData = msg.taskDataList[i]
            local _data = self:GetTaskDataById(msg.round, _msgData.taskID)
            if _data ~= nil then
                _data.Count = _msgData.progress
                _data.IsAward = _msgData.state
            end
        end
    end
    self:CheckRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_TIANJINLING_LVDATA_REFRESH)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_TIANJINLING_TASKDATA_REFRESH)
end

-- Task progress refresh
function TianJinLingSystem:ResRefreshFallSkyTask(msg)
    if msg == nil then
        return
    end
    if msg.taskData ~= nil then
        for i = 1, #msg.taskData do
            local _msgData = msg.taskData[i]
            local _data = self:GetTaskDataById(self.CurGroup, _msgData.taskID)
            if _data ~= nil then
                _data.Count = _msgData.progress
                _data.IsAward = _msgData.state
            end
        end
    end
    local _taskDic = self:GetTaskDataDic(self.CurGroup)
    local _keys = _taskDic:GetKeys()
    for i = 1, #_keys do
        local _taskList = _taskDic[_keys[i]]
        _taskList:Sort(function(a, b)
            return a:GetState() * 100 + a:GetId() < b:GetState() * 100 + b:GetId()
        end)
    end
    self:CheckRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_TIANJINLING_TASKDATA_REFRESH)
end

-- Single level reward status refresh
function TianJinLingSystem:ResRefreshFallSkyLevel(msg)
    if msg == nil then
        return
    end
    if msg ~= nil then
        for i = 1, #msg.levelData do
            local _msgData = msg.levelData[i]
            local _data = self:GetGroupLvDataByLv(self.CurGroup, _msgData.levelId)
            if _data ~= nil then
                _data.IsAwardFree = _msgData.isGetfeelReward
                _data.IsAwardPay = _msgData.isGetpayReward
            end
        end
    end
    self:CheckRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_TIANJINLING_LVDATA_REFRESH)
end

-- Refresh paid status
function TianJinLingSystem:ResRefreshRechargeState(msg)
    if msg == nil then
        return
    end
    self.IsBuy = msg.hasPay
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_TIANJINLING_BUY_RESULT)
end

return TianJinLingSystem
