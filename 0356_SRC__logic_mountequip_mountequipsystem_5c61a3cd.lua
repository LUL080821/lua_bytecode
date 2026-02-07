------------------------------------------------
-- Author:
-- Date: 2020-11-04
-- File: MountEquipSystem.lua
-- Module: MountEquipSystem
-- Description: Mount Equipment System Code
------------------------------------------------
local FightUtils = require "Logic.Base.FightUtils.FightUtils"
local RedPointCustomCondition = CS.Thousandto.Code.Logic.RedPointCustomCondition
local RedPointItemCondition = CS.Thousandto.Code.Logic.RedPointItemCondition
local RedPointTaskCondition = CS.Thousandto.Code.Logic.RedPointTaskCondition

local MountEquipSystem = {
    -- List of currently clicked support mount IDs
    ClickMountList = List:New(),
    -- Current assisting data
    CurMountCellsDic = Dictionary:New(),
    -- Frame count, red dot interval use
    FrameCount = 0,
    -- List of additional items required for equipment synthesis
    EquipSynNeedItemList = List:New(),
    -- Equipment unlocked table data
    MountEquipUnlockDict = Dictionary:New(),
    -- Equipment rating
    MountEquipScoreDict = Dictionary:New(),
    -- Total equipment rating
    EquipScores = 0,
    -- Checked to automatically decompose to true
    IsAutoSplit = false,
    -- Current level
    CurLevel = 0,
    -- Current experience
    CurExp = 0,
    -- Is the function enabled
    FuncOpen = 0,
    -- The quality of automatic decomposition
    Autocolor = 0,
    -- Automatically decomposed star rating
    AutoStar = 0,
}

-- initialization
function MountEquipSystem:Initialize()
    self.ClickMountList:Clear()

    DataConfig.DataHorseEquipUnlock:Foreach(
        function(_key, _cfg)
            if self.MountEquipUnlockDict:ContainsKey(_cfg.Site) then
                self.MountEquipUnlockDict[_cfg.Site]:Add(_cfg)
            else
                local _cfgList = List:New()
                _cfgList:Add(_cfg)
                self.MountEquipUnlockDict:Add(_cfg.Site, _cfgList)
            end
        end
    )

    DataConfig.DataHorseEquipScore:Foreach(
        function(_key, _cfg)
            if self.MountEquipScoreDict:ContainsKey(_cfg.Site) then
                self.MountEquipScoreDict[_cfg.Site]:Add(_cfg)
            else
                local _cfgList = List:New()
                _cfgList:Add(_cfg)
                self.MountEquipScoreDict:Add(_cfg.Site, _cfgList)
            end
        end
    )

    self.EquipChangeEvent = Utils.Handler(self.OnEquipUpdate, self)
    GameCenter.RegFixEventHandle(LogicLuaEventDefine.EVENT_MOUNTEQUIP_BAGCHANGE, self.EquipChangeEvent)
end

-- De-initialization
function MountEquipSystem:UnInitialize()
    self.MountEquipUnlockDict:Clear()
    self.MountEquipScoreDict:Clear()
    GameCenter.UnRegFixEventHandle(LogicLuaEventDefine.EVENT_MOUNTEQUIP_BAGCHANGE, self.EquipChangeEvent)
end

function MountEquipSystem:OnEquipUpdate(obj, sender)
    self.IsSetRed = true
end

function MountEquipSystem:Update(dt)
    if self.FrameCount then
        self.FrameCount = self.FrameCount + 1
        if self.FrameCount >= 20 and self.IsSetRed then
            local _wearRed = false
            local _allEquipList = self:GetHightMountEquipList()
            local _keys = self.CurMountCellsDic:GetKeys()
            for i = 1, #_keys do
                --if self.CurMountCellsDic[_keys[i]].Score > 0 and not _wearRed and self:GetEquipWearRedByMountCell(_keys[i], _allEquipList) then
                if self.CurMountCellsDic[_keys[i]].Score > 0 and not _wearRed and self:GetEquipWearRedByMountCell(_keys[i], _allEquipList) then
                    _wearRed = true
                    break
                end
            end
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MOUNTEQUIP_MOUNTLISTUPDATE)
            GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.MountEquipWear, _wearRed)
            self.IsSetRed = false
            self.FrameCount = 0
            self:SetMountFightRed()
        end
    end
end

function MountEquipSystem:GetEquipWearRedByMountCell(assistantId, allEquipList)
    local _red = false
    local _equipCellDic = self.CurMountCellsDic[assistantId].EquipCellDic
    local _keys = _equipCellDic:GetKeys()
    for i = 1, #_keys do
        if self:GetMountEquipCellState(_keys[i], assistantId) then
            local _score = 0
            if _equipCellDic[_keys[i]].EquipInfo then
                _score = _equipCellDic[_keys[i]].EquipInfo.ItemInfo.Score
            end
            if allEquipList:ContainsKey(_keys[i]) then
                local _info = allEquipList[_keys[i]].ItemInfo
                if _info.Score > _score then
                    _red = true
                end
            end
        else
            break
        end
    end
    if _red then
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.MountEquip, _red);
    end
    return _red
