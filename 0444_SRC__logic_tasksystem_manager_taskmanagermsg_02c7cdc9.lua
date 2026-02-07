------------------------------------------------
-- Author: Wang Sheng
-- Date: 2021-03-19
-- File: TaskManagerMsg.lua
-- Module: TaskManagerMsg
-- Description: Task message
------------------------------------------------
-- Quote
local TaskManagerMsg = {
    SyncTime = 0,
    IsReceiveTaskList = false,
}

function TaskManagerMsg:Initialize()
    self.IsReceiveTaskList = false
end

function TaskManagerMsg:UnInitialize()
    self.IsReceiveTaskList = false
end

-- Request to complete the task
function TaskManagerMsg:ReqTaskFinish(data)
    if data == nil then
        return
    end
    local _msgData = nil
    if data.SubType ~= nil then
        _msgData = {
            type = data.Type,
            modelId = data.TagId,
            taskId = data.Id,
            rewardPer = 0,
            subType = data.SubType
        }
    else
        _msgData = {
            type = data.Type,
            modelId = data.TagId,
            taskId = data.Id,
            rewardPer = 0
        }
    end
    GameCenter.Network.Send("MSG_Task.ReqTaskFinish", _msgData)
end

-- Request to give up the task
function TaskManagerMsg:GiveUpTask(data)
    if data == nil then
        return
    end
    GameCenter.Network.Send("MSG_Task.ReqGiveUpTask", {taskId = data.Id, type = data.Type, modelId = 0})
end

-- Request to refresh the Immortal Alliance mission
function TaskManagerMsg:ReqRefreashXmTask(gold)
    GameCenter.Network.Send("MSG_Task.ReqRefreshGuildTaskPool", {
        useGold = gold
    })
end

-- Request to receive a task
function TaskManagerMsg:ReqAccessTask(id)
    local _task = GameCenter.LuaTaskManager:GetTask(id)
    GameCenter.Network.Send("MSG_Task.ReqReceiveTask", {
        taskId = id,
        type = _task.Data.Type,
        subType = _task.Data.SubType
    })
end

-- Star Up
function TaskManagerMsg:ReqDailyUpStar(id)
    GameCenter.Network.Send("MSG_Task.ReqDailyUpStar", {
        modelId = id
    })
end

-- Prison Star Up
function TaskManagerMsg:ReqPrisonDailyUpStar(id)
    GameCenter.Network.Send("MSG_Task.ReqPrisonDailyUpStar", {
        modelId = id
    })
end

-- Complete the current task with one click
function TaskManagerMsg:ReqOneKeyOverTask(task)
    if task ~= nil then
        GameCenter.Network.Send("MSG_Task.ReqOneKeyOverTask", {
            type = task.Data.Type,
            taskModelId = task.Data.Id,
            subType = task.Data.SubType
        })
    end
end

-- Complete all tasks in one click
function TaskManagerMsg:ReqQuickFinish(type1, type2)
    GameCenter.Network.Send("MSG_Task.ReqQuickFinish", {
        type = type1,
        subType = type2
    })
end

-- Whether the request task is completed
function TaskManagerMsg:ReqCheckTaskIsFinish(ty, id)
    GameCenter.Network.Send("MSG_Task.ReqCheckTaskIsFinish", {
        type = ty,
        taskId = id
    })
end

-- Request a refresh task
function TaskManagerMsg:ReqRefreshTask(ty)
    GameCenter.Network.Send("MSG_Task.ReqRefreshTask", {
        type = ty
    })
end

-- Request a task status change
function TaskManagerMsg:ReqChangeTaskState(ty, id)
    GameCenter.Network.Send("MSG_Task.ReqChangeTaskState", {
        type = ty,
        modelId = id
    })
end

-- Server message returns
function TaskManagerMsg:OnAcceptTask(id)
    -- Boot detection
    GameCenter.GuideSystem:Check(GuideTriggerType.TaskAccept, id)
end

-- Request for daily tasks rewards
function TaskManagerMsg:ReqDailyTaskCountReward(num)
    GameCenter.Network.Send("MSG_Task.ReqDailyTaskCountReward", {
        count = num
    })
end

