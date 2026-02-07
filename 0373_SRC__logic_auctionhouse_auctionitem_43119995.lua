------------------------------------------------
-- Author: 
-- Date: 2021-02-23
-- File: AuctionItem.lua
-- Module: AuctionItem
-- Description: Auction house props
------------------------------------------------

local L_ItemCache = List:New()

local AuctionItem = {
    -- Whether it is locked, the locked cannot be free
    IsLocked = false,

    -- Listed ID
    OwnerID = 0,
    -- Item unique ID
    ID = 0,
    -- Item Configuration ID
    CfgID = 0,
    -- Item Example
    ItemInst  = nil,
    -- Guild belonging to
    OwnerGuild = 0,
    -- Current Price
    CurPrice = 0,
    -- Current bidder ID
    CurPriceOwner = 0,
    -- Is it the highest bidder?
    IsSelfPriceOwner = false,
    -- List of players who have participated in the bidding
    JionPlayerList = nil,
    -- Have you participated in the bidding
    IsSefJion = false,
    -- Minimum bidding
    MinPrice = 0,
    -- Bidding value added type: 0 price, 10,000 points
    SinglePriceType = 0,
    -- Add value for each bid
    SinglePrice = 0,
    -- Fixed price
    MaxPrice = 0,
    -- Is there a start CD
    HaveStartCD = false,
    -- Item configuration
    ItemCfg = nil,
    -- Equipment configuration
    EquipCfg = nil,
    -- Total auction time
    AuctionAllTime = 0,
    -- time left
    ServerRemainTime = 0,
    -- Synchronized time
    SyncTime = 0,
    -- Is there a password
    HasMiMa = false,
    -- Currency Configuration Used
    UseCoinCfg = nil,
    -- Auction type used, 0 fixed price, 1 custom price
    UsePriceType = 0,
}

function AuctionItem.Get()
    local _m = nil
    local _haveCount = #L_ItemCache
    if _haveCount > 0 then
        _m = L_ItemCache[_haveCount]
        L_ItemCache:RemoveAt(_haveCount)
    else
        _m = Utils.DeepCopy(AuctionItem)
    end
    return _m
end
function AuctionItem.Free(item, force)
    if item.IsLocked and not force then
        return
    end
    item.ItemInst = nil
    item.ID = 0
    item.CfgID = 0
    item.OwnerID = 0
    item.ServerRemainTime = 0
    item.SyncTime = 0
    item.CurPrice = 0
    item.CurPriceOwner = 0
    item.ItemCfg = nil
    item.EquipCfg = nil
    item.HasMiMa = false
    L_ItemCache:Add(item)
end

-- Refresh data
-- function AuctionItem:RefreshData(msgInfo)
--     local _lpId = GameCenter.GameSceneSystem:GetLocalPlayerID()

--     Debug.Log("=====msgInfomsgInfomsgInfomsgInfomsgInfo====msgInfomsgInfomsgInfomsgInfo===", Inspect(msgInfo))

--     self.ItemInst = LuaItemBase.CreateItemBaseByMsg(msgInfo.item)
--     self.CfgID = self.ItemInst.CfgID
--     self.OwnerGuild = msgInfo.guildId
--     self.ID = msgInfo.id
--     self.OwnerID = msgInfo.ownId
--     self.ServerRemainTime = msgInfo.time
--     self.SyncTime = Time.GetRealtimeSinceStartup()
--     self.CurPrice = msgInfo.price
--     self.CurPriceOwner = msgInfo.roleId
--     self.IsSelfPriceOwner = (self.CurPriceOwner == _lpId)
--     self.HasMiMa = msgInfo.isPassword
--     self.JionPlayerList = {}
--     if self.CurPriceOwner > 0 then
--         self.JionPlayerList[self.CurPriceOwner] = true
--     end
--     if msgInfo.roleIds ~= nil then
--         for i = 1, #msgInfo.roleIds do
--             self.JionPlayerList[msgInfo.roleIds[i]] = true
--         end
--     end
  
