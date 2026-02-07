------------------------------------------------
-- Author:
-- Date: 2021-06-30
-- File: PrefectRomanceSystem.lua
-- Module: PrefectRomanceSystem
-- Description: Perfect Love System
------------------------------------------------
local L_TimeUtils = CS.Thousandto.Core.Base.TimeUtils;

-- //Module definition
local PrefectRomanceSystem =
{
    TaskDict = nil,
    RankFuncList = nil,
    -- Ranked data
    RankData = {},
    -- Mall data[id,count]
    ShopDict = nil,
    -- Remaining time for the event
    LeftTime = nil,
}

-- //Member function definition
-- initialization
function PrefectRomanceSystem:Initialize()
    self.TaskDict = Dictionary:New()
    self.ShopDict = Dictionary:New()

    -- Analyze the function jump button information of ranking configuration
    local _params = DataConfig.DataGlobal[1961].Params
    self.RankFuncList = List:New()
    local _ps = Utils.SplitStr(_params, ';')
    for i = 2, _ps[1] + 1 do
        local _s = Utils.SplitStr(_ps[i], '_')
        local _icon = _ps[_ps[1] + i]
        local _data = {}
        _data.FunId = _s[1]
        _data.Name = _s[2]
        _data.Icon = _icon
        self.RankFuncList:Add(_data)
    end

    if self.TimerID ~= nil then
        GameCenter.TimerEventSystem:RemoveTimerEvent(self.TimerID)
    end
    -- Add a timer to execute at 1 second every morning
    self.TimerID = GameCenter.TimerEventSystem:AddTimeStampDayEvent(1, 86400,
    true, nil, function(id, remainTime, param)
        self:GetLeftTime()
    end)

    DataConfig.DataMarryActivityTask:ForeachCanBreak(
        function(_id, _cfg)
            self.TaskDict[_id] = {
                Cfg = _cfg,
                taskID = _id,
                progress = 0,
                state = false
            }
        end
    )
end

-- De-initialization
function PrefectRomanceSystem:UnInitialize()
    self.TaskDict:Clear()
    self.RankFuncList:Clear()
    self.ShopDict:Clear()
    -- Delete the timer
    GameCenter.TimerEventSystem:RemoveTimerEvent(self.TimerID)
end

function PrefectRomanceSystem:SetOpenServerTime(time)
    self.ServerOpenTime = math.floor(time / 1000) + GameCenter.HeartSystem.ServerZoneOffset
    self:GetLeftTime()
end

-- Get the remaining time of the event
function PrefectRomanceSystem:GetLeftTime()
    if self.ServerOpenTime == nil then
        return 0
    end
    if self.EndTime == nil then
        local _day = tonumber(DataConfig.DataGlobal[1960].Params)
        -- What time is the day when the server is launched
        local _hour, _min, _sec = L_TimeUtils.GetStampTimeHHMMSSNotZone(math.floor(self.ServerOpenTime))
        local _curSeconds = _hour * 3600 + _min * 60 + _sec
        -- Calculate the end time
        self.EndTime = self.ServerOpenTime - _curSeconds + _day * 86400
    end
    self.LeftTime = self.EndTime - GameCenter.HeartSystem.ServerZoneTime
    local _funcIsVisible = true
    if self.LeftTime <= 0 then
        _funcIsVisible = false
    end
    if self.FuncIsVisible ~= _funcIsVisible then
        self.FuncIsVisible = _funcIsVisible
        GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.PrefectRomance, _funcIsVisible)
    end
    return self.LeftTime
end

-- Love Store Purchase Response
function PrefectRomanceSystem:ResMarryActivityShopBuy(msg)
    if msg ~= nil then
        local _list = msg.shopInfoList
        if _list ~= nil then
            for i = 1, #_list do
                local _data = _list[i]
                if _data.shopId ~= nil and _data.buyCount ~= nil then
                    if self.ShopDict:ContainsKey(_data.shopId) then
                        self.ShopDict[_data.shopId] = _data.buyCount
                    else
                        self.ShopDict:Add(_data.shopId, _data.buyCount)
                    end
                end
            end
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_PREFECT_GIFT_REFESH, msg)
end

-- Perfect love acquisition Intimacy return
function PrefectRomanceSystem:ResMarryActivityIntimacy(msg)
    self.RankData = {}
    self.RankData.Rank = msg.rank
    self.RankData.Intimacy = msg.intimacy
    self.RankData.ReceivedList = List:New()
    -- Reward ID received
    local _hasReceivedDict = Dictionary:New()
    if msg.rankRewardEd ~= nil then
        self.RankData.ReceivedList:AddRange(msg.rankRewardEd)
        for i = 1, #msg.rankRewardEd do
            local _id = msg.rankRewardEd[i]
            _hasReceivedDict[_id] = _id
        end
    end
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.PrefectSpouse, false);
    DataConfig.DataMarryActivityRank:ForeachCanBreak(
        function(_id, _cfg)
            -- Haven't received the reward yet
            if not _hasReceivedDict:ContainsKey(_id) then
                if msg.rank ~= nil then
                    -- Only need to care about 0 [personal]
                    if _cfg.RewardType == 0 then
                        -- Meet the standard
                        if msg.intimacy >= _cfg.Limit then
                            GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.PrefectSpouse, true);
                            return true
                        end
                    end
                end
            end
        end
    )
    -- Refresh ranking data
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_PREFECT_RANK_REFESH, msg)
end

-- Love mission progress refresh
function PrefectRomanceSystem:ResRefreshMarryActivityTask(msg)
    if msg.taskData ~= nil then
        local _taskDatas = msg.taskData
        for i = 1, #_taskDatas do
            --ID
            local _id = _taskDatas[i].taskID
            self.TaskDict[_id].taskID = _taskDatas[i].taskID
            self.TaskDict[_id].progress = _taskDatas[i].progress
            self.TaskDict[_id].state = _taskDatas[i].state
        end
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.PrefectTask, false);
        DataConfig.DataMarryActivityTask:ForeachCanBreak(
            function(_id, _cfg)
                if self.TaskDict:ContainsKey(_id) then
                    local _data = self.TaskDict[_id]
                    if _cfg.Type == 1 then
                        local _cond = Utils.SplitStr(_cfg.Condition, '_')
                        local _count = #_cond
                        -- Set a red dot when no award is received and the conditions are met
                        if not _data.state and _data.progress >= tonumber(_cond[_count]) then
                            GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.PrefectTask, true);
                            return true
                        end
                    else
                        if  not _data.state and _data.progress >= tonumber(_cfg.Rate) then
                            GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.PrefectTask, true);
                            return true
                        end
                    end
                end
            end
        )
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_PREFECT_TASK_REFESH)
end

-- Update your heartbeat
function PrefectRomanceSystem:Update(dt)
end

return PrefectRomanceSystem
