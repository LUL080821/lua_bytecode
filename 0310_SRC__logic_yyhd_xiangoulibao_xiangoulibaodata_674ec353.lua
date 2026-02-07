------------------------------------------------
-- Author: 
-- Date: 2020-08-24
-- File: XianGouLiBaoData.lua
-- Module: XianGouLiBaoData
-- Description: Purchase Limited Gift Pack Data
------------------------------------------------
local BaseData = require("Logic.YYHD.YYHDBaseData")
local ItemData = require("Logic.YYHD.YYHDItemData")

local XianGouLiBaoData = {
    ShopList = nil,
    BuyCountTable = nil,
}

function XianGouLiBaoData:New(typeId)
    local _n = Utils.DeepCopy(self)
    local _mn = setmetatable(_n, {__index = BaseData:New(typeId)})
    return _mn
end

-- Parse activity configuration data
function XianGouLiBaoData:ParseSelfCfgData(jsonTable)
    self.ShopList = List:New()
    for k, v in pairs(jsonTable) do
        local _itemList = List:New()
        if v.rewardDatas ~= nil then
            for _, vn in pairs(v.rewardDatas) do
                if vn.i ~= nil then
                    _itemList:Add(ItemData:New(vn))
                end
            end
        end
        self.ShopList:Add({
            ID = tonumber(k),
            Name = v.giftName,
            ItemList = _itemList,
            LimitCount = tonumber(v.buyNum),
            Price = tonumber(v.price),
            ZheKou = tonumber(v.discount),
            CoinType = tonumber(v.costCoinType)
        })
    end

    local _sortFunc = function(a, b)
        return a.ID < b.ID
    end
    self.ShopList:Sort(_sortFunc)
end

-- Analyze the data of active players
function XianGouLiBaoData:ParsePlayerData(jsonTable)
    self.BuyCountTable = {}
    if jsonTable.giftBuyData ~= nil then
        for k, v in pairs(jsonTable.giftBuyData) do
            self.BuyCountTable[tonumber(k)] = v
        end
    end
end

-- Refresh data
function XianGouLiBaoData:RefreshData()
end

-- Request a purchase
function XianGouLiBaoData:ReqBuy(id, count)
    local _json = string.format("{\"buyId\":%d,\"buyNum\":%d}", id, count)
    GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {type = self.TypeId, data = _json})
end

-- Processing operational activities return
function XianGouLiBaoData:ResActivityDeal(jsonTable)
end

return XianGouLiBaoData