-- Request for prison daily tasks rewards
function TaskManagerMsg:ReqDailyPrisonTaskCountReward(num)
    Debug.Log("Request for prison daily tasks rewards:" .. tostring(num))
    GameCenter.Network.Send("MSG_Task.ReqDailyPrisonTaskCountReward", {
        count = num
    })
end

-- / <summary>
-- / Task data
-- / </summary>
-- / <param name="result"></param>
function TaskManagerMsg:GS2U_ResTaskList(result)
    GameCenter.LuaTaskManager:ClearTask()
    -- daily
    if result.dailyTask ~= nil and #result.dailyTask > 0 then
        GameCenter.LuaTaskManager:CreateDailyTask(result.dailyTask)
    end
    -- Side line
    if result.branchTask ~= nil and #result.branchTask > 0 then
        GameCenter.LuaTaskManager:CreateBranchTask(result.branchTask)
    end
    -- Gang
    if result.conquerTask ~= nil and #result.conquerTask > 0 then
        GameCenter.LuaTaskManager:CreateGuildTask(result.conquerTask)
    end
    -- Transfer
    if result.genderTask ~= nil and #result.genderTask > 0 then
        GameCenter.LuaTaskManager:CreateTransferTask(result.genderTask)
    end
    -- Battlefield missions
    if result.battleFieldTask ~= nil and #result.battleFieldTask > 0 then
        GameCenter.LuaTaskManager:CreateBattleTask(result.battleFieldTask)
    end
    -- New side missions
    if result.loopTask ~= nil and #result.loopTask > 0 then
        GameCenter.LuaTaskManager:CreateLoopTask(result.loopTask)
    end
    -- Main line
    if result.mainTask ~= nil then
        GameCenter.LuaTaskManager:CreateMainTask(result.mainTask)
        if result.mainTask.overIDs ~= nil then
            for i = 1, #result.mainTask.overIDs do
                GameCenter.LuaTaskManager:PushOverId(result.mainTask.overIDs[i])
            end
        end 
    end
    -- Prison line
    if result.prisonTask ~= nil then
        GameCenter.LuaTaskManager:CreatePrisonTask(result.prisonTask)
        if result.prisonTask.overIDs ~= nil then
            for i = 1, #result.prisonTask.overIDs do
                GameCenter.LuaTaskManager:PushPrisonOverId(result.prisonTask.overIDs[i])
            end
        end 
    end
    -- Prison daily
    if result.dailyPrisonTask ~= nil and #result.dailyPrisonTask > 0 then
        GameCenter.LuaTaskManager:CreateDailyPrisonTask(result.dailyPrisonTask)
    end
    if GameCenter.LuaTaskManager.DailyBoxState == nil then
        GameCenter.LuaTaskManager.DailyBoxState = Dictionary:New()
        GameCenter.LuaTaskManager.DailyBoxState:Add(10, false)
        GameCenter.LuaTaskManager.DailyBoxState:Add(20, false)
    end
    if result.countRewardList ~= nil then
        for i = 1, #result.countRewardList do
            local _rewardInfo = result.countRewardList[i]
            GameCenter.LuaTaskManager.DailyBoxState[_rewardInfo.count] = _rewardInfo.isReward
        end
    end
    if GameCenter.LuaTaskManager.PrisonDailyBoxState == nil then
        GameCenter.LuaTaskManager.PrisonDailyBoxState = Dictionary:New()
        GameCenter.LuaTaskManager.PrisonDailyBoxState:Add(10, false)
        GameCenter.LuaTaskManager.PrisonDailyBoxState:Add(20, false)
    end
    if result.countPrisonRewardList ~= nil then
        for i = 1, #result.countPrisonRewardList do
            local _rewardInfo = result.countPrisonRewardList[i]
            GameCenter.LuaTaskManager.PrisonDailyBoxState[_rewardInfo.count] = _rewardInfo.isReward
        end
    end
    GameCenter.LuaTaskManager.XmReciveCount = result.guildReceiveCount
    GameCenter.LuaTaskManager.XmRefreashCount = result.guildRefreshCount
    GameCenter.LuaTaskManager.TransferTaskStep = result.overGenderTaskCount
    GameCenter.LuaTaskManager.BattleTaskStep = result.nowBattleTaskCount
    GameCenter.LuaTaskManager.BattleTaskFreeCount = result.remainFreeFreshCount
    GameCenter.LuaTaskManager.HuSongLeftCount = result.remainEscortTaskCount
    GameCenter.LuaTaskManager.BattleTaskFreshTime = result.autoFreshRemainTime
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_TASKINIT)
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_TASKCHANG)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_CHANJEJOB_TASK_UPDATED)
    self.IsReceiveTaskList = true
