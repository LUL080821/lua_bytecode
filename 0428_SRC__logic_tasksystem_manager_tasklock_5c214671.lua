------------------------------------------------
-- Au:: Wang Sheng
-- Date: 2021-03-19
-- File: TaskLock.lua
-- Module: TaskLock
-- Description: Task lock
------------------------------------------------
-- Quote
local TaskLock = {
    Id = 0,
    Tick = 0,
    Time = 60
}
function TaskLock:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

return TaskLock
