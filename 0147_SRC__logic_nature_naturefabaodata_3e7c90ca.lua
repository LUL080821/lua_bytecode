-- Author:
-- Date: 2019-09-05
-- File: NatureFabaoData.lua
-- Module: NatureFabaoData
-- Description: Magic weapon data system subclass inherits NatureBaseData
------------------------------------------------
local NatureBase = require "Logic.Nature.NatureBaseData"
local SkillSetDate = require "Logic.Nature.NatureSkillSetData"
local ModelData= require "Logic.Nature.NatureBaseModelData"
local FashionData = require "Logic.Nature.NatureFashionData"
local BaseItemData = require "Logic.Nature.NatureBaseItemData"
local RedPointCustomCondition = CS.Thousandto.Code.Logic.RedPointCustomCondition

local NatureFabaoData = {
    Cfg = nil , -- Array configuration table data
    IsMax = 0, -- Maximum level of formation
    super = nil, -- Parent class object
    BreakItem = List:New() -- Breakthrough props
}

function NatureFabaoData:New()
    local _obj = NatureBase:New(NatureEnum.FaBao)
    local _M = Utils.DeepCopy(self)
    _M.super = _obj
    return _M
end

-- Initialization skills
function NatureFabaoData:Initialize()
    -- Initialize the transformed data
    DataConfig.DataHuaxingfabao:Foreach(function(k, v)
        if v.IfFashion == 1 and v.IsIgnore == 1 then
            local _data = FashionData:New(v)
            if v.Type ~= 1 then
                self.super.FishionList:Add(_data)
            end
        end
    end)
    self.super.FishionList:Sort(
        function(a,b)
            return tonumber(a.SortNum) < tonumber(b.SortNum)
        end
    )
end

-- De-initialization
function NatureFabaoData:UnInitialize()
    self.Cfg = nil
    self.super = nil
    self.IsMax = 0
end

-- Initialize server data
function NatureFabaoData:InitWingInfo(msg)
    if msg and msg.natureInfo then
        self.Cfg = DataConfig.DataHuaxingfabao[msg.natureInfo.curLevel]
        self.super:UpDateModel(msg.natureInfo.haveActiveModel) -- Set up the model
        self.super:UpDataFashionInfos(msg.natureInfo.outlineInfo) -- Set the shape
        self.super:Parase(msg.natureType,msg.natureInfo)
        self.super:UpDateFashionHit(FunctionStartIdCode.FaBaoHuaxing)
        self.super:UpDateDrugHit(FunctionStartIdCode.FaBaoDrug)
    end
end

-- Update the Setup Model ID
function NatureFabaoData:UpDateModelId(model)
    self.super.CurModel = model
end

-- Update the transformation and upgrading results
function NatureFabaoData:UpDateFashionInfo(msg)
    local _info = DataConfig.DataHuaxingfabao[msg.id]
    self.super:UpDataFashion(msg,_info)
    self.super:UpDateFashionHit(FunctionStartIdCode.FaBaoHuaxing)
end

function NatureFabaoData:GetDamage(modelID)
    local _damage = 0
    if self.super.FishionList then -- Transformation
        self.super.FishionList:Find(
            function(code)
                if code.IsActive then
                    local _numArr = Utils.SplitNumber(code.Cfg.Fabaohit, "_")
                    if not modelID then
                        if #_numArr >= 2 then
                            _damage = _damage + _numArr[1] + _numArr[2] * code.Level
                        end
                    else
                        if modelID > 0 and code.ModelId == modelID then
                            _damage = _numArr[1] + _numArr[2] * code.Level
                            return true
                        end
                    end
                end
            end
        )
    end
    return _damage
end

-- Function function! ! ! ! ! ! ! ! ! ! ! ! ! ! !

-- Is it full level?
function NatureFabaoData:IsMaxLevel()
    return self.IsMax <= self.super.Level
end

-- Get the model camera size
function NatureFabaoData:Get3DUICamerSize(modelid)
    local _info = DataConfig.DataHuaxingfabao[modelid]
    if _info then
        return _info.CameraSize
    end
    return 1
end

function NatureFabaoData:GetModelYPosition(modelid)
    local _info = DataConfig.DataHuaxingfabao[modelid]
    if _info and _info.ModelYPos then
        return _info.ModelYPos / self:Get3DUICamerSize(modelid)
    end
    return 0
end

function NatureFabaoData:GetShowModelYPosition(modelid)
    local _info = DataConfig.DataHuaxingfabao[modelid]
    if _info and _info.ShowModelYPos then
        return _info.ShowModelYPos / self:Get3DUICamerSize(modelid)
    end
    return 0
end

-- Update the attribute data from the server
function NatureFabaoData:UpDateMsgWeaponInfo(weaponsInfo)
    if weaponsInfo then
        for i=1,#weaponsInfo do
            local _info = self.super.AttrList:Find(
                function(code)
                    return code.AttrID == weaponsInfo[i].id
                end
            )
            if _info then
                _info.Attr = weaponsInfo[i].value
            end
        end
    end
end

-- Can you break through the attribute value?
function NatureFabaoData:GetAttrIsBreak()
    if self.super.AttrList then
        for i=1,#self.super.AttrList do
            if self.super.AttrList[i].Attr <  self.super.AttrList[i].AddAttr then
                return false
            end
        end
        return true
    end
    return false
end

-- Update the information on eating fruits
function NatureFabaoData:UpDateGrugInfo(msg)
    self.super.Fight = msg.fight
    self.super:UpDateDrug(msg.druginfo)
    self.super:UpDateDrugHit(FunctionStartIdCode.FaBaoDrug)
end

return NatureFabaoData

