------------------------------------------------
-- Author:
-- Date: 2020-09-01
-- File: ZhenCangGeSystem.lua
-- Module: ZhenCangGeSystem
-- Description: Collection Pavilion System
------------------------------------------------
-- Quote
local TimeUtils = CS.Thousandto.Core.Base.TimeUtils
local L_RedPointItemCondition = CS.Thousandto.Code.Logic.RedPointItemCondition
local L_RedPointCustomCondition = CS.Thousandto.Code.Logic.RedPointCustomCondition;
local ChouJian = require "Logic.ZhenCangGeSystem.ZhenCangGeChouJian"
local Reward = require "Logic.ZhenCangGeSystem.ZhenCangGeReward"
local Exchange = require "Logic.ZhenCangGeSystem.ZhenCangGeExchange"
-- Lottery data
local L_DicCjData = Dictionary:New()
local L_CjFinallCount = -1
local L_CjRefreashTime = -1
-- Consumed props Id
local L_CostData = nil

-- Received data
local L_DicReward = Dictionary:New()
-- Number of draws required to refresh the prize-winning props
local L_RewardRefreashPoint = -1

-- Redemption data
local L_DicExchange = Dictionary:New()
local ZhenCangGeSystem = {
    -- Number of lottery draws
    PayCount = 0,
    -- Final Prize {Id, Num, Value}
    FinallItem = nil,
    -- The number of rounds of the final round of the lottery
    ChouJiangFinallCount = -1,
    -- Number of rounds of awards
    RewardStep = 1,
    RewardIsChange = false,
}

function ZhenCangGeSystem:Initialize()
    -- Set a lottery red dot
    self:SetChouJiangRedPoint()
end

-- Calculate the refresh end time
function ZhenCangGeSystem:GetEndTime()
    local openTime = Time.GetOpenSeverDay()
    local refreashDay = self:GetChouJiangRereashTime()
    local time = openTime % refreashDay
    if time == 0 then
        time = refreashDay
    end
    local hour, min, sec = TimeUtils.GetStampTimeHHMMSS(math.floor(GameCenter.HeartSystem.ServerTime))
    local curSeconds = hour * 3600 + min * 60 + sec
    time = refreashDay * 24 * 3600 - (time - 1) * 24 * 2600 - curSeconds
    time = GameCenter.HeartSystem.ServerZoneTime + time
    return time
end

-- Get the consumed currency
function ZhenCangGeSystem:GetChouJiangCostData()
    if L_CostData == nil then
        local param = DataConfig.DataGlobal[GlobalName.CangZhenGe_need_item].Params
        local list = Utils.SplitNumber(param, '_')
        L_CostData = {Id = list[1], Num = list[2]}
    end
    return L_CostData
end

-- ====================================================================================================--
-- Get the lottery dictionary
function ZhenCangGeSystem:GetCjDatas()
    if L_DicCjData:Count() == 0 then
        DataConfig.DataRechargeDailyCangzhenge:Foreach(function(k, v)
            local key = v.Times
            local data = ChouJian:New(k, v)
            local list = L_DicCjData[key]
            if list == nil then
                list = List:New()
                list:Add(data)
            else
                list:Add(data)
            end
            L_DicCjData[key] = list
        end)
    end
    return L_DicCjData
end

-- Get the last round of the lottery
function ZhenCangGeSystem:GetChouJianFinallCount()
    if L_CjFinallCount == -1 then
        local dic = self:GetCjDatas()
        if dic ~= nil then
            local keys = dic:GetKeys()
            if keys ~= nil then
                for i = 1, #keys do
                    local key = keys[i]
                    local dataList = dic[key]
                    if dataList ~= nil then
                        for m = 1, #dataList do
                            local data = dataList[m]
                            local cfg = data:GetCfg()
                            if cfg ~= nil and cfg.End == 1 then
                                L_CjFinallCount = key
                            end
                        end
                    end
                end
            end
        end
    end
    return L_CjFinallCount
end

