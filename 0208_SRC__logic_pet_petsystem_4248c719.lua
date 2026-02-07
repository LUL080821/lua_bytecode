------------------------------------------------
-- Author:
-- Date: 2019-06-18
-- File: PetSystem.lua
-- Module: PetSystem
-- Description: Pet system code
------------------------------------------------
local FightUtils = require "Logic.Base.FightUtils.FightUtils"
local PetSoulInfo = require "Logic.Pet.PetSoulInfo"
local PetInfo = require "Logic.Pet.PetInfo"
local RedPointCustomCondition = CS.Thousandto.Code.Logic.RedPointCustomCondition
local RedPointItemCondition = CS.Thousandto.Code.Logic.RedPointItemCondition
local RedPointTaskCondition = CS.Thousandto.Code.Logic.RedPointTaskCondition

local PetSystem = {
    -- Pets currently in battle
    CurFightPet = 0,
    -- Current level
    CurLevel = 0,
    -- Current experience
    CurExp = 0,
    -- Current level configuration
    CurLevelCfg = nil,
    -- Attributes of the current level
    CurLevelPros = nil,
    -- Next level attributes
    NextLevelPros = nil,
    -- Currently activated pet data
    CurActivePets = Dictionary:New(),
    -- Current data of the Soul
    CurSoulLevelList = List:New(),

    -- Total Pet Attributes = Level Attributes + All Pet Attributes
    AllProps = nil,
    -- Total pet combat power
    AllFightPower = 0,

    -- List of items used for attribute upgrade
    ProLevelUseItems = nil,
}

-- initialization
function PetSystem:Initialize()
    -- Initialize the Soul List
    self.CurSoulLevelList:Clear()
    DataConfig.DataPetSoul:Foreach(function(k, v)
        self.CurSoulLevelList:Add(PetSoulInfo:New(v))
    end)

    local _gCfg = DataConfig.DataGlobal[GlobalName.Pet_Levelup_Item_Num]
    if _gCfg ~= nil then
        self.ProLevelUseItems = Utils.SplitStrByTableS(_gCfg.Params, {';','_'})
    end
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_ONLINE_ITEMINFO, self.SetPetProDetRed, self)
    GameCenter.RegFixEventHandle(LogicEventDefine.EVENT_PETLV_ITEM_CHANGE, self.SetPetProDetRed, self)
end

-- De-initialization
function PetSystem:UnInitialize()
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_ONLINE_ITEMINFO, self.SetPetProDetRed, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EVENT_PETLV_ITEM_CHANGE, self.SetPetProDetRed, self)
end

-- Calculate total pet attributes
function PetSystem:CalculateAllProps()
    self.CurLevelCfg = DataConfig.DataPetLevel[self.CurLevel]
    self.CurLevelPros = Utils.SplitStrByTableS(self.CurLevelCfg.Attribute, {';','_'})
    self.NextLevelPros = nil
    local _nextCfg = DataConfig.DataPetLevel[self.CurLevel + 1]
    if _nextCfg ~= nil then
        self.NextLevelPros = Utils.SplitStrByTableS(_nextCfg.Attribute, {';','_'})
    end

    self.AllProps = {}
    -- Add level attributes first
    self.AllProps = Utils.MergePropTable(self.AllProps, self.CurLevelPros)
    -- Add all the properties of the pet itself
    for k, v in pairs(self.CurActivePets) do
        self.AllProps = Utils.MergePropTable(self.AllProps, v.CurAllPros)
    end
    -- Add Soul-Reigning Attribute
    for i = 1, #self.CurSoulLevelList do
        self.AllProps = Utils.MergePropTable(self.AllProps, self.CurSoulLevelList[i].CurPros)
    end
    self.AllFightPower = FightUtils.GetPropetryPowerByList(self.AllProps)
end

-- Find Soul Data
function PetSystem:FindSoulIndfo(soulId)
    for i = 1, #self.CurSoulLevelList do
        if self.CurSoulLevelList[i].ID == soulId then
            return self.CurSoulLevelList[i]
        end
    end
end

-- Find pet data
function PetSystem:FindActivePetInfo(petId)
    return self.CurActivePets[petId]
