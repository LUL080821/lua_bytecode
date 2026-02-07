------------------------------------------------
-- Author: 
-- Date: 2020-08-14
-- File: JieRiXueYuanData.lua
-- Module: JieRiXueYuanData
-- Description: Holiday Wishes
------------------------------------------------
local BaseData = require("Logic.YYHD.YYHDBaseData")
local ItemData = require("Logic.YYHD.YYHDItemData")

local JieRiXueYuanData = {
    -- Configuration data
    CfgData = nil,
    PlayerData = nil,
    -- Guaranteed reward
    BaoDiCfgList = nil,
    -- Guaranteed collection status
    BaoDiGetState = nil,
    -- The number of guaranteed draws
    BaoDiAwardCount = 0,
}

function JieRiXueYuanData:New(typeId)
    local _n = Utils.DeepCopy(self)
    local _mn = setmetatable(_n, {
        __index = BaseData:New(typeId)
    })
    --TODO
    -- self:Test();
    return _mn
end

-- Parse activity configuration data
function JieRiXueYuanData:ParseSelfCfgData(jsonTable)
    self.CfgData = jsonTable;
    self.PlayerData = nil;
    local _occ = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
    -- Points Reward
    local _rewards = self.CfgData.lowestRewards or {};
    self.ScoreItems = {}
    for i=1, #_rewards do
        local _reward = _rewards[i];
        if _reward.c == 9 or _occ == _reward.c then
            table.insert(self.ScoreItems, _reward)
        end
    end

    table.sort(self.ScoreItems, function(a,b)
        return a.s < b.s
    end)

    for i=1, #self.ScoreItems do
        self.ScoreItems[i].index = i;
    end
    -- Scroll rewards
    _rewards = self.CfgData.rewardPool or {};
    self.BigItemDic = {};
    self.ShowItemList = {};
    for i=1, #_rewards do
        local _reward = _rewards[i];
        if _reward.c == 9 or _occ == _reward.c then
            if _reward.isB == 1 then
                self.BigItemDic[_reward.i] = _reward;
            end
            if _reward.isS == 1 then
                table.insert(self.ShowItemList, _reward)
            end
        end
    end
    
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

function JieRiXueYuanData:IsBigItem(id)
    if self.BigItemDic then
        return not(not self.BigItemDic[id])
    end
end

-- Resolve custom data and update it
function JieRiXueYuanData:ParsePlayerData(jsonTable)
    self.PlayerData = jsonTable;
    local _itemTable = {}
    local _itemList = List:New()
    if jsonTable.store ~= nil then
        for i = 1, #jsonTable.store do
            local _item = jsonTable.store[i]
            local _oriItem = _itemTable[_item.i]
            if _oriItem ~= nil then
                _oriItem.n = _oriItem.n + _item.n
            else
                _itemTable[_item.i] = _item
                _itemList:Add(_item)
            end
        end
    end
    self.Store = _itemList
    self.LastItems = nil;

    -- Guaranteed state
    self.BaoDiGetState = {}
    if jsonTable.lowestMap ~= nil then
        for k, v in pairs(jsonTable.lowestMap) do
            self.BaoDiGetState[tonumber(k)] = (v ~= 0)
        end
    end
    self.BaoDiAwardCount = jsonTable.lowestCount or 0
end

-- Is there a small red dot in this function
function JieRiXueYuanData:IsRedpoint()
    if self.PlayerData then
        if #self.Store > 0 then
            return true;
        end
    end

    if self.ScoreItems then
        for i=1,#self.ScoreItems do
            -- There are rewards for points available
            if self:GetScoreRewardStateByIndex(self.ScoreItems[i].index) == 1 then
                return true;
            end
        end
    end

    if self.CfgData then
        local _haveKeyNum = tonumber(GameCenter.ItemContianerSystem:GetItemCountFromCfgId(self.CfgData.keyId))
        if _haveKeyNum >= self.CfgData.oneCostKey or _haveKeyNum >= self.CfgData.tenCostKey then
            return true;
        end
    end
end

