------------------------------------------------
-- author:
-- Date: 2021-11-11
-- File: UnrealEquipSystem.lua
-- Module: UnrealEquipSystem
-- Description: Magic installation system
------------------------------------------------

local L_UnrealEquipSoul = require "Logic.UnrealEquip.UnrealEquipSoul"
local L_UnrealEquipPart = require "Logic.UnrealEquip.UnrealEquipPart"
local L_RedPointCustomCondition = CS.Thousandto.Code.Logic.RedPointCustomCondition

local UnrealEquipSystem = {
    -- Equipment bar data
    EquipDic = Dictionary:New(),
    -- Data in the backpack
    BagList = List:New(),
    -- Backpack quantity counter
    BagCounter = {},
    -- Temporary list for return to external
    TmpList = List:New(),
    -- List of holy souls
    SoulList = List:New(),
    -- Synthetic configuration
    SyncCfgTable = nil,
    -- Synthesizable equipment idtable
    CanSyncEquipIds = nil,
    -- Synthesizable props idtable
    CanSyncItemIds = nil,
    -- List of items required for synthesis
    SyncNeedItems = List:New(),
    -- Check the red dots of the backpack
    IsCheckBagRedPoint = false,
    -- Check the synthetic red dots
    IsCheckSyncRedPoint = false,
    -- Total combat power
    AllPower = 0,
}

function UnrealEquipSystem:Initialize()
    self.SoulList:Clear()
    local _gCfg = DataConfig.DataGlobal[GlobalName.Equip_Magic_att_item]
    if _gCfg ~= nil then
        local _paramArray = Utils.SplitStrByTableS(_gCfg.Params, {';', '_'})
        for i = 1, #_paramArray do
            local _itemId = _paramArray[i][1]
            local _maxCount = _paramArray[i][2]
            self.SoulList:Add(L_UnrealEquipSoul:New(_itemId, _maxCount))
        end
    end
    self.SyncCfgTable = {}
    self.CanSyncEquipIds = {}
    self.CanSyncItemIds = {}
    local _registerItems = {}
    local _func = function(k, v)
        local _needItem = Utils.SplitNumber(v.NeedItem, '_')
        local _cfg = {}
        if _needItem ~= nil and #_needItem >= 2 then
            _registerItems[_needItem[1]] = true
            _cfg.Item = _needItem
        end
        local _needEquip = Utils.SplitNumber(v.NeedEquip, '_')
        if _needEquip ~= nil and #_needEquip >= 2 then
            _cfg.Equip = _needEquip
            self.CanSyncEquipIds[_needEquip[1]] = _cfg
        elseif _cfg.Item ~= nil then
            self.CanSyncItemIds[_needItem[1]] = _cfg
        end
        _cfg.TargetId = k
        self.SyncCfgTable[k] = _cfg
    end
    DataConfig.DataEquipMagicSynthesis:Foreach(_func)
    -- Registered Item Change Message
    self.SyncNeedItems:Clear()
    for k, v in pairs(_registerItems) do
        self.SyncNeedItems:Add(k)
    end
    GameCenter.ItemContianerSystem:AddItemMsgCondition(LogicLuaEventDefine.EID_EVENT_UNREAL_ITEM_CHANGED, self.SyncNeedItems, FunctionStartIdCode.UnrealEquipSync)
    GameCenter.RegFixEventHandle(LogicLuaEventDefine.EID_EVENT_UNREAL_ITEM_CHANGED, self.OnSyncItemChanged, self)
    self.BagCounter = {}
end

function UnrealEquipSystem:UnInitialize()
    GameCenter.UnRegFixEventHandle(LogicLuaEventDefine.EID_EVENT_UNREAL_ITEM_CHANGED, self.OnSyncItemChanged, self)
end

-- Get the equipment you wear
function UnrealEquipSystem:GetDressEquip(part)
    return self.EquipDic[part]
end

