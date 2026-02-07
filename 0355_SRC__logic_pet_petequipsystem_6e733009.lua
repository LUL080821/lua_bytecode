------------------------------------------------
-- Author:
-- Date: 2020-11-04
-- File: PetEquipSystem.lua
-- Module: PetEquipSystem
-- Description: Pet Equipment System Code
------------------------------------------------
local FightUtils = require "Logic.Base.FightUtils.FightUtils"
local PetSoulInfo = require "Logic.Pet.PetSoulInfo"
local PetInfo = require "Logic.Pet.PetInfo"
local RedPointCustomCondition = CS.Thousandto.Code.Logic.RedPointCustomCondition
local RedPointItemCondition = CS.Thousandto.Code.Logic.RedPointItemCondition
local RedPointTaskCondition = CS.Thousandto.Code.Logic.RedPointTaskCondition

local PetEquipSystem = {
    -- List of currently clicked pet support IDs
    ClickPetList = List:New(),
    -- Current assisting data
    CurPetCellsDic = Dictionary:New(),
    -- Frame count, red dot interval use
    FrameCount = 0,
    -- List of additional items required for equipment synthesis
    EquipSynNeedItemList = List:New(),
}

-- initialization
function PetEquipSystem:Initialize()
    self.ClickPetList:Clear()
    GameCenter.RegFixEventHandle(LogicLuaEventDefine.EVENT_PETEQUIP_BAGCHANGE, self.OnEquipChange, self)
end

-- De-initialization
function PetEquipSystem:UnInitialize()
    GameCenter.UnRegFixEventHandle(LogicLuaEventDefine.EVENT_PETEQUIP_BAGCHANGE, self.OnEquipChange, self)
end

function PetEquipSystem:Update(dt)
    if self.FrameCount then
        self.FrameCount = self.FrameCount + 1
        if self.FrameCount >= 20 and self.IsSetRed then
            local _wearRed = false
            local _allEquipList = self:GetHightPetEquipList()
            local _keys = self.CurPetCellsDic:GetKeys()
            for i = 1, #_keys do
                if self.CurPetCellsDic[_keys[i]].PetID > 0 and not _wearRed and self:GetEquipWearRedByPetCell(_keys[i], _allEquipList) then
                    _wearRed = true
                    break
                end
            end
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_PETEQUIP_PETLISTUPDATE)
            GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.PetEquipWear, _wearRed)
            self.IsSetRed = false
            self.FrameCount = 0
            self:SetEquipSynRed()
        end
    end
end

-- Backpack pet equipment changes
function PetEquipSystem:OnEquipChange(obj, sender)
    self.IsSetRed = true
end

function PetEquipSystem:GetEquipWearRedByPetCell(assistantId, allEquipList)
    local _red = false
    local _equipCellDic = self.CurPetCellsDic[assistantId].EquipCellDic
    local _keys = _equipCellDic:GetKeys()
    for i = 1, #_keys do
        if self:GetPetEquipCellState(_keys[i], assistantId) then
            local _power = 0
            if _equipCellDic[_keys[i]].EquipInfo then
                _power = _equipCellDic[_keys[i]].EquipInfo.Power
            end
            if allEquipList:ContainsKey(_keys[i]) then
                if allEquipList[_keys[i]].Power > _power then
                    _red = true
                end
            end
        else
            break
        end
    end
    return _red
end

-- Set up pet support red dots
function PetEquipSystem:SetPetFightRed()
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.PetFight)
    self.CurPetCellsDic:ForeachCanBreak(function(k, v)
        if v.PetID == 0 and v.IsOpen and not self.ClickPetList:Contains(k) then
            GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.PetFight, k, RedPointCustomCondition(true))
        elseif v.PetID == 0 and not v.IsOpen and v.Condition then
            local _ar = Utils.SplitNumber(v.Condition, '_')
            if _ar[1] ~= 1 and _ar[1] ~= 56 and _ar[1] ~= 150 then
                local _conditions = List:New();
                _conditions:Add(RedPointItemCondition(_ar[1], _ar[2]));
                GameCenter.RedPointSystem:LuaAddFuncCondition(FunctionStartIdCode.PetFight, k * 1000, _conditions);
            end
        end
    end)
end

-- Check if a pet is aided
function PetEquipSystem:PetIsFighting(petId)
    local _isFight = false
    self.CurPetCellsDic:ForeachCanBreak(function(k, v)
        if v.PetID == petId then
            _isFight = true
            return true
        end
    end)
    return _isFight
end

-- Search the list of pets for helping fight
function PetEquipSystem:GetFightPetList()
    local list = List:New()
    local _index = 1
    local _keys = self.CurPetCellsDic:GetKeys()
    for i = 1, #_keys do
        local v = self.CurPetCellsDic[_keys[i]]
        if v.PetID > 0 then
            if _index ~= 1 then
                list:Add(v.PetID)
            end
            _index = _index + 1
        end
    end
    return list
