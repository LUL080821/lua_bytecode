
------------------------------------------------
-- Author:
-- Date: 2019-04-29
-- File: GodBookData.lua
-- Module: GodBookData
-- Description: Heavenly Book Data
------------------------------------------------
local AmuletData = require "Logic.GodBook.AmuletData"

local GodBookData = {
    ID = 0,                                     -- The ID corresponding to the DataAmulet table
    Status = false,                             -- Talisman activation status
    TaskList = List:New(),                      -- Task list corresponding to the spell
}

function GodBookData:New(info)
    local _m = Utils.DeepCopy(self)
    _m:Init(info)
    _m:SortData()
    return _m
end

-- initialization
function GodBookData:Init(info)
    self.ID = info.id
    self.Status = info.status
    if info.list ~= nil then
        self.TaskList:Clear()
        for i = 1, #info.list do
            self.TaskList:Add(AmuletData:New(info.list[i]))
        end
    end
end

-- Task List Sort Received > In Progress > Received
function GodBookData:SortData()
    table.sort( self.TaskList, function(a, b)
        if a.Status == b.Status then
            return a.TargetValue < b.TargetValue
        end
        return a.Status < b.Status
    end)
end

return GodBookData