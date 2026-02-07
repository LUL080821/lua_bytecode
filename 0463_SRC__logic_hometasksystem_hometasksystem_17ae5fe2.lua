------------------------------------------------
-- Author:
-- Date: 2021-06-17
-- File: HomeTaskSystem.lua
-- Module: HomeTaskSystem
-- Description: Home Mission
------------------------------------------------
-- Quote
local L_TaskData = require "Logic.HomeTaskSystem.HomeTaskData"
local L_GetSortValue = nil
local L_TaskSortFunc = nil
local L_SortBase = 1000000000
local HomeTaskSystem = {
    -- Spirit Gathering Level
    JuLingLv = 0,
    -- Decorate the current value
    ZHValue = 0,
    -- Decoration maximum
    ZHMaxValue = 0,
    -- Daily reward experience
    RewardExp = 0,
    -- Have you received your daily experience
    IsRewardExp = 0,
    -- Task Dictionary
    DicTask = Dictionary:New(),
}

-- initialization
function HomeTaskSystem:Initialize()
end

function HomeTaskSystem:UnInitialize()
end

function HomeTaskSystem:CanRewardExp()
    local _ret = not self.IsRewardExp
    local _activeLogic = GameCenter.MapLogicSystem.ActiveLogic
    if _activeLogic ~= nil and _activeLogic.TupInfo ~= nil then
        _ret = _activeLogic.TupInfo.tupReward
    end
    return _ret
end

function HomeTaskSystem:GetTaskListByType(type)
    local _ret = nil
    if self.DicTask ~= nil then
        if type == 0 then
            local _taskList = List:New()
            local _keys = self.DicTask:GetKeys()
            if _keys ~= nil then
                for i = 1, #_keys do
                    local _key = _keys[i]
                    local _list = self.DicTask[_key]
                    if _list ~= nil then
                        for m = 1, #_list do
                            local _task = _list[m]
                            _taskList:Add(_task)
                        end
                    end
                end
            end
            _ret = _taskList
        else
            _ret = self.DicTask[type]
        end
    end
    if _ret ~= nil then
        _ret:Sort(L_TaskSortFunc)
    end
    return _ret
end

function HomeTaskSystem:GetTask(id)
    local _ret = nil
    local _keys = self.DicTask:GetKeys()
    if _keys ~= nil then
        for i = 1, #_keys do
            local _key = _keys[i]
            local _list = self.DicTask[_key]
            if _list ~= nil then
                for m = 1, #_list do
                    local _task = _list[m]
                    if _task.Id == id then
                        _ret = _task
                        break
                    end
                end
            end
        end
    end
    return _ret
end

function HomeTaskSystem:GetRedPointArray()
    local _result = {}
    local _container = self.DicTask
    if _container == nil then
        return _result
    end

    _container:Foreach(function(k, v)
        local _list = v
        local _listCount = #_list
        for i = 1, _listCount do
            local _task = _list[i]
            local _taskId = _task.Id
            local _type = _task.Type
            if _result[_type] == nil then
                if _task.State == 1 then
                    _result[_type] = true
                    _result[HomeTaskType.Default] = true
                end
            end
        end
    end)
    return _result
end

function HomeTaskSystem:CheckRedPoint()
    local _isHave = self:CanRewardExp()
    if not _isHave then
        local _redPointArray = self:GetRedPointArray()
        _isHave = _redPointArray[HomeTaskType.Default]
        if not _isHave then
            _isHave = _redPointArray[HomeTaskType.BaiFang]
            if not _isHave then
                _isHave = _redPointArray[HomeTaskType.SongLi]
                if not _isHave then
                    _isHave = _redPointArray[HomeTaskType.GouMai]
                    if not _isHave then
                        _isHave = _redPointArray[HomeTaskType.RenQi]
                        if not _isHave then
                            _isHave = _redPointArray[HomeTaskType.ZhuangShiDu]
                        end
                    end
                end
            end
        end
    end
    if _isHave == nil then
        _isHave = false
    end
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.HomeTask, _isHave)
end

L_TaskSortFunc = function(left, right)
    return L_GetSortValue(left) < L_GetSortValue(right)
end

L_GetSortValue = function(taskData)
    local _sort = 0
    local _subsort = 0
    if taskData == nil then
        return _sort
    end
    local _taskId = taskData.Id
    if taskData.State == 1 then
        _sort = 0
        _subsort = math.floor(L_SortBase / 10)
    elseif taskData.State == 2 then
        _sort = L_SortBase*2
        _subsort = 0
    else
        _sort = L_SortBase
        _subsort = 0
    end
    _sort = _sort + _subsort + taskData.Sort
    return _sort
end

----------------------------------------msg----------------------------------------

-- Request a Cornucopia Reward
function HomeTaskSystem:ReqGetTupReward()
    GameCenter.Network.Send("MSG_Home.ReqGetTupReward")
end

function HomeTaskSystem:ReqTaskList()
    GameCenter.Network.Send("MSG_Home.ReqTaskList")
end

-- Request a reward for a mission
function HomeTaskSystem:ReqTaskReward(taskId)
    GameCenter.Network.Send("MSG_Home.ReqTaskReward", {id = taskId})
end


-- Return to the task list
function HomeTaskSystem:ResHomeTaskList(msg)
    if msg == nil then
        return
    end
    self.DicTask:Clear()
    if msg.tasks ~= nil then
        for i = 1, #msg.tasks do
            local _info = msg.tasks[i]
            local _cfg = DataConfig.DataSocialHouseTask[_info.id]
            local _type = _cfg.Type
            local _taskList = self.DicTask[_type]
            if _taskList == nil then
                _taskList = List:New()
                local _task = L_TaskData:New()
                _task:ParaseMsg(_info, _cfg)
                _taskList:Add(_task)
                self.DicTask:Add(_type, _taskList)
            else
                local _task = L_TaskData:New()
                _task:ParaseMsg(_info, _cfg)
                _taskList:Add(_task)
            end
        end
    end
    self:CheckRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_HOMETASKCHANG)
end

-- Return to task update
function HomeTaskSystem:ResTaskUpdate(msg)
    if msg == nil then
        return
    end
    if msg.tasks ~= nil then
        for i = 1, #msg.tasks do
            local _info = msg.tasks[i]
            local _cfg = DataConfig.DataSocialHouseTask[_info.id]
            local _type = _cfg.Type
            local _taskList = self.DicTask[_type]
            if _taskList == nil then
                _taskList = List:New()
                local _task = L_TaskData:New()
                _task:ParaseMsg(_info, _cfg)
                _taskList:Add(_task)
                self.DicTask:Add(_type, _taskList)
            else
                local _isFind = false
                for i = #_taskList, 1, -1 do
                    local _task = _taskList[i]
                    if _task.Id == _info.id then
                        _task:Updata(_info, _cfg)
                        _isFind = true
                        break
                    end
                end
                if not _isFind then
                    local _task = L_TaskData:New()
                    _task:ParaseMsg(_info, _cfg)
                    _taskList:Add(_task)
                end
            end
        end
    end
    self:CheckRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_HOMETASKCHANG)
end

return HomeTaskSystem