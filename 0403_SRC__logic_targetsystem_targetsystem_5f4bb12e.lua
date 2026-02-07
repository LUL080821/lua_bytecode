------------------------------------------------
-- Author: 
-- Date: 2021-03-13
-- File: TargetSystem.lua
-- Module: TargetSystem
-- Description: Target system
------------------------------------------------
local L_RedPointItemCondition = CS.Thousandto.Code.Logic.RedPointItemCondition
local L_GetSortValue = nil
local L_TaskSortFunc = nil
local L_SortBase = 1000000000
local L_CacheList = List:New()

local TargetSystem = {
    StepCfgId = 0,
}

function TargetSystem:GetTargets(type)
    L_CacheList:Clear()
    local _container = GameCenter.LuaTaskManager.TaskContainer.Container
    if _container == nil then
        return L_CacheList
    end
    _container:Foreach(function(k, v)
        local _list = v
        local _listCount = #_list
        for i = 1, _listCount do
            local _task = _list[i]
            local _taskData = _task.Data
            if _taskData.Type ~= TaskType.Guild or _taskData.IsAccess then
                if type == TargetTaskDefine.All or type == _task:GetNewType() then
                    L_CacheList:Add(_taskData)
                end
            end
        end
    end)
    L_CacheList:Sort(L_TaskSortFunc)
    return L_CacheList
end

function TargetSystem:GetRedPointArray()
    local _result = {}
    local _container = GameCenter.LuaTaskManager.TaskContainer.Container
    if _container == nil then
        return _result
    end

    _container:Foreach(function(k, v)
        local _list = v
        local _listCount = #_list
        for i = 1, _listCount do
            local _task = _list[i]
            local _taskId = _task.Data.Id
            local _newType = _task:GetNewType()
            if _result[_newType] == nil then
                if GameCenter.LuaTaskManager:GetBehaviorType(_taskId) ~= TaskBeHaviorType.Talk and GameCenter.LuaTaskManager:CanSubmitTask(_taskId) then
                    _result[_newType] = true
                    _result[TargetTaskDefine.All] = true
                end
            end
        end
    end)
    return _result
end

function TargetSystem:ReqGetTarget()
    GameCenter.Network.Send("MSG_Task.ReqGetTarget")
end

function TargetSystem:ResTargetInfo(msg)
    GameCenter.RedPointSystem:RemoveFuncCondition(FunctionStartIdCode.TargetTask, -9999)
    local _cfg = DataConfig.DataTaskTargetReward[msg.stage]
    if _cfg ~= nil then
        GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.TargetTask, -9999, L_RedPointItemCondition(ItemTypeCode.WorldLevelScore, _cfg.NeedNum))
    end
    local _isLv = false
    if self.StepCfgId ~= msg.stage then
        _isLv = true
    end
    self.StepCfgId = msg.stage
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_TASKTARGET_UPDATE, isLv)
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
    local _beType = GameCenter.LuaTaskManager:GetBehaviorType(_taskId)
    if _beType ~= TaskBeHaviorType.Talk and GameCenter.LuaTaskManager:CanSubmitTask(_taskId) then
        _sort = 0
        _subsort = math.floor(L_SortBase / 10)
    else
        _sort = L_SortBase
        _subsort = 0
    end
    local _taskType = taskData.Type
    if _taskType == TaskType.Main then
        _sort = _sort + _subsort + _taskId
    elseif _taskType == TaskType.Daily then
        _sort = (_sort +_subsort) * 2 + _taskId
    elseif _taskType == TaskType.Guild then
        _sort = (_sort + _subsort) * 3 + _taskId
    elseif _taskType == TaskType.Branch then
        _sort = (_sort + _subsort) * 4 + _taskId
    elseif _taskType == TaskType.Prison then
        _sort = (_sort + _subsort) * 5 + _taskId
    elseif _taskType == TaskType.DailyPrison then
        _sort = (_sort +_subsort) * 6 + _taskId
    end
    return _sort
end

return TargetSystem