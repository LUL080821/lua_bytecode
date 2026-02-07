------------------------------------------------
-- Author: Wang Sheng
-- Date: 2021-03-19
-- File: LuaTaskManager.lua
-- Module: LuaTaskManager
-- Description: lua task management
------------------------------------------------
-- Quote
local L_MainTask = require "Logic.TaskSystem.Instance.MainTask"
local L_DailyTask = require "Logic.TaskSystem.Instance.DailyTask"
local L_GuildTask = require "Logic.TaskSystem.Instance.GuildTask"
local L_BranchTask = require "Logic.TaskSystem.Instance.BranchTask"
local L_TransferTask = require "Logic.TaskSystem.Instance.TransferTask"
local L_PrisonTask = require "Logic.TaskSystem.Instance.PrisonTask"
local L_DailyPrisonTask = require "Logic.TaskSystem.Instance.DailyPrisonTask"

local L_TaskLock = require "Logic.TaskSystem.Manager.TaskLock"
local L_TaskTarget = require "Logic.TaskSystem.Data.TaskTarget"
local L_TaskContainer = require "Logic.TaskSystem.Container.TaskContainer"
local L_BehaviorManager = require "Logic.TaskSystem.Manager.TaskBehaviorManager"

local L_ItemBase = CS.Thousandto.Code.Logic.ItemBase
local L_CSNpcTaskState = CS.Thousandto.Code.Logic.NpcTaskState

local LuaTaskManager = {
    CurSelectTaskID = 0, -- The currently selected task id
    TransferTaskStep = 0, -- Number of loops completed by transfer tasks
    BattleTaskStep = 0, -- Number of completed battlefield missions
    BattleTaskAllStep = 10, -- Total number of battlefield missions
    BattleTaskFreeCount = 0, -- Free number of battlefield mission refreshes
    HuSongLeftCount = 0, -- Number of remaining escort missions
    SelectDailyTaskId = 0, -- Externally selected daily circumference task ID
    WaiteFormId = 0, -- The form ID waiting to close
    BattleTaskFreshTime = 0, -- Battlefield mission refresh time
    SyncTime = 0,
    IsAutoMainTask = false, -- Whether to start the automatic main task
    IsAutoGuildTask = false, -- Whether to start automatic guild tasks
    IsAutoDailyTask = false, -- Whether to start automatic chief tasks
    IsAutoTransferTask = false, -- Whether to start automatic job transfer
    IsAutoBranchExTask = false, -- Whether to start the automatic side loop task
    IsAutoPrisonTask = false, -- Whether to start the automatic prison task
    IsAutoDailyPrisonTask = false, -- Whether to start the automatic prison daily task
    IsAutoTaskForTransPort = false, -- After cutting the map, determine whether to start executing tasks
    IsAutoAccessTaskForTrans = false, -- Cut the map to receive tasks
    IsShowGuide = false, -- Whether to display boot
    IsClickAccessHuSongTask = false, -- Whether to manually receive the escort mission
    IsWiptOutClick = false, -- Click to sweep
    IsStopAllTask = false, -- Whether to stop all tasks that are being executed
    IsLocalUserTeleport = false, -- It is used to transmit on the current map. Otherwise, it is used to use the small flying shoes across the map.
    TaskContainer = nil, -- Task container
    OverTaskIdList = nil,
    OverPrisonTaskIdList = nil,

    OldParam = nil,
    CurSelectDailyTask = nil, -- The currently selected daily task
    TaskBeHaviorManager = nil,
    FlyItemId = 0, -- Little flying shoes prop id
    FlyVip = 0, -- Free use of small flying shoes

    -- Immortal Alliance Mission
    XmRefreashCount = 0, -- The number of times the Immortal Alliance mission can be refreshed
    XmReciveCount = 0, -- The number of times the Immortal Alliance mission can be taken

    LockList = List:New(),

    IsSuspend = false,
    MaxXmTaskCount = 5,
    DailyBoxState = nil,
    PrisonDailyBoxState = nil,
}

function LuaTaskManager:InitiactiveExitPlaneCopy(o, sender)
    -- Players actively click to exit the plane copy
    self.IsStopAllTask = true;
    PlayerBT.ChangeState(PlayerBDState.Default);
end

function LuaTaskManager:WaitCloseForm(o, sender)
    local _id = o;
    if _id == self.WaiteFormId then
        self.IsAutoMainTask = true;
        self.WaiteFormId = 0;
        -- Continue to perform the main task
        GameCenter.TaskController:Run(self:GetMainTaskId());
    end
end

-- Callback after refresh of daily activities
function LuaTaskManager:OnDailyRefresh(o, sender)
    if self.TaskContainer ~= nil then
        self.TaskContainer:UpdateAllTaskTargetDes()
    end
end

function LuaTaskManager:OnCoinChange(o, sender)
    local _type = o;
    if _type == ItemTypeCode.ActivePoint then
        if self.TaskContainer ~= nil then
            self.TaskContainer:UpdateAllTaskTargetDes();
        end
    end
end

-- Change in combat power
function LuaTaskManager:OnFightPowerChange(o, sender)
    if self.TaskContainer ~= nil then
        self.TaskContainer:UpdateFightPowerLimitTask();
    end
end

function LuaTaskManager:IniItialization()
    self.TaskContainer = L_TaskContainer:New();
    self.TaskBeHaviorManager = L_BehaviorManager:New();
    self.TaskBeHaviorManager:IniItialization();
    self.OverTaskIdList = List:New();
    self.OverPrisonTaskIdList = List:New();
    -- Initialize the small flying shoes prop id
    local _gCfg = DataConfig.DataGlobal[GlobalName.FlyShoeID];
    if _gCfg ~= nil then
        self.FlyItemId = tonumber(_gCfg.Params);
    end
    -- Initialize the permissions for using small flying shoes
    DataConfig.DataVip:ForeachCanBreak(function(k, v)
        local _strList = Utils.SplitNumber(v.VipPowerId, '_');
        if _strList ~= nil then
            for i = 1, #_strList do
                local _id = tonumber(_strList[i]);
                if _id == 1 then
                    self.FlyVip = v.VipLevel;
                    return true
                end
            end
        end
    end)
    _gCfg = nil
    -- The maximum number of Immortal Alliance missions collected
    _gCfg = DataConfig.DataGlobal[GlobalName.GuildTaskMax];
    if _gCfg ~= nil then
        local _arr = Utils.SplitStr(_gCfg.Params, ';')
        local _single = Utils.SplitNumber(_arr[#_arr], '_') -- .Split('_');
        if #_single >= 2 then
            self.MaxXmTaskCount = _single[2];
        end
    end
    GameCenter.TimerEventSystem:AddTimeStampDayEvent(5, 10,
    true, nil, function(id, remainTime, param)
        if GameCenter.LuaTaskManager.DailyBoxState ~= nil then
            GameCenter.LuaTaskManager.DailyBoxState[10] = false
            GameCenter.LuaTaskManager.DailyBoxState[20] = false
        end
        if GameCenter.LuaTaskManager.PrisonDailyBoxState ~= nil then
            GameCenter.LuaTaskManager.PrisonDailyBoxState[10] = false
            GameCenter.LuaTaskManager.PrisonDailyBoxState[20] = false
        end
    end)
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_INITIATIVE_EXIT_PLANECOPY, self.InitiactiveExitPlaneCopy, self);
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_FORM_ID_CLOSE_AFTER, self.WaitCloseForm, self);
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_REFRESH_DAILYPANEL, self.OnDailyRefresh, self);
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_REFRESH_ACTIVITYLIST, self.OnDailyRefresh, self);
    GameCenter.RegFixEventHandle(LogicEventDefine.EVENT_COIN_CHANGE_UPDATE, self.OnCoinChange, self);
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_FIGHT_POWER_CHANGED, self.OnFightPowerChange, self);
end