-- Get the magic costume in the backpack based on DBID
function UnrealEquipSystem:GetEquipByDBID(uid)
    for i = 1, #self.BagList do
        local _equip = self.BagList[i]
        if _equip.DBID == uid then
            return self.BagList[i]
        end
    end
    return nil
end

-- Set sorting
local L_SuitSort = function(left, right)
    return right.Grade < left.Grade
end

-- Calculate set properties
function UnrealEquipSystem:CalculateSuit()
    local equipList = List:New()
    for k, v in pairs(self.EquipDic) do
        if v.Equip ~= nil then
            equipList:Add(v.Equip)
        end
    end
    -- Sorting from high to low
    equipList:Sort(L_SuitSort)
    local _suit2Grade = 0
    local _suit2SuitID = 0
    -- 2 pieces
    local _equipCount = #equipList
    if _equipCount >= 2 then
        _suit2SuitID = equipList[2].SuitID
        _suit2Grade = equipList[2].Grade
    end
    -- 4 pieces
    local _suit4Grade = 0
    local _suit4SuitID = 0
    if _equipCount >= 4 then
        _suit4SuitID = equipList[4].SuitID
        _suit4Grade = equipList[4].Grade
    end
    -- 6 pieces
    local _suit6Grade = 0
    local _suit6SuitID = 0
    if _equipCount >= 6 then
        _suit6SuitID = equipList[6].SuitID
        _suit6Grade = equipList[6].Grade
    end
    -- 8 pieces
    local _suit8Grade = 0
    local _suit8SuitID = 0
    if _equipCount >= 8 then
        _suit8SuitID = equipList[8].SuitID
        _suit8Grade = equipList[8].Grade
    end
    -- 10 pieces
    local _suit10Grade = 0
    local _suit10SuitID = 0
    if _equipCount >= 10 then
        _suit10SuitID = equipList[10].SuitID
        _suit10Grade = equipList[10].Grade
    end
    if _suit2SuitID <= 0 then
        _suit2SuitID = nil
    end
    if _suit4SuitID <= 0 then
        _suit4SuitID = nil
    end
    if _suit6SuitID <= 0 then
        _suit6SuitID = nil
    end
    if _suit8SuitID <= 0 then
        _suit8SuitID = nil
    end
    if _suit10SuitID <= 0 then
        _suit10SuitID = nil
    end
    for i = 1, #equipList do
        local _equipGrade = equipList[i].Grade
        local _equipSuitIds = equipList[i].ActiveSuits
        _equipSuitIds:Clear()
        if _equipGrade >= _suit2Grade then
            _equipSuitIds[2] = _suit2SuitID
        end
        if _equipGrade >= _suit4Grade then
            _equipSuitIds[4] = _suit4SuitID
        end
        if _equipGrade >= _suit6Grade then
            _equipSuitIds[6] = _suit6SuitID
        end
        if _equipGrade >= _suit8Grade then
            _equipSuitIds[8] = _suit8SuitID
        end
        if _equipGrade >= _suit10Grade then
            _equipSuitIds[10] = _suit10SuitID
        end
    end
end

-- Sort equipment
local L_SortEquip = function(left, right)
    if left.Grade ~= right.Grade then
        return right.Grade < left.Grade
    end
    if left.Quality ~= right.Quality then
        return right.Quality < left.Quality
    end
    if left.Part ~= right.Part then
        return left.Part < right.Part
    end
    return false
end

