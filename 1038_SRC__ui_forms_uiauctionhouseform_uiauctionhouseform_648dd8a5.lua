------------------------------------------------
-- author:
-- Date: 2019-10-8
-- File: UIAuctionHouseForm.lua
-- Module: UIAuctionHouseForm
-- Description: Auction House Interface
------------------------------------------------

local UIListMenu = require "UI.Components.UIListMenu.UIListMenuRight"
local TOPUIListMenu = require "UI.Components.UIListMenu.UIListMenu"
local UIAuctionItemListPanel = require "UI.Forms.UIAuctionHouseForm.UIAuctionItemListPanel"
local UIAuctionSellPanel = require "UI.Forms.UIAuctionHouseForm.UIAuctionSellPanel"
local UIAuctionItemBuyPanel = require "UI.Forms.UIAuctionHouseForm.UIAuctionItemBuyPanel"
local UIAuctionItemJingJiaPanel = require "UI.Forms.UIAuctionHouseForm.UIAuctionItemJingJiaPanel"
local UIActionSelfBuyPanel = require "UI.Forms.UIAuctionHouseForm.UIActionSelfBuyPanel"
local UIAuctionRecordPanel = require "UI.Forms.UIAuctionHouseForm.UIAuctionRecordPanel"
local UIAuctionCarePanel = require "UI.Forms.UIAuctionHouseForm.UIAuctionCarePanel"
local UIAuctionItemMiMaBuyPanel = require "UI.Forms.UIAuctionHouseForm.UIAuctionItemMiMaBuyPanel"

-- //Module definition
local UIAuctionHouseForm = {
    -- Top Menu
    ListMenuTop = nil,
    -- Menu on the right
    ListMenuRight = nil,
    -- Close button
    CloseBtn = nil,
    -- North background picture
    BackTex = nil,
    SelectPanelID = 0,
    -- Product List Page
    ItemListPanel = nil,
    -- For Sale Interface
    SellPanel = nil,

    -- Purchase page
    BuyPanel = nil,
    -- Password purchase page
    MiMaBuyPanel = nil,
    -- Bidding page
    JingJiaPanel = nil,
    -- List of bidding for your own
    SelfJingJiaPanel = nil,
    -- Recording interface
    RecordPanel = nil,
    -- Follow the interface
    CarePanel = nil,

    -- Open parameters
    OpenParam = nil,

    -- Personal record data
    SelfRecordList = nil,
    -- World Record Data
    WorldRescorList = nil,

    -- Is it already open
    IsShow = false,

    -- VIP level required for the launch of the holy clothing
    HolyEquipSellNeedVipLevel = 0,
    -- VIP level required for purchasing holy clothing
    HolyEquipBuyNeedVipLevel = 0,

    -- VIP level required for magic souls
    DevilEquipSellNeedVipLevel = 0,
    -- VIP level required for purchasing demon souls
    DevilEquipBuyNeedVipLevel = 0,
}

-- Inheriting Form functions
function UIAuctionHouseForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UIAuctionHouseForm_OPEN,self.OnOpen)
    self:RegisterEvent(UIEventDefine.UIAuctionHouseForm_CLOSE,self.OnClose)

    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_AUCTION_UPDATELIST,self.OnListUpdate)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_AUCTION_UP_SUCC,self.OnUpSucc)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_AUCTION_DOWN_RESULT,self.OnDownResult)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_AUCTION_BUY_RESULT,self.OnBuyReult)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_AUCTION_JINGJIA_RESULT,self.OnJingJiaResult)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_AUCTION_SELFRECORD_LIST,self.OnSelfRecordResult)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_AUCTION_WORLDRECORD_LIST,self.OnWorldRecordResult)
end

