-- Author: 
-- Date: 2019-04-18
-- File: NatureMountData.lua
-- Module: NatureMountData
-- Description: Mount data system subclass inherits NatureBaseData
------------------------------------------------
local NatureBase = require "Logic.Nature.NatureBaseData"
local SkillSetDate = require "Logic.Nature.NatureSkillSetData"
local ModelData= require "Logic.Nature.NatureBaseModelData"
local FashionData = require "Logic.Nature.NatureFashionData"
local BaseAttrData = require "Logic.Nature.NatureBaseAttrData"
local BaseItemData = require "Logic.Nature.NatureBaseItemData"
local RedPointCustomCondition = CS.Thousandto.Code.Logic.RedPointCustomCondition
local LocalPlayerRoot = CS.Thousandto.Code.Logic.LocalPlayerRoot

local NatureMountData = {
    Cfg = nil , -- Mount configuration table data
    IsMax = 0, -- Upgrade maximum level
    super = nil, -- Parent class object
    BaseCfg = nil, -- Basic attribute configuration table
    BaseExp = 0, -- Basic attribute experience value, progress bar
    BaseIsMax = 0, -- The maximum level of basic attributes
    BaseAttrList = List:New(), -- List of properties, store NatureBaseAttrData
    BaseStarDir = Dictionary:New(),-- The maximum number of stars corresponding to the order
    BaseItemList = List:New(), -- Props that can be eaten
}

function NatureMountData:New()
    local _obj = NatureBase:New(NatureEnum.Mount)
    local _M = Utils.DeepCopy(self)
    _M.super = _obj
    return _M
end

-- Initialization skills
function NatureMountData:Initialize()
    DataConfig.DataNatureHorse:Foreach(function(k, v)
        if v.Skill ~= "" then
            local _cs = {'_'}
            local _skill = Utils.SplitStrByTable(v.Skill,_cs)
            local skilllevel = tonumber(_skill[2])
            if _skill and #_skill >= 2 and skilllevel == 1 then
                local _data = SkillSetDate:New(v)
                _data.NeedLevel = v.Steps
                self.super.SkillList:Add(_data)
            elseif _skill and #_skill >= 2  then
                self.super.AllSkillList:Add(v)
            end
        end
        if v.ModelID ~= 0 then
            local _data = ModelData:New(v,self.super.NatureType)
            self.super.ModelList:Add(_data)
        end
        if self.BaseStarDir:ContainsKey(v.Steps) then
            if self.BaseStarDir[v.Steps] < v.Star then
                self.BaseStarDir[v.Steps] = v.Star
            end
        else
            self.BaseStarDir:Add(v.Steps,v.Star)
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
    DataConfig.DataHuaxingHorse:Foreach(function(k, v)
        if v.IfFashion == 1 and v.IsIgnore == 1 then
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
    GameCenter.RegFixEventHandle(LogicEventDefine.EVENT_MOUNTLV_ITEM_CHANGE, self.ItemsChange, self)
end

-- De-initialization
function NatureMountData:UnInitialize()
    self.Cfg = nil
    self.super = nil
    self.IsMax = 0
    self.BaseCfg = nil
    self.BaseExp = 0
    self.BaseIsMax = 0
    self.BaseAttrList:Clear()
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_ONLINE_ITEMINFO, self.ItemsChange, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EVENT_MOUNTLV_ITEM_CHANGE, self.ItemsChange, self)
end

-- Initialize server data
function NatureMountData:InitWingInfo(msg)
    if msg and msg.natureInfo then
        self.Cfg = DataConfig.DataNatureHorse[msg.natureInfo.curLevel]
        --self.BaseCfg = DataConfig.DataHorseBasic[msg.natureInfo.mountinfo.Level]
        --self.BaseExp = msg.natureInfo.mountinfo.Exp
        --self.super.CurModel = msg.natureInfo.modelId
        self.super:UpDateSkill(msg.natureInfo.haveActiveSkill) -- Set skills
        self.super:UpDateModel(msg.natureInfo.haveActiveModel) -- Set up the model
        self.super:UpDataFashionInfos(msg.natureInfo.outlineInfo) -- Set the shape
        if self.BaseCfg then
            self:AnalysisAttr(self.BaseCfg.Attribute)
        end
        if self.Cfg then
            self.super:AnalysisAttr(self.Cfg.Attribute)
            self.super:AnalysisItem(self.Cfg.UpItem)
            self.super:Parase(msg.natureType,msg.natureInfo)
            local _num = self.Cfg.Progress - self.super.CurExp
            self.super:UpDateLevelHit(FunctionStartIdCode.MountLevel, self.IsMax, _num, LogicEventDefine.EVENT_MOUNTLV_ITEM_CHANGE)
        end
        self.super:UpDateDrugHit(FunctionStartIdCode.MountDrug)
        self.super:UpDateFashionHit(FunctionStartIdCode.MountFashion)
        self:UpDateModelId(msg.natureInfo.modelId)
    end
end

-- Update basic attributes and upgrade
function NatureMountData:UpDateBaseAttr(msg)
    self.super.Fight = msg.fight
    self.BaseCfg = DataConfig.DataHorseBasic[msg.info.Level]
    self.BaseExp = msg.info.Exp
    if self.BaseCfg then
        self:AnalysisAttr(self.BaseCfg.Attribute)
    end
end

-- Update skills and upgrade
function NatureMountData:UpDateUpLevel(msg)
    if msg.activeSkill then
        self.super:UpDateSkill(msg.activeSkill)
    end
    self.super.Level = msg.level
    self.Cfg = DataConfig.DataNatureHorse[msg.level]
    if self.Cfg then
        self.super:AnalysisAttr(self.Cfg.Attribute)
    end
    if msg.activeModel then
        -- for i = 1, #msg.activeModel do
        --     local _data = self.super:GetModelData(msg.activeModel[i])
        --     if _data and not _data.IsActive then
        --         GameCenter.ModelViewSystem:ShowModel(ShowModelType.Mount, msg.activeModel[i], 160, 0, self.super:GetModelsName(msg.activeModel[i]))
        --     end
        -- end
        self.super:UpDateModel(msg.activeModel)
    end
    self.super.CurExp = msg.curexp
    self.super.Fight = msg.fight
    self.super:UpDateLevelHit(FunctionStartIdCode.MountLevel,self.IsMax, self.Cfg.Progress - msg.curexp,  LogicEventDefine.EVENT_MOUNTLV_ITEM_CHANGE)
end

-- Update the information on eating fruits
function NatureMountData:UpDateGrugInfo(msg)
    self.super.Fight = msg.fight
    self.super:UpDateDrug(msg.druginfo)
    self.super:UpDateDrugHit(FunctionStartIdCode.MountDrug)
end

-- Update the Setup Model ID
function NatureMountData:UpDateModelId(model)
    self.super.CurModel = model
    if model ~= nil and type(model) == "number" then
        LocalPlayerRoot.CurMountId = model
    else
        LocalPlayerRoot.CurMountId = 0
    end
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_UPDATMOUNTRIDE_STATE)
end

