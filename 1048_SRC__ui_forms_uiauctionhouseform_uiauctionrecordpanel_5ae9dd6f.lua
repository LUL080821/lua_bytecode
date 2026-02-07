------------------------------------------------
-- author:
-- Date: 2019-10-11
-- File: UIAuctionRecordPanel.lua
-- Module: UIAuctionRecordPanel
-- Description: Bidding record interface
------------------------------------------------

local L_PopupListMenu = require "UI.Components.UIPopoupListMenu.PopupListMenu"
local L_TaxRevenue = 0
local L_RecordId = {
    SelfRecord = 1,
    SelfBuy = 2,
    SelfSell = 3,
    WorldRecord = 4,
}

-- //Module definition
local UIAuctionRecordPanel = {
    -- Current transform
    Trans = nil,
    Go = nil,
    -- father
    Parent = nil,
    -- Animation module
    AnimModule = nil,
    -- Whether to display
    IsVisible = false,
    -- menu
    PopList = nil,
    PopScrollView = nil,

    -- List
    ItemScrollView = nil,
    ItemGrid = nil,
    ItemItemRes = nil,
    ItemItemList = nil,

    CurSelectMenuID = 0,
    CurSelectType = 0,  -- 0 personal records, 1 world record

    -- [Gosu] thêm label cường hóa
    StrengthLevel = nil,   -- Strengthening level
    StrengthLevelLabel = nil,
}

local L_AHUIItem = nil

function UIAuctionRecordPanel:OnFirstShow(trans, parent, rootForm)
    self.Trans = trans
    self.Go = trans.gameObject
    self.Parent = parent
    self.RootForm = rootForm

    -- Create an animation module
    self.AnimModule = UIAnimationModule(self.Trans)
    -- Add an animation
	self.AnimModule:AddAlphaScaleAnimation(nil, 0, 1, 1.05, 1.05, 1, 1, 0.3, true, false)
    self.Go:SetActive(false)
    self.IsVisible = false

    -- Add PopoupListMenu
    self.PopList = L_PopupListMenu:CreateMenu(UIUtils.FindTrans(trans, "BtnScrll/PopoupList"), Utils.Handler(self.OnClickChildMenu,self), 3, false)
    local _selfMenu = List:New()
    _selfMenu:Add({Id = L_RecordId.SelfBuy, Name = DataConfig.DataMessageString.Get("Buy")})
    _selfMenu:Add({Id = L_RecordId.SelfSell, Name = DataConfig.DataMessageString.Get("Sell")})
    self.PopList:AddMenu(L_RecordId.SelfRecord, DataConfig.DataMessageString.Get("OPersonalRecord"), _selfMenu)
    self.PopList:AddMenu(L_RecordId.WorldRecord, DataConfig.DataMessageString.Get("WorldRecord"))
    self.PopScrollView = UIUtils.FindScrollView(trans, "BtnScrll")

    self.ItemScrollView = UIUtils.FindScrollView(trans, "ItemScrll")
    self.ItemGrid = UIUtils.FindGrid(trans, "ItemScrll/Grid")
    self.ItemItemRes = UIUtils.FindGo(trans, "ItemScrll/Grid/Item")
    self.ItemItemList = List:New()
    local _itemParent = self.ItemGrid.transform
    for i = 0, _itemParent.childCount - 1 do
        self.ItemItemList:Add(L_AHUIItem:New(_itemParent:GetChild(i), self))
    end
    local _taxCfg = DataConfig.DataGlobal[GlobalName.AuctionTax]
    L_TaxRevenue = tonumber(_taxCfg.Params) / 100
    return self
end

function UIAuctionRecordPanel:Show()
    -- Play the start-up picture
    self.AnimModule:PlayEnableAnimation()
    self.IsVisible = true
    GameCenter.Network.Send("MSG_Auction.ReqAuctionRecordList", {})
    self.PopList:OpenMenuList(L_RecordId.SelfRecord)
end

function UIAuctionRecordPanel:Hide()
    -- Play Close animation
    self.Go:SetActive(false)
    self.IsVisible = false
end

function UIAuctionRecordPanel:Update(dt)
    self.PopList:Update(dt)
end

function UIAuctionRecordPanel:OnClickChildMenu(id)
    if id <= 0 then
        return
    end
    self.CurSelectMenuID = id
    if id == L_RecordId.SelfRecord then
        self.CurSelectType = 0
        self:RefreshPanel()
    elseif id == L_RecordId.SelfBuy then
        self.CurSelectType = 0
        self:RefreshPanel()
    elseif id == L_RecordId.SelfSell then
        self.CurSelectType = 0
        self:RefreshPanel()
    elseif id == L_RecordId.WorldRecord then
        self.CurSelectType = 1
        self:RefreshPanel()
    end
end