end

-- / <summary>
-- / Mission completion
-- / </summary>
-- / <param name="result"></param>
function TaskManagerMsg:GS2U_ResTaskFinish(result)
    GameCenter.LuaTaskManager:CheckClearPrisonOverIdList(result)

    if not result.submitResult then
        GameCenter.PushFixEvent(UIEventDefine.UINpcTalkForm_CLOSE)
        return
    end
    if result.state == 3 then -- The task does not exist
        -- The client directly deletes the non-existent task
        GameCenter.LuaTaskManager:RemoveTask(result.modelId)
        -- Task changes
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_TASKCHANG)
        if DataConfig.DataTaskGender[result.modelId] ~= nil then
            -- Deleted job transfer task
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_CHANJEJOB_TASK_UPDATED)
        end
        return
    end
    -- Statistical tasks completed
    GameCenter.SDKSystem:SendEventTaskFinsh(result.modelId, result.type == TaskType.Main and "main" or "branch")
    GameCenter.LuaTaskManager:SetLoopTaskStep(result.type, result.currentCount)
    GameCenter.LuaTaskManager:CompeletTask(result)
    if result.finshType == 1 then
        -- Complete with one click
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_TASKFINISH_ONEKEY)
    end
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_TASKINIT)
    -- Task changes
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_TASKCHANG)
    -- Task completion
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_TASKFINISH, result.modelId)
    if DataConfig.DataTaskGender[result.modelId] ~= nil then
        -- Complete the job transfer task
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_CHANJEJOB_TASK_UPDATED)
    end
    -- Boot detection
    GameCenter.GuideSystem:Check(GuideTriggerType.TaskEnd, result.modelId)
end

-- Delete a task
function TaskManagerMsg:GS2U_ResTaskDelete(result)
    GameCenter.LuaTaskManager:RemoveTask(result.modelId)
    GameCenter.PushFixEvent(UIEventDefine.UINpcTalkForm_CLOSE)
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_TASKCHANG)
    if DataConfig.DataTaskGender[result.modelId] ~= nil then
        -- Deleted job transfer task
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_CHANJEJOB_TASK_UPDATED)
    end
end

-- / <summary>
-- / Main task changes
-- / </summary>
-- / <param name="result"></param>
function TaskManagerMsg:GS2U_ResMainTaskChange(result)
    if not self.IsReceiveTaskList then
        return
    end
    local _value = GameCenter.LuaTaskManager.TaskContainer.Container[TaskType.Main]
    if _value ~= nil then
        local _task = GameCenter.LuaTaskManager.TaskContainer:FindTakByID(result.mainTask.modelId)
        if _task == nil then
            -- There is only one main task to clear the rest of the cache and create one main task
            GameCenter.LuaTaskManager.TaskContainer:Remove(TaskType.Main)
            GameCenter.LuaTaskManager:CreateMainTask(result.mainTask)
            self:OnAcceptTask(result.mainTask.modelId)
        else
            -- Update the main task
            GameCenter.LuaTaskManager:UpdateMainTask(result, _task)
        end
    else
        -- No main task Create main task
        GameCenter.LuaTaskManager:CreateMainTask(result.mainTask)
        self:OnAcceptTask(result.mainTask.modelId)
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_GETNEWTASK, result.mainTask.modelId)
    end
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_TASKCHANG)
end

-- / <summary>
-- / Daily tasks change
-- / </summary>
-- / <param name="result"></param>
function TaskManagerMsg:GS2U_ResDailyTaskChang(result)
    if not self.IsReceiveTaskList then
        return
    end
    local _task = GameCenter.LuaTaskManager.TaskContainer:FindByTypeAndID(TaskType.Daily, result.dailyTask.modelId)
    if _task ~= nil then
        -- Update daily tasks
        GameCenter.LuaTaskManager:UpdateDailyTask(result, _task)
    else
        -- No daily tasks Create daily tasks
        local _list = List:New()
        _list:Add(result.dailyTask)
        if not result.isAuto then
            GameCenter.LuaTaskManager.IsAutoDailyTask = false
        end
        GameCenter.LuaTaskManager:CreateDailyTask(_list)
        self:OnAcceptTask(result.dailyTask.modelId)
    end
    GameCenter.PushFixEvent(UIEventDefine.UINpcTalkForm_CLOSE)
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_TASKCHANG, result.dailyTask)
end