-- Update the transformation and upgrading results
function NatureMountData:UpDateFashionInfo(msg)
    local _info = DataConfig.DataHuaxingHorse[msg.id]
    self.super:UpDataFashion(msg,_info)
    self.super:UpDateFashionHit(FunctionStartIdCode.MountFashion)
end

function NatureMountData:ItemsChange()
    if self.super then
        self.super:UpdateLvRed(FunctionStartIdCode.MountLevel)
    end
end

-- Function function! ! ! ! ! ! ! ! ! ! ! ! ! ! !

-- Get the maximum number of stars in the current stage
function NatureMountData:GetCurMaxStar()
    if self.BaseStarDir:ContainsKey(self.Cfg.Steps) then
        return self.BaseStarDir[self.Cfg.Steps]
    end
    return 0
end

function NatureMountData:AnalysisAttr(str)
    self.BaseAttrList:Clear()
    if str then
        local _cs = {';','_'}
        local _attr = Utils.SplitStrByTableS(str,_cs)
        for i=1,#_attr do        
            local _data = BaseAttrData:New(_attr[i][1],_attr[i][2],_attr[i][3])
            self.BaseAttrList:Add(_data)
        end
    end
end

-- Get prop experience
function NatureMountData:GetItemExp(itemid)
    local _isHave = self.BaseItemList:Find(
        function(code)
            return code.ItemID == itemid
        end
    )
    if _isHave then
        return _isHave.ItemExp
    end
    return 0
end

-- Props that can be eaten
function NatureMountData:AnalysisItem(str)
    self.BaseItemList:Clear()
    if str then
        local _attr = Utils.SplitStr(str,'_')
        for i=1,#_attr do
            local _itemid = tonumber(_attr[i])
            local _itemInfo = DataConfig.DataItem[_itemid]
            if _itemInfo then
                local _value = Utils.SplitStr(_itemInfo.EffectNum,'_')
                if _value[2] then
                    local _data = BaseItemData:New(_itemid,tonumber(_value[2]))
                    self.BaseItemList:Add(_data)
                end
            end
        end
    end
end

-- Is it full level?
function NatureMountData:IsMaxLevel()
    return self.IsMax <= self.super.Level
end

-- Is the foundation full?
function NatureMountData:IsBaseMaxLevel()
    return self.BaseIsMax <= self.BaseCfg.Id
end

-- Get the model camera size
function NatureMountData:Get3DUICamerSize(modelid)
    local _info = DataConfig.DataHuaxingHorse[modelid]
    if _info then
        return _info.CameraSize
    end
    return self.super:GetCameraSize(modelid)
end

function NatureMountData:GetModelYPosition(modelid)
    local _info = DataConfig.DataHuaxingHorse[modelid]
    if _info and _info.ModelYPos then
        return _info.ModelYPos / self:Get3DUICamerSize(modelid)
    end
    return 0
end

function NatureMountData:GetModelRotation(modelid)
    local _info = DataConfig.DataHuaxingHorse[modelid]
    if _info and _info.CameraRotation then
        local _attr = Utils.SplitNumber(_info.CameraRotation, '_')
        return _attr[1], _attr[2], _attr[3]
    end
    return 0, 0, 0
end

function NatureMountData:GetShowModelYPosition(modelid)
    local _info = DataConfig.DataHuaxingHorse[modelid]
    if _info and _info.ShowModelYPos then
        return _info.ShowModelYPos / self:Get3DUICamerSize(modelid)
    end
    return 0
end

return NatureMountData

