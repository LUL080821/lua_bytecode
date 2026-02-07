
------------------------------------------------
-- Author:
-- Date: 2019-07-19
-- File: ServerActiveTaskData.lua
-- Module: ServerActiveTaskData
-- Description: Service activity task data
------------------------------------------------
-- Quote
local ServerActiveTaskData = {
    -- Configuration table id
    CfgId = 0,
    -- Current completion degree
    CurNum = 0,
    -- Total times
    TotalNum = 0,
    -- Number of remaining parts
    LeftNum = 0,
    -- Receive status 0: Not met the requirement 1: Can be collected 2: Received
    RewardState = 0,
    -- Condition description
    Condition = nil,
    -- Is it restricted to collect
    IsLimit = false,
    -- Reward props List
    ItemList = List:New()
}
function ServerActiveTaskData:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

function ServerActiveTaskData:Parase(cfg)
    self.CfgId = cfg.Id
    local list = Utils.SplitStr(cfg.Condition,'_')
    if list ~= nil then
        self.TotalNum = tonumber(list[#list])
    end
    -- Set whether to limit
    self.IsLimit = cfg.LimitTime ~= 0
    self.Condition = cfg.Des
end

function ServerActiveTaskData:ParaseMsg(msg)
    self.CurNum = msg.progress
    self.RewardState = msg.state
    self.LeftNum = msg.remain
end
return ServerActiveTaskData