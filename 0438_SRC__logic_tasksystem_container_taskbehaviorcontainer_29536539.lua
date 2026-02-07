------------------------------------------------
-- Author: 
-- Date: 2021-03-19
-- File: TaskBehaviorContainer.lua
-- Module: TaskBehaviorContainer
-- Description: Task behavior container
------------------------------------------------
-- Quote
local TaskBehaviorContainer = {
    Container = Dictionary:New(),
}

function TaskBehaviorContainer:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

-- Add behavior
function TaskBehaviorContainer:Add(taskId, behavior)
    self.Container[taskId] = behavior
end

-- Delete the corresponding behavior of the task
function TaskBehaviorContainer:Remove(taskId)
    self.Container:Remove(taskId)
end

-- Find task behavior by id
function TaskBehaviorContainer:Find(taskId)
    local _ret = self.Container[taskId]
    return _ret;
end

function TaskBehaviorContainer:GetCount()
    local _ret = self.Container:Count();
    return _ret;
end

function TaskBehaviorContainer:Clear()
    self.Container:Clear()
end

-- Heartbeat
function TaskBehaviorContainer:OnUpdate(dt)
    self.Container:Foreach(function(k, v)
        if v ~= nil then
            v:Update(dt)
        end
    end)
end

return TaskBehaviorContainer
