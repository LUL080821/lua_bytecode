------------------------------------------------
-- Author:
-- Date: 2021-03-18
-- File: HolyEquipSystem.lua
-- Module: HolyEquipSystem
-- Description: Holy installation system
------------------------------------------------

local AUTO_SPLIT_LEVEL = "HolyEquipSplitLevel"
local AUTO_SPLIT_QUALITY = "HolyEquipSplitQuality"
local L_HolyEquipSoul = require "Logic.HolyEquip.HolyEquipSoul"
local L_HolyEquipPart = require "Logic.HolyEquip.HolyEquipPart"
local L_HolyEquipSuitCfg = require "Logic.HolyEquip.HolyEquipSuitCfg"
local L_HolyEquip = CS.Thousandto.Code.Logic.HolyEquip
local L_RedPointCustomCondition = CS.Thousandto.Code.Logic.RedPointCustomCondition
local L_RedPointItemCondition = CS.Thousandto.Code.Logic.RedPointItemCondition

local HolyEquipSystem = {
    -- Equipment bar data
    EquipDic = Dictionary:New(),
    -- Data in the backpack
    BagList = List:New(),
    -- Temporary list for return to external
    TmpList = List:New(),
    -- Whether it is automatically decomposed
    AutoFenJie = false,
    -- Automatic decomposition level
    AutoFenJieLevel = 0,
    -- The quality of automatic decomposition
    AutoFenJieQuality = 0,
    -- List of holy souls
    SoulList = List:New(),
    -- Set attribute configuration
    SuitCfgs = Dictionary:New(),
    -- Set part configuration
    SuitPartCfg = nil,
    SuitTypePartCfg = nil,
    -- Total attributes
    AllProps = nil,
    -- Total combat power
    AllPower = 0,
    -- Current suit properties
    CurSuitPro = nil,
    -- The total attribute bonus of the current suit
    CurMultipleSuitPro = nil,
}

function HolyEquipSystem:Initialize()
    self.AutoFenJie = true
    self.AutoFenJieLevel = PlayerPrefs.GetInt(AUTO_SPLIT_LEVEL, 3)
    self.AutoFenJieQuality = PlayerPrefs.GetInt(AUTO_SPLIT_QUALITY, 4)
    self.AllProps = {}

    self.SoulList:Clear()
    local _gCfg = DataConfig.DataGlobal[GlobalName.Equip_Holy_att_item]
    if _gCfg ~= nil then
        local _paramArray = Utils.SplitStrByTableS(_gCfg.Params, {';', '_'})
        for i = 1, #_paramArray do
            local _itemId = _paramArray[i][1]
            local _maxCount = _paramArray[i][2]
            self.SoulList:Add(L_HolyEquipSoul:New(_itemId, _maxCount))
        end
    end
    self.SuitCfgs:Clear()
    local _func = function(k, v)
        self.SuitCfgs:Add(k, L_HolyEquipSuitCfg:New(v))
    end
    DataConfig.DataEquipHolySuit:Foreach(_func)

    self.SuitPartCfg = List:New()
    self.SuitTypePartCfg = Dictionary:New()
    local _func2 = function(k,v)
        local _partParams = Utils.SplitNumber(v.PartsList, '_')
        local _allList = List:New()
        local _list1 = List:New()
        for i = 1, 6 do
            _list1:Add(_partParams[i])
            _allList:Add(_partParams[i])
        end
        local _list2 = List:New()
        for i = 7, 11 do
            _list2:Add(_partParams[i])
            _allList:Add(_partParams[i])
        end
        self.SuitPartCfg:Add(_list1)
        self.SuitPartCfg:Add(_list2)
        self.SuitTypePartCfg:Add(k, _allList)
    end
    DataConfig.DataEquipHolyType:Foreach(_func2)
    self.CurSuitPro = {}
    self.CurMultipleSuitPro = {}
end

function HolyEquipSystem:UnInitialize()
end

function HolyEquipSystem:SetAutoFenJie(value)
    if self.AutoFenJie ~= value then
        self.AutoFenJie = value
        self:SendAutoSplitMsg()
    end
end

