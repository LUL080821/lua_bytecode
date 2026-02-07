------------------------------------------------
-- Author: 
-- Date: 2021-03-19
-- File: TaskBehavior.lua
-- Module: TaskBehavior
-- Description: Task behavior
------------------------------------------------
-- Quote
local L_NetHander = CS.Thousandto.Code.Logic.NetHandler
local L_Target = require "Logic.TaskSystem.Data.TaskTarget"
local TaskBehavior = {
    Id = 0, -- Corresponding task id
    Des = nil, -- Behavior description
    UiDes = nil,
    Type = TaskBeHaviorType.Default, -- Behavior Type
    TaskTarget = nil, -- Behavioral Objectives
    Task = nil
}
function TaskBehavior:New(type, taskId)
    local _m = Utils.DeepCopy(self)
    _m.Type = type
    _m.Id = taskId
    _m.TaskTarget = L_Target:New()
    return Utils.DeepCopy(_m)
end

function TaskBehavior:GetTask()
    if self.Task == nil then
        self.Task = GameCenter.LuaTaskManager:GetTask(self.Id)
    end
    return self.Task
end

-- Custom conditions
function TaskBehavior:CustomCondition()
    local _ret = false
    if self.OnCustomCondition then
        _ret = self:OnCustomCondition()
    end
    return _ret
end

-- Update task targets
function TaskBehavior:UpdateBehavior(taskTarget)
    self.TaskTarget.Count = taskTarget.Count;
    self.TaskTarget.TagId = taskTarget.TagId;
    self:SetTargetDes();
    local _task = self:GetTask();
    if _task ~= nil then
        _task.Data.UiDes = self.UiDes;
    end
end

function TaskBehavior:SetTarget(id, count, talkId, x, y, itemID, type)
    if self.OnSetTarget then
        if type == nil then
            type = -1
        end
        self:OnSetTarget(id, count, talkId, x, y, itemID, type)
    end
end

-- Set the target description
function TaskBehavior:SetTargetDes()
    if self.OnSetTargetDes then
        self:OnSetTargetDes()
    end
end

-- Determine whether it can be delivered
function TaskBehavior:CanTransPort()
    local _ret = true
    if self.OnCanTransPort then
        _ret = self:OnCanTransPort()
    end
    return _ret
end

-- Execution behavior
function TaskBehavior:DoBehavior(isClick)
    -- Debug.LogTable(self)
    local _task = self:GetTask();
    if _task ~= nil then
        GameCenter.TaskController:SetRunTimeTask(_task);
    end
    if self.OnDoBehavior then
        if isClick == nil then
            isClick = false
        end
        self:OnDoBehavior(isClick)
    end
end

function TaskBehavior:TransPort(func)
    local _isTransPort = true;
    GameCenter.LuaTaskManager.CurSelectTaskID = self.Id;
    local _task = self:GetTask();
    -- If the current map is a copy of the plane, it will not be sent
    if GameCenter.GameSceneSystem.ActivedScene == nil or GameCenter.GameSceneSystem.ActivedScene.Cfg == nil then
        _isTransPort = false
    else
        local _mapCfg = DataConfig.DataMapsetting[GameCenter.GameSceneSystem.ActivedScene.MapId]
        if _mapCfg ~= nil and _mapCfg.Type == MapTypeDefine.PlaneCopy then
            _isTransPort = false;
        else
            _isTransPort = self:CanTransPort()
        end
    end
    if _task ~= nil then
        if GameCenter.MapLogicSystem.MapCfg ~= nil and _task.Data.MapId ~= GameCenter.MapLogicSystem.MapCfg.MapId and _task.Data.IsTransPort and _isTransPort then
            -- Send
            local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
            if _lp ~= nil then
                if GameCenter.MapLogicSystem.MapCfg.Type == UnityUtils.GetObjct2Int(MapTypeDef.Copy) then
                else
                    if GameCenter.MapLogicSystem.MapCfg.Type ~= UnityUtils.GetObjct2Int(MapTypeDef.JJC) then
                        local _targetMapCfg = DataConfig.DataMapsetting[_task.Data.MapID]
                        if _targetMapCfg ~= nil and _targetMapCfg.LevelName ==
                            GameCenter.MapLogicSystem.MapCfg.LevelName then
                            -- Same resources, switch directly
                            L_NetHander.SendMessage_TransportWorldMap(_task.Data.MapId, 0)
                        else
                            Debug.Log("[TaskBehavior:TransPort] LocalPlayer switch mapId = " .. _task.Data.MapId)
                            _lp:Action_CrossMapTran(_task.Data.MapId)
                        end
                    end
                end
                GameCenter.LuaTaskManager.IsAutoTaskForTransPort = true; -- If you are too lazy to change your name, it means whether you start performing tasks. Don't care about Main
            end
        else
            if func ~= nil then
                func()
            end
        end
    end
end

function TaskBehavior:IsTalkToNpc()
    local _ret = false
    if self.OnIsTalkToNpc then
        _ret = self:OnIsTalkToNpc()
    end
    return _ret
end

function TaskBehavior:Update(dt)
    if self.OnUpdate then
        self:OnUpdate(dt)
    end
end

return TaskBehavior