-- Get the lottery refresh interval
function ZhenCangGeSystem:GetChouJiangRereashTime()
    if L_CjRefreashTime == -1 then
        local param = DataConfig.DataGlobal[GlobalName.CangZhenGe_Refresh_time].Params
        local list = Utils.SplitNumber(param, '_')
        L_CjRefreashTime = list[1]
    end
    return L_CjRefreashTime
end

-- Which round of the current draw is obtained
function ZhenCangGeSystem:GetChouJiangStep()
    local openTime = Time.GetOpenServerTime()
    local refreashTime = self:GetChouJiangRereashTime()
    local finallStep = self:GetChouJianFinallCount()
    local curStep = math.ceil(openTime / refreashTime)
    if curStep > finallStep then
        curStep = finallStep
    end
    return curStep
end

-- Get the current round of lottery data
function ZhenCangGeSystem:GetCurChouJianDatas()
    local ret = nil
    local curStep = self:GetChouJiangStep()
    local dic = self:GetCjDatas()
    if dic ~= nil then
        ret = dic[curStep]
    end
    return ret
end

-- Get daily recharge display data
function ZhenCangGeSystem:GetCurChouJianDatasEx()
    local ret = List:New()
    local dataList = self:GetCurChouJianDatas()
    for i = 1, #dataList do
        local data = dataList[i]
        if data:IsSuper() then
            ret:Add(data)
        end
    end
    return ret
end 

-- Lottery prop data
function ZhenCangGeSystem:GetChouJiangData(cfgId)
    local ret = nil
    local dataList = self:GetCurChouJianDatas()
    if dataList ~= nil then
        for i = 1, #dataList do
            local data = dataList[i]
            if data:GetCfgId() == cfgId then
                ret = data
            end
        end
    end
    return ret
end

-- Setting up lottery red dots
function ZhenCangGeSystem:SetChouJiangRedPoint()
    local _condition = List:New()
    local costData = self:GetChouJiangCostData()
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.ZhenCangGe)
    _condition:Add(L_RedPointItemCondition(costData.Id, costData.Num))
    GameCenter.RedPointSystem:LuaAddFuncCondition(FunctionStartIdCode.ZhenCangGe, 0, _condition)
end

-- ====================================================================================================--

-- Get the award data dictionary
function ZhenCangGeSystem:GetRewardDatas()
    if L_DicReward:Count() == 0 then
        local preValue = 0
        local preType = 0
        DataConfig.DataRechargeDailySuperreward:Foreach(function(k, v)
            local key = v.Times
            local data = Reward:New(k, v)
            if preType ~= key then
                preValue = 0
                preType = key
            end
            data.PreValue = preValue
            local list = L_DicReward[key]
            if list == nil then
                list = List:New()
                list:Add(data)
            else
                list:Add(data)
            end
            L_DicReward[key] = list
            preValue = data:GetNeedCount()
        end)
    end
    return L_DicReward
end

-- Number of draws required to get refreshed and receive the prize prop
function ZhenCangGeSystem:GetRewardRefreashPoint()
    if L_RewardRefreashPoint == -1 then
        local param = DataConfig.DataGlobal[GlobalName.Superreward_Refresh_time].Params
        local list = Utils.SplitNumber(param, '_')
        L_RewardRefreashPoint = list[1]
    end
    return L_RewardRefreashPoint
end

-- Get the current round of award list
function ZhenCangGeSystem:GetCurRewardList()
    local ret = nil
    local dic = self:GetRewardDatas()
    if dic ~= nil then
        ret = dic[self.RewardStep]
    end
    return ret
end