end

-- Set up mounts to help red dots
function MountEquipSystem:SetMountFightRed()
    -- GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.MountFight)
    -- self.CurMountCellsDic:ForeachCanBreak(function(k, v)
    --     local _curModel = GameCenter.NatureSystem.NatureMountData.super:GetCurShowModel()
    --     local _modlDta = GameCenter.NatureSystem.NatureMountData.super:GetModelData(_curModel)
    --     local _isActive = _curModel == GameCenter.NatureSystem.NatureMountData.super.CurModel and _modlDta.IsActive
    --     if v.MountID == 0 and v.IsOpen and not self.ClickMountList:Contains(k) and _isActive then
    --         GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.MountFight, k, RedPointCustomCondition(true))
    --     elseif v.MountID == 0 and not v.IsOpen and v.Condition then
    --         local _ar = Utils.SplitNumber(v.Condition, '_')
    --         if _ar[1] ~= 1 and _ar[1] ~= 56 and _ar[1] ~= 150 then
    --             local _conditions = List:New();
    --             _conditions:Add(RedPointItemCondition(_ar[1], _ar[2]));
    --             GameCenter.RedPointSystem:LuaAddFuncCondition(FunctionStartIdCode.MountFight, k * 1000, _conditions);
    --         end
    --     end
    -- end)
    local _EquipInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.MountEquip).IsShowRedPoint
    local _SynthInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.MountEquipSynth).IsShowRedPoint
    local _StrengthInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.MountEquipStrength).IsShowRedPoint
    local _WearInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.MountEquipWear).IsShowRedPoint
    local _FuhunInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.MountEquipFuhun).IsShowRedPoint
    local _FightInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.MountFight).IsShowRedPoint

    local _red = _SynthInfo or _StrengthInfo or _WearInfo or _FuhunInfo or _FightInfo
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.MountEquip, _red);
end

-- Check if a mount is helpful
function MountEquipSystem:MountIsFighting(mountId)
    local _isFight = false
    self.CurMountCellsDic:ForeachCanBreak(function(k, v)
        if v.MountID == mountId then
            _isFight = true
            return true
        end
    end)
    return _isFight
end

-- Check the list of mounts for assisting war
function MountEquipSystem:GetFightMountList()
    local list = List:New()
    local _index = 1
    self.CurMountCellsDic:ForeachCanBreak(function(k, v)
        if v.MountID > 0 then
            if _index ~= 1 then
                list:Add(v.MountID)
            end
            _index = _index + 1
        end
    end)
    return list
end

function MountEquipSystem:GetMountEquipScoreByPart(cellId, part)
    local _isFight = 0
    if self.CurMountCellsDic:ContainsKey(cellId) then
        if self.CurMountCellsDic[cellId].EquipCellDic:ContainsKey(part) and self.CurMountCellsDic[cellId].EquipCellDic[part].EquipInfo then
            _isFight = self.CurMountCellsDic[cellId].EquipCellDic[part].EquipInfo.ItemInfo.Score
        else
            if not self:GetMountEquipCellState(part, cellId) then
                _isFight = -1
            end
        end
    end
    return _isFight
end

function MountEquipSystem:GetMountEquipByPart(cellId, part)
    local _info = nil
    if self.CurMountCellsDic:ContainsKey(cellId) then
        if self.CurMountCellsDic[cellId].EquipCellDic:ContainsKey(part) then
            _info = self.CurMountCellsDic[cellId].EquipCellDic[part].EquipInfo
        end
    end
    return _info
end

-- Get the reinforcement attributes
function MountEquipSystem:GetMountStrengthAtt(assistantId, part)
    local _dic = Dictionary:New()
    if self.CurMountCellsDic:ContainsKey(assistantId) then
        if self.CurMountCellsDic[assistantId].EquipCellDic:ContainsKey(part) then
            local _lv = self.CurMountCellsDic[assistantId].EquipCellDic[part].StrengthLv
            local _cfg = DataConfig.DataHorseEquipInten[assistantId * 100000000 + part * 10000 + _lv]
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
function MountEquipSystem:GetMountSoulAtt(assistantId, part)
    local _dic = Dictionary:New()
    if self.CurMountCellsDic:ContainsKey(assistantId) then
        if self.CurMountCellsDic[assistantId].EquipCellDic:ContainsKey(part) then
            local _lv = self.CurMountCellsDic[assistantId].EquipCellDic[part].SoulLv
            local _cfg = DataConfig.DataHorseEquipSoulbound[assistantId * 100000000 + part * 10000 + _lv]
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
function MountEquipSystem:GetMountEquipSoulLv(assistantId, part)
    if self.CurMountCellsDic:ContainsKey(assistantId) then
        if self.CurMountCellsDic[assistantId].EquipCellDic:ContainsKey(part) then
            local _lv = self.CurMountCellsDic[assistantId].EquipCellDic[part].SoulLv
            return _lv
        end
    end
    return 0
