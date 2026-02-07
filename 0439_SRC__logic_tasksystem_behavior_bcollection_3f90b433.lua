------------------------------------------------
-- Author: 
-- Date: 2021-03-19
-- File: BCollection.lua
-- Module: BCollection
-- Description: Task acquisition behavior
------------------------------------------------
-- Quote
local SlotNameDefine = CS.Thousandto.Core.Asset.SlotNameDefine
local L_Behavior = require "Logic.TaskSystem.Behavior.TaskBehavior"
local BCollection = {
    -- The name of the action clip
    ActionName = "", -- action format: action_modelID (0_0, 2_800150)
    ActionState = 0, -- action state (0:normal;1:walk;2:rice)
    ActionModelID = 0, -- action model ID
    ActionSlotNum = 0, -- action slot num

    -- 2. Modal Follow Player
    -- tmp: create npc id follow player
    FollowModel = "",

    -- 3. Find pos enter plane copy
    -- Use for find pos enter plane copy via Trigger on the map
    PlaneCopyId = 0,
    TargetMapId = 0,
    TargetPos = nil,
}

function BCollection:New(type, taskId)
    return Utils.Extend(L_Behavior:New(type, taskId), self)
end

function BCollection:OnSetTarget(id, count, talkId, x, y, itemID, type)
    self.TaskTarget.TagId = id
    self.TaskTarget.TCount = count
    local _cfg = DataConfig.DataGather[self.TaskTarget.TagId]
    self.TaskTarget.TagName = _cfg == nil and nil or _cfg.Name
    local _task = GameCenter.LuaTaskManager.TaskContainer:FindTakByID(self.Id)
    if _task ~= nil then
        self.TaskTarget.MapName = _task.Data:GetMapName()
    end

    -- 2. Model Follow Player
    self.FollowModel = _task:GetFollowModel()

    -- 3. Find pos to enter plane copy
    local _taskXZ = _task:GetTaskXZ(self.Id)
    if _taskXZ ~= nil and _taskXZ ~= "" then
        -- 121_94_1999100: x_z_planeCopyId
        local _strs = Utils.SplitNumber(_taskXZ, '_')
        if #_strs >= 2 then
            self.TargetMapId = _taskXZ.MapId
            self.TaskTarget.PosX = _strs[1] or 0
            self.TaskTarget.PosY = _strs[2] or 0
        end
        if #_strs >= 3 then
            self.PlaneCopyId = _strs[3] or 0
        end
        if self.TaskTarget.PosX > 0 and self.TaskTarget.PosY > 0 then
            self.TargetPos = {
                MapId = _task.Data.MapId,
                X = self.TaskTarget.PosX,
                Y = 0,
                Z = self.TaskTarget.PosY
            }
        end
    end


    -- Another: Set Animation and Model
    self.ActionName = _task:GetActionName()
    if self.ActionName ~= "" then
        local action_list = Utils.SplitNumber(self.ActionName, '_')
        if action_list ~= nil and #action_list >= 2 then
            self.ActionState = tonumber(action_list[1]) or 0
            self.ActionModelID = tonumber(action_list[2]) or 0
            self.ActionSlotNum = tonumber(action_list[3]) or 0
        else
            self.ActionState = 0
            self.ActionModelID = 0
            self.ActionSlotNum = 0
        end
    end
end

function BCollection:SetTargetDes()
    if self.TaskTarget.Count >= self.TaskTarget.TCount then
        local _task = GameCenter.LuaTaskManager.TaskContainer:FindTakByID(self.Id)
        if _task ~= nil then
            if _task:IsAuto() then
                self.Des = DataConfig.DataMessageString.Get("TASK_BEHEAIOR_OVER")
            else
                self.Des = _task:GetJinDuDes()
            end
            self.UiDes = _task:GetUIDes(self.TaskTarget.Count, self.TaskTarget.TCount)
        end
    else
        local _task = GameCenter.LuaTaskManager.TaskContainer:FindTakByID(self.Id)
        if _task == nil then
            return
        end
        if _task.Data.Type == TaskType.Main or _task.Data.Type == TaskType.Daily or _task.Data.Type == TaskType.Guild or
            _task.Data.Type == TaskType.ZhuanZhi or _task.Data.Type == TaskType.Prison or _task.Data.Type == TaskType.DailyPrison then
            self.Des = _task:GetJinDuDes()
        else
            self.Des = UIUtils.CSFormat(DataConfig.DataMessageString.Get("TASK_BEHEAIOR_COLLECT"),
                           self.TaskTarget.MapName, self.TaskTarget.TagName, self.TaskTarget.Count,
                           self.TaskTarget.TCount)
        end
        self.UiDes = self.Des
    end
    
    -- Set Animation and Model
    if self.ActionState > 0 then
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if _lp == nil then
            return
        end
        _lp:MountDown()
        _lp:SetForceAnimId(self.ActionState)
    end
    if self.ActionModelID > 0 then
        GameCenter.LuaCharacterSystem:ReqTaskTransEquipPlayer(self.ActionName)
    end

    -- Create NPC to follow player
    if self.FollowModel ~= "" then
        GameCenter.LuaCharacterSystem:ReqTaskTransNPC(self.FollowModel)
    end