function HolyEquipSystem:SetAutoFenJieLevel(value)
    if self.AutoFenJieLevel ~= value then
        self.AutoFenJieLevel = value
        PlayerPrefs.SetInt(AUTO_SPLIT_LEVEL, self.AutoFenJieLevel)
        self:SendAutoSplitMsg()
    end
end

function HolyEquipSystem:SetAutoFenJieQuality(value)
    if self.AutoFenJieQuality ~= value then
        self.AutoFenJieQuality = value
            PlayerPrefs.GetInt(AUTO_SPLIT_QUALITY, self.AutoFenJieQuality)
        self:SendAutoSplitMsg()
    end
end

-- Get the equipment you wear
function HolyEquipSystem:GetDressEquip(part)
    return self.EquipDic[part]
end

-- Get a list of decomposed items
function HolyEquipSystem:GetCanFenJieList()
    self.TmpList:Clear()
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp ~= nil then
        for i = 1, #self.BagList do
            local _equip = self.BagList[i]
            if _equip.CanFenJie then
                if string.find(_equip:GetOcc(), tostring(_lp.IntOcc)) == nil then
                    -- Career mismatch
                    self.TmpList:Add(_equip)
                else
                    local _dressEquip = self:GetDressEquip(_equip.Part)
                    if _dressEquip ~= nil and _dressEquip.Equip ~= nil and _dressEquip.Equip.Power >= _equip.Power then
                        self.TmpList:Add(_equip)
                    end
                end
            end
        end
    end
    return self.TmpList
end

-- Get set attribute configuration
function HolyEquipSystem:GetSuitCfg(suitID)
    return self.SuitCfgs[suitID]
end

-- Get the number of pieces that the set is activated
function HolyEquipSystem:GetSuitActiveCounts(suitID)
    local _result = List:New()
    for k, v in pairs(self.EquipDic) do
        local _equip = v.equip
        if _equip ~= nil then
            local _iterActive = _equip.ActiveSuits:GetEnumerator()
            while _iterActive:MoveNext() do
                if _iterActive.Current.Value == suitID and not _result:Contains(iterActive.Current.Key) then
                    _result:Add(iterActive.Current.Key)
                end
            end
        end
    end
    return _result
end

-- Get the holy clothes in the backpack based on DBID
function HolyEquipSystem:GetEquipByDBID(uid)
    for i = 1, #self.BagList do
        local _equip = self.BagList[i]
        if _equip.DBID == uid then
            return self.BagList[i]
        end
    end
    return nil
end

-- Get a list of synthesisable equipment
function HolyEquipSystem:GetCanHeChengEquipList()
    self.TmpList:Clear()
    local _occ = tostring(GameCenter.GameSceneSystem:GetLocalPlayer().Occ)
    for k, v in pairs(self.EquipDic) do
        if v.Equip ~= nil then
            local _cfg = DataConfig.DataEquipHolySynthesis[v.Equip.CfgID]
            if _cfg ~= nil then
                self.TmpList:Add(v.Equip)
            end
        end
    end
    for i = 1, #self.BagList do
        local _item = self.BagList[i]
        local _cfg = DataConfig.DataEquipHolySynthesis[_item.CfgID]
        if _cfg ~= nil then
            local _equipCfg = DataConfig.DataEquip[_cfg.Id]
            if _equipCfg ~= nil and string.find(_equipCfg.Gender, _occ) then
                self.TmpList:Add(_item)
            end
        end
    end
    return self.TmpList
end

-- Get the synthesis automatically placed holy id
function HolyEquipSystem:GetCanMergeItemID()
    local _list = self:GetCanHeChengEquipList()
    local _itemCountDic = {}
    for i = 1, #_list do
        local _cfgID = _list[i].CfgID
        local _oriCount = _itemCountDic[_cfgID]
        if _oriCount == nil then
            _oriCount = 0
        end
        if (_oriCount + 1) >= 2 then
            -- Determine whether the materials are sufficient
            local _cfg = DataConfig.DataEquipHolySynthesis[_cfgID]
            if _cfg.JoinItem ~= nil and string.len(_cfg.JoinItem) > 0 then
                local _itemPar = Utils.SplitNumber(_cfg.JoinItem, '_')
                if GameCenter.ItemContianerSystem:GetItemCountFromCfgId(_itemPar[1]) >= _itemPar[2] then
                    return _list[i].DBID
                end
            else
                return _list[i].DBID
            end
        else
            _itemCountDic[_cfgID] = _oriCount + 1
        end
    end
    return 0
