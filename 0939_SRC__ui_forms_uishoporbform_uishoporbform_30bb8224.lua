------------------------------------------------
--author:
--Date: 2025-11-04
--File: UIShopOrbForm.lua
--Module: UIShopOrbForm.prefab
------------------------------------------------
local L_UIListMenu = require "UI.Components.UIListMenu.UIListMenu"
local L_UITradeCurrency = require "UI.Components.UITradeCurrency.UITradeCurrency"
local L_UIShopOrbPanel = require "UI.Forms.UIShopOrbForm.UIShopOrbPanel"

local UIShopOrbForm = {
    Texture       = nil,
    CloseBtn      = nil,
    
    --Mall scripts, product lists and purchase operations are processed in the script
    ShopPanel     = nil, -- Panel UI tương ứng với CurrentPageId
    
    --The currently selected page
    CurrentShopId = SpecialShopPanelEnum.OrbShop, -- ID số của shop chính (OrbShop, GoldShop…)
    CurrentPageId = 1, -- ID số của page con (BestSellers, Weapons, Fashion…)
}

------------------------------------------------------------------------------------------------------------------------
--region [Lifecycle Methods]
-- Object lifecycle: OnFirstShow, OnShowAfter,...
-- ---------------------------------------------------------------------------------------------------------------------

function UIShopOrbForm:OnRegisterEvents()
    self:RegisterEvent(UILuaEventDefine.UIShopOrbForm_OPEN, self.OnOpen)
    self:RegisterEvent(UILuaEventDefine.UIShopOrbForm_CLOSE, self.OnClose)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_SHOP_ORB_RESULT, self.OnUpdateShopItemList)
end

function UIShopOrbForm:OnFirstShow()
    self:FindAllComponents()
    self:RegUICallback()
    self.CSForm:AddNormalAnimation()
end

function UIShopOrbForm:OnShowAfter()
    self.CSForm:LoadTexture(self.Texture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_b_shangcheng"))
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_HIDEANIMATION)
end

function UIShopOrbForm:OnHideBefore()
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_SHOWANIMATION)
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
end

function UIShopOrbForm:OnTryHide()
    return self.ShopPanel:OnTryHide()
end

function UIShopOrbForm:Update(dt)
    self.ShopPanel:Update(dt)
end

--endregion [Lifecycle Methods]

------------------------------------------------------------------------------------------------------------------------
--region [UI Event Handlers]
-- UI callbacks: button clicks, hovers, external UI events
-- ---------------------------------------------------------------------------------------------------------------------
function UIShopOrbForm:OnOpen(obj, sender)
    self.CSForm:Show(sender)
    if obj ~= nil then
        if type(obj) == "number" then
            self.CurrentShopId = obj
        else
            local p1, p2, p3 = obj[1], obj[2], obj[3]
            if p1 then self.CurrentShopId = p1 end
            if p2 then self.CurrentPageId = p2 end
            if p3 then self.ShopPanel:SetCurrSelectItemId(p3 or nil) end
        end
    end
    -- self.ShopPanel:HideItemList()
    -- self.ShopPanel:OnClose()
    -- -----------------------------------------------
    local _openId = self.CurrentShopId
    --[[if self.CurrentPageId then
        _openId = self.CurrentPageId
    end]]
    self.UIListMenu:SetSelectById(_openId)
end

function UIShopOrbForm:OnClose(obj, sender)
    self.CSForm:Hide()
end

function UIShopOrbForm:OnUpdateShopItemList(page, sender)
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
    self.ShopPanel:OnUpdateItemList(page, sender == true)
end

-- Click to callback on the big tag list of the mall on the right
function UIShopOrbForm:OnClickCallBack(shopTypeId, isSelected)
    if shopTypeId == -1 or not isSelected then
        return
    end

    if shopTypeId == SpecialShopPanelEnum.OrbShop then
        self.CurrentShopId = shopTypeId
    elseif false then
        -- reserved for future panels
        -- e.g., WeaponShop, GoldShop
    end

    if self.CurrentShopId == SpecialShopPanelEnum.OrbShop then
        self.ShopPanel:OnOpen();
        self.ShopPanel:OnClickCallBack(self.CurrentPageId, self.CurrentShopId);
    elseif false then
        -- reserved for future panels
        -- e.g., self.WeaponShopPagePanel:OnOpen()
    end
end

function UIShopOrbForm:OnClickCloseBtn()
    self:OnClose();
end

--endregion [UI Event Handlers]

------------------------------------------------------------------------------------------------------------------------
--region [Data Binding / UI Update]
-- Update UI elements based on data and state
-- ---------------------------------------------------------------------------------------------------------------------

function UIShopOrbForm:FindAllComponents()
    local _myTrans = self.Trans
    self.Texture = UIUtils.FindTex(_myTrans, "BackTex")
    self.CloseBtn = UIUtils.FindBtn(_myTrans, "RightTop/CloseBtn")
    self.TradeCurrencyForm = L_UITradeCurrency:OnFirstShow(self.CSForm, UIUtils.FindTrans(_myTrans, "RightTop/UIMoneyForm"))
    self.TradeCurrencyForm:SetCurrencyList(6307348, 6307349, 6307350)

    self.UIListMenu = L_UIListMenu:OnFirstShow(self.CSForm, UIUtils.FindTrans(_myTrans, "MainTabList"))
    self.UIListMenu:RemoveAll()
    self.UIListMenu:AddIcon(SpecialShopPanelEnum.OrbShop, "Tiệm Tinh Châu")
    self.UIListMenu:ClearSelectEvent();
    self.UIListMenu:AddSelectEvent(Utils.Handler(self.OnClickCallBack, self))
    self.UIListMenu.IsHideIconByFunc = false

    self.ShopPanel = L_UIShopOrbPanel:OnFirstShow(self.CSForm, UIUtils.FindTrans(_myTrans, "ShopPanels"))
end

function UIShopOrbForm:RegUICallback()
    UIUtils.AddBtnEvent(self.CloseBtn, self.OnClickCloseBtn, self)
end

--endregion [Data Binding / UI Update]

return UIShopOrbForm