function UIAuctionHouseForm:OnFirstShow()
    self.CSForm:AddNormalAnimation()

    local _trans = self.Trans
    self.CloseBtn = UIUtils.FindBtn(_trans, "Back/CloseBtn")
    UIUtils.AddBtnEvent(self.CloseBtn, self.OnCloseBtnClick, self)
    self.BackTex = UIUtils.FindTex(_trans, "Back/BackTex")

    self.ListMenuRight = UIListMenu:OnFirstShow(self.CSForm, UIUtils.FindTrans(_trans, "UIListMenu"))
    self.ListMenuRight:AddIcon(0, DataConfig.DataMessageString.Get("StrAuction"), FunctionStartIdCode.Auchtion)
    self.ListMenuTop = TOPUIListMenu:OnFirstShow(self.CSForm, UIUtils.FindTrans(_trans, "UIListMenuTop"))

    self.ListMenuTop:ClearSelectEvent();
    self.ListMenuTop:AddSelectEvent(Utils.Handler(self.OnMenuSelect, self))
    self.ListMenuTop:AddIcon(AuctionSubPanel.World, DataConfig.DataMessageString.Get("WorldAuction"), FunctionStartIdCode.AuchtionWorld)
    self.ListMenuTop:AddIcon(AuctionSubPanel.Guild, DataConfig.DataMessageString.Get("GuildAuction"), FunctionStartIdCode.AuchtionGuild)
    self.ListMenuTop:AddIcon(AuctionSubPanel.SelfBuy, DataConfig.DataMessageString.Get("MyAuction"), FunctionStartIdCode.AuchtionBuy)
    self.ListMenuTop:AddIcon(AuctionSubPanel.SelfSell, DataConfig.DataMessageString.Get("MyPutaway"), FunctionStartIdCode.AuchtionSell)
    self.ListMenuTop:AddIcon(AuctionSubPanel.Record, DataConfig.DataMessageString.Get("TradingRecord"), FunctionStartIdCode.AuchtionRecord)
    self.ListMenuTop:AddIcon(AuctionSubPanel.SelfFollow, DataConfig.DataMessageString.Get("MyAttention"), FunctionStartIdCode.AuchtionFollow)
    self.ListMenuTop.IsHideIconByFunc = true

    self.ItemListPanel = UIAuctionItemListPanel:OnFirstShow(UIUtils.FindTrans(_trans, "ShopListPanel"), self, self)
    self.SellPanel = UIAuctionSellPanel:OnFirstShow(UIUtils.FindTrans(_trans, "SellPanel"), self, self)
    self.SelfJingJiaPanel = UIActionSelfBuyPanel:OnFirstShow(UIUtils.FindTrans(_trans, "SelfBuyPanel"), self, self)
    self.RecordPanel = UIAuctionRecordPanel:OnFirstShow(UIUtils.FindTrans(_trans, "RecordPanel"), self, self)
    self.CarePanel = UIAuctionCarePanel:OnFirstShow(UIUtils.FindTrans(_trans, "CarePanel"), self, self)
    
    self.BuyPanel = UIAuctionItemBuyPanel:OnFirstShow(UIUtils.FindTrans(_trans, "BuyPanel"), self, self)
    self.MiMaBuyPanel = UIAuctionItemMiMaBuyPanel:OnFirstShow(UIUtils.FindTrans(_trans, "MiMaBuyPanel"), self, self)
    self.JingJiaPanel = UIAuctionItemJingJiaPanel:OnFirstShow(UIUtils.FindTrans(_trans, "JingJiaPanel"), self, self)

    local _gCfg = DataConfig.DataGlobal[GlobalName.Holy_Trade_VIP_Limit]
    if _gCfg ~= nil then
        local _levels = Utils.SplitNumber(_gCfg.Params, '_')
        self.HolyEquipSellNeedVipLevel = tonumber(_levels[1])
        self.HolyEquipBuyNeedVipLevel = tonumber(_levels[2])
    end
	self.MoenyForm = UIUtils.RequireUIMoneyForm(UIUtils.FindTrans(_trans, "UIMoneyForm"))
    self.MoenyForm:SetMoneyList(3, 12, 2, 1)
    
    _gCfg = DataConfig.DataGlobal[GlobalName.DevilSoul_Trade_VIP_Limit]
    if _gCfg ~= nil then
        local _levels = Utils.SplitNumber(_gCfg.Params, '_')
        self.DevilEquipSellNeedVipLevel = tonumber(_levels[1])
        self.DevilEquipBuyNeedVipLevel = tonumber(_levels[2])
    end
