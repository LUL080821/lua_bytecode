------------------------------------------------
-- Author:
-- Date: 2020-10-21
-- File: LuckyCardSystem.lua
-- Module: LuckyCardSystem
-- Description: Lucky Flop System
------------------------------------------------
-- Quote
local L_TimeUtils = CS.Thousandto.Core.Base.TimeUtils
local LuckyCardSystem = {
    -- Time remaining in activity (seconds)
    LeftTime = -1,
    -- How many days does the activity last
    ActiveDay = -1,
    -- Lucky value
    LuckyPoint = 0,
    -- Lucky value consumed once
    CostPoint = 0,
    -- Real data
    RealDataList = nil,
    -- Preview data
    ViewDataList = nil,
    -- Task data
    TaskList = nil
}

-- initialization
function LuckyCardSystem:Initialize()

end

function LuckyCardSystem:UnInitialize()

end

function LuckyCardSystem:GetActiveDay()
    if self.ActiveDay == -1 then
        self.ActiveDay = 7
    end
    return self.ActiveDay
end

-- Get the lucky value you have
function LuckyCardSystem:GetCurPoint()
    return self.LuckyPoint
end

-- Get the total lucky value
function LuckyCardSystem:GetTotalPoint()
    if self.CostPoint == 0 then
        local _cfg = DataConfig.DataGlobal[GlobalName.New_Sever_Luck_Limit]
        self.CostPoint = tonumber(_cfg.Params)
    end
    return self.CostPoint
end

-- Get the remaining time of the event
function LuckyCardSystem:GetLeftTime()
    local _openTime = Time.GetOpenServerTime() + GameCenter.HeartSystem.ServerZoneOffset
    local _day = self:GetActiveDay()
    -- What time is the day when the server is launched
    local _hour, _min, _sec = L_TimeUtils.GetStampTimeHHMMSSNotZone(math.floor(_openTime))
    local _curSeconds = _hour * 3600 + _min * 60 + _sec
    -- Calculate the end time
    local _time = (_day - 1) * 24 * 3600 + (24 * 3600 - _curSeconds)
    _time = _openTime + _time
    self.LeftTime = _time - GameCenter.HeartSystem.ServerZoneTime
    return self.LeftTime
end

-- Get lottery data
function LuckyCardSystem:GetRealDataList()
    if self.RealDataList == nil then
        self.RealDataList = List:New()
        local _list = self:GetViewDataList()
        for i = 1, #_list do
            local _data = {
                CellId = _list[i].CellId,
                Name = _list[i].Name,
                Id = _list[i].Id,
                Num = _list[i].Num,
                IsBind = _list[i].IsBind,
                Occ = _list[i].Occ,
                IsReward = false
            }
            self.RealDataList:Add(_data)
        end
    end
    return self.RealDataList
end

function LuckyCardSystem:GetRealDataByCellId(id)
    local _ret = nil
    local _list = self:GetRealDataList()
    for i = 1, #_list do
        local _data = _list[i]
        if _data.CellId == id then
            _ret = _data
        end
    end
    return _ret
end

-- Get preview data
function LuckyCardSystem:GetViewDataList()
    if self.ViewDataList == nil then
        self.ViewDataList = List:New()
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        local _lpOcc = 0
        if _lp then
            _lpOcc = _lp.IntOcc
        end
        local _cfg = DataConfig.DataGlobal[GlobalName.New_Sever_Luck_reward]
        if _cfg ~= nil then
            local _index = 1
            local _list = Utils.SplitStr(_cfg.Params, ';')
            for i = 1, #_list do
                local _values = Utils.SplitNumber(_list[i], '_')
                local _id = _values[1]
                local _num = _values[2]
                local _isBind = _values[3] == 1
                local _occ = _values[4]
                local _itemCfg = DataConfig.DataItem[_id]
                if _itemCfg == nil then
                    _itemCfg = DataConfig.DataEquip[_id]
                end
                local _name = _itemCfg.Name
                if _lpOcc == _occ or _occ == 9 then
                    local _data = {
                        CellId = _index,
                        Name = _name,
                        Id = _id,
                        Num = _num,
                        IsBind = _isBind,
                        Occ = _occ,
                        IsReward = false
                    }
                    _index = _index + 1
                    self.ViewDataList:Add(_data)
                end
            end
        end
    end
    return self.ViewDataList
end

-- Get task data
function LuckyCardSystem:GetTaskDataList()
    if self.TaskList == nil then
        self.TaskList = List:New()
        DataConfig.DataNewSeverLuckcard:Foreach(function(k, v)
            local _iconId = v.ShowIcon
            local _name = v.ShowName
            local _showDouble = v.IsDouble
            local _showTuiJian = v.IsRecommend
            local _funcId = v.JumpFunction
            local _task = {
                Id = k,
                IconId = _iconId,
                Name = _name,
                ShowDouble = _showDouble,
                ShowTuiJian = _showTuiJian,
                FuncId = _funcId,
                Count = 0,
                TCount = 0,
                Des = nil,
                State = 0
            }
            self.TaskList:Add(_task)
        end)
    end
    return self.TaskList
end

-- Get task data through task id
function LuckyCardSystem:GetTaskDataById(id)
    local _ret = nil
    local _list = self:GetTaskDataList()
    for i = 1, #_list do
        local _task = _list[i]
        if id == _task.Id then
            _ret = _task
        end
    end
    return _ret