-- Refresh the red dots
function JieRiXueYuanData:RereshRedpoint()
    if self:IsRedpoint() then
        self:AddRedPoint(self.TypeId, nil, nil, nil, true, nil)
    else
        self:RemoveRedPoint()
    end
end

-- Refresh data
function JieRiXueYuanData:RefreshData()
    self:OnRefresh()
end

-- Operation activity return
function JieRiXueYuanData:ResActivityDeal(jsonTable)
    self.PlayerData = jsonTable;
    self.LastItems = jsonTable.last; 
    if jsonTable.lowestMap ~= nil then
        for k, v in pairs(jsonTable.lowestMap) do
            self.BaoDiGetState[tonumber(k)] = (v ~= 0)
        end
    end
    self.BaoDiAwardCount = jsonTable.lowestCount or 0
    if jsonTable.last ~= nil then
        for i = 1, #jsonTable.last do
            local _item = jsonTable.last[i]
            local _finded = false
            for j = 1, #self.Store do
                local _oriItem = self.Store[j]
                if _oriItem.i == _item.i then
                    _oriItem.n = _oriItem.n + _item.n
                    _finded = true
                    break
                end
            end
            if not _finded then
                self.Store:Add(_item)
            end
        end
    end
    -- Refresh data
    self:RefreshData()
    -- Refresh activity list
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_HDLIST)
    -- Refresh an event
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_HDFORM, self.TypeId)
end

function JieRiXueYuanData:ReqActivityDeal(count)
	GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {
        type = self.TypeId,
        data = Json.encode({
            wish = count,
        })
	})
end

-- Reward status of points: 0 Cannot be claimed, 1 Can be claimed, 2 Have received
function JieRiXueYuanData:GetScoreRewardStateByIndex(index)
    if not self.CfgData then
        return false;
    end
    local _curScore = self.PlayerData.score or 0;
    local _reward = self.ScoreItems[index];
    local _boxBin = self.PlayerData.boxBin or 0;

    -- Debug.LogError(index, _curScore , _reward.s , _boxBin >> (index - 1))
    if _curScore < _reward.s then
        return 0;
    elseif (_boxBin >> (index - 1)) & 1 ~= 1 then
        return 1;
    else
        return 2;
    end
end

function JieRiXueYuanData:OnRefresh()
    if self.LastItems and #self.LastItems > 0 then
        for i=1, #self.LastItems do
            local _item = self.LastItems[i]
            GameCenter.GetNewItemSystem:AddShowItem(ItemChangeReasonName.FestvialWishGet, nil, _item.i, _item.n);
        end
    end
    self:RereshRedpoint()
end


