------------------------------------------------
-- author:
-- Date: 2021-11-11
-- File: UnrealEquipSoul.lua
-- Module: UnrealEquipSoul
-- Description: Phantom Data
------------------------------------------------
local RedPointItemCondition = CS.Thousandto.Code.Logic.RedPointItemCondition

local UnrealEquipSoul = {
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

function UnrealEquipSoul:New(itemID, maxCount)
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

function UnrealEquipSoul:SetCurCount(count)
    if self.CurCount ~= count then
        GameCenter.RedPointSystem:RemoveFuncCondition(FunctionStartIdCode.UnrealEquipSoul, self.ItemID)
        self.CurCount = count
        if self.CurCount < self.MaxCount then
            -- There is only red spots when you don't eat it
            GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.UnrealEquipSoul, self.ItemID, RedPointItemCondition(self.ItemID, 1))
        end
        self:CalculatePros()
    end
end

function UnrealEquipSoul:CalculatePros()
    self.AllPros = {}
    for k, v in pairs(self.SinglePros) do
        self.AllPros[k] = v * self.CurCount
    end
end

return UnrealEquipSoul