--     local _itemCount = self.ItemInst.Count
--     self.IsSefJion = self.JionPlayerList[_lpId] or false
--     if self.ItemInst.Type == ItemType.Equip or self.ItemInst.Type == ItemType.HolyEquip or self.ItemInst.Type == ItemType.UnrealEquip then
--         self.EquipCfg = DataConfig.DataEquip[self.CfgID]
--         if self.EquipCfg ~= nil then
--             self.MinPrice = self.EquipCfg.AuctionMinPrice * _itemCount
--             self.SinglePrice = self.EquipCfg.AuctionSinglePrice * _itemCount
--             self.SinglePriceType = self.EquipCfg.AuctionSingleType
--             self.MaxPrice = self.EquipCfg.AuctionMaxPrice * _itemCount
--             -- There will be no start cd when there is a transaction password
--             self.HaveStartCD = self.EquipCfg.AuctionCountdown ~= 0 and not self.HasMiMa
--             if self.OwnerGuild > 0 then
--                 -- Xianmeng Auction
--                 self.AuctionAllTime = self.EquipCfg.AuctionGuildAllTime
--             else
--                 -- World Auction
--                 self.AuctionAllTime = self.EquipCfg.AuctionAllTime
--             end
--             self.UseCoinCfg = DataConfig.DataItem[self.EquipCfg.AuctionUseCoin]
--             self.UsePriceType = self.EquipCfg.AuctionPriceType
--         end
--     else
--         self.ItemCfg = DataConfig.DataItem[self.CfgID]
--         if self.ItemCfg ~= nil then
--             self.MinPrice = self.ItemCfg.AuctionMinPrice * _itemCount
--             self.SinglePrice = self.ItemCfg.AuctionSinglePrice * _itemCount
--             self.SinglePriceType = self.ItemCfg.AuctionSingleType
--             self.MaxPrice = self.ItemCfg.AuctionMaxPrice * _itemCount
--             -- There will be no start cd when there is a transaction password
--             self.HaveStartCD = self.ItemCfg.AuctionCountdown ~= 0 and not self.HasMiMa
--             if self.OwnerGuild > 0 then
--                 -- Xianmeng Auction
--                 self.AuctionAllTime = self.ItemCfg.AuctionGuildAllTime
--             else
--                 -- World Auction
--                 self.AuctionAllTime = self.ItemCfg.AuctionAllTime
--             end
--             self.UseCoinCfg = DataConfig.DataItem[self.ItemCfg.AuctionUseCoin]
--             self.UsePriceType = self.ItemCfg.AuctionPriceType
--         end
--     end
--     if self.CurPrice <= 0 then
--         self.CurPrice = self.MinPrice
--     end
-- end



