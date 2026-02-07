------------------------------------------------
-- Author: Wang Sheng
-- Date: 2021-03-19
-- File: DailyTask.lua
-- Module: DailyTask
-- Description: Daily Task Example
------------------------------------------------
-- Quote
local L_TaskBase = require "Logic.TaskSystem.Instance.TaskBase"
local DailyTask = {}

function DailyTask:New(info, isAccess)
    local _m = Utils.Extend(L_TaskBase:New(), self)
    _m:SetTask(info, isAccess)
    return _m
end

function DailyTask:SetTask(info, isAccess)
    if info == nil then
        return
    end
    if isAccess == nil then
        isAccess = false
    end
    local _cfg = DataConfig.DataTaskDaily[info.modelId]
    if _cfg == nil then
        Debug.LogError("DailyTask Id Is Error");
        return
    end
    local _name = DataConfig.DataMessageString.Get("C_KILL_CEHUA")
    local _mapId = 0
    if isAccess then
        _mapId = info.useItems.mapId
    else
        _mapId = _cfg.ConditionsMap
    end
    self.Data:SetData(info.modelId, TaskType.Daily, self:GetAccessNpcId(info.modelId),
        self:GetSubmitNpcId(info.modelId), isAccess, _cfg.TaskType, _name, nil, nil, self:GetRwardStr(_cfg, info.star),
        _mapId, nil, nil, true)
    self.Data.Name = UIUtils.CSFormat(DataConfig.DataMessageString.Get("TASK_CUR_COUNT"), info.count)
    self.Data.TypeName = _cfg.TypeName
    self.Data.SubType = _cfg.DailySubtype
    if _cfg.DailySubtype == 0 then
        self.Data.Sort = TaskSort.DailyExp
    elseif _cfg.DailySubtype == 1 then
        Data.Sort = TaskSort.DailyGold
    end
    self.Data.StarNum = info.star
    self.Data.CurStep = info.count
    self.Data.Cfg = _cfg
    local _globCfg = DataConfig.DataGlobal[1134]
    local _strs = Utils.SplitStr(_globCfg.Params, ';')
    local _values = nil
    if #_strs > _cfg.DailySubtype then
        _values = Utils.SplitNumber(_strs[_cfg.DailySubtype + 1], '_')
    end
    local _step = #_values >= 2 and _values[2] or -1
    self.Data.AllStep = _step
    if isAccess then
        GameCenter.LuaTaskManager:AddTask(self)
    else
        GameCenter.LuaTaskManager:AddTaskByType(TaskType.Not_Recieve, self)
    end
    local _behavior = GameCenter.LuaTaskManager:CreateBehavior(_cfg.TaskType)
    if _behavior == nil then
        Debug.LogError("Creation behavior failed")
        return
    end
    _behavior.Id = info.modelId
    if isAccess then
        if GameCenter.LuaTaskManager:IsInNotRecieveContainer(info.modelId) then
            -- The player takes the initiative to receive the task and removes the task container without the task. Execute the task behavior.
            GameCenter.LuaTaskManager:RemoveTaskInNotRecieve(info.modelId)
            GameCenter.LuaTaskManager:SetBehaviorTag(info.useItems.model, info.useItems.needNum, info.useItems.talkId,
            info.useItems.xPos, info.useItems.yPos, info.useItems.itemId, info.useItems.type, _behavior)
            _behavior.Type = _cfg.TaskType
            _behavior.TaskTarget.Count = info.useItems.num;
            GameCenter.LuaTaskManager:AddBehavior(info.modelId, _behavior)
            _behavior:SetTargetDes()
            self.Data.TargetDes = _behavior.Des
            _behavior:DoBehavior()

        else
            GameCenter.LuaTaskManager:SetBehaviorTag(info.useItems.model, info.useItems.needNum, info.useItems.talkId,
            info.useItems.xPos, info.useItems.yPos, info.useItems.itemId, info.useItems.type, _behavior)
            _behavior.Type = _cfg.TaskType
            _behavior.TaskTarget.Count = info.useItems.num;
            GameCenter.LuaTaskManager:AddBehavior(info.modelId, _behavior)
            _behavior:SetTargetDes()
            self.Data.TargetDes = _behavior.Des
            -- GameCenter.LuaSystem.Adaptor.EndMandate();
            if _behavior.Type == TaskBeHaviorType.PassCopy then
                if GameCenter.LuaTaskManager.IsAutoDailyTask then
                    _behavior:DoBehavior()
                end
            else
                if GameCenter.LuaTaskManager.IsAutoDailyTask and _behavior.Type ~= TaskBeHaviorType.OpenUI then
                    _behavior:DoBehavior()
                end
            end
            if GameCenter.LuaTaskManager.IsWiptOutClick then
                -- If it's click to sweep
                GameCenter.LuaTaskManager.CurSelectTaskID = info.modelId;
            end
        end
    else
        GameCenter.LuaTaskManager:SetBehaviorTag(info.useItems.model, info.useItems.needNum, info.useItems.talkId,
        info.useItems.xPos, info.useItems.yPos, info.useItems.itemId, info.useItems.type, _behavior)
        _behavior.Type = _cfg.TaskType
        _behavior.TaskTarget.Count = info.useItems.num;
        GameCenter.LuaTaskManager:AddBehavior(info.modelId, _behavior)
        _behavior:SetTargetDes()
        self.Data.TargetDes = _behavior.Des
    end
    self.Data.PromptStr = DataConfig.DataMessageString.Get("C_TASK_SHOUXILEVELUP");