end

function PetEquipSystem:GetPetEquipPowerByPart(cellId, part)
    local _isFight = 0
    if self.CurPetCellsDic:ContainsKey(cellId) then
        if self.CurPetCellsDic[cellId].EquipCellDic:ContainsKey(part) and self.CurPetCellsDic[cellId].EquipCellDic[part].EquipInfo then
            _isFight = self.CurPetCellsDic[cellId].EquipCellDic[part].EquipInfo.Power
        else
            if not self:GetPetEquipCellState(part, cellId) then
                _isFight = -1
            end
        end
    end
    return _isFight
end

function PetEquipSystem:GetPetEquipByPart(cellId, part)
    local _info = nil
    if self.CurPetCellsDic:ContainsKey(cellId) then
        if self.CurPetCellsDic[cellId].EquipCellDic:ContainsKey(part) then
            _info = self.CurPetCellsDic[cellId].EquipCellDic[part].EquipInfo
        end
    end
    return _info
end

-- Get the reinforcement attributes
function PetEquipSystem:GetPetStrengthAtt(assistantId, part)
    local _dic = Dictionary:New()
    if self.CurPetCellsDic:ContainsKey(assistantId) then
        if self.CurPetCellsDic[assistantId].EquipCellDic:ContainsKey(part) then
            local _lv = self.CurPetCellsDic[assistantId].EquipCellDic[part].StrengthLv
            local _cfg = DataConfig.DataPetEquipInten[assistantId * 100000000 + part * 10000 + _lv]
            if _cfg then
                local _arr = Utils.SplitStr(_cfg.Value, ';')
                for i = 1, #_arr do
                    local _sg = Utils.SplitNumber(_arr[i], '_')
                    if _sg[2] > 0 then
                        _dic:Add(_sg[1], _sg[2])
                    end
                end
            end
        end
    end
    return _dic
end

-- Obtain the Soul Attachment Attribute
function PetEquipSystem:GetPetSoulAtt(assistantId, part)
    local _dic = Dictionary:New()
    if self.CurPetCellsDic:ContainsKey(assistantId) then
        if self.CurPetCellsDic[assistantId].EquipCellDic:ContainsKey(part) then
            local _lv = self.CurPetCellsDic[assistantId].EquipCellDic[part].SoulLv
            local _cfg = DataConfig.DataPetEquipSoulbound[assistantId * 100000000 + part * 10000 + _lv]
            if _cfg then
                local _arr = Utils.SplitStr(_cfg.ExtraValue, ';')
                for i = 1, #_arr do
                    local _sg = Utils.SplitNumber(_arr[i], '_')
                    if _sg[2] > 0 then
                        _dic:Add(_sg[1], _sg[2])
                    end
                end
            end
        end
    end
    return _dic
end

-- Obtain the Soul Attachment Attribute
function PetEquipSystem:GetPetEquipSoulLv(assistantId, part)
    if self.CurPetCellsDic:ContainsKey(assistantId) then
        if self.CurPetCellsDic[assistantId].EquipCellDic:ContainsKey(part) then
            local _lv = self.CurPetCellsDic[assistantId].EquipCellDic[part].SoulLv
            return _lv
        end
    end
    return 0
end

-- Set up equipment enhancement red dots
function PetEquipSystem:SetEquipStrengthRed()
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.PetEquipStrength)
    self.CurPetCellsDic:ForeachCanBreak(function(k, v)
        v.EquipCellDic:ForeachCanBreak(function(ik, iv)
            if iv.EquipInfo then
                self:SetEquipCellStrengthRed(k, ik)
            end
        end)
        local _cfg = DataConfig.DataPetEquipIntenClass[v.TotalStrActiveID + 1]
        if _cfg then
            if _cfg.SuitLevel <= v.TotalStrLv then
                GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.PetEquipStrength, k*1000, RedPointCustomCondition(true))
            else
                GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.PetEquipStrength, k*1000, RedPointCustomCondition(false))
            end
        end
    end)
end

-- Set up equipment with soul-attached red dots
function PetEquipSystem:SetEquipSoulRed()
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.PetEquipFuhun)
    self.CurPetCellsDic:ForeachCanBreak(function(k, v)
        v.EquipCellDic:ForeachCanBreak(function(ik, iv)
            if iv.EquipInfo then
                self:SetEquipCellSoulRed(k, ik)
            end
        end)
        local _cfg = DataConfig.DataPetEquipSoulboundClass[v.TotalSoulActiveID + 1]
        if _cfg then
            if _cfg.SuitLevel <= v.TotalSoulLv then
                GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.PetEquipFuhun, k*1000, RedPointCustomCondition(true))
            else
                GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.PetEquipFuhun, k*1000, RedPointCustomCondition(false))
            end
        end
    end)