-- Refresh the interface
function UIAuctionRecordPanel:RefreshPanel()
    local _showList = List:New()
    if self.CurSelectMenuID == L_RecordId.SelfRecord then
        local _selfList = self.Parent.SelfRecordList
        if _selfList ~= nil then
            _showList = _selfList
        end
    elseif self.CurSelectMenuID == L_RecordId.SelfBuy then
        local _selfList = self.Parent.SelfRecordList
        if _selfList ~= nil then
            local _count = #_selfList
            for i = 1, _count do
                if _selfList[i].type == 0 then
                    _showList:Add(_selfList[i])
                end
            end
        end
    elseif self.CurSelectMenuID == L_RecordId.SelfSell then
        local _selfList = self.Parent.SelfRecordList
        if _selfList ~= nil then
            local _count = #_selfList
            for i = 1, _count do
                if _selfList[i].type ~= 0 then
                    _showList:Add(_selfList[i])
                end
            end
        end
    elseif self.CurSelectMenuID == L_RecordId.WorldRecord then
        local _worldList = self.Parent.WorldRescorList
        if _worldList ~= nil then
            _showList = _worldList
        end
    end
    local _count = #self.ItemItemList
    for i = 1, _count do
        self.ItemItemList[i]:SetData(nil)
    end

    local _curTime = GameCenter.HeartSystem.ServerTime
    _count = #_showList
    for i = 1, _count do
        local _uiItem = nil
        if i < #self.ItemItemList then
            _uiItem = self.ItemItemList[i]
        else
            _uiItem = L_AHUIItem:New(UnityUtils.Clone(self.ItemItemRes).transform, self)
            self.ItemItemList:Add(_uiItem)
        end
        -- Arrange in reverse order
        _uiItem:SetData(_showList[_count - i + 1], _curTime)
    end

    self.ItemGrid:Reposition()
    self.PopScrollView.repositionWaitFrameCount = 1
    self.ItemScrollView.repositionWaitFrameCount = 2
end

L_AHUIItem = {
    RootGo = nil,
    UIItem = nil,
    BuyGo = nil,
    SellGo = nil,
    Name = nil,
    Time = nil,
    JingPaiGo = nil,
    YiKouJiaGo = nil,

    NormalPriceGo = nil,
    NormalPrice = nil,

    DePriceGo = nil,
    DeAllPrice = nil,
    DeSHPrice = nil,
    DeSRPice = nil,

    Parent = nil,

    PriceIcon = nil,
    CJPriceIcon = nil,
    SHPriceIcon = nil,
    SRPriceIcon = nil,
}

function L_AHUIItem:New(trans, parent)
    local _m = Utils.DeepCopy(self)
    _m.RootGo = trans.gameObject
    _m.Parent = parent
    _m.UIItem = UILuaItem:New(UIUtils.FindTrans(trans, "Item"))
    _m.BuyGo = UIUtils.FindGo(trans, "Buy")
    _m.SellGo = UIUtils.FindGo(trans, "Sell")
    _m.Name = UIUtils.FindLabel(trans, "Name")
    _m.Time = UIUtils.FindLabel(trans, "Time")
    _m.JingPaiGo = UIUtils.FindGo(trans, "JPPrice")
    _m.YiKouJiaGo = UIUtils.FindGo(trans, "MaxPrice")
    _m.NormalPriceGo = UIUtils.FindGo(trans, "Price")
    _m.NormalPrice = UIUtils.FindLabel(trans, "Price/Label")
    _m.DePriceGo = UIUtils.FindGo(trans, "DetPrice")
    _m.DeAllPrice = UIUtils.FindLabel(trans, "DetPrice/CJPrice/Value")
    _m.DeSHPrice = UIUtils.FindLabel(trans, "DetPrice/SHPrice/Value")
    _m.DeSRPice = UIUtils.FindLabel(trans, "DetPrice/SRPrice/Value")
    _m.PriceIcon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(trans, "Price"))
    _m.CJPriceIcon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(trans, "DetPrice/CJPrice"))
    _m.SHPriceIcon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(trans, "DetPrice/SHPrice"))
    _m.SRPriceIcon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(trans, "DetPrice/SRPrice"))

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