function LuaTaskManager:UnInitialization()
    if self.TaskContainer ~= nil then
        self.TaskContainer:Clear()
    end
    if self.TaskBeHaviorManager ~= nil then
        self.TaskBeHaviorManager:UnIniItialization()
    end
    self.DailyBoxState = nil
    self.PrisonDailyBoxState = nil
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_INITIATIVE_EXIT_PLANECOPY, self.InitiactiveExitPlaneCopy, self);
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_FORM_ID_CLOSE_AFTER, self.WaitCloseForm, self);
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_REFRESH_DAILYPANEL, self.OnDailyRefresh, self);
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_REFRESH_ACTIVITYLIST, self.OnDailyRefresh, self);
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EVENT_COIN_CHANGE_UPDATE, self.OnCoinChange, self);
end

-- Main line
function LuaTaskManager:CreateMainTask(info)
    local _task = L_MainTask:New(info)
    return _task
end

-- daily
function LuaTaskManager:CreateDailyTask(infos)
    local _list = List:New()
    if infos ~= nil then
        for i = 1, #infos do
            local _task = L_DailyTask:New(infos[i], infos[i].isReceive)
            _list:Add(_task)
        end
    end
    return _list
end

-- Gang
function LuaTaskManager:CreateGuildTask(infos)
    local _list = List:New()
    if infos ~= nil then
        for i = 1, #infos do
            local _task = L_GuildTask:New(infos[i], infos[i].isReceive)
            _list:Add(_task)
        end
    end
    return _list
end

-- Side line
function LuaTaskManager:CreateBranchTask(infos)
    if infos ~= nil then
        for i = 1, #infos do
            local _task = L_BranchTask:New(infos[i])
        end
    end
end

-- Transfer
function LuaTaskManager:CreateTransferTask(infos)
    if infos ~= nil then
        for i = 1, #infos do
            local _task = L_TransferTask:New(infos[1], infos[1].isReceive)
        end
    end
end

-- Prison line
function LuaTaskManager:CreatePrisonTask(info)
    local _task = L_PrisonTask:New(info)
    return _task
end

-- Prison daily
function LuaTaskManager:CreateDailyPrisonTask(infos)
    local _list = List:New()
    if infos ~= nil then
        for i = 1, #infos do
            local _task = L_DailyPrisonTask:New(infos[i], infos[i].isReceive)
            _list:Add(_task)
        end
    end
    return _list
end

-- Add completed tasks
function LuaTaskManager:PushOverId(id)
    self.OverTaskIdList:Add(id);
end

-- Add completed tasks prison
function LuaTaskManager:PushPrisonOverId(id)
    self.OverPrisonTaskIdList:Add(id);
end

function LuaTaskManager:CheckClearPrisonOverIdList(msg)
    if msg.type ~= TaskType.Prison then
        return
    end

    local _str = DataConfig.DataGlobal[GlobalName.Prison_Task_End]
    if _str == nil then
        return
    end

    local _strCfg = Utils.SplitNumber(_str.Params, "_")
    if msg.modelId == _strCfg[1] then
        self.OverPrisonTaskIdList:Clear();
    end
end

-- Accept the task
function LuaTaskManager:AccessTask(taskId)
    GameCenter.TaskManagerMsg:ReqAccessTask(taskId);
end

-- Automatic way to get the task
function LuaTaskManager:AutoAccessTask(taskId)
    self.IsAutoAccessTaskForTrans = false;
    self.CurSelectTaskID = taskId;
    local _task = self.TaskContainer:FindTakByID(taskId);
    if _task ~= nil then
        if _task.Data.IsAccess then
            Debug.LogError("The task container data storage error, the task has been received");
            return;
        end
        -- Calling the Npc pathfinding interface
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer();
        if _lp == nil then
            return;
        end
        if _task.Data.MapID ~= GameCenter.MapLogicSystem.MapCfg.MapId then
            -- Send
            if _task.Data.Type ~= TaskType.Guild then
                _lp:Action_CrossMapTran(_task.Data.MapID);
            end

            self.IsAutoAccessTaskForTrans = true; -- If you are too lazy to change your name, it means whether you start performing tasks. Don't care about Main
        else
            local _npcId = _task:GetAccessNpcId(taskId);
            PlayerBT.Task:TaskTalkToNpc(_npcId, _task.Data.Id);
        end
    end
end

-- Submit a task
function LuaTaskManager:SubMitTaskNoParam()
    self:AddLock(self.CurSelectTaskID);
    local _subMitId = self.CurSelectTaskID;
    local _task = self.TaskContainer:FindTakByID(_subMitId);
    if _task ~= nil then
        local _modelId = 0
        local _behavior = self:GetBehavior(_task.Data.Id);
        if _behavior ~= nil then
            _modelId = _behavior.TaskTarget.TagId;
        end
        local _data = {
            Id = _task.Data.Id,
            Type = _task.Data.Type,
            TagId = _modelId,
            SubType = _task.Data.SubType,
            RewardPer = 0
        }
        Debug.LogTable(_data, "SubMitTaskNoParam")
        GameCenter.TaskManagerMsg:ReqTaskFinish(_data)
    end
end

function LuaTaskManager:SubMitTask(id)
    local _task = self:GetTask(id);
    Debug.LogTable(_task.Data, "SubMitTask")
    if _task ~= nil then
        local _modelId = 0
        local _behavior = self:GetBehavior(_task.Data.Id);
        if _behavior ~= nil then
            _modelId = _behavior.TaskTarget.TagId;
        end
        local _data = {
            Id = _task.Data.Id,
            Type = _task.Data.Type,
            TagId = _modelId,
            SubType = nil,
            RewardPer = 1
        }
        Debug.LogTable(_data, "SubMitTask")
        GameCenter.TaskManagerMsg:ReqTaskFinish(_data)
    end
end

-- Submit daily tasks on the UI
function LuaTaskManager:SubMitDailyTaskForUI(task, rewardPer)
    if task ~= nil then
        local _modelId = 0
        local _behavior = self:GetBehavior(task.Data.Id);
        if _behavior ~= nil then
            _modelId = _behavior.TaskTarget.TagId;
        end
        local _data = {
            Id = task.Data.Id,
            Type = task.Data.Type,
            TagId = _modelId,
            SubType = nil,
            RewardPer = rewardPer
        }
        Debug.LogTable(_data, "SubMitDailyTaskForUI")
        GameCenter.TaskManagerMsg:ReqTaskFinish(_data)
    end
end

-- Complete the task
function LuaTaskManager:CompeletTask(msg)
    -- Check whether there are props that need to be displayed
    local _task = self.TaskContainer:FindTakByID(msg.modelId);
    if _task ~= nil then
        if _task.Data.Type == TaskType.Main or _task.Data.Type == TaskType.Prison then
            if _task.Data.Cfg.Type == TaskBeHaviorType.OpenUI then
                -- Pause the main task and wait for the operation UI to close
                if _task.Data.Cfg.CloseNpcPanel ~= 0 then
                    self.IsAutoMainTask = false;
                    self.WaiteFormId = _task.Data.Cfg.CloseNpcPanel * 10;
                end
            elseif _task.Data.Cfg.Type == TaskBeHaviorType.Collection or _task.Data.Cfg.Type == TaskBeHaviorType.Talk then
                local _lpId = GameCenter.GameSceneSystem:GetLocalPlayerID()
                if _lpId ~=nil then
                    GameCenter.LuaCharacterSystem:ClearTaskTransNPC(_lpId)
                    GameCenter.LuaCharacterSystem:ClearTaskTransEquipPlayer(_lpId)
                end
            end
        end

        if _task.Data.Cfg.Type == TaskBeHaviorType.Collection then
            local _behavior = self.TaskBeHaviorManager:GetBehavior(msg.modelId);
            if _behavior ~= nil and _behavior.OnShowGatherModelView then
                _behavior:OnShowGatherModelView()
            end
        end

        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer();
        if _lp == nil then
            return;
        end
        local _curAnim = _lp:GetPlayerAnimState()
        if _curAnim ~= 0 then
            _lp:SetForceAnimId(0)
        end
    end

    -- Remove task
    self:RemoveTaskEx(_task);
    GameCenter.PushFixEvent(UIEventDefine.UINpcTalkForm_CLOSE)
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_TASKCHANG)
end

-- Give up the mission
function LuaTaskManager:GiveUpTask(id, type)
    local _data = {
        Id = id,
        Type = type
    };
    GameCenter.TaskManagerMsg:GiveUpTask(_data)
