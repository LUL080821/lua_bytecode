------------------------------------------------
-- Author: 
-- Date: 2019-04-19
-- File: ManyCopyMapData.lua
-- Module: ManyCopyMapData
-- Description: Multiple copy data
------------------------------------------------

local CopyMapBaseData = require("Logic.CopyMapSystem.CopyMapBaseData")

-- Constructor
local ManyCopyMapData = {
    -- Current clearance times
    JionCount = 0,
    -- The remaining free times
    FreeCount = 0,
    -- The remaining purchases
    VIPCount = 0,
    -- Number of times you can buy it
    CanBuyCount = 0,
    -- Current merge times
    CurMergeCount = 0,
};

function ManyCopyMapData:New(cfgData)
    local _n = Utils.DeepCopy(self);
    local _mn = setmetatable(_n, {__index = CopyMapBaseData:New(cfgData)});
    return _mn;
end

-- Analyze basic data
function ManyCopyMapData:ParseBaseMsg(msg)
    
end

-- Parse copy data
function ManyCopyMapData:ParseMsg(msg)
    self:ParseCountData(msg)
    self.CurMergeCount = msg.mergeCount
end

-- Number of parsed data
function ManyCopyMapData:ParseCountData(msg)
    -- Number of participations
    self.JionCount = msg.maxCount - msg.remainCount
    -- Total number of free times
    local _allFreeCount = msg.maxCount - msg.buyCount
    if self.JionCount > _allFreeCount then
        -- The number of participations is greater than the total number of free times, which means that the number of free times has been used up.
        self.FreeCount = 0
        self.VIPCount = msg.remainCount
    else
        -- The number of participations is less than the total number of free times, indicating that there are still free times
        self.FreeCount = _allFreeCount - self.JionCount
        self.VIPCount = msg.buyCount
    end
    self.CanBuyCount = msg.canBuyCount
end

return ManyCopyMapData;