end

-- Set up equipment enhancement red dots
function MountEquipSystem:SetEquipStrengthRed()
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.MountEquipStrength)
    self.CurMountCellsDic:ForeachCanBreak(function(k, v)
        v.EquipCellDic:ForeachCanBreak(function(ik, iv)
            if iv.EquipInfo then
                self:SetEquipCellStrengthRed(k, ik)
            end
        end)
        local _cfg = DataConfig.DataHorseEquipIntenClass[v.TotalStrActiveID + 1]
        if _cfg then
            if _cfg.SuitLevel <= v.TotalStrLv then
                GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.MountEquipStrength, k*1000, RedPointCustomCondition(true))
            else
                GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.MountEquipStrength, k*1000, RedPointCustomCondition(false))
            end
        end
    end)
end

-- Set up equipment with soul-attached red dots
function MountEquipSystem:SetEquipSoulRed()
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.MountEquipFuhun)
    self.CurMountCellsDic:ForeachCanBreak(function(k, v)
        v.EquipCellDic:ForeachCanBreak(function(ik, iv)
            if iv.EquipInfo then
                self:SetEquipCellSoulRed(k, ik)
            end
        end)
        local _cfg = DataConfig.DataHorseEquipSoulboundClass[v.TotalSoulActiveID + 1]
        if _cfg then
            if _cfg.SuitLevel <= v.TotalSoulLv then
                GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.MountEquipFuhun, k*1000, RedPointCustomCondition(true))
            else
                GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.MountEquipFuhun, k*1000, RedPointCustomCondition(false))
            end
        end
    end)
end

-- A certain equipment with soul-attached red dot
function MountEquipSystem:SetEquipCellSoulRed(cellId, partId)
    if self.CurMountCellsDic:ContainsKey(cellId) then
        local info = self.CurMountCellsDic[cellId]
        if info.EquipCellDic:ContainsKey(partId) then
            if info.EquipCellDic[partId].EquipInfo then
                local _cfg = DataConfig.DataHorseEquipSoulbound[cellId * 100000000 + partId * 10000 + info.EquipCellDic[partId].SoulLv]
                local _cfg1 = DataConfig.DataHorseEquipSoulbound[cellId * 100000000 + partId * 10000 + info.EquipCellDic[partId].SoulLv + 1]
                if _cfg and _cfg1 and _cfg.Consume and _cfg.Consume ~= "" then
                    local _itemArr = Utils.SplitNumber(_cfg.Consume, '_')
                    GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.MountEquipFuhun, cellId*1000+partId, RedPointItemCondition(_itemArr[1], _itemArr[2]))
                end
            end
        end
    end
end

-- Get a soul-attached red dot in a certain assisted position
function MountEquipSystem:GetMountCellSoulRed(cellId)
    local _red = false
    local _dic = self.CurMountCellsDic
    if cellId and _dic[cellId] then
        local _keys = _dic[cellId].EquipCellDic:GetKeys()
        local _equipDic = _dic[cellId].EquipCellDic
        for i = 1, #_keys do
            local _equip = _equipDic[_keys[i]].EquipInfo
            if _equip then
                if GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.MountEquipFuhun, cellId * 1000 + _keys[i]) then
                    _red = true
                    break
                end
            end
        end
        if not _red then
            if GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.MountEquipFuhun, cellId * 1000) then
                _red = true
            end
        end
    end
    if not _red then
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.MountEquipFuhun, false);
        self:SetMountFightRed()
    end 
    return _red
end

-- A certain equipment reinforces red dot
function MountEquipSystem:SetEquipCellStrengthRed(cellId, partId)
    if self.CurMountCellsDic:ContainsKey(cellId) then
        local info = self.CurMountCellsDic[cellId]
        if info.EquipCellDic:ContainsKey(partId) then
            if info.EquipCellDic[partId].EquipInfo then
                local _cfg = DataConfig.DataHorseEquipInten[cellId * 100000000 + partId * 10000 + info.EquipCellDic[partId].StrengthLv]
                local _cfg1 = DataConfig.DataHorseEquipInten[cellId * 100000000 + partId * 10000 + info.EquipCellDic[partId].StrengthLv + 1]
                if _cfg and _cfg1 and _cfg.Consume and _cfg.Consume ~= "" then
                    local _itemArr = Utils.SplitNumber(_cfg.Consume, '_')
                    GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.MountEquipStrength, cellId*1000+partId, RedPointItemCondition(_itemArr[1], _itemArr[2]))
                end
            end
        end
    end
end

-- Get a reinforced red dot for a certain assist position
function MountEquipSystem:GetMountCellStrengthRed(cellId)
    local _dic = self.CurMountCellsDic
    local _strengthRed = false
    if cellId and _dic[cellId] then
        local _keys = _dic[cellId].EquipCellDic:GetKeys()
        local _equipDic = _dic[cellId].EquipCellDic
        for i = 1, #_keys do
            local _equip = _equipDic[_keys[i]].EquipInfo
            if _equip then
                if GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.MountEquipStrength, cellId * 1000 + _keys[i]) then
                    _strengthRed = true
                    break
                end
            end
        end
        if not _strengthRed then
            if GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.MountEquipStrength, cellId * 1000) then
                _strengthRed = true
            end
        end
    end
    return _strengthRed
