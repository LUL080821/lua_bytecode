------------------------------------------------
-- Author: Wang Sheng
-- Date: 2021-03-19
-- File: TaskBehaviorManager.lua
-- Module: TaskBehaviorManager
-- Description: Task behavior management
------------------------------------------------
-- Quote
local L_Talk = require "Logic.TaskSystem.Behavior.TalkCharactor"
local L_PlaneCopy = require "Logic.TaskSystem.Behavior.ArrivePosEx"
local L_OpenUI = require "Logic.TaskSystem.Behavior.TaskOpenUI"
local L_PlaneCopyAnim = require "Logic.TaskSystem.Behavior.ArriveToAnim"
local L_PassCopy = require "Logic.TaskSystem.Behavior.PassCopy"
local L_Container = require "Logic.TaskSystem.Container.TaskBehaviorContainer"
local L_Collect = require "Logic.TaskSystem.Behavior.BCollection"
local L_SubMitItem = require "Logic.TaskSystem.Behavior.SubMitItem"
local L_KillMonsterTrainMap = require "Logic.TaskSystem.Behavior.KillMonsterTrainMap"
local L_KillMonsterDropItem = require "Logic.TaskSystem.Behavior.KillMonsterDropItem"

local TaskBehaviorManager = {
    IsPause = false,
    Container = nil
}
function TaskBehaviorManager:New()
    local _m = Utils.DeepCopy(self)
    _m.Container = L_Container:New()
    return _m
end

function TaskBehaviorManager:IniItialization()
end

function TaskBehaviorManager:UnIniItialization()
    self.Container:Clear()
end

-- Create behavior
function TaskBehaviorManager:Create(type, id)
    local _behavior = nil;
    if type == TaskBeHaviorType.Talk then
        _behavior = self:CreateTalk(type, id)
    elseif type == TaskBeHaviorType.Kill then
        _behavior = self:CreateKill(type, id)
    elseif type == TaskBeHaviorType.Collection then
        _behavior = self:CreateCollection(type, id)
    elseif type == TaskBeHaviorType.CopyKillForUI or type == TaskBeHaviorType.OpenUI then
        _behavior = self:CreateOpenUI(type, id)
    elseif type == TaskBeHaviorType.PassCopy then
        _behavior = self:CreatePassCopy(type, id)
    elseif type == TaskBeHaviorType.Level then
        _behavior = self:CreateLimitLv(type, id)
    elseif type == TaskBeHaviorType.CopyKill then
        _behavior = self:CreateCopyKill(type, id)
    elseif type == TaskBeHaviorType.FindCharactor then
        _behavior = self:CreateFindCharactor(type, id)
    elseif type == TaskBeHaviorType.SubMit then
        _behavior = self:CreateSubMitItem(type, id)
    elseif type == TaskBeHaviorType.ArrivePos then
        _behavior = self:CreateArrivePos(type, id)
    elseif type == TaskBeHaviorType.OpenUIToSubMit or type == TaskBeHaviorType.AddFriends then
        _behavior = self:CreateOpenUISbmit(type, id)
    elseif type == TaskBeHaviorType.MountFlyUp then
        _behavior = self:CreateTaskMountFlyUp(type, id)
    elseif type == TaskBeHaviorType.CollectItem or type == TaskBeHaviorType.CollectRealItem then
        _behavior = self:CreateCollectItem(type, id)
    elseif type == TaskBeHaviorType.ArrivePosEx then
        _behavior = self:CreateArrivePosEx(type, id)
    elseif type == TaskBeHaviorType.ArriveToAnim then
        _behavior = self:CreateArriveToAnim(type, id)
    elseif type == TaskBeHaviorType.KillMonsterTrainMap then
        _behavior = self:CreateKillMonsterTrainMap(type, id)
    elseif type == TaskBeHaviorType.KillMonsterDropItem then
        _behavior = self:CreateKillMonsterDropItem(type, id)
    end
    return _behavior
end
-- Dialogue behavior
function TaskBehaviorManager:CreateTalk(type, id)
    local _behavior = L_Talk:New(type, id)
    return _behavior
end
-- Kill monsters (kill players) behavior
function TaskBehaviorManager:CreateKill(type, id)
    -- local _behavior = L_PlaneCopy:New(type, id)
    -- return _behavior
