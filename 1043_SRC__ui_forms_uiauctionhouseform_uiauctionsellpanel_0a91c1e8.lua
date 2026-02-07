------------------------------------------------
-- author:
-- Date: 2019-10-10
-- File: UIAuctionSellPanel.lua
-- Module: UIAuctionSellPanel
-- Description: Auction house for sale paging
------------------------------------------------

local UIAuctionSellTipsPanel = require "UI.Forms.UIAuctionHouseForm.UIAuctionSellTipsPanel"
local L_UIListMenu = require "UI.Components.UIListMenu.UIListMenu"

-- //Module definition
local UIAuctionSellPanel = {
    -- Current transform
    Trans = nil,
    Go = nil,
    -- father
    Parent = nil,
    -- Animation module
    AnimModule = nil,

    -- Top Menu
    ListMenu = nil,

    BagScroll = nil,
    BagGird = nil,
    BagItemRes = nil,
    BagItemList = nil,

    ItemScroll = nil,
    ItemGrid = nil,
    ItemItemRes = nil,
    ItemItemList = nil,
    TipsPanel = nil,
    -- The number of current listings
    CurUPCount = 0,
    -- The currently selected page
    SelectPanelID = 0,

    -- [Gosu] thêm label cường hóa
    StrengthLevel = nil,   -- Strengthening level
    StrengthLevelLabel = nil,
}

local L_AHItemUI = nil

function UIAuctionSellPanel:OnFirstShow(trans, parent, rootForm)
    self.Trans = trans;
    self.Go = trans.gameObject
    self.Parent = parent;
    self.RootForm = rootForm;

    -- Create an animation module
    self.AnimModule = UIAnimationModule(self.Trans)
    -- Add an animation
	self.AnimModule:AddAlphaScaleAnimation(nil, 0, 1, 1.05, 1.05, 1, 1, 0.3, true, false)
    self.Go:SetActive(false);
    self.IsVisible = false

    self.ListMenu = L_UIListMenu:OnFirstShow(self.RootForm.CSForm, UIUtils.FindTrans(trans, "UIListMenuTop"))

    self.ListMenu:ClearSelectEvent();
    self.ListMenu:AddSelectEvent(Utils.Handler(self.OnMenuSelect, self))
    self.ListMenu:AddIcon(0, DataConfig.DataMessageString.Get("BackBag"))
    --self.ListMenu:AddIcon(1, DataConfig.DataMessageString.Get("ShenZhuang"))
    --self.ListMenu:AddIcon(2, DataConfig.DataMessageString.Get("C_UNREAL_EQUIP"))

    self.BagScroll = UIUtils.FindScrollView(trans, "BagScroll")
    self.BagGird = UIUtils.FindGrid(trans, "BagScroll/Grid")
    self.BagItemList = List:New()
    local _parentTrans = self.BagGird.transform
    self.BagItemRes = nil
    for i = 0, _parentTrans.childCount - 1 do
        local _item = UILuaItem:New(_parentTrans:GetChild(i))
        _item.IsShowTips = false
        _item.SingleClick = Utils.Handler(self.OnBagItemClick, self)
        self.BagItemList:Add(_item)
        if self.BagItemRes == nil then
            self.BagItemRes = _item.RootGO
        end
    end
  
    self.ItemScroll = UIUtils.FindScrollView(trans, "ItemScroll")
    self.ItemGrid = UIUtils.FindGrid(trans, "ItemScroll/Grid")
    self.ItemItemRes = UIUtils.FindGo(trans, "ItemScroll/Grid/Item")
    self.ItemItemList = List:New()
    _parentTrans = self.ItemGrid.transform
    for i = 0, _parentTrans.childCount - 1 do
        self.ItemItemList:Add(L_AHItemUI:New(_parentTrans:GetChild(i), self))
    end

    self.TipsPanel = UIAuctionSellTipsPanel:OnFirstShow(UIUtils.FindTrans(trans, "SellTipsPanel"), self, rootForm)

    return self
end

function UIAuctionSellPanel:Show(sellId)
    -- Play the start-up picture
    self.AnimModule:PlayEnableAnimation()
    self.IsVisible = true

    if GameCenter.HolyEquipSystem:GetEquipByDBID(sellId) ~= nil then
        --self.ListMenu:SetSelectById(1)
    else
        self.ListMenu:SetSelectById(0)
    end
    if sellId ~= nil then
        for i = 1, #self.BagItemList do
            if self.BagItemList[i].RootGO.activeSelf then
                if self.BagItemList[i].ShowItemData ~= nil and self.BagItemList[i].ShowItemData.DBID == sellId then
                    self.TipsPanel:Show(self.BagItemList[i].ShowItemData, true)
                    break
                end
            end
        end
    end
end

function UIAuctionSellPanel:Hide()
    -- Play Close animation
    self.Go:SetActive(false);
    self.ListMenu:SetSelectByIndex(-1)
    self.IsVisible = false
