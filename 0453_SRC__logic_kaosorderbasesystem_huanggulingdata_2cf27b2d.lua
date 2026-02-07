------------------------------------------------
-- Author:
-- Date: 2021-04-21
-- File: HuangGuLingData.lua
-- Module: HuangGuLingData
-- Description: The ancient ling iten data
------------------------------------------------
-- Quote
local HuangGuLingData = {
    Id = 0,
    Score = 0,
    FreeItemState = false,
    SpecialItemState = false,
    Rank = 0,
    FreeItem = nil,
    SpecialItem = nil,
    IfEnd = false,
    IfLast = 0, 
    Cfg = nil,
}

function HuangGuLingData:New(id)
    local _m = Utils.DeepCopy(self)
    _m.Id = id
    _m:SetDate()
    return _m
end

-- Set the status of free rewards
function HuangGuLingData:SetFreeState(state)
    self.FreeItemState = state
end

-- Set the status of special rewards
function HuangGuLingData:SetSpecialState(state)
    self.SpecialItemState = state
end

function HuangGuLingData:SetDate()
    local _cfg = DataConfig.DataKaoShangLingHorse[self.Id]
    self.Score = _cfg.Score
    self.Rank = _cfg.Rank
    self.FreeItem = _cfg.CommonReward
    self.SpecialItem = _cfg.SpecailReward
    self.IfEnd = _cfg.IfEnd
    self.IfLast = _cfg.IfLast
    self.Cfg = _cfg
end

function HuangGuLingData:GetCfg()
    return self.Cfg
end

return HuangGuLingData