end

-- Detection attribute upgrade red dot
function PetSystem:CheckProLevelRedPoint()
    GameCenter.ItemContianerSystem:ClearItemMsgCondition(FunctionStartIdCode.PetProDet)
    self.NeedItemExp = 0
    if self.NextLevelPros ~= nil then
        -- Only if there is a next level of attributes are needed to display red dots
        if self.ProLevelUseItems ~= nil then
            local _items = {}
            for i = 1, #self.ProLevelUseItems do
                _items[i] = tonumber(self.ProLevelUseItems[i][1])
            end
            self.NeedItemExp = self.CurLevelCfg.Exp - self.CurExp
            GameCenter.ItemContianerSystem:AddItemMsgCondition(LogicEventDefine.EVENT_PETLV_ITEM_CHANGE, _items, FunctionStartIdCode.PetProDet)
        end
    end
    self:SetPetProDetRed()
end

function PetSystem:SetPetProDetRed()
    if self.NeedItemExp and self.NeedItemExp > 0 and self.ProLevelUseItems ~= nil then
        local _exp = 0
        for i = 1, #self.ProLevelUseItems do
            local _itemCount = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(tonumber(self.ProLevelUseItems[i][1]))
            _exp = _exp + _itemCount * tonumber(self.ProLevelUseItems[i][2])
            if _exp >= self.NeedItemExp then
                break
            end
        end
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.PetProDet, _exp >= self.NeedItemExp)
    else
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.PetProDet, false)
    end
end

-- Detection upgrade red dot
function PetSystem:CheckLevelUPRedPoint()
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.PetLevel)
    DataConfig.DataPet:Foreach(function(k, v)
        local _petInfo = self:FindActivePetInfo(k)
        if _petInfo ~= nil then
            -- Already activated
            if _petInfo.CurLevel < v.MaxDegree then
                local _needItemParam = Utils.SplitStr(_petInfo.CurLevelCfg.RankExp, '_')
                GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.PetLevel, k, RedPointItemCondition(tonumber(_needItemParam[1]), tonumber(_needItemParam[2])))
            end
        else
            -- Not activated
            local _ulockParam = Utils.SplitStr(v.Unlock, '_')
            local _type = tonumber(_ulockParam[1])
            local _value = tonumber(_ulockParam[2])
    
            if _type == 0 then  -- Complete the task
                GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.PetLevel, k, RedPointTaskCondition(_value))
            elseif _type == 1 then -- Front full level
                local _frontPet = self:FindActivePetInfo(_value)
                if _frontPet ~= nil and _frontPet.IsFullDegree then
                    GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.PetLevel, k, RedPointCustomCondition(true))
                else
                    GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.PetLevel, k, RedPointCustomCondition(false))
                end
            elseif _type == 2 then -- Consumption props
                GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.PetLevel, k, RedPointItemCondition(_value, 1))
            end
        end
    end)
end

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Request to activate the pet
function PetSystem:ReqActivePet(petId)
    local _msg = ReqMsg.MSG_Pet.ReqPetAction:New()
    _msg.actType = 1
    _msg.modelId = petId
    _msg:Send()
end
-- Request to upgrade your pet
function PetSystem:ReqUpPet(petId)
    local _msg = ReqMsg.MSG_Pet.ReqPetAction:New()
    _msg.actType = 2
    _msg.modelId = petId
    _msg:Send()
end
-- Request a pet to fight
function PetSystem:ReqOutPet(petId)
    local _msg = ReqMsg.MSG_Pet.ReqPetAction:New()
    _msg.actType = 3
    _msg.modelId = petId
    _msg:Send()
end
-- Request for the retrieval of the pet
function PetSystem:ReqRestPet(petId)
    local _msg = ReqMsg.MSG_Pet.ReqPetAction:New()
    _msg.actType = 4
    _msg.modelId = petId
    _msg:Send()
end
-- Request an upgrade
function PetSystem:ReqLevelUP(itemID)
    local _msg = ReqMsg.MSG_Pet.ReqEatEquip:New()
    _msg.itemId = itemID
    _msg:Send()