end
-- Collection behavior
function TaskBehaviorManager:CreateCollection(type, id)
    local _behavior = L_Collect:New(type, id)
    return _behavior
end
-- Open UI behavior
function TaskBehaviorManager:CreateOpenUI(type, id)
    local _behavior = L_OpenUI:New(type, id)
    return _behavior
end
-- Transfer into copy behavior
function TaskBehaviorManager:CreatePassCopy(type, id)
    local _behavior = L_PassCopy:New(type, id)
    return _behavior
end
-- Achieving the level behavior
function TaskBehaviorManager:CreateLimitLv()
    -- LimitLevel behavior = new LimitLevel();
    -- return behavior;
end

function TaskBehaviorManager:CreateCopyKill()
    -- CopyKill behavior = new CopyKill();
    -- return behavior;
end
-- Looking for someone
function TaskBehaviorManager:CreateFindCharactor()
    -- FindCharactor behavior = new FindCharactor();
    -- return behavior;
end
-- Submit props
function TaskBehaviorManager:CreateSubMitItem(type, id)
    local _behavior = L_SubMitItem:New(type, id)
    return _behavior;
end
-- Arrive at a certain location
function TaskBehaviorManager:CreateArrivePos()
    -- ArrivePos behavior = new ArrivePos();
    -- return behavior;
end
-- Open the UI to complete the task
function TaskBehaviorManager:CreateOpenUISbmit()
    -- TaskOpenUISubmit behavior = new TaskOpenUISubmit();
    -- return behavior;
end
-- Take off and fly mount
function TaskBehaviorManager:CreateTaskMountFlyUp()
    -- TaskMountFltUp behaivor = new TaskMountFltUp();
    -- return behaivor;
end
-- Collect props
function TaskBehaviorManager:CreateCollectItem()
    -- CollectItem behaivor = new CollectItem();
    -- return behaivor;
end
-- Arrive at the specified location (no circle)
function TaskBehaviorManager:CreateArrivePosEx(type, id)
    local _behavior = L_PlaneCopy:New(type, id)
    return _behavior
end
-- Arrive at the specified location and enter the plane and play a specific action
function TaskBehaviorManager:CreateArriveToAnim(type, id)
    local _behavior = L_PlaneCopyAnim:New(type, id)
    return _behavior
end
-- Kill monsters in the training map
function TaskBehaviorManager:CreateKillMonsterTrainMap(type, id)
    local _behavior = L_KillMonsterTrainMap:New(type, id)
    return _behavior
end
-- Drop item behavior
function TaskBehaviorManager:CreateKillMonsterDropItem(type, id)
    local _behavior = L_KillMonsterDropItem:New(type, id)
    return _behavior
end
-- Trans behavior
function TaskBehaviorManager:CreateTrans(type, id)
    local _behavior = L_Trans:New(type, id)
    return _behavior
end
-- Add behavior
function TaskBehaviorManager:Add(taskId, behavior)
    -- Debug.LogError("yy TaskBehaviorManager:Add "..tostring(taskId))
    self.Container:Add(taskId, behavior)
end
-- The behavior of obtaining a task
function TaskBehaviorManager:GetBehavior(taskId)
    local _ret = self.Container:Find(taskId)
    return _ret;
end
-- Delete a task behavior
function TaskBehaviorManager:RmoveBehavior(taskId)
    self.Container:Remove(taskId)
end
function TaskBehaviorManager:GetBehaviorCount()
    return self.Container:Count()
end
-- Whether to complete the behavior
function TaskBehaviorManager:IsEndBehavior(taskId)
    local _ret = false;
    local _behavior = self:GetBehavior(taskId);
    if _behavior ~= nil then
        _ret = _behavior.TaskTarget:IsReach(_behavior.Type);
    end
    return _ret;