-- / <summary>
-- / PrisonDaily tasks change
-- / </summary>
-- / <param name="result"></param>
function TaskManagerMsg:GS2U_ResDailyPrisonTaskChange(result)
    Debug.LogTable(result, "GS2U_ResDailyPrisonTaskChange")
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp ~= nil and not _lp.IsInPrison then 
        return 
    end

    if not self.IsReceiveTaskList then
        return
    end
    local _task = GameCenter.LuaTaskManager.TaskContainer:FindByTypeAndID(TaskType.DailyPrison, result.dailyPrisonTask.modelId)
    if _task ~= nil then
        -- Update daily prison tasks
        GameCenter.LuaTaskManager:UpdateDailyPrisonTask(result, _task)
    else
        -- No daily prison tasks Create daily tasks
        local _list = List:New()
        _list:Add(result.dailyPrisonTask)
        if not result.isAuto then
            GameCenter.LuaTaskManager.IsAutoDailyPrisonTask = false
        end
        GameCenter.LuaTaskManager:CreateDailyPrisonTask(_list)
        self:OnAcceptTask(result.dailyPrisonTask.modelId)
    end
    if not result.dailyPrisonTask.isReceive then
        Debug.Log("Auto receive prison daily task")
        self:ReqAccessTask(result.dailyPrisonTask.modelId)
    end
    GameCenter.PushFixEvent(UIEventDefine.UINpcTalkForm_CLOSE)
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_TASKCHANG, result.dailyPrisonTask)
end

-- Guild Task Changes
function TaskManagerMsg:GS2U_ResGuildTaskChang(result)
    if not self.IsReceiveTaskList then
        return
    end
    if not GameCenter.LuaTaskManager.IsAutoGuildTask then
        GameCenter.LuaTaskManager.IsAutoGuildTask = true
    end
    local _task = GameCenter.LuaTaskManager.TaskContainer:FindByTypeAndID(TaskType.Guild, result.questsTask.modelId)
    if _task == nil then
        if GameCenter.LuaTaskManager:IsInNotRecieveContainer(result.questsTask.modelId) then
            -- The player takes the initiative to receive the task and removes the task container without the task. Execute the task behavior.
            GameCenter.LuaTaskManager:RemoveTaskInNotRecieve(result.questsTask.modelId)
        end
        -- There is only one union task task to clear the rest of the cache and create a main task
        GameCenter.LuaTaskManager.TaskContainer:Remove(TaskType.Guild)
        local _list = List:New()
        _list:Add(result.questsTask)
        GameCenter.LuaTaskManager:CreateGuildTask(_list)
        self:OnAcceptTask(result.questsTask.modelId)
    else
        -- Update daily tasks
        GameCenter.LuaTaskManager:UpdateGuildTask(result, _task)
    end
    GameCenter.PushFixEvent(UIEventDefine.UINpcTalkForm_CLOSE)
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_TASKCHANG, result.questsTask)
    if result.questsTask.isReceive and not GameCenter.LuaTaskManager:CanSubmitTask(result.questsTask.modelId) then
        GameCenter.PushFixEvent(UIEventDefine.UIGuildNewForm_CLOSE)
        GameCenter.PushFixEvent(UIEventDefine.UIGuildTaskGetForm_Close)
        GameCenter.LuaTaskManager.XmReciveCount = GameCenter.LuaTaskManager.XmReciveCount + 1
    end
end