end

-- Get the activated full-body enhancement level (using the configuration table as ID)
function MountEquipSystem:GetTotalActiveStrLv(assistantId)
    if self.CurMountCellsDic[assistantId] then
        return self.CurMountCellsDic[assistantId].TotalStrActiveID
    end
    return 1
end

-- Get the activated full-body possession level (using the configuration table as ID)
function MountEquipSystem:GetTotalActiveSoulLv(assistantId)
    if self.CurMountCellsDic[assistantId] then
        return self.CurMountCellsDic[assistantId].TotalSoulActiveID
    end
    return 1
end

function MountEquipSystem:GetMountEquipCellState(partId, assistantId, showMsg)
    local _state = false
    local _cfg = DataConfig.DataHorseEquipUnlock[assistantId * 10000 + partId]
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
                local _mountLv = GameCenter.MountEquipSystem.CurLevel
                if _ar[2] and _mountLv then
                    if _mountLv >= _ar[2] then
                        _state = true
                    else
                        _state = false
                        if showMsg then
                            Utils.ShowPromptByEnum("C_MOUNT_EQUIP_EQUIPWEAR2", _ar[2])
                        end
                    end
                end
            end
        end
    end
    return _state
end

-- Is the equipment on a certain mount possible to synthesize
function MountEquipSystem:GetEquipSynthByMount(assistantId, allEquipList)
    local _isRed = false
    if self.CurMountCellsDic:ContainsKey(assistantId) then
        local _equipCellDic = self.CurMountCellsDic[assistantId].EquipCellDic
        local _func = function(k, v)
            if v.EquipInfo then
                local _cfg = DataConfig.DataHorseEquipSynthesis[v.EquipInfo.CfgID]
                if _cfg then
                    if not allEquipList then
                        allEquipList = self:GetAllMountEquip()
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
                        local _probList = Utils.SplitNumber(_cfg.JoinNumProbability, '_')
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
                        local _gradle = false
                        for i = 1, #_equipList do
                            local _equipGrade = v.EquipInfo:GetGrade()
                            local _bagEquipGrade = _equipList[i].Grade
                            _gradle = _equipGrade <= _bagEquipGrade or (_equipGrade > _bagEquipGrade and _equipGrade - _bagEquipGrade <= 2)
                            -- if _gradle then
                            --     break
                            -- end
                            local _qualityPerList = Utils.SplitNumber(_cfg.QualityNumber, '_')
                            local _starPerList = Utils.SplitNumber(_cfg.DiamondNumber, '_')
                            local _levelPerList = Utils.SplitNumber(_cfg.JoinNumProbability, '_')
                            local _basePer = 0
                            if _bagEquipGrade == v.EquipInfo:GetGrade() then
                                _basePer = _levelPerList[1]
                            elseif _bagEquipGrade > v.EquipInfo:GetGrade() then
                                _basePer = _levelPerList[2]
                            elseif _bagEquipGrade == v.EquipInfo:GetGrade() - 1 then
                                _basePer = _levelPerList[3]
                            elseif _bagEquipGrade <= v.EquipInfo:GetGrade() - 2 then
                                _basePer = _levelPerList[4]
                            end
                            local _findIndex = 0
                            for j = 1, #_quaList do
                                if _equipList[i].Quality == _quaList[j] then
                                    _findIndex = j
                                end
                            end
                            if _qualityPerList[_findIndex] and _basePer then
                                _basePer = _basePer * _qualityPerList[_findIndex] / 10000
                            end
                            _findIndex = 0
                            for j = 1, #_starList do
                                if _equipList[i].StarNum == _starList[j] then
                                    _findIndex = j
                                end
                            end
                            if _starPerList[_findIndex] and _basePer then
                                _basePer = _basePer * _starPerList[_findIndex] / 10000
                            end
                            if not _basePer then
                                _basePer = 0
                            end
                            _per = _per + _basePer
                        end
                        if _per >= 10000 and _gradle then
                            _isRed = true
                            return true
                        end
                    end
                end
            end
        end
        _equipCellDic:ForeachCanBreak(_func)
    end
    if _isRed then
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.MountEquip, _isRed);
    end
    return _isRed
end