end
-- Go to complete a certain behavior
function TaskBehaviorManager:DoBehavior(taskId, isClick, isClickByForm)
    -- Check Stop Behavior Task
    -- if taskId == 80402 or taskId == 80502 then
    --     Debug.Log("Stop Behavior Task "..tostring(taskId))
    --     return;
    -- end
    local _denyDoBehavior = GameCenter.LuaTaskManager:IsDenyTalkDoBehavior(taskId)
    if _denyDoBehavior == true then
        Debug.Log("Deny Do Behavior task_id="..tostring(taskId))
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_TASK_DENY_DO_BEHAVIOR, taskId)
        return;
    end

    -- If pause, return directly
    if self.IsPause then
        return;
    end
    local _behavior = self:GetBehavior(taskId);
    -- Debug.LogTable(_behavior)
    local _task = GameCenter.LuaTaskManager:GetTask(taskId);
    if _task == nil then
        return;
    end
    -- Determine whether there is any combat power limit
    local _limitPower = _task:GetLimitPower();
    if _limitPower > 0 and not _task:GetIgnoLimit() then
        -- There is limited combat power
        if GameCenter.GameSceneSystem:GetLocalPlayerFightPower() >= _limitPower then
            self:OnDoBehavior(_behavior, _task, isClick, isClickByForm);
        else
            -- Popup prompt
            GameCenter.MsgPromptSystem:ShowMsgBox(DataConfig.DataMessageString.Get("Task_Score_Limit"),
                DataConfig.DataMessageString.Get("Task_TiShi_1"), DataConfig.DataMessageString.Get("Task_TiShi_2"),
                function(x)
                    if x == MsgBoxResultCode.Button1 then
                        self:OnDoBehavior(_behavior, _task, isClick, isClickByForm);
                        _task:SetIgnoLimit(true)
                    elseif x == MsgBoxResultCode.Button2 then
                        -- Open the interface to become stronger
                        GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.BianQiang);
                    end
                end);
        end
    else
        self:OnDoBehavior(_behavior, _task, isClick, isClickByForm);
    end
end

function TaskBehaviorManager:OnDoBehavior(behavior, task, isClick, isClickByForm)
    if behavior ~= nil then
        if behavior.Type ~= TaskBeHaviorType.CopyKill and behavior.Type ~= TaskBeHaviorType.CopyKillForUI and
            task.Data.Type ~= TaskType.ZhanChang and isClick then
            if GameCenter.MapLogicSystem.MapCfg.Type == UnityUtils.GetObjct2Int(MapTypeDef.Copy) then
                GameCenter.MsgPromptSystem:ShowPrompt(DataConfig.DataMessageString.Get("EXIT_COPY_FOR_GOON_TASK"))
                return;
            end
        end
        if task ~= nil then
            if isClick and task.IsShowGuide then
                task.IsShowGuide = false;
            end
            if isClickByForm then
                if  GameCenter.MapLogicSystem.MapCfg ~= nil and GameCenter.MapLogicSystem.MapCfg.Type == UnityUtils.GetObjct2Int(MapTypeDef.Copy) then
                    -- If the message confirmation box pops up in the copy, whether to exit the copy and continue the task
                    GameCenter.MsgPromptSystem:ShowMsgBox(DataConfig.DataMessageString.Get("TASK_TISHI_1"),
                        function(x)
                            if x == MsgBoxResultCode.Button2 then
                                -- Calling to leave the replica interface
                                GameCenter.LuaTaskManager.CurSelectTaskID = task.Data.Id;
                                GameCenter.LuaTaskManager.IsAutoTaskForTransPort = true;
                                GameCenter.MapLogicSystem:DoLeaveMap()
                                return;
                            end
                        end);
                end
            end
            GameCenter.LuaTaskManager.CurSelectTaskID = task.Data.Id;
            behavior:DoBehavior(isClick);
        end
    end
end

-- Update behavior
function TaskBehaviorManager:UpdateBehavior(behavior, target)
    if behavior ~= nil then
        behavior:UpdateBehavior(target)
    end

end

function TaskBehaviorManager:SetBehaviorTag(id, count, talkId, x, y, itemID, type, behavior)
    if behavior ~= nil then
        behavior:SetTarget(id, count, talkId, x, y, itemID, type);
    end
end

-- Get the behavior of a task corresponding to a task id
function TaskBehaviorManager:GetTaskBehaviorType(taskId)
    local _ret = TaskBeHaviorType.Default
    local _behavior = self:GetBehavior(taskId);
    if _behavior ~= nil then
        _ret = _behavior.Type;
    end
    return _ret;
end

-- Heartbeat
function TaskBehaviorManager:OnUpdate(dt)
    self.Container:OnUpdate(dt);
end

return TaskBehaviorManager