-- Initialize data online
function UnrealEquipSystem:ResOnlineInit(result)
    self.BagList:Clear()
    if result.unrealBagItemList ~= nil then
        for i = 1, #result.unrealBagItemList do
            local _msgItem = result.unrealBagItemList[i]
            if _msgItem.num == nil then
                _msgItem.num = 1
            end
            local _equip = LuaItemBase.CreateItemBaseByMsg(_msgItem)
            self:AddBagEquip(_equip, 0)
        end
    end
    self.BagList:Sort(L_SortEquip)
    self.EquipDic:Clear()
    if result.unrealEquipPartList ~= nil then
        for i = 1, #result.unrealEquipPartList do
            local _part = L_UnrealEquipPart:New(result.unrealEquipPartList[i])
            self:UpdateEquipDic(_part)
        end
    end
    for i = 1, #result.unrealSoulInfoList do
        for j = 1, #self.SoulList do
            if self.SoulList[j].ItemID == result.unrealSoulInfoList[i].itemId then
                self.SoulList[j]:SetCurCount(result.unrealSoulInfoList[i].useNum)
            end
        end
    end
    self.IsCheckBagRedPoint = true
    self.IsCheckSyncRedPoint = true
    -- Calculate set properties
    self:CalculateSuit()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UNREAL_EQUIP_ONLINE)
end

-- Mosaic results feedback
function UnrealEquipSystem:ResInlayUnrealReuslt(result)
    if result.unrealPart ~= nil then
        -- Update the equipment bar
        local _part = L_UnrealEquipPart:New(result.unrealPart)
        self:UpdateEquipDic(_part)
        -- Calculate set properties
        self:CalculateSuit()
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UNREAL_EQUIP_PART)
    end
end

-- Phantom Soul Use Results
function UnrealEquipSystem:ResUseUnrealSoulResult(result)
    for i = 1, #self.SoulList do
        if self.SoulList[i].ItemID == result.unrealSoulData.itemId then
            self.SoulList[i]:SetCurCount(result.unrealSoulData.useNum)
            break
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UNREAL_EQUIP_SOULUPDATE)
end

-- Delete the holy clothes
function UnrealEquipSystem:ResDeleteUnreal(result)
    if result.deleteUID ~= nil then
        for i= 1, #result.deleteUID do
            self:DeleteBagEquip(result.deleteUID[i], result.reason)
        end
        self.IsCheckBagRedPoint = true
        self.IsCheckSyncRedPoint = true
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UNREAL_EQUIP_UPDATE_BAG)
    end
    if result.reason == ItemChangeReasonName.UnrealEquipCompoundDec then
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UNREAL_EQUIP_PLAY_SYNCVFX)
    end
end

-- Add a magic dress
function UnrealEquipSystem:ResAddUnreal(result)
    if result.addUnrealitem ~= nil then
        for i = 1, #result.addUnrealitem do
            local _msgItem = result.addUnrealitem[i]
            if _msgItem.num == nil then
                _msgItem.num = 1
            end
            local _equip = LuaItemBase.CreateItemBaseByMsg(_msgItem)
            _equip.IsNew = true
            self:AddBagEquip(_equip, result.reason)
            GameCenter.GetNewItemSystem:AddShowItem(result.reason, _equip, _equip.CfgID, 1)
        end
        self.BagList:Sort(L_SortEquip)
        self.IsCheckBagRedPoint = true
        self.IsCheckSyncRedPoint = true
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UNREAL_EQUIP_UPDATE_BAG)
    end
end

-- Synchronous combat power
function UnrealEquipSystem:ResUnrealEquipFightPower(result)
    self.AllPower = result.fightPower
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UNREAL_EQUIP_FIGHTPOWER)
end

-- Detect red dots of backpack
function UnrealEquipSystem:CheckBagRedPoint()
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.UnrealEquip)
    local _betterParts = List:New()
    for i = 1, #self.BagList do
        local _equip = self.BagList[i]
        local _part = _equip.Part
        if not _betterParts:Contains(_part) and _equip:CheckCanEquip() and _equip:CheckBetterThanDress() then
            _betterParts:Add(_part)
        end
    end
    for i = 1, #_betterParts do
        GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.UnrealEquip, _betterParts[i], L_RedPointCustomCondition(true))
    end
end

function UnrealEquipSystem:OnSyncItemChanged(obj, sender)
    self.IsCheckSyncRedPoint = true