-- Is it possible to synthesize a piece of equipment on a mount?
function MountEquipSystem:GetEquipSynthByMountEquip(assistantId, equipPart, allEquipList)
    local _isRed = false
    if self.CurMountCellsDic:ContainsKey(assistantId) then
        local _equipCellDic = self.CurMountCellsDic[assistantId].EquipCellDic
        if _equipCellDic:ContainsKey(equipPart) then
            local v = _equipCellDic[equipPart]
            if v.EquipInfo then
                local _cfg = DataConfig.DataHorseEquipSynthesis[v.EquipInfo.CfgID]
                if _cfg then
                    if not allEquipList then
                        allEquipList = self:GetAllMountEquip()
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
                        local _probList = Utils.SplitNumber(_cfg.JoinNumProbability, '_')
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
                        local _gradle = false
                        for i = 1, #_equipList do
                            local _equipGrade = v.EquipInfo:GetGrade()
                            local _bagEquipGrade = _equipList[i].Grade
                            _gradle = _equipGrade <= _bagEquipGrade or (_equipGrade > _bagEquipGrade and _equipGrade - _bagEquipGrade <= 2)
                            -- if _gradle then
                            --     break
                            -- end
                            local _qualityPerList = Utils.SplitNumber(_cfg.QualityNumber, '_')
                            local _starPerList = Utils.SplitNumber(_cfg.DiamondNumber, '_')
                            local _levelPerList = Utils.SplitNumber(_cfg.JoinNumProbability, '_')
                            local _basePer = 0
                            if _bagEquipGrade == v.EquipInfo:GetGrade() then
                                _basePer = _levelPerList[1]
                            elseif _bagEquipGrade > v.EquipInfo:GetGrade() then
                                _basePer = _levelPerList[2]
                            elseif _bagEquipGrade == v.EquipInfo:GetGrade() - 1 then
                                _basePer = _levelPerList[3]
                            elseif _bagEquipGrade <= v.EquipInfo:GetGrade() - 2 then
                                _basePer = _levelPerList[4]
                            end
                            local _findIndex = 0
                            for j = 1, #_quaList do
                                if _equipList[i].Quality == _quaList[j] then
                                    _findIndex = j
                                end
                            end
                            if _qualityPerList[_findIndex] and _basePer then
                                _basePer = _basePer * _qualityPerList[_findIndex] / 10000
                            end
                            _findIndex = 0
                            for j = 1, #_starList do
                                if _equipList[i].StarNum == _starList[j] then
                                    _findIndex = j
                                end
                            end
                            if _starPerList[_findIndex] and _basePer then
                                _basePer = _basePer * _starPerList[_findIndex] / 10000
                            end
                            if not _basePer then
                                _basePer = 0
                            end
                            _per = _per + _basePer
                        end
                        if _per >= 10000 and _gradle then
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
function MountEquipSystem:GetStrengthCfgByLv(lv, MountCellID, Pos)
    return  DataConfig.DataHorseEquipInten[MountCellID * 100000000 + Pos * 10000 + lv]
end

-- Get all the equipment in the mount backpack
function MountEquipSystem:GetAllMountEquip()
    local ddressList = GameCenter.NewItemContianerSystem:GetItemListNOGC(LuaContainerType.ITEM_LOCATION_MOUNTEQUIP);
    return ddressList;
end

-- Find mount equipment that can be synthesized
function MountEquipSystem:GetMountEquipCanSyn(quaList, starList, partList, selectEquipInfo)
    local list = List:New()
    local bpModel = GameCenter.NewItemContianerSystem:GetBackpackModelByType(LuaContainerType.ITEM_LOCATION_MOUNTEQUIP);
    if bpModel then
        bpModel.ItemsOfIndex:Foreach(function(k, v)
            if (v and quaList:Contains(v.Quality) and starList:Contains(v.StarNum) and (v.Grade >= selectEquipInfo.Grade or (v.Grade < selectEquipInfo.Grade and (selectEquipInfo.Grade - v.Grade <= 2)))) then
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
        return x.ItemInfo.Score > y.ItemInfo.Score
    end);
    return list;
end

-- Obtain the equipment with the highest combat power in each part
function MountEquipSystem:GetHightMountEquipList()
    local _cacheDic = Dictionary:New()
    local bpModel = GameCenter.NewItemContianerSystem:GetBackpackModelByType(LuaContainerType.ITEM_LOCATION_MOUNTEQUIP);
    if bpModel then
        bpModel.ItemsOfIndex:Foreach(function(k, v)
            if (_cacheDic:ContainsKey(v.Part) and _cacheDic[v.Part].ItemInfo.Score < v.ItemInfo.Score) then
                _cacheDic[v.Part] = v;
            elseif (not _cacheDic:ContainsKey(v.Part)) then
                _cacheDic:Add(v.Part, v);
            end
        end)
    end
    return _cacheDic;
end

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Change the assisted mount
function MountEquipSystem:ReqMountChangeAssi(modelId, assistantId)
    local _msg = ReqMsg.MSG_Horse.ReqMountChangeAssi:New()
    _msg.mountModelId = modelId
    _msg.assistantId = assistantId
    _msg:Send()
end

-- Wearing equipment
function MountEquipSystem:ReqMountEquipWear(equipID, partId, assistantId)
    if self:GetMountEquipCellState(partId, assistantId, true) then
        local _msg = ReqMsg.MSG_Horse.ReqMountEquipWear:New()
        _msg.equipId = equipID
        _msg.cellId = partId
        _msg.assistantId = assistantId
        _msg:Send()
    end
