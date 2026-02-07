-- Author: 
-- Date: 2019-04-18
-- File: NaturePetData.lua
-- Module: NaturePetData
-- Description: Mount data system subclass inherits NatureBaseData
------------------------------------------------
local NatureBase = require "Logic.Nature.NatureBaseData"

local NaturePetData = {
}

function NaturePetData:New()
    local _obj = NatureBase:New(NatureEnum.Pet)
    local _M = Utils.DeepCopy(self)
    _M.super = _obj
    return _M
end

-- Initialization skills
function NaturePetData:Initialize()
    -- Props that can be eaten
    --local _iteminfo = DataConfig.DataHorseBasic[1].UpItem
    --self:AnalysisItem(_iteminfo)
end

-- De-initialization
function NaturePetData:UnInitialize()
end

-- Initialize server data
function NaturePetData:InitWingInfo(msg)
    if msg and msg.natureInfo then
        self.Cfg = DataConfig.DataHuaxingfabao[msg.natureInfo.curLevel]
        -- self.super:UpDateModel(msg.natureInfo.haveActiveModel) --Set the model
        -- self.super:UpDataFashionInfos(msg.natureInfo.outlineInfo) --Set the transformation
        self.super:Parase(msg.natureType, msg.natureInfo)
        -- self.super:UpDateFashionHit(FunctionStartIdCode.FaBaoHuaxing)
        self.super:UpDateDrugHit(FunctionStartIdCode.PetProSoul)
    end
end

-- Update the information on eating fruits
function NaturePetData:UpDateGrugInfo(msg)
    self.super.Fight = msg.fight
    self.super:UpDateDrug(msg.druginfo)
    self.super:UpDateDrugHit(FunctionStartIdCode.PetProSoul)
end

return NaturePetData