end

-- Get the task reward string
function DailyTask:GetRwardStr(cfg, starNum)
    local _reward_Str = nil
    if cfg ~= nil then
        if starNum == DailyTaskStarNum.Star_0 then
            _reward_Str = cfg.Rewards0
        elseif starNum == DailyTaskStarNum.Star_1 then
            _reward_Str = cfg.Rewards1
        elseif starNum == DailyTaskStarNum.Star_2 then
            _reward_Str = cfg.Rewards2
        elseif starNum == DailyTaskStarNum.Star_3 then
            _reward_Str = cfg.Rewards3
        elseif starNum == DailyTaskStarNum.Star_4 then
            _reward_Str = cfg.Rewards4
        elseif starNum == DailyTaskStarNum.Star_5 then
            _reward_Str = cfg.Rewards5
        end
    end
    return _reward_Str;
end

function DailyTask:OnGetAccessNpcId(id)
    local _ret = 0
    local _cfg = DataConfig.DataTaskDaily[id]
    if _cfg ~= nil then
        _ret = _cfg.ConditionsNpc
    end
    return _ret
end

-- Get the NPC id of the submitted task
function DailyTask:OnGetSubmitNpcId(id)
    local _ret = 0
    local _cfg = DataConfig.DataTaskDaily[id]
    if _cfg ~= nil then
        _ret = _cfg.OverNpc
    end
    return _ret
end

-- Update daily description
function DailyTask:OnUpdateTask(behavior)
    -- Update task goal description
    if behavior ~= nil then
        behavior:SetTargetDes()
        self.Data.TargetDes = behavior.Des
    end
end

function DailyTask:OnGetTaskTarget(id)
    local _ret = ""
    local _cfg = DataConfig.DataTaskDaily[id]
    if _cfg ~= nil then
        _ret = _cfg.GoalNpc
    end
    return _ret
end

function DailyTask:OnGetTaskXZ(id)
    local _ret = ""
    local _cfg = DataConfig.DataTaskDaily[id]
    if _cfg ~= nil then
        _ret = _cfg.TaskXZ
    end
    return _ret
end

function DailyTask:OnGetPlanShowEnter(id)
    local _ret = ""
    local _cfg = DataConfig.DataTaskDaily[id]
    if _cfg ~= nil then
        _ret = _cfg.PlanesShowEnter
    end
    return _ret
end

function DailyTask:OnGetNewType()
    return self.Data.Cfg.TargetType
end

function DailyTask:OnGetUIDes(count, tCount)
    return UIUtils.CSFormat(self.Data.Cfg.ConditionsDescribe, count, count)
end

function DailyTask:OnSubMitTaskOpenPanel()
    return self.Data.Cfg.OverTaskFunction
end

function DailyTask:OnIsAuto()
    return self.Data.Cfg.AutoCommit == 0
end

function DailyTask:OnGetJinDuDes(count, tCount)
    return UIUtils.CSFormat(self.Data.Cfg.ConditionsDescribe, count, tCount);
end

function DailyTask:OnAccessTask()
    PlayerBT.Task:TaskTalkToNpc(self.Data.AccessNpcID, self.Data.Id, true, self.Data.Cfg.OpenPanel)
end

return DailyTask
