------------------------------------------------
--author:
--Date: 2019-7-5
--File: UIShopMallItem.lua
--Module: UIShopMallItem
--Description: Mall interface product list subitem
------------------------------------------------
local L_Itembase = CS.Thousandto.Code.Logic.ItemBase
local UIShopMallItem = {
    Trans = nil,
    Go = nil,
    --thing
    Item = nil,
    --Item name
    NameLabel = nil,
    --price
    PriceLabel = nil,
    --currency
    PriceIcon = nil,
    --Sales empty label
    SellOutGo = nil,
    SellOutLabel = nil,
    --Limiting conditions
    LimitLabel = nil,
    --Background image
    BackSpr = nil,
    --Select
    SelectGo = nil,
    --Click to callback
    ClickCallBack = nil,
    --Product data
    ShopItemInfo = nil,
}

function UIShopMallItem:New(trans)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Item = UILuaItem:New(UIUtils.FindTrans(trans, "Item"))
    _m.NameLabel = UIUtils.FindLabel(trans, "NameLabel")
    _m.PriceLabel = UIUtils.FindLabel(trans, "Price/Label")
    _m.PriceBgGo = UIUtils.FindGo(trans, "Price/Price")
    _m.LimitLabel = UIUtils.FindLabel(trans, "Label")
    _m.SellOutGo = UIUtils.FindGo(trans, "SellOut")
    _m.SellOutLabel = UIUtils.FindLabel(trans, "SellOut")
    _m.Icon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(trans, "Price"))
    _m.SelectGo = UIUtils.FindGo(trans, "Select")
    _m.SelectSpr = UIUtils.FindSpr(trans, "Select")
    if UIUtils.FindTrans(trans, "New") then
        _m.NewGo = UIUtils.FindGo(trans, "New")
    end
    _m.Go = trans.gameObject
    _m.BackSpr = UIUtils.FindSpr(trans)
    _m.Btn = UIUtils.FindBtn(trans)
    UIUtils.AddBtnEvent(_m.Btn, _m.OnOwnClick, _m)
    return _m
end

function UIShopMallItem:Clone()
    return self:New(UnityUtils.Clone(self.Go).transform)
end

function UIShopMallItem:OnOwnClick()
    if self.ClickCallBack ~= nil then
        self.ClickCallBack(self)
    end
end

--Select
function UIShopMallItem:Select(isSelect)
    self.SelectGo:SetActive(isSelect)
    self.PriceBgGo:SetActive(not isSelect)
    if isSelect then
        UIUtils.SetColorByString(self.PriceLabel, "#202027")
        UIUtils.SetColorByString(self.LimitLabel, "#202027")
    else
        UIUtils.SetColorByString(self.PriceLabel, "#202027")
        UIUtils.SetColorByString(self.LimitLabel, "#202027")
    end
end

function UIShopMallItem:SetIsNew(isNew)
    if self.NewGo then
        if isNew then
            self.NewGo:SetActive(true)
        else
            self.NewGo:SetActive(false)
        end
    end
end

--Get the maximum purchase quantity
function UIShopMallItem:OnGetMaxNum()
    local _num = 1
    if self.ShopItemInfo.BuyLimit > 0 then
        _num = self.ShopItemInfo.BuyLimit - self.ShopItemInfo.AlreadyBuyNum
    else
        if self.ShopItemInfo.ItemInfo ~= nil then
            _num = self.ShopItemInfo.ItemInfo.ItemInfo.Max
        end
    end
    return _num;
end

--Load product specific data
function UIShopMallItem:UpdateItem(info, isNew)
    self.ShopItemInfo = info
    self:SetIsNew(isNew)
    if self.ShopItemInfo then
        self.Trans.name = string.format("%03d", info.Index)
        self.Item:InItWithCfgid(info.ItemId, info.ItemModelNum, info.BuyBind)
        if self.Item.ShowItemData then
            UIUtils.SetTextByString(self.NameLabel, self.Item.ShowItemData.Name)
            UIUtils.SetColorByQuality(self.NameLabel, self.Item.ShowItemData.Quality)
            self.NameLabel.applyGradient = self.Item.ShowItemData.Quality == 10
        else
            UIUtils.SetTextByNumber(self.NameLabel, info.ItemId)
        end
        self.Icon:UpdateIcon(LuaItemBase.GetItemIcon(info.CoinType))
        UIUtils.SetTextByNumber(self.PriceLabel, info.Price + info.AddPrice)
        self.BackSpr.IsGray = false
        self.SelectSpr.IsGray = false
        if self.SellOutGo ~= nil then
            if info.VipLv > 0 then
                self.SellOutGo:SetActive(true)
                self.BackSpr.IsGray = false
                self.SelectSpr.IsGray = false
                UIUtils.SetTextFormat(self.SellOutLabel, "VIP{0}", info.VipLv)
            else
                if info.AlreadyBuyNum >= info.BuyLimit and info.BuyLimit > 0 then
                    self.SellOutGo:SetActive(true)
                    self.BackSpr.IsGray = true
                    self.SelectSpr.IsGray = true
                    UIUtils.SetTextByEnum(self.SellOutLabel, "C_SHOP_SELLOUT")
                else
                    if info.Hot > 0 then
                        self.SellOutGo:SetActive(true)
                        self.BackSpr.IsGray = false
                        self.SelectSpr.IsGray = false
                        if info.Hot == 1 then
                            if info.Discount > 0 then
                                UIUtils.SetTextByEnum(self.SellOutLabel, "C_SHOP_DISCOUNT_NUM", Utils.GetDiscount(info.Discount))
                            else
                                self.SellOutGo:SetActive(false)
                            end
                        elseif info.Hot == 2 then
                            UIUtils.SetTextByEnum(self.SellOutLabel, "C_SERVER_STATE_RECOMMEND")
                        elseif info.Hot == 3 then
                            UIUtils.SetTextByEnum(self.SellOutLabel, "C_UI_SHOP_NEW")
                        else
                            UIUtils.SetTextByEnum(self.SellOutLabel, "C_UI_SHOP_HOT")
                        end
                    else
                        self.SellOutGo:SetActive(false)
                        self.BackSpr.IsGray = false
                        self.SelectSpr.IsGray = false
                    end
                end
            end
        end
        if info.LimitType > 0 then
            if self.LimitLabel ~= nil then
                local _str = ""
                local _buyNum = info.BuyLimit - info.AlreadyBuyNum
                if _buyNum >= 0 then
                    if info.LimitType == 1 then
                        UIUtils.SetTextByEnum(self.LimitLabel, "C_SHOP_BUYLIMIT_STRING1", _buyNum)
                    elseif info.LimitType == 2 then
                        UIUtils.SetTextByEnum(self.LimitLabel, "C_SHOP_BUYLIMIT_STRING2", _buyNum)
                    elseif info.LimitType == 3 then
                        UIUtils.SetTextByEnum(self.LimitLabel, "C_SHOP_BUYLIMIT_STRING3", _buyNum)
                    elseif info.LimitType == 4 then
                        UIUtils.SetTextByEnum(self.LimitLabel, "C_SHOP_BUYLIMIT_STRING4", _buyNum)
                    elseif info.LimitType == 5 then
                        UIUtils.SetTextByEnum(self.LimitLabel, "C_SHOP_BUYLIMIT_STRING5", _buyNum)
                    end
                end
            end
        else
            if self.LimitLabel ~= nil then
                UIUtils.ClearText(self.LimitLabel)
            end
        end
    end
end
return UIShopMallItem
