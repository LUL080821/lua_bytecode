------------------------------------------------
-- Author: 
-- Date: 2025-11-04
-- File: UITradeCurrencyForm.lua
-- Module: UITradeCurrencyForm
-- Description: Clone Money Form
------------------------------------------------
local UITradeCurrencyItem = require "UI.Components.UITradeCurrency.UITradeCurrencyItem"

local MAX_SHOW_CURRENCY = 4
local UITradeCurrencyForm = {
    Root      = nil,
    Go        = nil,

    Item      = nil,
    ItemList  = List:New(),
    IsVisible = false,
    IsInit    = false,
}

------------------------------------------------------------------------------------------------------------------------
--region [Lifecycle Methods]
-- Object lifecycle: OnOpen, OnClose
-- ---------------------------------------------------------------------------------------------------------------------

function UITradeCurrencyForm:OnFirstShow(owner, trans)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m.ParentForm = owner
    _m:FindAllComponents()
    LuaBehaviourManager:Add(_m.Trans, _m)
    return _m
end

function UITradeCurrencyForm:OnEnable()
    self:UpdateCurrencies()
    GameCenter.RegFixEventHandle(LogicEventDefine.EVENT_BACKFORM_ITEM_UPDATE, self.OnUpdateItem, self)
    --GameCenter.RegFixEventHandle(LogicEventDefine.EVENT_ITEM_CHANGE_UPDATE, self.OnUpdateItemByCfgId, self)
end

function UITradeCurrencyForm:OnDisable()
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EVENT_BACKFORM_ITEM_UPDATE, self.OnUpdateItem, self)
    --GameCenter.UnRegFixEventHandle(LogicEventDefine.EVENT_ITEM_CHANGE_UPDATE, self.OnUpdateItemByCfgId, self)
end

--endregion [Lifecycle Methods]

------------------------------------------------------------------------------------------------------------------------
--region [UI Event Handlers]
-- UI callbacks: button clicks, hovers, external UI events
-- ---------------------------------------------------------------------------------------------------------------------

---@param itemBase -- ItemBase.cs
function UITradeCurrencyForm:OnUpdateItem(itemBase)
    if itemBase and itemBase.CfgID then
        self:OnCurrencyChanged(itemBase.CfgID)
    end
end

---@param itemID number: item CfgID
function UITradeCurrencyForm:OnUpdateItemByCfgId(itemID)
    if itemID then
        self:OnCurrencyChanged(itemID)
    end
end

--endregion [UI Event Handlers]

------------------------------------------------------------------------------------------------------------------------
--region [Data Binding / UI Update]
-- Update UI elements based on data and state
-- ---------------------------------------------------------------------------------------------------------------------

function UITradeCurrencyForm:FindAllComponents()
    if self.IsInit then
        return
    end
    self.ItemList = List:New()
    self.RightTopTrans = UIUtils.FindTrans(self.Trans, "RightTop")
    for i = 0, self.RightTopTrans.childCount - 1 do
        self.Item = UITradeCurrencyItem:New(self.RightTopTrans:GetChild(i))
        self.ItemList:Add(self.Item)
    end
    self.IsInit = true;
end

---Update all Currency
function UITradeCurrencyForm:UpdateCurrencies()
    if not self.ItemList then return end
    for _, item in ipairs(self.ItemList) do
        item:UpdateValue()
    end
end

---Currency change callback
function UITradeCurrencyForm:OnCurrencyChanged(currencyId)
    if not self.ItemList then return end

    for _, item in ipairs(self.ItemList) do
        if item:IsVisible() and item.CurrencyID == currencyId then
            item:UpdateValue()
        end
    end
end

--endregion [Data Binding / UI Update]

------------------------------------------------------------------------------------------------------------------------
--region [Public API / Getters & Setters]
-- Methods callable from outside (other systems or UI)
-- ---------------------------------------------------------------------------------------------------------------------

function UITradeCurrencyForm:SetCurrencyList(...)
    local currencies = { ... }
    if #currencies == 0 then return end

    -- Set Item config
    local _uiIndex = 1
    for i = 1, #currencies do
        if _uiIndex > MAX_SHOW_CURRENCY then break end

        local id = currencies[i]
        local _itemCfg = DataConfig.DataItem[id]

        local uiItem = self.ItemList[_uiIndex]

        if _itemCfg and uiItem then
            uiItem:SetItemCfg(_itemCfg)
            uiItem:SetVisible(true)
        end
        _uiIndex = _uiIndex + 1
    end

    -- Hide remaining unused UI slots
    for i = _uiIndex, MAX_SHOW_CURRENCY do
        local uiItem = self.ItemList[i]
        if uiItem then
            uiItem:SetVisible(false)
        end
    end
end

--endregion [UI Event Handlers]

------------------------------------------------------------------------------------------------------------------------
--region [Private Helpers]
-- Internal utilities, component finding, and setup functions
-- ---------------------------------------------------------------------------------------------------------------------

--endregion [Private Helpers]

return UITradeCurrencyForm