end

-- A certain equipment with soul-attached red dot
function PetEquipSystem:SetEquipCellSoulRed(cellId, partId)
    if self.CurPetCellsDic:ContainsKey(cellId) then
        local info = self.CurPetCellsDic[cellId]
        if info.EquipCellDic:ContainsKey(partId) then
            if info.EquipCellDic[partId].EquipInfo then
                local _cfg = DataConfig.DataPetEquipSoulbound[cellId * 100000000 + partId * 10000 + info.EquipCellDic[partId].SoulLv]
                local _cfg1 = DataConfig.DataPetEquipSoulbound[cellId * 100000000 + partId * 10000 + info.EquipCellDic[partId].SoulLv + 1]
                if _cfg and _cfg1 and _cfg.Consume and _cfg.Consume ~= "" then
                    local _itemArr = Utils.SplitNumber(_cfg.Consume, '_')
                    GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.PetEquipFuhun, cellId*1000+partId, RedPointItemCondition(_itemArr[1], _itemArr[2]))
                end
            end
        end
    end
end

-- Get a soul-attached red dot in a certain assisted position
function PetEquipSystem:GetPetCellSoulRed(cellId)
    local _red = false
    local _dic = self.CurPetCellsDic
    if cellId and _dic[cellId] then
        local _keys = _dic[cellId].EquipCellDic:GetKeys()
        local _equipDic = _dic[cellId].EquipCellDic
        for i = 1, #_keys do
            local _equip = _equipDic[_keys[i]].EquipInfo
            if _equip then
                if GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.PetEquipFuhun, cellId * 1000 + _keys[i]) then
                    _red = true
                    break
                end
            end
        end
        if not _red then
            if GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.PetEquipFuhun, cellId * 1000) then
                _red = true
            end
        end
    end
    return _red
end

-- A certain equipment reinforces red dot
function PetEquipSystem:SetEquipCellStrengthRed(cellId, partId)
    if self.CurPetCellsDic:ContainsKey(cellId) then
        local info = self.CurPetCellsDic[cellId]
        if info.EquipCellDic:ContainsKey(partId) then
            if info.EquipCellDic[partId].EquipInfo then
                local _cfg = DataConfig.DataPetEquipInten[cellId * 100000000 + partId * 10000 + info.EquipCellDic[partId].StrengthLv]
                local _cfg1 = DataConfig.DataPetEquipInten[cellId * 100000000 + partId * 10000 + info.EquipCellDic[partId].StrengthLv + 1]
                if _cfg and _cfg1 and _cfg.Consume and _cfg.Consume ~= "" then
                    local _itemArr = Utils.SplitNumber(_cfg.Consume, '_')
                    GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.PetEquipStrength, cellId*1000+partId, RedPointItemCondition(_itemArr[1], _itemArr[2]))
                end
            end
        end
    end
end

-- Get a reinforced red dot for a certain assist position
function PetEquipSystem:GetPetCellStrengthRed(cellId)
    local _dic = self.CurPetCellsDic
    local _strengthRed = false
    if cellId and _dic[cellId] then
        local _keys = _dic[cellId].EquipCellDic:GetKeys()
        local _equipDic = _dic[cellId].EquipCellDic
        for i = 1, #_keys do
            local _equip = _equipDic[_keys[i]].EquipInfo
            if _equip then
                if GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.PetEquipStrength, cellId * 1000 + _keys[i]) then
                    _strengthRed = true
                    break
                end
            end
        end
        if not _strengthRed then
            if GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.PetEquipStrength, cellId * 1000) then
                _strengthRed = true
            end
        end
    end
    return _strengthRed
end

-- Get the activated full-body enhancement level (using the configuration table as ID)
function PetEquipSystem:GetTotalActiveStrLv(assistantId)
    if self.CurPetCellsDic[assistantId] then
        return self.CurPetCellsDic[assistantId].TotalStrActiveID
    end
    return 1
end

-- Get the activated full-body possession level (using the configuration table as ID)
function PetEquipSystem:GetTotalActiveSoulLv(assistantId)
    if self.CurPetCellsDic[assistantId] then
        return self.CurPetCellsDic[assistantId].TotalSoulActiveID
    end
    return 1
end

