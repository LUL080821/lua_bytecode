------------------------------------------------
-- author:
-- Date: 2020-04-21
-- File: UIGetAuctionItemTIps.lua
-- Module: UIGetAuctionItemTIps
-- Description: Quick launch interface
------------------------------------------------

local UIGetAuctionItemTIps = {
    CloseBtn = nil,
    BackTex = nil,
    WorldBtn = nil,
    GuildBtn = nil,
    ItemScroll = nil,
    ItemRes = nil,
    ItemGrid = nil,
    NotItemGo = nil,
    SelectPanel = 0,
    ItemList = nil,
    CanAuctionCount = nil,
    SelfRemainCount = 0,
    UpdateList = false,

    -- VIP level required for magic souls
    DevilEquipSellNeedVipLevel = 0,
}

-- Inheriting Form functions
function UIGetAuctionItemTIps:OnRegisterEvents()
	self:RegisterEvent(UIEventDefine.UIGetAuctionItemTIps_OPEN, self.OnOpen)
    self:RegisterEvent(UIEventDefine.UIGetAuctionItemTIps_CLOSE, self.OnClose)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_AUCTION_UP_SUCC, self.OnUpSucc)
end

local L_AuctionItem = nil

function UIGetAuctionItemTIps:OnFirstShow()
    local _trans = self.Trans
    self.CloseBtn = UIUtils.FindBtn(_trans, "CloseBtn")
    UIUtils.AddBtnEvent(self.CloseBtn, self.OnCloseBtnClick, self)
    self.BackTex = UIUtils.FindTex(_trans, "BackTex")
    self.WorldBtn = UIUtils.FindBtn(_trans, "WorldSell")
    UIUtils.AddBtnEvent(self.WorldBtn, self.OnWorldBtnClick, self)
    self.GuildBtn = UIUtils.FindBtn(_trans, "GuildSell")
    UIUtils.AddBtnEvent(self.GuildBtn, self.OnGuildBtnClick, self)
    self.ItemScroll = UIUtils.FindScrollView(_trans, "ItemScroll")
    self.ItemRes = UIUtils.FindGo(_trans, "ItemScroll/Grid/Item")
    self.ItemGrid = UIUtils.FindGrid(_trans, "ItemScroll/Grid")
    self.NotItemGo = UIUtils.FindGo(_trans, "NotItemGo")
    self.CanAuctionCount = UIUtils.FindLabel(_trans, "CanSJCount/Value")

    self.CSForm:AddNormalAnimation(0.3)

    self.ItemList = List:New()
    local _parentTrans = self.ItemGrid.transform
    for i = 0, _parentTrans.childCount - 1 do
        local _item = L_AuctionItem:New(_parentTrans:GetChild(i), self)
        self.ItemList:Add(_item)
    end

    local _gCfg = DataConfig.DataGlobal[GlobalName.DevilSoul_Trade_VIP_Limit]
    if _gCfg ~= nil then
        local _levels = Utils.SplitNumber(_gCfg.Params, '_')
        self.DevilEquipSellNeedVipLevel = tonumber(_levels[1])
    end
end

