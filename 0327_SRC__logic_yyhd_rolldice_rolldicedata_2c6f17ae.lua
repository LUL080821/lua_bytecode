------------------------------------------------
-- Author:
-- Date: 2020-12-21
-- File: RollDiceData.lua
-- Module: RollDiceData
-- Description: Dice roll activity
------------------------------------------------
local BaseData = require("Logic.YYHD.YYHDBaseData")
local ItemData = require("Logic.YYHD.YYHDItemData")

local RollDiceData = {
    -- Grid information
    GridInfoList = nil,
    -- Reward for personal clearance
    PlayerTimesList = nil,
    -- Reward for clearances for the entire server
    ServerTimesList = nil,
    -- Dice information
    DiceInfo = nil,
    -- Ingot consumption
    GoldCost = 0,
    CostMoneyType = 1,
    -- Treasure Box Data
    SpecialBoxItem = nil,
    -- Current number of personal clearances and number of clearances for the entire server
    CurPlayerTimes = 0,
    CurServerTimes = 0,
    -- Current location
    PlayerIndex = 0,
    -- Personal pass rewards that have been received
    ReceiveTimesList = nil,
    -- Dice points
    JunpNumList = List:New(),
    TotalJunpNum = 0,
    -- Number of times you pass the mark after rolling the dice
    CrossIndex = 0,
    -- Whether to skip animation
    NoEffect = false,
    -- Guaranteed reward
    BaoDiCfgList = nil,
    -- Guaranteed collection status
    BaoDiGetState = nil,
    -- The number of guaranteed draws
    BaoDiAwardCount = 0,
}

function RollDiceData:New(typeId)
    local _n = Utils.DeepCopy(self)
    local _mn = setmetatable(_n, {__index = BaseData:New(typeId)})
    return _mn
end

-- Parse activity configuration data
function RollDiceData:ParseSelfCfgData(jsonTable)
    self.GridInfoList = List:New()
    self.PlayerTimesList = List:New()
    self.ServerTimesList = List:New()
    if jsonTable.cost then
        self.DiceInfo = ItemData:New(jsonTable.cost)
    end
    if jsonTable.costGold then
        self.GoldCost = jsonTable.costGold
    end

    -- Grid information
    if jsonTable.grids ~= nil then
        local _count = #jsonTable.grids
        for i = 1, _count - 1 do
            local _item = {}
            _item.ShowItemList = List:New()
            if jsonTable.grids[i] then
                for mk, mv in pairs (jsonTable.grids[i]) do
                    _item.ShowItemList:Add(ItemData:New(mv))
                end
            end
            self.GridInfoList:Add(_item)
        end
        local _item = {}
        _item.ShowItemList = List:New()
        if jsonTable.grids[_count] then
            for mk, mv in pairs (jsonTable.grids[_count]) do
                _item.ShowItemList:Add(ItemData:New(mv))
            end
        end
        self.SpecialBoxItem = _item
    end
    -- Reward information for players passing the level
    if jsonTable.playerTimes then
        for ik, iv in pairs(jsonTable.playerTimes) do
            local _item = {}
            _item.Num = tonumber(iv.proc)
            _item.ShowItemList = List:New()
            if iv.items then
                for mk, mv in pairs (iv.items) do
                    _item.ShowItemList:Add(ItemData:New(mv))
                end
            end
            self.PlayerTimesList:Add(_item)
        end
    end
    self.PlayerTimesList:Sort(function(a, b)
        return a.Num < b.Num
    end)
    -- Reward information for clearance times for the entire server
    if jsonTable.serverTimes then
        for ik, iv in pairs(jsonTable.serverTimes) do
            local _item = {}
            _item.Num = tonumber(iv.proc)
            _item.ShowItemList = List:New()
            if iv.items then
                for mk, mv in pairs (iv.items) do
                    _item.ShowItemList:Add(ItemData:New(mv))
                end
            end
            self.ServerTimesList:Add(_item)
        end
    end
    self.ServerTimesList:Sort(function(a, b)
        return a.Num < b.Num
    end)
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
end

-- Analyze the data of active players
function RollDiceData:ParsePlayerData(jsonTable)
    -- Debug.LogTableYellow(jsonTable)
    self.JunpNumList:Clear()
    self.TotalJunpNum = 0
    self.CrossIndex = 0
    -- Guaranteed state
    self.BaoDiGetState = {}
    if jsonTable.drawLowestMap ~= nil then
        for k, v in pairs(jsonTable.drawLowestMap) do
            self.BaoDiGetState[tonumber(k)] = (v ~= 0)
        end
    end
    self.BaoDiAwardCount = jsonTable.drawLowestCount or 0
    if jsonTable.playerTimes then
        self.CurPlayerTimes = tonumber(jsonTable.playerTimes)
    end
    if jsonTable.serverTimes then
        self.CurServerTimes = tonumber(jsonTable.serverTimes)
    end
    if jsonTable.jumpGrids then
        for mk, mv in pairs (jsonTable.jumpGrids) do
            self.PlayerIndex = tonumber(mv)
        end
    end
    self.ReceiveTimesList = List:New()
    if jsonTable.rewardHistory then
        for mk, mv in pairs (jsonTable.rewardHistory) do
            self.ReceiveTimesList:Add(tonumber(mv))
        end
    end