function PetEquipSystem:GetPetEquipCellState(partId, assistantId, showMsg)
    local _state = false
    local _cfg = DataConfig.DataPetEquipUnlock[assistantId * 10000 + partId]
    if _cfg then
        local _ar = Utils.SplitNumber(_cfg.PartUnlock, '_')
        if _ar then
            if _ar[1] == 1 then
                local _lpLv = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
                if _ar[2] then
                    if _lpLv >= _ar[2] then
                        _state = true
                    else
                        _state = false
                        if showMsg then
                            Utils.ShowPromptByEnum("C_PETEQUIP_EQUIPWEAR1", _ar[2])
                        end
                    end
                end
            elseif _ar[1] == 56 then
                local _petLv = GameCenter.PetSystem.CurLevel
                if _ar[2] and _petLv then
                    if _petLv >= _ar[2] then
                        _state = true
                    else
                        _state = false
                        if showMsg then
                            Utils.ShowPromptByEnum("C_PETEQUIP_EQUIPWEAR2", _ar[2])
                        end
                    end
                end
            end
        end
    end
    return _state
end

function PetEquipSystem:SetEquipSynRed()
    local allEquipList = self:GetAllPetEquip()
    local _red = false
    self.CurPetCellsDic:ForeachCanBreak(function(k, v)
        if self:GetEquipSynthByPet(k, allEquipList) then
            _red = true
            return true
        end
    end)
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.PetEquipSynth, _red)
end