end

function UIAuctionHouseForm:OnShowAfter()
    self.SelectPanelID = -1
    self.ListMenuRight:SetSelectByIndex(1);
    self.CSForm:LoadTexture(self.BackTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_1_2"))
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_HIDEANIMATION)
    self.IsShow = true
    -- When opening the interface, request the world level to follow the interface processing
    GameCenter.OfflineOnHookSystem:ReqHookSetInfo()
end

function UIAuctionHouseForm:OnHideBefore()
    self.ListMenuTop:SetSelectByIndex(-1);
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_SHOWANIMATION)
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
    self.IsShow = false
end

function UIAuctionHouseForm:OnTryHide()
    if self.SellPanel.IsVisible and not self.SellPanel:OnTryHide() then
        return false
    end
    if self.BuyPanel.IsVisible then
        self.BuyPanel:Hide()
        return false
    end
    if self.JingJiaPanel.IsVisible then
        self.JingJiaPanel:Hide()
        return false
    end
    if self.MiMaBuyPanel.IsVisible then
        self.MiMaBuyPanel:Hide()
        return false
    end
    return true
end

-- Menu Select Events
function UIAuctionHouseForm:OnMenuSelect(id, b)
    if b then
        self.SelectPanelID = id
        if id == AuctionSubPanel.World then
            self.ItemListPanel:Show(0, self.OpenParam)
        elseif id == AuctionSubPanel.Guild then
            self.ItemListPanel:Show(1, self.OpenParam)
        elseif id == AuctionSubPanel.SelfBuy then
            self.SelfJingJiaPanel:Show()
        elseif id == AuctionSubPanel.SelfSell then
            self.SellPanel:Show(self.OpenParam)
        elseif id == AuctionSubPanel.Record then
            self.RecordPanel:Show()
        elseif id == AuctionSubPanel.SelfFollow then
            self.CarePanel:Show()
        end

        self.OpenParam = nil
    else
        if id == AuctionSubPanel.World then
            self.ItemListPanel:Hide()
        elseif id == AuctionSubPanel.Guild then
            self.ItemListPanel:Hide()
        elseif id == AuctionSubPanel.SelfBuy then
            self.SelfJingJiaPanel:Hide()
        elseif id == AuctionSubPanel.SelfSell then
            self.SellPanel:Hide()
        elseif id == AuctionSubPanel.Record then
            self.RecordPanel:Hide()
        elseif id == AuctionSubPanel.SelfFollow then
            self.CarePanel:Hide()
        end
    end
end

-- Turn on the event
function UIAuctionHouseForm:OnOpen(obj, sender)
    if not self.IsShow then
        GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN, DataConfig.DataMessageString.Get("GoodsListLoading"));
        -- Send a get list message
        GameCenter.AuctionHouseSystem:ReqItemList()
    end

    self.CSForm:Show(sender)
    if obj ~= nil then
        if type(obj) == "table" then
            self.OpenParam = obj[2]
            self.ListMenuTop:SetSelectById(obj[1])
        else
            self.ListMenuTop:SetSelectById(obj)
        end
    else
        self.ListMenuTop:SetSelectById(AuctionSubPanel.World)
    end
end

-- Close Event
function UIAuctionHouseForm:OnClose(obj, sender)
    self.CSForm:Hide()
end

-- Refresh the list
function UIAuctionHouseForm:OnListUpdate(obj, sender)
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
    if self.SelectPanelID == AuctionSubPanel.World or self.SelectPanelID == AuctionSubPanel.Guild then
        -- Refresh the list interface
        self.ItemListPanel.IsRefreshItemList = true
    elseif self.SelectPanelID == AuctionSubPanel.SelfBuy then
        -- Refresh the list interface
        self.SelfJingJiaPanel.IsRefreshItemList = true
    elseif self.SelectPanelID == AuctionSubPanel.SelfSell then
        self.SellPanel:RefreshPaghe()
    end
end

