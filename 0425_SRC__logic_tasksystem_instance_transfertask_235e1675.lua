------------------------------------------------
-- Author: Wang Sheng
-- Date: 2021-03-19
-- File: TransferTask.lua
-- Module: TransferTask
-- Description: Transfer task example
------------------------------------------------
-- Quote
local L_TaskBase = require "Logic.TaskSystem.Instance.TaskBase"
local TransferTask = {
}

function TransferTask:New(info, isAccess)
    local _m = Utils.Extend(L_TaskBase:New(), self)
    _m:SetTask(info, isAccess)
    return _m
end

function TransferTask:SetTask(info, isAccess)
    local _cfg = DataConfig.DataTaskGender[info.modelId]
    if _cfg == nil then
        return
    end
    self.Data:SetData(info.modelId, TaskType.ZhuanZhi, self:GetAccessNpcId(info.modelId),
        self:GetSubmitNpcId(info.modelId), isAccess, _cfg.TaskType, _cfg.TaskName, _cfg.Taksdesc, nil, _cfg.Rewards,
        info.target.mapId, nil, nil, true)
    self.Data.TypeName = _cfg.TapeName
    self.Data.Chapter_Name = _cfg.ChapterName
    self.Data.Chapter_Des = _cfg.ChapterDesc
    self.Data.Cfg = _cfg
    if isAccess then
        GameCenter.LuaTaskManager:AddTask(self)
    else
        GameCenter.LuaTaskManager:AddTaskByType(TaskType.Not_Recieve, self)
    end
    local _behavior = GameCenter.LuaTaskManager:CreateBehavior(_cfg.TaskType, info.modelId)
    if _behavior == nil then
        return
    end
    _behavior.Id = info.modelId
    GameCenter.LuaTaskManager:SetBehaviorTag(info.target.model, info.target.needNum, info.target.talkId,
        info.target.xPos, info.target.yPos, info.target.itemId, info.target.type, _behavior)
    _behavior.Type = _cfg.TaskType
    _behavior.TaskTarget.Count = info.target.num
    if isAccess then
        if GameCenter.LuaTaskManager:IsInNotRecieveContainer(info.modelId) then
            -- The player takes the initiative to receive the task and removes the task container without the task. Execute the task behavior.
            GameCenter.LuaTaskManager:RemoveTaskInNotRecieve(info.modelId)
            GameCenter.LuaTaskManager:AddBehavior(info.modelId, _behavior)
            GameCenter.TaskController:Run(self.Data.Id)

        else
            GameCenter.LuaTaskManager:AddBehavior(info.modelId, _behavior)
            if GameCenter.LuaTaskManager.IsAutoTransferTask and self.Data.Cfg.AutoTask ~= 0 then
                if GameCenter.MandateSystem ~= nil then
                    GameCenter.MandateSystem:End()
                end
                GameCenter.TaskController:Run(self.Data.Id)
                GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_START_DITRANSFER_TASK)
            end
        end
    end
    _behavior:SetTargetDes()
    self.Data.TargetDes = _behavior.Des
end

-- Get the npc id of the task
function TransferTask:OnGetAccessNpcId(id)
    local _ret = 0
    local _cfg = DataConfig.DataTaskGender[id]
    if _cfg ~= nil then
        _ret = _cfg.ConditionsNpc
    end
    return _ret
end

-- Get the submission task npc id
function TransferTask:OnGetSubmitNpcId(id)
    local _ret = 0
    local _cfg = DataConfig.DataTaskGender[id]
    if _cfg ~= nil then
        local _list = Utils.SplitNumber(_cfg.Endpath, '_')
        if _list ~= nil and #_list == 2 then
            _ret = _list[2]
        end
    end
    return _ret
end

-- Update job transfer description
-- Update daily description
function TransferTask:OnUpdateTask(behavior)
    -- Update task goal description
    if behavior ~= nil then
        behavior:SetTargetDes();
        self.Data.TargetDes = behavior.Des;
    end
end

function TransferTask:OnGetTaskTarget(id)
    local _ret = ""
    local _cfg = DataConfig.DataTaskGender[id]
    if _cfg ~= nil then
        _ret = _cfg.GoalNpc
    end
    return _ret
end

function TransferTask:OnGetTaskXZ(id)
    local _ret = ""
    local _cfg = DataConfig.DataTaskGender[id]
    if _cfg ~= nil then
        _ret = _cfg.TaskXZ
    end
    return _ret
end

function TransferTask:OnGetPlanShowEnter(id)
    local _ret = ""
    local _cfg = DataConfig.DataTaskGender[id]
    if _cfg ~= nil then
        _ret = _cfg.PlanesShowEnter
    end
    return _ret
end

function TransferTask:OnGetUIDes(count, tCount)
    return UIUtils.CSFormat(self.Data.Cfg.ConditionsDescribe, count, count)
end

function TransferTask:OnGetNewType()
    return self.Data.Cfg.TargetType
end

function TransferTask:OnIsAuto()
    return self.Data.Cfg.AutoTask == 0
end

function TransferTask:OnGetLimitPower()
    return self.Data.Cfg.ScoreLimit
end

function TransferTask:OnGetJinDuDes(count, tCount)
    local _ret = ""
    local _limit = self:GetLimitPower()
    if _limit > 0 then
        local _myPower = GameCenter.GameSceneSystem:GetLocalPlayerFightPower()
        if _myPower < _limit then
            local _str = DataConfig.DataMessageString.Get("Task_Score_Describe1")
            _str = _str.."\n"--UIUtils.CSFormat("{0}\n", DataConfig.DataMessageString[5738])
            _ret = _ret .. UIUtils.CSFormat(_str, _myPower, _limit)
        else
            _ret = _ret .. UIUtils.CSFormat("{0}\n", DataConfig.DataMessageString.Get("Task_Score_Describe2"))
        end
        _ret = _ret .. UIUtils.CSFormat(self.Data.Cfg.ConditionsDescribe, count, tCount)
    else
        _ret = UIUtils.CSFormat(self.Data.Cfg.ConditionsDescribe, count, tCount)
    end
    return _ret;
end

return TransferTask
