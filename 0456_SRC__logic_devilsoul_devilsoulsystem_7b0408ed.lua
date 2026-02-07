------------------------------------------------
-- Author:
-- Date: 2021-04-25
-- File: DevilSoulSystem.lua
-- Module: DevilSoulSystem
-- Description: Demon Soul System Code
------------------------------------------------

local RedPointCustomCondition = CS.Thousandto.Code.Logic.RedPointCustomCondition
local RedPointItemCondition = CS.Thousandto.Code.Logic.RedPointItemCondition
local L_DevilCampData = require "Logic.DevilSoul.DevilCampData"

local DevilSoulSystem = {
    TrainDict = nil,
    --[campID,List<card>]
    CampCardDict = nil,
    DevilSoulDict = nil,
    Qualitys = nil,
    EquipPartsDict = nil,
    -- Case position ID list [campID,List<Part>]
    CampPartsDict = nil,
    QualityList = nil,

    CampRedPointDataIds = nil,
    CardRedPointDataIds = nil,
    -- Detect the number of red dot frames
    CheckRedPointFrameCount = 0,
}

-- initialization
function DevilSoulSystem:Initialize()
    self.DevilSoulDict = Dictionary:New()
    -- Faction Table
    self.CampCardDict = Dictionary:New()
    self.CampPartsDict = Dictionary:New()
    DataConfig.DataCrossDevilCardCamp:Foreach(
        function(key, _campCfg)
            self.CampCardDict[key] = List:New()
            self.CampPartsDict[key] = Utils.SplitNumber(_campCfg.PartsList, "_")
        end)
    DataConfig.DataCrossDevilCardMain:Foreach(
        function(_cardId, _mainCfg)
            local _list = self.CampCardDict[_mainCfg.Camp]
            _list:Add(_mainCfg)
        end
    )
    -- Upgrade table
    self.TrainDict = Dictionary:New()
    DataConfig.DataCrossDevilCardTrain:Foreach(
        function(key, _cfgTrain)
            local _dicKey = _cfgTrain.Card * 10000 + _cfgTrain.Rank * 100 + _cfgTrain.Level
            self.TrainDict[_dicKey] = _cfgTrain
        end
    )
    self.EquipPartsDict = Dictionary:New()
    -- Part ID and name
    local _parts = Utils.SplitStr(DataConfig.DataGlobal[1956].Params, ";")
    for i = 1, #_parts do
        local _part = Utils.SplitStr(_parts[i], "_")
        self.EquipPartsDict:Add(tonumber(_part[1]), _part[2])
    end
    self.Qualitys = Utils.SplitNumber(DataConfig.DataGlobal[1954].Params, '_')
    self.QualityList = {3, 4, 6, 7, 8, 9, 10}

    GameCenter.RegFixEventHandle(LogicLuaEventDefine.EID_EVENT_DEVILEQUIP_BAGCHANGE, self.OnBagChanged, self)
end

-- De-initialization
function DevilSoulSystem:UnInitialize()
    self.TrainDict:Clear()
    self.CampCardDict:Clear()
    self.DevilSoulDict:Clear()
    self.EquipPartsDict:Clear()
    self.CampPartsDict:Clear()
    GameCenter.UnRegFixEventHandle(LogicLuaEventDefine.EID_EVENT_DEVILEQUIP_BAGCHANGE, self.OnBagChanged, self)
end

function DevilSoulSystem:Update(dt)
    if self.CheckRedPointFrameCount > 0 then
        self.CheckRedPointFrameCount = self.CheckRedPointFrameCount - 1
        if self.CheckRedPointFrameCount <= 0 then
            self:CheckRedPoint()
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_DEVILCARD_EQUIP_WEAR)
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_DEVILCARD_FIGHT_POWER_REFESH)
        end
    end
end

function DevilSoulSystem:OnBagChanged(obj, sender)
    self.CheckRedPointFrameCount = 10
end

-- --------------------------------------------------------------------------------------------------------------------------------
-- Return all demon soul information
function DevilSoulSystem:ResDevilCardList(msg)
    -- Demon Souls Camp List
    self.DevilSoulDict:Clear()
    local _campList = msg.camp
    if _campList ~= nil then
        for i = 1, #_campList do
            local _cardCamp = _campList[i]
            local _devilData = L_DevilCampData:New(_cardCamp, self)
            local _campId = _devilData.CampId
            self.DevilSoulDict[_campId] = _devilData
        end
    end
    self:CheckRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_DEVILCARD_DATA_REFESH)
end

