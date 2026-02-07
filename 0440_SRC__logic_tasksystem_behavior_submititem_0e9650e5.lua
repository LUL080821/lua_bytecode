------------------------------------------------
-- Author: 
-- Date: 2021-03-19
-- File: SubmitItem.lua
-- Module: SubmitItem
-- Description: Task dialogue behavior
------------------------------------------------
-- Quote
local L_Behavior = require "Logic.TaskSystem.Behavior.TaskBehavior"
local SubmitItem = {
    -- The name of the action clip
    ActionName = "", -- action (0:normal;1:walk;2:rice) , format: action_modelID (0_0, 2_800150)
    ActionState = 0, -- action state (0:normal;1:walk;2:rice)
    ActionModelID = 0, -- action model ID
    ActionSlotNum = 0, -- action slot num
}

function SubmitItem:New(type, taskId)
    return Utils.Extend(L_Behavior:New(type, taskId), self)
end

function SubmitItem:OnSetTarget(id, count, talkId, x, y, itemID, type)
    self.TaskTarget.TagId = id
    local _npcCfg = DataConfig.DataNpc[self.TaskTarget.TagId]
    self.TaskTarget.TagName = _npcCfg == nil and nil or _npcCfg.Name
    local _task = GameCenter.LuaTaskManager.TaskContainer:FindTakByID(self.Id)
    if _task ~= nil then
        self.TaskTarget.MapName = _task.Data:GetMapName()
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

function SubmitItem:OnSetTargetDes()
    local _task = GameCenter.LuaTaskManager.TaskContainer:FindTakByID(self.Id)
    if _task == nil then
        return
    end
    if _task.Data.Type == TaskType.Main or _task.Data.Type == TaskType.Prison then
        self.Des = _task.Data.Cfg.ConditionsDescribe
        self.UiDes = self.Des
    elseif _task.Data.Type == TaskType.Daily or _task.Data.Type == TaskType.DailyPrison then
        self.Des = _task.Data.Cfg.ConditionsDescribe
        self.UiDes = self.Des
    elseif _task.Data.Type == TaskType.Guild then
        self.Des = _task.Data.Cfg.ConditionsDescribe
        self.UiDes = self.Des
    elseif _task.Data.Type == TaskType.ZhuanZhi then
        self.Des = _task.Data.Cfg.ConditionsDescribe
        self.UiDes = self.Des
    else
        DataConfig.DataMessageString.Get("TASK_BEHAIVOR_GOTO_TALK")
        self.Des = UIUtils.CSFormat(DataConfig.DataMessageString.Get("TASK_BEHAVIOR_TALK_CHARACTOR"),
                       self.TaskTarget.MapName, self.TaskTarget.TagName)
        self.UiDes = UIUtils.CSFormat(DataConfig.DataMessageString.Get("TASK_BEHAIVOR_GOTO_TALK"),
                         self.TaskTarget.MapName, self.TaskTarget.TagName)
    end

    -- Set Animation and Model
    if self.ActionState > 0 then
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if _lp == nil then
            return
        end
        _lp:SetForceAnimId(self.ActionState)
    end
    if self.ActionModelID > 0 then
        GameCenter.LuaCharacterSystem:ReqTaskTransEquipPlayer(self.ActionName)
    end
end

function SubmitItem:CallBack()
    local _task = GameCenter.LuaTaskManager.TaskContainer:FindTakByID(self.Id)
    if _task ~= nil then
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if _lp == nil then
            return
        end
        if _task.Data.IsAccess then
            if _task.Data.Type == TaskType.Guild then
                if _task.Data.Cfg.ConquerSubtype == 2 then
                    if self.TaskTarget.IsEnd then
                        -- Open the Immortal Alliance mission interface
                        GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.GuildTask)
                    else
                        PlayerBT.Task:TaskTalkToNpc(self.TaskTarget.TagId, self.Id)
                    end
                    return
                end
            end
            -- Calling the Npc pathfinding interface
            PlayerBT.Task:TaskTalkToNpc(self.TaskTarget.TagId, self.Id)
        else
            _task:AccessTask()
        end
    end
end

function SubmitItem:OnDoBehavior(isClick)
    -- Debug.Log("yy SubmitItem  OnDoBehavior   ")
    self:TransPort(Utils.Handler(self.CallBack, self))
end

return SubmitItem
