------------------------------------------------
-- Author: Wang Sheng
-- Date: 2021-03-19
-- File: GuildTask.lua
-- Module: GuildTask
-- Description: Trade Union Task Example
------------------------------------------------
-- Quote
local L_TaskBase = require "Logic.TaskSystem.Instance.TaskBase"
local GuildTask = {}

function GuildTask:New(info, isAccess)
    local _m = Utils.Extend(L_TaskBase:New(), self)
    _m:SetTask(info, isAccess)
    return _m
end

function GuildTask:SetTask(info, isAccess)
    local _cfg = DataConfig.DataTaskConquer[info.modelId]
    if _cfg == nil then
        Debug.LogError("DailyTask Id Is Error");
        return
    end
    local _name = DataConfig.DataMessageString.Get("C_KILL_CEHUA")
    self.Data:SetData(info.modelId, TaskType.Guild, self:GetAccessNpcId(info.modelId),
        self:GetSubmitNpcId(info.modelId), isAccess, _cfg.TaskType, _name, nil, nil, _cfg.Rewards, info.monsters.mapId, nil, nil, true)
    self.Data.Name = UIUtils.CSFormat(DataConfig.DataMessageString.Get("TASK_CUR_COUNT"), info.count)
    self.Data.TypeName = _cfg.TapeName
    self.Data.IconId = _cfg.PromptIcon
    if _cfg.ConquerSubtype == 0 then
        self.Data.Sort = TaskSort.GuildWeek
    elseif _cfg.ConquerSubtype == 1 then
        self.Data.Sort = TaskSort.GuildDaily
    end
    self.Data.SubType = _cfg.ConquerSubtype
    self.Data.Cfg = _cfg
    self.Data.Count = info.count
    self.Data.AllStep = info.maxCount
    if isAccess then
        GameCenter.LuaTaskManager:AddTask(self)
    else
        GameCenter.LuaTaskManager:AddTaskByType(TaskType.Not_Recieve, self)
    end
    local _behavior = GameCenter.LuaTaskManager:CreateBehavior(_cfg.TaskType)
    if _behavior == nil then
        -- Debug.LogError("Creation behavior failed")
        return
    end
    _behavior.Id = info.modelId;
    GameCenter.LuaTaskManager:SetBehaviorTag(_cfg.GoalNpc, _behavior);
    GameCenter.LuaTaskManager:SetBehaviorTag(info.monsters.model, info.monsters.needNum, info.monsters.talkId,
        info.monsters.xPos, info.monsters.yPos, info.monsters.itemId, info.monsters.type, _behavior)
    _behavior.Type = _cfg.TaskType
    _behavior.TaskTarget.Count = info.monsters.num
    GameCenter.LuaTaskManager:AddBehavior(info.modelId, _behavior)
    _behavior:SetTargetDes()
    self.Data.TargetDes = _behavior.Des
    self.Data.UiDes = _behavior.UiDes
    if isAccess then
        if GameCenter.LuaTaskManager:IsInNotRecieveContainer(info.modelId) then
            -- The player takes the initiative to receive the task and removes the task container without the task. Execute the task behavior.
            GameCenter.LuaTaskManager:RemoveTaskInNotRecieve(info.modelId);
            GameCenter.TaskController:Run(self.Data.Id)

        else
            if GameCenter.LuaTaskManager.IsAutoGuildTask then
                if GameCenter.MandateSystem ~= nil then
                    GameCenter.MandateSystem:End()
                end
                GameCenter.TaskController:Run(self.Data.Id)
            end
            if GameCenter.LuaTaskManager.IsWiptOutClick then
                -- If it's click to sweep
                GameCenter.LuaTaskManager.CurSelectTaskID = info.modelId;
            end
        end
    end
end

function GuildTask:OnGetAccessNpcId(id)
    local _ret = 0
    local _cfg = DataConfig.DataTaskConquer[id]
    if _cfg ~= nil then
        _ret = _cfg.ConditionsNpc
    end
    return _ret
end

-- Get the NPC id of the submitted task
function GuildTask:OnGetSubmitNpcId(id)
    local _ret = 0
    local _cfg = DataConfig.DataTaskConquer[id]
    if _cfg ~= nil then
        _ret = _cfg.OverNpc
    end
    return _ret
end

-- Update daily description
function GuildTask:OnUpdateTask(behavior)
    -- Update task goal description
    if behavior ~= nil then
        behavior:SetTargetDes()
        self.Data.TargetDes = behavior.Des
    end
end

function GuildTask:OnGetTaskTarget(id)
    local _ret = ""
    local _cfg = DataConfig.DataTaskConquer[id]
    if _cfg ~= nil then
        _ret = _cfg.GoalNpc
    end
    return _ret
end

function GuildTask:OnGetTaskXZ(id)
    local _ret = ""
    local _cfg = DataConfig.DataTaskConquer[id]
    if _cfg ~= nil then
        _ret = _cfg.TaskXZ
    end
    return _ret
end

function GuildTask:OnGetPlanShowEnter(id)
    local _ret = ""
    local _cfg = DataConfig.DataTaskConquer[id]
    if _cfg ~= nil then
        _ret = _cfg.PlanesShowEnter
    end
    return _ret
end

-- Can union support be provided
function GuildTask:OnCanSupport()
    return self.Data.Cfg.GuildSupport == 1
end

function GuildTask:OnGetNewType()
    return self.Data.Cfg.TargetType
end

function GuildTask:OnGetUIDes(count, tCount)
    return UIUtils.CSFormat(self.Data.Cfg.ConditionsDescribe, count, count)
end

function GuildTask:OnSubMitTaskOpenPanel()
    return self.Data.Cfg.OverTaskFunction
end

function GuildTask:OnIsAuto()
    return self.Data.Cfg.AutoCommit == 0
end

function GuildTask:OnGetJinDuDes(count, tCount)
    return UIUtils.CSFormat(self.Data.Cfg.ConditionsDescribe, count, tCount)
end

return GuildTask
