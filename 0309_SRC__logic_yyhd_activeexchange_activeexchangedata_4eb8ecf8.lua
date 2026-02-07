------------------------------------------------
-- Author: 
-- Date: 2020-08-24
-- File: ActiveExchangeData.lua
-- Module: ActiveExchangeData
-- Description: Active redemption data
------------------------------------------------
local BaseData = require("Logic.YYHD.YYHDBaseData")
local ItemData = require("Logic.YYHD.YYHDItemData")

local ActiveExchangeData = {
    -- Redemption list
    ItemList = nil,
    -- Rewards received
    AlreadyGetIds = nil,
}

function ActiveExchangeData:New(typeId)
    local _n = Utils.DeepCopy(self)
    local _mn = setmetatable(_n, {__index = BaseData:New(typeId)})
    return _mn
end

-- Parse activity configuration data
function ActiveExchangeData:ParseSelfCfgData(jsonTable)
    self.ItemList = List:New()
    for k, v in pairs(jsonTable) do
        local _itemList = List:New()
        if v.awardList ~= nil then
            for ik, iv in pairs(v.awardList) do
                _itemList:Add(ItemData:New(iv))
            end
        end
        self.ItemList:Add({
            NeedValue = tonumber(k),
            ItemList = _itemList,
            ShowItemId = v.showItem
        })
    end
end

-- Analyze the data of active players
function ActiveExchangeData:ParsePlayerData(jsonTable)
    if not self:IsActive() then
        return
    end
    self.AlreadyGetIds = {}
    if jsonTable.isGets ~= nil then
        for k, v in pairs(jsonTable.isGets) do
            if v ~= 0 then
                self.AlreadyGetIds[tonumber(k)] = true
            end
        end
    end
end

-- Refresh data
function ActiveExchangeData:RefreshData()
    if not self:IsActive() then
        return
    end
    local _sortFunc = function (left, right)
        local _lGeted = self.AlreadyGetIds[left.NeedValue]
        local _lSortValue = _lGeted and (100000000 + left.NeedValue) or left.NeedValue
        local _rGeted = self.AlreadyGetIds[right.NeedValue]
        local _rSortValue = _rGeted and (100000000 + right.NeedValue) or right.NeedValue
        return _lSortValue < _rSortValue
    end
    -- Sort by recharge quantity
    self.ItemList:Sort(_sortFunc)

    -- Detect red dots
    self:RemoveRedPoint()
    for i = 1, #self.ItemList do
        local _need = self.ItemList[i].NeedValue
        if self.AlreadyGetIds[_need] ~= true then
            self:AddRedPoint(i, {{27, _need}}, nil, nil, nil, nil)
        end
    end
end

-- Processing operational activities return
function ActiveExchangeData:ResActivityDeal(jsonTable)
end

-- Request for a prize
function ActiveExchangeData:ReqGetAward(id)
    local _json = string.format("{\"request\":\"reqAward\",\"coinNum\":%d}", id)
    GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {type = self.TypeId, data = _json})
end

return ActiveExchangeData