------------------------------------------------
-- Author: Wang Sheng
-- Date: 2021-03-19
-- File: TaskRewardData.lua
-- Module: TaskRewardData
-- Description: Task recommendation data
------------------------------------------------
-- Quote
local TaskRecommendData = {
    Id,
    DailyId,
    Des,
}
function TaskRecommendData:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

return TaskRecommendData
