------------------------------------------------
-- Author: 
-- Date: 2021-07-05
-- File: XingYunZaDanData.lua
-- Module: XingYunZaDanData
-- Description: Lucky egg smash data
------------------------------------------------
local BaseData = require("Logic.YYHD.YYHDBaseData")
local ItemData = require("Logic.YYHD.YYHDItemData")

local XingYunZaDanData = {
    -- The item id consumed by smashing eggs does not need to be configured, each time it is 1
    CostItemId = 0,
    CostItemName = nil,
    -- The number of ingots consumed in a single egg smash
    CostGoldId = 0,
    -- Purchase free props
    GiveItemName = nil,
    GiveItemCount = 0,
    -- The maximum number of egg smashes per day
    DailyMaxCount = 0,
    -- Reward list of cumulative egg smash times, each item contains the number of times and item list (needed to be ordered)
    CountAwardList = nil,
    -- Reward display list (needed to be orderly)
    ShowAwardList = nil,
    -- The id and quantity of items required to refresh the easter egg
    RefreshItemId = 0,
    RefreshItemName = nil,
    RefreshIGoldCount = 0,
    -- Guaranteed reward
    BaoDiCfgList = nil,
    -- Free bonus time interval
    FreeAwardInvert = 0,
    -- Free bonus maximum
    FreeAwardMaxCount = 0,
    -- Free bonus prop list
    FreeAwardItemList = nil,

    -- Current number of eggs
    CurCount = 0,
    -- Number of eggs smashed today
    CurDayCount = 0,
    -- Egg data list {type, item}
    EggDatas = nil,
    -- Rewards received by the number of times
    GetedAwardTable = nil,
    -- Total number of refreshes
    AllRefreshCount = 0,
    -- Record
    WorldRecordList = nil,
    -- Guaranteed collection status
    BaoDiGetState = nil,
    -- The number of guaranteed draws
    BaoDiAwardCount = 0,
    -- Current free rewards received
    CurFreeAwardCount = 0,
    -- The last time you received the reward UTC time
    FrontGetFreeTime = 0,

    -- Whether to skip the ingot consumption inquiry
    IsJumpAskBuy = false,
    -- Whether to skip refresh inquiry
    IsJumpRefreshItemAsk = false,
    IsJumpRefreshGoldAsk = false,
    FrontShowRedPoint = nil,
    -- Whether to skip animation
    IsJumpAnim = false,
    -- Whether to check the red dots of gift packages
    IsCheckFreeRedPoint = false,
}

function XingYunZaDanData:New(typeId)
    local _n = Utils.DeepCopy(self)
    local _mn = setmetatable(_n, {
        __index = BaseData:New(typeId)
    })
    return _mn
end