-- Wearing equipment back
function DevilSoulSystem:ResDevilEquipWear(msg)
    if self.DevilSoulDict:ContainsKey(msg.campId) then
        local _campData = self.DevilSoulDict[msg.campId]
        local _cardList = _campData.CardList
        for i = 1, #_cardList do
            -- The Demon Soul ID of the Wear
            if _cardList[i].Id == msg.cardId then
                _cardList[i]:EquipWear(msg)
                break
            end
        end
    end
    local _result = {
        itemId = msg.equipId
    }
    GameCenter.NewItemContianerSystem:ResDevilEquipDelete(_result)
    self:CheckRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_DEVILCARD_EQUIP_WEAR)
end

-- Demon soul breakthrough
function DevilSoulSystem:ResDevilCardBreak(msg)
    local _campData = self.DevilSoulDict[msg.campId]
    if _campData == nil then
        return
    end
    local _cardList = _campData.CardList
    for i = 1, #_cardList do
        if _cardList[i].Id == msg.cardId then
            -- Current breakthrough level
            _cardList[i].BreakLv = _cardList[i].BreakLv + 1
            _cardList[i]:RefreshData()
            break
        end
    end
    Utils.ShowPromptByEnum("C_DEVIL_BREAK_SUCCESS")
    self:CheckRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_DEVILCARD_BREAK)
end

-- Return to the Demon Soul Upgrade
function DevilSoulSystem:ResDevilCardUp(msg)
    local _campData = self.DevilSoulDict[msg.campId]
    if _campData == nil then
        return
    end
    local _cardList = _campData.CardList
    for i = 1, #_cardList do
        -- The Demon Soul ID of the Wear
        if _cardList[i].Id == msg.cardId then
            -- Current order
            _cardList[i].Rank = msg.rank
            -- Current series
            _cardList[i].Level = msg.level
            _cardList[i]:RefreshData()
            break
        end
    end
    self:CheckRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_DEVILCARD_LV_UP)
end

-- Equipment synthesis return
function DevilSoulSystem:ResDevilEquipSynthesis(msg)
    if msg.success then
        local data = LuaItemBase.CreateItemBase(msg.newEquip.itemModelId)
        GameCenter.GetNewItemSystem:AddShowItem(ItemChangeReasonName.DevilEquipSynthesisGet, data, data.CfgID, 1)
        Utils.ShowPromptByEnum("ImmSoulcompoundSuc")
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_DEVIL_EQUIP_SYNTHESIS)
    else
        Utils.ShowPromptByEnum("C_MSG_EQUIPSYN_FAILED")
    end
end

-- Combat power synchronization
function DevilSoulSystem:ResDevilCardFightPoint(msg)
    if self.DevilSoulDict:ContainsKey(msg.campId) then
        local _campData = self.DevilSoulDict[msg.campId]
        local _cardList = _campData.CardList
        for i = 1, #_cardList do
            -- The Demon Soul ID of the Wear
            if _cardList[i].Id == msg.cardId then
                -- Current combat power
                _cardList[i].FightPower = msg.fightPoint
                break
            end
        end
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_DEVILCARD_FIGHT_POWER_REFESH)
    end
end

-- Get all the equipment on your body
function DevilSoulSystem:GetAllEquipsByCamp(camp)
    local _equipList = List:New()
    local _bpModel = GameCenter.NewItemContianerSystem:GetBackpackModelByType(LuaContainerType.ITEM_LOCATION_DEVILEQUIP)
    if _bpModel then
        for _, v in pairs(_bpModel.ItemsOfIndex) do
            if v:GetGrade() == camp then
                _equipList:Add(v)
            end
        end
    end
    return _equipList
end

function DevilSoulSystem:GetTrainCfgByCardMainCfg(mainCfg)
    local _rank = 0
    local _level = 0
    local _campData = self.DevilSoulDict[mainCfg.Camp]
    if _campData ~= nil then
        local _cardList = _campData.CardList
        for i = 1, #_cardList do
            if mainCfg.Id == _cardList[i].Id then
                _rank = _cardList[i].Rank
                _level = _cardList[i].Level
                break
            end
        end
    end
    local _dicKey = mainCfg.Id * 10000 + _rank * 100 + _level
    local _nextDicKey = 0
    if _level == 10 then
        _nextDicKey = mainCfg.Id * 10000 + (_rank + 1) * 100 + _level
    else
        _nextDicKey = _dicKey + 1
    end
    return self.TrainDict[_dicKey], self.TrainDict[_nextDicKey]
end