-- Immortal Alliance Mission Refresh Message Change
function TaskManagerMsg:GS2U_ResGuildTaskPool(result)
    if not self.IsReceiveTaskList then
        return
    end
    if result == nil then
        return
    end
    -- Clear previously saved unaccepted Immortal Alliance missions
    GameCenter.LuaTaskManager:ClearXmTasks()
    GameCenter.LuaTaskManager.XmRefreashCount = result.refreshCount
    GameCenter.LuaTaskManager.XmReciveCount = result.receiveCount
    if result.taskList ~= nil then
        for i = 1, #result.taskList do
            local _task =
                GameCenter.LuaTaskManager.TaskContainer:FindByTypeAndID(TaskType.Guild, result.taskList[i].modelId)
            if _task == nil then
                -- There is only one daily task task to clear the rest of the cache and create a main task
                GameCenter.LuaTaskManager.TaskContainer:Remove(TaskType.Guild)
                local _list = List:New()
                _list:Add(result.taskList[i])
                GameCenter.LuaTaskManager:CreateGuildTask(_list)
                self:OnAcceptTask(result.taskList[i].modelId)
            else
                GameCenter.LuaTaskManager:UpdateGuildTask(result.taskList[i], _task)
            end
            GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_TASKCHANG, result.taskList[i])
        end
    end
    GameCenter.PushFixEvent(UIEventDefine.UINpcTalkForm_CLOSE)
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_GUILDTASKLIST_UPDATE)
end

-- Side Quest Changes
function TaskManagerMsg:GS2U_ResBranchTaskChang(result)
    if not self.IsReceiveTaskList then
        return
    end
    local _value = GameCenter.LuaTaskManager.TaskContainer.Container[TaskType.Branch]
    if _value ~= nil then
        local _task = GameCenter.LuaTaskManager.TaskContainer:FindTakByID(result.branchTask.modelId)
        if _task == nil then
            local _list = List:New()
            _list:Add(result.branchTask)
            GameCenter.LuaTaskManager:CreateBranchTask(_list)
            self:OnAcceptTask(result.branchTask.modelId)
        else
            -- Update daily tasks
            GameCenter.LuaTaskManager:UpdateBranchTask(result, _task)
        end
    else
        -- No daily tasks Create daily tasks
        local _list = List:New()
        _list:Add(result.branchTask)
        GameCenter.LuaTaskManager:CreateBranchTask(_list)
        self:OnAcceptTask(result.branchTask.modelId)
    end
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_TASKCHANG)
end

-- Update on job transfer tasks
function TaskManagerMsg:GS2U_ResGenderTaskChange(result)
    if not self.IsReceiveTaskList then
        return
    end
    local _isNewTask = false
    local _value = GameCenter.LuaTaskManager.TaskContainer.Container[TaskType.ZhuanZhi]
    if _value ~= nil then
        local _task = GameCenter.LuaTaskManager.TaskContainer:FindTakByID(result.genderTask.modelId)
        if _task == nil then
            -- There is only one job transfer task to clear the rest of the cache and create a main task
            GameCenter.LuaTaskManager.TaskContainer:Remove(TaskType.ZhuanZhi)
            local _list = List:New()
            _list:Add(result.genderTask)
            _isNewTask = true
            GameCenter.LuaTaskManager:CreateTransferTask(_list)
            self:OnAcceptTask(result.genderTask.modelId)
        else
            -- Update daily tasks
            GameCenter.LuaTaskManager:UpdateTransferTask(result, _task)
        end
    else
        -- No daily tasks Create daily tasks
        local _list = List:New()
        _list:Add(result.genderTask)
        _isNewTask = true
        GameCenter.LuaTaskManager:CreateTransferTask(_list)
        self:OnAcceptTask(result.genderTask.modelId)
    end
    GameCenter.PushFixEvent(UIEventDefine.UINpcTalkForm_CLOSE)
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_TASKCHANG)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_CHANJEJOB_TASK_UPDATED, _isNewTask)
end

