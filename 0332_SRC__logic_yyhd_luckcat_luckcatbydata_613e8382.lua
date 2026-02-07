------------------------------------------------
-- Author: 
-- Date: 2021-10-26
-- File: LuckCatBYData.lua
-- Module: LuckCatBYData
-- Description: Data of the activity of the jade-bound cat
------------------------------------------------
local BaseData = require("Logic.YYHD.YYHDBaseData")

local LuckCatBYData = {
    -- magnification list, 8 in total
    RateList = nil,
    -- The number of times corresponds to consumption and recharge
    GearList = nil,
    -- Lottery record list
    RecordList = nil,
    -- Number of remaining draws
    RemainCount = 0,
    -- Current recharge amount
    RechargeCount = 0,

    -- Currently consumed ingots
    CurCost = 0,
    -- The amount to the next level
    NextNeed = 0,
    -- Increase the number of times to the next level
    NextAddCount = 0,
    -- The number of times you have drawn
    CostCountTable = nil,

    -- Current limit
    CurLimitCount = 0,
    -- Currently draws
    CurCostCount = 0,
    -- Show red dots online
    ShowOnlineRedPoint = false,
}

function LuckCatBYData:New(typeId)
    local _n = Utils.DeepCopy(self)
    local _mn = setmetatable(_n, {__index = BaseData:New(typeId)})
    return _mn
end

-- Parse activity configuration data
function LuckCatBYData:ParseSelfCfgData(jsonTable)
    self.ShowOnlineRedPoint = true
    self.RateList = List:New()
    if jsonTable.rate ~= nil then
        local _rateParams = Utils.SplitNumber(jsonTable.rate, '_')
        for i = 1, #_rateParams do
            self.RateList:Add(_rateParams[i])
        end

        -- Added to 8
        local _rateCount = #self.RateList
        if _rateCount < 8 then
            local _addRate = 1
            if _rateCount > 0 then
                _addRate = self.RateList[_rateCount]
            end
            for i = _rateCount + 1, 8 do
                self.RateList:Add(_addRate)
            end
        end
    end
    self.GearList = List:New()
    if jsonTable.gear ~= nil then
        local _gearParams = Utils.SplitStrByTableS(jsonTable.gear, {';', '_'})
        for i = 1, #_gearParams do
            local _limit = _gearParams[i][5]
            if _limit == nil then
                _limit = 0
            end
            self.GearList:Add({
                Cost = _gearParams[i][1],   -- Cost Consumption of Yuanbao
                Need = _gearParams[i][2],    -- Need demand recharge amount
                Limit = _limit,
            })
        end
    end
end

-- Analyze the data of active players
function LuckCatBYData:ParsePlayerData(jsonTable)
    self.RecordList = List:New()
    if jsonTable.record ~= nil then

        local _recordLines = Utils.SplitStr(jsonTable.record, ';')
        for _, recordStr in ipairs(_recordLines) do
            local parts = Utils.SplitStr(recordStr, '_')
            local partCount = #parts
            if partCount >= 3 then
                local rate = tonumber(parts[partCount - 1]) or 0
                local count = tonumber(parts[partCount]) or 0
                local name = table.concat(parts, '_', 1, partCount - 2)
                self.RecordList:Add({
                    Name = name,
                    Rate = rate / 100,
                    Count = count
                })
            end
        end


        -- local _recordParams = Utils.SplitStrBySeps(jsonTable.record, {';', '_'})
        -- for i = 1, #_recordParams do
        --     self.RecordList:Add({
        -- Name = _recordParams[i][1], --Name player name
        -- Rate = tonumber(_recordParams[i][2]) / 100, --Rate winning multiple
        -- Count = tonumber(_recordParams[i][3])--Count winning quantity
        --     })
        -- end
    end
    self.RemainCount = jsonTable.num or 0
    self.RechargeCount = jsonTable.rechargeCount or 0
    self.CostCountTable = {}
    if jsonTable.serverDrawMap ~= nil then
        for k, v in pairs(jsonTable.serverDrawMap) do
            self.CostCountTable[tonumber(k)] = tonumber(v)
        end
    end
