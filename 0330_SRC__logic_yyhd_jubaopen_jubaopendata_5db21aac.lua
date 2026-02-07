------------------------------------------------
-- Author: 
-- Date: 2021-06-16
-- File: JuBaoPenData.lua
-- Module: JuBaoPenData
-- Description: Cornucopia Data
------------------------------------------------
local BaseData = require("Logic.YYHD.YYHDBaseData")
local ItemData = require("Logic.YYHD.YYHDItemData")
local JuBaoPenData = {
    -- Configuration data
    AwardList = nil, -- List of rewards displayed
    CostItemId = 0, -- The item id consumed in the lottery, the quantity consumed at 1 per time
    CostItemName = nil,-- The name of the item consumed in the lottery
    CostGoldCount = 0, -- The number of gold ingots consumed in the lottery
    CountAwardList = nil,-- Number of reward list {Count, ItemList}
    GoldAwardPercent = 0, -- Golden ingot spit percentage
    GoldMaxCount = 0,-- Maximum number of gold ingots
    -- Purchase free props
    GiveItemName = nil,
    GiveItemCount = 0,
    -- Guaranteed reward
    BaoDiCfgList = nil,
    -- Active Reward Configuration
    HuoYueCfg = nil,

    -- Player data
    AllGoldCount = 0, -- Total ingot count
    GoldRecordList = nil, -- Gold Yuanbao Reward Record {Count}
    SelfRecordList = nil, -- Self-record {ItemId, Count}
    WorldRecordList = nil, -- World Record {RoleName, ItemId, Count}
    SelfGetCount = 0,  -- Number of draws by yourself
    SelfCountAwardTable = nil, -- Rewards for the number of times you have received
    -- Guaranteed collection status
    BaoDiGetState = nil,
    -- The number of guaranteed draws
    BaoDiAwardCount = 0,
    -- Active rewards to receive data
    HuoYueGetState = nil,

    -- Client data
    IsJumpAnim = false, -- Whether to skip animation
    -- Do you ask for purchase
    IsJumpAskBuy = false,

    -- List of items for display
    ResultItemList = nil,
    -- List of ingots for display
    ResultGoldList = nil,

    FrontShowRedPoint = nil,
    -- The last active point tested
    FrontCheckHuoYue = nil,
}

function JuBaoPenData:New(typeId)
    local _n = Utils.DeepCopy(self)
    local _mn = setmetatable(_n, {
        __index = BaseData:New(typeId)
    })
    return _mn
end

-- Parse activity configuration data
function JuBaoPenData:ParseSelfCfgData(jsonTable)
    self.AwardList = List:New()
    for i = 1, #jsonTable.AwardList do
        local _awardTabel = {}
        local _award = jsonTable.AwardList[i]
        for j = 1, #_award do
            local _itemData = ItemData:New(_award[j])
            _awardTabel[_itemData.Occ] = _itemData
        end
        self.AwardList:Add(_awardTabel)
    end
    self.CostGoldCount = jsonTable.CostGoldCount
    self.CostItemId = jsonTable.CostItemId
    self.GoldAwardPercent = jsonTable.GoldAwardPercent
    self.GoldAwardPercent = jsonTable.GoldAwardPercent
    self.GoldMaxCount = jsonTable.goldOneMaxCount or 0
    self.CountAwardList = List:New()
    for k, v in pairs(jsonTable.CountAwardList) do
        local _count = tonumber(k)
        local _itemList = List:New()
        for i = 1, #v do
            local _itemData = ItemData:New(v[i])
            _itemList:Add(_itemData)
        end
        self.CountAwardList:Add({
            Count = _count,
            Items = _itemList,
        })
    end
    self.CountAwardList:Sort(function(x,y)
        return x.Count < y.Count
    end)
    if jsonTable.giftData ~= nil then
        self.GiveItemName = DataConfig.DataItem[jsonTable.giftData.i].Name
        self.GiveItemCount = jsonTable.giftData.n
    end
    self.CostItemName = DataConfig.DataItem[self.CostItemId].Name
    self.IsJumpAskBuy = false

    self.BaoDiCfgList = List:New()
    if jsonTable.lowestData ~= nil then
        for k, v in pairs(jsonTable.lowestData) do
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
    self.HuoYueCfg = {}
    if jsonTable.freeGiftMap ~= nil then
        for k, v in pairs(jsonTable.freeGiftMap) do
            local _itemList = List:New()
            for i = 1, #v do
                local _item = ItemData:New(v[i])
                _itemList:Add(_item)
            end
            self.HuoYueCfg[tonumber(k)] = _itemList
        end
    end
end