-- / <summary>
-- / Prison task changes
-- / </summary>
-- / <param name="result"></param>
function TaskManagerMsg:GS2U_ResPrisonTaskChange(result)
    if not self.IsReceiveTaskList then
        return
    end
    local _value = GameCenter.LuaTaskManager.TaskContainer.Container[TaskType.Prison]
    if _value ~= nil then
        local _task = GameCenter.LuaTaskManager.TaskContainer:FindTakByID(result.prisonTask.modelId)
        if _task == nil then
            -- There is only one prison task to clear the rest of the cache and create one prison task
            GameCenter.LuaTaskManager.TaskContainer:Remove(TaskType.Prison)
            GameCenter.LuaTaskManager:CreatePrisonTask(result.prisonTask)
            self:OnAcceptTask(result.prisonTask.modelId)
        else
            -- Update the prison task
            GameCenter.LuaTaskManager:UpdatePrisonTask(result, _task)
        end
    else
        -- No prison task Create prison task
        GameCenter.LuaTaskManager:CreatePrisonTask(result.prisonTask)
        self:OnAcceptTask(result.prisonTask.modelId)
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_GETNEWTASK, result.prisonTask.modelId)
    end
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_TASKCHANG)
end

function TaskManagerMsg:ResDailyTaskFinish(msg)
    if msg == nil then
        return
    end
    local _rewards = List:New()
    if msg.rewards ~= nil then
        for i = 1, #msg.rewards do
            local _info = msg.rewards[i]
            local _id = _info.modelId
            local _num = _info.count
            local _itemData = {Id = _id, Num = _num, IsBind = true}
            _rewards:Add(_itemData)
        end
    end
    local _exRewards = List:New()
    if msg.extraRewards ~= nil then
        for i = 1, #msg.extraRewards do
            local _info = msg.extraRewards[i]
            local _id = _info.modelId
            local _num = _info.count
            local _itemData = {Id = _id, Num = _num, IsBind = true}
            _exRewards:Add(_itemData)
        end
    end
    local _finalData = {Rewards = _rewards, ExRewards = _exRewards, Count = msg.taskCount}
    GameCenter.PushFixEvent(UILuaEventDefine.UIDailyTaskFinishForm_OPEN, _finalData)
end

function TaskManagerMsg:ResDailyTaskCountReward(msg)
    if msg == nil then
        return
    end
    --DailyBoxState
    if GameCenter.LuaTaskManager.DailyBoxState == nil then
        GameCenter.LuaTaskManager.DailyBoxState = Dictionary:New()
        GameCenter.LuaTaskManager.DailyBoxState:Add(10, false)
        GameCenter.LuaTaskManager.DailyBoxState:Add(20, false)
    end
    if msg.countReward ~= nil then
        GameCenter.LuaTaskManager.DailyBoxState[msg.countReward.count] = msg.countReward.isReward
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_NEWDAILYTASK_REFRESH)
end

function TaskManagerMsg:ResDailyPrisonTaskFinish(msg)
    Debug.LogTable(msg, "ResDailyPrisonTaskFinish")
    if msg == nil then
        return
    end
    local _rewards = List:New()
    if msg.rewards ~= nil then
        for i = 1, #msg.rewards do
            local _info = msg.rewards[i]
            local _id = _info.modelId
            local _num = _info.count
            local _itemData = {Id = _id, Num = _num, IsBind = true}
            _rewards:Add(_itemData)
        end
    end
    local _exRewards = List:New()
    if msg.extraRewards ~= nil then
        for i = 1, #msg.extraRewards do
            local _info = msg.extraRewards[i]
            local _id = _info.modelId
            local _num = _info.count
            local _itemData = {Id = _id, Num = _num, IsBind = true}
            _exRewards:Add(_itemData)
        end
    end
    local _finalData = {Rewards = _rewards, ExRewards = _exRewards, Count = msg.taskCount}
    GameCenter.PushFixEvent(UILuaEventDefine.UIDailyTaskFinishForm_OPEN, _finalData)
end

function TaskManagerMsg:ResDailyPrisonTaskCountReward(msg)
    Debug.LogTable(msg, "ResDailyPrisonTaskCountReward")
    if msg == nil then
        return
    end
    --PrisonDailyBoxState
    if GameCenter.LuaTaskManager.PrisonDailyBoxState == nil then
        GameCenter.LuaTaskManager.PrisonDailyBoxState = Dictionary:New()
        GameCenter.LuaTaskManager.PrisonDailyBoxState:Add(10, false)
        GameCenter.LuaTaskManager.PrisonDailyBoxState:Add(20, false)
    end
    if msg.countReward ~= nil then
        GameCenter.LuaTaskManager.PrisonDailyBoxState[msg.countReward.count] = msg.countReward.isReward
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_NEWDAILYTASK_REFRESH)
end

return TaskManagerMsg
