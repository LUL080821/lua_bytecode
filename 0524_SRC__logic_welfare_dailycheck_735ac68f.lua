------------------------------------------------
-- author:
-- Date: 2019-12-04
-- File: DailyCheck.lua
-- Module: DailyCheck
-- Description: Daily welfare sign-in
------------------------------------------------

local DailyCheck = {
    -- Will you sign in today
    IsCheck = false,
    -- Cumulative number of sign-in days
    DayNum = 0,
    -- Which day can I sign today?
    CheckInDay = 0,
    -- Re-sign ID
    MakeUpCfgId = 0,
    -- Sign-in type 0: Normal sign-in 1: Re-sign
    CheckType = -1,
    -- What round of rewards
    Round = 0,
    -- List of normal check-in
    CheckList = List:New(),
    -- List of re-signatures
    MakeUpList = List:New(),
    -- List of rewards received
    RewardList = List:New(),
    -- Reward configuration
    RewardCfgList = nil,
    -- Check-in configuration
    DailyCheckCfgList = List:New(),
    -- Is it prompted
    IsShowTips = true,
    -- Maximum number of sign-in days
    MaxDay = 0,
}

function DailyCheck:Initialize()
    IsShowTips = true;
    self.DailyCheckCfgList:Clear()
    DataConfig.DataSignReward:Foreach(function(k, v)
        self.MaxDay = self.MaxDay < v.Day and v.Day or self.MaxDay;
        self.DailyCheckCfgList:Add(v)
    end)
    table.sort(self.DailyCheckCfgList, function(a, b)
        return a.Day < b.Day
    end)
    return self
end

function DailyCheck:UnInitialize()
    self.Round = 0
    self.CheckList:Clear()
    self.MakeUpList:Clear()
    self.RewardList:Clear()
    self.DailyCheckCfgList:Clear()
    if self.RewardCfgList then
        self.RewardCfgList = nil
    end
end

-- Detect red dot display
function DailyCheck:CheckShowRedPoint()
    local _showRed = false
    if not self.IsCheck then
        _showRed = true
    else
        _showRed = self:CheckRewardRed()
    end
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.WelfareDailyCheck, _showRed)
end

-- Check if there is a reward to receive
function DailyCheck:CheckRewardRed()
    if self.RewardCfgList then
        for i=1, #self.RewardCfgList do
            if self.DayNum >= self.RewardCfgList[i].Day 
                and (not self.RewardList:Contains(self.RewardCfgList[i].Id)) then
                return true
            end
        end
    end
    return false
end

-- Test whether you can receive the prize
function DailyCheck:CheckIsReward(id)
    if self.RewardList:Contains(id) then
        return false
    end
    local _cfg = DataConfig.DataSignRewardCumulative[id]
    if _cfg then
        return _cfg.Day <= self.DayNum
    end
    return false
end

-- Get the current round reward configuration
function DailyCheck:GetCurrRoundRewardCfg()
    local _cfg = List:New()
    DataConfig.DataSignRewardCumulative:Foreach(function(k, v)
        if v.Round == self.Round then
            _cfg:Add(v)
        end
    end)
    table.sort( _cfg, function(a, b)
        return a.Day < b.Day
    end)
    return _cfg
end

-- Request to sign in
function DailyCheck:ReqDayCheckIn(id, checkType)
    local _req = {}
    _req.typ = 1
    _req.cfgID = id
    if checkType == 1 then
        self.MakeUpCfgId = id
    end
    if not checkType then
        _req.typ = 2
    end
    self.CheckType = checkType
    GameCenter.Network.Send("MSG_Welfare.ReqDayCheckIn", _req)
end

-- Daily check-in data
function DailyCheck:GS2U_ResDayCheckInData(msg)
    self.IsCheck = msg.isCheckIn
    self.DayNum = msg.day
    self.CheckInDay = msg.checkInDay > self.MaxDay and self.MaxDay or msg.checkInDay
    if msg.checkIns then
        self.CheckList = List:New(msg.checkIns)
    else
        self.CheckList = List:New()
    end
    if msg.checkIn2s then
        self.MakeUpList = List:New(msg.checkIn2s)
    else
        self.MakeUpList = List:New()
    end
    if msg.rewardCfgID then
        self.RewardList = List:New(msg.rewardCfgID)
    end
    if self.Round ~= msg.round or (not self.RewardCfgList) then
        self.Round = msg.round
        self.RewardCfgList = self:GetCurrRoundRewardCfg()
    end

    if self.CheckType == 0 and self.IsCheck then
        Utils.ShowPromptByEnum("WELFARE_SignSuccess")
        self.CheckType = -1
    end
    if self.CheckType == 1 and self.MakeUpList:Contains(self.MakeUpCfgId) then
        Utils.ShowPromptByEnum("RetroactiveSucced")
        self.CheckType = -1
        self.MakeUpCfgId = 0
    end
    self:CheckShowRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_WELFARE_DAILYCHECK_REFRESH)
end

return DailyCheck
