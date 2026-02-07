
------------------------------------------------
-- Author: 
-- Date: 2021-05-6
-- File: DevilCampData.lua
-- Module: DevilCampData
-- Description: Data from the Demon Soul System
------------------------------------------------
local FightUtils = require "Logic.Base.FightUtils.FightUtils"

local DevilCampData =
{
    Parent = nil,
    CampId = nil,
    Active = nil,
    CardList = List:New(),
}

-- Specific equipment data
local L_ItemInfo = {
    -- Equipment configuration table Id
    CfgId = 0,
    -- Equipment configuration
    EquipCfg = nil,
    -- Unique ID of equipment
    DBID = 0,
}

-- Equipment Information
local L_EquipInfo = {
    -- Part ID
    Part = 0,
    -- Equipment Information
    ItemInfo = nil,
}

-- Card data
local L_CardData = {
    -- Magic soul card id, CardMain configuration table
    Id = 0,
    -- Equipment Information
	EquipPartDict = Dictionary:New(),
    Level = 0,
    -- Strengthening level
    Rank = 0,
    -- Whether to activate
    Active = false,
    -- Breakthrough Level
    BreakLv = 0,
    -- Fighting power
    Power = 0,
    -- Breakthrough Consumable Equipment List
    BreakCostIds = nil,
    -- Activate or strengthen the list of consumed items
    CostItems = nil,
}

function L_CardData:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

function L_CardData:Parse(msg)
    self.Id = msg.id
    self.EquipPartDict:Clear()
    local _equipList = msg.part
    for j = 1, #_equipList do
        local _equ = Utils.DeepCopy(L_EquipInfo)
        -- Part ID
        _equ.Part = _equipList[j].id
        if _equipList[j].equip ~= nil then
            -- Equipment items
            _equ.ItemInfo = Utils.DeepCopy(L_ItemInfo)
            _equ.ItemInfo.CfgId = _equipList[j].equip.itemModelId
            _equ.ItemInfo.DBID = _equipList[j].equip.itemId
            _equ.ItemInfo.EquipCfg = DataConfig.DataEquip[_equ.ItemInfo.CfgId]
        else
            _equ.ItemInfo = Utils.DeepCopy(L_ItemInfo)
        end
        self.EquipPartDict:Add(_equ.Part, _equ)
    end
    self.Level = msg.level
    self.Active = msg.active
    self.Rank = msg.rank
    self.BreakLv = msg.breakLv
    self.FightPower = msg.fightPoint
end

function L_CardData:RefreshData()
    -- Strengthen consumption props
    self.CostItems = nil
    local _dicKey = self.Id * 10000 + self.Rank * 100 + self.Level
    local _tranCfg = GameCenter.DevilSoulSystem.TrainDict[_dicKey]
    if _tranCfg ~= nil and string.len(_tranCfg.Condition) > 0 then
        self.CostItems = Utils.SplitNumber(_tranCfg.Condition, '_')
    end
    -- Image consumption equipment
    self.BreakCostIds = nil
    local _breCfg = DataConfig.DataCrossDevilCardBreak[self.Id * 1000 + self.BreakLv + 1]
    if _breCfg ~= nil then
        self.BreakCostIds = Utils.SplitStrByTableS(_breCfg.Condition, {';', '_'})
    end
end

function L_CardData:EquipWear(msg)
    local _equip = self.EquipPartDict[msg.cellId]
    -- Weared equipment id
    _equip.ItemInfo.CfgId = msg.equipModelId
    -- Weared equipment template id
    _equip.ItemInfo.DBID = msg.equipId
    _equip.ItemInfo.EquipCfg = DataConfig.DataEquip[msg.equipModelId]
end

function DevilCampData:New(cardCamp, parent)
    local _m = Utils.DeepCopy(self)
    _m.Parent = parent
    _m.CardList:Clear()
    _m:RefeshData(cardCamp)
    return _m
end

function DevilCampData:RefeshData(cardCamp)
    -- Demon Soul Camp ID
    self.CampId = cardCamp.campId
    -- Whether to activate
    self.Active = cardCamp.active
    -- Demon Soul List
    local _cardList = cardCamp.card
    if _cardList ~= nil then
        for i = 1, #_cardList do
            local _t = L_CardData:New()
            _t:Parse(_cardList[i])
            _t:RefreshData()
            self.CardList:Add(_t)
        end
    end
end

return DevilCampData