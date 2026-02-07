
------------------------------------------------
-- Author:
-- Date: 2019-07-15
-- File: GrowthWayTaskData.lua
-- Module: GrowthWayTaskData
-- Description: Daily Task Data on the Road to Growth
------------------------------------------------
-- Quote
local ItemData = require "Logic.ServeCrazy.ServeCrazyItemData"
local GrowthWayTaskData = {
    CfgId = 0,
    -- Total number of tasks
    TotalCount = 0,
    -- Current number of completed times
    CurCount = 0,
    -- Complete reward stars
    StarNum = 0,
    -- Open UIid
    OpenUIId = 0,
    -- Open parameters
    OpenParam = 0,
    -- Task Description
    TaskDes = nil,
    -- Item displayed
    Item = nil,
    -- Whether to receive it
    IsRward = false,
    Cfg = nil,
    State = 0,
}

function GrowthWayTaskData:New()
    local _m = Utils.DeepCopy(self)
    return _m
end
-- Analyze data
function GrowthWayTaskData:Parase(cfg)
    if cfg ~= nil then
        self.CfgId = cfg.Id
        local list = Utils.SplitStr(cfg.Condition,'_')
        self.TotalCount = tonumber(list[#list])
        self.StarNum = cfg.Rate
        self.OpenUIId = cfg.RelationUI
        self.OpenParam = cfg.RelationSubUI
        self.TaskDes = cfg.Des
        self.Item = ItemData:New()
        self.Item:Parase(cfg.Reward)
        self.Cfg = cfg
    end
end

-- Parsing the message
function GrowthWayTaskData:ParaseMsg(msg)
    if not msg.IsRward and msg.state then
        --GameCenter.GrowthWaySystem.CurGold = GameCenter.GrowthWaySystem.CurGold - self.Cfg.Worth
    end
    self.CurCount = msg.progress
    self.IsRward = msg.state
    if self.IsRward then
        self.State = 3
    else
        if self.CurCount >= self.TotalCount then
            self.State = 1
        else
            self.State = 2
        end
    end
end

-- Can I get props
function GrowthWayTaskData:CanRewardItem()
    if self.CurCount>=self.TotalCount then
        if not self.IsRward then
            return true
        end
    end
    return false
end

return GrowthWayTaskData