-- Get the final prize
function ZhenCangGeSystem:GetFinallItem()
    local dic = self:GetRewardDatas()
    if dic ~= nil then
        local dataList = dic[self.RewardStep]
        if dataList ~= nil then
            return dataList[#dataList]
        end
    end
    return nil
end

-- Progress in obtaining the final prize
function ZhenCangGeSystem:GetFinallProcess()
    local ret = 0
    local data = self:GetFinallItem()
    if self.PayCount > data.PreValue then
        ret = (self.PayCount - data.PreValue) / (data.Value - data.PreValue)
    end
    if ret > 1 then
        ret = 1
    end
    return ret
end

-- Set up red dots for receiving awards
function ZhenCangGeSystem:SetRewardRedPoint()
    local dataList = self:GetCurRewardList()
    if dataList == nil then
        return
    end
    local _conditions = List:New();
    GameCenter.RedPointSystem:RemoveFuncCondition(FunctionStartIdCode.ZhenCangGe, 1)
    for i = 1, #dataList do
        local data = dataList[i]
        if not data:IsReward() then
            -- Can display red dots
            _conditions:Add(L_RedPointCustomCondition(data:GetNeedCount() <= self.PayCount))
            GameCenter.RedPointSystem:LuaAddFuncCondition(FunctionStartIdCode.ZhenCangGe, 1, _conditions);
            break
        end
    end
end

-- ===================================================================================================--

-- Get redemption data dictionary
function ZhenCangGeSystem:GetExchangeDic()
    if L_DicExchange:Count() == 0 then
        DataConfig.DataRechargeDailyDuibaodian:Foreach(function(k, v)
            local key = v.Times
            local data = Exchange:New(k, v)
            local list = L_DicExchange[key]
            if list == nil then
                list = List:New()
                list:Add(data)
            else
                list:Add(data)
            end
            L_DicExchange[key] = list
        end)
    end
    return L_DicExchange
end

-- Get the current redemption data list
function ZhenCangGeSystem:GetCurExchangeDatas()
    local list = nil
    local dic = self:GetExchangeDic()
    local step = self:GetChouJiangStep()
    if dic ~= nil then
        list = dic[step]
    end
    return list
end

-- Set redemption dots
function ZhenCangGeSystem:SetExchangeRedPoint()
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.DuiBaoDian)
    local dataList = self:GetCurExchangeDatas()
    if dataList == nil then
        return
    end
    for i = 1, #dataList do
        local data = dataList[i]
        if data:GetCount() < data:GetAllCount() and data.IsWarning then
            local costData = data:GetCostData()
            GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.DuiBaoDian, data:GetCfgId(), L_RedPointItemCondition(costData.Id, costData.Num))
        end
    end
end

-- =================================================================================================-

-- Request to open the lottery interface
function ZhenCangGeSystem:ReqOpenCangbaogePanel()
    GameCenter.Network.Send("MSG_Cangbaoge.ReqOpenCangbaogePanel")
end

-- Request to open the recording interface
function ZhenCangGeSystem:ReqOpenRecordPanel()
    GameCenter.Network.Send("MSG_Cangbaoge.ReqOpenRecordPanel")
end

-- Request a lottery
function ZhenCangGeSystem:ReqCangbaogeLottery()
    GameCenter.Network.Send("MSG_Cangbaoge.ReqCangbaogeLottery")
end

-- Request for a prize
function ZhenCangGeSystem:ReqCangbaogeReward(rewardId)
    GameCenter.Network.Send("MSG_Cangbaoge.ReqCangbaogeReward", {id = rewardId})
end

-- Request to open the redemption interface
function ZhenCangGeSystem:ReqOpenCangbaogeExchange()
    GameCenter.Network.Send("MSG_Cangbaoge.ReqOpenCangbaogeExchange")
end

-- Request redemption
function ZhenCangGeSystem:ReqCangbaogeExchange(id)
    GameCenter.Network.Send("MSG_Cangbaoge.ReqCangbaogeExchange", {exchangeId = id})
end

-- Open the lottery interface to return
function ZhenCangGeSystem:ResOpenCangbaogePanel(msg)
    if msg == nil then
        return
    end
    self.PayCount = msg.lotteryTimes
    self.RewardStep = msg.curSuperRound
    local rewardDataList = self:GetCurRewardList()
    if msg.alreadyGetID ~= nil then
        for i = 1, #rewardDataList do
            local rewardData = rewardDataList[i]
            rewardData:SetReward(false)
        end
        for i = 1, #msg.alreadyGetID do
            for m = 1, #rewardDataList do
                local rewardData = rewardDataList[m]
                if rewardData:GetCfgId() == msg.alreadyGetID[i] then
                    rewardData:SetReward(true)
                end
            end
        end
    end
    -- Set up red dots to collect once
    self:SetRewardRedPoint()
