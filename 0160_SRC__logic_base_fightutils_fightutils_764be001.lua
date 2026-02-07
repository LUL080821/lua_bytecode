------------------------------------------------
-- Author:
-- Date: 2019-05-13
-- File: FightUtils.lua
-- Module: FightUtils
-- Description: General tool for combat effectiveness calculation
------------------------------------------------

local FightUtils = {}
function FightUtils.GetPropetryPower(table)
    local _power = 0
    for k, v in pairs(table) do
        local _param = 0.0
        local _item = DataConfig.DataAttributeAdd[k]
        if _item ~= nil then
            _param = _item.Variable
        end
        _power = _power + v * (_param / 10000)
    end
    return math.floor(_power)
end

function FightUtils.GetPropetryPowerByList(list)
    local _power = 0
    for i = 1, #list do
        local _attId = list[i][1]
        local _attValue = list[i][2]
        local _param = 0.0
        local _item = DataConfig.DataAttributeAdd[_attId]
        if _item ~= nil then
            _param = _item.Variable
        end
        _power = _power + _attValue * (_param / 10000)
    end
    return math.floor(_power)
end
return FightUtils