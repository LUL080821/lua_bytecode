-- Author: 
-- Date: 2019-04-18
-- File: NatureWingsData.lua
-- Module: NatureWingsData
-- Description: The Wing Data System subclass inherits NatureBaseData
------------------------------------------------
local NatureBase = require "Logic.Nature.NatureBaseData"
local SkillSetDate = require "Logic.Nature.NatureSkillSetData"
local ModelData= require "Logic.Nature.NatureBaseModelData"
local FashionData = require "Logic.Nature.NatureFashionData"

local NatureWingsData = {
    Cfg = nil , -- Wing configuration table data
    IsMax = 0, -- Maximum wing level
    super = nil, -- Parent class object
}

function NatureWingsData:New()
    local _obj = NatureBase:New(NatureEnum.Wing)
    local _M = Utils.DeepCopy(self)
    _M.super = _obj
    return _M
end

-- Initialization skills
function NatureWingsData:Initialize()
    DataConfig.DataNatureWing:Foreach(function(k, v)
        if v.Skill and v.Skill ~= "" then
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
        if v.ModelID ~= 0 then
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
    DataConfig.DataHuaxingWing:Foreach(function(k, v)
        if v.IfFashion == 1 and v.IsIgnore == 1  then
            local _data = FashionData:New(v)
            self.super.FishionList:Add(_data)
        end
    end)
    self.super.FishionList:Sort(
        function(a,b)
            return tonumber(a.SortNum) < tonumber(b.SortNum)
        end
    )
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_ONLINE_ITEMINFO, self.ItemsChange, self)
    GameCenter.RegFixEventHandle(LogicEventDefine.EVENT_WINGLV_ITEM_CHANGE, self.ItemsChange, self)
end

-- De-initialization
function NatureWingsData:UnInitialize()
    self.Cfg = nil
    self.super = nil
    self.IsMax = 0
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_ONLINE_ITEMINFO, self.ItemsChange, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EVENT_WINGLV_ITEM_CHANGE, self.ItemsChange, self)
end
function NatureWingsData:ItemsChange()
    if self.super then
        self.super:UpdateLvRed(FunctionStartIdCode.NatureWingLevel)
    end
end
-- Initialize server data
function NatureWingsData:InitWingInfo(msg)
    if msg and msg.natureInfo then
        self.Cfg = DataConfig.DataNatureWing[msg.natureInfo.curLevel]
        self.super:UpDateSkill(msg.natureInfo.haveActiveSkill) -- Set skills
        self.super:UpDateModel(msg.natureInfo.haveActiveModel) -- Set up the model
        self.super:UpDataFashionInfos(msg.natureInfo.outlineInfo) -- Set the shape
        if self.Cfg then
            self.super:AnalysisAttr(self.Cfg.Attribute)
            self.super:AnalysisItem(self.Cfg.UpItem)
            self.super:Parase(msg.natureType,msg.natureInfo)
            local _num = self.Cfg.Progress - self.super.CurExp
            self.super:UpDateLevelHit(FunctionStartIdCode.NatureWingLevel, self.IsMax, _num, LogicEventDefine.EVENT_WINGLV_ITEM_CHANGE)
        end
        self.super:UpDateDrugHit(FunctionStartIdCode.NatureWingDrug)
        self.super:UpDateFashionHit(FunctionStartIdCode.NatureWingFashion)
        if msg.natureInfo.modelId > 0 then
            self:UpDateModelId(msg.natureInfo.modelId)
        end
    end
end

-- Update skills and upgrade
function NatureWingsData:UpDateUpLevel(msg)
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
    local _num = self.Cfg.Progress - self.super.CurExp
    self.super:UpDateLevelHit(FunctionStartIdCode.NatureWingLevel, self.IsMax, _num, LogicEventDefine.EVENT_WINGLV_ITEM_CHANGE)
end

-- Update the information on eating fruits
function NatureWingsData:UpDateGrugInfo(msg)
    self.super.Fight = msg.fight
    self.super:UpDateDrug(msg.druginfo)
    self.super:UpDateDrugHit(FunctionStartIdCode.NatureWingDrug)
end

-- Update the Setup Model ID
function NatureWingsData:UpDateModelId(model)
    self.super.CurModel = model
end

-- Update the transformation and upgrading results
function NatureWingsData:UpDateFashionInfo(msg)
    local _config = DataConfig.DataHuaxingWing[msg.id]
    self.super:UpDataFashion(msg,_config)
    self.super:UpDateFashionHit(FunctionStartIdCode.NatureWingFashion)
end

-- Function function! ! ! ! ! ! ! ! ! ! ! ! ! ! !

-- Is the wings full?
function NatureWingsData:IsMaxLevel()
    return self.IsMax <= self.super.Level
end

-- Get the model camera size
function NatureWingsData:Get3DUICamerSize(modelid)
    local _info = DataConfig.DataHuaxingWing[modelid]
    if _info then
        return _info.CameraSize
    end
    return self.super:GetCameraSize(modelid)
end

function NatureWingsData:GetModelYPosition(modelid)
    local _info = DataConfig.DataHuaxingWing[modelid]
    if _info and _info.ModelYPos then
        return _info.ModelYPos / self:Get3DUICamerSize(modelid)
    end
    return 0
end

return NatureWingsData