end

-- Determine whether a certain type of holy outfit has red dots
function HolyEquipSystem:IsHasIntensifyRedPointByType(type)
    local _parts = self.SuitTypePartCfg[type]
    if _parts ~= nil then
        for i = 1, #_parts do
            if GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.HolyEquipIntensify, _parts[i]) then
                return true
            end
        end
    end
    return false
end

-- Get the equipment list by type
function HolyEquipSystem:GetEquipListByType(type)
    local _result = List:New()
    local _parts = self.SuitTypePartCfg[type]
    if _parts ~= nil then
        for i = 1, #_parts do
            local _equip = self:GetDressEquip(_parts[i])
            if _equip ~= nil and _equip.Equip ~= nil then
                _result:Add(_equip)
            end
        end
    end
    return _result
end

-- Set sorting
local L_SuitSort = function(left, right)
    if right.Grade ~= left.Grade then
        return right.Grade < left.Grade
    end
    return right.Quality < left.Quality
end

function HolyEquipSystem:GetEquipListBySuitType(typeId, suitType)
    self.TmpList:Clear()
    local _parts = self.SuitTypePartCfg[typeId]
    if _parts ~= nil then
        if suitType == 0 then
            for i = 1, 6 do
                local _equip = self:GetDressEquip(_parts[i])
                if _equip ~= nil and _equip.Equip ~= nil then
                    self.TmpList:Add(_equip.Equip)
                end
            end
        else
            for i = 7, 11 do
                local _equip = self:GetDressEquip(_parts[i])
                if _equip ~= nil and _equip.Equip ~= nil then
                    self.TmpList:Add(_equip.Equip)
                end
            end
        end
    end
    self.TmpList:Sort(L_SuitSort)
    return self.TmpList
end

-- Sort equipment 2
local L_SortEquip2 = function(left, right)
    return right.Power < right.Power
end
-- Obtain all equipment in a certain part and sort it according to combat power
function HolyEquipSystem:GetEquipListByPart(part)
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    self.TmpList:Clear()
    if _lp ~= nil then
        local _lpOcc = _lp.IntOcc
        for i = 1, #self.BagList do
            local _item = self.BagList[i]
            if _item.Occ == _lpOcc and _item.Part == part and _item:CheckBetterThanDress() then
                self.TmpList:Add(_item)
            end
        end
        self.TmpList:Sort(L_SortEquip2)
    end
    return self.TmpList
end

-- Get the type of sacred clothing
function HolyEquipSystem:GetTypeIdByPart(part)
    for k, v in pairs(self.SuitTypePartCfg) do
        if v:Contains(part) then
            return k
        end
    end
    return 0
end

-- Sort equipment
local L_SortEquip = function(left, right)
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp ~= nil then
        local _occ = _lp.IntOcc
        local _leftOcc = 1
        if left.Occ == _occ then
            _leftOcc = 0
        end
        local _rightOcc = 1
        if right.Occ == _occ then
            _rightOcc = 0
        end
        if _leftOcc ~= _rightOcc then
            return _leftOcc < _rightOcc
        end
        if left.Grade ~= right.Grade then
            return right.Grade < left.Grade
        end
        if left.Quality ~= right.Quality then
            return right.Quality < left.Quality
        end
        if left.Part ~= right.Part then
            return left.Part < right.Part
        end
    end
    return false
end

