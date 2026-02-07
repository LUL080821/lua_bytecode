------------------------------------------------
-- author:
-- Date: 2019-12-19
-- File: WelfareCard.lua
-- Module: WelfareCard
-- Description: Benefit Card
------------------------------------------------

local WelfareCard = {
    -- Card purchased this time
    CurrBuyCard = nil,
    -- Benefit card list
    CardList = List:New(),
    -- Benefit card owned
    OwnedCards = nil,
    -- The currently collected ID
    CurReceiveID = nil,
    -- Whether you need to display a red dot for the first time entering the game
    IsFirstShow = true,
}

function WelfareCard:Initialize()
    -- DataConfig.DataMonthCard:Foreach(function(k, v)
    --     self.CardList:Add(k)
    -- end)
    -- table.sort(self.CardList, function(a, b)
    --     return a < b
    -- end)
    -- Write 4 and 5 first to modify it later. What Lao Huang said is written 4 and 5 first to modify it
    self.CardList:Add(4)
    self.CardList:Add(5)
    return self
end

function WelfareCard:UnInitialize()
    self.CurrBuyCard = nil
    self.CardList:Clear()
    self.OwnedCards = nil
    self.IsFirstShow = true
end

function WelfareCard:SetIsFirstShow(b)
    if self.IsFirstShow == b then
        return
    end
    self.IsFirstShow = b
    self:CheckWelfareCardRed()
end

-- Detect red dots
function WelfareCard:CheckWelfareCardRed()
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.WelfareCard, self:IsRedpoint())
end

-- Is there a little red dot
function WelfareCard:IsRedpoint()
    if self.IsFirstShow then
        return true
    end
    local _keys = self.OwnedCards:GetKeys();
    for i = 1, #_keys do
        -- What Lao Huang said is to die first
        if _keys[i] ~= 1 and _keys[i] ~= 2 then
            if not self.OwnedCards[_keys[i]].receive then
                return true
            end
        end
    end
    return false
end

-- Whether to receive it
function WelfareCard:IsBought(specialCard)
    if not self.OwnedCards then
        return false
    end
    return not (not self.OwnedCards[specialCard]);
end

-- Get multiples
function WelfareCard:GetTimes(id)
    local _cfg = DataConfig.DataMonthCard[id]
    return _cfg.MagicBowl/10000;
end

-- Request to purchase a welfare card
function WelfareCard:ReqBuyCard(id)
    local _req = ReqMsg.MSG_Welfare.ReqExclusiveCard:New()
    _req.id = id
    _req:Send()
end

-- Request a reward
function WelfareCard:ReqReward(id)
    local _req = ReqMsg.MSG_Welfare.ReqExclusiveCardReward:New()
    self.CurReceiveID = id
    _req.id = id
    _req:Send()
end

-- Welfare card data
function WelfareCard:GS2U_ResWelfareCards(msg)
    local _IsFirstEnterMap = false;
    if not self.OwnedCards then
        self.OwnedCards = Dictionary:New();
        _IsFirstEnterMap = true;
    end
    local _activateCard = nil
    self.OwnedCards:Clear()
    if msg.ownedCards then
        for i = 1, #msg.ownedCards do
            local _v = msg.ownedCards[i]
            if not _IsFirstEnterMap and not self.OwnedCards[_v.id] then
                _activateCard = _v.id == 4 and SpecialCard.Week or SpecialCard.Month
            end
            self.OwnedCards[_v.id] = _v
        end
    end
    self:CheckWelfareCardRed()
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_WELFARE_CARD_REFRESH, self.CurrBuyCard)
    self.CurrBuyCard = nil
    if _activateCard then
        if self.CurrBuyCard then
            local _cfg = DataConfig.DataMonthCard[self.CurrBuyCard]
            if not _cfg then
                return
            end
            Utils.ShowPromptByEnum("BuySuccess", _cfg.Name)
        end
    end
    if self.CurReceiveID then
        local _cfg = DataConfig.DataMonthCard[self.CurReceiveID]
        if not _cfg then
            self.CurReceiveID = nil
            return
        end
        -- local _msg = UIUtils.CSFormat(DataConfig.DataMessageString.Get("BuySuccess"), _cfg.Name)
        Utils.ShowPromptByEnum("C_SHOP_TIPS_RECIEVEMONEYSUCESS")
        -- Notify SDK that the weekly or monthly card is successfully purchased
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_WELFARE_CARD_RECEIVED, self.CurReceiveID)
        self.CurReceiveID = nil
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_WELFARE_CARD_ACTIVATE);
end

return WelfareCard