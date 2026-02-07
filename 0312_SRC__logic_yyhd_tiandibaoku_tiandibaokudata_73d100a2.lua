------------------------------------------------
-- Author: 
-- Date: 2020-09-08
-- File: TianDiBaoKuData.lua
-- Module: TianDiBaoKuData
-- Description: Tiandi Treasure Library Data
------------------------------------------------
local BaseData = require("Logic.YYHD.YYHDBaseData")
local ItemData = require("Logic.YYHD.YYHDItemData")

local TianDiBaoKuData = {
    -- Reward list
    CardList = nil,
    -- Grand Prize List
    BigList = nil,
    -- Progress reward list
    ProList = nil,
    -- Maximum progress value
    MaxProValue = nil,
    -- Round reward list
    RoundList = nil,
    -- Consumable prop ID
    CostItem = 0,
    -- The number of ingots consumed
    UseGold = 0,
    -- Purchase free props
    GiveItemName = nil,
    GiveItemCount = 0,
    -- Guaranteed reward
    BaoDiCfgList = nil,

    -- Flop reward data
    CardAwardTable = nil,
    -- Current round
    CurRound = 0,
    -- Number of players' draws
    PlayerCount = 0,
    -- Server lottery times
    ServerCount = 0,
    -- Round reward collection information
    RoundAwardTable = nil,
    -- Progress reward collection information
    ProAwardTable = nil,
    -- Personal records
    PlayerRecord = nil,
    -- Server Record
    ServerRecord = nil,
    -- Guaranteed collection status
    BaoDiGetState = nil,
    -- The number of guaranteed draws
    BaoDiAwardCount = 0,

    -- Whether to skip animation
    IsJumpAnim = false,
    -- Is it prompted to buy
    IsJumpAskBuy = false,
}

function TianDiBaoKuData:New(typeId)
    local _n = Utils.DeepCopy(self)
    local _mn = setmetatable(_n, {__index = BaseData:New(typeId)})
    return _mn
end

