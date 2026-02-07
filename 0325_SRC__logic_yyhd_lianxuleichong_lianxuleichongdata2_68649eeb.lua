------------------------------------------------
-- Author: 
-- Date: 2020-11-03
-- File: LianXuLeiChongData2.lua
-- Module: LianXuLeiChongData2
-- Description: Thailand's continuous cumulative activity data
------------------------------------------------
local BaseData = require("Logic.YYHD.YYHDBaseData")
local ItemData = require("Logic.YYHD.YYHDItemData")

local L_RechargeData = nil

local LianXuLeiChongData2 = {
    RechargeList = nil,
}

function LianXuLeiChongData2:New(typeId)
    local _n = Utils.DeepCopy(self)
    local _mn = setmetatable(_n, {__index = BaseData:New(typeId)})
    return _mn
end

-- Parse activity configuration data
function LianXuLeiChongData2:ParseSelfCfgData(jsonTable)
    self.RechargeList = List:New()
    for k, v in pairs(jsonTable) do
        local _data = L_RechargeData:New(tonumber(k))
        _data:ParseCfgData(v)
        self.RechargeList:Add(_data)
    end

    self.RechargeList:Sort(function(x,y)
        return x.RechargeID < y.RechargeID
    end)
end

-- Analyze the data of active players
function LianXuLeiChongData2:ParsePlayerData(jsonTable)
    for i = 1, #self.RechargeList do
        local _data = self.RechargeList[i]
        _data.CurDayCount = jsonTable.curRechargeDay[tostring(_data.RechargeID)]
        _data.IsGetReward = jsonTable.isGetReward[tostring(_data.RechargeID)] ~= 0
        _data.IsGetTotalReward = jsonTable.IsGetTotalReward[tostring(_data.RechargeID)] ~= 0
    end
end

function LianXuLeiChongData2:GetRechargeInfo(rechargeID)
    for i = 1, #self.RechargeList do
        if self.RechargeList[i].RechargeID == rechargeID then
            return self.RechargeList[i]
        end
    end
    return nil
end

-- Receive total reward
function LianXuLeiChongData2:ReqGetTotalAward(rechargeID)
    local _json = string.format("{\"rechargeKey\":%d}", rechargeID)
    GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {type = self.TypeId, data = _json})
end


-- Refresh data
function LianXuLeiChongData2:RefreshData()
    -- Detect red dots
    self:RemoveRedPoint()
    for i = 1, #self.RechargeList do
        local _data = self.RechargeList[i]
        local _showData = _data:GetShowData()
        if _showData ~= nil then
            local _haveTotalAward = _showData.TotalItems ~= nil
            if _data.IsGetReward and (_haveTotalAward and not _data.IsGetTotalReward) then
                self:AddRedPoint(_data.RechargeID, nil, nil, nil, true, nil)
            end
        end
    end
end

-- Processing operational activities return
function LianXuLeiChongData2:ResActivityDeal(jsonTable)
end

L_RechargeData = {
    RechargeID = 0,
    DayList = nil,
    CurDayCount = 0,
    IsGetReward = false,
    IsGetTotalReward = false,
    -- Maximum number of days
    MaxDayCount = 0,
    -- Maximum number of days of cumulative reward
    TotalMaxDayCount = 0,
}

function L_RechargeData:New(rechargeID)
    local _m = Utils.DeepCopy(self)
    _m.RechargeID = rechargeID
    return _m
end

function L_RechargeData:ParseCfgData(jsonTable)
    self.DayList = List:New()
    self.MaxDayCount = 0
    self.TotalMaxDayCount = 0
    for k, v in pairs(jsonTable) do
        local _itemList = List:New()
        local _day = tonumber(k)
        if v.rewardDatas ~= nil then
            for _, vn in pairs(v.rewardDatas) do
                if vn.i ~= nil then
                    _itemList:Add(ItemData:New(vn))
                end
            end
        end
        local _totalList = nil
        if v.totalRewardDatas ~= nil then
            for _, vn in pairs(v.totalRewardDatas) do
                if vn.i ~= nil then
                    if _totalList == nil then
                        _totalList = List:New()
                    end
                    _totalList:Add(ItemData:New(vn))
                end
            end
        end
        if _day > self.MaxDayCount then
            self.MaxDayCount = _day
        end
        if _day > self.TotalMaxDayCount and _totalList ~= nil then
            self.TotalMaxDayCount = _day
        end
        self.DayList:Add({
            Day = _day,
            Items = _itemList,
            TotalItems = _totalList
        })
    end
end

function L_RechargeData:GetShowData()
    if self.DayList ~= nil then
        for i = 1, #self.DayList do
            if self.DayList[i].Day == self.CurDayCount then
                return self.DayList[i]
            end
        end
        return self.DayList[self.MaxDayCount]
    end
end

return LianXuLeiChongData2