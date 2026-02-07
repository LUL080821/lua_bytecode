------------------------------------------------
-- Author:
-- Date: 2021-02-25
-- File: ServerCharInfo.lua
-- Module: ServerCharInfo
-- Description: Information about server roles
------------------------------------------------

local ServerCharInfo = {
    -- Role ID
    ID,
    -- Server ID
    ServerId,
    -- Character name
    Name,
    -- Role Career
    Career,
    -- Role Level
    Level,
    -- Combat Power Value
    PowerValue,
}

function ServerCharInfo:New()
    local _m = Utils.DeepCopy(self);
    return _m;    
end



return ServerCharInfo;