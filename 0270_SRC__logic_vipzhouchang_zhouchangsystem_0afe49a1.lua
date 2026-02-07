
------------------------------------------------
-- author:
-- Date: 2019-12-19
-- File: ZhouChangSystem.lua
-- Module: ZhouChangSystem
-- Description: VIP perimeter system
------------------------------------------------
-- Quote
local TimeUtils = CS.Thousandto.Core.Base.TimeUtils;
local BaseData = require "Logic.VipZhouChang.ZcTaskData"
local ZhouChangSystem = {
    LeftTime = 0,
    SyncTime = 0,
    -- The amount of currency currently obtained
    CurCoinNum = 0,
    -- Total amount of currency available
    TotalCoinNum = 0,
    -- Refresh the time next time
    ReFreashTime = 0,
    IsEnable = false,
    DicTaskData = Dictionary:New(),
    DicReward = Dictionary:New(),
}

function ZhouChangSystem:Initialize()
    -- Initialize the configuration table
    self.TotalCoinNum = 0
    self.CurCoinNum = 0
    DataConfig.DataVIPWeek:Foreach(function(k, v)
        local cfg = DataConfig.DataVIPWeek[k]
        if cfg ~= nil then
            local list = Utils.SplitStr(cfg.TaskNum,'_')
            local key = tonumber(list[1])
            local data = nil
            if self.DicTaskData:ContainsKey(key) then
                data = self.DicTaskData[key]
                data:ParseCfg(v)
            else
                data = BaseData:New()
                data:ParseCfg(v)
                self.DicTaskData:Add(key,data)
            end
        end
    end)

    -- Initialize the award data
    DataConfig.DataVIPWeekReward:Foreach(function(k, v)
        local _data = {Id = k, NormalReward = false, WeekReward = false}
        self.DicReward:Add(k,_data)
    end)
end

function ZhouChangSystem:UnInitialize()
end

-- Get the first task data
function ZhouChangSystem:GetFirstGroupData()
    local keys = self.DicTaskData:GetKeys()
    if keys ~= nil and #keys >= 1 then
        return self.DicTaskData[keys[1]]
    end
end

function ZhouChangSystem:GetGroupData(groupId)
    if self.DicTaskData:ContainsKey(groupId) then
        return self.DicTaskData[groupId]
    end
    return nil
end

-- Get the total quest reward currency according to the task groupId
function ZhouChangSystem:GetGroupCoins(groupId)
    if self.DicTaskData:ContainsKey(groupId) then
        local groupTasks = self.DicTaskData[groupId]
        if groupTasks ~= nil then
            return groupTasks:GetTotalCoin()
        end
    end
end

-- Get the currency for the remaining task rewards based on the task groupId
function ZhouChangSystem:GetGroupLeftCoins(groupId)
    if self.DicTaskData:ContainsKey(groupId) then
        local groupTasks = self.DicTaskData[groupId]
        if groupTasks ~= nil then
            return groupTasks:GetLeftCoin()
        end
    end
end

-- Get the total number of tasks according to the task groupId
function ZhouChangSystem:GetGroupTaskNum(groupId)
    if self.DicTaskData:ContainsKey(groupId) then
        local groupTasks = self.DicTaskData[groupId]
        if groupTasks ~= nil then
            return groupTasks:GetTotalTaskNum()
        end
    end
    return 0
end

-- Get task based on task groupId icon
function ZhouChangSystem:GetGroupTaskIcon(groupId)
    if self.DicTaskData:ContainsKey(groupId) then
        local groupTasks = self.DicTaskData[groupId]
        if groupTasks ~= nil then
            return groupTasks.IconId
        end
    end
    return -1
end

-- Obtain the number of completed tasks according to the task groupId
function ZhouChangSystem:GetGroupFinishTaskNum(groupId)
    if self.DicTaskData:ContainsKey(groupId) then
        local groupTasks = self.DicTaskData[groupId]
        if groupTasks ~= nil then
            return groupTasks:GetFinishTaskNum()
        end
    end
    return 0
end

-- Get task data based on task id
function ZhouChangSystem:GetTaskData(taskId)
    self.DicTaskData:Foreach(function(k, v)
        local taskData = v:GetTaskData(taskId)
        if taskData ~= nil then
            return taskData
        end
	end)
end

-- Whether all tasks to obtain the specified tag id of the specified group have been completed
function ZhouChangSystem:GetIsFinishTabTask(groupId, tabId)
    if self.DicTaskData:ContainsKey(groupId) then
        local groupTasks = self.DicTaskData[groupId]
        if groupTasks ~= nil then
            return groupTasks:IsFinishAllTask(tabId)
        end
    end
    return false
end

-- Calculate the remaining time
function ZhouChangSystem:GetLeftTime()
    local serverTime = GameCenter.HeartSystem.ServerTime
    local week, h, m, s = TimeUtils.GetStampTimeWeekHHMMSS(math.floor( serverTime ))
    if week == 0 then
        week = 7
    end
    local leftTime = (7 - week) * 24 * 3600 + (24*3600 - (h*3600 + m * 60 + s))
    return leftTime
end

function ZhouChangSystem:Reset()
    self.DicTaskData:Foreach(function(k, v)
        v:ResetTasks()
	end)
