------------------------------------------------
-- author:
-- Date: 2019-12-05
-- File: DailyGift.lua
-- Module: DailyGift
-- Description: Welfare Daily Gift Pack
------------------------------------------------

local DailyGift = {
    -- The gift package I bought this time
    CurrBuyGiftId = nil,
    -- Free gift package
    FreeGifts = List:New(),
    -- Purchased List
    ReceiveList = List:New(),
    -- Daily Gift Pack List
    DailyGiftList = List:New(),
    -- Is the purchase completed?
    IsAllBuy = false,
    -- Whether you need to display a red dot for the first time entering the game
    IsFirstShow = true,
}

function DailyGift:Initialize()
    self.IsFirstShow = true
    self.DailyGiftList:Clear()
    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.WelfareDailyGift, false)
    GameCenter.RegFixEventHandle(LogicLuaEventDefine.EID_EVENT_REFESH_PAY_DATA, self.OnPayDataRefresh, self)
    return self
end

function DailyGift:UnInitialize()
    self.ReceiveList:Clear()
    self.DailyGiftList:Clear()
    GameCenter.UnRegFixEventHandle(LogicLuaEventDefine.EID_EVENT_REFESH_PAY_DATA, self.OnPayDataRefresh, self)
end

function DailyGift:OnPayDataRefresh(obj, sender)
    self.DailyGiftList:Clear()
    self.FreeGifts:Clear()
    GameCenter.PaySystem.PayDataIdDict:Foreach(
        function(k, v)
            -- 2 is the data of the gift package type
            if v.ServerCfgData.RechargeType == 2 then
                self.DailyGiftList:Add(k)
                if v.ServerCfgData.Money == 0 then
                    self.FreeGifts:Add(k)
                end
            end
        end
    )
    table.sort(self.DailyGiftList, function(a, b)
        return a < b
    end)
    self:CheckIsAllBuy()
    self:CheckDailyGiftRed()
    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.WelfareDailyGift, #self.DailyGiftList > 0)
end

function DailyGift:CheckDailyGiftRed()
    local _red = false
    if self.IsFirstShow then
        _red = true
    else
        for i = 1, #self.FreeGifts do
            if not self.ReceiveList:Contains(self.FreeGifts[i]) then
                _red = true
                break
            end
        end
    end
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.WelfareDailyGift, _red)
end

function DailyGift:CheckIsAllBuy()
    self.IsAllBuy = true
    for i = 1, #self.DailyGiftList do
        local _isReceive = self.ReceiveList:Contains(self.DailyGiftList[i])
        if not _isReceive then
            self.IsAllBuy = false
            break
        end
    end
end

function DailyGift:CheckIsBuySomeone()
    local IsHaveBuy = false
    for i = 1, #self.DailyGiftList do
        local _isReceive = self.ReceiveList:Contains(self.DailyGiftList[i]) and self.DailyGiftList[i] ~= self.FreeGifts[1]
        if _isReceive then
            IsHaveBuy = true
            return IsHaveBuy
        end
    end
    return IsHaveBuy
end

function DailyGift:GetOnekeyBuyID()
    for key, value in pairs(GameCenter.PaySystem.PayDataIdDict) do      
        if value.ServerCfgData.RechargeType == 14 then
            return value.Id
        end
    end  
    return nil
end

-- Request a recharge to purchase a daily gift package
function DailyGift:ReqBuyDailyGift(id)
    self.CurrBuyGiftId = id
    -- 1. If it is 0 yuan, please directly send a request to purchase
    if self.FreeGifts:Contains(self.CurrBuyGiftId) then
        local _reqBuyMsg = ReqMsg.MSG_Recharge.ReqRecharge:New()
        _reqBuyMsg.id = self.CurrBuyGiftId
        _reqBuyMsg:Send()
    -- 2. Follow the real recharge process
    else
        GameCenter.PaySystem:PayByCfgId(self.CurrBuyGiftId)
    end
end

-- Return daily gift package data
function DailyGift:GS2U_ResDailyGiftData(msg)
    if msg.buyIDs then
        self.ReceiveList = List:New(msg.buyIDs)
    else
        self.ReceiveList = List:New()
    end
    self:CheckIsAllBuy()
    self:CheckDailyGiftRed()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_WELFARE_DAILYGIFT_REFRESH, self.CurrBuyGiftId)
    if self.CurrBuyGiftId then
        self.CurrBuyGiftId = nil
    end
end

return DailyGift