-- Successfully launched
function UIAuctionHouseForm:OnUpSucc(obj, sender)
    Utils.ShowPromptByEnum("PutawaySucceed")
    if self.SelectPanelID == AuctionSubPanel.SelfSell then
        -- Refresh the shelves interface
        self.SellPanel:RefreshPaghe(true, false)
    end
end

-- Removed and returned
function UIAuctionHouseForm:OnDownResult(obj, sender)
    if self.SelectPanelID == AuctionSubPanel.SelfSell then
        -- Refresh the shelves interface
        self.SellPanel:RefreshPaghe(true)
    end
end

-- Buy it in one price and return
function UIAuctionHouseForm:OnBuyReult(obj, sender)
    if self.SelectPanelID == AuctionSubPanel.World or self.SelectPanelID == AuctionSubPanel.Guild then
        -- Delete purchased items
        self.ItemListPanel:OnBuySucc(obj)
    elseif self.SelectPanelID == AuctionSubPanel.SelfBuy then
        self.SelfJingJiaPanel:OnBuySucc(obj)
    end

    if self.JingJiaPanel.IsVisible then
        -- Bidding is successful, close the interface
        self.JingJiaPanel:Hide()
    end
end

-- Bidding Return
function UIAuctionHouseForm:OnJingJiaResult(id, sender)
    if self.SelectPanelID == AuctionSubPanel.World or self.SelectPanelID == AuctionSubPanel.Guild then
        -- Refresh or delete purchased items
        self.ItemListPanel:OnJingJiaResult(id)
    elseif self.SelectPanelID == AuctionSubPanel.SelfBuy then
        self.SelfJingJiaPanel:OnJingJiaResult(id)
    end

    if self.JingJiaPanel.IsVisible and id == self.JingJiaPanel.AHItemID then
        local _ahItem = GameCenter.AuctionHouseSystem:GetItemByID(id)
        if _ahItem ~= nil then
            if _ahItem.IsSelfPriceOwner then
                -- Bidding is successful, close the interface
                self.JingJiaPanel:Hide()
            else
                -- Bidding failed, refresh the interface
                self.JingJiaPanel:RefreshPanel(_ahItem)
            end
        else
            -- The item has been deleted, close the interface
            self.JingJiaPanel:Hide()
        end
    end
end

-- Return to personal records
function UIAuctionHouseForm:OnSelfRecordResult(msg, sender)

    Debug.Log("==msg.recordsmsg.recordsmsg.recordsmsg.recordsmsg.recordsmsg.recordsmsg.records====", Inspect(msg.records))

    self.SelfRecordList = msg.records
    if self.RecordPanel.IsVisible then
        self.RecordPanel:RefreshPanel()
    end
end
-- World Record Return
function UIAuctionHouseForm:OnWorldRecordResult(msg, sender)
    self.WorldRescorList = msg.records
    if self.RecordPanel.IsVisible then
        self.RecordPanel:RefreshPanel()
    end
end

-- Rearrange the list
function UIAuctionHouseForm:ReSortList()
    if self.SelectPanelID == AuctionSubPanel.World or self.SelectPanelID == AuctionSubPanel.Guild then
        self.ItemListPanel:ReSortList()
    elseif self.SelectPanelID == AuctionSubPanel.SelfBuy then
        self.SelfJingJiaPanel:ReSortList()
    end
end

-- Click Close button
function UIAuctionHouseForm:OnCloseBtnClick()
    self:OnClose(nil, nil)
end

function UIAuctionHouseForm:Update(dt)
    if self.SelectPanelID == AuctionSubPanel.World then
        self.ItemListPanel:Update(dt)
    elseif self.SelectPanelID == AuctionSubPanel.Guild then
        self.ItemListPanel:Update(dt)
    elseif self.SelectPanelID == AuctionSubPanel.SelfBuy then
        self.SelfJingJiaPanel:Update(dt)
    elseif self.SelectPanelID == AuctionSubPanel.Record then
        self.RecordPanel:Update(dt)
    elseif self.SelectPanelID == AuctionSubPanel.SelfFollow then
        self.CarePanel:Update(dt)
    end
end

return UIAuctionHouseForm;
