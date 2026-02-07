------------------------------------------------
-- Author: Wang Sheng
-- Date: 2021-03-19
-- File: TaskTarget.lua
-- Module: TaskTarget
-- Description: Mission Objective
------------------------------------------------
-- Quote
local TaskTarget = {
    TagId = 0, -- Mission target id
    Count = 0, -- Number of completed times
    TCount = 0, -- Total times
    TalkId = 0, -- Dialogue id
    ItemId = 0, -- Item id
    PosX = 0, -- X coordinate
    PosY = 0, -- Y coordinates
    Param = 0, -- Added parameters
    IsEnd = false, -- Whether the goal is completed
    TagName = nil, -- Target name
    MapName = nil -- Target map name
}
function TaskTarget:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

function TaskTarget:IsReach(type)
    self.IsEnd = false;
    if  type == TaskBeHaviorType.Talk 
        or type == TaskBeHaviorType.Level 
        or type == TaskBeHaviorType.CopyKill 
        or type == TaskBeHaviorType.PassCopy
        or type == TaskBeHaviorType.OpenUI
        or type == TaskBeHaviorType.Kill
        or type == TaskBeHaviorType.Collection
        or type == TaskBeHaviorType.CopyKillForUI
        or type == TaskBeHaviorType.KillPlayer 
        or type == TaskBeHaviorType.FindCharactor
        or type == TaskBeHaviorType.SubMit
        or type == TaskBeHaviorType.ArrivePos 
        or type == TaskBeHaviorType.OpenUIToSubMit
        or type == TaskBeHaviorType.MountFlyUp
        or type == TaskBeHaviorType.CollectItem
        or type == TaskBeHaviorType.CollectRealItem
        or type == TaskBeHaviorType.ArrivePosEx 
        or type == TaskBeHaviorType.ArriveToAnim
        or type == TaskBeHaviorType.AddFriends
        or type == TaskBeHaviorType.KillMonsterTrainMap
        or type == TaskBeHaviorType.KillMonsterDropItem 
    then
        if self.Count >= self.TCount then
            self.IsEnd = true;
        end
    end
    return self.IsEnd
end

return TaskTarget
