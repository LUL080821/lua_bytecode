------------------------------------------------
-- Author: 
-- Date: 2020-08-14
-- File: XianShiLeiChongData.lua
-- Module: XianShiLeiChongData
-- Description: Limited time cumulative activity data
------------------------------------------------
local BaseData = require("Logic.YYHD.YYHDBaseData")
local ItemData = require("Logic.YYHD.YYHDItemData")

local XianShiLeiChongData = {
    -- List
    ItemList = nil,
    -- Rewards received
    AlreadyGetTable = nil,
    -- Custom reward data
    CustomRewardTable = nil,
    -- Current recharge quantity
    RechargeCount = nil,
}

function XianShiLeiChongData:New(typeId)
    local _n = Utils.DeepCopy(self)
    local _mn = setmetatable(_n, {__index = BaseData:New(typeId)})
    return _mn
end

-- Parse activity configuration data
function XianShiLeiChongData:ParseSelfCfgData(jsonTable)
    self.ItemList = List:New()
    for _, v in pairs(jsonTable) do
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
            NeedRecharge = v.targetRcharge
        })
    end
end

-- Analyze the data of active players
function XianShiLeiChongData:ParsePlayerData(jsonTable)
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
    self.RechargeCount = jsonTable.rechargeNum
end

-- Refresh data
function XianShiLeiChongData:RefreshData()
    local _sortFunc = function (left, right)
        local _lGeted = self.AlreadyGetTable[left.NeedRecharge]
        local _lSortValue = _lGeted and (100000000 + left.NeedRecharge) or left.NeedRecharge
        local _rGeted = self.AlreadyGetTable[right.NeedRecharge]
        local _rSortValue = _rGeted and (100000000 + right.NeedRecharge) or right.NeedRecharge
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
        _cutCountTable[self.ItemList[i].NeedRecharge] = _countTable
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
        local _need = self.ItemList[i].NeedRecharge
        if self.RechargeCount >= _need and self.AlreadyGetTable[_need] ~= true then
            self:AddRedPoint(i, nil, nil, nil, true, nil)
        end
    end
end

-- Request a custom reward
function XianShiLeiChongData:ReqDingZhi(rechargeCount, index, itemId)
    local _json = string.format("{\"customReward\":%d,\"index\":%d,\"value\":%d}", rechargeCount, index, itemId)
    GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {type = self.TypeId, data = _json})
end

-- Request a reward
function XianShiLeiChongData:ReqGet(rechargeCount)
    if self.RechargeCount < rechargeCount then
        return
    end
    local _json = string.format("{\"getReward\":%d}", rechargeCount)
    GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {type = self.TypeId, data = _json})
end

-- Processing operational activities return
function XianShiLeiChongData:ResActivityDeal(jsonTable)
end

return XianShiLeiChongData