------------------------------------------------
-- Author:
-- Date: 2021-03-01
-- File: GuildLogData.lua
-- Module: GuildLogData
-- Description: Basic data of gang logs
------------------------------------------------
local GuildLogData ={
    -- type
    Type = 0,
    -- name
    str = List:New(),
    -- time
    Time = 0,
    formate = nil,
}

function GuildLogData:New()
    local _m = Utils.DeepCopy(self)
    _m.Type = 0
    _m.str = List:New()
    _m.Time = 0
    _m.formate = nil
    return _m
end
return GuildLogData