end

-- Sort
function LuckyCardSystem:SortTask()
    self.TaskList:Sort(function(a, b)
        return a.State * 100 + a.Id < b.State * 100 + b.Id
    end)
end

-- Check the red dots
function LuckyCardSystem:CheckRedPoint()
    local _have = false
    local _taskList = self:GetTaskDataList()
    for i = 1, #_taskList do
        local _task = _taskList[i]
        if _task.State == 0 and not _have then
            _have = true
        end
    end
    local _count = self:GetCurPoint()
    local _tCount = self:GetTotalPoint()
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.ServeCrazy, _have)
    if not _have then
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.ServeCrazy, _count >= _tCount)
    end
end

function LuckyCardSystem:HaveRedPoint()
    local _have = false
    local _taskList = self:GetTaskDataList()
    for i = 1, #_taskList do
        local _task = _taskList[i]
        if _task.State == 0 and not _have then
            _have = true
        end
    end
    local _count = self:GetCurPoint()
    local _tCount = self:GetTotalPoint()
    if not _have then
        _have = _count >= _tCount
    end
    if _have then
        local _finish = true
        local _realDataList = self:GetRealDataList()
        for i = 1, #_realDataList do
            local _realData = _realDataList[i]
            if _finish and not _realData.IsReward then
                _finish = false
            end
        end
        if _finish then
            _have = false
        end
    end 
    return _have
end

-------------------------------------------- req msg --------------------------------------------

-- Request a flop
function LuckyCardSystem:ReqLuckyOnce(id)
    GameCenter.Network.Send("MSG_OpenServerAc.ReqLuckyOnce", {
        cellId = id
    })
end

-- Request a reward for a mission
function LuckyCardSystem:ReqGetLuckyTaskReawrd(id)
    GameCenter.Network.Send("MSG_OpenServerAc.ReqGetLuckyTaskReawrd", {
        taskId = id
    })
end

-- Request for award record
function LuckyCardSystem:ReqGetLuckyLog()
    GameCenter.Network.Send("MSG_OpenServerAc.ReqGetLuckyLog")
end

-------------------------------------------- req msg --------------------------------------------
---
-------------------------------------------- res msg --------------------------------------------

-- Lucky flop news
function LuckyCardSystem:ResLuckyCardInfo(msg)
    if msg == nil then
        return
    end
    -- Process the flop list
    if msg.gotRewards ~= nil then
        for i = 1, #msg.gotRewards do
            local got = msg.gotRewards[i]
            local _data = self:GetRealDataByCellId(got.cellId)
            _data.Id = got.itemId
            _data.Num = got.num
            _data.IsBind = got.bind
            _data.IsReward = true
        end
    end
    -- Processing task data
    if msg.tasks ~= nil then
        for i = 1, #msg.tasks do
            local _msgTask = msg.tasks[i]
            local _task = self:GetTaskDataById(_msgTask.id)
            local _cfg = DataConfig.DataNewSeverLuckcard[_task.Id]
            _task.Count = _msgTask.fenzi
            _task.TCount = _msgTask.fenmu
            _task.State = _msgTask.state
            local _des = UIUtils.CSFormat(_cfg.Name, _task.Count, _task.TCount)
            _task.Des = _des
        end
    end
    -- Set the current lucky value
    self.LuckyPoint = msg.lucky
    self:SortTask()
    -- Red dot settings
    -- self:CheckRedPoint()
end

-- Flop back
function LuckyCardSystem:ResLuckyOnce(msg)
    if msg == nil then
        return
    end
    local got = msg.reward
    local _data = self:GetRealDataByCellId(got.cellId)
    _data.Id = got.itemId
    _data.Num = got.num
    _data.IsBind = got.bind
    _data.IsReward = true
    self.LuckyPoint = msg.lucky
    -- self:CheckRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LUCKYCARD_LOTTERY_RESULT, _data)
end

-- Receive the task reward and return
function LuckyCardSystem:ResGetLuckyTaskReawrd(msg)
    if msg == nil then
        return
    end
    local _msgTask = msg.task
    local _task = self:GetTaskDataById(_msgTask.id)
    _task.Count = _msgTask.fenzi
    _task.TCount = _msgTask.fenmu
    _task.State = _msgTask.state
    local _cfg = DataConfig.DataNewSeverLuckcard[_task.Id]
    _task.Des = UIUtils.CSFormat(_cfg.Name, _task.Count, _task.TCount)
    self.LuckyPoint = msg.lucky
    self:SortTask()
    -- Red dot settings
    -- self:CheckRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LUCKYCARD_TASK_RESULT)
end

-- Return to the award record
function LuckyCardSystem:ResGetLuckyLog(msg)
    if msg == nil then
        return
    end
    local list = List:New()
    if msg.records ~= nil then
        for i = 1, #msg.records do
            local record = msg.records[i]
            local data = {
                Time = record.time,
                Name = record.playerName,
                ItemId = record.itemId,
                Num = record.num
            }
            list:Add(data)
        end
    end
    list:Sort(function(a, b)
        return a.Time > b.Time
    end)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LUCKYCARD_RECORD_RESULT, list)
end

-------------------------------------------- res msg --------------------------------------------

return LuckyCardSystem
