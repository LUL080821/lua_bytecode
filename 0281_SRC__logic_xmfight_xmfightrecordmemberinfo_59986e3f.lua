-- Author: 
-- Date: 2020-02-18
-- File: XmFightRecordMemberInfo.lua
-- Module: XmFightRecordMemberInfo
-- Description: Statistics of the Immortal Alliance War
-----------------------------------------------
local XmFightRecordMemberInfo =
{
    -- Sort
    Rank = 0,
    -- name
    Name = "",
    -- direct
    Career = 0,
    -- integral
    Score = 0,
    -- Number of kills
    KillNum = nil,

    -- Destroyed quantity
    DestroyNum = nil,

    -- Number of repairs
    RepairNum = nil,

    -- Number of times the city breaks
    BreakNum = nil,
    
}

-- Constructor
function XmFightRecordMemberInfo:New(pb_msg)
    if pb_msg then 
        local _m = Utils.DeepCopy(self);
        _m.Name = pb_msg.name;
        _m.Career = pb_msg.career;
        _m.Score = pb_msg.record;
        _m.KillNum = pb_msg.killNum;
        _m.DestroyNum = pb_msg.destroyNum;
        _m.RepairNum = pb_msg.repairNum;
        _m.BreakNum = pb_msg.breakNum;
        return _m;
    else
        return nil;
    end
end

-- Resolve member list
function XmFightRecordMemberInfo:Parse(msg_members)
   local _result = List:New();
   if msg_members ~= nil then
        for _,v in ipairs(msg_members) do
            _result:Add(XmFightRecordMemberInfo:New(v));
        end
        -- Sorting
        _result:Sort(function(a,b) 
                return a.Score > b.Score
            end );
        -- Set ranking
        for i=1,#_result do
            _result[i].Rank = i;
        end
    end
   return _result;
end

return XmFightRecordMemberInfo;