end

-- Refresh data
function LuckCatBYData:RefreshData()
    -- Calculate the total number of draws available
    local _allCount = 0
    for i = 1, #self.GearList do
        if self.RechargeCount >= self.GearList[i].Need then
            _allCount = i
        end
    end
    local _curCount = _allCount - self.RemainCount + 1
    -- Prevent mistakes
    if _curCount <= 0 or _curCount > #self.GearList then
        self.CurCost = 0
        self.NextNeed = 0
        self.NextAddCount = 0
        self.CurLimitCount = 0
        self.CurCostCount = 0
    else
        local _curCfg = self.GearList[_curCount]
        self.CurLimitCount = _curCfg.Limit
        self.CurCostCount = self.CostCountTable[_curCfg.Need]
        if self.CurCostCount == nil then
            self.CurCostCount = 0
        end
        self.CurCost = _curCfg.Cost
        self.NextNeed = 0
        if _allCount < #self.GearList then
            local _nextNeed = self.GearList[_allCount + 1].Need
            -- Calculate how much you can increase the number of times
            self.NextNeed = _nextNeed - self.RechargeCount
            -- Calculate the number of lottery times that can be increased for the next recharge
            local _nextCount = 0
            for i = 1, #self.GearList do
                if _nextNeed >= self.GearList[i].Need then
                    _nextCount = i
                end
            end
            self.NextAddCount = _nextCount - _allCount
        end
    end
    self:CheckRedPoint()
end

-- Check the red dots
function LuckCatBYData:CheckRedPoint()
    self:RemoveRedPoint(nil)
    if self.RemainCount > 0 and self.CurCostCount < self.CurLimitCount then
        self:AddRedPoint(0, nil, nil, nil, true, nil)
    end
    if self.ShowOnlineRedPoint then
        self:AddRedPoint(1, nil, nil, nil, true, nil)
    end
end

-- Clear the red dots online
function LuckCatBYData:ClearOnlineRedPoint()
    if self.ShowOnlineRedPoint then
        self.ShowOnlineRedPoint = false
        self:CheckRedPoint()
    end
end

-- Increase the winning record of the protagonist
function LuckCatBYData:AddLocalRecord(rate, count)
    -- Remaining the remaining times by 1
    self.RemainCount = self.RemainCount - 1
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end
    self.RecordList:Insert({
        Name = _lp.Name,     -- Name player name
        Rate = tonumber(rate) / 100, -- Rate win multiple
        Count = tonumber(count)-- Count wins
    }, 1)
end

-- Send a lottery request
function LuckCatBYData:ReqChouJiang()
    if self.RemainCount <= 0 or self.CurCostCount >= self.CurLimitCount then
        Utils.ShowPromptByEnum("C_LUCKCAT_COUNT_NOTENOUGH")
        return
    end
    local _haveGold = GameCenter.ItemContianerSystem:GetEconomyWithType(ItemTypeCode.BindGold)
    if _haveGold < self.CurCost then
        Utils.ShowPromptByEnum("C_LUCKCAT_BANGYU_NOTENOUGH")
        return
    end
    GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {type = self.TypeId})
end

-- Processing operational activities return
function LuckCatBYData:ResActivityDeal(jsonTable)
    self:AddLocalRecord(jsonTable.rate, jsonTable.money)
    if jsonTable.serverDrawMap ~= nil then
        for k, v in pairs(jsonTable.serverDrawMap) do
            self.CostCountTable[tonumber(k)] = tonumber(v)
        end
    end
    self:RefreshData()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_REFRESH_LUCKCAT_RESULT, jsonTable)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_HDLIST)
end

return LuckCatBYData
