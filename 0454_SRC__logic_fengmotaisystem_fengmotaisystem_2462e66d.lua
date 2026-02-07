------------------------------------------------
-- Author:
-- Date: 2021-04-25
-- File: FengMoTaiSystem.lua
-- Module: FengMoTaiSystem
-- Description: Magic Sealing Platform System
------------------------------------------------
-- Quote
local L_FengMoTaiData = require "Logic.FengMoTaiSystem.FengMoTaiData"
local RedPointItemCondition = CS.Thousandto.Code.Logic.RedPointItemCondition

local FengMoTaiSystem = {
   -- Low-level lottery consumables owned
   LowPoint = nil,
   -- Mid-level lottery consumables owned
   MidPoint = nil,
   -- High-level lottery consumables owned
   HighPoint = nil,
   -- Current Demon-Sealing Progress
   FengMoProgressValue = nil,

   ShowRewardsList = List:New(),
   LowRwardsList  = List:New(),
   MidRwardsList  = List:New(),
   HighRwardsList  = List:New(),

   DicHotLimit = nil,
   DicDrawCost = nil,

}


function FengMoTaiSystem:Initialize()
    self:GetDrawCostData()

    -- Add conditional red dots
    for k, v in pairs(self.DicDrawCost) do
        local _conList = List:New()
        _conList:Add(RedPointItemCondition(v.OnectimesCost, v.OnectimesCostCount))
        GameCenter.RedPointSystem:LuaAddFuncCondition(FunctionStartIdCode.FengMoTai, k, _conList)
    end
end

function FengMoTaiSystem:UnInitialize()
    self.ShowRewardsList = nil
    self.LowRwardsList  = nil
    self.MidRwardsList  = nil
    self.HighRwardsList  = nil
    self.DicHotLimit = nil
    self.DicDrawCost = nil
end

-- Get rewards for each level. If the parameter is empty, the reward is all
function FengMoTaiSystem:GetStepsRwardsList(type)
    local  section = self:GetHotAreaByNum(self.FengMoProgressValue)
    if type == nil then 
        if #self.ShowRewardsList == 0 then 
            self:GetRewardsListByData()
        end
        local tab = List:New()
        for i = 1, #self.ShowRewardsList do
            if self.ShowRewardsList[i].HotLimit == section then
                tab:Add(self.ShowRewardsList[i])
            end
        end
        return tab
    end
    if type == FengMoTaiCost.Low then
        if #self.LowRwardsList == 0 then 
            self:GetRewardsListByData()
        end
        local tab = List:New()
        for i = 1, #self.LowRwardsList do
            if self.LowRwardsList[i].HotLimit == section then
                tab:Add(self.LowRwardsList[i])
            end
        end
        return tab
    elseif type == FengMoTaiCost.Mid then
        if #self.MidRwardsList == 0 then 
            self:GetRewardsListByData()
        end
        local tab = List:New()
        for i = 1, #self.MidRwardsList do
            if self.MidRwardsList[i].HotLimit == section then
                tab:Add( self.MidRwardsList[i])
            end
        end
        return tab
    elseif type == FengMoTaiCost.High then
        if #self.HighRwardsList == 0 then 
            self:GetRewardsListByData()
        end
        local tab = List:New()
        for i = 1, #self.HighRwardsList do
            if self.HighRwardsList[i].HotLimit == section then
                tab:Add(self.HighRwardsList[i])
            end
        end
        return tab
    end
end

-- Reading table
function FengMoTaiSystem:GetRewardsListByData()
    DataConfig.DataCrossDevilHuntPool:Foreach(function(k,v)
        if v.IsShow == 1 then
            if v.RankShow == 3 then
                local data = L_FengMoTaiData:New(v)
                self.LowRwardsList:Add(data)
                self.ShowRewardsList:Add(data)
            elseif v.RankShow == 2 then
                local data = L_FengMoTaiData:New(v)
                self.MidRwardsList:Add(data)
                self.ShowRewardsList:Add(data)
            elseif v.RankShow == 1 then
                local data = L_FengMoTaiData:New(v)
                self.HighRwardsList:Add(data)
                self.ShowRewardsList:Add(data)
            end
        end
    end)
