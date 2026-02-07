------------------------------------------------
-- Author: 
-- Date: 2020-08-14
-- File: XianShiXiaoHaoData.lua
-- Module: XianShiXiaoHaoData
-- Description: Consume activity data for limited time
------------------------------------------------
local BaseData = require("Logic.YYHD.YYHDBaseData")
local ItemData = require("Logic.YYHD.YYHDItemData")

local XianShiXiaoHaoData = {
    -- List
    ItemList = nil,
    -- Types of currency consumed by activity
    CoinType = 0,
    -- Rewards received
    AlreadyGetTable = nil,
    -- Custom reward data
    CustomRewardTable = nil,
    -- Current consumption quantity
    CostCount = 0,
}

function XianShiXiaoHaoData:New(typeId)
    local _n = Utils.DeepCopy(self)
    local _mn = setmetatable(_n, {__index = BaseData:New(typeId)})
    return _mn
end

-- Parse activity configuration data
function XianShiXiaoHaoData:ParseSelfCfgData(jsonTable)
    self.CoinType = tonumber(jsonTable.coinType)
    
    self.ItemList = List:New()
    for k, v in pairs(jsonTable.totalConsumeTargetMap) do
        local fixItems = List:New()
        if v.fixedRewardMap ~= nil then
            for i = 1, #v.fixedRewardMap do
                fixItems:Add(ItemData:New(v.fixedRewardMap[i]))
            end
        end
        local custItems = List:New()
        if v.customRewardMap ~= nil then
            for i = 1, #v.customRewardMap do
                custItems:Add(ItemData:New(v.customRewardMap[i]))
            end
        end
        self.ItemList:Add({
            -- Fixed rewards
            FixItems = fixItems,
            -- Custom Rewards
            CustItems = custItems,
            -- Optional quantity
            SelectCount = v.customlen,
            -- Need to recharge
            NeedCost = v.targetConsume
        })
    end
end

-- Analyze the data of active players
function XianShiXiaoHaoData:ParsePlayerData(jsonTable)
    -- Rewards received
    self.AlreadyGetTable = {}
    if jsonTable.alreadyGet ~= nil then
        for i = 1, #jsonTable.alreadyGet do
            self.AlreadyGetTable[jsonTable.alreadyGet[i]] = true
        end
    end
    -- Custom reward data
    self.CustomRewardTable = {}
    if jsonTable.customReward ~= nil then
        for k, v in pairs(jsonTable.customReward) do
            local _nk = tonumber(k)
            local _itemTable = {}
            for ik, iv in pairs(v) do
                local _index = tonumber(ik)
                _itemTable[_index] = {ItemID = tonumber(iv), ItemCount = 1, IsBind = false}
            end
            self.CustomRewardTable[_nk] = _itemTable
        end
    end
    -- Current recharge quantity
    self.CostCount = jsonTable.consumeNum
end

-- Refresh data
function XianShiXiaoHaoData:RefreshData()
    local _sortFunc = function (left, right)
        local _lGeted = self.AlreadyGetTable[left.NeedCost]
        local _lSortValue = _lGeted and (100000000 + left.NeedCost) or left.NeedCost
        local _rGeted = self.AlreadyGetTable[right.NeedCost]
        local _rSortValue = _rGeted and (100000000 + right.NeedCost) or right.NeedCost
        return _lSortValue < _rSortValue
    end
    -- Sort by recharge quantity
    self.ItemList:Sort(_sortFunc)

    local _cutCountTable = {}
    for i = 1, #self.ItemList do
        local _cutItems = self.ItemList[i].CustItems
        local _countTable = {}
        for j = 1, #_cutItems do
            _countTable[_cutItems[j].ItemID] = {_cutItems[j].ItemCount, _cutItems[j].IsBind}
        end
        _cutCountTable[self.ItemList[i].NeedCost] = _countTable
    end

    for k, v in pairs(self.CustomRewardTable) do
        local _countTable = _cutCountTable[k]
        if _countTable ~= nil then
            for _, cv in pairs(v) do
                local _countAndBind = _countTable[cv.ItemID]
                if _countAndBind ~= nil then
                    cv.ItemCount = _countAndBind[1]
                    cv.IsBind = _countAndBind[2]
                end
            end
        end
    end

     -- Detect red dots
     self:RemoveRedPoint()
     for i = 1, #self.ItemList do
         local _need = self.ItemList[i].NeedCost
         if self.CostCount >= _need and self.AlreadyGetTable[_need] ~= true then
             self:AddRedPoint(i, nil, nil, nil, true, nil)
         end
     end
end

-- Request a custom reward
function XianShiXiaoHaoData:ReqDingZhi(costCount, index, itemId)
    local _json = string.format("{\"customReward\":%d,\"index\":%d,\"value\":%d}", costCount, index, itemId)
    GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {type = self.TypeId, data = _json})
end

-- Request a reward
function XianShiXiaoHaoData:ReqGet(costCount)
    if self.CostCount < costCount then
        return
    end
    local _json = string.format("{\"getReward\":%d}", costCount)
    GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {type = self.TypeId, data = _json})
end

-- Processing operational activities return
function XianShiXiaoHaoData:ResActivityDeal(jsonTable)
end

return XianShiXiaoHaoData