end
-- Request for Soul
function PetSystem:ReqEatSoul(soulId)
    local _msg = ReqMsg.MSG_Pet.ReqEatSoul:New()
    _msg.soulId = soulId
    _msg:Send()
end
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Send pet list
function PetSystem:ResPetList(msg)
    self.HaveFullPet = false
    self.CurLevel = msg.curLevel
    self.CurExp = msg.curExp
    self.CurFightPet = msg.battlePetId
    self.CurActivePets:Clear()
    if msg.petList ~= nil then
        for i = 1, #msg.petList do
            local _petCfg = DataConfig.DataPet[msg.petList[i].modelId]
            if _petCfg ~= nil then
                local _petInfo = PetInfo:New(_petCfg, msg.petList[i].curStage)
                if _petInfo.IsFullDegree then
                    self.HaveFullPet = true
                end
                self.CurActivePets:Add(_petCfg.Id, _petInfo)
                -- if msg.funcOpen then
                -- --If the function is enabled, the display pet will be obtained
                --     GameCenter.ModelViewSystem:ShowModel(ShowModelType.Pet, _petCfg.Model, _petCfg.UiScale, _petCfg.GetUiHeight, _petCfg.Name)
                -- end
            end
        end
    end

    if msg.soulList ~= nil then
        for i = 1, #msg.soulList do
            local _soulInfo = self:FindSoulIndfo(msg.soulList[i].soulId)
            if _soulInfo ~= nil then
                _soulInfo:SetCurLevel(msg.soulList[i].soulLevel)
            end
        end
    end
    if msg.assistantList then
        GameCenter.PetEquipSystem:ResPetCellsList(msg.assistantList)
    end
    GameCenter.PetEquipSystem.IsAutoSplit = msg.autoSet
    -- Recalculate properties
    self:CalculateAllProps()
    self:CheckProLevelRedPoint()
    self:CheckLevelUPRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_REFRESH_PET_FORM)
end
-- Synchronize individual pet data
function PetSystem:ResSyncPet(msg)
    local _isActive = self.CurActivePets[msg.pet.modelId] ~= nil
    local _petCfg = DataConfig.DataPet[msg.pet.modelId]
    if _petCfg ~= nil then
        local _petInfo = PetInfo:New(_petCfg, msg.pet.curStage)
        if _petInfo.IsFullDegree then
            self.HaveFullPet = true
        end
        self.CurActivePets[_petInfo.ID] = _petInfo
    end
    -- Recalculate properties
    self:CalculateAllProps()
    self:CheckLevelUPRedPoint()
    if msg.fight and GameCenter.NatureSystem.NaturePetData then
        GameCenter.NatureSystem.NaturePetData.super.Fight = msg.fight
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_REFRESH_PET_FORM)
    -- if not _isActive then
    --     GameCenter.ModelViewSystem:ShowModel(ShowModelType.Pet, _petCfg.Model, _petCfg.UiScale, _petCfg.GetUiHeight, _petCfg.Name)
    -- end
end
-- Synchronize the currently playing pets
function PetSystem:ResBattlePet(msg)
    self.CurFightPet = msg.battlePetId
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_REFRESH_PET_FORM)
end
-- Pets eat equipment back
function PetSystem:ResEatEquip(msg)
    self.CurLevel = msg.curLevel
    self.CurExp = msg.curExp
    -- Recalculate properties
    self:CalculateAllProps()
    self:CheckProLevelRedPoint()
    if msg.fight and GameCenter.NatureSystem.NaturePetData then
        GameCenter.NatureSystem.NaturePetData.super.Fight = msg.fight
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_REFRESH_PET_FORM)
end
-- Return to the Soul
function PetSystem:ResEatSoul(msg)
    local _soulInfo = self:FindSoulIndfo(msg.petSoulInfo.soulId)
    if _soulInfo ~= nil then
        _soulInfo:SetCurLevel(msg.petSoulInfo.soulLevel)
    end
    -- Recalculate properties
    self:CalculateAllProps()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_REFRESH_PET_FORM)
end
-- Add pet skills to players
function PetSystem:ResAddPetSkill(msg)
    --GameCenter.PlayerSkillSystem:SetPetSkillID(msg.skillId)
end
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

return PetSystem