-- Initialize data online
function HolyEquipSystem:ResOnlineInit(result)
    self.BagList:Clear()
    if result.holyBagItemList ~= nil then
        for i = 1, #result.holyBagItemList do
            local _equip = L_HolyEquip.CreateByLuaMsg(result.holyBagItemList[i])
            self:AddBagEquip(_equip, 0)
        end
    end
    self.BagList:Sort(L_SortEquip)
    self.EquipDic:Clear()
    if result.holyEquipPartList ~= nil then
        for i = 1, #result.holyEquipPartList do
            local _part = L_HolyEquipPart:New(result.holyEquipPartList[i])
            self:UpdateEquipDic(_part)
        end
    end

    for i = 1, #result.holySoulInfoList do
        for j = 1, #self.SoulList do
            if self.SoulList[j].ItemID == result.holySoulInfoList[i].itemId then
                self.SoulList[j]:SetCurCount(result.holySoulInfoList[i].useNum)
            end
        end
    end
    self:SendAutoSplitMsg()
    self:CheckBagRedPoint()
    self:CalculateSuit()
    self:CalculateAllPros()
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_HOLYEQUIP_ONLINE)
end

-- Mosaic results feedback
function HolyEquipSystem:ResInlayHolyReuslt(result)
    if result.holyPart ~= nil then
        -- Update the equipment bar
        local _part = L_HolyEquipPart:New(result.holyPart)
        self:UpdateEquipDic(_part)
        self:CalculateSuit()
        self:CalculateAllPros()
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_UPDATE_HOLYEQUIP_PART)
    end
end

-- Strengthen results
function HolyEquipSystem:ResIntensifyHolyPartResult(result)
    local _oldPart = self.EquipDic[result.holyPart.part]
    local _part = L_HolyEquipPart:New(result.holyPart)
    if _oldPart ~= nil and _oldPart.Equip ~= nil and _part.Equip ~= nil then
        -- Copy set activation status
        local _iter = _oldPart.Equip.ActiveSuits:GetEnumerator()
        while _iter:MoveNext() do
            _part.Equip.ActiveSuits[_iter.Current.Key] = _iter.Current.Value
        end
    end
    self:UpdateEquipDic(_part)
    self:CheckBagRedPoint()
    self:CalculateAllPros()
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_INTENSIFY_HOLYEQUIP)
end

-- The results of the holy soul use
function HolyEquipSystem:ResUseHolySoulResult(result)
    for i = 1, #self.SoulList do
        if self.SoulList[i].ItemID == result.holySoulData.itemId then
            self.SoulList[i]:SetCurCount(result.holySoulData.useNum)
            break
        end
    end
    self:CalculateAllPros()
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_HOLYEQUIP_SOUL_UPDATE)
end

-- Delete the holy clothes
function HolyEquipSystem:ResDeleteHoly(result)
    if result.deleteUID ~= nil then
        for i= 1, #result.deleteUID do
            self:DeleteBagEquip(result.deleteUID[i], result.reason)
        end
        self:CheckBagRedPoint()
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_UPDATE_HOLYEQUIP_BAG, result.reason == ItemChangeReasonName.HolyEquipResolveDec)
        if result.reason == ItemChangeReasonName.HolyEquipCompoundGet then
            GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MERGE_SUCC)
        end
    end
end

-- Add a holy suit
function HolyEquipSystem:ResAddHoly(result)
    if result.addholyitem ~= nil then
        for i = 1, #result.addholyitem do
            local _equip = L_HolyEquip.CreateByLuaMsg(result.addholyitem[i])
            _equip.IsNew = true
            self:AddBagEquip(_equip, result.reason)
            GameCenter.GetNewItemSystem:AddShowItem(result.reason, _equip, _equip.CfgID, 1)
        end
        self.BagList:Sort(L_SortEquip)
        self:CheckBagRedPoint()
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_UPDATE_HOLYEQUIP_BAG)
    end
end

-- Synchronous combat power
function HolyEquipSystem:ResHolyEquipFightPower(result)
    self.AllPower = result.fightPower
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_REFRESH_HOLY_FIGHTPOWER)
end

local L_MergePropTable = function(proTables)
    local _result = {}
    for i = 1, #proTables do
        for k, v in pairs(proTables[i]) do
            local _oriValue = _result[k]
            if _oriValue == nil then
                _oriValue = 0
            end
            _result[k] = _oriValue + v
        end
    end
    return _result
end