function JieRiXueYuanData:Test()
self.CfgData = 
{
    ['keyId']  = 1033,
    ['lowestRewards'] = {
        [1] = {
            ['b']      = 0,
            ['c']      = 9,
            ['i']      = 12003,
            ['n']      = 1,
            ['s']      = 50,},
        [2] = {
            ['b']      = 0,
            ['c']      = 9,
            ['i']      = 12003,
            ['n']      = 1,
            ['s']      = 200,},
        [3] = {
            ['b']      = 0,
            ['c']      = 9,
            ['i']      = 12003,
            ['n']      = 1,
            ['s']      = 500,},
        [4] = {
            ['b']      = 0,
            ['c']      = 9,
            ['i']      = 12003,
            ['n']      = 1,
            ['s']      = 1000,},
        [5] = {
            ['b']      = 0,
            ['c']      = 9,
            ['i']      = 12003,
            ['n']      = 1,
            ['s']      = 2000,},},
    ['oneCostGold'] = 50,
    ['rewardPool'] = {
        [1] = {
            ['b']      = 0,
            ['c']      = 9,
            ['i']      = 10001,
            ['isB']    = 1,
            ['isS']    = 1,
            ['n']      = 1,},
        [2] = {
            ['b']      = 0,
            ['c']      = 9,
            ['i']      = 10002,
            ['isB']    = 1,
            ['isS']    = 1,
            ['n']      = 1,},
        [3] = {
            ['b']      = 0,
            ['c']      = 9,
            ['i']      = 10003,
            ['isB']    = 1,
            ['isS']    = 1,
            ['n']      = 1,},
        [4] = {
            ['b']      = 0,
            ['c']      = 9,
            ['i']      = 10004,
            ['isB']    = 1,
            ['isS']    = 1,
            ['n']      = 1,},
        [5] = {
            ['b']      = 0,
            ['c']      = 9,
            ['i']      = 10005,
            ['isB']    = 1,
            ['isS']    = 1,
            ['n']      = 1,},
        [6] = {
            ['b']      = 0,
            ['c']      = 9,
            ['i']      = 10006,
            ['isB']    = 1,
            ['isS']    = 1,
            ['n']      = 1,},
        [7] = {
            ['b']      = 0,
            ['c']      = 9,
            ['i']      = 10007,
            ['isB']    = 1,
            ['isS']    = 1,
            ['n']      = 1,},
        [8] = {
            ['b']      = 0,
            ['c']      = 9,
            ['i']      = 10008,
            ['isB']    = 1,
            ['isS']    = 1,
            ['n']      = 1,},
        [9] = {
            ['b']      = 0,
            ['c']      = 9,
            ['i']      = 10009,
            ['isB']    = 1,
            ['isS']    = 1,
            ['n']      = 1,},
        [10] = {
            ['b']      = 0,
            ['c']      = 9,
            ['i']      = 10010,
            ['isB']    = 1,
            ['isS']    = 1,
            ['n']      = 1,},
        [11] = {
            ['b']      = 0,
            ['c']      = 9,
            ['i']      = 10011,
            ['isB']    = 1,
            ['isS']    = 1,
            ['n']      = 1,},
        [12] = {
            ['b']      = 0,
            ['c']      = 9,
            ['i']      = 10012,
            ['isB']    = 1,
            ['isS']    = 1,
            ['n']      = 1,},
        [13] = {
            ['b']      = 0,
            ['c']      = 9,
            ['i']      = 10013,
            ['isB']    = 1,
            ['isS']    = 1,
            ['n']      = 1,},
        [14] = {
            ['b']      = 0,
            ['c']      = 9,
            ['i']      = 10014,
            ['isB']    = 1,
            ['isS']    = 0,
            ['n']      = 1,},
        [15] = {
            ['b']      = 0,
            ['c']      = 9,
            ['i']      = 10015,
            ['isB']    = 1,
            ['isS']    = 0,
            ['n']      = 1,},
        [16] = {
            ['b']      = 0,
            ['c']      = 9,
            ['i']      = 10016,
            ['isB']    = 1,
            ['isS']    = 0,
            ['n']      = 1,},
        [17] = {
            ['b']      = 0,
            ['c']      = 9,
            ['i']      = 10017,
            ['isB']    = 1,
            ['isS']    = 0,
            ['n']      = 1,},
        [18] = {
            ['b']      = 0,
            ['c']      = 9,
            ['i']      = 10018,
            ['isB']    = 1,
            ['isS']    = 0,
            ['n']      = 1,},},
    ['tenCostGold'] = 500,
    ['oneCostKey'] = 1,
    ['tenCostKey'] = 10,
}

self.PlayerData = 
{
    ['wish'] = 360,
    ['boxBin'] = 1,
    ['score']  = 49,
    ['store'] = {
        [1] = {
            ['b']      = 0,
            ['c']      = 9,
            ['i']      = 10016,
            ['n']      = 2,},
        [2] = {
            ['b']      = 0,
            ['c']      = 9,
            ['i']      = 10017,
            ['n']      = 3,},
        [3] = {
            ['b']      = 0,
            ['c']      = 9,
            ['i']      = 10018,
            ['n']      = 5,}
    },
    ['last'] = {
        [1] = {
            ['b']      = 0,
            ['c']      = 9,
            ['i']      = 10016,
            ['n']      = 2,},
        [2] = {
            ['b']      = 0,
            ['c']      = 9,
            ['i']      = 10017,
            ['n']      = 3,},
        [3] = {
            ['b']      = 0,
            ['c']      = 9,
            ['i']      = 10018,
            ['n']      = 5,}
    },
}

GameCenter.YYHDSystem.DataTable[self.TypeId] = self
end

return JieRiXueYuanData