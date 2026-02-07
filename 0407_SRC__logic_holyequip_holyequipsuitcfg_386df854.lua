------------------------------------------------
-- Author:
-- Date: 2021-03-18
-- File: HolyEquipSuitCfg.lua
-- Module: HolyEquipSuitCfg
-- Description: Holy suit attribute configuration
------------------------------------------------

local HolyEquipSuitCfg = {
    Cfg = nil,
    Pros2 = nil,
    Pros4 = nil,
    Pros5 = nil,
    Pros6 = nil,
    MultiplePros2 = nil,
    MultiplePros4 = nil,
    MultiplePros5 = nil,
    MultiplePros6 = nil,
}

local function L_ParsePropByString(text)
    local _result = {}
    local _paramTable = Utils.SplitStrByTableS(text, {';', '_'})
    for i = 1, #_paramTable do
        local _type = _paramTable[i][1]
        local _value = _paramTable[i][2]
        local _oriValue = _result[_type]
        if _oriValue == nil then
            _oriValue = 0
        end
        _result[_type] = _oriValue + _value
    end
    return _result
end
   
function HolyEquipSuitCfg:New(cfg)
    local _m = Utils.DeepCopy(self)
    _m.Cfg = cfg
    _m.Pros2 = L_ParsePropByString(cfg.Attribute2)
    _m.Pros4 = L_ParsePropByString(cfg.Attribute4)
    _m.Pros5 = L_ParsePropByString(cfg.Attribute5)
    _m.Pros6 = L_ParsePropByString(cfg.Attribute6)
    _m.MultiplePros2 = L_ParsePropByString(cfg.ElementAttribute2)
    _m.MultiplePros4 = L_ParsePropByString(cfg.ElementAttribute4)
    _m.MultiplePros5 = L_ParsePropByString(cfg.ElementAttribute5)
    _m.MultiplePros6 = L_ParsePropByString(cfg.ElementAttribute6)
    return _m
end

return HolyEquipSuitCfg