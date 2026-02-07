------------------------------------------------
-- Author: 
-- Date: 2021-03-19
-- File: LuaTestBehavior.lua
-- Module: LuaTestBehavior
-- Description: Lua test task behavior
------------------------------------------------
-- Quote
local L_WrapMode = CS.UnityEngine.WrapMode
local L_AnimClipNameDefine = CS.Thousandto.Core.Asset.AnimClipNameDefine
local L_AnimationPartType = CS.Thousandto.Core.Asset.AnimationPartType
local L_Behavior = require "Logic.TaskSystem.Behavior.TaskBehavior"
local L_WaterParam = require "Logic.TaskSystem.Data.WaterWaveParam"
local L_MonsterProperty = CS.Thousandto.Code.Logic.MonsterProperty
local ArriveToAnim = {
    -- Anim Type 0: Protagonist Action 1: Magic Action 2: Pet Action
    AnimType = 0,
    -- Plane copy ID
    PlaneCopyId = 0,
    -- Plane copy map id
    TargetMapId = 0,
    TargetPos = nil,
    Param = nil,

    -- The coordinates to be moved in the copy
    Move_x = 0,
    Move_y = 0,

    -- The starting coordinate of the movement
    StarMovePos = Vector3.zero,
    -- The end point coordinates of the moving
    EndMovePos = Vector3.zero,

    -- The name of the action clip
    ActionName = "",
    -- Tick time of action clips
    Tick = 0,
    -- Action clip playback time
    PlayClipTime = 0,
    -- Current Anim type
    CurAnimType = TaskAnimType.Default
}

function ArriveToAnim:New(type, taskId)
    return Utils.Extend(L_Behavior:New(type, taskId), self)
end

function ArriveToAnim:OnSetTarget(id, count, talkId, x, y, itemID, type)
    if type == nil then
        type = -1
    end
    self.TaskTarget.TagId = id
    self.TaskTarget.PosX = x
    self.TaskTarget.PosY = y
    self.TaskTarget.TCount = count
    self.TaskTarget.TagName = L_MonsterProperty.GetName(self.TaskTarget.TagId)
    local _task = GameCenter.LuaTaskManager.TaskContainer:FindTakByID(Id)
    if _task ~= nil then
        if self.TargetPos == nil then
            self.TargetPos = {
                MapId = _task.Data.MapID,
                X = self.TaskTarget.PosX,
                Y = 0,
                Z = self.TaskTarget.PosY
            }
        end
        self.TaskTarget.MapName = _task.Data:GetMapName()
    end
    -- Set the plane screen effect data
    if self.Param == nil then
        self.Param = L_WaterParam:New()
    end
    local _planesShowEnter = ""
    local _target = ""
    _target = _task:GetTaskTarget(self.Id)
    _planesShowEnter = _task:GetPlanShowEnter(self.Id)
    if _planesShowEnter ~= nil and _planesShowEnter ~= "" then
        local _strs = Utils.SplitNumber(_planesShowEnter, '_')
        for i = 1, #_strs do
            if #_strs.Length ~= 5 then
                -- Debug.LogError("Task WaterWaveEffect cfg isError")
                break
            end
            self.Param.distanceFactor = _strs[1]
            self.Param.timeFactor = _strs[2]
            self.Param.totalFactor = _strs[3]
            self.Param.waveWidth = _strs[4]
            self.Param.waveSpeed = _strs[5]
        end
    end
    -- Set the plane copy Id
    if _target ~= nil and _target ~= "" then
        local _strs = Utils.SplitNumber(target, '_')
        if #_strs >= 3 then
            self.AnimType = _strs[1]
            self.PlaneCopyId = _strs[3]
        end
    end
    self.ActionName = _task:GetActionName()
    local _movePos = _task:GetMovePos()
    self.Move_x = _movePos.x
    self.Move_y = _movePos.z
end

function ArriveToAnim:OnSetTargetDes()
    local _task = GameCenter.LuaTaskManager.TaskContainer:FindTakByID(Id)
    if _task == nil then
        return
    end
    self.Des = _task:GetJinDuDes()
    self.UiDes = self.Des
end