end

-- Get the popularity range
function FengMoTaiSystem:GetHotLimitData()
    if self.DicHotLimit == nil then
        self.DicHotLimit = Dictionary:New()
        DataConfig.DataCrossDevilHuntHot:Foreach(function(k,v)
            local tab = {}
            local intervals = Utils.SplitStr(v.Hot, '_')
            tab.Lowest = intervals[1]
            tab.Tallest = intervals[2]
            if intervals[2] == "-1" then
                tab.Tallest = "Max"
            end
            tab.ShowUI = v.ShowUI
            self.DicHotLimit[k] = tab
        end)
        return self.DicHotLimit
    else 
        return self.DicHotLimit
    end
end

-- Get the lottery cost
function FengMoTaiSystem:GetDrawCostData()
    if self.DicDrawCost == nil then
        self.DicDrawCost = Dictionary:New()
        DataConfig.DataCrossDevilHuntPop:Foreach(function(k,v)
            local tab = {}
            local strs = Utils.SplitStr(v.Times, ';')
            local OnceCost = Utils.SplitNumber(strs[1], '_')
            local TenCost = Utils.SplitNumber(strs[2], '_')
            tab.OnectimesCostTimes = OnceCost[1]
            tab.OnectimesCost = OnceCost[2]
            tab.OnectimesCostCount = OnceCost[3]
            tab.TentimesCostTimes = TenCost[1]
            tab.TentimesCost = TenCost[2]
            tab.TentimesCostCount = TenCost[3]
            self.DicDrawCost[k] = tab
        end)
        return self.DicDrawCost
    else 
        return self.DicDrawCost
    end
end

-- Get the heat interval according to the progress value of the demon seal
function FengMoTaiSystem:GetHotAreaByNum(num)
    local tab = self:GetHotLimitData()
    for i = 1, #tab do
        local lowest = tab[i].Lowest
        local tallest = tab[i].Tallest
        if tallest == "Max" then
            tallest = "99999999"
        end
        if tonumber(lowest) <= num and num <= tonumber(tallest) then
            return i
        end
    end
end



-- lottery
function FengMoTaiSystem:Draw(type , times)
    local consecutiveType = 1
    if times > 1 then
        consecutiveType = 2
    end
    local _data = self.DicDrawCost[type]
    if _data == nil then
        return
    end
    local _itemId = _data.OnectimesCost
    local _itemCount = _data.OnectimesCostCount
    if times > 1 then
        _itemId = _data.TentimesCost
        _itemCount = _data.TentimesCostCount
    end
    local _haveCount = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(_itemId)
    if _haveCount < _itemCount then
        -- Insufficient props
        Utils.ShowPromptByEnum("ItemNotEnough")
        GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(_itemId)
        return
    end
    self:ReqDevilHunt(type, consecutiveType)
end

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Request type = stage consecutiveType = number of draws
function FengMoTaiSystem:ReqDevilHunt(type , consecutiveType)
    GameCenter.Network.Send("MSG_DevilSeries.ReqDevilHunt", {
        huntType = type,
        consecutiveType = consecutiveType,
    })
end

-- 
function FengMoTaiSystem:ReqDevilHuntPanel(palyerId)
    GameCenter.Network.Send("MSG_DevilSeries.ReqDevilHuntPanel", {
    })
end
-- --------------------------------------------------------------------------------------------------------------------------------
function FengMoTaiSystem:ResDevilHuntPanel(result)
    self.FengMoProgressValue = result.devilHotValue
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FMT_DRAW_REFRESH)
end

function FengMoTaiSystem:ResDevilHunt(result)
    self.FengMoProgressValue = result.devilHotValue
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FMT_DRAW_REFRESH)
end

return FengMoTaiSystem
