------------------------------------------------
-- Author:
-- Date: 2020-10-16
-- File: BossHappyData.lua
-- Module: BossHappyData
-- Description: Chief Carnival Data (Christmas)
------------------------------------------------
local BaseData = require("Logic.YYHD.YYHDBaseData")
local ItemData = require("Logic.YYHD.YYHDItemData")
local ModelData = require("Logic.YYHD.YYHDModelData")

local BossHappyData = {
    -- Treasure box
    BoxItem = nil,
    -- Display item list
    ShowItemList = nil,
    -- BOSS Help Pack List
    BuyItemList = nil,
    -- Model data
    ModelData = nil,
}

function BossHappyData:New(typeId)
    local _n = Utils.DeepCopy(self)
    local _mn = setmetatable(_n, {__index = BaseData:New(typeId)})
    return _mn
end

-- Parse activity configuration data
function BossHappyData:ParseSelfCfgData(jsonTable)
    self.ShowItemList = List:New()
    self.BuyItemList = List:New()
    if jsonTable.showItems ~= nil then
        for ik, iv in pairs(jsonTable.showItems) do
            self.ShowItemList:Add(ItemData:New(iv))
        end
    end
    if jsonTable.boxId ~= nil then
        self.BoxItem = tonumber(jsonTable.boxId)
    end
    if jsonTable.goods then
        for ik, iv in pairs(jsonTable.goods) do
            local _item = {}
            _item.Id = iv.id
            _item.CoinType = iv.coin
            _item.LimitNum = iv.limit
            _item.Price = iv.price
            _item.BuyNum = 0
            _item.Item = ItemData:New(iv.item)
            self.BuyItemList:Add(_item)
        end
    end
    if jsonTable.magicId ~= nil then
        local _magicTable = Json.decode(jsonTable.magicId)
        self.ModelData = ModelData:New(_magicTable)
    end
end

-- Analyze the data of active players
function BossHappyData:ParsePlayerData(jsonTable)
    if jsonTable.shopHistory then
        for ik, iv in pairs(jsonTable.shopHistory) do
            for i = 1, #self.BuyItemList do
                if self.BuyItemList[i].Id == iv.id then
                    self.BuyItemList[i].BuyNum = iv.buy
                    break
                end
            end
        end
    end
end

-- Refresh data
function BossHappyData:RefreshData()
    -- local _sortFunc = function (left, right)
    --     local _lGeted = self.AlreadyGetIds[left.NeedValue]
    --     local _lSortValue = _lGeted and (100000000 + left.NeedValue) or left.NeedValue
    --     local _rGeted = self.AlreadyGetIds[right.NeedValue]
    --     local _rSortValue = _rGeted and (100000000 + right.NeedValue) or right.NeedValue
    --     return _lSortValue < _rSortValue
    -- end
    -- --Sorted by recharge quantity
    -- self.ItemList:Sort(_sortFunc)

    -- --Detection of red dots
    -- self:RemoveRedPoint()
    -- for i = 1, #self.ItemList do
    --     local _need = self.ItemList[i].NeedValue
    --     if self.AlreadyGetIds[_need] ~= true then
    --         self:AddRedPoint(i, {{27, _need}}, nil, nil, nil, nil)
    --     end
    -- end
end

-- Processing operational activities return
function BossHappyData:ResActivityDeal(jsonTable)
    if jsonTable.goodsId then
        for i = 1, #self.BuyItemList do
            if self.BuyItemList[i].Id == jsonTable.goodsId then
                self.BuyItemList[i].BuyNum = jsonTable.count
                break
            end
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_HDFORM, self.TypeId)
end

-- Request for a prize
function BossHappyData:ReqGetAward(id)
    local _json = string.format("{\"goodsId\":%d}", id)
    GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {type = self.TypeId, data = _json})
end

return BossHappyData