function UIGetAuctionItemTIps:OnShowAfter()
    self.UpdateList = true
    self.CSForm:LoadTexture(self.BackTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_2"))
end

function UIGetAuctionItemTIps:OnHideAfter()
end

function UIGetAuctionItemTIps:OnOpen(obj, sender)
    self.CSForm:Show(sender)
end

function UIGetAuctionItemTIps:OnClose(obj, sender)
    self.CSForm:Hide()
end

function UIGetAuctionItemTIps:OnUpSucc(obj, sender)
    self.UpdateList = true
end

function UIGetAuctionItemTIps:Update(dt)
    if self.UpdateList then
        self:RefreshPage()
        self.UpdateList = false
    end
end


-- Number of updates
function UIGetAuctionItemTIps:UpdateSelectCount()
    local _curSelectCount = 0
    for i = 1, #self.ItemList do
        if self.ItemList[i].IsSelect and self.ItemList[i].ItemDBID > 0 then
            _curSelectCount = _curSelectCount + 1
        end
    end
    UIUtils.SetTextByEnum(self.CanAuctionCount, "ShowNum", self.SelfRemainCount - _curSelectCount)
end

-- Can you continue to choose
function UIGetAuctionItemTIps:CanSelect()
    local _curSelectCount = 0
    for i = 1, #self.ItemList do
        if self.ItemList[i].IsSelect and self.ItemList[i].ItemDBID > 0 then
            _curSelectCount = _curSelectCount + 1
        end
    end
    if _curSelectCount >= self.SelfRemainCount then
        return false
    end
    return true
end

-- Refresh the interface
function UIGetAuctionItemTIps:RefreshPage()
    self.SelfRemainCount = GameCenter.AuctionHouseSystem.MaxAuctionCount - GameCenter.AuctionHouseSystem.SelfAuctionCount
    local _bagTableList = GameCenter.AuctionHouseSystem:GetCanSellItems(true)
    local _uiCount = #self.ItemList
    for i = 1, _uiCount do
        self.ItemList[i]:SelInto(nil)
    end
    local _itemCount = #_bagTableList
    if _itemCount <= 0 then
        self.ItemScroll.gameObject:SetActive(false)
        self.NotItemGo:SetActive(true)
    else
        self.ItemScroll.gameObject:SetActive(true)
        self.NotItemGo:SetActive(false)
        for i = 1, _itemCount do
            local _uiItem = nil
            if i <= #self.ItemList then
                _uiItem = self.ItemList[i]
            else
                _uiItem = L_AuctionItem:New(UnityUtils.Clone(self.ItemRes).transform, self)
                self.ItemList:Add(_uiItem)
            end
            _uiItem:SelInto(_bagTableList[i])
        end
        self.ItemGrid:Reposition()
        self.ItemScroll.repositionWaitFrameCount = 2
    end
    self:UpdateSelectCount()
end

-- Click the Close button on the interface
function UIGetAuctionItemTIps:OnCloseBtnClick()
    self:OnClose()
end

-- Click on buttons on the world
function UIGetAuctionItemTIps:OnWorldBtnClick()
    self:UpAuction(0)
end

-- Click the gang list button
function UIGetAuctionItemTIps:OnGuildBtnClick()
    self:UpAuction(1)
end

-- Listed items selected
function UIGetAuctionItemTIps:UpAuction(type)
    -- Determine whether it is available for guilds to be listed on the shelves
    if type == 1 and not GameCenter.GuildSystem:HasJoinedGuild() then
        Utils.ShowPromptByEnum("PutawayGuildTips")
        return
    end
    local _isAuction = false
    for i = 1, #self.ItemList do
        local _item = self.ItemList[i]
        if _item.ItemDBID > 0 and _item.IsSelect then
            _isAuction = true
            GameCenter.Network.Send("MSG_Auction.ReqAuctionInfoPut", {itemUid = _item.ItemDBID, num = _item.ItemCount, type = type})
        end
    end
    if not _isAuction then
        Utils.ShowPromptByEnum("PleaseSelectGoods")
    else
        Utils.ShowPromptByEnum("BatchPutawaySucceed")
    end
end

L_AuctionItem = {
    RootGo = nil,
    Btn = nil,
    SelectGo = nil,
    CurPrice = nil,
    CurIcon = nil,
    MaxPrice = nil,
    MaxIcon = nil,
    UIItem = nil,
    Name = nil,
    IsSelect = false,
    ItemDBID = 0,
    ItemCount = 0,
    ItemInstType = 0,
}

function L_AuctionItem:New(trans, parent)
    local _m = Utils.DeepCopy(self)
    _m.Parent = parent
    _m.RootGo = trans.gameObject
    _m.Btn = UIUtils.FindBtn(trans)
    UIUtils.AddBtnEvent(_m.Btn, _m.OnBtnClick, _m)
    _m.SelectGo = UIUtils.FindGo(trans, "Select")
    _m.CurPrice = UIUtils.FindLabel(trans, "CurPrice/NumLabel")
    _m.MaxPrice = UIUtils.FindLabel(trans, "MaxPrice/NumLabel")
    _m.UIItem = UILuaItem:New(UIUtils.FindTrans(trans, "UIItem"))
    _m.Name = UIUtils.FindLabel(trans, "NameLabel")
    _m.CurIcon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(trans, "CurPrice/Icon"))
    _m.MaxIcon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(trans, "MaxPrice/Icon"))
    return _m