end

-- Uninstall the equipment
function MountEquipSystem:ReqMountEquipUnWear(partId, assistantId)
    local _msg = ReqMsg.MSG_Horse.ReqMountEquipUnWear:New()
    _msg.cellId = partId
    _msg.assistantId = assistantId
    _msg:Send()
end

-- Strengthen equipment
function MountEquipSystem:ReqMountEquipStrength(partId, assistantId)
    local _msg = ReqMsg.MSG_Horse.ReqMountEquipStrength:New()
    _msg.cellId = partId
    _msg.assistantId = assistantId
    _msg:Send()
end

-- Activate the reinforcement target
function MountEquipSystem:ReqMountEquipActiveInten(assistantId)
    if self.CurMountCellsDic:ContainsKey(assistantId) then
        local _activeID = self.CurMountCellsDic[assistantId].TotalStrActiveID + 1
        local _cfg = DataConfig.DataHorseEquipIntenClass[_activeID]
        if _cfg then
            if self.CurMountCellsDic[assistantId].TotalStrLv >= _cfg.SuitLevel then
                local _msg = ReqMsg.MSG_Horse.ReqMountEquipActiveInten:New()
                _msg.assistantId = assistantId
                _msg.strengthActiveId = _cfg.Id
                _msg:Send()
            else
                GameCenter.MsgPromptSystem:ShowPrompt(UIUtils.CSFormat(DataConfig.DataMessageString.Get("C_PETEQUIP_TOTALSTR_TIPS"), _cfg.SuitLevel, self.CurMountCellsDic[assistantId].TotalStrLv))
            end
        else
            GameCenter.MsgPromptSystem:ShowPrompt(DataConfig.DataMessageString.Get("C_PETEQUIP_MAXLV"))
        end
    end
end

-- Soul-attached equipment
function MountEquipSystem:ReqMountEquipSoul(partId, assistantId)
    local _msg = ReqMsg.MSG_Horse.ReqMountEquipSoul:New()
    _msg.cellId = partId
    _msg.assistantId = assistantId
    _msg:Send()
end

-- Activate the whole body soul-bearing effect
function MountEquipSystem:ReqMountEquipActiveSoul(assistantId)
    if self.CurMountCellsDic:ContainsKey(assistantId) then
        local _cfg = DataConfig.DataHorseEquipSoulboundClass[self.CurMountCellsDic[assistantId].TotalSoulActiveID + 1]
        if _cfg then
            if self.CurMountCellsDic[assistantId].TotalSoulLv >= _cfg.SuitLevel then
                local _msg = ReqMsg.MSG_Horse.ReqMountEquipActiveSoul:New()
                _msg.assistantId = assistantId
                _msg.soulActiveId = _cfg.Id
                _msg:Send()
            else
                GameCenter.MsgPromptSystem:ShowPrompt(UIUtils.CSFormat(DataConfig.DataMessageString.Get("C_HOURSEEQUIP_SOULLVLESS"), _cfg.SuitLevel, self.CurMountCellsDic[assistantId].TotalSoulLv))
            end
        else
            GameCenter.MsgPromptSystem:ShowPrompt(DataConfig.DataMessageString.Get("C_PETEQUIP_MAXLV"))
        end
    end
end

-- Return to the activated chakra list and battle chakra when online
function MountEquipSystem:ResHorseEquipList(msg)
    -- Current level
    self.CurLevel = msg.curLevel
    -- Current experience
    self.CurExp = msg.curExp
    -- Model Id for playing (if it is 0 means that there is no play)
    self.BattleId = msg.battleId
    -- Is the function enabled
	self.FuncOpen = msg.funcOpen
    -- Helping position list
    if msg.assistantList then
        self:ResMountCellsList(msg.assistantList)
    end
    -- Checked to automatically decompose to true
    self.IsAutoSplit = msg.autoSet
    -- The quality of automatic decomposition
    self.Autocolor = msg.autocolor
    -- Automatically decomposed star rating
    self.AutoStar = msg.autoStar
