------------------------------------------------
-- Author: 
-- Date: 2019-08-01
-- File: ShopAuctionSystem.lua
-- Module: ShopAuctionSystem
-- Description: Trading line logic and data management category
------------------------------------------------
local L_Record = require("Logic.ShopAuction.AHGoodsRecords")
local L_SortInfo = require("Logic.ShopAuction.AHSortInfo")
local L_Goods = require("Logic.ShopAuction.AHGoods")
local ShopAuctionSystem = {
    -- List of goods sold
    MarketInfoList = List:New(),
    -- Purchase list
    AskBuyInfoList = List:New(),
    -- Log List
    MarketHistoryList = List:New(),
    -- List of items on shelves
    MarketOwnInfoDic = Dictionary:New(),
    -- Some basic information about the sales list, such as sorting method
    MarketBuyInfo = L_SortInfo:New(),
    -- Some basic information about the purchase list, such as sorting method
    AskBuyInfo = L_SortInfo:New(),
    -- List of items on shelves
    AskBuyOwnInfoDic = Dictionary:New(),
    -- Yuanbao that can be collected after selling items
    MarketSellGold = 0,
}
-- load
function ShopAuctionSystem:Initialize()
    self.MarketSellGold = 0
end

-- uninstall
function ShopAuctionSystem:UnInitialize()
    self.MarketInfoList:Clear()
    self.MarketHistoryList:Clear()
    self.MarketOwnInfoDic:Clear()
    self.MarketBuyInfo = L_SortInfo:New()
    self.AskBuyInfo = L_SortInfo:New()
end

-- Auction house log records are issued
function ShopAuctionSystem:ResMarketLogList(result)
    self.MarketHistoryList:Clear()
    if result.infoList then
        for idx = 1, #result.infoList do
            local _records = L_Record:New(result.infoList[idx])
            self.MarketHistoryList:Add(_records)
        end
    end
    self.MarketSellGold = result.gold
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MARKET_UPDATE_LOG);
end

-- Auction house purchase page product list
function ShopAuctionSystem:ResMarketSortList(result)
    if result.panelType == 1 then
        self.MarketInfoList:Clear();
        self.MarketBuyInfo.PanelType = result.panelType;
        self.MarketBuyInfo.Desc = result.desc;
        self.MarketBuyInfo.DirType = result.dirType;
        self.MarketBuyInfo.AllNum = result.sortCount;
        self.MarketBuyInfo.IdxBegin = result.indexBegin;
        self.MarketBuyInfo.IdxEnd = result.indexEnd;
        self.MarketBuyInfo.Level = result.pingJiType;
        self.MarketBuyInfo.Quailty = result.color;
        self.MarketBuyInfo.SerachName = result.searchName;
        self.MarketBuyInfo.Sex = result.sex;
        self.MarketBuyInfo.SortType = result.sortType;

        if self.MarketBuyInfo.IdxEnd >= (self.MarketBuyInfo.AllNum - 1) then
            self.MarketBuyInfo.IdxEnd = self.MarketBuyInfo.AllNum - 1;
        end
        if result.marketList then
            for idx = 1, #result.marketList do
                local _goods = L_Goods:NewWithInfo(result.marketList[idx])
                self.MarketInfoList:Add(_goods);
            end
        end
    else
        self.AskBuyInfoList:Clear();
        self.AskBuyInfo.PanelType = result.panelType;
        self.AskBuyInfo.Desc = result.desc;
        self.AskBuyInfo.DirType = result.dirType;
        self.AskBuyInfo.AllNum = result.sortCount;
        self.AskBuyInfo.IdxBegin = result.indexBegin;
        self.AskBuyInfo.IdxEnd = result.indexEnd;
        self.AskBuyInfo.Level = result.pingJiType;
        self.AskBuyInfo.Quailty = result.color;
        self.AskBuyInfo.SerachName = result.searchName;
        self.AskBuyInfo.Sex = result.sex;
        self.AskBuyInfo.SortType = result.sortType;

        if self.AskBuyInfo.IdxEnd >= (self.AskBuyInfo.AllNum - 1) then
            self.AskBuyInfo.IdxEnd = self.AskBuyInfo.AllNum - 1;
        end
        if result.marketList then
            for idx = 1, #result.marketList do
                local _goods = L_Goods:NewWithInfo(result.marketList[idx])
                self.AskBuyInfoList:Add(_goods);
            end
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MARKET_UPDATE_BUY)
end

-- Auction house listing network messages
function ShopAuctionSystem:ResMyMarketList(result)
    self.MarketOwnInfoDic:Clear();
    self.AskBuyOwnInfoDic:Clear()
    if result.marketList then
        if #result.marketList > 0 and result.marketList[1].panelType == 1 then
            for idx = 1, #result.marketList do
                local _goods = L_Goods:NewWithInfo(result.marketList[idx])
                self.MarketOwnInfoDic:Add(_goods.MarketId, _goods)
            end
        else
            for idx = 1, #result.marketList do
                local _goods = L_Goods:NewWithInfo(result.marketList[idx])
                self.AskBuyOwnInfoDic:Add(_goods.MarketId, _goods)
            end
        end
    end

    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MARKET_UPDATE_OWN)
end

-- Successfully listed products
function ShopAuctionSystem:ResMarketUpItem(result)
    if result.marketItemInfo and result.marketItemInfo.panelType == 1 then
        local _goods = L_Goods:NewWithInfo(result.marketItemInfo)
        if self.MarketOwnInfoDic:ContainsKey(_goods.MarketId) then
            self.MarketOwnInfoDic[_goods.MarketId] = _goods
        else
            self.MarketOwnInfoDic:Add(_goods.MarketId, _goods)
        end
    elseif result.marketItemInfo and result.marketItemInfo.panelType == 2 then
        local _goods = L_Goods:NewWithInfo(result.marketItemInfo)
        if self.AskBuyOwnInfoDic:ContainsKey(_goods.MarketId) then
            self.AskBuyOwnInfoDic[_goods.MarketId] = _goods
        else
            self.AskBuyOwnInfoDic:Add(_goods.MarketId, _goods)
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MARKET_UPDATE_OWN)
end

-- Product listing failed
function ShopAuctionSystem:ResMarketUpFailure(result)

end

-- Purchase failed, auction house
function ShopAuctionSystem:ResBuyItemFailure(result)
    if result.state == 7 then
        Utils.ShowPromptByEnum("C_SHOP_TIPS_BUYFAILEDCONTBUYOWN")
    elseif result.state == 5 then
        Utils.ShowPromptByEnum("C_SHOP_TIPS_BUYFAILEDITEMISSELL")
    end
end

-- When it is launched, request similar items
function ShopAuctionSystem:ResSellItemList(result)
    local _list = List:New()
    if result.marketList then
        for idx = 1, #result.marketList do
            local _goods = L_Goods:NewWithInfo(result.marketList[idx])
            _list:Add(_goods)
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MARKET_UPDATE_OTHERLIST, _list)
end

-- List of currencies sold by auction house
function ShopAuctionSystem:ResCoinList(result)
    self.MarketSellGold = result.gold;
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MARKET_UPDATE_SELLCOIN);
end
return ShopAuctionSystem