end

-- function BCollection:OnCanTransPort()
--     local _ret = true
--     if self.TargetMapId == GameCenter.MapLogicSystem.MapCfg.MapId then
--         _ret = false
--     end
--     return _ret
-- end

function BCollection:CallBack()
    local _task = GameCenter.LuaTaskManager.TaskContainer:FindTakByID(self.Id)
    if self.TaskTarget.Count == self.TaskTarget.TCount or self.TaskTarget.IsEnd then
        local _isSpecialTask = false
        if _task.Data.Type == TaskType.Guild then
            if _task.Data.Cfg.ConquerSubtype == 2 then
                -- Open the Immortal Alliance mission interface
                GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.GuildTask)
                _isSpecialTask = true;
            end
        end
        if not _isSpecialTask then
            local _openId = _task:SubMitTaskOpenPanel()
            if _openId == 0 then
                GameCenter.LuaTaskManager:SubMitTask(_task.Data.Id, _task.Data.Type)
            else
                GameCenter.MainFunctionSystem:DoFunctionCallBack(_openId)
            end
        end
    else
        if _task.Data.IsAccess then
            local _cloneCfg = DataConfig.DataCloneMap[self.PlaneCopyId]
            if _cloneCfg ~= nil then
                self.TargetMapId = _cloneCfg.Mapid
            end

            if self.TargetPos ~= nil then
                PlayerBT.Task:TaskArrivePosExEx(self.TaskTarget.TagId, self.Id, self.TargetPos.MapId, self.TargetPos.X, 0, self.TargetPos.Z)
            else
                -- collection
                PlayerBT.Task:TaskCollectObj(self.TaskTarget.TagId, self.Id, self.TaskTarget.Count, self.TaskTarget.TCount)
            end
        else
            -- Find npc to receive tasks
            _task:AccessTask()
        end
    end
end

function BCollection:OnDoBehavior(isClick)
    -- Debug.Log("yy BCollection  OnDoBehavior")
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end
    local _task = GameCenter.LuaTaskManager.TaskContainer:FindTakByID(self.Id)
    if _task ~= nil then
        if _task.Data.Type == TaskType.ZhanChang then
            if self.TaskTarget.Count ~= self.TaskTarget.TCount then
                if GameCenter.MapLogicSystem.MapCfg.Type == UnityUtils.GetObjct2Int(MapTypeDef.Copy) then
                    PlayerBT.Task:TaskCollectObj(self.TaskTarget.TagId, _task.Data.Id, self.TaskTarget.TCount)
                end
            else
                PlayerBT.ChangeState(PlayerBDState.Default)
            end
        else
            self:TransPort(Utils.Handler(self.CallBack, self))
        end
    end
end

function BCollection:OnShowGatherModelView()
    if self.TaskTarget.TagId then
        local _cfg = DataConfig.DataGather[self.TaskTarget.TagId]
        -- 1_800040_300_0 (type_modelID_scale_posY)
        if _cfg and _cfg.ShowUIModel then
            local _strs = Utils.SplitNumber(_cfg.ShowUIModel, '_')
            if #_strs >= 2 then
                local _UIType = tonumber(_strs[1]) -- UI Type not use this time
                local _modelID = tonumber(_strs[2])
                local _scale = tonumber(_strs[3]) or 100
                local _posY = tonumber(_strs[4]) or 0
                -- ShowModel(mtype,id, scale, posY, name, isShowWear, wearId, info)
                GameCenter.ModelViewSystem:ShowModel(ShowModelType.Gather, _modelID, _scale, _posY, _cfg.Name)
            end
        end
    end
end

return BCollection
