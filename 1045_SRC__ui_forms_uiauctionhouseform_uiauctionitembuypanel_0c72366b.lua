------------------------------------------------
-- author:
-- Date: 2019-10-10
-- File: UIAuctionItemBuyPanel.lua
-- Module: UIAuctionItemBuyPanel
-- Description: Auction house purchase paging
------------------------------------------------

-- //Module definition
local UIAuctionItemBuyPanel = {
    -- Current transform
    Trans = nil,
    -- father
    Parent = nil,
    -- Animation module
    AnimModule = nil,

    -- Close button
    CloseBtn = nil,
    -- thing
    UIItem = nil,
    -- name
    Name = nil,
    -- Background picture
    BackTex = nil,
    -- OK button
    OkBtn = nil,
    -- Cancel button
    CanelBtn = nil,
    -- quantity
    Count = nil,
    -- price
    MaxPrice = nil,
    MaxPriceIcon = nil,
    -- commodity
    AHItem = nil,
}

function UIAuctionItemBuyPanel:OnFirstShow(trans, parent, rootForm)
    self.Trans = trans
    self.Parent = parent
    self.RootForm = rootForm

    -- Create an animation module
    self.AnimModule = UIAnimationModule(self.Trans)
    -- Add an animation
    self.AnimModule:AddNormalAnimation(0.3)
    self.Trans.gameObject:SetActive(false)
    self.IsVisible = false
    self.CloseBtn = UIUtils.FindBtn(trans, "CloseBtn")
    UIUtils.AddBtnEvent(self.CloseBtn, self.OnCloseBtnClick, self)
    self.UIItem = UILuaItem:New(UIUtils.FindTrans(trans, "UIItem"))
    self.Name = UIUtils.FindLabel(trans, "Name")
    self.BackTex = UIUtils.FindTex(trans, "BackTex")
    self.OkBtn = UIUtils.FindBtn(trans, "OkBtn")
    UIUtils.AddBtnEvent(self.OkBtn, self.OnOkBtnClick, self)
    self.CanelBtn = UIUtils.FindBtn(trans, "NoBtn")
    UIUtils.AddBtnEvent(self.CanelBtn, self.OnCloseBtnClick, self)
    self.Count = UIUtils.FindLabel(trans, "Count/Value")
    self.MaxPrice = UIUtils.FindLabel(trans, "MaxPrice/Value")
    self.MaxPriceIcon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(trans, "MaxPrice/Icon"))
    return self
end

function UIAuctionItemBuyPanel:Show(ahItemInfo)
    -- Play the start-up picture
    self.AnimModule:PlayEnableAnimation()
    self.AHItem = ahItemInfo
    self.AHItem.IsLocked = true
    self.RootForm.CSForm:LoadTexture(self.BackTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_3"))
    
    self.UIItem:InitWithItemData(ahItemInfo.ItemInst, nil, nil, false, nil, nil)
    UIUtils.SetTextFormat(self.Name, "[{0}]{1}",  Utils.GetQualityStrColor(ahItemInfo.ItemInst.Quality),  ahItemInfo.ItemInst.Name)
    UIUtils.SetTextByNumber(self.Count, ahItemInfo.ItemInst.Count)
    if ahItemInfo.UsePriceType == 1 then
        UIUtils.SetTextByNumber(self.MaxPrice, ahItemInfo.CurPrice)
    else
        UIUtils.SetTextByNumber(self.MaxPrice, ahItemInfo.MaxPrice)
    end
    self.MaxPriceIcon:UpdateIcon(ahItemInfo.UseCoinCfg.Icon)
    self.IsVisible = true
end

function UIAuctionItemBuyPanel:Hide()
    -- Play Close animation
    self.AnimModule:PlayDisableAnimation()
    if self.AHItem ~= nil then
        self.AHItem.IsLocked = false
    end
    self.IsVisible = false
end

function UIAuctionItemBuyPanel:OnCloseBtnClick()
    self:Hide()
end

function UIAuctionItemBuyPanel:OnOkBtnClick()
    if GameCenter.GameSceneSystem:GetLocalPlayerID() == self.AHItem.OwnerID then
        Utils.ShowPromptByEnum("C_AUTION_CANNOTBUY_SELF")
        return
    end
    local _price = self.AHItem.MaxPrice
    if self.AHItem.UsePriceType == 1 then
        _price = self.AHItem.CurPrice
    end
    local _curMoney = GameCenter.ItemContianerSystem:GetEconomyWithType(self.AHItem.UseCoinCfg.Id)
    if _curMoney < _price then
        Utils.ShowPromptByEnum("LingshiNotEnough", self.AHItem.UseCoinCfg.Name)
        return;
    end
    local _showMsgBox = false
    local _equipCfg = DataConfig.DataEquip[self.AHItem.ItemInst.CfgID]
    if _equipCfg ~= nil then
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if string.find(_equipCfg.Gender, tostring(_lp.IntOcc)) == nil and string.find(_equipCfg.Gender, "9") == nil then
            _showMsgBox = true
        end
    end

    if _showMsgBox then
        Utils.ShowMsgBoxAndBtn(function (code)
            if (code == MsgBoxResultCode.Button2) then
                GameCenter.Network.Send("MSG_Auction.ReqAuctionInfoPur", {auctionId = self.AHItem.ID})
                self:Hide()
            end
        end, "GiveUpToBuy", "InsistOnBuying", "BuyTips", self.AHItem.ItemInst.Name)
    else
        GameCenter.Network.Send("MSG_Auction.ReqAuctionInfoPur", {auctionId = self.AHItem.ID})
        self:Hide()
    end
end

return UIAuctionItemBuyPanel
