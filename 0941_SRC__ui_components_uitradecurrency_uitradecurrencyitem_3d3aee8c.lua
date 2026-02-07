------------------------------------------------
-- Author: 
-- Date: 2025-11-04
-- File: UICurrencyItem.lua
-- Module: UICurrencyItem
-- Description: Money Item
------------------------------------------------
local UITradeCurrencyItem = {
    Root        = nil,
    RootGo      = nil,

    CurrencyID  = 0,
    CurrencyCfg = nil,
    Icon        = nil,
    Value       = nil,
    Btn         = nil,
}

------------------------------------------------------------------------------------------------------------------------
--region [Init & Config]
-- Initialization, setup, and preloading data
-- ---------------------------------------------------------------------------------------------------------------------

function UITradeCurrencyItem:New(trans)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.RootGo = trans.gameObject
    _m:FindAllComponents()
    return _m
end

--endregion [Init & Config]

------------------------------------------------------------------------------------------------------------------------
--region [Data Binding / UI Update]
-- Update UI elements based on data and state
-- ---------------------------------------------------------------------------------------------------------------------

function UITradeCurrencyItem:FindAllComponents()
    self.Icon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(self.Trans, "Icon"))
    self.Value = UIUtils.FindLabel(self.Trans, "Label")
    --self.Btn = UIUtils.FindBtn(self.Trans, "Add")
    --UIUtils.AddBtnEvent(self.Btn, self.OnBtnClick, self)
end

function UITradeCurrencyItem:OnBtnClick()
end

--endregion[Data Binding / UI Update]

------------------------------------------------------------------------------------------------------------------------
--region [Public API / Getters & Setters]
-- Methods callable from outside (other systems or UI)
-- ---------------------------------------------------------------------------------------------------------------------

function UITradeCurrencyItem:SetItemCfg(itemCfg)
    self.Icon:UpdateIcon(itemCfg.Icon)
    self.CurrencyID = itemCfg.Id
    self.CurrencyCfg = itemCfg

    self:UpdateValue();
end

function UITradeCurrencyItem:UpdateValue()
    local showValue = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(self.CurrencyID);
    UIUtils.SetTextByBigNumber(self.Value, showValue, true, 4)
end

function UITradeCurrencyItem:SetVisible(isVisible)
    self.RootGo:SetActive(isVisible)
end

function UITradeCurrencyItem:IsVisible()
    return self.RootGo.activeSelf
end

--endregion [Public API / Getters & Setters]

return UITradeCurrencyItem