-- Analyze the data of active players
function JuBaoPenData:ParsePlayerData(jsonTable)
    self.AllGoldCount = jsonTable.gold
    self.SelfGetCount = jsonTable.drawCount
    -- Guaranteed state
    self.BaoDiGetState = {}
    if jsonTable.drawLowestMap ~= nil then
        for k, v in pairs(jsonTable.drawLowestMap) do
            self.BaoDiGetState[tonumber(k)] = (v ~= 0)
        end
    end
    self.BaoDiAwardCount = jsonTable.drawLowestCount
    if jsonTable.operate == 0 then -- 0 Go online
        -- Refresh all records
        self:AddRecord(jsonTable, true)
        -- Refresh Reward
        self.SelfCountAwardTable = {}
        for k, v in pairs(jsonTable.countReward) do
            self.SelfCountAwardTable[tonumber(k)] = v
        end
        self.HuoYueGetState = {}
        if jsonTable.activeState ~= nil then
            for k, v in pairs(jsonTable.activeState) do
                local _value = tonumber(v)
                if _value ~= 0 then
                    self.HuoYueGetState[tonumber(k)] = true
                end
            end
        end
    elseif jsonTable.operate == 1 then -- 1 lottery
        -- Increase records and display rewards
        self:AddRecord(jsonTable, false)
        if self.ResultItemList == nil then
            self.ResultItemList = List:New()
        end
        self.ResultItemList:Clear()
        for i = 1, #jsonTable.reward do
            local _itemData = ItemData:New(jsonTable.reward[i])
            self.ResultItemList:Add(_itemData)
        end

        if self.ResultGoldList == nil then
            self.ResultGoldList = List:New()
        end
        self.ResultGoldList:Clear()
        for i = 1, #jsonTable.goldReward do
            self.ResultGoldList:Add(jsonTable.goldReward[i])
        end
    elseif jsonTable.operate == 2 then -- 2 Rewards
        -- Refresh Reward
        self.SelfCountAwardTable = {}
        for k, v in pairs(jsonTable.countReward) do
            self.SelfCountAwardTable[tonumber(k)] = v
        end
    elseif jsonTable.operate == 3 then -- 3 Receive activity rewards
        self.HuoYueGetState = {}
        if jsonTable.activeState ~= nil then
            for k, v in pairs(jsonTable.activeState) do
                local _value = tonumber(v)
                if _value ~= 0 then
                    self.HuoYueGetState[tonumber(k)] = true
                end
            end
        end
    end
end

-- Refresh data
function JuBaoPenData:RefreshData()
    self:RemoveRedPoint()
    local _canGetCount = false
    for i = 1, #self.CountAwardList do
        local _count = self.CountAwardList[i].Count
        if self.SelfCountAwardTable[_count] == 0 and self.SelfGetCount >= _count then
            _canGetCount = true
            break
        end
    end
    -- Item Conditions
    self:AddRedPoint(1, {{self.CostItemId, 1}}, nil, nil, nil)
    -- Rewards Reward Conditions
    if _canGetCount then
        self:AddRedPoint(2, nil, nil, nil, true)
    end
    local _curAddHuoYue = GameCenter.DailyActivitySystem.CurrActive
    -- Activity reward red dots
    for k, v in pairs(self.HuoYueCfg) do
        if self.HuoYueGetState[k] == nil and _curAddHuoYue >= k then
            self:AddRedPoint(1000 + k, nil, nil, nil, true)
        end
    end
    self.FrontCheckHuoYue = _curAddHuoYue
    self.FrontShowRedPoint = self:IsShowRedPoint()
end

function JuBaoPenData:UpdateActive()
    if self.FrontCheckHuoYue ~= GameCenter.DailyActivitySystem.CurrActive then
        -- Add red dots when activity changes
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

function JuBaoPenData:AddRecord(jsonTable, isReplace)
    if self.GoldRecordList == nil then
        self.GoldRecordList = List:New()
    end
    if self.SelfRecordList == nil then
        self.SelfRecordList = List:New()
    end
    if self.WorldRecordList == nil then
        self.WorldRecordList = List:New()
    end
    if isReplace then
        self.GoldRecordList:Clear()
        self.SelfRecordList:Clear()
        self.WorldRecordList:Clear()
    end
    for i = 1, #jsonTable.goldHistory do
        local _itemTable = Utils.SplitStr(jsonTable.goldHistory[i], "_") 
        self.GoldRecordList:Add({
            Name = _itemTable[1],
            Count = tonumber(_itemTable[2]),
        })
    end
    for i = 1, #jsonTable.selfHistory do
        local _itemTable = Utils.SplitNumber(jsonTable.selfHistory[i], "_") 
        local _name = nil
        local _quality = nil
        local _itemCfg = DataConfig.DataItem[_itemTable[1]]
        if _itemCfg ~= nil then
            _name = _itemCfg.Name
            _quality = _itemCfg.Color
        else
            local _equipCfg = DataConfig.DataEquip[_itemTable[1]]
            if _equipCfg ~= nil then
                _name = _equipCfg.Name
                _quality = _equipCfg.Quality
            end
        end
        if _name ~= nil then
            self.SelfRecordList:Add({
                ItemName = _name,
                Quality = _quality,
                Count = _itemTable[2],
            })
        end
    end
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
end
-- Processing operational activities return
function JuBaoPenData:ResActivityDeal(jsonTable)
    local _showRedPoint = self.FrontShowRedPoint
    self:ParsePlayerData(jsonTable)
    -- Detect red dots
    self:RefreshData()
    if _showRedPoint ~= self.FrontShowRedPoint then
        -- The red dot changes, refresh the activity list
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_HDLIST)
    end
    -- Refresh an event
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_HDFORM, self.TypeId)
end

-- Request a lottery
function JuBaoPenData:ReqChouJiang(isTen)
    local _once = 1
    if isTen then
        _once = 0
    end
    local _json = string.format("{\"operate\":1,\"once\":%d}", _once)
    GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {type = self.TypeId, data = _json})
end

-- Request a reward for the number of times
function JuBaoPenData:ReqGetCountAward(count)
    local _json = string.format("{\"operate\":2,\"count\":%d}", count)
    GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {type = self.TypeId, data = _json})
end

-- Request for active rewards
function JuBaoPenData:ReqGetHuoYueAward(value)
    local _json = string.format("{\"operate\":3,\"count\":%d}", value)
    GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {type = self.TypeId, data = _json})
end

return JuBaoPenData