end

-- Request to refresh the Immortal Alliance mission
function LuaTaskManager:ReqRefreashXmTask(useGold)
    GameCenter.TaskManagerMsg:ReqRefreashXmTask(useGold)
end

-- Main task changes
function LuaTaskManager:UpdateMainTask(msg, task)
    if msg == nil then
        return
    end
    if task == nil then
        return
    end
    -- Update main task data
    local _taskTarget = L_TaskTarget:New();
    -- Update behavior
    local _behavior = self.TaskBeHaviorManager:GetBehavior(task.Data.Id)
    if _behavior ~= nil then
        if _behavior.Type == TaskBeHaviorType.CollectItem then
            GameCenter.PushFixEvent(UIEventDefine.UIMSGTIPS_SHOWINFO,
                L_ItemBase.CreateItemBase(msg.mainTask.useItems.model));
        end
        _taskTarget.TagId = msg.mainTask.useItems.model;
        _taskTarget.Count = msg.mainTask.useItems.num;
        self.TaskBeHaviorManager:UpdateBehavior(_behavior, _taskTarget);
        if _behavior.Type ~= TaskBeHaviorType.Level and _behavior.Type ~= TaskBeHaviorType.OpenUI then
            self.TaskBeHaviorManager:OnDoBehavior(_behavior, task, false, false);
        end
        -- When the main line nests other loop tasks, enforce the main line after the main line meets the submission conditions.
        if _behavior.Type == TaskBeHaviorType.OpenUI then
            if msg.mainTask.useItems.num >= msg.mainTask.useItems.needNum then
                self.TaskBeHaviorManager:OnDoBehavior(_behavior, task, false, false);
            end
        end
        task:UpdateTask(_behavior);
    end
end

-- Update daily tasks
function LuaTaskManager:UpdateDailyTask(msg, task)
    if msg == nil then
        return
    end
    if task == nil then
        return
    end
    local _taskTarget = L_TaskTarget:New();
    task.Data.StarNum = msg.dailyTask.star;
    task.Data.IsFull = msg.dailyTask.isfull;
    task.Data.IsAccess = msg.dailyTask.isReceive;
    task.Data.IsOneKey = msg.dailyTask.oneKeyState;
    task.Data.CurStep = msg.dailyTask.count;
    if task.Data.IsFull then
        if task.Data.Cfg ~= nil then
            task.Data.RewardList:Clear();
            task.Data:SetAwardData(task.Data.Cfg.Rewards5);
        end
    end
    local _behavior = self.TaskBeHaviorManager:GetBehavior(task.Data.Id);
    if _behavior ~= nil then
        _taskTarget.TagId = msg.dailyTask.useItems.model;
        _taskTarget.Count = msg.dailyTask.useItems.num;
        self.TaskBeHaviorManager:UpdateBehavior(_behavior, _taskTarget);
        if _behavior.Type == TaskBeHaviorType.Collection or _behavior.Type == TaskBeHaviorType.KillMonsterDropItem or _behavior.Type == TaskBeHaviorType.KillMonsterTrainMap then
            -- If it is a collection
            self.TaskBeHaviorManager:OnDoBehavior(_behavior, task, false, false);
        end
        task:UpdateTask(_behavior);
    end
end

-- Update gang tasks
function LuaTaskManager:UpdateGuildTask(msg, task)
    if msg == nil then
        return
    end
    if task == nil then
        return
    end
    local _taskTarget = L_TaskTarget:New();
    task.Data.IsAccess = msg.questsTask.isReceive;
    task.Data.Count = msg.questsTask.count;
    local _behavior = self.TaskBeHaviorManager:GetBehavior(task.Data.Id);
    if _behavior ~= nil then
        _taskTarget.TagId = msg.questsTask.monsters.model;
        _taskTarget.Count = msg.questsTask.monsters.num;
        self.TaskBeHaviorManager:UpdateBehavior(_behavior, _taskTarget);
        if _behavior.Type == TaskBeHaviorType.Collection then
            -- If it is a collection
            self.TaskBeHaviorManager:OnDoBehavior(_behavior, task, false, false);
        end
        task:UpdateTask(_behavior);
    end
end

-- Update gang tasks
function LuaTaskManager:UpdateXmGuildTask(info, task)
    if info == nil then
        return
    end
    if task == nil then
        return
    end
    local _taskTarget = L_TaskTarget:New();
    task.Data.IsAccess = info.isReceive;
    task.Data.Count = info.count;
    local _behavior = self.TaskBeHaviorManager:GetBehavior(task.Data.Id);
    if _behavior ~= nil then
        _taskTarget.TagId = info.monsters.model;
        _taskTarget.Count = info.monsters.num;
        self.TaskBeHaviorManager:UpdateBehavior(_behavior, _taskTarget);
        if _behavior.Type == TaskBeHaviorType.Collection then
            -- If it is a collection
            self.TaskBeHaviorManager:OnDoBehavior(_behavior, task, false, false);
        end
        -- GameCenter.TaskBeHaviorManager.DoBehavior(behavior, task, false);
        task:UpdateTask(_behavior);
    end
end

-- Update job transfer tasks
function LuaTaskManager:UpdateTransferTask(msg, task)
    if msg == nil then
        return
    end
    if task == nil then
        return
    end
    local _taskTarget = L_TaskTarget:New();
    -- Update behavior
    local _behavior = self.TaskBeHaviorManager:GetBehavior(task.Data.Id);
    if _behavior ~= nil then
        _taskTarget.TagId = msg.genderTask.target.model;
        _taskTarget.Count = msg.genderTask.target.num;
        self.TaskBeHaviorManager:UpdateBehavior(_behavior, _taskTarget);
        self.TaskBeHaviorManager:OnDoBehavior(_behavior, task, false, false);
        task:UpdateTask(_behavior);
    end
end

-- Update side tasks
function LuaTaskManager:UpdateBranchTask(msg, task)
    if msg == nil then
        return
    end
    if task == nil then
        return
    end
    local _taskTarget = L_TaskTarget:New();
    local _behavior = self.TaskBeHaviorManager:GetBehavior(task.Data.Id);
    if _behavior ~= nil then
        _taskTarget.TagId = msg.branchTask.monsters.model;
        _taskTarget.Count = msg.branchTask.monsters.num;
        self.TaskBeHaviorManager:UpdateBehavior(_behavior, _taskTarget);
        task:UpdateTask(_behavior);
    end
end

-- Update daily prison tasks
function LuaTaskManager:UpdateDailyPrisonTask(msg, task)
    if msg == nil then
        return
    end
    if task == nil then
        return
    end
    local _taskTarget = L_TaskTarget:New();
    task.Data.StarNum = msg.dailyPrisonTask.star;
    task.Data.IsFull = msg.dailyPrisonTask.isfull;
    task.Data.IsAccess = msg.dailyPrisonTask.isReceive;
    task.Data.IsOneKey = msg.dailyPrisonTask.oneKeyState;
    task.Data.CurStep = msg.dailyPrisonTask.count;
    if task.Data.IsFull then
        if task.Data.Cfg ~= nil then
            task.Data.RewardList:Clear();
            task.Data:SetAwardData(task.Data.Cfg.Rewards5);
        end
    end
    local _behavior = self.TaskBeHaviorManager:GetBehavior(task.Data.Id);
    if _behavior ~= nil then
        _taskTarget.TagId = msg.dailyPrisonTask.useItems.model;
        _taskTarget.Count = msg.dailyPrisonTask.useItems.num;
        self.TaskBeHaviorManager:UpdateBehavior(_behavior, _taskTarget);
        if _behavior.Type == TaskBeHaviorType.Collection or _behavior.Type == TaskBeHaviorType.KillMonsterDropItem or _behavior.Type == TaskBeHaviorType.KillMonsterTrainMap then
            -- If it is a collection
            self.TaskBeHaviorManager:OnDoBehavior(_behavior, task, false, false);
        end
        task:UpdateTask(_behavior);
    end
end

-- Update guidance tasks
function LuaTaskManager:UpdatePrompteTask(msg, task)
end

