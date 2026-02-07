------------------------------------------------
-- author:
-- Date: 2019-10-10
-- File: UIAuctionItemJingJiaPanel.lua
-- Module: UIAuctionItemJingJiaPanel
-- Description: Auction house bidding interface
------------------------------------------------

-- //Module definition
local UIAuctionItemJingJiaPanel = {
    -- Current transform
    Trans = nil,
    -- father
    Parent = nil,
    -- Animation module
    AnimModule = nil,
    -- Whether to display
    IsVisible = false,

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
    -- Current Price
    CurPrice = nil,
    -- Price increase amount
    AddPrice = nil,
    -- price
    OutPrice = nil,

    -- Product ID
    AHItemID = 0,
    -- commodity
    AHItem = nil,
    -- Bid price
    OutPriceValue = 0,

    CurPriceIcon = nil,
    AddPriceIcon = nil,
    OutPriceIcon = nil,
}

function UIAuctionItemJingJiaPanel:OnFirstShow(trans, parent, rootForm)
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
    self.CurPrice = UIUtils.FindLabel(trans, "CurPrice/Value")
    self.AddPrice = UIUtils.FindLabel(trans, "AddPrice/Value")
    self.OutPrice = UIUtils.FindLabel(trans, "OutPice/Value")
    self.CurPriceIcon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(trans, "CurPrice/Icon"))
    self.AddPriceIcon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(trans, "AddPrice/Icon"))
    self.OutPriceIcon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(trans, "OutPice/Icon"))
    return self
end

function UIAuctionItemJingJiaPanel:Show(ahItemInfo)
    -- Play the start-up picture
    self.AnimModule:PlayEnableAnimation()
    self:RefreshPanel(ahItemInfo)
    self.IsVisible = true
end

function UIAuctionItemJingJiaPanel:Hide()
    -- Play Close animation
    self.AnimModule:PlayDisableAnimation()
    if self.AHItem ~= nil then
        self.AHItem.IsLocked = false
    end
    self.IsVisible = false
end

function UIAuctionItemJingJiaPanel:RefreshPanel(ahItemInfo)
    self.AHItem = ahItemInfo
    self.AHItem.IsLocked = true
    self.AHItemID = ahItemInfo.ID
    self.RootForm.CSForm:LoadTexture(self.BackTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_3"))
    
    self.UIItem:InitWithItemData(ahItemInfo.ItemInst, nil, nil, false, nil, nil)
    UIUtils.SetTextFormat(self.Name, "[{0}]{1}",  Utils.GetQualityStrColor(ahItemInfo.ItemInst.Quality),  ahItemInfo.ItemInst.Name)
    local _coinIcon = ahItemInfo.UseCoinCfg.Icon
    self.CurPriceIcon:UpdateIcon(_coinIcon)
    self.AddPriceIcon:UpdateIcon(_coinIcon)
    self.OutPriceIcon:UpdateIcon(_coinIcon)
    local _curPrice = ahItemInfo.CurPrice
    local _addPrice = ahItemInfo.SinglePrice
    if ahItemInfo.SinglePriceType ~= 0 then
        _addPrice = math.floor(_addPrice / ahItemInfo.ItemInst.Count / 10000 * _curPrice)
    end
    if ahItemInfo.CurPriceOwner <= 0 then
        -- No one is currently bidding, the price increase is 0
        _addPrice = 0
    end
    self.OutPriceValue = _curPrice + _addPrice
    local _maxPrice = ahItemInfo.MaxPrice
    if _maxPrice > 0 and self.OutPriceValue > _maxPrice then
        self.OutPriceValue = _maxPrice
    end
    UIUtils.SetTextByNumber(self.CurPrice, _curPrice)
    UIUtils.SetTextByNumber(self.AddPrice, _addPrice)
    UIUtils.SetTextByNumber(self.OutPrice, self.OutPriceValue)
end

function UIAuctionItemJingJiaPanel:OnCloseBtnClick()
    self:Hide()
end

function UIAuctionItemJingJiaPanel:OnOkBtnClick()
    if GameCenter.GameSceneSystem:GetLocalPlayerID() == self.AHItem.OwnerID then
        Utils.ShowPromptByEnum("C_AUTION_CANNOTBUY_SELF")
        return
    end
    local _curMoney = GameCenter.ItemContianerSystem:GetEconomyWithType(self.AHItem.UseCoinCfg.Id)
    if _curMoney < self.OutPriceValue then
        Utils.ShowPromptByEnum("NotAuctionThisGoods", self.AHItem.UseCoinCfg.Name)
        return
    end
    if self.AHItem.ID == 0 then
        -- The product ID is 0, which means it is a fake item. Send the purchase message directly.
        GameCenter.Network.Send("MSG_Auction.ReqAuctionInfoPur", {auctionId = self.AHItem.ID})
        return
    end
    local _showMsgBox = false
    local _equipCfg = DataConfig.DataEquip[self.AHItem.ItemInst.CfgID]
    if _equipCfg ~= nil then
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if string.find(_equipCfg.Gender, tostring(_lp.IntOcc)) == nil and string.find(_equipCfg.Gender, "9") == nil  then
            _showMsgBox = true
        end
    end

    if _showMsgBox then
        Utils.ShowMsgBoxAndBtn(function (code)
            if (code == MsgBoxResultCode.Button2) then
                GameCenter.Network.Send("MSG_Auction.ReqAuctionInfo", {auctionId = self.AHItem.ID, price = self.OutPriceValue})
            end
        end, "GiveUpBidding", "AdhereBidding", "AuctionTips", self.AHItem.ItemInst.Name)
    else
        GameCenter.Network.Send("MSG_Auction.ReqAuctionInfo", {auctionId = self.AHItem.ID, price = self.OutPriceValue})
    end
end

return UIAuctionItemJingJiaPanel