-- Obtain the data of the current equipment list based on the faction ID and card ID
function DevilSoulSystem:GetCardEquipDictByCampID(campId, cardId)
    local _equipDict = nil
    local _devilData = self.DevilSoulDict[campId]
    if _devilData ~= nil then
        local _cardList = _devilData.CardList
        for i = 1, #_cardList do
            if _cardList[i].Id == cardId then
                _equipDict = _cardList[i].EquipPartDict
                break
            end
        end
    end
    return _equipDict
end

function DevilSoulSystem:GetCardData(cardId, campId)
    if campId == nil then
        for k, _campData in pairs(self.DevilSoulDict) do
            local _cardList = _campData.CardList
            for i = 1, #_cardList do
                if _cardList[i].Id == cardId then
                    return _cardList[i]
                end
            end
        end
    else
        local _campData = self.DevilSoulDict[campId]
        if _campData ~= nil then
            local _cardList = _campData.CardList
            for i = 1, #_cardList do
                if _cardList[i].Id == cardId then
                    return _cardList[i]
                end
            end
        end
    end
    return nil
end

function DevilSoulSystem:CheckRedPoint()
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.DevilSoulMain);
    local bpModel = GameCenter.NewItemContianerSystem:GetBackpackModelByType(LuaContainerType.ITEM_LOCATION_DEVILEQUIP)
    if bpModel == nil then
        return
    end
    if self.CampRedPointDataIds == nil then
        self.CampRedPointDataIds = Dictionary:New()
    else
        self.CampRedPointDataIds:Clear()
    end
    if self.CardRedPointDataIds == nil then
        self.CardRedPointDataIds = Dictionary:New()
    else
        self.CardRedPointDataIds:Clear()
    end
    for k, v in pairs(self.DevilSoulDict) do
        -- Traverse each demon soul
        local _dataIds = List:New()
        local _cardCount = #v.CardList
        local _partList = self.CampPartsDict[k]
        for i = 1, _cardCount do
            local _cardDataIds = List:New()
            local _card = v.CardList[i]
            if _card.CostItems ~= nil then
                -- Add item conditions
                local _dataId = _card.Id * 100 + 1
                GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.DevilSoulMain, _dataId,  RedPointItemCondition(_card.CostItems[1], _card.CostItems[2]))
                _dataIds:Add(_dataId)
                _cardDataIds:Add(_dataId)
            end
            -- Only after activation can the breakthrough and wear red points be calculated
            if _card.Level > 0 then
                -- Calculation breaks through the red point
                if _card.BreakCostIds ~= nil then
                    local _canTuPo = true
                    for j = 1, #_card.BreakCostIds do
                        if bpModel:GetCountByCfgId(_card.BreakCostIds[j][1]) < _card.BreakCostIds[j][2] then
                            _canTuPo = false
                        end
                    end
                    if _canTuPo then
                        local _dataId = _card.Id * 100 + 2
                        GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.DevilSoulMain, _dataId,  RedPointCustomCondition(true))
                        _dataIds:Add(_dataId)
                        _cardDataIds:Add(_dataId)
                    end
                end
                -- Calculate wearable red dots
                for ei = 1, #_partList do
                    local _equip = _card.EquipPartDict[_partList[ei]]
                    local _quality = -1
                    if _equip ~= nil and _equip.ItemInfo ~= nil and _equip.ItemInfo.EquipCfg ~= nil then
                        _quality = _equip.ItemInfo.EquipCfg.Quality
                    end
                    local _canDress = false
                    for ev, ev in pairs(bpModel.ItemsOfIndex) do
                        if ev:GetGrade() == k and ev:GetPart() == _equip.Part and ev:GetQuality() > _quality then
                            _canDress = true
                            break
                        end
                    end
                    if _canDress then
                        local _dataId = _card.Id * 1000 + _equip.Part
                        GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.DevilSoulMain, _dataId,  RedPointCustomCondition(true))
                        _dataIds:Add(_dataId)
                        _cardDataIds:Add(_dataId)
                    end
                end
            end
            self.CardRedPointDataIds[_card.Id] = _cardDataIds
        end
        self.CampRedPointDataIds[k] = _dataIds
    end
end

function DevilSoulSystem:GetCampRedPoint(camp)
    local _dataIdList = self.CampRedPointDataIds[camp]
    if _dataIdList == nil then
        return false
    end
    for i = 1, #_dataIdList do
        if GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.DevilSoulMain, _dataIdList[i]) then
            return true
        end
    end
    return false
end

function DevilSoulSystem:GetCardRedPoint(cardId)
    local _dataIdList = self.CardRedPointDataIds[cardId]
    if _dataIdList == nil then
        return false
    end
    for i = 1, #_dataIdList do
        if GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.DevilSoulMain, _dataIdList[i]) then
            return true
        end
    end
    return false
end

return DevilSoulSystem