-- Update battlefield missions
function LuaTaskManager:UpdateBattleTask(info, task)
end

-- Update new side missions
function LuaTaskManager:UpdateBranchTaskEx(msg, task)
end

-- Update escort missions
function LuaTaskManager:UpdateHuSongTask(result, task)
end

-- Prison task changes
function LuaTaskManager:UpdatePrisonTask(msg, task)
    if msg == nil then
        return
    end
    if task == nil then
        return
    end
    -- Update main task data
    local _taskTarget = L_TaskTarget:New();
    -- Update behavior
    local _behavior = self.TaskBeHaviorManager:GetBehavior(task.Data.Id)
    if _behavior ~= nil then
        if _behavior.Type == TaskBeHaviorType.CollectItem then
            GameCenter.PushFixEvent(UIEventDefine.UIMSGTIPS_SHOWINFO, L_ItemBase.CreateItemBase(msg.prisonTask.useItems.model));
        end
        _taskTarget.TagId = msg.prisonTask.useItems.model;
        _taskTarget.Count = msg.prisonTask.useItems.num;
        self.TaskBeHaviorManager:UpdateBehavior(_behavior, _taskTarget);
        if _behavior.Type ~= TaskBeHaviorType.Level and _behavior.Type ~= TaskBeHaviorType.OpenUI then
            self.TaskBeHaviorManager:OnDoBehavior(_behavior, task, false, false);
        end
        -- When the main line nests other loop tasks, enforce the main line after the main line meets the submission conditions.
        if _behavior.Type == TaskBeHaviorType.OpenUI then
            if msg.prisonTask.useItems.num >= msg.prisonTask.useItems.needNum then
                self.TaskBeHaviorManager:OnDoBehavior(_behavior, task, false, false);
            end
        end
        task:UpdateTask(_behavior);
    end
end

-- Add a task
function LuaTaskManager:AddTask(task)
    if self.TaskContainer ~= nil then
        self.TaskContainer:Add(task.Data.Type, task);
    end
end

-- Add a task
function LuaTaskManager:AddTaskByType(type, task)
    if self.TaskContainer ~= nil then
        self.TaskContainer:Add(type, task)
    end
end

function LuaTaskManager:RemoveTask(taskId)
    local _task = self.TaskContainer:FindTakByID(taskId);
    if _task ~= nil then
        if _task.Data.Type == TaskType.Main then
            if not self.IsAutoMainTask then
                self.IsAutoMainTask = true;
            end
            self:PushOverId(taskId);
        elseif _task.Data.Type == TaskType.Guild then
            if not self.IsAutoGuildTask then
                self.IsAutoGuildTask = true;
            end
        elseif _task.Data.Type == TaskType.Daily then
            if not self.IsAutoDailyTask then
                self.IsAutoDailyTask = true;
            end
        elseif _task.Data.Type == TaskType.ZhuanZhi then
            if not self.IsAutoTransferTask then
                self.IsAutoTransferTask = true;
            end
        elseif _task.Data.Type == TaskType.NewBranch then
            if not self.IsAutoBranchExTask then
                self.IsAutoBranchExTask = true;
            end
        elseif _task.Data.Type == TaskType.Prison then
            -- if not self.IsAutoPrisonTask then
            --     self.IsAutoPrisonTask = true;
            -- end
            self:PushPrisonOverId(taskId);
        elseif _task.Data.Type == TaskType.DailyPrison then
            -- if not self.IsAutoDailyPrisonTask then
            --     self.IsAutoDailyPrisonTask = true;
            -- end
        end
    end
    self.TaskContainer:Remove(taskId);
    self.TaskBeHaviorManager:RmoveBehavior(taskId);
    self.CurSelectTaskID = 0;
end

function LuaTaskManager:RemoveTaskEx(task)
    if task ~= nil then
        if task.Data.Type == TaskType.Main then
            if not self.IsAutoMainTask and self.WaiteFormId == 0 then
                self.IsAutoMainTask = true;
            end
            self:PushOverId(task.Data.Id);
        elseif task.Data.Type == TaskType.Guild then
            if not self.IsAutoGuildTask then
                self.IsAutoGuildTask = true;
            end
        elseif task.Data.Type == TaskType.Daily then
            if not self.IsAutoDailyTask then
                self.IsAutoDailyTask = true;
            end
        elseif (task.Data.Type == TaskType.ZhuanZhi) then
            if (not self.IsAutoTransferTask) then
                self.IsAutoTransferTask = true;
            end
        elseif task.Data.Type == TaskType.NewBranch then
            if (not self.IsAutoBranchExTask) then
                self.IsAutoBranchExTask = true;
            end
        elseif task.Data.Type == TaskType.Prison then
            -- if not self.IsAutoPrisonTask and self.WaiteFormId == 0 then
            --     self.IsAutoPrisonTask = true;
            -- end
            self:PushPrisonOverId(task.Data.Id);
        elseif task.Data.Type == TaskType.DailyPrison then
            -- if not self.IsAutoDailyPrisonTask then
            --     self.IsAutoDailyPrisonTask = true;
            -- end
        end
        self.TaskContainer:Remove(task.Data.Id)
        self.TaskBeHaviorManager:RmoveBehavior(task.Data.Id)
        self.CurSelectTaskID = 0;
    end
end

function LuaTaskManager:ClearTask()
    if self.TaskContainer ~= nil then
        self.TaskContainer:Clear()
    end
    if (self.TaskBeHaviorManager.TaskBehaviorContainer ~= nil) then
        self.TaskBeHaviorManager.TaskBehaviorContainer:Clear()
    end
end

-- Remove the missed task with the specified id
function LuaTaskManager:RemoveTaskInNotRecieve(taskId)
    self.TaskContainer:RemoveEx(TaskType.Not_Recieve, taskId)
end

-- Get a task
function LuaTaskManager:GetTask(taskId)
    return self.TaskContainer:FindTakByID(taskId);
end

-- Get the ID of the previous main task
function LuaTaskManager:GetPreMainTaskId(taskId)
    local _ret = 0
    local _cfg = DataConfig.DataTask[taskId]
    if (_cfg ~= nil) then
        _ret = _cfg.PreTaskId;
    end
    return _ret;
end

-- Return to whether the player has received the task
function LuaTaskManager:IsHaveTask(taskId)
    local _ret = false
    local _task = self.TaskContainer:FindTakByID(taskId);
    if _task == nil then
        _ret = false;
    else
        if not _task.Data.IsAccess then
            _ret = false;
        end
    end
    return _ret;
end

-- Get the task name
function LuaTaskManager:GetTaskName(taskId)
    local _task = self:GetTask(taskId)
    return self:GetTaskNameEx(_task)
end

-- Get the task name
function LuaTaskManager:GetTaskNameEx(task)
    local _ret = ""
    if task ~= nil then
        _ret = task.Data.Name;
        local _cfg = task.Data.Cfg
        if task.Data.Type == TaskType.Daily then
            if _cfg ~= nil then
                _ret = UIUtils.CSFormat("{0} ({1}/{2})", _cfg.TaskName, task.Data.CurStep, task.Data.AllStep)
            end
        elseif task.Data.Type == TaskType.Guild then
            if _cfg ~= nil then
                if task.Data.Count > task.Data.AllStep then
                    _ret = UIUtils.CSFormat("{0})", _cfg.TaskName);
                else
                    _ret = UIUtils.CSFormat("{0} ({1}/{2})", _cfg.TaskName, task.Data.Count, task.Data.AllStep)
                end
            end
        elseif task.Data.Type == TaskType.DailyPrison then
            if _cfg ~= nil then
                _ret = UIUtils.CSFormat("{0} ({1}/{2})", _cfg.TaskName, task.Data.CurStep, task.Data.AllStep)
            end
        end
    end
    return _ret
end

