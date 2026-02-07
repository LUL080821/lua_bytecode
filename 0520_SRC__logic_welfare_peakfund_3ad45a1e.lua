------------------------------------------------
-- Author:
-- Date: 2021-06-16
-- File: PeakFund.lua
-- Module: PeakFund
-- Description: Welfare Peak Fund
------------------------------------------------
local RedPointCustomCondition = CS.Thousandto.Code.Logic.RedPointCustomCondition
local RedPointLevelCondition = CS.Thousandto.Code.Logic.RedPointLevelCondition

local PeakFund = {
    -- Whether to buy a peak fund
    IsBuy = false,
    -- Purchased peak fund
    Gear = 0,
    -- Number of purchasers for the entire server
    BuyNum = 0,
    -- Personal reward configuration
    SingleConfigList = List:New(),
    -- Full server reward configuration
    AllServerConfigList = List:New(),
    -- Whether you need to display a red dot for the first time entering the game
    IsFirstShow = true,
    CostCount = nil,
}

function PeakFund:Initialize()
    DataConfig.DataInvestPeakLevel:ForeachCanBreak(function(k, v)
        if v.IfOpen == 1 then
            self.Gear = v.InvestLevel
            self.CostCount = v.Diamond
            return true
        end
    end)
    self:InitSingleConfig()
    return self
end

function PeakFund:UnInitialize()
    self.IsFirstShow = true
end

-- Initialize personal reward configuration
function PeakFund:InitSingleConfig()
    DataConfig.DataInvestPeak:Foreach(function(k, v)
        if v.Gear == self.Gear then
            v.IsGet = false
            v.Sort = v.Level
            self.SingleConfigList:Add(v)
        end
    end)
    self:SingleConfigSort()
    self:InitAllServerConfig()
end

-- Update the personal reward configuration
function PeakFund:UpdateSingleConfig(rewardList)
    for i = 1, #self.SingleConfigList do
        if rewardList:Contains(self.SingleConfigList[i].ID) then
            self.SingleConfigList[i].IsGet = true
            self.SingleConfigList[i].Sort = self.SingleConfigList[i].Level + 1000
        end
    end
    self:SingleConfigSort()
end

-- Personal Reward Configuration Sort
function PeakFund:SingleConfigSort()
    table.sort(self.SingleConfigList, function(a, b)
        return a.Sort  < b.Sort
    end)
end

-- Initialize the full server reward configuration
function PeakFund:InitAllServerConfig()
    DataConfig.DataInvestPeakGlobal:Foreach(function(k, v)
        if v.Gear == self.Gear then
            v.IsGet = false
            self.AllServerConfigList:Add(v)
        end
    end)
    table.sort(self.AllServerConfigList, function(a, b)
        return a.Level  < b.Level
    end)
end

-- Update the full server reward configuration
function PeakFund:UpdateAllServerConfig(rewardList)
    for i = 1, #self.AllServerConfigList do
        if rewardList:Contains(self.AllServerConfigList[i].ID) then
            self.AllServerConfigList[i].IsGet = true
        end
    end
end

-- Red dot
function PeakFund:CheckShowRedPoint()
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.WelfareIPeakFund)
    if self.IsFirstShow then
        GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.WelfareIPeakFund, 999999, RedPointCustomCondition(true))
    end
    if self.IsBuy then
        for i = 1, #self.SingleConfigList do
            local _cfg = self.SingleConfigList[i]
            if not _cfg.IsGet then
                GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.WelfareIPeakFund, _cfg.Level, RedPointLevelCondition(_cfg.Level))
            end
        end
        local _lv = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
        for i = 1, #self.AllServerConfigList do
            local _cfg = self.AllServerConfigList[i]
            if _lv >= _cfg.Level and not _cfg.IsGet and self.BuyNum >= _cfg.Times then
                GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.WelfareIPeakFund, 999998, RedPointCustomCondition(true))
                break
            end
        end
    end
end

-- Request to buy a peak fund
function PeakFund:ReqPeakFundBuy()
    local _req = ReqMsg.MSG_Welfare.ReqInvestPeakBuy:New()
    _req.gear = self.Gear
    _req:Send()
    -- GameCenter.PaySystem:PayByCfgId(self.Gear)
end

-- Request for Peak Fund Rewards
function PeakFund:ReqPeakFundGetAward(cfgID)
    local _req = ReqMsg.MSG_Welfare.ReqInvestPeakGetAward:New()
    _req.cfgID = cfgID
    _req:Send()
end

-- Request to receive full fund service rewards
function PeakFund:ReqPeakFundServer(cfgID)
    local _req = ReqMsg.MSG_Welfare.ReqInvestPeakServer:New()
    _req.cfgID = cfgID
    _req:Send()
end

-- Fund data
function PeakFund:GS2U_ResPeakFundData(msg)
    self.IsBuy = msg.isBuy
    self.BuyNum = msg.buyNum
    if msg.rewardCfgID  and #msg.rewardCfgID > 0 then
        self:UpdateSingleConfig(List:New(msg.rewardCfgID))
    end
    if msg.rewardCfgIDServer  and #msg.rewardCfgIDServer > 0 then
        self:UpdateAllServerConfig(List:New(msg.rewardCfgIDServer))
    end
    self:CheckShowRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_WELFARE_Peak_REFRESH)
end

return PeakFund