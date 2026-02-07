------------------------------------------------
-- author:
-- Date: 2021-03-17
-- File: UIAuctionItemMiMaBuyPanel.lua
-- Module: UIAuctionItemMiMaBuyPanel
-- Description: Auction house password purchase paging
------------------------------------------------

-- //Module definition
local UIAuctionItemMiMaBuyPanel = {
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
    CostIcon = nil,

    -- commodity
    AHItem = nil,

    -- Password input box
    MiMaInputGo = nil,
    MiMaBtns = nil,
    MiMaDelBtn = nil,
    MiMaOkBtn = nil,
    MiMaLabel = nil,
    CurInputMiMa = nil,
}

function UIAuctionItemMiMaBuyPanel:OnFirstShow(trans, parent, rootForm)
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
    self.CostIcon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(trans, "MaxPrice/Icon"))

    self.MiMaInputGo = UIUtils.FindGo(trans, "MiMaInPut")
    self.MiMaBtns = {}
    for i = 1, 10 do
        self.MiMaBtns[i] = UIUtils.FindBtn(trans, string.format("MiMaInPut/%d", i - 1))
        UIUtils.AddBtnEvent(self.MiMaBtns[i], self.OnNumberClick, self, i - 1)
    end
    self.MiMaDelBtn = UIUtils.FindBtn(trans, "MiMaInPut/Del")
    UIUtils.AddBtnEvent(self.MiMaDelBtn, self.OnMiMaDelBtnClick, self)
    self.MiMaOkBtn = UIUtils.FindBtn(trans, "MiMaInPut/OK")
    UIUtils.AddBtnEvent(self.MiMaOkBtn, self.OnOkBtnClick, self)
    self.MiMaLabel = UIUtils.FindLabel(trans, "MiMaInPut/MiMa/Value")
    return self
end

function UIAuctionItemMiMaBuyPanel:Show(ahItemInfo)
    -- Play the start-up picture
    self.AnimModule:PlayEnableAnimation()
    self.AHItem = ahItemInfo
    self.AHItem.IsLocked = true
    self.RootForm.CSForm:LoadTexture(self.BackTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_3_1"))
    
    self.UIItem:InitWithItemData(ahItemInfo.ItemInst, nil, nil, false, nil, nil)
    UIUtils.SetTextFormat(self.Name, "[{0}]{1}",  Utils.GetQualityStrColor(ahItemInfo.ItemInst.Quality),  ahItemInfo.ItemInst.Name)
    UIUtils.SetTextByNumber(self.Count, ahItemInfo.ItemInst.Count)
    UIUtils.SetTextByNumber(self.MaxPrice, ahItemInfo.CurPrice)
    self.CostIcon:UpdateIcon(ahItemInfo.UseCoinCfg.Icon)
    self.CurInputMiMa = ""
    if ahItemInfo.HasMiMa then
        self.MiMaInputGo:SetActive(true)
        self:RefreshMiMa()
    else
        self.MiMaInputGo:SetActive(false)
    end
    self.IsVisible = true
end

function UIAuctionItemMiMaBuyPanel:Hide()
    -- Play Close animation
    self.AnimModule:PlayDisableAnimation()
    if self.AHItem ~= nil then
        self.AHItem.IsLocked = false
    end
    self.IsVisible = false
end

function UIAuctionItemMiMaBuyPanel:OnNumberClick(num)
    if string.len(self.CurInputMiMa) >= 6 then
        return
    end
    self.CurInputMiMa = self.CurInputMiMa .. num
    self:RefreshMiMa()
end

function UIAuctionItemMiMaBuyPanel:OnMiMaDelBtnClick()
    local _len = string.len(self.CurInputMiMa)
    if _len <= 0 then
        return
    end
    self.CurInputMiMa = string.sub(self.CurInputMiMa, 1, _len - 1)
    self:RefreshMiMa()
end

function UIAuctionItemMiMaBuyPanel:RefreshMiMa()
    if self.CurInputMiMa == nil or string.len(self.CurInputMiMa) <= 0 then
        UIUtils.SetTextByEnum(self.MiMaLabel, "C_AUCTION_INPUT_MIMA")
    else
        UIUtils.SetTextByString(self.MiMaLabel, self.CurInputMiMa)
    end
end

function UIAuctionItemMiMaBuyPanel:OnCloseBtnClick()
    self:Hide()
end

function UIAuctionItemMiMaBuyPanel:OnOkBtnClick()
    if self.AHItem.HasMiMa then
        if self.CurInputMiMa == nil or string.len(self.CurInputMiMa) ~= 6 then
            Utils.ShowPromptByEnum("C_AUCTION_BUY_MIMA_ERROR")
            return
        end
    end
    if GameCenter.GameSceneSystem:GetLocalPlayerID() == self.AHItem.OwnerID then
        Utils.ShowPromptByEnum("C_AUTION_CANNOTBUY_SELF")
        return
    end

    local _curMoney = GameCenter.ItemContianerSystem:GetEconomyWithType(self.AHItem.UseCoinCfg.Id)
    if _curMoney < self.AHItem.CurPrice then
        Utils.ShowPromptByEnum("LingshiNotEnough", self.AHItem.UseCoinCfg.Name)
        return;
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
                GameCenter.Network.Send("MSG_Auction.ReqAuctionInfoPur", {auctionId = self.AHItem.ID, password = self.CurInputMiMa})
                self:Hide()
            end
        end, "GiveUpToBuy", "InsistOnBuying", "BuyTips", self.AHItem.ItemInst.Name)
    else
        GameCenter.Network.Send("MSG_Auction.ReqAuctionInfoPur", {auctionId = self.AHItem.ID, password = self.CurInputMiMa})
        self:Hide()
    end
end

return UIAuctionItemMiMaBuyPanel