function ArriveToAnim:CallBack()
    -- Calling the Npc pathfinding interface
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end
    local _task = GameCenter.LuaTaskManager.TaskContainer:FindTakByID(self.Id)
    if _task.Data.IsAccess then
        local _cloneCfg = DataConfig.DataCloneMap[self.PlaneCopyId]
        if _cloneCfg ~= nil then
            self.TargetMapId = _cloneCfg.Mapid
        end
        if GameCenter.MapLogicSystem.MapCfg.MapId == self.TargetMapId then
            if self.TaskTarget.TagId == 0 then
                -- Play the protagonist's action
                self.PlayClipTime = _lp:GetAnimClipLength(self.ActionName)
                _lp:PlayAnim(self.ActionName, Core.Asset.AnimationPartType.AllBody)
                _lp.IsCatching = true
                self.CurAnimType = TaskAnimType.PlayAnim
            elseif self.TaskTarget.TagId == 1 then
            elseif self.TaskTarget.TagId == 2 then
                -- Play pet action
                local _pet = GameCenter.GameSceneSystem:GetLocalPet()
                if _pet ~= nil then
                    self.CurAnimType = TaskAnimType.MoveTo;
                    self.StarMovePos = Vector3(_pet.Position.x, _pet.Position.y, _pet.Position.z)
                    self.EndMovePos = Vector3(self.Move_x, _pet.Position.y, self.Move_y)
                    self.PlayClipTime = _pet:GetAnimClipLength(self.ActionName)
                end
            end
            self.Tick = 0;
        else
            -- Not reached the target point
            if self.TaskTarget.Count ~= self.TaskTarget.TCount then
                GameCenter.MapLogicSwitch.CanMandate = false;
                PlayerBT.Task:TaskArriveToAnimEx(self.TaskTarget.TagId, self.Id, self.TargetPos.MapId, self.TargetPos.X,
                    self.TargetPos.Y, self.TargetPos.Z)
            end
        end
        GameCenter.LuaTaskManager.CurSelectTaskID = self.Id
    else
        -- Find npc to receive tasks
        _task:AccessTask()
    end
end

function ArriveToAnim:OnDoBehavior(isClick)
    -- Debug.Log("yy ArriveToAnim  OnDoBehavior   ")
    self:TransPort(Utils.Handler(self.CallBack, self))
end

function ArriveToAnim:OnUpdate(dt)
    if self.CurAnimType ~= TaskAnimType.Default then
        -- Determine whether it is in the mission map
        if GameCenter.MapLogicSystem.MapCfg.MapId == self.TargetMapId then
            if self.AnimType == 0 then
                -- Lead role action
                self:TickPlayerAction(dt)
            elseif self.AnimType == 1 then
                -- Magic weapon action
                self:TickFbAction(dt)
            elseif self.AnimType == 2 then
                -- Pet action
            end
        else
            -- Not on the mission map
            if self.AnimType == 0 then
                -- Lead role action
            elseif self.AnimType == 1 then
                -- Magic weapon action
            elseif self.AnimType == 2 then
                -- Pet action
            end
        end
    end
end

-- Tick player action
function ArriveToAnim:TickPlayerAction(dt)
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp ~= nil then
        if self.Tick < self.PlayClipTime then
            self.Tick = self.Tick + dt
        else
            -- Request server task completion
            local _task = GameCenter.LuaTaskManager.TaskContainer:FindTakByID(self.Id)
            local _isSpecialTask = self:CheckSpecialTask(_task)
            if not _isSpecialTask then
                if _task ~= nil then
                    self.Tick = 0;
                    self.CurAnimType = TaskAnimType.Default;
                    _lp.IsCatching = false;
                    _lp:PlayAnim(L_AnimClipNameDefine.NormalIdle, L_AnimationPartType.AllBody, L_WrapMode.Once)
                    GameCenter.LuaTaskManager:SubMitTask(_task.Data.Id, _task.Data.Type)
                end
            end
        end
    end
end
-- Tick magic weapon action
function ArriveToAnim:TickFbAction(dt)
end

-- Tick pet action
function ArriveToAnim:TickPetAction(dt)
end

function ArriveToAnim:CheckSpecialTask(task)
    if task.Data.Type == TaskType.Guild then
        if task.Data.Cfg.ConquerSubtype == 2 then
            if self.TaskTarget.IsEnd then
                -- Open the Immortal Alliance mission interface
                GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.GuildTask)
                return true
            end
        end
    end
    return false;
end

return ArriveToAnim
