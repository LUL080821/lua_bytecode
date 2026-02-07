------------------------------------------------
-- Author:
-- Date: 2020-10-16
-- File: JiFenPaiMingData.lua
-- Module: JiFenPaiMingData
-- Description: Points Ranking Event
------------------------------------------------
local BaseData = require("Logic.YYHD.YYHDBaseData")
local ItemData = require("Logic.YYHD.YYHDItemData")

local JiFenPaiMingData = {
    -- Ranking reward information
    AwardInfoList = nil,
    -- Ranking information
    RankInfoList = nil,
    -- My ranking information
    MyRankInfo = nil,
    -- time left
    RemainTime = 0,
}

function JiFenPaiMingData:New(typeId)
    local _n = Utils.DeepCopy(self)
    local _mn = setmetatable(_n, {__index = BaseData:New(typeId)})
    return _mn
end

-- Parse activity configuration data
function JiFenPaiMingData:ParseSelfCfgData(jsonTable)
    self.AwardInfoList = List:New()
    self.RankInfoList = List:New()
    -- Ranking reward information
    if jsonTable.ranks ~= nil then
        for ik, iv in pairs(jsonTable.ranks) do
            local _item = {}
            _item.MinRank = iv.start
            _item.MaxRank = iv.tail
            _item.Score = tonumber(iv.score)
            _item.ShowItemList = List:New()
            if iv.items then
                for mk, mv in pairs (iv.items) do
                    _item.ShowItemList:Add(ItemData:New(mv))
                end
            end
            if #_item.ShowItemList > 0 then
                _item.SpecialItemID = _item.ShowItemList[1].ItemID
            end
            self.AwardInfoList:Add(_item)
        end
    end
    -- Points Reward Information
    if jsonTable.scores then
        for ik, iv in pairs(jsonTable.scores) do
            local _item = {}
            _item.Score = tonumber(iv.score)
            _item.MinRank = 0
            _item.MaxRank = 0
            _item.ShowItemList = List:New()
            if iv.items then
                for mk, mv in pairs (iv.items) do
                    _item.ShowItemList:Add(ItemData:New(mv))
                end
            end
            if #_item.ShowItemList > 0 then
                _item.SpecialItemID = _item.ShowItemList[1].ItemID
            end
            self.AwardInfoList:Add(_item)
        end
    end
end

-- Analyze the data of active players
function JiFenPaiMingData:ParsePlayerData(jsonTable)
    self.AlreadyGetIds = {}
    if jsonTable.giftHistory then
        for k, v in pairs(jsonTable.giftHistory) do
            if v ~= 0 then
                self.AlreadyGetIds[tonumber(v)] = true
            end
        end
    end
    if jsonTable.myRank then
        self.MyRankInfo = {}
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if _lp then
            self.MyRankInfo.Score = jsonTable.myRank.score
            self.MyRankInfo.Rank = jsonTable.myRank.rank
            self.MyRankInfo.Name = _lp.Name
            self.MyRankInfo.VipLevel = _lp.VipLevel
        end
    end
    if jsonTable.timeout then
        self.RemainTime = jsonTable.timeout
    end
    if jsonTable.ranks then
        self.RankInfoList:Clear()
        for ik, iv in pairs(jsonTable.ranks) do
            local _item = {}
            _item.Rank = iv.rank
            _item.Name = iv.name
            _item.Score = tonumber(iv.score)
            _item.VipLevel = iv.vip
            self.RankInfoList:Add(_item)
        end
    end
end

-- Refresh data
function JiFenPaiMingData:RefreshData()
    local _isRed = false
    -- According to points
    local _sortFunc = function (left, right)
        local _lSortValue = 0
        if left.MinRank > 0 then
            _lSortValue = left.MinRank + 10000
        else
            local _lGeted = self.AlreadyGetIds[left.Score]
            if self.MyRankInfo.Score >= left.Score and _lGeted ~= true then
                _lSortValue = left.Score
                _isRed = true
            else
                _lSortValue = _lGeted and (100000000 + left.Score) or (left.Score + 1000000)
            end
        end
        local _rSortValue = 0
        if right.MinRank > 0 then
            _rSortValue = right.MinRank + 10000
        else
            local _lGeted = self.AlreadyGetIds[right.Score]
            if self.MyRankInfo.Score >= right.Score and _lGeted ~= true then
                _rSortValue = right.Score
                _isRed = true
            else
                _rSortValue = _lGeted and (100000000 + right.Score) or (right.Score + 1000000)
            end
        end
        return _lSortValue < _rSortValue
    end
    self.AwardInfoList:Sort(_sortFunc)

    -- Detect red dots
    self:RemoveRedPoint()
    self:AddRedPoint(0, nil, nil, nil, _isRed, nil)
end

-- Processing operational activities return
function JiFenPaiMingData:ResActivityDeal(jsonTable)
    if jsonTable.score then
        self.AlreadyGetIds[jsonTable.score] = true
    end
    self:RefreshData()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_HDFORM, self.TypeId)
end

-- Request for a prize
function JiFenPaiMingData:ReqGetAward(id)
    local _json = string.format("{\"score\":%d}", id)
    GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {type = self.TypeId, data = _json})
end

return JiFenPaiMingData