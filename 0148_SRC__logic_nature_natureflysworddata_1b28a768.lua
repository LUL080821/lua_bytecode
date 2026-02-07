-- Author:
-- Date: 2020-05-21
-- File: NatureFlySwordData.lua
-- Module: NatureFlySwordData
-- Description: The Feijian system subclass inherits NatureBaseData
------------------------------------------------
local NatureBase = require "Logic.Nature.NatureBaseData"
local SkillSetDate = require "Logic.Nature.NatureSkillSetData"
local ModelData= require "Logic.Nature.NatureBaseModelData"
local FashionData = require "Logic.Nature.NatureFashionData"

local NatureFlySwordData = {
    Cfg = nil , -- Wing configuration table data
    IsMax = 0, -- Maximum wing level
    super = nil, -- Parent class object
}

function NatureFlySwordData:New()
    local _obj = NatureBase:New(NatureEnum.FlySword)
    local _M = Utils.DeepCopy(self)
    _M.super = _obj
    return _M
end

-- initialization
function NatureFlySwordData:Initialize()
    -- Initialize the transformed data
    DataConfig.DataHuaxingFlySword:Foreach(function(k, v)
        if v.IfShow and v.IfShow == 1 then
            local _data = FashionData:New(v)
            self.super.FishionList:Add(_data)
        end
    end)
    self.super.FishionList:Sort(
        function(a,b)
            return tonumber(a.ModelId) < tonumber(b.ModelId)
        end
    )
end

-- De-initialization
function NatureFlySwordData:UnInitialize()
    self.Cfg = nil
    self.super = nil
    self.IsMax = 0
end

-- Initialize server data
function NatureFlySwordData:InitWingInfo(msg)
    if msg then
        if msg.huaxinList then
            if msg.curUseHuaxin then
                self.super.CurModel = msg.curUseHuaxin.modelID
            end
            self.super:UpDataFashionInfos(msg.huaxinList) -- Set the shape
            self.super:UpDateFashionHit(FunctionStartIdCode.RealmHuaxing)
        end
    end
end

-- Update the transformation and upgrading results
function NatureFlySwordData:UpDateFashionInfo(msg)
    if msg and msg.curUseHuaxin then
        local _config = DataConfig.DataHuaxingFlySword[msg.curUseHuaxin.modelID]
        self.super:UpDataFashion(msg.curUseHuaxin, _config)
        self.super:UpDateFashionHit(FunctionStartIdCode.RealmHuaxing)
        if msg.type == 1 or msg.type == 3 then
            self.super.CurModel = msg.curUseHuaxin.modelID
        end
        GameCenter.PushFixEvent(LogicLuaEventDefine.NATURE_EVENT_WING_UPDATEFASHION,msg.curUseHuaxin.modelID)
    end
end

-- Function function! ! ! ! ! ! ! ! ! ! ! ! ! ! !

-- Get the model camera size
function NatureFlySwordData:Get3DUICamerSize(modelid)
    local _info = DataConfig.DataHuaxingFlySword[modelid]
    if _info then
        return _info.CameraSize
    end
    return self.super:GetCameraSize(modelid)
end

function NatureFlySwordData:GetModelYPosition(modelid)
    local _info = DataConfig.DataHuaxingFlySword[modelid]
    if _info and _info.ModelYPos then
        return _info.ModelYPos / self:Get3DUICamerSize(modelid)
    end
    return 0
end

function NatureFlySwordData:GetModelRoteZPosition(modelid)
    local _info = DataConfig.DataHuaxingFlySword[modelid]
    if _info and _info.ModelRZPos then
        return _info.ModelRZPos
    end
    return 0
end

function NatureFlySwordData:GetModelPosition(modelid)
    local _info = DataConfig.DataHuaxingFlySword[modelid]
    if _info and _info.ModelYPos and _info.ModelXPos then
        return Vector3(_info.ModelXPos / _info.CameraSize, _info.ModelYPos / _info.CameraSize, 0)
    end
    return 0
end

return NatureFlySwordData

