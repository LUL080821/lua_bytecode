------------------------------------------------
-- Author: 
-- Date: 2021-03-19
-- File: PassCopy.lua
-- Module: PassCopy
-- Description: Purchase copy task behavior
------------------------------------------------
-- Quote
local L_NetHandler = CS.Thousandto.Code.Logic.NetHandler
local L_Behavior = require "Logic.TaskSystem.Behavior.TaskBehavior"
local PassCopy = {}

function PassCopy:New(type, taskId)
    return Utils.Extend(L_Behavior:New(type, taskId), self)
end

function PassCopy:OnSetTarget(id, count, talkId, x, y, itemID, type)
    self.TaskTarget.TagId = id
    self.TaskTarget.TCount = count
    local _cfg = DataConfig.DataCloneMap[self.TaskTarget.TagId]
    self.TaskTarget.TagName = _cfg == nil and nil or _cfg.DuplicateName
end

function PassCopy:OnSetTargetDes()
    local _task = GameCenter.LuaTaskManager.TaskContainer:FindTakByID(self.Id)
    if self.TaskTarget.Count >= self.TaskTarget.TCount then
        if _task ~= nil then
            if _task:IsAuto() then
                self.Des = DataConfig.DataMessageString.Get("TASK_BEHEAIOR_OVER")
            else
                self.Des = _task:GetJinDuDes()
            end
            self.UiDes = _task:GetUIDes(self.TaskTarget.Count, self.TaskTarget.TCount)
        end
    else
        if _task ~= nil and (_task.Data.Type == TaskType.Main or _task.Data.Type == TaskType.Prison) then
            self.Des = UIUtils.CSFormat(_task.Data.Cfg.ConditionsDescribe, self.TaskTarget.TagName)
            self.UiDes = self.Des
        elseif _task.Data.Type == TaskType.Guild then
            self.Des =
                UIUtils.CSFormat(_task.Data.Cfg.ConditionsDescribe, self.TaskTarget.Count, self.TaskTarget.TCount)
            self.UiDes = self.Des
        elseif _task.Data.Type == TaskType.ZhuanZhi then
            self.Des = UIUtils.CSFormat(DataConfig.DataMessageString.Get("TASK_BEHAVIOR_CROSS_COPY"),
                           self.TaskTarget.TagName)
            local _limit = _task:GetLimitPower()
            if _limit > 0 then
                local _str = ""
                local _myPower = GameCenter.GameSceneSystem:GetLocalPlayerFightPower()
                if _myPower < _limit then
                    local _des = UIUtils.CSFormat("{0}{1}/{2}#n", DataConfig.DataMessageString[5738], _myPower, _limit)
                    _str = _str .. _des
                else
                    local _des = UIUtils.CSFormat("{0}#n", DataConfig.DataMessageString[5738])
                    _str = _str .. _des
                end
                self.Des = _str
            end
            self.UiDes = self.Des
        else
            self.Des = UIUtils.CSFormat(DataConfig.DataMessageString.Get("TASK_BEHAVIOR_CROSS_COPY"),
                           self.TaskTarget.TagName)
            self.UiDes = self.Des
        end
    end
end

function PassCopy:OnDoBehavior(isClick)
    -- Debug.Log("yy PassCopy  OnDoBehavior   ")
    if isClick == nil then
        isClick = false
    end
    local _task = GameCenter.LuaTaskManager.TaskContainer:FindTakByID(self.Id)
    if _task ~= nil then
        if _task.Data.Type == TaskType.Main or _task.Data.Type == TaskType.Prison then
            if GameCenter.LuaTaskManager:CanSubmitTask(task.Data.Id) then
                self:TransPort(Utils.Handler(function()
                    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
                    if _lp ~= nil then
                        PlayerBT.Task:TaskTalkToNpc(_task.Data.SubmitNpcID, self.Id)
                    end
                end, self))
            else
                -- Check the boot
                if not GameCenter.GuideSystem:Check(GuideTriggerType.ChickOpenUITask, _task.Data.Id) then
                    GameCenter.MainFunctionSystem:DoFunctionCallBack(_task.Data.Cfg.OpenPanel,
                        _task.Data.Cfg.OpenPanelParam)
                end
            end
        elseif _task.Data.Type == TaskType.Guild then
            self:TransPort(Utils.Handler(function()
                if GameCenter.LuaTaskManager:CanSubmitTask(_task.Data.Id) then
                    -- Special treatment
                    if _task.Data.Cfg.ConquerSubtype == 2 then
                        -- Open the Immortal Alliance mission interface
                        GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.GuildTask)
                    end
                else
                    local _value = _task.Data.Cfg.OpenNpcPanel
                    local _isTalkToNpc = false
                    if _value == 1 then
                        _isTalkToNpc = true
                    end
                    if _isTalkToNpc then
                        PlayerBT.Task:TaskTalkToNpc(_task.Data.Cfg.OverNpc, self.Id)
                    end
                end
                GameCenter.LuaTaskManager.CurSelectTaskID = self.Id
            end, self))
        else
            if _task.Data.Type == TaskType.Daily or _task.Data.Type == TaskType.DailyPrison then
                self:TransPort(Utils.Handler(function()
                    -- Not in the copy
                    if self.TaskTarget.Count == self.TaskTarget.TCount or self.TaskTarget.IsEnd then
                    else
                        PlayerBT.Task:TaskTalkToNpc(_task.Data.Cfg.NpcId, self.Id)
                    end
                end, self))
            else
                if self.TaskTarget.Count == self.TaskTarget.TCount or self.TaskTarget.IsEnd then
                    -- Complete task dialogue
                    PlayerBT.Task:TaskTalkToNpc(_task.Data.SubmitNpcID)
                else
                    L_NetHandler.SendMessage_EnterCopyMap(TaskTarget.TagId)
                end
            end
        end
        GameCenter.LuaTaskManager.CurSelectTaskID = self.Id
    end
end

return PassCopy
