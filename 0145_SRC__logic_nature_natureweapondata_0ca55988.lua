-- Author: 
-- Date: 2019-04-28
-- File: NatureWeaponData.lua
-- Module: NatureWeaponData
-- Description: The artifact data system subclass inherits NatureBaseData
------------------------------------------------
local NatureBase = require "Logic.Nature.NatureBaseData"
local SkillSetDate = require "Logic.Nature.NatureSkillSetData"
local ModelData= require "Logic.Nature.NatureBaseModelData"
local FashionData = require "Logic.Nature.NatureFashionData"
local BaseItemData = require "Logic.Nature.NatureBaseItemData"
local RedPointCustomCondition = CS.Thousandto.Code.Logic.RedPointCustomCondition

local NatureWeaponData = {
    Cfg = nil , -- Array configuration table data
    IsMax = 0, -- Maximum level of formation
    super = nil, -- Parent class object
}

function NatureWeaponData:New()
    local _obj = NatureBase:New(NatureEnum.Weapon)
    local _M = Utils.DeepCopy(self)
    _M.super = _obj
    return _M
end

-- Analyze the breakthrough props
function NatureWeaponData:AnalysisBreakItem(str)
    self.BreakItem:Clear()
    if str then
        local _cs = {';','_'}
        local _attr = Utils.SplitStrByTableS(str,_cs)
        for i=1,#_attr do        
            local _data = BaseItemData:New(_attr[i][1],_attr[i][2])
            self.BreakItem:Add(_data)
        end
    end
end

-- Initialization skills
function NatureWeaponData:Initialize()
    DataConfig.DataNatureWeapon:Foreach(function(k, v)
        if v.Skill ~= "" then
            local _cs = {'_'}
            local _skill = Utils.SplitStrByTable(v.Skill,_cs)
            local skilllevel = tonumber(_skill[2])
            if _skill and #_skill >= 2 and skilllevel == 1 then
                local _data = SkillSetDate:New(v)
                self.super.SkillList:Add(_data)
            elseif _skill and #_skill >= 2  then
                self.super.AllSkillList:Add(v)
            end
        end
        if v.ModelID ~= 0 and v.ModelID ~= "" then
            local _data = ModelData:New(v,self.super.NatureType)
            self.super.ModelList:Add(_data)
        end
        if self.IsMax < v.Id then
            self.IsMax = v.Id
        end
    end)
    self.super.AllSkillList:Sort(
        function(a,b)
            return tonumber(a.Id) < tonumber(b.Id)
        end
    )
    self.super.SkillList:Sort(
        function(a,b)
            if a.SkillInfo and b.SkillInfo then
                return tonumber(a.SkillInfo.Id) < tonumber(b.SkillInfo.Id)
            end
            return true
        end
    )
    self.super.ModelList:Sort(
        function(a,b)
            return tonumber(a.Stage) < tonumber(b.Stage)
        end
    )
    -- Initialize the transformed data
    DataConfig.DataHuaxingWeapon:Foreach(function(k, v)
        if v.IsIgnore == 1 and v.IfFashion == 1 then
            local _data = FashionData:New(v)
            self.super.FishionList:Add(_data)
        end
    end)
    self.super.FishionList:Sort(
        function(a,b)
            return tonumber(a.ModelId) < tonumber(b.ModelId)
        end
    )
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_ONLINE_ITEMINFO, self.ItemsChange, self)
    GameCenter.RegFixEventHandle(LogicEventDefine.EVENT_WEAPONLV_ITEM_CHANGE, self.ItemsChange, self)
end

-- De-initialization
function NatureWeaponData:UnInitialize()
    self.Cfg = nil
    self.super = nil
    self.IsMax = 0
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_ONLINE_ITEMINFO, self.ItemsChange, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EVENT_WEAPONLV_ITEM_CHANGE, self.ItemsChange, self)
end
function NatureWeaponData:ItemsChange()
    if self.super then
        self.super:UpdateLvRed(FunctionStartIdCode.NatureWeaponLevel)
    end