end

function L_AuctionItem:SelInto(itemInfo)
    if itemInfo == nil then
        self.RootGo:SetActive(false)
        self.ItemDBID = 0
        self.IsSelect = false
    else
        self.RootGo:SetActive(true)
        self:SetSelect(false)
        self.ItemDBID = itemInfo.DBID
        self.ItemCount = itemInfo.Count
        self.ItemInstType = itemInfo.Type
        self.UIItem:InitWithItemData(itemInfo)
        UIUtils.SetTextFormat(self.Name, "[{0}]{1}",  Utils.GetQualityStrColor(itemInfo.Quality),  itemInfo.Name)
        local _addPirce = 0
        local _minPrice = 0
        local _maxPrice = 0
        local _equipCfg = DataConfig.DataEquip[itemInfo.CfgID]
        local _itemCfg = DataConfig.DataItem[itemInfo.CfgID]
        local _useCion = nil
        if _equipCfg ~= nil then
            _addPirce = _equipCfg.AuctionSinglePrice
            _minPrice = _equipCfg.AuctionMinPrice
            _maxPrice = _equipCfg.AuctionMaxPrice
            _useCion = DataConfig.DataItem[_equipCfg.AuctionUseCoin]
        elseif _itemCfg ~= nil then
            _addPirce = _itemCfg.AuctionSinglePrice
            _minPrice = _itemCfg.AuctionMinPrice
            _maxPrice = _itemCfg.AuctionMaxPrice
            _useCion = DataConfig.DataItem[_itemCfg.AuctionUseCoin]
        end
        self.CurIcon:UpdateIcon(_useCion.Icon)
        self.MaxIcon:UpdateIcon(_useCion.Icon)

        local _count = itemInfo.Count
        if _count <= 0 then
            _count = 1
        end
        if _addPirce <= 0 then
            UIUtils.SetTextByEnum(self.CurPrice, "NULL")
        else
            UIUtils.SetTextByNumber(self.CurPrice, _count * _minPrice)
        end

        if _maxPrice <= 0 then
            UIUtils.SetTextByEnum(self.MaxPrice, "NULL")
        else
            UIUtils.SetTextByNumber(self.MaxPrice, _count * _maxPrice)
        end
    end
end

function L_AuctionItem:SetSelect(select)
    self.IsSelect = select
    self.SelectGo:SetActive(select)
end

function L_AuctionItem:OnBtnClick()
    if not self.IsSelect and not self.Parent:CanSelect() then
        Utils.ShowPromptByEnum("ShelfFull")
        return
    end
    if not self.IsSelect then
        -- Demon soul equipment, determine whether the player's VIP level is sufficient
        if self.ItemInstType == ItemType.DevilSoulChip and self.Parent.DevilEquipSellNeedVipLevel > 0 then
            local _vipLevel = GameCenter.VipSystem:GetVipLevel()
            if _vipLevel < self.Parent.DevilEquipSellNeedVipLevel then
                Utils.ShowPromptByEnum("Devil_Trade_VIP_Limit_Push_Title", self.Parent.DevilEquipSellNeedVipLevel)
                return
            end
            if not GameCenter.VipSystem:BaoZhuIsOpen() then
                Utils.ShowPromptByEnum("C_AUCTION_MHSELL_BAOZHU")
                return
            end
        end
    end
    self:SetSelect(not self.IsSelect)
    self.Parent:UpdateSelectCount()
end

return UIGetAuctionItemTIps