-- Is the equipment on a pet synthesized?
function PetEquipSystem:GetEquipSynthByPet(assistantId, allEquipList)
    local _isRed = false
    if not GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.PetEquipSynth) then
        return false
    end
    if self.CurPetCellsDic:ContainsKey(assistantId) then
        local _equipCellDic = self.CurPetCellsDic[assistantId].EquipCellDic
        local _func = function(k, v)
            if v.EquipInfo then
                local _cfg = DataConfig.DataPetEquipSynthesis[v.EquipInfo.CfgID]
                if _cfg then
                    if not allEquipList then
                        allEquipList = self:GetAllPetEquip()
                    end
                    local itemflag = true
                    if _cfg.JoinItem and _cfg.JoinItem ~= "" then
                        local itemArr = Utils.SplitNumber(_cfg.JoinItem, '_')
                        if #itemArr >= 2 then
                            local itemID = itemArr[1]
                            local needNum = itemArr[2]
                            local haveNum = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(itemID)
                            if haveNum < needNum then
                                itemflag = false;
                                if _cfg.ItemPrice and _cfg.ItemPrice ~= "" then
                                    local coinArr = Utils.SplitNumber(_cfg.ItemPrice, '_');
                                    if (#coinArr >= 2) then
                                        local coinID = coinArr[1]
                                        local price = coinArr[2]
                                        local haveCoinNum = GameCenter.ItemContianerSystem:GetEconomyWithType(coinID);
                                        if haveCoinNum >= price * (needNum - haveNum) then
                                            itemflag = true;
                                        end
                                        if not self.EquipSynNeedItemList:Contains(coinID) then
                                            self.EquipSynNeedItemList:Add(coinID)
                                        end
                                    end
                                end
                            end
                            if not self.EquipSynNeedItemList:Contains(itemID) then
                                self.EquipSynNeedItemList:Add(itemID)
                            end
                        end
                    end
                    if itemflag then
                        local _quaList = Utils.SplitNumber(_cfg.Quality, '_')
                        local _starList = Utils.SplitNumber(_cfg.Diamond, '_')
                        local _partList = List:New()
                        local _equipList = List:New()
                        if _cfg.JoinPart and _cfg.JoinPart ~= "" then
                            _partList = Utils.SplitNumber(_cfg.JoinPart, '_')
                        end
                        if allEquipList then
                            for i = 1, #allEquipList do
                                if ((#_partList > 0 and _partList:Contains(allEquipList[i].Part)) or #_partList == 0) and allEquipList[i].Quality == 6 and allEquipList[i].StarNum == 1 and _starList:Contains(allEquipList[i].StarNum) and _quaList:Contains(allEquipList[i].Quality) then
                                    _equipList:Add(allEquipList[i])
                                end
                            end
                        end
                        local _per = 0
                        for i = 1, #_equipList do
                            local _starIndex = 0
                            local _quaIndex = 0
                            for j = 1, #_starList do
                                if _starList[j] == _equipList[i].StarNum then
                                    local _starPerList = Utils.SplitNumber(_cfg.DiamondNumber, '_')
                                    if _starPerList[j] then
                                        _starIndex = _starPerList[j]
                                        break
                                    end
                                end
                            end
                            for j = 1, #_quaList do
                                if _quaList[j] == _equipList[i].Quality then
                                    local _quaPerList = Utils.SplitNumber(_cfg.QualityNumber, '_')
                                    if _quaPerList[j] then
                                        _quaIndex = _quaPerList[j]
                                        break
                                    end
                                end
                            end
                            _per = _per + _cfg.JoinNumProbability * _quaIndex * _starIndex / 100000000
                            if _per >= 10000 then
                                break
                            end
                        end
                        if _per >= 10000 then
                            _isRed = true
                            return true
                        end
                    end
                end
            end
        end
        _equipCellDic:ForeachCanBreak(_func)
    end
    return _isRed
end

-- Is it possible to synthesize a piece of equipment on a pet?
function PetEquipSystem:GetEquipSynthByPetEquip(assistantId, equipPart, allEquipList)
    local _isRed = false
    if self.CurPetCellsDic:ContainsKey(assistantId) then
        local _equipCellDic = self.CurPetCellsDic[assistantId].EquipCellDic
        if _equipCellDic:ContainsKey(equipPart) then
            local v = _equipCellDic[equipPart]
            if v.EquipInfo then
                local _cfg = DataConfig.DataPetEquipSynthesis[v.EquipInfo.CfgID]
                if _cfg then
                    if not allEquipList then
                        allEquipList = self:GetAllPetEquip()
                    end
                    local itemflag = true
                    if _cfg.JoinItem and _cfg.JoinItem ~= "" then
                        local itemArr = Utils.SplitNumber(_cfg.JoinItem, '_')
                        if #itemArr >= 2 then
                            local itemID = itemArr[1]
                            local needNum = itemArr[2]
                            local haveNum = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(itemID)
                            if haveNum < needNum then
                                itemflag = false;
                                if _cfg.ItemPrice and _cfg.ItemPrice ~= "" then
                                    local coinArr = Utils.SplitNumber(_cfg.ItemPrice, '_');
                                    if (#coinArr >= 2) then
                                        local coinID = coinArr[1]
                                        local price = coinArr[2]
                                        local haveCoinNum = GameCenter.ItemContianerSystem:GetEconomyWithType(coinID);
                                        if haveCoinNum >= price * (needNum - haveNum) then
                                            itemflag = true;
                                        end
                                        if not self.EquipSynNeedItemList:Contains(coinID) then
                                            self.EquipSynNeedItemList:Add(coinID)
                                        end
                                    end
                                end
                            end
                            if not self.EquipSynNeedItemList:Contains(itemID) then
                                self.EquipSynNeedItemList:Add(itemID)
                            end
                        end
                    end
                    if itemflag then
                        local _quaList = Utils.SplitNumber(_cfg.Quality, '_')
                        local _starList = Utils.SplitNumber(_cfg.Diamond, '_')
                        local _partList = List:New()
                        local _equipList = List:New()
                        if _cfg.JoinPart and _cfg.JoinPart ~= "" then
                            _partList = Utils.SplitNumber(_cfg.JoinPart, '_')
                        end
                        if allEquipList then
                            for i = 1, #allEquipList do
                                if ((#_partList > 0 and _partList:Contains(allEquipList[i].Part)) or #_partList == 0) and allEquipList[i].Quality == 6 and allEquipList[i].StarNum == 1 and _starList:Contains(allEquipList[i].StarNum) and _quaList:Contains(allEquipList[i].Quality) then
                                    _equipList:Add(allEquipList[i])
                                end
                            end
                        end
                        local _per = 0
                        for i = 1, #_equipList do
                            local _starIndex = 0
                            local _quaIndex = 0
                            for j = 1, #_starList do
                                if _starList[j] == _equipList[i].StarNum then
                                    local _starPerList = Utils.SplitNumber(_cfg.DiamondNumber, '_')
                                    if _starPerList[j] then
                                        _starIndex = _starPerList[j]
                                        break
                                    end
                                end
                            end
                            for j = 1, #_quaList do
                                if _quaList[j] == _equipList[i].Quality then
                                    local _quaPerList = Utils.SplitNumber(_cfg.QualityNumber, '_')
                                    if _quaPerList[j] then
                                        _quaIndex = _quaPerList[j]
                                        break
                                    end
                                end
                            end
                            _per = _per + _cfg.JoinNumProbability * _quaIndex * _starIndex / 100000000
                            if _per >= 10000 then
                                break
                            end
                        end
                        if _per >= 10000 then
                            _isRed = true
                        end
                    end
                end
            end
        end
    end
    return _isRed
end

-- Get enhanced configuration
function PetEquipSystem:GetStrengthCfgByLv(lv, PetCellID, Pos)
    return  DataConfig.DataPetEquipInten[PetCellID * 100000000 + Pos * 10000 + lv]
end

-- Get all the equipment in your pet backpack
function PetEquipSystem:GetAllPetEquip()
    local ddressList = GameCenter.NewItemContianerSystem:GetItemListNOGC(LuaContainerType.ITEM_LOCATION_PETEQUIP);
    return ddressList;
end

-- Find pet equipment that can be synthesized
function PetEquipSystem:GetPetEquipCanSyn(quaList, starList, partList)
    local list = List:New()
    local bpModel = GameCenter.NewItemContianerSystem:GetBackpackModelByType(LuaContainerType.ITEM_LOCATION_PETEQUIP);
    if bpModel then
        bpModel.ItemsOfIndex:Foreach(function(k, v)
            if (v and quaList:Contains(v.Quality) and starList:Contains(v.StarNum)) then
                if (partList and #partList > 0) then
                    if (partList:Contains(v.Part)) then
                        list:Add(v);
                    end
                else
                    list:Add(v);
                end
            end
        end)
    end
    list:Sort(function(x, y)
        return x.Power > y.Power
    end);
    return list;
end

-- Obtain the equipment with the highest combat power in each part
function PetEquipSystem:GetHightPetEquipList()
    local _cacheDic = Dictionary:New()
    local bpModel = GameCenter.NewItemContianerSystem:GetBackpackModelByType(LuaContainerType.ITEM_LOCATION_PETEQUIP);
    if bpModel then
        bpModel.ItemsOfIndex:Foreach(function(k, v)
            if (_cacheDic:ContainsKey(v.Part) and _cacheDic[v.Part].Power < v.Power) then
                _cacheDic[v.Part] = v;
            elseif (not _cacheDic:ContainsKey(v.Part)) then
                _cacheDic:Add(v.Part, v);
            end
        end)
    end
    return _cacheDic;
end

-- --------------------------------------------------------------------------------------------------------------------------------
-- Replace pets
function PetEquipSystem:ReqChangeAssiPet(petId, assistantId)
    local _msg = ReqMsg.MSG_Pet.ReqChangeAssiPet:New()
    _msg.petModelId = petId
    _msg.assistantId = assistantId
    _msg:Send()
end

-- Wearing equipment
function PetEquipSystem:ReqPetEquipWear(equipID, partId, assistantId)
    if self:GetPetEquipCellState(partId, assistantId, true) then
        local _msg = ReqMsg.MSG_Pet.ReqPetEquipWear:New()
        _msg.equipId = equipID
        _msg.cellId = partId
        _msg.assistantId = assistantId
        _msg:Send()
    end
end

-- Uninstall the equipment
function PetEquipSystem:ReqPetEquipUnWear(partId, assistantId)
    local _msg = ReqMsg.MSG_Pet.ReqPetEquipUnWear:New()
    _msg.cellId = partId
    _msg.assistantId = assistantId
    _msg:Send()
end

-- Strengthen equipment
function PetEquipSystem:ReqPetEquipStrength(partId, assistantId)
    local _msg = ReqMsg.MSG_Pet.ReqPetEquipStrength:New()
    _msg.cellId = partId
    _msg.assistantId = assistantId
    _msg:Send()
end

-- Activate the reinforcement target
function PetEquipSystem:ReqPetEquipActiveInten(assistantId)
    if self.CurPetCellsDic:ContainsKey(assistantId) then
        local _cfg = DataConfig.DataPetEquipIntenClass[self.CurPetCellsDic[assistantId].TotalStrActiveID + 1]
        if _cfg then
            if self.CurPetCellsDic[assistantId].TotalStrLv >= _cfg.SuitLevel then
                local _msg = ReqMsg.MSG_Pet.ReqPetEquipActiveInten:New()
                _msg.assistantId = assistantId
                _msg.strengthActiveId = _cfg.Id
                _msg:Send()
            else
                GameCenter.MsgPromptSystem:ShowPrompt(UIUtils.CSFormat(DataConfig.DataMessageString.Get("C_PETEQUIP_TOTALSTR_TIPS"), _cfg.SuitLevel, self.CurPetCellsDic[assistantId].TotalStrLv))
            end
        else
            GameCenter.MsgPromptSystem:ShowPrompt(DataConfig.DataMessageString.Get("C_PETEQUIP_MAXLV"))
        end
    end
end

-- Soul-attached equipment
function PetEquipSystem:ReqPetEquipSoul(partId, assistantId)
    local _msg = ReqMsg.MSG_Pet.ReqPetEquipSoul:New()
    _msg.cellId = partId
    _msg.assistantId = assistantId
    _msg:Send()
end

-- Activate the whole body soul-bearing effect
function PetEquipSystem:ReqPetEquipActiveSoul(assistantId)
    if self.CurPetCellsDic:ContainsKey(assistantId) then
        local _cfg = DataConfig.DataPetEquipSoulboundClass[self.CurPetCellsDic[assistantId].TotalSoulActiveID + 1]
        if _cfg then
            if self.CurPetCellsDic[assistantId].TotalSoulLv >= _cfg.SuitLevel then
                local _msg = ReqMsg.MSG_Pet.ReqPetEquipActiveSoul:New()
                _msg.assistantId = assistantId
                _msg.soulActiveId = _cfg.Id
                _msg:Send()
            else
                GameCenter.MsgPromptSystem:ShowPrompt(UIUtils.CSFormat(DataConfig.DataMessageString.Get("C_PETEQUIP_SOULLVLESS"), _cfg.SuitLevel, self.CurPetCellsDic[assistantId].TotalSoulLv))
            end
        else
            GameCenter.MsgPromptSystem:ShowPrompt(DataConfig.DataMessageString.Get("C_PETEQUIP_MAXLV"))
        end
    end
end
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Send pet list
function PetEquipSystem:ResPetCellsList(list)
    self.CurPetCellsDic:Clear()
    for i = 1, #list do
        local _tmp = {}
        _tmp.CellID = list[i].assistantId
        if list[i].petId then
            _tmp.PetID = list[i].petId
        else
            _tmp.PetID = 0
        end
        if list[i].strengthActiveId then
            _tmp.TotalStrActiveID = list[i].strengthActiveId
        else
            _tmp.TotalStrActiveID = 0
        end
        if list[i].soulActiveId then
            _tmp.TotalSoulActiveID = list[i].soulActiveId
        else
            _tmp.TotalSoulActiveID = 0
        end
        if list[i].score then
            _tmp.Score = list[i].score
        else
            _tmp.Score = 0
        end
        _tmp.EquipCellDic = Dictionary:New()
        _tmp.TotalStrLv = 0
        _tmp.TotalSoulLv = 0
        if list[i].cellList then
            for j = 1, #list[i].cellList do
                local _equipTmp = {}
                _equipTmp.CellID = list[i].cellList[j].cellId
                if list[i].cellList[j].strengthLv then
                    _equipTmp.StrengthLv = list[i].cellList[j].strengthLv
                else
                    _equipTmp.StrengthLv = 0
                end
                _tmp.TotalStrLv = _tmp.TotalStrLv + _equipTmp.StrengthLv
                if list[i].cellList[j].soulLv then
                    _equipTmp.SoulLv = list[i].cellList[j].soulLv
                else
                    _equipTmp.SoulLv = 0
                end
                _tmp.TotalSoulLv = _tmp.TotalSoulLv + _equipTmp.SoulLv
                if list[i].cellList[j].equip then
                    _equipTmp.EquipInfo = LuaItemBase.CreateItemBaseByMsg(list[i].cellList[j].equip)
                else
                    _equipTmp.EquipInfo = nil
                end
                _tmp.EquipCellDic:Add(_equipTmp.CellID, _equipTmp)
            end
        end
        if list[i].open then
            _tmp.IsOpen = true
            _tmp.Condition = nil
            _tmp.Index = _tmp.CellID
        else
            _tmp.Index = _tmp.CellID + 1000
            _tmp.IsOpen = false
            local _keys = _tmp.EquipCellDic:GetKeys()
            local _cfg = DataConfig.DataPetEquipUnlock[_tmp.CellID * 10000 + _keys[1]]
            if _cfg then
                if _cfg.SiteUnlock and _cfg.SiteUnlock ~= "" then
                    _tmp.Condition = _cfg.SiteUnlock
                elseif _cfg.SiteUnlockItem and _cfg.SiteUnlockItem ~= "" then
                    _tmp.Condition = _cfg.SiteUnlockItem
                end
            end
        end
        self.CurPetCellsDic:Add(list[i].assistantId, _tmp)
    end
    self.CurPetCellsDic:SortValue(
        function(a, b)
            return a.Index < b.Index
        end
    )
    self.IsSetRed = true
    self:SetEquipStrengthRed()
    self:SetEquipSoulRed()
    self:SetPetFightRed()
end

-- Replace the help pet to return
function PetEquipSystem:ResChangeAssiPet(msg)
    if self.CurPetCellsDic[msg.assistantId] then
        self.CurPetCellsDic[msg.assistantId].PetID = msg.petModelId
    end
    self.IsSetRed = true
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_PETEQUIP_PETLISTUPDATE)
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_REFRESH_ASSIST_PET)
end

function PetEquipSystem:ResPetAssistantScoreUpdate(msg)
    if self.CurPetCellsDic[msg.assistantId] then
        self.CurPetCellsDic[msg.assistantId].Score = msg.score
    end
end

-- Wearing equipment back
function PetEquipSystem:ResEquipWear(msg)
    if self.CurPetCellsDic[msg.assistantId] then
        local _list = self.CurPetCellsDic[msg.assistantId].EquipCellDic
        _list:ForeachCanBreak(function(k, v)
            if k == msg.cellId then
                v.EquipInfo = LuaItemBase.CreateItemBase(msg.equipModelId)
                if v.EquipInfo then
                    v.EquipInfo.DBID = msg.equipId
                end
            end
        end)
    end
    self.IsSetRed = true
    self:SetEquipStrengthRed()
    self:SetEquipSoulRed()
    self:SetPetFightRed()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_PETEQUIP_WEARUPDATE, msg.assistantId)
end

-- Write down the equipment and return
function PetEquipSystem:ResPetEquipUnWear(msg)
    if self.CurPetCellsDic[msg.assistantId] then
        local _list = self.CurPetCellsDic[msg.assistantId].EquipCellDic
        _list:ForeachCanBreak(function(k, v)
            if k == msg.cellId then
                v.EquipInfo = nil
            end
        end)
    end
    self.IsSetRed = true
    self:SetEquipStrengthRed()
    self:SetEquipSoulRed()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_PETEQUIP_WEARUPDATE, msg.assistantId)
end

-- Reinforced equipment return
function PetEquipSystem:ResPetEquipStrength(msg)
    if self.CurPetCellsDic[msg.assistantId] then
        local _lv = 0
        self.CurPetCellsDic[msg.assistantId].EquipCellDic:ForeachCanBreak(function(k, v)
            if k == msg.cellId then
                v.StrengthLv = msg.strengthLv
            end
            _lv = _lv + v.StrengthLv
        end)
        self.CurPetCellsDic[msg.assistantId].TotalStrLv = _lv
    end
    self:SetEquipStrengthRed()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_PETEQUIP_STRENGTHRESULT, true)
end

-- Soul-attached equipment returns
function PetEquipSystem:ResPetEquipSoul(msg)
    if self.CurPetCellsDic[msg.assistantId] then
        local _lv = 0
        self.CurPetCellsDic[msg.assistantId].EquipCellDic:ForeachCanBreak(function(k, v)
            if k == msg.cellId then
                v.SoulLv = msg.soulLv
            end
            _lv = _lv + v.SoulLv
        end)
        self.CurPetCellsDic[msg.assistantId].TotalSoulLv = _lv
    end
    self:SetEquipSoulRed()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_PETEQUIP_SoulRESULT, true)
end

-- Activate the whole body strengthening effect and return
function PetEquipSystem:ResPetEquipActiveInten(msg)
    if self.CurPetCellsDic[msg.assistantId] then
        self.CurPetCellsDic[msg.assistantId].TotalStrActiveID = msg.strengthActiveId
        GameCenter.RedPointSystem:RemoveFuncCondition(FunctionStartIdCode.PetEquipStrength, msg.assistantId*1000)
        local _cfg = DataConfig.DataPetEquipIntenClass[msg.strengthActiveId + 1]
        if _cfg then
            if _cfg.SuitLevel <= self.CurPetCellsDic[msg.assistantId].TotalStrLv then
                GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.PetEquipStrength, msg.assistantId*1000, RedPointCustomCondition(true))
            else
                GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.PetEquipStrength, msg.assistantId*1000, RedPointCustomCondition(false))
            end
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_PETEQUIP_TOTALSTRENGTHRESULT, true)
end

