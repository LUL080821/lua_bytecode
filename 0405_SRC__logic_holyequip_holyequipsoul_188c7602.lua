------------------------------------------------
-- Author:
-- Date: 2021-03-18
-- File: HolyEquipSoul.lua
-- Module: HolyEquipSoul
-- Description: Holy Soul Data
------------------------------------------------
local RedPointItemCondition = CS.Thousandto.Code.Logic.RedPointItemCondition

local HolyEquipSoul = {
    -- Item ID
    ItemID = 0,
    -- Current quantity
    CurCount = 0,
    -- Maximum number
    MaxCount = 0,
    -- Single attribute
    SinglePros  = nil,
    -- Total attributes
    AllPros = nil,
}

function HolyEquipSoul:New(itemID, maxCount)
    local _m = Utils.DeepCopy(self)
    _m.ItemID = itemID
    _m.MaxCount = maxCount
    _m.SinglePros = {}
    local _itemCfg = DataConfig.DataItem[itemID]
    if _itemCfg ~= nil then
        local _paramTable = Utils.SplitStrByTableS(_itemCfg.EffectNum, {';', '_'})
        for i = 1, #_paramTable do
            local _type = _paramTable[i][2]
            local _value = _paramTable[i][3]
            local _oriValue = _m.SinglePros[_type]
            if _oriValue == nil then
                _oriValue = 0
            end
            _m.SinglePros[_type] = _oriValue + _value
        end
    end
    _m.CurCount = -1
    _m:SetCurCount(0)
    return _m
end

function HolyEquipSoul:SetCurCount(count)
    if self.CurCount ~= count then
        GameCenter.RedPointSystem:RemoveFuncCondition(FunctionStartIdCode.HolyEquipSoul, self.ItemID)
        self.CurCount = count
        if self.CurCount < self.MaxCount then
            -- There is only red spots when you don't eat it
            GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.HolyEquipSoul, self.ItemID, RedPointItemCondition(self.ItemID, 1))
        end
        self:CalculatePros()
    end
end

function HolyEquipSoul:CalculatePros()
    self.AllPros = {}
    for k, v in pairs(self.SinglePros) do
        self.AllPros[k] = v * self.CurCount
    end
end

return HolyEquipSoul