end

function UIAuctionSellPanel:OnTryHide()
    if self.TipsPanel.IsVisible then
        self.TipsPanel:Hide()
        return false
    end
    return true
end

-- Menu Select Events
function UIAuctionSellPanel:OnMenuSelect(id, b)
    if b then
        self.SelectPanelID = id
        if id == 0 or id == 1 or id == 2 then
            self:RefreshPaghe(true)
        end
    end
end

-- Refresh the interface
function UIAuctionSellPanel:RefreshPaghe(closeTips, reposBag)
    if closeTips then
        self.TipsPanel:Hide()
    end
    local _bagList = nil
    if self.SelectPanelID == 0 then
        _bagList = GameCenter.AuctionHouseSystem:GetCanSellItems(false)
    elseif self.SelectPanelID == 1 then
        _bagList = GameCenter.AuctionHouseSystem:GetCanSellHolyEquips()
    elseif self.SelectPanelID == 2 then
        _bagList = GameCenter.AuctionHouseSystem:GetCanSellUnrealEquips()
    end
    local _bagTableList = _bagList

    local _itemCount = #_bagTableList
    for i = 1, _itemCount do
        local _uiItem = nil
        local _itemData = _bagTableList[i]
        if i <= #self.BagItemList then
            _uiItem = self.BagItemList[i]
        else
            _uiItem = UILuaItem:New(UnityUtils.Clone(self.BagItemRes).transform)
            _uiItem.IsShowTips = false
            _uiItem.SingleClick = Utils.Handler(self.OnBagItemClick, self)
            self.BagItemList:Add(_uiItem)
        end
        _uiItem.RootGO:SetActive(true)
        UIUtils.SetGameObjectNameByNumber(_uiItem.RootGO, _itemData.CfgID)
        _uiItem:InitWithItemData(_itemData, nil, nil, false, nil, nil)
    end

    local _allCellCount = 0
    if _itemCount < 24 then
        _allCellCount = 24
    else
        if _itemCount % 4 == 0 then
            _allCellCount = _itemCount
        else
            _allCellCount = (_itemCount // 4 + 1) * 4
        end
    end
    for i = _itemCount + 1, _allCellCount do
        if i > #self.BagItemList then
            local _uiItem = UILuaItem:New(UnityUtils.Clone(self.BagItemRes).transform)
            _uiItem.IsShowTips = false
            _uiItem.SingleClick = Utils.Handler(self.OnBagItemClick, self)
            _uiItem.RootGO:SetActive(true)
            self.BagItemList:Add(_uiItem)
        end
    end

    for i = _itemCount + 1,  #self.BagItemList do
        self.BagItemList[i]:InitWithItemData(nil)
        UIUtils.SetGameObjectNameByNumber(self.BagItemList[i].RootGO, 0)
    end

    local _ahTableList = GameCenter.AuctionHouseSystem:GetSelfSellItems()
    _itemCount = #self.ItemItemList
    for i = 1, _itemCount do
        self.ItemItemList[i]:SetData(nil)
    end

    _itemCount = #_ahTableList
    self.CurUPCount = _itemCount
    for i = 1, _itemCount do
        local _uiItem = nil
        if i <= #self.ItemItemList then
            _uiItem = self.ItemItemList[i]
        else
            _uiItem = L_AHItemUI:New(UnityUtils.Clone(self.ItemItemRes).transform, self)
            self.ItemItemList:Add(_uiItem)
        end
        _uiItem.RootGo:SetActive(true)
        _uiItem:SetData(_ahTableList[i])
    end

    self.BagGird:Reposition()
    if reposBag == nil or reposBag == true then
        self.BagScroll.repositionWaitFrameCount = 2
    end

    self.ItemGrid:Reposition()
    self.ItemScroll.repositionWaitFrameCount = 2
end

-- Backpack items click
function UIAuctionSellPanel:OnBagItemClick(uiItem)
    if uiItem.ShowItemData ~= nil then
        self.TipsPanel:Show(uiItem.ShowItemData, true)
    end
end

-- Items already on the shelves
L_AHItemUI = {
    -- Root node
    RootGo = nil,
    -- Button
    Btn = nil,
    -- thing
    UIItem = nil,
    -- name
    NameLabel = nil,
    -- Current Price
    CurPriceGo = nil,
    CurPriceLabel = nil,
    -- Maximum price
    MaxPriceGo = nil,
    MaxPriceLabel = nil,
    -- Immortal Alliance Mark
    GuildFlag = nil,
    -- World Mark
    WorldFlag = nil,

    -- Item Example
    ItemInst = nil,
    -- Parent node
    Parent = nil,

    MiMaGo = nil,
    MiMaPrice = nil,

    CurPriceIcon = nil,
    MaxPriceIcon = nil,
    MiMaPriceIcon = nil,
}

function L_AHItemUI:New(trans, parent)
    local _m = Utils.DeepCopy(self)
    _m.Parent = parent
    _m.RootGo = trans.gameObject
    _m.Btn = UIUtils.FindBtn(trans)
    UIUtils.AddBtnEvent(_m.Btn, _m.OnBtnClick, _m)
    _m.UIItem = UILuaItem:New(UIUtils.FindTrans(trans, "UIItem"))
    _m.UIItem.IsShowTips = false
    _m.UIItem.SingleClick = Utils.Handler(_m.OnItemClick, _m)
    _m.NameLabel = UIUtils.FindLabel(trans, "NameLabel");
    _m.CurPriceGo = UIUtils.FindGo(trans, "CurPrice");
    _m.CurPriceLabel = UIUtils.FindLabel(trans, "CurPrice/NumLabel");
    _m.MaxPriceGo = UIUtils.FindGo(trans, "MaxPrice");
    _m.MaxPriceLabel = UIUtils.FindLabel(trans, "MaxPrice/NumLabel");
    _m.GuildFlag = UIUtils.FindGo(trans, "Guild");
    _m.WorldFlag = UIUtils.FindGo(trans, "World");
    _m.MiMaGo = UIUtils.FindGo(trans, "MiMaPrice");
    _m.MiMaPrice = UIUtils.FindLabel(trans, "MiMaPrice/NumLabel");
    _m.CurPriceIcon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(trans, "CurPrice/Icon"))
    _m.MaxPriceIcon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(trans, "MaxPrice/Icon"))
    _m.MiMaPriceIcon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(trans, "MiMaPrice/Icon"))

    -- [Gosu] lấy thông tin cường hóa vật phẩm trong túi
    local intensify = UIUtils.FindTrans(trans, "Intensify")
    if intensify then
        _m.StrengthLevel = intensify.gameObject
        _m.StrengthLevelLabel = UIUtils.FindLabel(intensify, "")
    else
        Debug.LogError("UIAuctionItemUI: Intensify not found")
    end
    return _m
