------------------------------------------------
-- Author:
-- Date: 2019-07-08
-- File: ShopData.lua
-- Module: ShopData
-- Description: Store Data Model
------------------------------------------------
local ShopData = {
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
function ShopData:NewWithData(itemInfo)
    local _m = Utils.DeepCopy(self)
    if itemInfo then
        _m.AddPrice = 0
        _m.SellId = itemInfo.sellId;
        _m.ItemId = itemInfo.itemId;
        _m.Index = itemInfo.sort;
        _m.CoinType = itemInfo.coinType;
        _m.Price = itemInfo.coinNum;
        _m.OrigionPrice = itemInfo.originalCoinNum;
        _m.Hot = itemInfo.hot;
        _m.Discount = itemInfo.discount
        _m.BuyBind = itemInfo.bind == 1;
        _m.TimeOut = itemInfo.duration;
        _m.LostTime = itemInfo.lostTime;
        _m.BuyLimit = itemInfo.buyLimit;
        _m.IsDisCount = itemInfo.isdiscount
        _m.VipLv = itemInfo.vipLevel
        _m.Occ = -1
        if itemInfo.buyLimit and itemInfo.buyNum then
            _m.AlreadyBuyNum = itemInfo.buyNum;
        else
            _m.AlreadyBuyNum = 0
        end
        _m.BuyLv = itemInfo.level;
        _m.GuildLv = itemInfo.guildLevel;
        _m.MilitaryRanklevel = itemInfo.militaryRankLevel;
        _m.LimitType = itemInfo.limitType;
        _m.ItemInfo = CS.Thousandto.Code.Logic.ItemBase.CreateItemBase(itemInfo.itemId)
        if itemInfo.discount > 0 and itemInfo.hot == 1 then
            _m.Price = itemInfo.coinNum
        else
            _m.Price = itemInfo.originalCoinNum;
        end
        if itemInfo.countdiscount then
            _m.CountdisCount = itemInfo.countdiscount
            _m:SetAddPrice()
        end
        if itemInfo.shopType then
            local _arr = Utils.SplitNumber(itemInfo.shopType, '_')
            _m.ItemTypeList:Clear()
            for i = 1, #_arr do
                _m.ItemTypeList:Add(_arr[i])
            end
        end
    end
    return _m
end

-- Create new data according to the configuration table
function ShopData:NewWithCfg(cfg)
    local _m = Utils.DeepCopy(self)
    if cfg then
        _m.AddPrice = 0
        _m.SellId = cfg.ID;
        _m.ItemId = cfg.ItemID;
        _m.Index = cfg.Sort;
        _m.CoinType = cfg.CurrencyID;
        _m.Price = cfg.DiscountPrice;
        _m.OrigionPrice = cfg.Price;
        _m.Hot = cfg.Promotion;
        _m.Discount = cfg.Discount
        _m.BuyBind = cfg.Bind == 1;
        _m.TimeOut = cfg.Duration;
        _m.LostTime = cfg.Overdue;
        _m.BuyLimit = cfg.BuyNum;
        _m.AlreadyBuyNum = 0
        _m.BuyLv = cfg.Level;
        _m.Occ = cfg.Occupation
        _m.VipLv = cfg.VipLevel
        _m.GuildLv = cfg.GuildLevel;
        _m.MilitaryRanklevel = cfg.MilitaryLevel;
        _m.LimitType = cfg.LimitType;
        _m.IsDisCount = cfg.IsDiscount
        _m.ItemInfo = CS.Thousandto.Code.Logic.ItemBase.CreateItemBase(cfg.ItemID)
        _m.OpenDay = cfg.OpenDay
        _m.CloseDay = cfg.CloseDay
        if cfg.Discount > 0 and cfg.Promotion == 1 then
            _m.Price = cfg.DiscountPrice
        else
            _m.Price = cfg.Price;
        end
        if cfg.countdiscount then
            _m.CountdisCount = cfg.CountDiscount
            _m:SetAddPrice()
        end
        if cfg.ShopType then
            local _arr = Utils.SplitNumber(cfg.ShopType, '_')
            _m.ItemTypeList:Clear()
            for i = 1, #_arr do
                _m.ItemTypeList:Add(_arr[i])
            end
        end
    end
    return _m
end

function ShopData:SetAddPrice()
    if self.CountdisCount and self.CountdisCount ~= "" and self.AlreadyBuyNum then
        local _ar = Utils.SplitStr(self.CountdisCount, ';')
        for i = 1, #_ar do
            local _sin = Utils.SplitNumber(_ar[i], '_')
            if _sin[1] and _sin[2] and _sin[3] and self.AlreadyBuyNum + 1 >= _sin[1] and self.AlreadyBuyNum + 1 <= _sin[2] then
                self.AddPrice = _sin[3]
                break
            end
        end
    end
end

-- Create new as ShopData object
function ShopData:New(data)
    local _m = Utils.DeepCopy(self)
    _m = data
    return _m
end

function ShopData:CheckOcc(occ)
    if occ == nil or self.Occ == -1 then
        return true
    end
    return occ == self.Occ
end

function ShopData:CheckOpenTime()
    if self.CloseDay == nil then
        return true
    end
    if tonumber( self.CloseDay ) == 0 then
        return true
    elseif tonumber( self.CloseDay ) >= Time.GetOpenSeverDay() then
        return true
    else
        return false
    end
end
return ShopData