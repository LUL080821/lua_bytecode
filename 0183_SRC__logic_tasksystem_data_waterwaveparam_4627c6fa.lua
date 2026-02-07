------------------------------------------------
-- Author: Wang Sheng
-- Date: 2021-03-19
-- File: WaterWaveParam.lua
-- Module: WaterWaveParam
-- Description: Task Reward Data
------------------------------------------------
-- Quote
local WaterWaveParam = {
    -- Distance coefficient
    DistanceFactor = 0,
    -- Time coefficient
    TimeFactor = 0,
    -- The result coefficient of sin function
    TotalFactor = 0,
    -- Corrugated width
    WaveWidth = 0,
    -- The speed of ripple diffusion
    WaveSpeed = 0,
}
function WaterWaveParam:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

return WaterWaveParam