end
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Send mount list
function MountEquipSystem:ResMountCellsList(list)
    self.CurMountCellsDic:Clear()
    for i = 1, #list do
        local _tmp = {}
        -- Chakra id unlock table 1-4
        _tmp.CellID = list[i].assistantId
        -- This is useless
        if list[i].petId then
            _tmp.MountID = list[i].petId
        else
            _tmp.MountID = 0
        end
        -- Activated configuration table id in the whole body reinforcement target
        if list[i].strengthActiveId then
            _tmp.TotalStrActiveID = list[i].strengthActiveId
        else
            _tmp.TotalStrActiveID = 0
        end
        -- The configuration table id activated in the whole body soul-bearing target
        if list[i].soulActiveId then
            _tmp.TotalSoulActiveID = list[i].soulActiveId
        else
            _tmp.TotalSoulActiveID = 0
        end
        _tmp.Score = 0
        _tmp.EquipCellDic = Dictionary:New()
        _tmp.TotalStrLv = 0
        _tmp.TotalSoulLv = 0
        -- 4 equipment grid information
        if list[i].cellList then
            for j = 1, #list[i].cellList do
                local _equipTmp = {}
                -- Part ID
                _equipTmp.CellID = list[i].cellList[j].id
                -- Grid strengthening level
                if list[i].cellList[j].strengthLv then
                    _equipTmp.StrengthLv = list[i].cellList[j].strengthLv
                else
                    _equipTmp.StrengthLv = 0
                end
                _tmp.TotalStrLv = _tmp.TotalStrLv + _equipTmp.StrengthLv
                -- Soul-attached level of grid
                if list[i].cellList[j].soulLv then
                    _equipTmp.SoulLv = list[i].cellList[j].soulLv
                else
                    _equipTmp.SoulLv = 0
                end
                _tmp.TotalSoulLv = _tmp.TotalSoulLv + _equipTmp.SoulLv
                -- Equipment items
                if list[i].cellList[j].equip then
                    _equipTmp.EquipInfo = LuaItemBase.CreateItemBaseByMsg(list[i].cellList[j].equip)
                    if _equipTmp.EquipInfo then
                        _tmp.Score = _tmp.Score + _equipTmp.EquipInfo.ItemInfo.Score
                    end
                else
                    _equipTmp.EquipInfo = nil
                end
                _tmp.EquipCellDic:Add(_equipTmp.CellID, _equipTmp)
            end
        end
        -- Whether to activate
        if list[i].open then
            _tmp.IsOpen = true
            _tmp.Index = _tmp.CellID
        else
            _tmp.IsOpen = false
            _tmp.Index = _tmp.CellID + 1000
        end
        local _keys = _tmp.EquipCellDic:GetKeys()
        local _cfg = DataConfig.DataHorseEquipUnlock[_tmp.CellID * 10000 + _keys[1]]
        if _cfg then
            if _cfg.SiteUnlock and _cfg.SiteUnlock ~= "" then
                _tmp.Condition = _cfg.SiteUnlock
            end
            if _cfg.SiteUnlockItem and _cfg.SiteUnlockItem ~= "" then
                _tmp.ItemCondition = _cfg.SiteUnlockItem
            end
        end
        _tmp.EquipCellDic:SortKey(
            function(a, b)
                return a < b
            end
        )
        self.CurMountCellsDic:Add(list[i].assistantId, _tmp)
    end
    self.CurMountCellsDic:SortValue(
        function(a, b)
            return a.Index < b.Index
        end
    )
    self.IsSetRed = true
    self:UpdateScore()
    self:SetEquipStrengthRed()
    self:SetEquipSoulRed()
end

-- Update total ratings
function MountEquipSystem:UpdateScore()
    -- Here you need to traverse the accumulated scores of left and right equipment
    self.EquipScores = 0
    self.CurMountCellsDic:Foreach(
        function(_key, _val)
            local _dict = _val.EquipCellDic
            _dict:Foreach(
                function(_cellId, _equip)
                    if _equip.EquipInfo ~= nil then
                        self.EquipScores = self.EquipScores + _equip.EquipInfo.ItemInfo.Score
                    end
                end
            )
        end
    )
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MOUNTEQUIP_SCORE_UPDATE)
    self:SetMountFightRed()
end

-- Replace the assisted mount and return
function MountEquipSystem:ResMountChangeAssi(msg)
    if self.CurMountCellsDic[msg.assistantId] then
        self.CurMountCellsDic[msg.assistantId].MountID = msg.petModelId
    end
    self.IsSetRed = true
    self:UpdateScore()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MOUNTEQUIP_MOUNTLISTUPDATE)
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_REFRESH_ASSIST_PET)
end

-- Wearing equipment back
function MountEquipSystem:ResMountEquipWear(msg)
    if self.CurMountCellsDic[msg.assistantId] then
        local _list = self.CurMountCellsDic[msg.assistantId].EquipCellDic
        local _score = 0
        _list:ForeachCanBreak(function(k, v)
            if k == msg.cellId then
                v.EquipInfo = LuaItemBase.CreateItemBase(msg.equipModelId)
                if v.EquipInfo then
                    v.EquipInfo.DBID = msg.equipId
                    _score = _score + v.EquipInfo.ItemInfo.Score
                end
            else
                if v.EquipInfo then
                    _score = _score + v.EquipInfo.ItemInfo.Score
                end
            end
        end)
        self.CurMountCellsDic[msg.assistantId].Score = _score
    end
    self.IsSetRed = true
    self:UpdateScore()
    self:SetEquipStrengthRed()
    self:SetEquipSoulRed()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MOUNTEQUIP_WEARUPDATE, msg.assistantId)
end

