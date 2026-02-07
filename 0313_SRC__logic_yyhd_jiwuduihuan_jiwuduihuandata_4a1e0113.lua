------------------------------------------------
-- Author: 
-- Date: 2020-09-09
-- File: JiWuDuiHuanData.lua
-- Module: JiWuDuiHuanData
-- Description: Collection redemption data
------------------------------------------------
local BaseData = require("Logic.YYHD.YYHDBaseData")
local ItemData = require("Logic.YYHD.YYHDItemData")

local JiWuDuiHuanData = {
    -- Consumed item ID
    CostItemID = 0,
    -- Product List
    ItemList = nil,

    -- Number of purchases
    BuyCountTable = nil,
    -- Consumed items Icon
    CostItemIcon = 0,
    -- Show red dots
    ShowRedPoint = true,
}

function JiWuDuiHuanData:New(typeId)
    local _n = Utils.DeepCopy(self)
    local _mn = setmetatable(_n, {__index = BaseData:New(typeId)})
    return _mn
end

-- Parse activity configuration data
function JiWuDuiHuanData:ParseSelfCfgData(jsonTable)
    self.CostItemID = jsonTable.exChangeMaterialsId
    self.ItemList = List:New()
    for k, v in pairs(jsonTable.exChangeDataMap) do
        self.ItemList:Add({
            ID = tonumber(k),
            Price = v.exChangePrice,
            Times = v.exChangeTimes,
            Item = ItemData:New(v.rewardData)
        })
    end

    self.ItemList:Sort(function(a, b)
        return a.ID < b.ID
    end)
end


-- Analyze the data of active players
function JiWuDuiHuanData:ParsePlayerData(jsonTable)
    self.BuyCountTable = {}
    for v, k in pairs(jsonTable.exChangeList) do
        self.BuyCountTable[tonumber(v)] = k
    end
end

-- Refresh data
function JiWuDuiHuanData:RefreshData()
    -- Detect red dots
    self:RemoveRedPoint()
    if self.ShowRedPoint then
        self:AddRedPoint(0, nil, nil, nil, true, nil)
    end
    local _minNeedCount = nil
    for i = 1, #self.ItemList do
        local _item = self.ItemList[i]
        local _buyCount = self.BuyCountTable[_item.ID]
        if _buyCount == nil then
            _buyCount = 0
        end
        if _item.Times <= 0 or _buyCount < _item.Times then
            if _minNeedCount == nil or _item.Price < _minNeedCount then
                _minNeedCount = _item.Price
            end
        end
    end
    if _minNeedCount ~= nil then
        self:AddRedPoint(1, {{self.CostItemID, _minNeedCount}}, nil, nil, nil, nil)
    end
    local _costCfg = DataConfig.DataItem[self.CostItemID]
    self.CostItemIcon = _costCfg.Icon
end
-- Buy
function JiWuDuiHuanData:ReqBuy(id, count)
    local _json = string.format("{\"exChange\":%d,\"num\":%d}", id, count)
    GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {type = self.TypeId, data = _json})
end

-- Processing operational activities return
function JiWuDuiHuanData:ResActivityDeal(jsonTable)
end

return JiWuDuiHuanData
