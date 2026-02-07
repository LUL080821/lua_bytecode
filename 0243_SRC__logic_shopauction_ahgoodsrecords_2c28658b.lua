------------------------------------------------
-- Author:
-- Date: 2019-08-01
-- File: AHGoodsRecords.lua
-- Module: AHGoodsRecords
-- Description: Transaction line log data model
------------------------------------------------
local AHGoodsRecords = {
    -- Trading player DBID
    PlayerID = 0,
    -- Trading time
    TranTime = 0,
    -- Transaction type, 1 is for sale, 2 is for purchase
    TranType = 0,
    -- Trading player names
    TranAuthor = nil,
    -- Payment currency type
    CoinType = 0,
    -- The amount of currency
    CoinNum = 0,
    -- Trading items
    ItemInfo = nil,
}
function AHGoodsRecords:New(info)
    local _records = Utils.DeepCopy(self)
    if info then
        -- Trading player DBID
        _records.PlayerID = info.tranRoleId
        -- Trading time
        _records.TranTime = info.tranTime;
        -- Transaction type, 1 is for sale, 2 is for purchase
        _records.TranType = info.tranType;
        -- Trading player names
        _records.TranAuthor = info.tranAuthor;
        -- Payment currency type
        _records.CoinType = info.coinType;
        -- The amount of currency
        _records.CoinNum = info.coinNum
        _records.ItemInfo = CS.Thousandto.Code.Logic.ItemBase.CreateItemBase(info.itemInfo.itemModelId)
        if _records.ItemInfo then
            _records.ItemInfo.Count = info.itemInfo.num
            _records.ItemInfo.DBID = info.itemInfo.itemId
        end
    end
    return _records
end
return AHGoodsRecords