-- Activate the whole body soul-bearing effect to return
function PetEquipSystem:ResPetEquipActiveSoul(msg)
    if self.CurPetCellsDic[msg.assistantId] then
        self.CurPetCellsDic[msg.assistantId].TotalSoulActiveID = msg.soulActiveId
        GameCenter.RedPointSystem:RemoveFuncCondition(FunctionStartIdCode.PetEquipFuhun, msg.assistantId*1000)
        local _cfg = DataConfig.DataPetEquipSoulboundClass[msg.soulActiveId + 1]
        if _cfg then
            if _cfg.SuitLevel <= self.CurPetCellsDic[msg.assistantId].TotalSoulLv then
                GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.PetEquipFuhun, msg.assistantId*1000, RedPointCustomCondition(true))
            else
                GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.PetEquipFuhun, msg.assistantId*1000, RedPointCustomCondition(false))
            end
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_PETEQUIP_TotalSoulRESULT, true)
end

-- Equipment synthesis return
function PetEquipSystem:ResPetEquipSynthesis(msg)
    if self.CurPetCellsDic[msg.assistantId] then
        local _list = self.CurPetCellsDic[msg.assistantId].EquipCellDic
        _list:ForeachCanBreak(function(k, v)
            if k == msg.cellId and msg.newEquip then
                v.EquipInfo = LuaItemBase.CreateItemBaseByMsg(msg.newEquip)
                if v.EquipInfo then
                    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_PETEQUIP_WEARUPDATE, msg.assistantId)
                end
            end
        end)
    end
    self.IsSetRed = true
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_PETEQUIP_SYNTHRESULT, msg.success)
end

-- Automatic equipment decomposition settings save return
function PetEquipSystem:ResPetEquipDecomposeSetting(msg)
    self.IsAutoSplit = msg.set
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATEAUTOSMELTSTATE)
end
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

return PetEquipSystem
