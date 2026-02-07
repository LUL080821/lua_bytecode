------------------------------------------------
-- Author: 
-- Date: 2020-10-19
-- File: LianXuLeiChongData.lua
-- Module: LianXuLeiChongData
-- Description: Thailand's continuous cumulative activity data
------------------------------------------------
local BaseData = require("Logic.YYHD.YYHDBaseData")
local ItemData = require("Logic.YYHD.YYHDItemData")

local L_RechargeData = nil

local LianXuLeiChongData = {
    RechargeList = nil,
    RechargeCount = 0,-- Units are counted
}

function LianXuLeiChongData:New(typeId)
    local _n = Utils.DeepCopy(self)
    local _mn = setmetatable(_n, {__index = BaseData:New(typeId)})
    return _mn
end

-- Parse activity configuration data
function LianXuLeiChongData:ParseSelfCfgData(jsonTable)
    self.RechargeList = List:New()
    for k, v in pairs(jsonTable) do
        local _data = L_RechargeData:New(tonumber(k))
        _data:ParseCfgData(v)
        self.RechargeList:Add(_data)
    end

    self.RechargeList:Sort(function(x,y)
        return x.NeedRecharge < y.NeedRecharge
    end)
end

-- Analyze the data of active players
function LianXuLeiChongData:ParsePlayerData(jsonTable)
    for i = 1, #self.RechargeList do
        local _data = self.RechargeList[i]
        _data.CurDayCount = jsonTable.curRechargeDay[tostring(_data.NeedRecharge)]
        _data.IsGetReward = jsonTable.isGetReward[tostring(_data.NeedRecharge)] ~= 0
        _data.IsGetTotalReward = jsonTable.IsGetTotalReward[tostring(_data.NeedRecharge)] ~= 0
    end
    self.RechargeCount = jsonTable.rechargeNum
end

function LianXuLeiChongData:GetRechargeInfo(rechargeCount)
    for i = 1, #self.RechargeList do
        if self.RechargeList[i].NeedRecharge == rechargeCount then
            return self.RechargeList[i]
        end
    end
    return nil
end

-- Receive rewards
function LianXuLeiChongData:ReqGetAward(rechargeCount)
    local _json = string.format("{\"rechargeKey\":%d,\"getReward\":\"GetNormalReward\"}", rechargeCount)
    GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {type = self.TypeId, data = _json})
end

-- Receive total reward
function LianXuLeiChongData:ReqGetTotalAward(rechargeCount)
    local _json = string.format("{\"rechargeKey\":%d,\"getReward\":\"GetTotalReward\"}", rechargeCount)
    GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {type = self.TypeId, data = _json})
end


-- Refresh data
function LianXuLeiChongData:RefreshData()
    -- Detect red dots
    self:RemoveRedPoint()
    for i = 1, #self.RechargeList do
        local _data = self.RechargeList[i]
        local _showData = _data:GetShowData()
        if _showData ~= nil then
            local _haveTotalAward = _showData.TotalItems ~= nil
            if (not _data.IsGetReward or (_haveTotalAward and not _data.IsGetTotalReward)) and self.RechargeCount >= _data.NeedRecharge then
                self:AddRedPoint(_data.NeedRecharge, nil, nil, nil, true, nil)
            end
        end
    end
end

-- Processing operational activities return
function LianXuLeiChongData:ResActivityDeal(jsonTable)
end

L_RechargeData = {
    NeedRecharge = 0,
    DayList = nil,
    CurDayCount = 0,
    IsGetReward = false,
    IsGetTotalReward = false,
    -- Maximum number of days
    MaxDayCount = 0,
    -- Maximum number of days of cumulative reward
    TotalMaxDayCount = 0,
}

function L_RechargeData:New(rechargeCount)
    local _m = Utils.DeepCopy(self)
    _m.NeedRecharge = rechargeCount
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

return LianXuLeiChongData