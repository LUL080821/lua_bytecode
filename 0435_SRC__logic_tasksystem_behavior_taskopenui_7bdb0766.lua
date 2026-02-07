------------------------------------------------
-- Author: 
-- Date: 2021-03-19
-- File: TaskOpenUI.lua
-- Module: TaskOpenUI
-- Description: Task opening UI behavior
------------------------------------------------
-- Quote
local L_MonsterProperty = CS.Thousandto.Code.Logic.MonsterProperty
local L_Behavior = require "Logic.TaskSystem.Behavior.TaskBehavior"
local TaskOpenUI = {}

function TaskOpenUI:New(type, taskId)
    return Utils.Extend(L_Behavior:New(type, taskId), self)
end

function TaskOpenUI:OnSetTarget(id, count, talkId, x, y, itemID, type)
            self.TaskTarget.TagId = id
            self.TaskTarget.TCount = count
            self.TaskTarget.TagName = L_MonsterProperty.GetName(self.TaskTarget.TagId)
            local _task = GameCenter.LuaTaskManager.TaskContainer:FindTakByID(self.Id)
            if _task ~= nil then
                self.TaskTarget.MapName = _task.Data:GetMapName()
            end
        end

        function TaskOpenUI:OnSetTargetDes()
            local _task = GameCenter.LuaTaskManager.TaskContainer:FindTakByID(self.Id)
            if _task == nil then
                return
            end
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
                self.Des = _task:GetJinDuDes()
                self.UiDes = self.Des
            end
        end

        function TaskOpenUI:OnCustomCondition()
            local _ret = true
            local _task = GameCenter.LuaTaskManager.TaskContainer:FindTakByID(self.Id)
            if _task ~= nil and _task.Data.IsShowRecommend then
                GameCenter.TaskController.IsUseHoldUI = false
                _ret = not _task:JoinRecommendDaily()
            end
            return _ret
        end

        function TaskOpenUI:OnDoBehavior(isClick)
            if not self:CustomCondition() then
                return
            end
            local _task = GameCenter.LuaTaskManager.TaskContainer:FindTakByID(self.Id)
            if _task ~= nil then
                if _task.Data.Type == TaskType.Main then
                    if GameCenter.LuaTaskManager:CanSubmitTask(_task.Data.Id) then
                        -- Submit the task now
                        GameCenter.LuaTaskManager:SubMitTask(_task.Data.Id, _task.Data.Type)
                    else
                        local _isTalkToNpc = false
                        local _value = _task.Data.Cfg.OpenNpcPanel
                        if _value == 1 then
                            _isTalkToNpc = true
                        else
                            _isTalkToNpc = false
                        end
                        if _task.Data.Cfg.OpenPanel == FunctionStartIdCode.TaskDaily then
                            -- Determine whether you have received daily tasks
                            local _task = GameCenter.LuaTaskManager:GetDailyTask()
                            if _task == nil or not _task.Data.IsAccess then
                                _isTalkToNpc = true
                            else
                                _isTalkToNpc = false
                            end
                        end
                        if _isTalkToNpc then
                            self:TransPort(Utils.Handler(function()
                                GameCenter.TaskController.IsUseHoldUI = false
                                if _task.Data.Cfg.OpenPanelParam == 0 then
                                    PlayerBT.Task:TaskTalkToNpc(_task.Data.SubmitNpcID, _task.Data.Id, true, nil)
                                else
                                    PlayerBT.Task:TaskTalkToNpc(_task.Data.SubmitNpcID, _task.Data.Id, true, _task.Data.Cfg.OpenPanelParam)
                                end
                            end, self))
                        else
                            if isClick then
                                -- Debug.LogTable(_task.Data)
                                -- Debug.LogTable(_task.Data.Cfg)
                                -- Check the boot
                                if not GameCenter.GuideSystem:Check(GuideTriggerType.ChickOpenUITask, _task.Data.Id) then
                                    GameCenter.TaskController.IsUseHoldUI = false
                                    -- Debug.LogTable(_task.Data)                    
                                    GameCenter.MainFunctionSystem:DoFunctionCallBack(_task.Data.Cfg.OpenPanel, _task.Data.Cfg.OpenPanelParam)
                                end
                            end
                        end
                    end
                    GameCenter.LuaTaskManager.CurSelectTaskID = self.Id;
                elseif _task.Data.Type == TaskType.Guild then
                    self:TransPort(Utils.Handler(function()
                        if GameCenter.LuaTaskManager:CanSubmitTask(_task.Data.Id) then
                            -- Special treatment
                            if _task.Data.Cfg.ConquerSubtype == 2 then
                                -- Open the Immortal Alliance mission interface
                                GameCenter.TaskController.IsUseHoldUI = false;
                                GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.GuildTask)
                            end
                        else
                            local _isTalkToNpc = false
                            local _value = guildTask.GuildData.Cfg.OpenNpcPanel;
                            if _value == 1 then
                                _isTalkToNpc = true
                            else
                                _isTalkToNpc = false
                            end
                            if _isTalkToNpc then
                                PlayerBT.Task:TaskTalkToNpc(_task.Data.Cfg.OverNpc)
                            end
                        end
                        GameCenter.LuaTaskManager.CurSelectTaskID = self.Id;
                    end, self))
                elseif _task.Data.Type == TaskType.Daily then
                    if GameCenter.LuaTaskManager:CanSubmitTask(_task.Data.Id) then
                        GameCenter.LuaTaskManager.SubMitTask();
                    else
                        -- Check the boot
                        if not GameCenter.GuideSystem:Check(GuideTriggerType.ChickOpenUITask, _task.Data.Id) then
                            if _task.Data.Cfg.OpenPanelParam ~= 0 then
                                GameCenter.TaskController.IsUseHoldUI = false;
                                GameCenter.MainFunctionSystem:DoFunctionCallBack(_task.Data.Cfg.OpenPanel, _task.Data.Cfg.OpenPanelParam)
                            else
                                GameCenter.TaskController.IsUseHoldUI = false;
                                GameCenter.MainFunctionSystem:DoFunctionCallBack(_task.Data.Cfg.OpenPanel, nil)
                            end
                        end
                    end
                    GameCenter.LuaTaskManager.CurSelectTaskID = self.Id
                elseif _task.Data.Type == TaskType.Branch then
                    if GameCenter.LuaTaskManager:CanSubmitTask(_task.Data.Id) then
                        local _openId = _task:SubMitTaskOpenPanel()
                        if _openId == 0 then
                            GameCenter.LuaTaskManager:SubMitTask()
                        else
                            GameCenter.TaskController.IsUseHoldUI = false;
                            GameCenter.MainFunctionSystem:DoFunctionCallBack(_openId)
                        end
                    else
                        if _task.Data.Cfg.BackGroupId ~= 0 then
                            -- Check the boot
                            if not GameCenter.GuideSystem:Check(GuideTriggerType.ChickOpenUITask, _task.Data.Id) then
                                GameCenter.TaskController.IsUseHoldUI = false;
                                GameCenter.MainFunctionSystem:DoFunctionCallBack(_task.Data.Cfg.OpenPanel, _task.Data.Cfg.BackGroupId)
                            end
                        else
                            if _task.Data.Cfg.GetItem ~= 0 then
                                GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(_task.Data.Cfg.GetItem)                                
                            else
                                -- Check the boot
                                if not GameCenter.GuideSystem:Check(GuideTriggerType.ChickOpenUITask, _task.Data.Id) then
                                    GameCenter.TaskController.IsUseHoldUI = false;
                                    GameCenter.MainFunctionSystem:DoFunctionCallBack(_task.Data.Cfg.OpenPanel, nil)
                                end
                            end
                        end
                    end
                    GameCenter.LuaTaskManager.CurSelectTaskID = self.Id
                elseif _task.Data.Type == TaskType.ZhuanZhi then
                    -- Debug.LogTable(_task.Data)
                    if GameCenter.LuaTaskManager:CanSubmitTask(_task.Data.Id) then
                        -- If it is clicked in on the main interface --Open the transfer UI to submit the task
                        GameCenter.TaskController.IsUseHoldUI = false;
                        GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.ChangeJob, nil);
                    else
                        -- Check the boot
                        if isClick then
                            if not GameCenter.GuideSystem:Check(GuideTriggerType.ChickOpenUITask, _task.Data.Id) then
                                GameCenter.TaskController.IsUseHoldUI = false
                                if _task.Data.Cfg.BackGroupId == 0 then
                                    GameCenter.MainFunctionSystem:DoFunctionCallBack(_task.Data.Cfg.OpenUI, nil)
                                else
                                    GameCenter.MainFunctionSystem:DoFunctionCallBack(_task.Data.Cfg.OpenUI, _task.Data.Cfg.BackGroupId)
                                end
                            end
                        end
                        GameCenter.LuaTaskManager.CurSelectTaskID = self.Id
                    end
                    GameCenter.TaskController:Stop()
                elseif _task.Data.Type == TaskType.Prison then
                    if GameCenter.LuaTaskManager:CanSubmitTask(_task.Data.Id) then
                        -- Submit the task now
                        GameCenter.LuaTaskManager:SubMitTask(_task.Data.Id, _task.Data.Type)
                    else
                        local _isTalkToNpc = false
                        local _value = _task.Data.Cfg.OpenNpcPanel
                        if _value == 1 then
                            _isTalkToNpc = true
                        else
                            _isTalkToNpc = false
                        end
                        if _task.Data.Cfg.OpenPanel == FunctionStartIdCode.TaskDaily then
                            -- Determine whether you have received daily tasks
                            local _task = GameCenter.LuaTaskManager:GetDailyTask()
                            if _task == nil or not _task.Data.IsAccess then
                                _isTalkToNpc = true
                            else
                                _isTalkToNpc = false
                            end
                        end
                        if _isTalkToNpc then
                            self:TransPort(Utils.Handler(function()
                                GameCenter.TaskController.IsUseHoldUI = false
                                if _task.Data.Cfg.OpenPanelParam == 0 then
                                    PlayerBT.Task:TaskTalkToNpc(_task.Data.SubmitNpcID, _task.Data.Id, true, nil)
                                else
                                    PlayerBT.Task:TaskTalkToNpc(_task.Data.SubmitNpcID, _task.Data.Id, true, _task.Data.Cfg.OpenPanelParam)
                                end
                            end, self))
                        else
                            if isClick then
                                -- Debug.LogTable(_task.Data)
                                -- Debug.LogTable(_task.Data.Cfg)
                                -- Check the boot
                                if not GameCenter.GuideSystem:Check(GuideTriggerType.ChickOpenUITask, _task.Data.Id) then
                                    GameCenter.TaskController.IsUseHoldUI = false
                                    -- Debug.LogTable(_task.Data)                    
                                    GameCenter.MainFunctionSystem:DoFunctionCallBack(_task.Data.Cfg.OpenPanel, _task.Data.Cfg.OpenPanelParam)
                                end
                            end
                        end
                    end
                    GameCenter.LuaTaskManager.CurSelectTaskID = self.Id;
                elseif _task.Data.Type == TaskType.DailyPrison then
                    if GameCenter.LuaTaskManager:CanSubmitTask(_task.Data.Id) then
                        GameCenter.LuaTaskManager.SubMitTask();
                    else
                        -- Check the boot
                        if not GameCenter.GuideSystem:Check(GuideTriggerType.ChickOpenUITask, _task.Data.Id) then
                            if _task.Data.Cfg.OpenPanelParam ~= 0 then
                                GameCenter.TaskController.IsUseHoldUI = false;
                                GameCenter.MainFunctionSystem:DoFunctionCallBack(_task.Data.Cfg.OpenPanel, _task.Data.Cfg.OpenPanelParam)
                            else
                                GameCenter.TaskController.IsUseHoldUI = false;
                                GameCenter.MainFunctionSystem:DoFunctionCallBack(_task.Data.Cfg.OpenPanel, nil)
                            end
                        end
                    end
                    GameCenter.LuaTaskManager.CurSelectTaskID = self.Id
                end
            end
        end

        function TaskOpenUI:OnIsTalkToNpc()
            local _ret = false
            local _task = GameCenter.LuaTaskManager.TaskContainer:FindTakByID(self.Id)
            if _task ~= nil then
                if _task.Data.Type == TaskType.Main or _task.Data.Type == TaskType.Prison then
                    if not GameCenter.LuaTaskManager:CanSubmitTask(_task.Data.Id) then
                        local _value = _task.Data.Cfg.OpenNpcPanel
                        if _value == 1 then
                            _ret = true
                        else
                            _ret = false
                        end
                    end
                elseif _task.Data.Type == TaskType.Guild then
                    if not GameCenter.LuaTaskManager:CanSubmitTask(_task.Data.Id) then
                        local _value = _task.Data.Cfg.OpenNpcPanel
                        if _value == 1 then
                            _ret = true
                        else
                            _ret = false
                        end
                    end
                end
            end
            return _ret
        end

return TaskOpenUI