end

function ZhouChangSystem:Update(dt)
    if not self.IsEnable then
        return
    end
    local serverTime = GameCenter.HeartSystem.ServerTime
    local week, h, m, s = TimeUtils.GetStampTimeWeekHHMMSS(math.floor( serverTime ))
    if week == 0 then
        week = 7
    end
    local leftTime = (7 - week) * 24 * 3600 + (24*3600 - (h*3600 + m * 60 + s))
    if self.ReFreashTime == 0 then
        self.ReFreashTime = serverTime + leftTime
    end
    if serverTime >= self.ReFreashTime then
        self.ReFreashTime = serverTime + leftTime
        self:Reset()
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_IVPWEEK_UPDATE)
    end
end

function ZhouChangSystem:UpdateRedPoint()
    local haveCoinNum = self:GetCurCoinNum()
    local conditionNum = 0
    local isRewardShowRedPoint = false
    self.DicReward:Foreach(function(k, v)
        -- Red dot processing
        if not isRewardShowRedPoint then
            local cfgReward = DataConfig.DataVIPWeekReward[k]
            conditionNum = cfgReward.Condition
            if v.NormalReward then
                isRewardShowRedPoint = false
            else
                -- No ordinary rewards received
                if haveCoinNum >=  conditionNum then
                    -- Available to buy
                    isRewardShowRedPoint = true
                else
                    isRewardShowRedPoint = false
                end 
            end
            if not isRewardShowRedPoint then
                if v.WeekReward then
                    -- Received additional rewards
                    isRewardShowRedPoint = false
                else
                    -- No additional rewards received
                    if v.NormalReward then
                        -- Determine whether you can receive weekly card rewards
                        if GameCenter.WelfareSystem.WelfareCard:IsBought(SpecialCard.Week) then
                            isRewardShowRedPoint = true
                        end                        
                    else
                        isRewardShowRedPoint = false
                    end
                end
            end
        end
    end)
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.VipWeekReward,isRewardShowRedPoint)
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.VipWeekBase,isRewardShowRedPoint)
end

-------------------------------------------------msg---------------------------
-- Request a reward for circumference
function ZhouChangSystem:ReqVipWeekReward(taskId, cardType)
    GameCenter.Network.Send("MSG_Vip.ReqVipWeekReward", {id = taskId, flag = cardType})
end

-- Return to the existing goals and award records of the circumference
function ZhouChangSystem:ResVipWeekList(result)
    if result == nil then
        return 
    end
    if result.weekTargets ~= nil then
        for i = 1,#result.weekTargets do
            local cfg = DataConfig.DataVIPWeek[result.weekTargets[i].id]
            if cfg ~= nil then
                local list = Utils.SplitStr(cfg.TaskNum,'_')
                if list ~= nil then
                    local key = tonumber(list[1])
                    if self.DicTaskData:ContainsKey(key) then
                        local v = self.DicTaskData[key]
                        v:ParaseMsg(result.weekTargets)
                    end
                end
            end
        end
    end
    if result.weekReward ~= nil then
        for i = 1,#result.weekReward do
            if self.DicReward:ContainsKey(result.weekReward[i].id) then
                local reward = self.DicReward[result.weekReward[i].id]
                reward.NormalReward = result.weekReward[i].normalReward
                reward.WeekReward = result.weekReward[i].weekReward
            end
        end
    end

    --self.CurCoinNum = 0
    self.TotalCoinNum = 0
    self.DicTaskData:Foreach(function(k, v)
        self.TotalCoinNum = self.TotalCoinNum + v:GetTotalCoin()
        --self.CurCoinNum = self.CurCoinNum + v:GetRewardCoin()
    end)

    self:UpdateRedPoint()
    self.IsEnable = true
end

function ZhouChangSystem:GetCurCoinNum()
    local ret = 0
    self.DicTaskData:Foreach(function(k, v)
        ret = ret + v:GetRewardCoin()
    end)
    return ret
end

-- Update the perimeter target
function ZhouChangSystem:ResUpdateWeekTarget(result)
    if result == nil then
        return
    end
    local cfg = DataConfig.DataVIPWeek[result.weekTarget.id]
    if cfg ~= nil then
        local list = Utils.SplitStr(cfg.TaskNum,'_')
        if list ~= nil then
            local key = tonumber(list[1])
            if self.DicTaskData:ContainsKey(key) then
                local v = self.DicTaskData[key]
                v:UpdateTask(result.weekTarget.id,result.weekTarget.prog)
            end
        end
    end

    self:UpdateRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_IVPWEEK_UPDATE)
end

-- Return to receive the prize
function ZhouChangSystem:ResVipWeekReward(reuslt)
    if reuslt  == nil then
        return
    end
    if self.DicReward:ContainsKey(reuslt.weekReward.id) then
        local reward = self.DicReward[reuslt.weekReward.id]
        reward.NormalReward = reuslt.weekReward.normalReward
        reward.WeekReward = reuslt.weekReward.weekReward
    end

    self:UpdateRedPoint()
    -- Update the award-winning interface
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_IVPWEEK_UPDATE)
end

return ZhouChangSystem