end

-- Refresh data
function RollDiceData:RefreshData()
    local _isRed = false
    for i = 1, #self.PlayerTimesList do
        if self.CurPlayerTimes >= self.PlayerTimesList[i].Num and not self.ReceiveTimesList:Contains(self.PlayerTimesList[i].Num) then
            _isRed = true
            break
        end
    end
    -- Detect red dots
    self:RemoveRedPoint()
    self:AddRedPoint(0, nil, nil, nil, _isRed, nil)
    if self.DiceInfo then
        self:AddRedPoint(1, {{self.DiceInfo.ItemID, self.DiceInfo.ItemCount}}, nil, nil, nil, nil)
    end
end

-- Processing operational activities return
function RollDiceData:ResActivityDeal(jsonTable)
    -- Debug.LogTableYellow(jsonTable)
    -- Guaranteed state
    if jsonTable.drawLowestMap ~= nil then
        self.BaoDiGetState = {}
        for k, v in pairs(jsonTable.drawLowestMap) do
            self.BaoDiGetState[tonumber(k)] = (v ~= 0)
        end
    end
    if jsonTable.drawLowestCount then
        self.BaoDiAwardCount = jsonTable.drawLowestCount
    end
    if jsonTable.playerTimes then
        local _curNum = tonumber(jsonTable.playerTimes)
        if self.CurPlayerTimes then
            self.CrossIndex = _curNum - self.CurPlayerTimes
        end
        self.CurPlayerTimes = _curNum
    end
    if jsonTable.serverTimes then
        self.CurServerTimes = tonumber(jsonTable.serverTimes)
    end
    if jsonTable.openGrid then
        self.PlayerIndex = tonumber(jsonTable.openGrid)
    end
    if not self.JunpNumList then
        self.JunpNumList = List:New()
    else
        self.JunpNumList:Clear()
    end
    self.TotalJunpNum = 0
    if jsonTable.jump then
        for mk, mv in pairs (jsonTable.jump) do
            self.JunpNumList:Add(tonumber(mv))
            self.TotalJunpNum = self.TotalJunpNum + tonumber(mv)
        end
    end
    if jsonTable.bigRewards then
        if not self.BigReward then
            self.BigReward = List:New()
        else
            self.BigReward:Clear()
        end
        for mk, mv in pairs (jsonTable.bigRewards) do
            -- _m.ItemID = itemTable.i
            -- _m.ItemCount = itemTable.n
            -- _m.Occ = itemTable.c
            -- _m.IsBind = itemTable.b ~= 0
            self.BigReward:Add(ItemData:New(mv))
        end
    end
    if jsonTable.rewards then
        if not self.NormalReward then
            self.NormalReward = List:New()
        else
            self.NormalReward:Clear()
        end
        for mk, mv in pairs (jsonTable.rewards) do
            -- _m.ItemID = itemTable.i
            -- _m.ItemCount = itemTable.n
            -- _m.Occ = itemTable.c
            -- _m.IsBind = itemTable.b ~= 0
            self.NormalReward:Add(ItemData:New(mv))
        end
    end
    if jsonTable.selfHistory then
        for mk, mv in pairs (jsonTable.selfHistory) do
            local _num = tonumber(mv)
            if not self.ReceiveTimesList:Contains(_num) then
                self.ReceiveTimesList:Add(_num)
            end
        end
    end
    self:RefreshData()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_HDFORM, self.TypeId)
end

-- Request for a prize
function RollDiceData:ReqGetAward(type, id, num, needNum)
    if type == 0 then
        if id == 1 then
            if GameCenter.ItemContianerSystem:GetItemCountFromCfgId(self.CostMoneyType) < self.GoldCost * needNum then
                Utils.ShowMsgBox(function(k)
                    if k == MsgBoxResultCode.Button2 then
                        GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(ItemTypeCode.Gold)
                    end
                end, "C_UI_EQUIPWASH_TIPS3")
            end
        end
        local _json = string.format("{\"opt\":%d,\"isGold\":%d,\"num\":%d}", type, id, num)
        GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {type = self.TypeId, data = _json})
    elseif type == 1 then
        local _json = string.format("{\"opt\":%d,\"times\":%d}", type, id)
        GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {type = self.TypeId, data = _json})
    end
end

return RollDiceData