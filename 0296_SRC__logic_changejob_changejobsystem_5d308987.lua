------------------------------------------------
-- Author: 
-- Date: 2020-07-03
-- File: ChangeJobSystem.lua
-- Module: ChangeJobSystem
-- Description: Transfer system
------------------------------------------------
local L_RoleBaseAttribute = CS.Thousandto.Code.Global.RoleBaseAttribute

local ChangeJobSystem = {
    -- Tasks for transfer grades
    TaskLevelTable = nil,
    -- Task List
    TaskList = nil,
    -- Transfer settlement task id
    EndIds = nil,
    
    -- Current job transfer configuration
    CurCfg = nil,
    -- Current job transfer task
    CurTask = nil,
    -- Do you need to refresh
    IsRefresh = false,
    -- Complete the price with one click
    OneKeyPrice = 0,

    -- The current total number of tasks
    CurTaskCount = 0,
    -- Current task index
    CurTaskIndex = 0,

    -- Preview realm data
    PreviewJobID = nil,
    PreviewNeedLevel = nil,
    PreviewFuncID = nil,
    PreviewFuncParam = nil,
    PreviewTips = nil,

    -- Have you received a new job transfer task?
    IsNewGetTask = false,
}

-- initialization
function ChangeJobSystem:Initialize()
    self.IsRefresh = false
    GameCenter.RegFixEventHandle(LogicLuaEventDefine.EID_EVENT_CHANJEJOB_TASK_UPDATED, self.OnChangeJobTaskChange, self)
end

-- De-initialization
function ChangeJobSystem:UnInitialize()
    GameCenter.UnRegFixEventHandle(LogicLuaEventDefine.EID_EVENT_CHANJEJOB_TASK_UPDATED, self.OnChangeJobTaskChange, self)
end

-- Determine whether it is a marrow cleaning task
function ChangeJobSystem:IsXiSuiTask(task)
    if task == nil then
        return false
    end

    if task.OpenUI == FunctionStartIdCode.RealmXiSui or task.OpenUI == FunctionStartIdCode.RealmXiSuiLv1 or
        task.OpenUI == FunctionStartIdCode.RealmXiSuiLv2 or task.OpenUI == FunctionStartIdCode.RealmXiSuiLv3 or
        task.OpenUI == FunctionStartIdCode.RealmXiSuiLv4 or task.OpenUI == FunctionStartIdCode.RealmXiSuiLv5 then
         -- Marrow cleaning task
         return true
    end
    return false
end

function ChangeJobSystem:OnChangeJobTaskChange(isNewTask, sender)
    self.IsNewGetTask = isNewTask
    if self.TaskLevelTable == nil then
        self.TaskLevelTable = {}
        self.EndIds = {}
        self.TaskList = {}
        DataConfig.DataChangejob:Foreach(function(k, v)
            local _params = Utils.SplitNumber(v.TaskGroup, '_')
            self.TaskList[k] = _params
            local _count = #_params
            for i = 1, _count do
                self.TaskLevelTable[_params[i]] = v
                if i >= _count then
                    self.EndIds[_params[i]] = k
                end
            end
        end)
    end
    self.IsRefresh = true
end

function ChangeJobSystem:OnXiSuiLevelChanged()
    self.IsRefresh = true
end