-- Parse activity configuration data
function XingYunZaDanData:ParseSelfCfgData(jsonTable)
    self.CostItemId = jsonTable.costItemId
    self.CostItemName = DataConfig.DataItem[self.CostItemId].Name
    self.CostGoldId = jsonTable.oneCostGold
    self.GiveItemName = DataConfig.DataItem[jsonTable.giftData.i].Name
    self.GiveItemCount = jsonTable.giftData.n
    self.DailyMaxCount = jsonTable.dailyLimitCount
    self.RefreshIGoldCount = jsonTable.refreshGoldCost
    self.RefreshItemId = jsonTable.refreshItem
    self.RefreshItemName = DataConfig.DataItem[self.RefreshItemId].Name

    self.CountAwardList = List:New()
    for k, v in pairs(jsonTable.countRewardMap) do
        local _count = tonumber(k)
        local _itemList = List:New()
        for i = 1, #v do
            local _itemData = ItemData:New(v[i])
            _itemList:Add(_itemData)
        end
        self.CountAwardList:Add({
            Count = _count,
            ItemList = _itemList
        })
    end
    self.CountAwardList:Sort(function(x,y)
        return x.Count < y.Count
    end)
    self.ShowAwardList = List:New()
    for i = 1, #jsonTable.AwardList do
        local _items = jsonTable.AwardList[i]
        for j = 1, #_items do
            local _itemData = ItemData:New(_items[j])
            self.ShowAwardList:Add(_itemData)
        end
    end
    self.BaoDiCfgList = List:New()
    if jsonTable.baodiMap ~= nil then
        for k, v in pairs(jsonTable.baodiMap) do
            local _itemList = List:New()
            for i = 1, #v.rewardData do
                local _item = ItemData:New(v.rewardData[i])
                _itemList:Add(_item)
            end
            self.BaoDiCfgList:Add({
                Index = v.index,
                Min = v.min,
                Max = v.max,
                Items = _itemList
            })
        end
    end
    self.BaoDiCfgList:Sort(function(x, y)
        return x.Index < y.Index
    end)
    self.IsJumpAnim = false

    if jsonTable.onLineTime ~= nil then
        self.FreeAwardInvert = tonumber(jsonTable.onLineTime) * 60
    end
    if jsonTable.timesLimit ~= nil then
        self.FreeAwardMaxCount = tonumber(jsonTable.timesLimit)
    end
    self.FreeAwardItemList = List:New()
    if jsonTable.freeGift ~= nil then
        for i = 1, #jsonTable.freeGift do
            local _item = jsonTable.freeGift[i]
            local _itemData = ItemData:New(_item)
            self.FreeAwardItemList:Add(_itemData)
        end
    end
end

-- Analyze the data of active players
function XingYunZaDanData:ParsePlayerData(jsonTable)
    -- Guaranteed state
    self.BaoDiGetState = {}
    if jsonTable.drawLowestMap ~= nil then
        for k, v in pairs(jsonTable.drawLowestMap) do
            self.BaoDiGetState[tonumber(k)] = (v ~= 0)
        end
    end
    self.BaoDiAwardCount = jsonTable.drawLowestCount or 0

    self.CurCount = jsonTable.drawCount
    self.CurDayCount = jsonTable.dailyCount
    self.AllRefreshCount = jsonTable.refreshEggCount
    self.EggDatas = {}
    for i = 1, #jsonTable.eggList do
        local _type = nil
        for k, v in pairs(jsonTable.eggList[i]) do
            _type = tonumber(k)
        end
        self.EggDatas[i] = {Index = i, Type = _type, Item = nil}
    end
    for k, v in pairs(jsonTable.reward) do
        local _eggIndex = tonumber(k) + 1
        self.EggDatas[_eggIndex].Item = ItemData:New(v)
    end
    self.GetedAwardTable = {}
    if jsonTable.countReward ~= nil then
        for k, v in pairs(jsonTable.countReward) do
            self.GetedAwardTable[tonumber(k)] = (v ~= 0)
        end
    end
    self.WorldRecordList = List:New()
    for i = 1, #jsonTable.serverHistory do
        local _itemTable = Utils.SplitStr(jsonTable.serverHistory[i], "_")
        local _name = nil
        local _quality = nil
        local _itemCfg = DataConfig.DataItem[tonumber(_itemTable[2])]
        if _itemCfg ~= nil then
            _name = _itemCfg.Name
            _quality = _itemCfg.Color
        else
            local _equipCfg = DataConfig.DataEquip[tonumber(_itemTable[2])]
            if _equipCfg ~= nil then
                _name = _equipCfg.Name
                _quality = _equipCfg.Quality
            end
        end
        if _name ~= nil then
            self.WorldRecordList:Add({
                Name = _itemTable[1],
                ItemName = _name,
                Quality = _quality,
                Count = tonumber(_itemTable[3]),
            })
        end
    end
    self.CurFreeAwardCount = tonumber(jsonTable.onlineCount)
    self.FrontGetFreeTime = tonumber(jsonTable.onlineTime)
end