function L_AHUIItem:SetData(msgItem, curTime)
    if msgItem == nil then
        self.RootGo:SetActive(false)
    else
        self.RootGo:SetActive(true)

        local itemInst = self:BuildItemInstByRecordDetail(msgItem)
        if itemInst then
            self.UIItem:InitWithItemData(
                itemInst,
                msgItem.num,
                true,
                false,
                ItemTipsLocation.Market,
                {
                    itemId = itemInst.ItemID,
                    from = "AuctionRecord"
                }
            )
        else
            self.UIItem:InItWithCfgid(msgItem.itemModelId, msgItem.num, msgItem.isbind, false)
        end
        
        local _coinIcon = 0
        local _equipCfg = DataConfig.DataEquip[msgItem.itemId]
        local _itemCfg = DataConfig.DataItem[msgItem.itemId]
        local _priceType = 0
        if _equipCfg ~= nil then
            UIUtils.SetTextFormat(self.Name, "[{0}]{1}",  Utils.GetQualityStrColor(_equipCfg.Quality),  _equipCfg.Name)
            _coinIcon = DataConfig.DataItem[_equipCfg.AuctionUseCoin].Icon
        elseif _itemCfg ~= nil then
            UIUtils.SetTextFormat(self.Name, "[{0}]{1}",  Utils.GetQualityStrColor(_itemCfg.Color),  _itemCfg.Name)
            _coinIcon = DataConfig.DataItem[_itemCfg.AuctionUseCoin].Icon
        end
        self.PriceIcon:UpdateIcon(_coinIcon)
        self.CJPriceIcon:UpdateIcon(_coinIcon)
        self.SHPriceIcon:UpdateIcon(_coinIcon)
        self.SRPriceIcon:UpdateIcon(_coinIcon)

        if self.Parent.CurSelectType == 0 then
            -- Personal records
            self.BuyGo:SetActive(msgItem.type == 0)
            self.SellGo:SetActive(msgItem.type ~= 0)

            if msgItem.type ~= 0 then
                self.NormalPriceGo:SetActive(false)
                self.DePriceGo:SetActive(true)
                local _tax = math.floor(msgItem.price * L_TaxRevenue)
                if _tax < 1 then
                    _tax = 1
                end
                UIUtils.SetTextByNumber(self.DeAllPrice, msgItem.price)
                UIUtils.SetTextByNumber(self.DeSHPrice, _tax)
                UIUtils.SetTextByNumber(self.DeSRPice, msgItem.price - _tax)
            else
                self.NormalPriceGo:SetActive(true)
                self.DePriceGo:SetActive(false)
                UIUtils.SetTextByNumber(self.NormalPrice, msgItem.price)
            end
        else
            -- World Records
            self.BuyGo:SetActive(true)
            self.SellGo:SetActive(false)
            self.NormalPriceGo:SetActive(true)
            self.DePriceGo:SetActive(false)
            UIUtils.SetTextByNumber(self.NormalPrice, msgItem.price)
        end

        local _timeValue = curTime - msgItem.time
        if _timeValue > 86400 then
            UIUtils.SetTextByEnum(self.Time, "C_GUILD_STATE_OUTLINE_HOUR2", math.floor(_timeValue // 86400))
        elseif _timeValue > 3600 then
            UIUtils.SetTextByEnum(self.Time, "C_GUILD_STATE_OUTLINE_HOUR1", math.floor(_timeValue // 3600))
        elseif _timeValue > 60 then
            UIUtils.SetTextByEnum(self.Time, "C_GUILD_STATE_OUTLINE_HOUR", math.floor(_timeValue // 60))
        else
            UIUtils.SetTextByEnum(self.Time, "InOneMinute")
        end

        -- [Gosu] check hiển thị label cường hóa
        local lv = msgItem.detail.strengthInfo.level
        if self.StrengthLevel then
            self.StrengthLevel:SetActive(lv > 0)
            if self.StrengthLevelLabel then
                UIUtils.SetTextByString(self.StrengthLevelLabel, "+" .. lv)
            end
        end
        -- TODO: kiểm tra thêm tại sao lúc không có đồ bên list đấu giá thì list lịch sử không hiện thông tin
    end
end

function L_AHUIItem:BuildItemInstByRecordDetail(msgItem)

    local equipWrapper = msgItem.detail
    if not equipWrapper then
        Debug.Log("[AuctionRecord] equipListDetail empty, index =", Inspect(msgItem))
        return nil
    end

    local equipDetail = equipWrapper.equip
    if not equipDetail then
        Debug.Log("[AuctionRecord] equip detail missing at index =", Inspect(msgItem))
        return nil
    end

    local buildMsg = {
        itemId      = equipDetail.itemId,
        itemModelId = equipDetail.itemModelId,
        num         = msgItem.num or 1,
        gridId      = 0,
        isbind      = msgItem.isbind or false,
        lostTime    = equipDetail.lostTime or 0,

        suitId      = equipDetail.suitId or 0,
        percent     = equipDetail.percent or 0,
    }

    if equipWrapper.strengthInfo then
        buildMsg.strengLv = equipWrapper.strengthInfo.level or 0
    end

    Debug.Log("[AuctionRecord] BuildItemMsg =", Inspect(buildMsg))

    local itemInst = LuaItemBase.CreateItemBaseByMsg(buildMsg)
    if not itemInst then
        Debug.Log("[AuctionRecord] CreateItemBaseByMsg FAILED")
        return nil
    end

    Debug.Log(string.format(
        "[AuctionRecord] Create Item OK cfg=%d itemId=%d streng=%d",
        itemInst.CfgID,
        itemInst.ItemID or -1,
        itemInst.StrengthLevel or 0
    ))

    return itemInst
end

return UIAuctionRecordPanel
