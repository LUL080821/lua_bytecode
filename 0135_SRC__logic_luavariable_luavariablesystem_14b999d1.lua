------------------------------------------------
-- Author:
-- Date: 2019-07-17
-- File: LuaVariableSystem.lua
-- Module: LuaVariableSystem
-- Description: Lua-end variable system
------------------------------------------------
local LuaVariableSystem = {}

function LuaVariableSystem:GetVariableShowText(functionVariableIdCode, curValue, value, simplifyValue)
    -- if functionVariableIdCode == FunctionVariableIdCode.XXXXXXXXXXXX then
        -- TODO
    -- end
    if UnityUtils.GetObjct2Int(functionVariableIdCode) == FunctionVariableIdCode.WanYaoJuanNum then
        return UIUtils.CSFormat(DataConfig.DataMessageString.Get("HellLayer"), value)
    end

    -- The last return value, if there are other required return values, please implement it above
    if simplifyValue then
        local _curText = ""
        if curValue > 1000000 then
            if curValue % 1000000 == 0 then
                _curText = string.format( "%dM", curValue // 1000000)
            else
                _curText = string.format( "%.2fM", curValue / 1000000)
            end
        elseif curValue > 1000 then
            if curValue % 1000 == 0 then
                _curText = string.format( "%dK", curValue // 1000)
            else
                _curText = string.format( "%.2fK", curValue / 1000)
            end
        else
            _curText = tostring(curValue)
        end

        local _valueText = ""
        if value > 1000000 then
            if value % 1000000 == 0 then
                _valueText = string.format( "%dM", value // 1000000)
            else
                _valueText = string.format( "%.2fM", value / 1000000)
            end
        elseif value > 1000 then
            if value % 1000 == 0 then
                _valueText = string.format( "%dM", value // 1000)
            else
                _valueText = string.format( "%.2fM", value / 1000)
            end
        else
            _valueText = tostring(value)
        end
        return string.format( "%s/%s", _curText, _valueText)
    end
    return string.format( "%d/%d", curValue, value)
end

function LuaVariableSystem:GetVariableShowProgress(functionVariableIdCode, curValue, value)
    -- if functionVariableIdCode == FunctionVariableIdCode.XXXXXXXXXXXX then
        -- TODO
    -- end
    if UnityUtils.GetObjct2Int(functionVariableIdCode) == FunctionVariableIdCode.WanYaoJuanNum then
        return curValue / value
    end

    -- The last return value, if there are other required return values, please implement it above
    return curValue / value
end

function LuaVariableSystem:IsVariableReach(functionVariableIdCode, curValue, value)
    -- if functionVariableIdCode == FunctionVariableIdCode.XXXXXXXXXXXX then
        -- TODO
    -- end
    if UnityUtils.GetObjct2Int(functionVariableIdCode) == FunctionVariableIdCode.WanYaoJuanNum then
        return curValue >= value
    end

    -- The last return value, if there are other required return values, please implement it above
    return curValue >= value
end

function LuaVariableSystem:GetVariableValue(functionVariableIdCode)
    -- if functionVariableIdCode == FunctionVariableIdCode.XXXXXXXXXXXX then
        -- TODO
    -- end
    if functionVariableIdCode == FunctionVariableIdCode.WanYaoJuanNum then
        -- The number of layers that have been passed by Wan Yao Scroll, so -1
        local _towerData = GameCenter.CopyMapSystem:FindCopyDataByType(CopyMapTypeEnum.TowerCopy);
        if _towerData and _towerData.CurLevel > 0 then
            return _towerData.CurLevel - 1
        end
        return -1
    elseif functionVariableIdCode == FunctionVariableIdCode.SkillCountLevel then
        -- The total skill level reaches level X
        return GameCenter.PlayerSkillSystem:GetOverallLevel()
    end

    -- The last return value, if there are other required return values, please implement it above
    return -1
end

return LuaVariableSystem
