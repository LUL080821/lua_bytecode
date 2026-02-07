------------------------------------------------
-- Author: 
-- Date: 2020-08-14
-- File: TuanGouData.lua
-- Module: TuanGouData
-- Description: Group purchase data
------------------------------------------------
local BaseData = require("Logic.YYHD.YYHDBaseData")

local TuanGouData = {
    -- Prop ID, possible equipment, props, holy equipment, spirit spirit, divine beast equipment, distinguished according to occupation ID
    ItemIds = 0,
    -- quantity
    ItemNum = 0,
    -- Types of currency consumed
    CostCoinType = 0,
    -- Original price
    OriPrice = 0,
    -- Number of people and price correspondence
    CountPriceList = nil,

    -- Current purchases
    CurBuyCount = 0,
    -- Have you purchased it
    IsSelfBuy = false,
}

function TuanGouData:New(typeId)
    local _n = Utils.DeepCopy(self)
    local _mn = setmetatable(_n, {__index = BaseData:New(typeId)})
    return _mn
end

-- Parse activity configuration data
function TuanGouData:ParseSelfCfgData(jsonTable)
    self.ItemIds = {}
    for k, v in pairs(jsonTable.itemId) do
        self.ItemIds[tonumber(k)] = v
    end
    self.ItemNum = jsonTable.itemNum
    self.CostCoinType = jsonTable.costCoinType
    self.OriPrice = jsonTable.oriPrice
    self.CountPriceList = List:New()
    for k, v in pairs(jsonTable.countDiscountList) do
        self.CountPriceList:Add({tonumber(k), v[2], v[1]})
    end
    self.CountPriceList:Sort(function(a, b)
        return a[1] < b[1]
    end)
end


-- Analyze the data of active players
function TuanGouData:ParsePlayerData(jsonTable)
    self.CurBuyCount = jsonTable.buyNum
    self.IsSelfBuy = jsonTable.isSelfBuy
end

-- Refresh data
function TuanGouData:RefreshData()
end

-- Send a purchase request
function TuanGouData:ReqBuy(price)
    -- Determine whether you have purchased it
    if self.IsSelfBuy then
        return
    end
    local _haveCoin = GameCenter.ItemContianerSystem:GetEconomyWithType(self.CostCoinType)
    if _haveCoin < price then
        Utils.ShowPromptByEnum("C_TUANGOU_COIN_NOTENOUGH", DataConfig.DataItem[self.CostCoinType].Name)
        GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(self.CostCoinType)
        return
    end
    GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {type = self.TypeId})
end

-- Processing operational activities return
function TuanGouData:ResActivityDeal(jsonTable)
end

return TuanGouData
