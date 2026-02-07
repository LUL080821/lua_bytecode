------------------------------------------------
-- Author: 
-- Date: 2019-05-8
-- File: CopyMapOpenState.lua
-- Module: CopyMapOpenState
-- Description: Copy open status data
------------------------------------------------

-- Constructor
local CopyMapOpenState = {
    -- int copy ID
    CopyID = 0,
    -- Current status
    CurState = CopyMapStateEnum.NotOpen,
    -- Remaining time, determines the meaning based on the current state
    -- 0 is not turned on as the countdown for next time
    -- 1 Wait for the countdown to enter
    -- 2 Current battle countdown
    RemainTime = 0.0,
    -- The time to synchronize the data, used to calculate the specific remaining time
    SyncTime = 0.0,
}

function CopyMapOpenState:New()
    local _m = Utils.DeepCopy(self);
    _m.CopyID = 0;
    _m.CurState = CopyMapStateEnum.NotOpen;
    _m.RemainTime = 0.0;
    _m.SyncTime = 0.0;
    return _m
end

-- Get the specific remaining time
function CopyMapOpenState:GetReaminTime()
    return self.RemainTime - (Time.GetRealtimeSinceStartup() - self.SyncTime);
end

-- Analyze data
function CopyMapOpenState:ParseMsg(msg)
    self.CopyID = msg.cloneType;
    self.CloneState = msg.cloneState;
    self.RemainTime = msg.cloneValue;
    self.SyncTime = Time.GetRealtimeSinceStartup();
end

return CopyMapOpenState