-- Refresh data
function XingYunZaDanData:RefreshData()
    self:RemoveRedPoint(nil)
    -- If there are still times, the number of items will be red.
    if self.DailyMaxCount > self.CurDayCount then
        self:AddRedPoint(1, {{self.CostItemId, 1}}, nil, nil, nil)
    end
    local _canGetCount = false
    for i = 1, #self.CountAwardList do
        local _count = self.CountAwardList[i].Count
        if self.GetedAwardTable[_count] == false and self.CurCount >= _count then
            _canGetCount = true
            break
        end
    end
      -- Rewards Reward Conditions
      if _canGetCount then
        self:AddRedPoint(2, nil, nil, nil, true)
    end
    self.IsCheckFreeRedPoint = true
    if self.CurFreeAwardCount < self.FreeAwardMaxCount then
        local _serverTime = GameCenter.HeartSystem.ServerTime
        if _serverTime >= (self.FrontGetFreeTime + self.FreeAwardInvert) then
            self:AddRedPoint(3, nil, nil, nil, true)
            self.IsCheckFreeRedPoint = false
        end
    end
    self.FrontShowRedPoint = self:IsShowRedPoint()
end

function XingYunZaDanData:UpdateActive()
    if self.IsCheckFreeRedPoint then
        local _serverTime = GameCenter.HeartSystem.ServerTime
        if _serverTime >= (self.FrontGetFreeTime + self.FreeAwardInvert) then
            -- When the time comes, add red dots
            local _showRedPoint = self.FrontShowRedPoint
            -- Detect red dots
            self:RefreshData()
            if _showRedPoint ~= self.FrontShowRedPoint then
                -- The red dot changes, refresh the activity list
                GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_HDLIST)
            end
            -- Refresh an event
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_HDFORM, self.TypeId)
        end
    end
end