-- Parse activity configuration data
function TianDiBaoKuData:ParseSelfCfgData(jsonTable)
    self.CostItem = jsonTable.costItem
    self.UseGold = jsonTable.gold or 0
    if jsonTable.goldGift ~= nil then
        self.GiveItemName = DataConfig.DataItem[jsonTable.goldGift.i].Name
        self.GiveItemCount = jsonTable.goldGift.n
    end
    self.CardList = List:New()
    self.BigList = List:New()
    for k, v in pairs(jsonTable.draws) do
        local _item = ItemData:New(v.item)
        self.CardList:Add({
            ID = v.id,
            IsBig = v.big ~= 0,
            Item = _item
        })
        if v.big ~= 0 then
            self.BigList:Add(_item)
        end
    end
    self.CardList:Sort(function(a, b)
        return a.ID < b.ID
    end)

    self.ProList = List:New()
    for k, v in pairs(jsonTable.prcs) do
        self.ProList:Add({
            PPro = v.p_reach,
            SPro = v.s_reach,
            Item = ItemData:New(v.item)
        })
    end
    self.ProList:Sort(function(a, b)
        return a.SPro < b.SPro
    end)
    self.MaxProValue = self.ProList[#self.ProList].SPro

    self.RoundList = List:New()
    for k, v in pairs(jsonTable.rounds) do
        self.RoundList:Add({
            Round = v.round,
            Item = ItemData:New(v.item)
        })
    end
    self.RoundList:Sort(function(a, b)
        return a.Round < b.Round
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
function TianDiBaoKuData:ParsePlayerData(jsonTable)
    -- Guaranteed state
    self.BaoDiGetState = {}
    if jsonTable.drawLowestMap ~= nil then
        for k, v in pairs(jsonTable.drawLowestMap) do
            self.BaoDiGetState[tonumber(k)] = (v ~= 0)
        end
    end
    self.BaoDiAwardCount = jsonTable.drawLowestCount or 0
    self.CardAwardTable = {}
    for k, v in pairs(jsonTable.open_cells) do
        self.CardAwardTable[tonumber(k)] = ItemData:New(v.item)
    end
    self.CurRound = jsonTable.player_big
    self.PlayerCount = jsonTable.player_prc
    self.ServerCount = jsonTable.server_prc
    self.RoundAwardTable = {}
    for _, v in pairs(jsonTable.r_prc_rewarded) do
        self.RoundAwardTable[v] = true
    end
    self.ProAwardTable = {}
    for _, v in pairs(jsonTable.s_prc_rewarded) do
        self.ProAwardTable[v] = true
    end
    -- Personal records
    self.PlayerRecord = List:New()
    for i = 1, #jsonTable.history do
        local _v = Json.decode(jsonTable.history[i])
        self.PlayerRecord:Add({
            Time = math.floor(_v.time / 1000),
            ItemID = _v.item.i,
            ItemCount = _v.item.n
        })
    end
    -- Server Record
    self.ServerRecord = List:New()
    for i = 1, #jsonTable.sHistory do
        local _v = Json.decode(jsonTable.sHistory[i])
        self.ServerRecord:Add({
            Name = _v.name,
            Time = math.floor(_v.time / 1000),
            ItemID = _v.item.i,
            ItemCount = _v.item.n
        })
    end
end

-- Refresh data
function TianDiBaoKuData:RefreshData()
    -- Detect red dots
    self:RemoveRedPoint()
    for i = 1, #self.RoundList do
        local _roundData = self.RoundList[i]
        if self.CurRound >= _roundData.Round and self.RoundAwardTable[_roundData.Round] == nil then
            -- There are round rewards available
            self:AddRedPoint(1, nil, nil, nil, true, nil)
            break
        end
    end

    for i = 1, #self.ProList do
        local _proData = self.ProList[i]
        if self.PlayerCount >= _proData.PPro and self.ServerCount >= _proData.SPro and self.ProAwardTable[_proData.SPro] == nil then
            -- There are progress rewards available
            self:AddRedPoint(2, nil, nil, nil, true, nil)
        end
    end
    -- Show red dots when there is an item
    self:AddRedPoint(3, {{self.CostItem, 1}}, nil, nil, nil, nil)
end

-- Processing operational activities return
function TianDiBaoKuData:ResActivityDeal(jsonTable)
    if jsonTable.draw ~= nil and jsonTable.draw.item ~= nil then
        -- Winning the jackpot
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_TDBK_BIGAWARD, ItemData:New(jsonTable.draw.item))
    end
end

-- Get rewards for this location
function TianDiBaoKuData:GetCellAward(cellIndex)
    return self.CardAwardTable[cellIndex]
end

function TianDiBaoKuData:ReqCardAward(cellIndex)
    -- 1=Flop 2=Receive round progress reward 3=Receive full server progress reward
    local _json = string.format("{\"operate\":1,\"index\":%d}", cellIndex)
    GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {type = self.TypeId, data = _json})
end

function TianDiBaoKuData:GetRoundArawd(cellIndex)
    -- 1=Flop 2=Receive round progress reward 3=Receive full server progress reward
    local _json = string.format("{\"operate\":2,\"index\":%d}", cellIndex)
    GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {type = self.TypeId, data = _json})
end

function TianDiBaoKuData:GetProAward(cellIndex)
    -- 1=Flop 2=Receive round progress reward 3=Receive full server progress reward
    local _json = string.format("{\"operate\":3,\"index\":%d}", cellIndex)
    GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {type = self.TypeId, data = _json})
end

-- Set skip animation
function TianDiBaoKuData:SetJumoAnim(b)
    if self.IsJumpAnim ~= b then
        self.IsJumpAnim = b
        if b then
            GameCenter.GetNewItemSystem:AddIngoreReson(364)
        else
            GameCenter.GetNewItemSystem:RemoveIngoreReson(364)
        end
    end
end

return TianDiBaoKuData
