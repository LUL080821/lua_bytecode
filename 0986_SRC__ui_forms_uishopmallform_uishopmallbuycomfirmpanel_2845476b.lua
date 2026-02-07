------------------------------------------------
--author:
--Date: 2019-11-22
--File: UIShopMallBuyComfirmPanel.lua
--Module: Mall Purchase Confirmation Panel
------------------------------------------------
local L_ItemBase = CS.Thousandto.Code.Logic.ItemBase
local L_UICheckBox = require ("UI.Components.UICheckBox")
local UIShopMallBuyComfirmPanel = {
    Texture = nil, --Background image
    CanBtn = nil, --Close button
    OkBtn = nil, --OK button
    ItemID = nil,--Props ID
    IsVisible = false,
}

--Open
function UIShopMallBuyComfirmPanel:OnOpen(info, itemNum)
    if info and itemNum then
        self.ItemNum = itemNum
        self.ShopItemInfo = info
        self.CoinType = info.CoinType
        self.SellId = info.SellId
        self.ItemID = info.ItemId
        self.CoinNum = itemNum * (self.ShopItemInfo.Price + self.ShopItemInfo.AddPrice)
        self.CSForm:PlayShowAnimation(self.Trans)
        self.IsVisible = true
        self:LoadTextures()
        self:SetItem()
        if self.CheckBox then
            self.CheckBox:SetChecked(false)
        end
    end
end

--closure
function UIShopMallBuyComfirmPanel:OnClose()
    self.CSForm:PlayHideAnimation(self.Trans, function()
        self.CSForm:UnloadTexture(self.Texture)
    end)
    self.IsVisible = false
end

function UIShopMallBuyComfirmPanel:OnFirstShow(parent, trans)
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

--Register events on the UI, such as click events, etc.
function UIShopMallBuyComfirmPanel:RegUICallback()
    UIUtils.AddBtnEvent(self.CanBtn, self.OnClickCanBtn, self)
    UIUtils.AddBtnEvent(self.OkBtn, self.OnClickOkBtn, self)
end

--Find components
function UIShopMallBuyComfirmPanel:FindAllComponents()
    self.Texture = UIUtils.FindTex(self.Trans,"Texture")
    self.CanBtn = UIUtils.FindBtn(self.Trans,"Canel")
    self.OkBtn = UIUtils.FindBtn(self.Trans,"OK")
    self.GetItem = UILuaItem:New(UIUtils.FindTrans(self.Trans,"Item"))
    self.CostTipsLabel = UIUtils.FindLabel(self.Trans,"Cost")
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

--Close button
function UIShopMallBuyComfirmPanel:OnClickCanBtn()
    self:OnClose()
end

--Whether to check only this professional equipment
function UIShopMallBuyComfirmPanel:OnClickCheckBox(check)
    if self.CheckBox.IsChecked then
        GameCenter.ShopSystem.IsBuyComfirm = false
    end
end

--Set props
function UIShopMallBuyComfirmPanel:SetItem()
    self.GetItem.IsShowTips = true
    self.GetItem:InItWithCfgid(self.ItemID, self.ItemNum, self.ShopItemInfo.BuyBind)
    self.CostCoinIcon:UpdateIcon(LuaItemBase.GetItemIcon(self.CoinType))
    local _discount = 10
    if self.ShopItemInfo.IsDisCount and self.ShopItemInfo.IsDisCount == 1 then
        _discount = GameCenter.ShopSystem:GetCurDisCount()
    end

    self.RealPrice = math.ceil( self.CoinNum * _discount / 10 )
    if self.GetItem.ShowItemData then
        if self.CoinNum > self.RealPrice then
            UIUtils.SetTextByEnum(self.CostTipsLabel, "C_SHOPMALL_BUYCOM",  self.RealPrice,self.ItemNum, self.GetItem.ShowItemData.Name, self.CoinNum - self.RealPrice)
        else
            UIUtils.SetTextByEnum(self.CostTipsLabel, "C_UI_SHOP_BUYCOMFIRM_TIPS",  self.CoinNum,self.ItemNum, self.GetItem.ShowItemData.Name)
        end
    end
end

--OK button
function UIShopMallBuyComfirmPanel:OnClickOkBtn()
    local _vipLv = self.ShopItemInfo.VipLv
    if _vipLv > 0 then
        if GameCenter.VipSystem:GetVipLevel() < _vipLv then
            Utils.ShowPromptByEnum("C_SHOP_BUY_VIPLV", _vipLv)
            self:OnClose()
            return
        end
        if GameCenter.VipSystem.BaoZhuState == 0 then
            Utils.ShowPromptByEnum("C_SHOP_BUY_BAOZHU")
            self:OnClose()
            return
        end
    end
    if self.RealPrice and GameCenter.ItemContianerSystem:GetEconomyWithType(self.CoinType) >= self.RealPrice then
        local _req = {}
        _req.sellId = self.SellId
        _req.num = self.ItemNum
        GameCenter.Network.Send("MSG_Shop.ReqBuyItem", _req)
    else
        Utils.ShowPromptByEnum("C_SHOP_BUYCOINLESS_TIPS", L_ItemBase.GetItemName(self.CoinType))
    end
    self:OnClose()
end

--Loading texture
function UIShopMallBuyComfirmPanel:LoadTextures()
    self.CSForm:LoadTexture(self.Texture,AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_3_3"))
end


return UIShopMallBuyComfirmPanel