end

function UnrealEquipSystem:GetCanMergeItemsById(equipNeed, itemNeed)
    local _result = List:New()
    if equipNeed ~= nil then
        local _equipCount = 0
        for k, v in pairs(self.EquipDic) do
            if v.Equip ~= nil and v.Equip.CfgID == equipNeed[1] then
                _equipCount = _equipCount + 1
                _result:Add(v.Equip)
                if _equipCount >= equipNeed[2] then
                    -- Enough quantity
                    break
                end
            end
        end
        for i = 1, #self.BagList do
            local _equip = self.BagList[i]
            if _equip.CfgID == equipNeed[1] then
                _equipCount = _equipCount + 1
                _result:Add(_equip)
                if _equipCount >= equipNeed[2] then
                    -- Enough quantity
                    break
                end
            end
        end
    end
    if itemNeed ~= nil then
        local _itemList = GameCenter.ItemContianerSystem:GetItemListByCfgidNOGC(ContainerType.ITEM_LOCATION_BAG, itemNeed[1])
        local _listCount = _itemList.Count
        local _haveCount = 0
        _result:Clear()
        for i = 1, _listCount do
            local _itemInst = _itemList[i - 1]
            _haveCount = _haveCount + _itemInst.Count
            _result:Add(_itemInst)
            if _haveCount >= itemNeed[2] then
                -- Enough quantity
                break
            end
        end
    end
    return _result
end

-- Get the synthesisable item id
function UnrealEquipSystem:GetCanMergeItems()
    for _, v in pairs(self.CanSyncItemIds) do
        local _itemCount = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(v.Item[1])
        if _itemCount >= v.Item[2] then
            return self:GetCanMergeItemsById(nil, v.Item), v.TargetId
        end
    end
    local _euipCount = {}
    for k, v in pairs(self.EquipDic) do
        if v.Equip ~= nil then
            local _oriCount = _euipCount[v.Equip.CfgID]
            if _oriCount == nil then
                _oriCount = 0
            end
            _euipCount[v.Equip.CfgID] = _oriCount + 1
        end
    end
    for _, v in pairs(self.CanSyncEquipIds) do
        local _partCount = _euipCount[v.Equip[1]]
        if _partCount == nil then
            _partCount = 0
        end
        local _bagCount = self.BagCounter[v.Equip[1]]
        if _bagCount == nil then
            _bagCount = 0
        end
        if (_bagCount + _partCount) >= v.Equip[2] then
            -- Enough equipment
            if v.Item ~= nil then
                -- Determine whether the amount of materials is sufficient
                local _itemCount = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(v.Item[1])
                if _itemCount >= v.Item[2] then
                    return self:GetCanMergeItemsById(v.Equip, nil), v.TargetId
                end
            else
                -- No materials required
                return self:GetCanMergeItemsById(v.Equip, nil), v.TargetId
            end
        end
    end
    return nil, nil
end

function UnrealEquipSystem:GetClipList()
    local _resultList = List:New()
    for _, v in pairs(self.CanSyncItemIds) do
        local _itemId = v.Item[1]
        local _itemList = GameCenter.ItemContianerSystem:GetItemListByCfgidNOGC(ContainerType.ITEM_LOCATION_BAG, _itemId)
        local _count = _itemList.Count
        for i = 1, _count do
            _resultList:Add(_itemList[i - 1])
        end
    end
    return _resultList
end