end
-- Initialize server data
function NatureWeaponData:InitWingInfo(msg)
    if msg and msg.natureInfo then
        self.Cfg = DataConfig.DataNatureWeapon[msg.natureInfo.curLevel]
        self.super:UpDateSkill(msg.natureInfo.haveActiveSkill) -- Set skills
        self.super:UpDateModel(msg.natureInfo.haveActiveModel) -- Set up the model
        self.super:UpDataFashionInfos(msg.natureInfo.outlineInfo) -- Set the shape
        if self.Cfg then
            self.super:AnalysisAttr(self.Cfg.Attribute)
            self.super:AnalysisItem(self.Cfg.UpItem)
            self.super:Parase(msg.natureType,msg.natureInfo)
            local _num = self.Cfg.Progress - self.super.CurExp
            self.super:UpDateLevelHit(FunctionStartIdCode.NatureWeaponLevel, self.IsMax, _num, LogicEventDefine.EVENT_WEAPONLV_ITEM_CHANGE)
        end
        self.super:UpDateDrugHit(FunctionStartIdCode.NatureWeaponDrag)
        self.super:UpDateFashionHit(FunctionStartIdCode.NatureWeaponFashion)
        if msg.natureInfo.modelId > 0 then
            self:UpDateModelId(msg.natureInfo.modelId)
        end
    end
end

-- Update skills and upgrade
function NatureWeaponData:UpDateUpLevel(msg)
    if msg.activeSkill then
        self.super:UpDateSkill(msg.activeSkill)
    end
    self.super.Level = msg.level
    self.Cfg = DataConfig.DataNatureWing[msg.level]
    if self.Cfg then
        self.super:AnalysisAttr(self.Cfg.Attribute)
    end
    if msg.activeModel then
        self.super:UpDateModel(msg.activeModel)
    end
    self.super.CurExp = msg.curexp
    self.super.Fight = msg.fight
    self.super:UpDateLevelHit(FunctionStartIdCode.NatureWeaponLevel,self.IsMax, self.Cfg.Progress - msg.curexp,  LogicEventDefine.EVENT_WEAPONLV_ITEM_CHANGE)
end

-- Update the information on eating fruits
function NatureWeaponData:UpDateGrugInfo(msg)
    self.super.Fight = msg.fight
    self.super:UpDateDrug(msg.druginfo)
    self.super:UpDateDrugHit(FunctionStartIdCode.NatureWeaponDrag)
end

-- Update the Setup Model ID
function NatureWeaponData:UpDateModelId(model)
    self.super.CurModel = model
end

-- Update the transformation and upgrading results
function NatureWeaponData:UpDateFashionInfo(msg)
    local _info = DataConfig.DataHuaxingWeapon[msg.id]
    self.super:UpDataFashion(msg,_info)
    self.super:UpDateFashionHit(FunctionStartIdCode.NatureWeaponFashion)
end

-- Function function! ! ! ! ! ! ! ! ! ! ! ! ! ! !

-- Is it full level?
function NatureWeaponData:IsMaxLevel()
    return self.IsMax <= self.super.Level
end

-- Get the model camera size
function NatureWeaponData:Get3DUICamerSize(modelid)
    local _info = DataConfig.DataHuaxingWeapon[modelid]
    if _info then
        return _info.CameraSize
    end
    _info = DataConfig.DataNatureWeapon[modelid]
    if _info then
        return _info.CameraSize
    end
    return self.super:GetCameraSize(modelid)
end

function NatureWeaponData:GetModelYPosition(modelid)
    local _info = DataConfig.DataHuaxingWeapon[modelid]
    if _info and _info.ModelYPos then
        return _info.ModelYPos
    end
    return 0
end

function NatureWeaponData:GetModelXPosition(modelid)
    local _info = DataConfig.DataHuaxingWeapon[modelid]
    if _info and _info.ModelXPos then
        return _info.ModelXPos
    end
    return 0
end

-- Get the rotation parameters
function NatureWeaponData:GetModelRotation(modelid)
    local _info = DataConfig.DataHuaxingWeapon[modelid]
    if _info and _info.CameraRotation then
        local _attr = Utils.SplitNumber(_info.CameraRotation, '_')
        return _attr[1], _attr[2], _attr[3]
    end
    return 0, 0, 0
end

-- Get the rotation parameters
function NatureWeaponData:GetShowModelPosition(modelid)
    local _info = DataConfig.DataHuaxingWeapon[modelid]
    local x = 0
    local y = 0
    if _info and _info.ShowModelXPos then
        x = _info.ShowModelXPos
    end
    y = _info.ShowModelYPos
    return x, y, 0
end

return NatureWeaponData