-- Perform tasks
function LuaTaskManager:StarTask(taskId, isClick, isClickByForm)
    Debug.Log("Start task:" .. taskId)
    if isClick == nil then
        isClick = false
    end
    if isClickByForm == nil then
        isClickByForm = false
    end
    self.IsSuspend = false;
    if taskId == -1 then
        return;
    end
    local _task = self:GetTask(taskId);
    -- Debug.LogTable(_task)
    if _task == nil then
        return;
    end
    if _task.Data.Type == TaskType.Main then
        if self:IsMainTaskOver(_task.Data.Id) then
            return;
        end
    end
    if _task.Data.Type == TaskType.Prison then
        if self:IsPrisonTaskOver(_task.Data.Id) then
            return;
        end
    end
    if self:IsLockContain(taskId) then
        return;
    end
    self.TaskBeHaviorManager:DoBehavior(taskId, isClick, isClickByForm)
end

-- Perform daily tasks
function LuaTaskManager:StartDailyTask(subType, isClick, isClickByForm)
    local _task = self:GetDailyTask();
    if _task ~= nil then
        self:StarTask(_task.Data.Id, isClick, isClickByForm)
    end
end

-- Perform daily prison tasks
function LuaTaskManager:StartDailyPrisonTask(subType, isClick, isClickByForm)
    local _task = self:GetDailyPrisonTask();
    if _task ~= nil then
        self:StarTask(_task.Data.Id, isClick, isClickByForm)
    end
end

-- Whether to perform tasks after transmission
function LuaTaskManager:StartTransPortTask()
    local _ret = false;
    if self.IsAutoTaskForTransPort then
        self.IsAutoTaskForTransPort = false;
        self.IsLocalUserTeleport = false;
        local _behavior = self.TaskBeHaviorManager.Container:Find(self.CurSelectTaskID);
        if _behavior ~= nil then
            if _behavior.Type == TaskBeHaviorType.OpenUI then
                local _isTalkToNpc = _behavior:IsTalkToNpc();
                if _isTalkToNpc then
                    _behavior:DoBehavior();
                end
            else
                _behavior:DoBehavior();
            end
        end
        _ret = true;
    end
    return _ret;
end

-- Set the number of times a loop task is completed
function LuaTaskManager:SetLoopTaskStep(type, step)
    if type == TaskType.ZhuanZhi then
        self.TransferTaskStep = step;
    end
end

-- Is it possible to submit a task
function LuaTaskManager:CanSubmitTask(taskID)
    return self.TaskBeHaviorManager:IsEndBehavior(taskID)
end

-- Is it possible to submit a task
function LuaTaskManager:CanSubmitTaskEx(task)
    local _ret = false
    if task == nil then
        _ret = false;
    else
        if task.Data.IsAccess == true then
            _ret = self.TaskBeHaviorManager:IsEndBehavior(task.Data.Id)
        end
    end
    return _ret;
end

-- Whether the main task of the specified id is completed
function LuaTaskManager:IsMainTaskOver(taskId)
    local _ret = false
    for i = 1, #self.OverTaskIdList do
        if self.OverTaskIdList[i] == taskId then
            _ret = true
            break
        end
    end
    return _ret;
end

-- Whether the main task of the specified id is completed
function LuaTaskManager:IsPrisonTaskOver(taskId)
    local _ret = false
    for i = 1, #self.OverPrisonTaskIdList do
        if self.OverPrisonTaskIdList[i] == taskId then
            _ret = true
            break
        end
    end
    return _ret;
end

-- Is it in the unretrieved task container
function LuaTaskManager:IsInNotRecieveContainer(taskId)
    local _ret = false
    local _task = self.TaskContainer:FindByTypeAndID(TaskType.Not_Recieve, taskId)
    if _task == nil then
        _ret = false
    else
        _ret = true
    end
    return _ret
end

-- Get the current main task
function LuaTaskManager:GetMainTask()
    local _ret = nil
    local _list = self.TaskContainer:FindTaskByType(TaskType.Main);
    if _list ~= nil then
        if #_list > 0 then
            if #_list > 1 then
                Debug.LogError("There are multiple errors on the main task");
            else
                local _task = _list[1]
                if _task.Data.Type == TaskType.Main then
                    _ret = _task
                end
            end
        end
    end
    return _ret;
end