end

-- Open the prize record and return
function ZhenCangGeSystem:ResOpenRecordPanel(msg)
    if msg == nil then
        return
    end
    local list = List:New()
    if msg.recordList ~= nil then
        for i = 1, #msg.recordList do
            local record = msg.recordList[i]
            local data = {Time = record.time, Name = record.playerName, ItemId = record.itemId, Num = record.num}
            list:Add(data)
        end
    end
    list:Sort(function(a,b)
        return a.Time > b.Time
     end )
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_CANGBAOGE_RECORD, list)
end

-- Return to lottery
function ZhenCangGeSystem:ResCangbaogeLottery(msg)
    if msg == nil then
        return
    end
    self.PayCount = msg.lotteryTimes
    local data = self:GetChouJiangData(msg.lotteryID)
    local occ = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
    local itemData = data:GetItemData(occ)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_ZHENBAOGE_CHOUJIANG_RESULT, itemData)
    -- Set up red dots to collect once
    self:SetRewardRedPoint()
end

-- Return to receive the prize
function ZhenCangGeSystem:ResCangbaogeReward(msg)
    self.RewardIsChange = false
    if msg == nil then
        return
    end
    local list = List:New()
    local isChange = false
    self.RewardStep = msg.curSuperRound
    self.PayCount = msg.lotteryTimes
    local rewardDataList = self:GetCurRewardList()
    if msg.alreadyGetID ~= nil then
        for i = 1, #rewardDataList do
            local rewardData = rewardDataList[i]
            for m = 1, #msg.alreadyGetID do
                if rewardData:GetCfgId() == msg.alreadyGetID[m] and not rewardData:IsReward() then
                    local item = rewardData:GetItemData()
                    list:Add(item)
                    --GameCenter.PushFixEvent(UIEventDefine.UIWelfareGetItemForm_OPEN, list)
                end
            end
            rewardData:SetReward(false)
        end
        for i = 1, #msg.alreadyGetID do
            for m = 1, #rewardDataList do
                local rewardData = rewardDataList[m]
                if rewardData:GetCfgId() == msg.alreadyGetID[i] then
                    rewardData:SetReward(true)
                end
            end
        end
    else
        isChange = true
        self.RewardIsChange = true
        for i = 1, #rewardDataList do
            local rewardData = rewardDataList[i]
            rewardData:SetReward(false)
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_ZHENBAOGE_REWARD_RESULT, true)
    -- Set up red dots to collect once
    self:SetRewardRedPoint()
end

-- Open the redemption interface to return
function ZhenCangGeSystem:ResOpenCangbaogeExchange(msg)
    if msg == nil then
        return
    end
    local dataList = self:GetCurExchangeDatas()
    if dataList == nil then
        return
    end
    if msg.exchangeMaps ~= nil then
        for i = 1, #dataList do
            local data = dataList[i]
            for m = 1, #msg.exchangeMaps do
                local resData = msg.exchangeMaps[m]
                if resData.exchangeID == data:GetCfgId() then
                    data.CurCount = resData.exchangeNum
                end
            end 
        end
    else
        for i = 1, #dataList do
            local data = dataList[i]
            data.CurCount = 0
        end
    end
    self:SetExchangeRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_CANGBAOGE_EXCHANGE_RESULT, true)
end

-- Redeem back
function ZhenCangGeSystem:ResCangbaogeExchange(msg)
    local dataList = self:GetCurExchangeDatas()
    if dataList == nil then
        return
    end
    for i = 1, #dataList do
        local data = dataList[i]
        if data:GetCfgId() == msg.exchangeData.exchangeID then
            data.CurCount = msg.exchangeData.exchangeNum
        end
    end
    self:SetExchangeRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_CANGBAOGE_EXCHANGE_RESULT, false)
end

return ZhenCangGeSystem
