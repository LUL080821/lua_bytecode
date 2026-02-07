
------------------------------------------------
-- Author:
-- Date: 2019-07-19
-- File: ServerActiveComData.lua
-- Module: ServerActiveComData
-- Description: General data model for service opening activities
------------------------------------------------
-- Quote
local ActiveTaskData = require "Logic.ServerActive.ServerActiveTaskData"
local ServerActiveComData = {
    -- Title Image Name
    TextureName = nil,
    -- Title description
    TitleDes = nil,
    -- Task List
    ListTask = List:New()
}
function ServerActiveComData:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

function ServerActiveComData:ParaseCfg(cfg)
    if cfg == nil  then
        return
    end
    local task = ActiveTaskData:New()
    task:Parase(cfg)
    self.ListTask:Add(task)
end

-- Resolve server messages
function ServerActiveComData:ParaseMsg(msg)
    for i = 1,#self.ListTask do
        if self.ListTask[i].CfgId == msg.id then
            self.ListTask[i]:ParaseMsg(msg)
            break
        end
    end
end

-- Add data
function ServerActiveComData:AddData(cfg)
    local task = ActiveTaskData:New()
    task:Parase(cfg)
    self.ListTask:Add(task)
end
return ServerActiveComData