------------------------------------------------
-- Author: 
-- Date: 2021-03-19
-- File: LuaTestBehavior.lua
-- Module: LuaTestBehavior
-- Description: Lua test task behavior
------------------------------------------------
-- Quote
local L_MonsterProperty = CS.Thousandto.Code.Logic.MonsterProperty
local L_Behavior = require "Logic.TaskSystem.Behavior.TaskBehavior"
local L_WaterParam = require "Logic.TaskSystem.Data.WaterWaveParam"
local ArrivePosEx = {
    -- Plane copy ID
    PlaneCopyId = 0,
    -- Plane copy map id
    TargetMapId = 0,
    TargetPos = nil,
    Param = nil,
    IsClick = false
}

function ArrivePosEx:New(type, taskId)
    return Utils.Extend(L_Behavior:New(type, taskId), self)
end

function ArrivePosEx:OnSetTarget(id, count, talkId, x, y, itemID, type)
    if type == nil then
        type = -1
    end
    self.TaskTarget.TagId = id
    self.TaskTarget.PosX = x
    self.TaskTarget.PosY = y
    self.TaskTarget.TCount = count
    self.TaskTarget.TagName = L_MonsterProperty.GetName(self.TaskTarget.TagId)
    local _task = GameCenter.LuaTaskManager.TaskContainer:FindTakByID(self.Id)
    if _task ~= nil then
        self.TargetPos = {
            MapId = _task.Data.MapId,
            X = self.TaskTarget.PosX,
            Y = 0,
            Z = self.TaskTarget.PosY
        }
        self.TaskTarget.MapName = _task.Data:GetMapName()
    end
    -- Set the plane screen effect data
    if self.Param == nil then
        self.Param = L_WaterParam:New()
    end
    local _planesShowEnter = ""
    local _arget = ""
    local _target = _task:GetTaskTarget(self.Id)
    _planesShowEnter = _task:GetPlanShowEnter(self.Id)
    if _planesShowEnter ~= nil and _planesShowEnter ~= "" then
        local _strs = Utils.SplitNumber(_planesShowEnter, '_')
        if _strs ~= nil then
            for i = 1, #_strs do
                if #_strs ~= 5 then
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
    end
    -- Set the plane copy Id
    if _target ~= nil and _target ~= "" then
        local _strs = Utils.SplitNumber(_target, '_')
        if #_strs >= 3 then
            self.PlaneCopyId = _strs[3]
        end
    end
end

function ArrivePosEx:OnSetTargetDes()
    local _task = GameCenter.LuaTaskManager.TaskContainer:FindTakByID(self.Id)
    if _task == nil then
        return
    end
    self.Des = _task:GetJinDuDes();
    self.UiDes = self.Des
    if (_task.Data.Type == TaskType.Main or _task.Data.Type == TaskType.Prison) and self.TaskTarget.Count == self.TaskTarget.TCount then
        if _task.Data.Cfg.LeaveMap == 1 then
            -- Request to exit the copy
            GameCenter.MapLogicSystem:SendLeaveMapMsg(false)
        end
    end
end

function ArrivePosEx:OnCanTransPort()
    local _ret = true
    if self.TargetMapId == GameCenter.MapLogicSystem.MapCfg.MapId then
        _ret = false
    end
    return _ret
end

function ArrivePosEx:CallBack()
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
            if GameCenter.MandateSystem ~= nil then
                GameCenter.MandateSystem:Start()
            end
        else
            -- Not reached the target point
            if self.TaskTarget.Count ~= self.TaskTarget.TCount then
                PlayerBT.Task:TaskArrivePosExEx(self.TaskTarget.TagId, self.Id, self.TargetPos.MapId, self.TargetPos.X,
                    0, self.TargetPos.Z)
            else
                local _isSpecialTask = false
                if _task.Data.Type == TaskType.Guild then
                    if _task.Data.Cfg.ConquerSubtype == 2 then
                        if GameCenter.LuaTaskManager:CanSubmitTask(_task.Data.Id) then
                            -- Open the Immortal Alliance mission interface
                            GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.GuildTask)
                            _isSpecialTask = true
                        end
                    end
                elseif _task.Data.Type == TaskType.ZhuanZhi then
                    if self.IsClick then
                        GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.ChangeJob);
                        _isSpecialTask = true
                    end
                end
                if not _isSpecialTask then
                    -- Determine whether you need to find an NPC to submit a task
                    if _task.Data.SubmitNpcID ~= 0 then
                        PlayerBT.Task:TaskTalkToNpc(_task.Data.SubmitNpcID)
                    else
                        local _openId = _task:SubMitTaskOpenPanel()
                        if _openId == 0 then
                            GameCenter.LuaTaskManager:SubMitTask(_task.Data.Id, _task.Data.Type)
                        else
                            GameCenter.MainFunctionSystem:DoFunctionCallBack(_openId)
                        end
                    end
                end
            end
        end
        GameCenter.LuaTaskManager.CurSelectTaskID = self.Id
    else
        -- Find npc to receive tasks
        _task:AccessTask()
    end
end

function ArrivePosEx:OnDoBehavior(isClick)
    -- Debug.Log("yy ArrivePosEx  OnDoBehavior   ")
    self.IsClick = isClick
    self:TransPort(Utils.Handler(self.CallBack, self))
end

return ArrivePosEx