-- Calculate total properties
function HolyEquipSystem:CalculateAllPros()
    self.AllProps = {}
    local _allBaseProDic = {}
    local _allLevelProDic = {}
    -- Add equipment attributes and enhancement attributes
    for _, part in pairs(self.EquipDic) do
        if part.Equip ~= nil and part.LevelCfg ~= nil then
            local _dicPro = part.Equip:GetBaseAttribute()
            local _iter = _dicPro:GetEnumerator()
            while _iter:MoveNext() do
                local _k = _iter.Current.Key
                local _v = _iter.Current.Value
                local _oriValue = _allBaseProDic[_k]
                if _oriValue == nil then
                    _oriValue = 0
                end
                _allBaseProDic[_k] = _oriValue + _v
            end
            _allLevelProDic = L_MergePropTable({_allLevelProDic, part.LevelPros})
        end
    end
    -- Accumulated basic attributes and enhanced attributes
    self.AllProps = L_MergePropTable({_allBaseProDic, _allLevelProDic})
    -- Add the holy soul attribute
    for i= 1, #self.SoulList do
        self.AllProps = L_MergePropTable({self.AllProps, self.SoulList[i].AllPros})
    end
    -- Add set attributes
    self.AllProps = L_MergePropTable({self.AllProps, self.CurSuitPro, self.CurMultipleSuitPro})
end

-- Detect red dots of backpack
function HolyEquipSystem:CheckBagRedPoint()
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.HolyEquipDress)
    local _betterParts = List:New()
    for i = 1, #self.BagList do
        local _equip = self.BagList[i]
        local _part = _equip.Part
        if not _betterParts:Contains(_part) and _equip:CheckCanEquip() and _equip:CheckBetterThanDress() then
            _betterParts:Add(_part)
        end
    end
    if #_betterParts > 0 then
        for k, v in pairs(self.SuitTypePartCfg) do
            for i = 1, #v do
                if _betterParts:Contains(v[i]) then
                    GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.HolyEquipDress, k, L_RedPointCustomCondition(true))
                    break
                end
            end
        end
    end
    for i = 1, #_betterParts do
        GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.HolyEquipDress, _betterParts[i], L_RedPointCustomCondition(true))
    end
    -- Determine whether there are red dots based on whether there are any that can be automatically synthesized
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.HolyEquipCompose, self:GetCanMergeItemID() > 0)
end

-- Add to backpack bar
function HolyEquipSystem:AddBagEquip(equip, reason)
    equip.ContainerType = ContainerType.ITEM_LOCATION_BAG
    self.BagList:Add(equip)
    GameCenter.GetNewItemSystem:AddShowTips(equip, reason, 1)
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_ADD_HOLYEQUIP, equip)
end

-- Delete the equipment in the backpack bar
function HolyEquipSystem:DeleteBagEquip(id, reason)
    for i = 1, #self.BagList do
        if self.BagList[i].DBID == id then
            self.BagList:RemoveAt(i)
            GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_DELETE_HOLYEQUIP, id)
            break
        end
    end
end

-- Calculate set properties
function HolyEquipSystem:CalculateSuit()
    self.CurSuitPro = {}
    self.CurMultipleSuitPro = {}
    for i = 1, #self.SuitPartCfg do
        local _equipList = List:New()
        for j = 1, #self.SuitPartCfg[i] do
            local _equip = self:GetDressEquip(self.SuitPartCfg[i][j])
            if _equip ~= nil and _equip.Equip ~= nil then
                _equipList:Add(_equip.Equip)
            end
        end
        -- Calculate properties
        self:CalculateSuitByParts(_equipList)
    end
end