-- Remove the equipment and return
function MountEquipSystem:ResMountEquipUnWear(msg)
    if self.CurMountCellsDic[msg.assistantId] then
        local _score = 0
        local _list = self.CurMountCellsDic[msg.assistantId].EquipCellDic
        _list:ForeachCanBreak(function(k, v)
            if k == msg.cellId then
                v.EquipInfo = nil
            end
            if v.EquipInfo then
                _score = _score + v.EquipInfo.ItemInfo.Score
            end
        end)
        self.CurMountCellsDic[msg.assistantId].Score = _score
    end
    self.IsSetRed = true
    self:UpdateScore()
    self:SetEquipStrengthRed()
    self:SetEquipSoulRed()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MOUNTEQUIP_WEARUPDATE, msg.assistantId)
end

-- Reinforced equipment return
function MountEquipSystem:ResMountEquipStrength(msg)
    if self.CurMountCellsDic[msg.assistantId] then
        local _lv = 0
        self.CurMountCellsDic[msg.assistantId].EquipCellDic:ForeachCanBreak(function(k, v)
            if k == msg.cellId then
                v.StrengthLv = msg.strengthLv
            end
            _lv = _lv + v.StrengthLv
        end)
        self.CurMountCellsDic[msg.assistantId].TotalStrLv = _lv
    end
    self.IsSetRed = true
    self:SetEquipStrengthRed()
    self:UpdateScore()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MOUNTEQUIP_STRENGTHRESULT, true)
end

-- Soul-attached equipment returns
function MountEquipSystem:ResMountEquipSoul(msg)
    if self.CurMountCellsDic[msg.assistantId] then
        local _lv = 0
        self.CurMountCellsDic[msg.assistantId].EquipCellDic:ForeachCanBreak(function(k, v)
            if k == msg.cellId then
                v.SoulLv = msg.soulLv
            end
            _lv = _lv + v.SoulLv
        end)
        self.CurMountCellsDic[msg.assistantId].TotalSoulLv = _lv
    end
    self:SetEquipSoulRed()
    self:UpdateScore()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MOUNTEQUIP_SoulRESULT, true)
end

-- Activate the whole body strengthening effect and return
function MountEquipSystem:ResMountEquipActiveInten(msg)
    if self.CurMountCellsDic[msg.assistantId] then
        self.CurMountCellsDic[msg.assistantId].TotalStrActiveID = msg.strengthActiveId
        GameCenter.RedPointSystem:RemoveFuncCondition(FunctionStartIdCode.MountEquipStrength, msg.assistantId*1000)
        local _cfg = DataConfig.DataHorseEquipIntenClass[msg.strengthActiveId + 1]
        if _cfg then
            if _cfg.SuitLevel <= self.CurMountCellsDic[msg.assistantId].TotalStrLv then
                GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.MountEquipStrength, msg.assistantId*1000, RedPointCustomCondition(true))
            else
                GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.MountEquipStrength, msg.assistantId*1000, RedPointCustomCondition(false))
            end
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MOUNTEQUIP_TOTALSTRENGTHRESULT, true)
end

-- Activate the whole body soul-bearing effect to return
function MountEquipSystem:ResMountEquipActiveSoul(msg)
    if self.CurMountCellsDic[msg.assistantId] then
        self.CurMountCellsDic[msg.assistantId].TotalSoulActiveID = msg.soulActiveId
        GameCenter.RedPointSystem:RemoveFuncCondition(FunctionStartIdCode.MountEquipFuhun, msg.assistantId*1000)
        local _cfg = DataConfig.DataHorseEquipSoulboundClass[msg.soulActiveId + 1]
        if _cfg then
            if _cfg.SuitLevel <= self.CurMountCellsDic[msg.assistantId].TotalSoulLv then
                GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.MountEquipFuhun, msg.assistantId*1000, RedPointCustomCondition(true))
            else
                GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.MountEquipFuhun, msg.assistantId*1000, RedPointCustomCondition(false))
            end
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MOUNTEQUIP_TotalSoulRESULT, true)
end

-- Equipment synthesis return
function MountEquipSystem:ResMountEquipSynthesis(msg)
    if self.CurMountCellsDic[msg.assistantId] then
        local _list = self.CurMountCellsDic[msg.assistantId].EquipCellDic
        local _score = 0
        _list:ForeachCanBreak(function(k, v)
            if k == msg.cellId and msg.newEquip then
                v.EquipInfo = LuaItemBase.CreateItemBaseByMsg(msg.newEquip)
                if v.EquipInfo then
                    _score = _score + v.EquipInfo.ItemInfo.Score
                    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MOUNTEQUIP_WEARUPDATE, msg.assistantId)
                end
            else
                if v.EquipInfo then
                    _score = _score + v.EquipInfo.ItemInfo.Score
                end
            end
        end)
        self.CurMountCellsDic[msg.assistantId].Score = _score
    end
    self.IsSetRed = true
    self:UpdateScore()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MOUNTEQUIP_SYNTHRESULT, msg.success)
end

-- Automatic equipment decomposition settings save return
function MountEquipSystem:ResMountEquipDecomposeSetting(msg)
    self.IsAutoSplit = msg.set
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATEAUTOSMELTSTATE)
end
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

return MountEquipSystem
