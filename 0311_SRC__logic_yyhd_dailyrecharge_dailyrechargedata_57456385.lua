------------------------------------------------
-- Author: 
-- Date: 2020-08-24
-- File: DailyRechargeData.lua
-- Module: DailyRechargeData
-- Description: Daily recharge data
------------------------------------------------
local BaseData = require("Logic.YYHD.YYHDBaseData")
local ItemData = require("Logic.YYHD.YYHDItemData")

local DailyRechargeData = {
    DayList = nil,

    CurDayCount = 0,
    IsGetReward = false,
    IsGetTotalReward = false,
    RechargeCount = 0,-- Units are counted

    -- Maximum number of days
    MaxDayCount = 0,
    -- Maximum number of days of cumulative reward
    TotalMaxDayCount = 0,
}

function DailyRechargeData:New(typeId)
    local _n = Utils.DeepCopy(self)
    local _mn = setmetatable(_n, {__index = BaseData:New(typeId)})
    return _mn
end

-- Parse activity configuration data
function DailyRechargeData:ParseSelfCfgData(jsonTable)
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
            NeedRecharge = v.rechargeTarget, -- Units are counted
            Items = _itemList,
            TotalItems = _totalList
        })
    end
end

-- Analyze the data of active players
function DailyRechargeData:ParsePlayerData(jsonTable)
    self.CurDayCount = jsonTable.curRechargeDay
    self.IsGetReward = jsonTable.isGetReward ~= 0
    self.IsGetTotalReward = jsonTable.IsGetTotalReward ~= 0
    self.RechargeCount = jsonTable.rechargeNum
end

function DailyRechargeData:GetShowData()
    if self.DayList ~= nil then
        for i = 1, #self.DayList do
            if self.DayList[i].Day == self.CurDayCount then
                return self.DayList[i]
            end
        end
        return self.DayList[self.MaxDayCount]
    end
    return nil
end

-- Receive rewards
function DailyRechargeData:ReqGetAward()
    GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {type = self.TypeId, data = "GetNormalReward"})
end

-- Receive total reward
function DailyRechargeData:ReqGetTotalAward()
    GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {type = self.TypeId, data = "GetTotalReward"})
end


-- Refresh data
function DailyRechargeData:RefreshData()
    -- Detect red dots
    self:RemoveRedPoint()
    local _showData = self:GetShowData()
    if _showData == nil then
        return
    end
    local _canGetDayAward = false
    if _showData.TotalItems ~= nil then
        _canGetDayAward = not self.IsGetTotalReward
    end
    if (not self.IsGetReward or _canGetDayAward) and self.RechargeCount >= _showData.NeedRecharge then
        self:AddRedPoint(0, nil, nil, nil, true, nil)
    end
end

-- Processing operational activities return
function DailyRechargeData:ResActivityDeal(jsonTable)
end

return DailyRechargeData