end

function L_AHItemUI:SetData(itemInst)
    self.ItemInst = itemInst
    if itemInst == nil then
        self.RootGo:SetActive(false)
    else
        self.RootGo:SetActive(true)
        self.UIItem:InitWithItemData(itemInst.ItemInst, nil, nil, false, nil, nil)
        UIUtils.SetTextFormat(self.NameLabel, "[{0}]{1}",  Utils.GetQualityStrColor(itemInst.ItemInst.Quality),  itemInst.ItemInst.Name)

        local _coinIcon = itemInst.UseCoinCfg.Icon
        self.CurPriceIcon:UpdateIcon(_coinIcon)
        self.MaxPriceIcon:UpdateIcon(_coinIcon)
        self.MiMaPriceIcon:UpdateIcon(_coinIcon)

        if itemInst.HasMiMa then
            self.CurPriceGo:SetActive(false)
            self.MaxPriceGo:SetActive(false)
            self.MiMaGo:SetActive(true)
            UIUtils.SetTextByNumber(self.MiMaPrice, itemInst.CurPrice)
        else
            if itemInst.UsePriceType == 1 then
                self.CurPriceGo:SetActive(false)
                self.MaxPriceGo:SetActive(true)
                self.MiMaGo:SetActive(false)
                UIUtils.SetTextByNumber(self.MaxPriceLabel, itemInst.CurPrice)
            else
                self.CurPriceGo:SetActive(true)
                self.MaxPriceGo:SetActive(true)
                self.MiMaGo:SetActive(false)
                if itemInst.SinglePrice <= 0 then
                    -- A single added value of 0 means that the bid cannot be made
                    UIUtils.SetTextByEnum(self.CurPriceLabel, "NULL")
                else
                    UIUtils.SetTextByNumber(self.CurPriceLabel, itemInst.CurPrice)
                end
        
                if itemInst.MaxPrice <= 0 then
                    -- The maximum value is less than 0 means that the price cannot be paid in one go
                    UIUtils.SetTextByEnum(self.MaxPriceLabel, "NULL")
                else
                    UIUtils.SetTextByNumber(self.MaxPriceLabel, itemInst.MaxPrice)
                end
            end
        end
        self.GuildFlag:SetActive(itemInst.OwnerGuild > 0)
        self.WorldFlag:SetActive(itemInst.OwnerGuild <= 0)

        -- [Gosu] check hiển thị label cường hóa
        local lv = self.ItemInst.Detail.strengthInfo.level
        if self.StrengthLevel then
            self.StrengthLevel:SetActive(lv > 0)
            if self.StrengthLevelLabel then
                UIUtils.SetTextByString(self.StrengthLevelLabel, "+" .. lv)
            end
        end
    end
end

function L_AHItemUI:OnBtnClick()
    -- Open the removal interface
    self.Parent.TipsPanel:Show(self.ItemInst, false)
end

function L_AHItemUI:OnItemClick(uiItem)
    self:OnBtnClick()
end

return UIAuctionSellPanel;
