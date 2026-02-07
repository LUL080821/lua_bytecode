------------------------------------------------
-- Author:
-- Date: 2019-07-08
-- File: HouseShopData.lua
-- Module: HouseShopData
-- Description: Store Data Model
------------------------------------------------
local HouseShopData = {
    -- Product ID
    SellId = 0,
    -- Number of products
    Count = 0,
    -- Product Category ID List
    ItemTypeList = List:New(),
    -- Corresponding item table ID
    ItemId = 0,
    -- Sort number. All locations are determined according to this
    Index = 0,
    -- Profession
    Occ = -1,
    -- Currency Type Find from item configuration table
    CoinType = 0,
    -- The current price may be the original price or the discounted price
    Price = 0,
    -- Original price
    OrigionPrice = 0,
    -- Product status, such as whether it is hot or not, whether it is discounted. wait
    Hot = 0,
    -- Discount number 0 is not discount, >0 is the specific discount number
    Discount = 0,
    -- Is it bound immediately when purchasing
    BuyBind = false,
    -- Disappearing time
    TimeOut = 0,
    -- Expiration time
    LostTime = "",
    -- Purchase limit quantity 0 is unlimited
    BuyLimit = 0,
    -- Number of times you have purchased
    AlreadyBuyNum = 0,
    -- Purchase level limit
    BuyLv = 0,
    -- Gang Level Limit
    GuildLv = 0,
    -- Purchase VIP level restrictions
    VipLv = 0,
    -- Rank level restrictions
    MilitaryRanklevel = 0,
    -- Purchase restriction type 0. No purchase limit; 1. Daily limit; 2. Weekly limit; 3. Monthly limit; 4. Yearly limit; 5. Lifetime limit
    LimitType = 0,
    -- Is there any VIP level discount
    IsDisCount = 0,
    -- Purchase discount
    CountdisCount = nil,
    -- Price increments floated according to purchases
    AddPrice = 0,
    -- thing
    ItemInfo = nil
}
-- Create a new object and use the protocol MSG_Shop.shopItemInfo as the data source
function HouseShopData:New(itemID, count)
    local itemInfo = DataConfig.DataSocialHouseMarket[itemID]
    if itemInfo then
        local _m = Utils.DeepCopy(self)
        _m.SellId = itemInfo.ID;
        _m.ItemId = itemInfo.FurnitureID;
        _m.Index = itemInfo.Sort;
        _m.CoinType = itemInfo.CurrencyID;
        _m.Price = itemInfo.Price;
        _m.OrigionPrice = itemInfo.Price;
        _m.Hot = itemInfo.Promotion;
        _m.BuyLimit = itemInfo.BuyNum;
        _m.BuyLv = itemInfo.Level;
        _m.LimitType = itemInfo.LimitType;
        _m.ShopID = itemInfo.ShopID;
        _m.ShopType = itemInfo.ShopType;
        _m.RemainBuyNum = count
        if _m.RemainBuyNum <= 0 then
            _m.Index = _m.Index + 999999
        end
        return _m
    end
    return nil
end
return HouseShopData