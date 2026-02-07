------------------------------------------------
--author:
--Date: 2025-11-04
--File: UIShopOrbBuyConfirm.lua
--Module: UIShopOrbForm > UIShopOrbBuyConfirm
--Description: Shop Purchase Confirmation Panel
------------------------------------------------
local L_ItemBase = CS.Thousandto.Code.Logic.ItemBase
local L_UICheckBox = require "UI.Components.UICheckBox"

local UIShopOrbBuyConfirm = {
    Texture   = nil, --Background image
    CanBtn    = nil, --Close button
    OkBtn     = nil, --OK button
    ItemID    = nil, --Props ID
    IsVisible = false,
}

------------------------------------------------------------------------------------------------------------------------
--region [Init & Config]
-- Initialization, setup, and preloading data
-- ---------------------------------------------------------------------------------------------------------------------

---Called once when panel first created
function UIShopOrbBuyConfirm:OnFirstShow(trans, parent)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.CSForm = parent
    _m.Go = trans.gameObject
    _m:FindAllComponents()
    _m:RegUICallback()
    _m.CSForm:AddTransNormalAnimation(trans, 50, 0.3)
    _m.Go:SetActive(false)
    return _m
end

--endregion [Init & Config]

------------------------------------------------------------------------------------------------------------------------
--region [Data Binding / UI Update]
-- Update UI elements based on data and state
-- ---------------------------------------------------------------------------------------------------------------------

---Register events on the UI, such as click events, etc.
function UIShopOrbBuyConfirm:RegUICallback()
    UIUtils.AddBtnEvent(self.CanBtn, self.OnClickCanBtn, self)
    UIUtils.AddBtnEvent(self.OkBtn, self.OnClickOkBtn, self)
end

---Find components
function UIShopOrbBuyConfirm:FindAllComponents()
    self.Texture = UIUtils.FindTex(self.Trans, "Texture")
    self.CanBtn = UIUtils.FindBtn(self.Trans, "Canel")
    self.OkBtn = UIUtils.FindBtn(self.Trans, "OK")
    self.GetItem = UILuaItem:New(UIUtils.FindTrans(self.Trans, "Item"))
    self.CostTipsLabel = UIUtils.FindLabel(self.Trans, "Cost")
    self.CostCoinIcon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(self.Trans, "CostIcon"))
    local _checkTrans = UIUtils.FindTrans(self.Trans, "CheckBox")
    if _checkTrans then
        self.CheckBox = L_UICheckBox:OnFirstShow(_checkTrans)
        self.CheckBox:SetOnClickFunc(Utils.Handler(self.OnClickCheckBox, self))
    end
    if UIUtils.FindTrans(self.Trans, "CloseBtn") then
        local _btn = UIUtils.FindBtn(self.Trans, "CloseBtn")
        UIUtils.AddBtnEvent(_btn, self.OnClickCanBtn, self)
    end
end

---Whether to check only this professional equipment
function UIShopOrbBuyConfirm:OnClickCheckBox(check)
    if self.CheckBox.IsChecked then
        GameCenter.ShopSystem.IsBuyComfirm = false
    end
end

---Cancel button
function UIShopOrbBuyConfirm:OnClickCanBtn()
    self:OnClose()
end

---OK button
function UIShopOrbBuyConfirm:OnClickOkBtn()
    local _haveCurrency = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(self.CoinType)
    if self.RealPrice and _haveCurrency >= self.RealPrice then
        GameCenter.ShopSpecialSystem:ReqExchangeOrb(self.ShopItemID, self.ItemNum)
    else
        Utils.ShowPromptByEnum("C_SHOP_BUYCOINLESS_TIPS", L_ItemBase.GetItemName(self.CoinType))
    end
    self:OnClose()
end

--endregion [Data Binding / UI Update]

------------------------------------------------------------------------------------------------------------------------
--region [Public API / Getters & Setters]
-- Methods callable from outside (other systems or UI)
-- ---------------------------------------------------------------------------------------------------------------------

---@param info: UIShopOrbItem.lua
---@param itemNum: số lượng item
function UIShopOrbBuyConfirm:OnOpen(info, itemNum)
    if info and itemNum then
        self.ShopItemID = info:GetShopItemID()
        self.ItemNum = itemNum
        self.ShopItemInfo = info

        self.ItemID = info:GetItemID()
        self.CoinType = info:GetCostType()
        self.CoinNum = itemNum * (info:GetCostNum())
        self.CSForm:PlayShowAnimation(self.Trans)
        self.IsVisible = true
        self:_SetItem()
        self:_LoadTextures()
        if self.CheckBox then
            self.CheckBox:SetChecked(false)
        end
    end
end

function UIShopOrbBuyConfirm:OnClose()
    self.CSForm:PlayHideAnimation(self.Trans, function()
        self.CSForm:UnloadTexture(self.Texture)
    end)
    self.IsVisible = false
end

--endregion [Public API / Getters & Setters]

------------------------------------------------------------------------------------------------------------------------
--region [Private Helpers]
-- Internal utilities, component finding, and setup functions
-- ---------------------------------------------------------------------------------------------------------------------

---Set item prop
function UIShopOrbBuyConfirm:_SetItem()
    self.GetItem.IsShowTips = true
    self.GetItem:InItWithCfgid(self.ItemID, self.ItemNum, self.ShopItemInfo:GetItemData().IsBind)
    --self.CostCoinIcon:UpdateIcon(LuaItemBase.GetItemIcon(self.CoinType))
    local itemCostCfg = DataConfig.DataItem[self.CoinType]
    self.CostCoinIcon:UpdateIcon(itemCostCfg.Icon)
    local _discount = 10
    --if self.ShopItemInfo.IsDisCount and self.ShopItemInfo.IsDisCount == 1 then
    --    _discount = GameCenter.ShopSystem:GetCurDisCount()
    --end
    --
    self.RealPrice = math.ceil(self.CoinNum * _discount / 10)
    if self.GetItem.ShowItemData then
        if self.CoinNum > self.RealPrice then
            UIUtils.SetTextByEnum(self.CostTipsLabel, "C_SHOPMALL_BUYCOM", self.RealPrice, self.ItemNum, self.GetItem.ShowItemData.Name, self.CoinNum - self.RealPrice)
        else
            UIUtils.SetTextByEnum(self.CostTipsLabel, "C_UI_SHOP_BUYCOMFIRM_TIPS", self.CoinNum, self.ItemNum, self.GetItem.ShowItemData.Name)
        end
    end
end

function UIShopOrbBuyConfirm:_LoadTextures()
    self.CSForm:LoadTexture(self.Texture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_3_3"))
end

--endregion [Private Helpers]

return UIShopOrbBuyConfirm