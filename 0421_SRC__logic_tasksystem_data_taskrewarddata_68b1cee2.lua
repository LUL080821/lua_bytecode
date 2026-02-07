------------------------------------------------
-- Author: Wang Sheng
-- Date: 2021-03-19
-- File: TaskRewardData.lua
-- Module: TaskRewardData
-- Description: Task Reward Data
------------------------------------------------
-- Quote
local TaskRewardData = {
    ID = 0, -- Prop ID
    Num = 0, -- Number of
    ShowSize = 1, -- Display prop camera size
    Name = nil, -- Show prop name
    IsBind = false -- Whether to bind
}
function TaskRewardData:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

return TaskRewardData
