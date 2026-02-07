------------------------------------------------
-- Author: Wang Sheng
-- Date: 2021-03-19
-- File: BranchTask.lua
-- Module: BranchTask
-- Description: Side Task Example
------------------------------------------------
-- Quote
local L_TaskBase = require "Logic.TaskSystem.Instance.TaskBase"
local BranchTask = {
}

function BranchTask:New(info)
    local _m = Utils.Extend(L_TaskBase:New(), self)
    _m:SetTask(info)
    return _m
end

function BranchTask:SetTask(info)
    local _cfg = DataConfig.DataTaskBranch[info.modelId]
    if _cfg == nil then
        Debug.LogError("MainTask Id Is Error");
        return
    end
    self.Data:SetData(info.modelId, TaskType.Branch, 0, 0, true, _cfg.ConditionsType, _cfg.Name, _cfg.TsakDescribe,
        _cfg.ConditionsDescribe, _cfg.TaskReward)
    self.Data.TypeName = _cfg.TypeName
    self.Data.Cfg = _cfg
    GameCenter.LuaTaskManager:AddTask(self)
    local _behavior = GameCenter.LuaTaskManager:CreateBehavior(_cfg.ConditionsType)
    if _behavior == nil then
        Debug.LogError("Creation behavior failed");
        return
    end
    _behavior.Id = info.modelId
    GameCenter.LuaTaskManager:SetBehaviorTag(info.monsters.model, info.monsters.needNum, info.monsters.talkId,
        info.monsters.xPos, info.monsters.yPos, info.monsters.itemId, info.monsters.type, _behavior);
    _behavior.Type = _cfg.ConditionsType
    _behavior.TaskTarget.Count = info.monsters.num;
    GameCenter.LuaTaskManager:AddBehavior(info.modelId, _behavior)
    _behavior:SetTargetDes()
    self.Data.TargetDes = _behavior.Des;
end

-- Update the branch description
-- Update daily description
function BranchTask:OnUpdateTask(behavior)
    -- Update task goal description
    if behavior ~= nil then
        if behavior.TaskTarget.Count >= behavior.TaskTarget.TCount then
            self.Data.TargetDes = self:GetJinDuDes()
        else
            self.Data.TargetDes = UIUtils.CSFormat(self.Data.Cfg.ConditionsDescribe, behavior.TaskTarget.Count,
                                      behavior.TaskTarget.TCount)
        end
        behavior.Des = self.Data.TargetDes;
    end
end

function BranchTask:OnGetNewType()
    return self.Data.Cfg.TargetType
end

function BranchTask:OnGetUIDes(count, tCount)
    return UIUtils.CSFormat(self.Data.Cfg.ConditionsDescribe, count, count)
end

function BranchTask:OnSubMitTaskOpenPanel()
    return self.Data.Cfg.OverTaskFunction
end

function BranchTask:OnGetSort()
    return self.Data.Cfg.BranchSort
end

function BranchTask:OnIsAuto()
    return false
end

function BranchTask:OnGetJinDuDes(count, tCount)
    return UIUtils.CSFormat(self.Data.Cfg.ConditionsDescribe, count, tCount);
end

return BranchTask