-- Calculate set properties
function HolyEquipSystem:CalculateSuitByParts(equipList)
    -- Sorting from high to low
    equipList:Sort(L_SuitSort)
    local _suit2Grade = 0
    local _suit2Quality = 0
    local _suit2SuitID = 0
    -- Take two sets
    local _equipCount = #equipList
    if _equipCount >= 2 then
        _suit2SuitID = equipList[2].SuitID
        _suit2Grade = equipList[2].Grade
        _suit2Quality = equipList[2].Quality
    end
    local _suit4Grade = 0
    local _suit4Quality = 0
    local _suit4SuitID = 0
    if _equipCount >= 4 then
        _suit4SuitID = equipList[4].SuitID
        _suit4Grade = equipList[4].Grade
        _suit4Quality = equipList[4].Quality
    end
    local _suit5Grade = 0
    local _suit5Quality = 0
    local _suit5SuitID = 0
    if _equipCount >= 5 then
        _suit5SuitID = equipList[5].SuitID
        _suit5Grade = equipList[5].Grade
        _suit5Quality = equipList[5].Quality
    end
    local _suit6Grade = 0
    local _suit6Quality = 0
    local _suit6SuitID = 0
    if _equipCount >= 6 then
        _suit6SuitID = equipList[6].SuitID
        _suit6Grade = equipList[6].Grade
        _suit6Quality = equipList[6].Quality
    end

    for i = 1, #equipList do
        local _equipGrade = equipList[i].Grade
        local _equipQuality = equipList[i].Quality
        local _equipSuitIds = equipList[i].ActiveSuits
        _equipSuitIds:Clear()
        if _equipGrade >= _suit2Grade and _equipQuality >= _suit2Quality then
            _equipSuitIds[2] = _suit2SuitID
        end
        if _equipGrade >= _suit4Grade and _equipQuality >= _suit4Quality then
            _equipSuitIds[4] = _suit4SuitID
        end
        if _equipGrade >= _suit5Grade and _equipQuality >= _suit5Quality then
            _equipSuitIds[5] = _suit5SuitID
        end
        if _equipGrade >= _suit6Grade and _equipQuality >= _suit6Quality then
            _equipSuitIds[6] = _suit6SuitID
        end
    end
    -- Calculate properties
    local _proList = List:New()
    local _muProList = List:New()
    local _suit2Cfg = self:GetSuitCfg(_suit2SuitID)
    if _suit2Cfg ~= nil then
        _proList:Add(_suit2Cfg.Pros2)
        _muProList:Add(_suit2Cfg.MultiplePros2)
    end
    local _suit4Cfg = self:GetSuitCfg(_suit4SuitID)
    if _suit4Cfg ~= nil then
        _proList:Add(_suit4Cfg.Pros4)
        _muProList:Add(_suit4Cfg.MultiplePros4)
    end
    local _suit5Cfg = self:GetSuitCfg(_suit5SuitID)
    if _suit5Cfg ~= nil then
        _proList:Add(_suit5Cfg.Pros5)
        _muProList:Add(_suit5Cfg.MultiplePros5)
    end
    local _suit6Cfg = self:GetSuitCfg(_suit6SuitID)
    if _suit6Cfg ~= nil then
        _proList:Add(_suit6Cfg.Pros6)
        _muProList:Add(_suit6Cfg.MultiplePros6)
    end
    _proList:Add(self.CurSuitPro)
    _muProList:Add(self.CurMultipleSuitPro)
    self.CurSuitPro = L_MergePropTable(_proList)
    self.CurMultipleSuitPro = L_MergePropTable(_muProList)
end

-- Update the equipment bar
function HolyEquipSystem:UpdateEquipDic(part)
    local _partValue = part.Part
    self.EquipDic[_partValue] = part
    local _haveEquip = false
    for _, v in pairs(self.EquipDic) do
        if v.Equip ~= nil then
            _haveEquip = true
            break
        end
    end
    -- The enhanced interface is displayed only when there is equipment
    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.HolyEquipIntensify, _haveEquip)

    -- Detection upgrade red dot
    GameCenter.RedPointSystem:RemoveFuncCondition(FunctionStartIdCode.HolyEquipIntensify, _partValue)
    if part.Equip ~= nil and part.LevelCfg ~= nil and not part.IsMaxLevel then
        GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.HolyEquipIntensify, _partValue, L_RedPointItemCondition(ItemTypeCode.HolyEquipScore, part.LevelCfg.Cost))
    end
end

-- Send a change automatic decomposition option message
function HolyEquipSystem:SendAutoSplitMsg()
    GameCenter.Network.Send("MSG_HolyEquip.ReqSetAutoResolve", {isAuto = self.AutoFenJie, grade = self.AutoFenJieLevel, quality = self.AutoFenJieQuality})
end

return HolyEquipSystem