function LuaTaskManager:GetMainTaskId()
    local _ret = -1
    local _list = self.TaskContainer:FindTaskByType(TaskType.Main);
    if _list ~= nil then
        if #_list > 0 then
            if (#_list > 1) then
                Debug.LogError("There are multiple errors on the main task");
            else
                local _task = _list[1];
                _ret = _task ~= nil and _task.Data.Id or -1;
            end
        end
    end

    -- Check prison tasks
    if _ret == -1 then
        Debug.Log("No main task found, checking prison tasks");
        local _prisonList = self.TaskContainer:FindTaskByType(TaskType.Prison);
        if _prisonList ~= nil and #_prisonList > 0 then
            if (#_prisonList > 1) then
                Debug.LogError("There are multiple errors on the prison task");
            else
                local _task = _prisonList[1];
                _ret = _task ~= nil and _task.Data.Id or -1;
            end
        end
    end

    return _ret;
end

-- Get the first daily task
function LuaTaskManager:GetDailyTask()
    local _ret = nil
    local _list = self.TaskContainer:FindTaskByType(TaskType.Daily);
    if _list ~= nil and #_list > 0 then
        _ret = _list[1]
    end
    if _list == nil then
        -- Find out if there are any unreceived daily tasks
        local _notReciveList = self.TaskContainer:FindTaskByType(TaskType.Not_Recieve);
        if _notReciveList ~= nil then
            for i = 1, #_notReciveList do
                local _task = _notReciveList[i]
                if _task ~= nil then
                    if _task.Data.Type == TaskType.Daily then
                        _ret = _task
                        break
                    end
                end
            end
        end
    end
    return _ret
end

-- Get the first daily task
function LuaTaskManager:GetNotReciveDailyTask()
    local _ret = nil
    local _notReciveList = self.TaskContainer:FindTaskByType(TaskType.Not_Recieve);
    if _notReciveList ~= nil then
        for i = 1, #_notReciveList do
            local _task = _notReciveList[i]
            if _task ~= nil then
                if _task.Data.Type == TaskType.Daily then
                    _ret = _task
                    break
                end
            end
        end
    end
    return _ret
end

-- Get daily tasks (including unreceived daily tasks)
function LuaTaskManager:GetDailyTasks()
    local _list = List:New()
    local _reciveList = self.TaskContainer:FindTaskByType(TaskType.Daily);
    local _notReciveList = self.TaskContainer:FindTaskByType(TaskType.Not_Recieve);
    if _reciveList ~= nil then
        for i = 1, #_reciveList do
            _list:Add(_reciveList[i])
        end
    end
    if _notReciveList ~= nil then
        for i = 1, #_notReciveList do
            local _task = _notReciveList[i]
            if _task.Data.Type == TaskType.Daily then
                _list:Add(_task);
            end
        end
    end
    if #_list == 0 then
        return nil
    end
    return _list;
end

-- Get the first daily prison task
function LuaTaskManager:GetDailyPrisonTask()
    local _ret = nil
    local _list = self.TaskContainer:FindTaskByType(TaskType.DailyPrison);
    if _list ~= nil and #_list > 0 then
        _ret = _list[1]
    end
    if _list == nil then
        -- Find out if there are any unreceived daily tasks
        local _notReciveList = self.TaskContainer:FindTaskByType(TaskType.Not_Recieve);
        if _notReciveList ~= nil then
            for i = 1, #_notReciveList do
                local _task = _notReciveList[i]
                if _task ~= nil then
                    if _task.Data.Type == TaskType.DailyPrison then
                        _ret = _task
                        break
                    end
                end
            end
        end
    end
    return _ret
end

-- Get the first daily prison task
function LuaTaskManager:GetNotReciveDailyPrisonTask()
    local _ret = nil
    local _notReciveList = self.TaskContainer:FindTaskByType(TaskType.Not_Recieve);
    if _notReciveList ~= nil then
        for i = 1, #_notReciveList do
            local _task = _notReciveList[i]
            if _task ~= nil then
                if _task.Data.Type == TaskType.DailyPrison then
                    _ret = _task
                    break
                end
            end
        end
    end
    return _ret
end

-- Get daily tasks (including unreceived daily tasks)
function LuaTaskManager:GetDailyPrisonTasks()
    local _list = List:New()
    local _reciveList = self.TaskContainer:FindTaskByType(TaskType.DailyPrison);
    local _notReciveList = self.TaskContainer:FindTaskByType(TaskType.Not_Recieve);
    if _reciveList ~= nil then
        for i = 1, #_reciveList do
            _list:Add(_reciveList[i])
        end
    end
    if _notReciveList ~= nil then
        for i = 1, #_notReciveList do
            local _task = _notReciveList[i]
            if _task.Data.Type == TaskType.DailyPrison then
                _list:Add(_task);
            end
        end
    end
    if #_list == 0 then
        return nil
    end
    return _list;
end

-- Get the first gang mission
function LuaTaskManager:GetGuildTask()
    local _ret = nil
    local _list = self.TaskContainer:FindTaskByType(TaskType.Guild);
    if _list ~= nil and #_list ~= 0 then
        _ret = _list[1]
    end
    return _ret
end

-- Get a list of gang tasks
function LuaTaskManager:GetGuildTasks()
    local _list = List:New()
    local _reciveList = self.TaskContainer:FindTaskByType(TaskType.Guild);
    local _notReciveList = self.TaskContainer:FindTaskByType(TaskType.Not_Recieve);
    if _reciveList ~= nil then
        for i = 1, #_reciveList do
            if _reciveList[i].Data.SubType ~= 2 then
                _list.Add(reciveList[i])
            end
        end
    end
    if _notReciveList ~= nil then
        for i = 1, #_notReciveList do
            local _task = _notReciveList[i]
            if _task.Data.Type == TaskType.Guild then
                if _task.Data.SubType ~= 2 then
                    _list.Add(_task)
                end
            end
        end
    end
    if #_list == 0 then
        return nil
    end
    return _list
end

-- Get all union tasks
function LuaTaskManager:GetAllGuildTasks()
    local _list = List:New()
    local _reciveList = self.TaskContainer:FindTaskByType(TaskType.Guild)
    local _notReciveList = self.TaskContainer:FindTaskByType(TaskType.Not_Recieve)
    if _reciveList ~= nil then
        for i = 1, #_reciveList do
            _list:Add(_reciveList[i]);
        end
    end
    if _notReciveList ~= nil then
        for i = 1, #_notReciveList do
            local _task = _notReciveList[i]
            if _task.Data.Type == TaskType.Guild then
                _list:Add(_task)
            end
        end
    end
    if #_list == 0 then
        return nil
    end
    return _list
end

-- Get all Immortal Alliance missions
function LuaTaskManager:GetXmTasks()
    local _retList = List:New()
    local _list = self:GetAllGuildTasks();
    if _list ~= nil then
        for i = 1, #_list do
            local _task = _list[i];
            if _task.Data.SubType == 2 then
                _retList:Add(_task)
            end
        end
    end
    return _retList;
end

-- Get the currently received Immortal Alliance mission
function LuaTaskManager:GetAccessXmTask()
    local _list = self:GetGuildTasks()
    if _list ~= nil then
        for i = 1, #_list do
            local _task = _list[i];
            if _task.Data.SubType == 2 and _task.Data.IsAccess then
                return _task
            end
        end
    end
    return nil
end

-- Clear unaccepted Immortal Alliance missions
function LuaTaskManager:ClearXmTasks()
    local _list = self:GetAllGuildTasks()
    if _list ~= nil then
        for i = 1, #_list do
            local _task = _list[i];
            if _task.Data.SubType == 2 and not _task.Data.IsAccess then
                -- Delete random unaccepted Xianlian missions
                self.TaskContainer:Remove(_task.Data.Id);
                self.TaskBeHaviorManager:RmoveBehavior(_task.Data.Id)
            end
        end
    end
end

-- Get side quests
function LuaTaskManager:GetBranchTask()
    local _ret = nil
    local _list = self.TaskContainer:FindTaskByType(TaskType.Branch);
    if _list ~= nil and #_list > 0 then
        _ret = _list[1]
    end
    return _ret
end

function LuaTaskManager:GetCopyBranchTask()
    local _ret = nil
    local _list = self.TaskContainer:FindTaskByType(TaskType.Branch)
    if _list ~= nil and #_list > 0 then
        for i = 1, #_list do
            local _task = _list[i]
            local _cloneMapId = _task.Data.Cfg.CopymapShow
            if _cloneMapId ~= 0 then
                _ret = _task
            end
        end

    end
    return _ret
end

-- Get job transfer tasks
function LuaTaskManager:GetTransferTask()
    local _ret = nil
    local _list = self.TaskContainer:FindTaskByType(TaskType.ZhuanZhi);
    if _list ~= nil and #_list > 0 then
        _ret = _list[1]
    end
    return _ret;
end

-- Get the current prison task
function LuaTaskManager:GetPrisonTask()
    local _ret = nil
    local _list = self.TaskContainer:FindTaskByType(TaskType.Prison);
    if _list ~= nil then
        if #_list > 0 then
            if #_list > 1 then
                Debug.LogError("There are multiple errors on the prison task");
            else
                local _task = _list[1]
                if _task.Data.Type == TaskType.Prison then
                    _ret = _task
                end
            end
        end
    end
    return _ret;
end

function LuaTaskManager:GetPrisonTaskId()
    local _ret = -1
    local _list = self.TaskContainer:FindTaskByType(TaskType.Prison);
    if _list ~= nil then
        if #_list > 0 then
            if (#_list > 1) then
                Debug.LogError("There are multiple errors on the prison task");
            else
                local _task = _list[1];
                _ret = _task ~= nil and _task.Data.Id or -1;
            end
        end
    end
    return _ret;
end

-- Is the collecting object id in the task?
function LuaTaskManager:IsCollectionIdInTask(id)
    local _list = self.TaskContainer:FindByBehaviorType(TaskBeHaviorType.Collection);
    if _list ~= nil then
        for i = 1, #_list do
            local _behavior = self.TaskBeHaviorManager.Container:Find(_list[i].Data.Id);
            if _behavior ~= nil then
                if _behavior.TaskTarget.TagId == id then
                    return true;
                end
            end
        end
    end
    return false;
end

function LuaTaskManager:AddLock(taskId)
    if not self:IsLockContain(taskId) then
        local _lockData = L_TaskLock:New()
        _lockData.Id = taskId;
        _lockData.Tick = _lockData.Time;
        self.LockList.Add(_lockData);
    end
end

function LuaTaskManager:IsLockContain(taskId)
    for i = 1, #self.LockList do
        local _data = self.LockList[i];
        if _data.id == taskId then
            return true
        end
    end
    return false;
end

function LuaTaskManager:UpdateLockData(dt)
    for i = 1, #self.LockList do
        local _data = self.LockList[i]
        if _data.Tick > 0 then
            _data.Tick = _data.Tick - dt
        else
            _data.Tick = 0;
            -- Remove
            self.LockList:RemoveAt(i)
        end
    end
end

-- Create task behavior
function LuaTaskManager:CreateBehavior(type)
    return self.TaskBeHaviorManager:Create(type)
end

-- Get task behavior
function LuaTaskManager:GetBehavior(id)
    return self.TaskBeHaviorManager:GetBehavior(id)
end

-- Add task behavior
function LuaTaskManager:AddBehavior(id, behavior)
    self.TaskBeHaviorManager:Add(id, behavior)
end

-- Set task behavior goals
function LuaTaskManager:SetBehaviorTag(id, count, talkId, x, y, itemID, type, behavior)
    self.TaskBeHaviorManager:SetBehaviorTag(id, count, talkId, x, y, itemID, type, behavior);
end

-- Get task behavior type
function LuaTaskManager:GetBehaviorType(id)
    return self.TaskBeHaviorManager:GetTaskBehaviorType(id)
end

-- Whether to suspend task behavior
function LuaTaskManager:GetIsPauseBehavior()
    return self.TaskBeHaviorManager.IsPause
end

function LuaTaskManager:SetIsPauseBehavior(b)
    self.TaskBeHaviorManager.IsPause = b;
end

-- Whether the behavior of the corresponding task id ends
function LuaTaskManager:IsEndBehavior(id)
    return self.TaskBeHaviorManager:IsEndBehavior(id);
end

-- Get the ui task behavior description above for the corresponding id of the task
function LuaTaskManager:GetUIDescript(id)
    local _uiDes = ""
    local _behavior = self.TaskBeHaviorManager.Container:Find(id)
    if _behavior ~= nil then
        _uiDes = _behavior.UiDes
    end
    return _uiDes
end

-- Get task conversation
function LuaTaskManager:GetTaskTalk(task)
    local _ret = nil
    local _talk = nil
    local _talkId = nil
    local _modelId = nil
    local _talkCfg = nil
    local _behavior = self.TaskBeHaviorManager:GetBehavior(task.Data.Id);
    if _behavior ~= nil and _behavior.Type == TaskBeHaviorType.FindCharactor then
        if _behavior.TaskTarget.Count < _behavior.TaskTarget.TCount then
            -- If the task of finding someone is not completed
            _talkId = _behavior.TaskTarget.TalkId
            local _cfg = DataConfig.DataTaskTalk[_talkId]
            if _cfg == nil then
                _talk = nil
                _modelId = -1
            else
                _talkCfg = DataConfig.DataTaskTalk[_talkId]
                if _talkCfg ~= nil then
                    _talk = _talkCfg.Content
                end
                _modelId = _cfg.Model
            end
        end
    end
    if task.Data.Type == TaskType.Main then
        local _cfg = DataConfig.DataTask[task.Data.Id]
        if _cfg ~= nil then
            _talkId = _cfg.TaskTalkEnd
            _talkCfg = DataConfig.DataTaskTalk[_talkId]
            if _talkCfg == nil then
                _talk = nil;
                _modelId = -1;
            else
                _talk = _talkCfg.Content;
                _modelId = _talkCfg.Model;
            end
        end
    elseif task.Data.Type == TaskType.Daily then
        if task.Data.IsAccess then
            if self:CanSubmitTask(task.Data.Id) then
                local _cfg = DataConfig.DataTaskDaily[task.Data.Id]
                if _cfg ~= nil then
                    _talkId = _cfg.TaskTalkOver
                end
            elseif task.Data.Behavior == TaskBeHaviorType.PassCopy then
                local _cfg = DataConfig.DataTaskDaily[task.Data.Id]
                if _cfg ~= nil then
                    _talkId = _cfg.TaskTalkStart
                end
            else
                _talk = nil
            end
        else
            local _taskCfg = DataConfig.DataTaskDaily[task.Data.Id]
            if _taskCfg ~= nil then
                _talkId = _taskCfg.TaskTalkStart
            end
        end
        _talkCfg = DataConfig.DataTaskTalk[_talkId];
        if _talkCfg == nil then
            _talk = nil
            _modelId = -1
        else
            _talk = _talkCfg.Content;
            _modelId = _talkCfg.Model;
        end
    elseif task.Data.Type == TaskType.Guild then
        local _taskCfg = DataConfig.DataTaskConquer[task.Data.Id]
        if task.Data.IsAccess then
            if _taskCfg ~= nil then
                _talkId = _taskCfg.TaskTalkOver
            end
        else
            if _taskCfg ~= nil then
                _talkId = _taskCfg.TaskTalkStart
            end
        end
        _talkCfg = DataConfig.DataTaskTalk[_talkId]
        if _talkCfg == nil then
            _talk = nil
            _modelId = -1
        else
            _talk = _talkCfg.Content;
            _modelId = _talkCfg.Model;
        end
    elseif task.Data.Type == TaskType.ZhuanZhi then
        local _taskCfg = DataConfig.DataTaskGender[task.Data.Id]
        if _taskCfg ~= nil then
            if task.Data.IsAccess then
                if self:CanSubmitTask(task.Data.Id) then
                    if _taskCfg ~= nil then
                        _talkId = _taskCfg.TaskTalkEnd;
                    end
                else
                    _talk = nil
                end
            else
                _talkId = _taskCfg.TaskTalkStart
            end
        end
        _talkCfg = DataConfig.DataTaskTalk[_talkId]
        if _talkCfg == nil then
            _talk = nil
            _modelId = -1;
        else
            _talk = _talkCfg.Content;
            _modelId = _talkCfg.Model;
        end
    elseif task.Data.Type == TaskType.Prison then
        local _cfg = DataConfig.DataTaskPrison[task.Data.Id]
        if _cfg ~= nil then
            _talkId = _cfg.TaskTalkEnd
            _talkCfg = DataConfig.DataTaskTalk[_talkId]
            if _talkCfg == nil then
                _talk = nil;
                _modelId = -1;
            else
                _talk = _talkCfg.Content;
                _modelId = _talkCfg.Model;
            end
        end
    elseif task.Data.Type == TaskType.DailyPrison then
        if task.Data.IsAccess then
            if self:CanSubmitTask(task.Data.Id) then
                local _cfg = DataConfig.DataTaskDailyPrison[task.Data.Id]
                if _cfg ~= nil then
                    _talkId = _cfg.TaskTalkOver
                end
            elseif task.Data.Behavior == TaskBeHaviorType.PassCopy then
                local _cfg = DataConfig.DataTaskDailyPrison[task.Data.Id]
                if _cfg ~= nil then
                    _talkId = _cfg.TaskTalkStart
                end
            else
                _talk = nil
            end
        else
            local _taskCfg = DataConfig.DataTaskDailyPrison[task.Data.Id]
            if _taskCfg ~= nil then
                _talkId = _taskCfg.TaskTalkStart
            end
        end
        _talkCfg = DataConfig.DataTaskTalk[_talkId];
        if _talkCfg == nil then
            _talk = nil
            _modelId = -1
        else
            _talk = _talkCfg.Content;
            _modelId = _talkCfg.Model;
        end
    end
    _ret = {
        Talk = _talk,
        TalkId = _talkId,
        ModelId = _modelId
    }
    return _ret;
end

-- Is it the last conversation in the task?
function LuaTaskManager:IsEndDialogue(talkId)
    local _ret = false
    local _cfg = DataConfig.DataTaskTalk[talkId]
    if _cfg ~= nil then
        _ret = _cfg.Nextid == 0 and true or false
    end
    return _ret
end

function LuaTaskManager:HaveNpcTask(npcId)
    local _ret = false
    local _task = self:GetNpcTask(npcId)
    if _task ~= nil and (_task.Data.Type ~= TaskType.Daily and _task.Data.Type ~= TaskType.DailyPrison) then
        _ret = true
    end
    return _ret
end

-- Get tasks on NPC (only return completed (main task priority) tasks and unreceived tasks (completed tasks priority is greater than unreceived tasks))
function LuaTaskManager:GetNpcTask(npcID)
    local _overTask = nil
    -- Tasks that have been received
    self.TaskContainer.Container:ForeachCanBreak(function(k, v)
        for i = 1, #v do
            if k == TaskType.Not_Recieve then
                -- No task received
                -- Mission not accepted
                if _overTask == nil then
                    if self.CurSelectTaskID == 0 then
                        if v[i].Data.AccessNpcID == npcID then
                            _overTask = v[i]
                        end
                    else
                        -- Specify to perform a task
                        if v[i].Data.Id == self.CurSelectTaskID then
                            local _accessNpcId = v[i]:GetAccessNpcId(v[i].Data.Id)
                            if _accessNpcId == npcID then
                                _overTask = v[i]
                            end
                            break
                        end
                    end
                end
            else
                -- Tasks that have been accepted
                local _behavior = self.TaskBeHaviorManager:GetBehavior(v[i].Data.Id);
                if _behavior ~= nil then
                    -- Tasks that have been received
                    -- Task completion
                    if self.CurSelectTaskID == 0 then
                        -- No task execution is specified
                        if _behavior.TaskTarget:IsReach(_behavior.Type) then
                            if _overTask == nil then
                                if v[i].Data.SubmitNpcID == npcID then
                                    _overTask = v[i]
                                    break
                                end
                            else
                                if v[i].Data.Type < _overTask.Data.Type and v[i].Data.SubmitNpcID == npcID then
                                    _overTask = v[i]
                                    break
                                end
                            end
                        end
                        if  (v[i].Data.Type == TaskType.Daily or v[i].Data.Type == TaskType.DailyPrison) 
                            and v[i].Data.Behavior == TaskBeHaviorType.PassCopy then
                            if v[i] ~= nil then
                                if v[i].Cfg.NpcId == npcID then
                                    _overTask = v[i]
                                end
                            end
                        end
                    else
                        -- Specify to perform a task
                        if v[i].Data.Id == self.CurSelectTaskID then
                            if  (v[i].Data.Type == TaskType.Daily or v[i].Data.Type == TaskType.DailyPrison) 
                                and v[i].Data.Behavior == TaskBeHaviorType.PassCopy then
                                if v[i].Cfg.NpcId == npcID then
                                    _overTask = v[i]
                                    return _overTask
                                end
                            end
                            if v[i].Data.SubmitNpcID == npcID then
                                _overTask = v[i]
                                return _overTask
                            end
                        else
                            if v[i].Data.SubmitNpcID == npcID then
                                _overTask = v[i]
                            end
                        end
                    end
                end
            end
        end
    end)
    return _overTask;
end

function LuaTaskManager:GetXmCopyTaskByNpc(npcId)
    local _ret = nil
    local _list = self:GetXmTasks();
    if _list ~= nil then
        for i = 1, #_list do
            local _task = _list[i];
            local _bType = self:GetBehaviorType(_task.Data.Id)
            if _bType == TaskBeHaviorType.PassCopy and _task.Data.IsAccess then
                if _task.Data.Cfg.OverNpc == npcId then
                    _ret = _task
                    break
                end
            end
        end
    end
    return _ret
end

-- Obtain the task status of NPC
function LuaTaskManager:GetNpcTaskState(npcID)
    local _task = self:GetNpcTask(npcID)
    if _task ~= nil then
        local _behavior = self.TaskBeHaviorManager:GetBehavior(_task.Data.Id);
        if _behavior == nil then
            return L_CSNpcTaskState.Default;
        else
            if _task.Data.IsAccess then
                -- Can submit
                if self:CanSubmitTask(_task.Data.Id) then
                    return L_CSNpcTaskState.Submit;
                end
                return L_CSNpcTaskState.Default;
            else
                -- Not received
                return L_CSNpcTaskState.Can_Access;
            end
        end
    end
    return L_CSNpcTaskState.Default;
end

function LuaTaskManager:GetWaterWaveParam()
    local _param = nil
    local _behavior = self.TaskBeHaviorManager:GetBehavior(self.CurSelectTaskID)
    if _behavior ~= nil and _behavior.Type == TaskBeHaviorType.ArrivePosEx then
        self.OldParam = _behavior.Param
        return self.OldParam
    else
        _param = self.OldParam;
        return _param
    end
end

function LuaTaskManager:EnterPlaneCopy()
end

function LuaTaskManager:LeavePlaneCopy()
    if self.IsStopAllTask then
        self.IsAutoTaskForTransPort = false
        self.IsStopAllTask = false
    else
        -- Ensure that tasks are actively executed when exiting the plane
        self.IsAutoTaskForTransPort = true
    end
end

function LuaTaskManager:IsSyncPos(isEnter, frontMapId, curMapId)
    local _task = self:GetTask(self.CurSelectTaskID)
    if _task == nil or _task.Data.MapID ~= curMapId then
        -- It's not the mission plane that you enter
        return false;
    else
        return self:GetTaskSyncId(isEnter, _task) == 1;
    end
end

function LuaTaskManager:GetTaskSyncId(isEnter, task)
    local _syncId = 0
    local _taskId = -1
    if isEnter then
        _taskId = self.CurSelectTaskID
    else
        local _preTaskId = -1;
        if task.Data.Type == TaskType.Main then
            _preTaskId = self:GetPreMainTaskId(self.CurSelectTaskID);
            _taskId = _preTaskId;
        end
    end
    if _taskId > 0 then
        if task.Data.Type == TaskType.Main then
            local _cfg = DataConfig.DataTask[taskId]
            if _cfg ~= nil then
                _syncId = _cfg.IsSyncPos
            end
        else
            _syncId = 0;
        end
    else
        _syncId = 0;
    end
    return _syncId;
end

function LuaTaskManager:IsTalkToNpcTask(taskId)
    local _ret = false
    if self:GetBehaviorType(taskId) == TaskBeHaviorType.Talk then
        _ret = true
    end
    return _ret
end

function LuaTaskManager:ReqTaskChange(taskId)
    local _task = self:GetTask(taskId)
    if _task ~= nil then
        GameCenter.TaskManagerMsg:ReqChangeTaskState(_task.Data.Type, _task.Data.Id)
    end
end

function LuaTaskManager:GetTaskIconId(taskId)
    local _ret = 0
    local _task = self:GetTask(taskId)
    if _task ~= nil then
        _ret = _task.Data.IconId
    end
end

-- Get the main task description
function LuaTaskManager:GetMainTaskDes()
    local _ret = ""
    local _id = self:GetMainTaskId()
    local _behavior = self:GetBehavior(_id)
    if _behavior ~= nil then
        _ret = _behavior.Des
    end
    return _ret
end

-- Get the main task type
function LuaTaskManager:GetMainTaskType()
    local _ret = 0
    local _id = self:GetMainTaskId()
    _ret = self:GetBehaviorType(_id)
    return _ret
end

function LuaTaskManager:GetDailyTaskRewardState(count)
    local _ret = false
    if self.DailyBoxState ~= nil then
        _ret = self.DailyBoxState[count]
    else
    end
    return _ret
end

function LuaTaskManager:AllDailyTaskRewared()
    local _ret = false
    local _b1 = GameCenter.LuaTaskManager:GetDailyTaskRewardState(10)
    local _b2 = GameCenter.LuaTaskManager:GetDailyTaskRewardState(20)
    _ret = _b1 and _b2
    return _ret
end

function LuaTaskManager:GetDailyPrisonTaskRewardState(count)
    local _ret = false
    if self.PrisonDailyBoxState ~= nil then
        _ret = self.PrisonDailyBoxState[count]
    else
    end
    return _ret
end

function LuaTaskManager:AllDailyPrisonTaskRewared()
    local _ret = false
    local _b1 = GameCenter.LuaTaskManager:GetDailyPrisonTaskRewardState(10)
    local _b2 = GameCenter.LuaTaskManager:GetDailyPrisonTaskRewardState(20)
    _ret = _b1 and _b2
    return _ret
end

function LuaTaskManager:Update(dt)
    -- behavior heartbeat
    if self.TaskBeHaviorManager ~= nil then
        self.TaskBeHaviorManager:OnUpdate(dt)
    end
    if self.IsAutoTaskForTransPort then
        if self.IsLocalUserTeleport then
            GameCenter.TaskController:ResumeForTransPort()
        end
    end

    self:UpdateLockData(dt)
end

function LuaTaskManager:IsDenyTalkDoBehavior(taskId)
    local _ret = false
    local _cfg = DataConfig.DataTask[taskId]
    if _cfg ~= nil and _cfg.TaskTalkStart == -2 then
        _ret = true
    end
    return _ret
end

function LuaTaskManager:IsCurrentTaskBlockTransport()
    local _ret = false
    
    local _mainTask = self:GetMainTask()
    if _mainTask ~= nil then
        _ret = self:IsTaskBlockTransfer(TaskType.Main, _mainTask.Data.Id)
    end

    if _ret == false then
        local _prisonTask = self:GetPrisonTask()
        if _prisonTask ~= nil then
            _ret = self:IsTaskBlockTransfer(TaskType.Prison, _prisonTask.Data.Id)
        end
    end

    return _ret
end

function LuaTaskManager:IsTaskBlockTransfer(type, taskId)
    local _ret = false
    local _cfg = nil

    if type == TaskType.Main then
        _cfg = DataConfig.DataTask[taskId]
    elseif type == TaskType.Prison then
        _cfg = DataConfig.DataTaskPrison[taskId]
    end

    if _cfg ~= nil and _cfg.BlockTransport == 1 then
        _ret = true
    end

    return _ret
end

return LuaTaskManager