-- Processing operational activities return
function XingYunZaDanData:ResActivityDeal(jsonTable)
    local _showRedPoint = self.FrontShowRedPoint
    if jsonTable.operate == 2 then
        -- Guaranteed state
        self.BaoDiGetState = {}
        if jsonTable.drawLowestMap ~= nil then
            for k, v in pairs(jsonTable.drawLowestMap) do
                self.BaoDiGetState[tonumber(k)] = (v ~= 0)
            end
        end
        self.BaoDiAwardCount = jsonTable.drawLowestCount or 0
        -- Blow eggs back
        self.CurCount = jsonTable.drawCount
        self.CurDayCount = jsonTable.dailyCount
        local _bigAwardTable = {}
        if jsonTable.bigReward ~= nil then
            for k, v in pairs(jsonTable.bigReward) do
                local _index = tonumber(k + 1)
                _bigAwardTable[_index] = true
            end
        end
        local itemList = List:New()
        local bigItemList = List:New()
        for k, v in pairs(jsonTable.reward) do
            local _index = tonumber(k + 1)
            local _item = ItemData:New(v)
            self.EggDatas[_index].Item = _item
            if _bigAwardTable[_index] == true then
                bigItemList:Add({Id = _item.ItemID, Num = _item.ItemCount, IsBind = _item.IsBind})
            else
                itemList:Add({Id = _item.ItemID, Num = _item.ItemCount, IsBind = _item.IsBind})
            end
        end
        local _eggDataFunc = function()
            -- Refresh egg data
            for i = 1, #self.EggDatas do
                local _eggData = jsonTable.eggList[i]
                local _type = nil
                local _state = nil
                for k, v in pairs(_eggData) do
                    _type = tonumber(k)
                    _state = tonumber(v)
                end
                self.EggDatas[i].Type = _type
                if _state == 0 then
                    -- Reset items
                    self.EggDatas[i].Item = nil
                end
            end
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_HDFORM, self.TypeId)
        end
        if #bigItemList > 0 then
            GameCenter.PushFixEvent(UILuaEventDefine.UIXYZDBigWAwardForm_OPEN, {
                BigAward = bigItemList,
                NorAward = itemList,
                Callback = function()
                    _eggDataFunc()
                end
            })
        elseif #itemList > 0 then
            GameCenter.PushFixEvent(UIEventDefine.UIWelfareGetItemForm_OPEN, itemList, {
                Callback = function()
                    _eggDataFunc()
                end,
            })
        else
            _eggDataFunc()
        end

        -- Add records
        for i = 1, #jsonTable.serverHistory do
            local _itemTable = Utils.SplitStr(jsonTable.serverHistory[i], "_")
            local _name = nil
            local _quality = nil
            local _itemCfg = DataConfig.DataItem[tonumber(_itemTable[2])]
            if _itemCfg ~= nil then
                _name = _itemCfg.Name
                _quality = _itemCfg.Color
            else
                local _equipCfg = DataConfig.DataEquip[tonumber(_itemTable[2])]
                if _equipCfg ~= nil then
                    _name = _equipCfg.Name
                    _quality = _equipCfg.Quality
                end
            end
            if _name ~= nil then
                self.WorldRecordList:Add({
                    Name = _itemTable[1],
                    ItemName = _name,
                    Quality = _quality,
                    Count = tonumber(_itemTable[3]),
                })
            end
        end
    elseif jsonTable.operate == 1 then
        -- Refresh and return, clear all eggs
        for i = 1, #self.EggDatas do
            local _eggData = jsonTable.eggList[i]
            local _type = nil
            for k, _ in pairs(_eggData) do
                _type = tonumber(k)
            end
            self.EggDatas[i].Type = _type
            self.EggDatas[i].Item = nil
        end
    elseif jsonTable.operate == 3 then
        -- Rewards for the number of times
        local itemList = List:New()
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        local _occ = _lp.Occ
        for k, v in pairs(jsonTable.countReward) do
            local _count = tonumber(k)
            local _getState = self.GetedAwardTable[_count]
            local _newState = (v ~= 0)
            if _newState and _newState ~= _getState then
                -- Show Rewards
                for i = 1, #self.CountAwardList do
                    local _countAward = self.CountAwardList[i]
                    if _countAward.Count == _count then
                        for j = 1, #_countAward.ItemList do
                            local _item = _countAward.ItemList[j]
                            if _item.Occ == _occ or _item.Occ == 9 then
                                itemList:Add({Id = _item.ItemID, Num = _item.ItemCount, IsBind = _item.IsBind})
                            end
                        end
                        break
                    end
                end
            end
            self.GetedAwardTable[_count] = _newState
        end
        if #itemList > 0 then
            GameCenter.PushFixEvent(UIEventDefine.UIWelfareGetItemForm_OPEN, itemList)
        end
    elseif jsonTable.operate == 4 then
        self.CurFreeAwardCount = tonumber(jsonTable.onlineCount)
        self.FrontGetFreeTime = tonumber(jsonTable.onlineTime)
    end
    self:RefreshData()
    if _showRedPoint ~= self.FrontShowRedPoint then
        -- The red dot changes, refresh the activity list
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_HDLIST)
    end
    -- Refresh an event
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_HDFORM, self.TypeId)
end

-- Request to smash the egg
function XingYunZaDanData:ReqZaDan(index)
    local _json = string.format("{\"operate\":2,\"index\":%d}", index - 1)
    GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {type = self.TypeId, data = _json})
end

-- Request refresh of Easter eggs
function XingYunZaDanData:ReqRefresh()
    local _json = string.format("{\"operate\":1}")
    GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {type = self.TypeId, data = _json})
end

-- Request a reward for the number of times
function XingYunZaDanData:ReqGetCountAward(count)
    local _json = string.format("{\"operate\":3,\"count\":%d}", count)
    GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {type = self.TypeId, data = _json})
end

-- Request for free rewards
function XingYunZaDanData:ReqGetFreeAward()
    local _json = "{\"operate\":4}"
    GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {type = self.TypeId, data = _json})
end

return XingYunZaDanData