function ChangeJobSystem:Update(dt)
    if self.IsRefresh and self.TaskLevelTable ~= nil then
        self.IsRefresh = false

        self.OneKeyPrice = 0
        self.CurTask = GameCenter.LuaTaskManager:GetTransferTask()
        -- Debug.Log("yy ChangeJobSystem:Update curTask")
        -- Debug.LogTable(self.CurTask)
        local _taskId = 0
        if self.CurTask ~= nil then
            _taskId = self.CurTask.Data.Id
        end
        -- Debug.Log("yy taskid "..tostring(_taskId))
        -- Debug.Log("yy TaskLevelTable")
        -- Debug.LogTable(self.TaskLevelTable)
        self.CurCfg = self.TaskLevelTable[_taskId]
        -- Debug.Log("yy curCfg "..tostring(self.CurCfg))
        if self.CurCfg == nil or self.CurTask == nil then
            -- There is currently no job transfer task, turn off the function
            GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.ChangeJob, false)
            -- Turn off marrow cleaning function
            GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.RealmXiSui, false)
            GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.RealmXiSuiLv1, false)
            GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.RealmXiSuiLv2, false)
            GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.RealmXiSuiLv3, false)
            GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.RealmXiSuiLv4, false)
            GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.RealmXiSuiLv5, false)

            local _previewSucc = false
            local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
            if _lp ~= nil then
                local _previewId = _lp.ChangeJobLevel + 1
                if _previewId ~= self.PreviewJobID then
                    local _cfg = DataConfig.DataChangejob[_previewId]
                    if _cfg ~= nil and string.len(_cfg.UnLockFunction) > 0 then
                        local _funcParams = Utils.SplitStr(_cfg.UnLockFunction, ';')
                        local _funcLevel = tonumber(_funcParams[1])
                        local _funcId = tonumber(_funcParams[2])
                        local _funcParam = tonumber(_funcParams[3])
                        local _funcTips = _funcParams[6]
                        if _funcLevel ~= nil and _funcId ~= nil and _funcParam ~= nil and _funcTips ~= nil then
                            _previewSucc = true
                            self.PreviewJobID = _previewId
                            self.PreviewNeedLevel = _funcLevel
                            self.PreviewFuncID = _funcId
                            self.PreviewFuncParam = _funcParam
                            self.PreviewTips = _funcTips
                            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_CJ_PREVIEW)
                        end
                    end
                else
                    _previewSucc = true
                end
            end
            if not _previewSucc then
                local _oldPreview = self.PreviewJobID
                -- Clear preview realm data
                self.PreviewJobID = nil
                self.PreviewNeedLevel = nil
                self.PreviewFuncID = nil
                self.PreviewFuncParam = nil
                self.PreviewTips = nil
                if _oldPreview ~= nil then
                    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_CJ_PREVIEW)
                end
            end
        else
      
            local _oldPreview = self.PreviewJobID
            -- Clear preview realm data
            self.PreviewJobID = nil
            self.PreviewNeedLevel = nil
            self.PreviewFuncID = nil
            self.PreviewFuncParam = nil
            self.PreviewTips = nil
            if _oldPreview ~= nil then
                GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_CJ_PREVIEW)
            end
            -- There is currently a job transfer task, enable function
            GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.ChangeJob, true)
            GameCenter.MainFunctionSystem:SetFunctionLittleName(FunctionStartIdCode.ChangeJob, self.CurCfg.MainLittleName)

            local _taskCfg = DataConfig.DataTaskGender[_taskId]
            local _jinduTable = Utils.SplitNumber(_taskCfg.Chapterprogr, '_')
            self.CurTaskIndex = _jinduTable[1]
            self.CurTaskCount = _jinduTable[2]
            if self.EndIds[_taskId] ~= nil then
                -- It's the last task, displaying red dots
                GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.ChangeJob, true)
                self.CurTaskIndex = self.CurTaskCount
            else
                -- Determine whether the current task has been completed
                if GameCenter.LuaTaskManager:CanSubmitTask(_taskId) then
                    -- Completed, can be submitted
                    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.ChangeJob, true)
                    self.OneKeyPrice = 0
                else
                    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.ChangeJob, false)
                    self.OneKeyPrice = _taskCfg.SkipCost
                    if self:IsXiSuiTask(_taskCfg) then
                        -- Marrow cleaning task, plus marrow cleaning price
                        self.OneKeyPrice = self.OneKeyPrice + GameCenter.RealmXiSuiSystem:GetXiSuiPrice()
                    end
                end
                if self.CurTaskIndex > 0 then
                    self.CurTaskIndex = self.CurTaskIndex - 1
                end
                local _taskList = self.TaskList[self.CurCfg.Id]
                local _addPrice = false
                local _allTaskCount = #_taskList
                for i = 1, _allTaskCount do
                    if _taskList[i] == _taskId then
                        _addPrice = true
                    end
                    if _taskList[i] ~= _taskId and _addPrice then
                        local _cfg = DataConfig.DataTaskGender[_taskList[i]]
                        self.OneKeyPrice = self.OneKeyPrice + _cfg.SkipCost
                        if self:IsXiSuiTask(_cfg) then
                            -- Marrow cleaning task, plus marrow cleaning price
                            self.OneKeyPrice = self.OneKeyPrice + GameCenter.RealmXiSuiSystem:GetXiSuiPrice()
                        end
                    end
                end
            end

            if self:IsXiSuiTask(_taskCfg) and not GameCenter.LuaTaskManager:CanSubmitTask(_taskId) then
                GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.RealmXiSui, true)
                GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.RealmXiSuiLv1, FunctionStartIdCode.RealmXiSuiLv1 == _taskCfg.OpenUI)
                GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.RealmXiSuiLv2, FunctionStartIdCode.RealmXiSuiLv2 == _taskCfg.OpenUI)
                GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.RealmXiSuiLv3, FunctionStartIdCode.RealmXiSuiLv3 == _taskCfg.OpenUI)
                GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.RealmXiSuiLv4, FunctionStartIdCode.RealmXiSuiLv4 == _taskCfg.OpenUI)
                GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.RealmXiSuiLv5, FunctionStartIdCode.RealmXiSuiLv5 == _taskCfg.OpenUI)
                if self.IsNewGetTask then
                    if FunctionStartIdCode.RealmXiSuiLv1 == _taskCfg.OpenUI then
                        GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.RealmXiSuiLv1)
                    elseif FunctionStartIdCode.RealmXiSuiLv2 == _taskCfg.OpenUI then
                        GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.RealmXiSuiLv2)
                    elseif FunctionStartIdCode.RealmXiSuiLv3 == _taskCfg.OpenUI then
                        GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.RealmXiSuiLv3)
                    elseif FunctionStartIdCode.RealmXiSuiLv4 == _taskCfg.OpenUI then
                        GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.RealmXiSuiLv4)
                    elseif FunctionStartIdCode.RealmXiSuiLv5 == _taskCfg.OpenUI then
                        GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.RealmXiSuiLv5)
                    end
                end
            else
                GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.RealmXiSui, false)
                GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.RealmXiSuiLv1, false)
                GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.RealmXiSuiLv2, false)
                GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.RealmXiSuiLv3, false)
                GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.RealmXiSuiLv4, false)
                GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.RealmXiSuiLv5, false)
            end
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_CHANGEJOB_FORM)
        end
    end
end

return ChangeJobSystem