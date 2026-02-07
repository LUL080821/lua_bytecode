------------------------------------------------
-- Author: Wang Sheng
-- Date: 2021-03-19
-- File: TaskController.lua
-- Module: TaskController
-- Description: Task Control Script
------------------------------------------------
-- Quote
local TaskController = {
    -- Current status of the controller
    CurState = TaskControllerState.Stop,
    -- The task currently being executed
    RunTimeTask = nil,
    -- Stop UI List
    HoldUiList = List:New(),
    -- Whether to execute suspended UI
    IsUseHoldUI = true
}

function TaskController:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

function TaskController:SetRunTimeTask(task)
    self.RunTimeTask = task;
end

-- Perform tasks
function TaskController:Run(taskId, isClick, isClickByForm)
    self.IsUseHoldUI = true
    if isClick == nil then
        isClick = false
    end
    if isClickByForm == nil then
        isClickByForm = false
    end
    self.CurState = TaskControllerState.Play
    self.HoldUiList:Clear()
    GameCenter.LuaTaskManager:StarTask(taskId, isClick, isClickByForm)
end

-- Perform daily tasks
function TaskController:RunDaiyTask(subType, isClick, isClickByForm)
    if isClick == nil then
        isClick = false
    end
    if isClickByForm == nil then
        isClickByForm = false
    end
    self.CurState = TaskControllerState.Play
    GameCenter.LuaTaskManager:StartDailyTask(subType, isClick, isClickByForm)
end

-- Stop the task
function TaskController:Stop()
    self.IsUseHoldUI = true;
    self.CurState = TaskControllerState.Stop;
    -- Clear the execution task
    self.RunTimeTask = nil
    self.HoldUiList:Clear()
    GameCenter.LuaTaskManager.IsAutoTaskForTransPort = false
end

-- Pause the task
function TaskController:Pause()
    self.CurState = TaskControllerState.Pause
end

-- Wake up mission
function TaskController:Resume()
    self.CurState = TaskControllerState.Play
    if self.RunTimeTask ~= nil then
        local _behavior = GameCenter.LuaTaskManager:GetBehavior(self.RunTimeTask.Data.Id)
        if _behavior ~= nil then
            -- Determine whether it is a mission to overcome the tribulation
            if self.RunTimeTask.Data.Type == TaskType.ZhuanZhi then
                local _system = GameCenter.ChangeJobSystem
                if _system ~= nil and _system.CurTask ~= nil then
                    local _taskId = _system.CurTask.Data.Id
                    if _system.EndIds[_taskId] ~= nil then
                        -- The last mission, to overcome the disaster
                        if GameCenter.MapLogicSystem.MapCfg.Type ~= UnityUtils.GetObjct2Int(MapTypeDef.Copy) and
                        GameCenter.MapLogicSystem.MapCfg.Type ~= UnityUtils.GetObjct2Int(MapTypeDef.PlanCopy) then
                            GameCenter.MapLogicSwitch:DoChangeJobDujie()
                        end
                    else
                        -- Determine whether it is a copy. If it is a copy, the task cannot be restored.
                        if GameCenter.MapLogicSystem.MapCfg.Type ~= UnityUtils.GetObjct2Int(MapTypeDef.Copy) then
                            GameCenter.TaskController:Run(_taskId, false, true)
                        end
                    end
                end
            else
                if _behavior.Type == TaskBeHaviorType.OpenUI then
                    local _isTalkToNpc = _behavior:IsTalkToNpc()
                    if _isTalkToNpc then
                        self:Run(self.RunTimeTask.Data.Id)
                    end
                else
                    self:Run(self.RunTimeTask.Data.Id)
                end
            end
        end
    else
        self.CurState = TaskControllerState.Stop
    end
end

-- Wake up the task after switching the map
function TaskController:ResumeForTransPort()
    if GameCenter.LuaTaskManager:StartTransPortTask() then
        self.CurState = TaskControllerState.Play
    end
end

-- Can I continue to perform tasks
function TaskController:CanRuning()
    return self.CurState == TaskControllerState.Play
end

-- Add a UI for suspending tasks
function TaskController:AddHoldUI(uiId)
    if not self.IsUseHoldUI then
        return
    end
    if self.CurState == TaskControllerState.Stop then
        return
    end
    self.HoldUiList:Add(uiId)
end

-- Remove the UI of the suspended task
function TaskController:RemoveHoldUI(uiId)
    if not self.IsUseHoldUI then
        return
    end
    for i = #self.HoldUiList, 1, -1 do
        if self.HoldUiList[i] == uiId then
            self.HoldUiList:RemoveAt(i)
        end
    end
end

-- Heartbeat
function TaskController:Update(dt)
    if self.CurState == TaskControllerState.Play then
        local _blockIsRunning = GameCenter.BlockingUpPromptSystem:IsRunning()
        if _blockIsRunning or #self.HoldUiList > 0 then
            if self.RunTimeTask ~= nil then
                self:Pause()
            end
        else
        end
    elseif self.CurState == TaskControllerState.Pause then
        if not GameCenter.BlockingUpPromptSystem:IsRunning() and GameCenter.MapLogicSystem.MapCfg ~= nil then
            local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
            if _lp ~= nil then
                if #self.HoldUiList == 0 and not _lp.IsChuanDaoing then
                    local _isMandating = false
                    if GameCenter.MandateSystem ~= nil then
                        _isMandating = GameCenter.MandateSystem:IsRunning()
                    end
                    if not _isMandating then
                        -- If there is no pending UI, continue to execute the task
                        -- self:Resume()
                        -- Debug.Log("TaskController:Update Resume task = disabled")
                    end
                end
            end
        end
    end
end

return TaskController
