------------------------------------------------
-- author:
-- Date: 2019-12-06
-- File: GrowthFund.lua
-- Module: GrowthFund
-- Description: Welfare Growth Fund
------------------------------------------------
local RedPointCustomCondition = CS.Thousandto.Code.Logic.RedPointCustomCondition
local RedPointLevelCondition = CS.Thousandto.Code.Logic.RedPointLevelCondition

local GrowthFund = {
    -- Whether to buy a growth fund
    IsBuy = false,
    -- Purchased growth fund
    Gear = 0,
    -- Number of purchasers for the entire server
    BuyNum = 0,
    -- Personal reward configuration
    SingleConfigList = List:New(),
    -- Full server reward configuration
    AllServerConfigList = List:New(),
    -- Whether you need to display a red dot for the first time entering the game
    IsFirstShow = true,
    -- The number of spiritual jade needed to purchase a growth fund
    CostCount = nil,
}

function GrowthFund:Initialize()
    DataConfig.DataInvestLevel:ForeachCanBreak(function(k, v)
        if v.IfOpen == 1 then
            self.Gear = v.InvestLevel
            self.CostCount = v.Diamond
            return true
        end
    end)
    self:InitSingleConfig()
    return self
end

function GrowthFund:UnInitialize()
    self.IsFirstShow = true
end

-- Initialize personal reward configuration
function GrowthFund:InitSingleConfig()
    DataConfig.DataInvest:Foreach(function(k, v)
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
function GrowthFund:UpdateSingleConfig(rewardList)
    for i = 1, #self.SingleConfigList do
        if rewardList:Contains(self.SingleConfigList[i].ID) then
            self.SingleConfigList[i].IsGet = true
            self.SingleConfigList[i].Sort = self.SingleConfigList[i].Level + 1000
        end
    end
    self:SingleConfigSort()
end

-- Personal Reward Configuration Sort
function GrowthFund:SingleConfigSort()
    table.sort(self.SingleConfigList, function(a, b)
        return a.Sort  < b.Sort
    end)
end

-- Initialize the full server reward configuration
function GrowthFund:InitAllServerConfig()
    DataConfig.DataInvestGlobal:Foreach(function(k, v)
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
function GrowthFund:UpdateAllServerConfig(rewardList)
    for i = 1, #self.AllServerConfigList do
        if rewardList:Contains(self.AllServerConfigList[i].ID) then
            self.AllServerConfigList[i].IsGet = true
        end
    end
end

-- Red dot
function GrowthFund:CheckShowRedPoint()
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.WelfareInvestment)
    if self.IsFirstShow then
        GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.WelfareInvestment, 999999, RedPointCustomCondition(true))
    end
    if self.IsBuy then
        for i = 1, #self.SingleConfigList do
            local _cfg = self.SingleConfigList[i]
            if not _cfg.IsGet then
                GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.WelfareInvestment, _cfg.Level, RedPointLevelCondition(_cfg.Level))
            end
        end
        local _lv = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
        for i = 1, #self.AllServerConfigList do
            local _cfg = self.AllServerConfigList[i]
            if _lv >= _cfg.Level and not _cfg.IsGet and self.BuyNum >= _cfg.Times then
                GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.WelfareInvestment, 999998, RedPointCustomCondition(true))
                break
            end
        end
    end
end

-- Request to buy a growth fund
function GrowthFund:ReqGrowthFundBuy()
    local _req = ReqMsg.MSG_Welfare.ReqGrowthFundBuy:New()
    _req.gear = self.Gear
    _req:Send()
    -- GameCenter.PaySystem:PayByCfgId(self.Gear)
end

-- Request for growth fund rewards
function GrowthFund:ReqGrowthGetAward(cfgID)
    local _req = ReqMsg.MSG_Welfare.ReqGrowthGetAward:New()
    _req.cfgID = cfgID
    _req:Send()
end

-- Request to receive the full service reward of the growth fund
function GrowthFund:ReqGrowthFundServer(cfgID)
    local _req = ReqMsg.MSG_Welfare.ReqGrowthFundServer:New()
    _req.cfgID = cfgID
    _req:Send()
end

-- Growth Fund Data
function GrowthFund:GS2U_ResGrowthFundData(msg)
    self.IsBuy = msg.isBuy
    self.BuyNum = msg.buyNum
    if msg.rewardCfgID  and #msg.rewardCfgID > 0 then
        self:UpdateSingleConfig(List:New(msg.rewardCfgID))
    end
    if msg.rewardCfgIDServer  and #msg.rewardCfgIDServer > 0 then
        self:UpdateAllServerConfig(List:New(msg.rewardCfgIDServer))
    end
    self:CheckShowRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_WELFARE_INVEST_REFRESH)
end

return GrowthFund