function AuctionItem:RefreshData(msgInfo)
    local _lpId = GameCenter.GameSceneSystem:GetLocalPlayerID()

    ------------------------------------------------
    -- 1. BUILD ITEM MSG (FAKE MSG_backpack.ItemInfo)
    ------------------------------------------------
    local buildMsg = nil
    local detail = msgInfo.detail

    if detail and detail.equip then
        local e = detail.equip
        buildMsg = {
            itemId      = e.itemId,
            itemModelId = e.itemModelId,
            num         = e.num or 1,
            gridId      = e.gridId or 0,
            isbind      = e.isbind or false,
            lostTime    = e.lostTime or 0,

            --  KEY POINT (QUYẾT ĐỊNH BASE ATTR)
            suitId      = e.suitId or 0,
            percent     = e.percent or 0,

        }
        if detail.strengthInfo then
            buildMsg.strengLv = detail.strengthInfo.level or 0
        end
    else
        -- fallback (should not happen normally)
        buildMsg = msgInfo.item
    end


    -- Debug.Log("buildMsgbuildMsgbuildMsgbuildMsgbuildMsgbuildMsg======================", Inspect(buildMsg))

    ------------------------------------------------
    -- 2. CREATE RUNTIME ITEM INSTANCE (BAG-LIKE)
    ------------------------------------------------
    self.ItemInst = LuaItemBase.CreateItemBaseByMsg(buildMsg)
    self.CfgID = self.ItemInst.CfgID

    ------------------------------------------------
    -- 3. KEEP DETAIL RAW DATA
    ------------------------------------------------
    self.Detail = detail

    ------------------------------------------------
    -- 4. BASIC AUCTION META
    ------------------------------------------------
    self.OwnerGuild = msgInfo.guildId
    self.ID = msgInfo.id
    self.OwnerID = msgInfo.ownId
    self.ServerRemainTime = msgInfo.time
    self.SyncTime = Time.GetRealtimeSinceStartup()

    self.CurPrice = msgInfo.price
    self.CurPriceOwner = msgInfo.roleId
    self.IsSelfPriceOwner = (self.CurPriceOwner == _lpId)
    self.HasMiMa = msgInfo.isPassword

    ------------------------------------------------
    -- 5. JOIN PLAYER LIST
    ------------------------------------------------
    self.JionPlayerList = {}
    if self.CurPriceOwner > 0 then
        self.JionPlayerList[self.CurPriceOwner] = true
    end
    if msgInfo.roleIds then
        for i = 1, #msgInfo.roleIds do
            self.JionPlayerList[msgInfo.roleIds[i]] = true
        end
    end
    self.IsSefJion = self.JionPlayerList[_lpId] or false

    ------------------------------------------------
    -- 6. PRICE LOGIC (KEEP OLD CONFIG LOGIC)
    ------------------------------------------------
    local _itemCount = self.ItemInst.Count

    if self.ItemInst.Type == ItemType.Equip
        or self.ItemInst.Type == ItemType.HolyEquip
        or self.ItemInst.Type == ItemType.UnrealEquip then

        self.EquipCfg = DataConfig.DataEquip[self.CfgID]
        if self.EquipCfg then
            self.MinPrice = self.EquipCfg.AuctionMinPrice * _itemCount
            self.SinglePrice = self.EquipCfg.AuctionSinglePrice * _itemCount
            self.SinglePriceType = self.EquipCfg.AuctionSingleType
            self.MaxPrice = self.EquipCfg.AuctionMaxPrice * _itemCount
            self.HaveStartCD = self.EquipCfg.AuctionCountdown ~= 0 and not self.HasMiMa

            self.AuctionAllTime =
                (self.OwnerGuild > 0)
                and self.EquipCfg.AuctionGuildAllTime
                or self.EquipCfg.AuctionAllTime

            self.UseCoinCfg = DataConfig.DataItem[self.EquipCfg.AuctionUseCoin]
            self.UsePriceType = self.EquipCfg.AuctionPriceType
        end
    else
        self.ItemCfg = DataConfig.DataItem[self.CfgID]
        if self.ItemCfg then
            self.MinPrice = self.ItemCfg.AuctionMinPrice * _itemCount
            self.SinglePrice = self.ItemCfg.AuctionSinglePrice * _itemCount
            self.SinglePriceType = self.ItemCfg.AuctionSingleType
            self.MaxPrice = self.ItemCfg.AuctionMaxPrice * _itemCount
            self.HaveStartCD = self.ItemCfg.AuctionCountdown ~= 0 and not self.HasMiMa

            self.AuctionAllTime =
                (self.OwnerGuild > 0)
                and self.ItemCfg.AuctionGuildAllTime
                or self.ItemCfg.AuctionAllTime

            self.UseCoinCfg = DataConfig.DataItem[self.ItemCfg.AuctionUseCoin]
            self.UsePriceType = self.ItemCfg.AuctionPriceType
        end
    end

    if self.CurPrice <= 0 then
        self.CurPrice = self.MinPrice
    end
end



-- Refresh false data
function AuctionItem:RefreshTempData(msgInfo)
    -- Time is set to maximum
    self.ServerRemainTime = self.AuctionAllTime
    self.SyncTime = Time.GetRealtimeSinceStartup()
    -- Price is set to the price of the last bid
    self.CurPrice = self.MaxPrice - self.SinglePrice
    CurPriceOwner = 1
end

-- time left
function AuctionItem:GetRemainTime()
    return self.ServerRemainTime - (Time.GetRealtimeSinceStartup() - self.SyncTime)
end

return AuctionItem