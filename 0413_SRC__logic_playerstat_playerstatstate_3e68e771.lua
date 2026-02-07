------------------------------------------------
-- Author:
-- Date: 2025-11-11
-- File: PlayerStatState.lua
-- Module: PlayerStatState
-- Description: PlayerStatState
------------------------------------------------
local PlayerStatState = {
    Config = nil,
    Values = nil,
}

function PlayerStatState:New(config)
    local _m = Utils.DeepCopy(self)
    _m.Config = config
    _m.Values = Dictionary:New()
    for stat, v in pairs(config) do
        local _value = v.default or 0
        _m.Values:Add(stat, _value)
    end
    return _m
end

function PlayerStatState:_ForceSet(stat, value)
    if not self.Config[stat] then
        return
    end

    local _min = self.Config[stat].min or 0
    local _max = self.Config[stat].max or 999
    local clamped = math.Clamp(value, _min, _max)

    self.Values[stat] = clamped
end

function PlayerStatState:CopyFrom(other)
    for stat, value in pairs(other.Values) do
        if self.Config[stat] then
            self.Values[stat] = value
        end
    end
end

function PlayerStatState:CloneValues()
    local clone = {}
    for k, v in pairs(self.Values) do
        clone[k] = v
    end
    return clone
end

function PlayerStatState:Get(stat)
    return self.Values[stat] or 0
end

function PlayerStatState:Add(stat, amount)
    if not self.Values[stat] then
        return false, "Invalid stat"
    end

    local _conf = self.Config[stat]
    local newValue = self.Values[stat] + amount

    if newValue > _conf.max then
        self.Values[stat] = _conf.max
        return true, "Reached max"
    end
    if newValue < _conf.min then
        self.Values[stat] = _conf.min
        return true, "Below min"
    end

    self.Values[stat] = newValue
    return true
end

function PlayerStatState:Sub(stat, amount)
    return self:Add(stat, -amount)
end

function PlayerStatState:IsMax(stat)
    local _conf = self.Config[stat]
    return self.Values[stat] >= _conf.max
end

function PlayerStatState:IsAtBase(stat, baseState)
    return self.Values[stat] <= baseState:Get(stat)
end

return PlayerStatState