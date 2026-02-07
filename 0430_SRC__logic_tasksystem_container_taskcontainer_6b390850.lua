------------------------------------------------
-- Author: 
-- Date: 2021-03-19
-- File: TaskContainer.lua
-- Module: TaskContainer
-- Description: Task Container
------------------------------------------------
-- Quote
local RedPointTaskSubmitCondition = CS.Thousandto.Code.Logic.RedPointTaskSubmitCondition;
local TaskContainer = {
    AllTaskList = List:New(),
    Container = Dictionary:New()
}
function TaskContainer:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

-- Add a task
function TaskContainer:Add(taskType, task)
    if task == nil then
        return
    end
    local _list = nil;
    if self.Container ~= nil and task ~= nil then
        _list = self.Container[taskType]
        if _list ~= nil then
            local _task = self:FindTakByID(task.Data.Id)
            if _task ~= nil then
                Debug.LogError("Repeat tasks");
            else
                _list:Add(task);
                GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.TargetTask, task.Data.Id, RedPointTaskSubmitCondition(task.Data.Id))
            end
        else
            _list = List:New();
            _list:Add(task);
            self.Container[taskType] = _list;
            GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.TargetTask, task.Data.Id, RedPointTaskSubmitCondition(task.Data.Id))
        end
    end
end

function TaskContainer:RemoveEx(type, taskId)
    local _releaseKeys = List:New()
    local _list = self.Container[type]
    if _list ~= nil then
        local _index = 0
        for i = 1, #_list do
            local _task = _list[i]
            if _task ~= nil and _task.Data.Id == taskId then
                _index = i
                GameCenter.RedPointSystem:RemoveFuncCondition(FunctionStartIdCode.TargetTask, taskId);
                break
            end
        end
        if _index  ~= 0 and _index <= #_list then
            _list:RemoveAt(_index)
        end
        if #_list == 0 then
            _releaseKeys:Add(type)
        end
    end
    for i = 1, #_releaseKeys do
        local _key = _releaseKeys[i]
        self.Container:Remove(_key)
    end
end

-- Delete tasks in containers based on id
function TaskContainer:Remove(taskId)
    local _releaseKeys = List:New()
    local _list = nil;
    self.Container:ForeachCanBreak(function(k, v)
        local _list = v
        if _list ~= nil then
            local _index = 0
            for i = 1, #_list do
                local _task = _list[i]
                if _task ~= nil and _task.Data.Id == taskId then
                    _index = i
                    GameCenter.RedPointSystem:RemoveFuncCondition(FunctionStartIdCode.TargetTask, taskId);
                    break
                end
            end
            if _index  ~= 0 and _index <= #_list then
                _list:RemoveAt(_index)
            end
            if #_list == 0 then
                _releaseKeys:Add(k)
            end
            if _index ~= 0 then
                -- Because all tasks are unique
                return true
            end
        end
    end)
    for i = 1, #_releaseKeys do
        local _key = _releaseKeys[i]
        self.Container:Remove(_key)
    end
end

-- Find tasks based on task id
function TaskContainer:FindTakByID(taskId)
    local _ret = nil
    self.Container:ForeachCanBreak(function(k, v)
        if v ~= nil then
            for i = 1, #v do
                local _task = v[i]
                if _task ~= nil and _task.Data.Id == taskId then
                    _ret = _task
                    return true
                end
            end
        end
    end)
    return _ret
end

-- Find task lists by task type
function TaskContainer:FindTaskByType(type)
    local _list = self.Container[type];
    return _list;
end

-- Find tasks by type and ID
function TaskContainer:FindByTypeAndID(type, taskId)
    local _ret = nil
    local _list = self.Container[type];
        if _list ~= nil then
            for i = 1, #_list do
                local _task = _list[i];
                if _task ~= nil and _task.Data.Id == taskId then
                    _ret = _task
                end
            end
        end
    return _ret;
end

-- Find tasks through task behavior
function TaskContainer:FindByBehaviorType(type )
    local _ret = List:New()
    self.Container:Foreach(function(k, v)
        if v ~= nil then
            for i = 1, #v do
                local _task = v[i]
                if _task ~= nil and _task.Data.Behavior == type then
                    _ret:Add(_task)
                end
            end
        end
    end)
    return _ret;
end

-- Get all tasks
function TaskContainer:GetAllTask()
    self.AllTaskList:Clear();
    self.Container:Foreach(function(k, v)
        if v ~= nil then
            for i = 1, #v do
                local _task = v[i]
                self.AllTaskList:Add(_task)
            end
        end
    end)
    return self.AllTaskList;
end

-- Update the target description for all tasks
function TaskContainer:UpdateAllTaskTargetDes()
    self.Container:Foreach(function(k, v)
        if v ~= nil then
            for i = 1, #v do
                local _task = v[i];
                _task:UpdateTargetDes();
            end
        end
    end)
end

-- Update missions with limited combat power
function TaskContainer:UpdateFightPowerLimitTask()
    self.Container:Foreach(function(k, v)
        if v ~= nil then
            for i = 1, #v do
                local _task = v[i];
                if _task ~= nil and _task:GetLimitPower() > 0 then
                    _task:UpdateTask(GameCenter.LuaTaskManager:GetBehavior(_task.Data.Id));
                    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_TASKCHANG)
                end
            end
        end
    end)
end

-- Empty the container
function TaskContainer:Clear()
    -- Clear the red dot of the target system
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.TargetTask);
    self.Container:Clear();
end

return TaskContainer
