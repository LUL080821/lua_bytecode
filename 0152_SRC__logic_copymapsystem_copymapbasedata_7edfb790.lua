------------------------------------------------
-- Author: 
-- Date: 2019-04-19
-- File: CopyMapBaseData.lua
-- Module: CopyMapBaseData
-- Description: Copy basic data
------------------------------------------------

-- Constructor
local CopyMapBaseData = {
    -- int copy ID
    CopyID = 0,
    -- Copy configuration
    CopyCfg = nil,
    -- Whether the requirements task is completed
    TaskFinish = false,
    -- Is the requirement level completed?
    LevelFinish = false,
    -- Is bool enabled?
    IsOpen = false,
}

function CopyMapBaseData:New(cfgData)
    local _m = Utils.DeepCopy(self);
    _m.CopyID = cfgData.Id;
    _m.CopyCfg = cfgData;
    _m.IsOpen = false;
    return _m;
end

return CopyMapBaseData;