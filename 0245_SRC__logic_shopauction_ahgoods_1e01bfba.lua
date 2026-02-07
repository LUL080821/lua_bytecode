------------------------------------------------
-- Author:
-- Date: 2019-08-01
-- File: AHGoods.lua
-- Module: AHGoods
-- Description: Trading bank commodity data model
------------------------------------------------
local AHGoods = {
    -- Product unique ID
    MarketId = 0,
    -- Expiration time
    OverTime = 0,
    -- Currency type The same ID in the item configuration table
    CoinType = 0,
    -- The amount of currency
    CoinNum = 0,
    -- Seller
    TranAuthor = "",
    -- Is a password required
    HavePassWord = false,
    -- password
    Secret = nil,
    -- Item information
    ItemInfo = nil,
}

-- Create a new object according to the content of the agreement
function AHGoods:NewWithInfo(info)
    local _m = Utils.DeepCopy(self)
    if info then
        _m.MarketId = info.marketId;
        _m.ItemInfo = CS.Thousandto.Code.Logic.ItemBase.CreateItemBase(info.itemInfo.itemModelId)
        if _m.ItemInfo then
            _m.ItemInfo.Count = info.itemInfo.num
            _m.ItemInfo.DBID = info.itemInfo.itemId
        end
        _m.OverTime = info.lostTime;
        _m.CoinType = info.coinType;
        _m.CoinNum = info.coinNum;
        _m.TranAuthor = info.tranAuthor;
        _m.Secret = info.secret;
        if info.secret and info.secret ~= "" then
            _m.HavePassWord = true
        else
            _m.HavePassWord = false
        end
    end
    return _m
end

-- Create a new object according to the item ID
function AHGoods:New(id)
    local _m = Utils.DeepCopy(self)
    _m.MarketId = 0
    _m.ItemID = id
    _m.ItemNum = 0
    _m.UpTime = 0
    _m.CoinType = 0
    _m.CoinNum = 0
    _m.TranAuthor = nil
    _m.HavePassWord = false
    return _m
end
return AHGoods