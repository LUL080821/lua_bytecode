------------------------------------------------
-- Author:
-- Date: 2021-03-18
-- File: HolyEquipPart.lua
-- Module: HolyEquipPart
-- Description: Holy Clothing Part
------------------------------------------------
local L_HolyEquip = CS.Thousandto.Code.Logic.HolyEquip
local L_FightUtils = require "Logic.Base.FightUtils.FightUtils"

local HolyEquipPart = {
    -- Part ID
    Part  = 0,
    -- Strengthening level
    Level = 0,
    -- Equipment example
    Equip = nil,
    -- Level configuration
    LevelCfg = nil,
    -- Is it full level
    IsMaxLevel = false,
    -- Strengthen attributes
    LevelPros = nil,
    -- Strengthen combat power
    LevelPower = 0,
}

function HolyEquipPart:New(info)
    local _m = Utils.DeepCopy(self)
    _m.Part = info.part
    _m.Level = info.level
    if info.holyEquipItem ~= nil then
        _m.Equip = L_HolyEquip.CreateByLuaMsg(info.holyEquipItem)
        _m.Equip.ContainerType = ContainerType.ITEM_LOCATION_EQUIP
        _m.LevelPower = 0
        _m.LevelCfg = DataConfig.DataEquipHolyLevelup[(_m.Part - 101) % 11 * 10000 + _m.Level]
        local _typeCfg = DataConfig.DataEquipHolyType[GameCenter.HolyEquipSystem:GetTypeIdByPart(_m.Part)]
        if _typeCfg ~= nil then
            _m.IsMaxLevel = _m.Level >= _typeCfg.MaxLevel
        else
            _m.IsMaxLevel = true
        end
        _m.LevelPros = {}
        local _attTable = Utils.SplitStrByTableS(_m.LevelCfg.Att, {';', '_'})
        for i = 1, #_attTable do
            local _type = _attTable[i][1]
            local _value = _attTable[i][2]
            local _oriValue = _m.LevelPros[_type]
            if _oriValue == nil then
                _oriValue = 0
            end
            _m.LevelPros[_type] = _oriValue + _value
        end
        _m.LevelPower = L_FightUtils.GetPropetryPower(_m.LevelPros)
    else
        _m.LevelPros = nil
        _m.Equip = nil
    end
    return _m
end

return HolyEquipPart