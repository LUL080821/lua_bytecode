------------------------------------------------
--author:
--Date: 2025-11-04
--File: UIShopOrbPanel.lua
--Module: UIShopOrbForm > UIShopOrbPanel
--Description: Shop Orb
------------------------------------------------
local L_UIAnimDelayPlayer = require "UI.Components.UIAnimDelayPlayer"
local L_ShopOrbItem = require "UI.Forms.UIShopOrbForm.UIShopOrbItem"
local L_BuyConfirmPanel = require "UI.Forms.UIShopOrbForm.UIShopOrbBuyConfirm"

local UIShopOrbPanel = {
    Trans            = nil,
    Go               = nil,
    CSForm           = nil,

    --Product List
    ListScrollView   = nil,
    ListGrid         = nil,
    ListGridTrans    = nil,
    ListItem         = nil,
    ShopList         = List:New(),

    IsVisible        = false,

    --The currently selected page
    CurrSelectItem   = nil,
    CurrSelectItemId = nil,

    CurrentShopId    = SpecialShopPanelEnum.OrbShop, -- ID số của shop chính (OrbShop, GoldShop…)
    CurrentPageId    = 1, -- ID số của page con (BestSellers, Weapons, Fashion…)
}

------------------------------------------------------------------------------------------------------------------------
--region [Lifecycle Methods]
-- Object lifecycle: OnOpen, OnClose
-- ---------------------------------------------------------------------------------------------------------------------

function UIShopOrbPanel:OnFirstShow(parent, trans)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.CSForm = parent
    _m.Go = trans.gameObject
    _m:FindAllComponents()
    _m.AnimPlayer = L_UIAnimDelayPlayer:New(_m.CSForm.AnimModule)
    return _m
end

function UIShopOrbPanel:OnOpen()
    self.Go:SetActive(true)
    self.IsVisible = true
end

function UIShopOrbPanel:OnClose()
    self.Go:SetActive(false)
    self.IsVisible = false
end

function UIShopOrbPanel:OnTryHide()
    return true
end

function UIShopOrbPanel:Update(dt)
    if not self.IsVisible then
        return
    end
    self.AnimPlayer:Update(dt)
end

--endregion [Lifecycle Methods]

------------------------------------------------------------------------------------------------------------------------
--region [Data Binding / UI Update]
-- Update UI elements based on data and state
-- ---------------------------------------------------------------------------------------------------------------------

--Click to callback on the list of small tags at the top of the mall
function UIShopOrbPanel:OnClickCallBack(pageId, shopId)
    self:HideItemList()
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN, DataConfig.DataMessageString.Get("Load_GoodsList"));
    GameCenter.ShopSpecialSystem:ReqOpenOrbShop(shopId, pageId) -- SpecialShopPanelEnum.OrbShop
end

function UIShopOrbPanel:OnUpdateItemList(page, playAnim)
    local _spContainer = GameCenter.ShopSpecialSystem:GetShopItemContainer(self.CurrentShopId) -- SpecialShopPanelEnum.OrbShop
    if _spContainer == nil then
        return
    end
    self.CurrentPageId = page

    local _index = 1
    local _itemDic = _spContainer:GetShopItemDic()
    _itemDic:Foreach(function(cfgId, itemData)
        -- itemData:  <ShopOrbItemData.lua>

        local _shopItemUI = nil
        _shopItemUI = self.ShopList[_index]
        --if #self.ShopList >= _index then
        --    _shopItemUI = self.ShopList[_index]
        --end
        if _shopItemUI == nil then
            _shopItemUI = self.ListItem:Clone()
            _shopItemUI.ClickCallBack = Utils.Handler(self.OnClickItem, self)
            self.ShopList:Add(_shopItemUI)
        end
        _shopItemUI:SetItemActive(true)
        _shopItemUI:UpdateShopItemData(itemData)
        _shopItemUI:SetItemQuantity(nil) -- Reset

        _index = _index + 1
    end)
    for i = _index, #self.ShopList do
        self.ShopList[i]:SetItemActive(false)
    end
    self.ListGrid:Reposition()
    self.ListScrollView:ResetPosition()
end

function UIShopOrbPanel:FindAllComponents()
    self.ListScrollView = UIUtils.FindScrollView(self.Trans, "TabScroll")
    self.ScrollTrans = UIUtils.FindTrans(self.Trans, "TabScroll")
    self.ListGridTrans = UIUtils.FindTrans(self.Trans, "TabScroll/Grid")
    self.ListGrid = UIUtils.FindGrid(self.Trans, "TabScroll/Grid")
    for i = 0, self.ListGridTrans.childCount - 1 do
        self.ListItem = L_ShopOrbItem:New(self.ListGridTrans:GetChild(i), self.CSForm)
        self.ListItem.ClickCallBack = Utils.Handler(self.OnClickItem, self)
        self.ShopList:Add(self.ListItem)
    end

    self.BuyConfirmPopup = L_BuyConfirmPanel:OnFirstShow(UIUtils.FindTrans(self.Trans, "BuyConfirmPopup"), self.CSForm)
    self.BuyConfirmPopup:OnClose()
end

---Click on the product list
---@param item: UIShopOrbItem.lua
function UIShopOrbPanel:OnClickItem(item)
    local itemNum = item:GetItemQuantity()
    ---
    self.CurrSelectItem = item
    self:SetCurrSelectItemId(item:GetShopItemID())
    ----------
    self.BuyConfirmPopup:OnOpen(item, itemNum)
end

--endregion [Data Binding / UI Update]

------------------------------------------------------------------------------------------------------------------------
--region [Public API / Getters & Setters]
-- Methods callable from outside (other systems or UI)
-- ---------------------------------------------------------------------------------------------------------------------

function UIShopOrbPanel:HideItemList()
    for i = 1, #self.ShopList do
        self.ShopList[i]:SetItemActive(false)
    end
end

function UIShopOrbPanel:SetCurrSelectItemId(itemID)
    self.CurrSelectItemId = itemID
end

function UIShopOrbPanel:GetCurrSelectItemId()
    return self.CurrSelectItemId
end

--endregion [Public API / Getters & Setters]

return UIShopOrbPanel