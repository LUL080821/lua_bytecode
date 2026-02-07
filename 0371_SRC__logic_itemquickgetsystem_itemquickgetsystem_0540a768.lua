------------------------------------------------
-- Author:
-- Date: 2021-02-22
-- File: ItemQuickGetSystem.lua
-- Module: ItemQuickGetSystem
-- Description: Quick item acquisition system
------------------------------------------------

local ItemQuickGetSystem = {
    TipsStr = nil,
}

function ItemQuickGetSystem:Initialize()
    self.TipsStr = nil
end
function ItemQuickGetSystem:UnInitialize()
    self.TipsStr = nil
end

function ItemQuickGetSystem:OpenItemQuickGetForm(itemId)
    if itemId == ItemTypeCode.Gold then
        -- Yuanbao
        local _curRecharge = GameCenter.VipSystem.CurRecharge
        -- First charge when there is no first charge
        if _curRecharge <= 0 and GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.FirstCharge) then
            GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.FirstCharge)
            return
        end
        -- Spiritual Jade Access Path Blocking Privileges Card
        -- -- If there is no monthly card, the monthly card will be popped up
        -- local _welfareCard = GameCenter.WelfareSystem.WelfareCard
        -- if _welfareCard ~= nil and GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.WelfareCard) then
        --     if _welfareCard.OwnedCards == nil or _welfareCard.OwnedCards:Count() < 2 then
        --         GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.WelfareCard)
        --         return
        --     end
        -- end
        -- Lingyu acquisition method blocks growth fund
        -- --Growth funds pop up when no growth funds are purchased
        -- local grow = GameCenter.WelfareSystem.GrowthFund
        -- if grow ~= nil and not grow.IsBuy and GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.WelfareInvestment) then
        --     GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.WelfareInvestment)
        --     return
        -- end
        -- Jump to the daily gift package when you have not purchased it
        local _dailyGift = GameCenter.WelfareSystem.DailyGift
        if _dailyGift ~= nil and not _dailyGift.IsAllBuy and GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.WelfareDailyGift) then
            GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.WelfareDailyGift)
            return
        end
        GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.Pay)
        return
    end
    local _equipCfg = DataConfig.DataEquip[itemId]
    local _itemCfg = DataConfig.DataItem[itemId]
    if _equipCfg ~= nil and string.len(_equipCfg.GetText) <= 0 then
        return
    end
    if _itemCfg ~= nil and string.len(_itemCfg.GetText) <= 0 then
        return
    end
    GameCenter.PushFixEvent(UIEventDefine.UIItemQuickGetForm_OPEN, itemId)
end

return ItemQuickGetSystem