function UnrealEquipSystem:GetCanHeChengEquipList()
    local _resultList = List:New()
    -- Get synthesisable items from the equipment list
    for _, v in pairs(self.EquipDic) do
        if v.Equip ~= nil and self.CanSyncEquipIds[v.Equip.CfgID] then
            _resultList:Add(v.Equip)
        end
    end
    -- Get synthetic items in the magic backpack
    for i = 1, #self.BagList do
        local _equip = self.BagList[i]
        if self.CanSyncEquipIds[_equip.CfgID] then
            _resultList:Add(_equip)
        end
    end
    -- Get synthesisable items from the player's backpack
    for _, v in pairs(self.CanSyncItemIds) do
        local _itemId = v.Item[1]
        local _itemList = GameCenter.ItemContianerSystem:GetItemListByCfgidNOGC(ContainerType.ITEM_LOCATION_BAG, _itemId)
        local _count = _itemList.Count
        for i = 1, _count do
            _resultList:Add(_itemList[i - 1])
        end
    end
    return _resultList
end

function UnrealEquipSystem:CheckSyncRedPoint()
    local _countTable = {}
    for i = 1, #self.SyncNeedItems do
        local _itemId = self.SyncNeedItems[i]
        _countTable[_itemId] = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(_itemId)
    end
    local _euipCount = {}
    for k, v in pairs(self.EquipDic) do
        if v.Equip ~= nil then
            local _oriCount = _euipCount[v.Equip.CfgID]
            if _oriCount == nil then
                _oriCount = 0
            end
            _euipCount[v.Equip.CfgID] = _oriCount + 1
        end
    end
    local _canSync = false
    for k, v in pairs(self.SyncCfgTable) do
        local _equipEnough = true
        local _itemEnough = true
        if v.Equip ~= nil then
            -- Need equipment
            local _bagCount = self.BagCounter[v.Equip[1]]
            local _partCount = _euipCount[v.Equip[1]]
            if _bagCount == nil then
                _bagCount = 0
            end
            if _partCount == nil then
                _partCount = 0
            end
            if (_bagCount + _partCount) < v.Equip[2] then
                _equipEnough = false
            end
        end
        if v.Item ~= nil then
            -- Need items
            local _itemCount = _countTable[v.Item[1]]
            if _itemCount == nil then
                _itemCount = 0
            end
            if _itemCount < v.Item[2] then
                _itemEnough = false
            end
        end
        if _equipEnough and _itemEnough then
            _canSync = true
            break
        end
    end
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.UnrealEquipSync, _canSync)
end

-- Add to backpack bar
function UnrealEquipSystem:AddBagEquip(equip, reason)
    equip.ContainerType = ContainerType.ITEM_LOCATION_BAG
    self.BagList:Add(equip)
    local _cfgId = equip.CfgID
    local _oriCount = self.BagCounter[_cfgId]
    if _oriCount == nil then
        _oriCount = 0
    end
    self.BagCounter[_cfgId] = _oriCount + 1
    GameCenter.GetNewItemSystem:AddShowTips(equip, reason, 1)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UNREAL_EQUIP_ADD, equip)
end

-- Delete the equipment in the backpack bar
function UnrealEquipSystem:DeleteBagEquip(id, reason)
    for i = 1, #self.BagList do
        local _bagEquip = self.BagList[i]
        if _bagEquip.DBID == id then
            local _cfgId = _bagEquip.CfgID
            self.BagList:RemoveAt(i)
            local _oriCount = self.BagCounter[_cfgId]
            if _oriCount == nil then
                _oriCount = 0
            end
            if _oriCount <= 0 then
                self.BagCounter[_cfgId] = nil
            else
                self.BagCounter[_cfgId] = _oriCount - 1
            end
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UNREAL_EQUIP_DELETE, id)
            break
        end
    end
end

-- Update the equipment bar
function UnrealEquipSystem:UpdateEquipDic(part)
    local _partValue = part.Part
    self.EquipDic[_partValue] = part
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UNREAL_EQUIP_DELETE, id)
end

function UnrealEquipSystem:Update(dt)
    if self.IsCheckBagRedPoint then
        self:CheckBagRedPoint()
        self.IsCheckBagRedPoint = false
    end
    if self.IsCheckSyncRedPoint then
        self.IsCheckSyncRedPoint = false
        self:CheckSyncRedPoint()
    end
end

return UnrealEquipSystem