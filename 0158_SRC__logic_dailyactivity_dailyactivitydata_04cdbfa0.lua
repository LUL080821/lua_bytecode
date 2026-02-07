
------------------------------------------------
-- Author:
-- Date: 2019-04-22
-- File: DailyActivityData.lua
-- Module: DailyActivityData
-- Description: Daily data
------------------------------------------------

local DailyActivityData = {
    -- Activity configuration
    Cfg = nil,
    -- Activity ID
    ID = 0,
    -- Whether the function is enabled (corresponding to the on condition)
    Open = false,
    -- Whether the activity is on (corresponding to the opening time)
    IsOpen = false,
    IsCloseShow = false,
    -- Whether the activity is completed
    Complete = false,
    -- Show serial number
    ShowSort = 0,
    -- Sort number
    Sort = 0,
    -- Number of remaining times
    RemindCount = 0,
    -- Number of purchases available
    CanBuyCount = 0,
    -- Reward list
    RewardList = List:New()
}

-- Initial activity data
function DailyActivityData:New(info,cfg)
    local _M = Utils.DeepCopy(self)
    _M.Cfg = cfg
    _M.ID = info.activeId
    _M.Open = info.conditionOpen
    _M.IsOpen = info.open
    _M.RemindCount = info.remainCount
    _M.CanBuyCount = info.canBuyCount
    if cfg ~= nil then
        _M.IsCloseShow = cfg.IsCloseShow
    end
    _M:RefreshData(cfg)
    return _M
end

-- Refresh activity data
function DailyActivityData:RefreshData(cfg)
    self.Sort = cfg.Sort
    self.RewardList = Utils.SplitStr(cfg.Reward, ";")
    if cfg.Times == -1 then
        self.Complete = false
    else
        self.Complete = self.CanBuyCount == 0 and self.RemindCount == 0
    end
    if self.Complete and self.ID == 3 then
        -- Special treatment of bounty
        self.Complete = GameCenter.LuaTaskManager:AllDailyTaskRewared()
    end
    -- Head of the sect special treatment
    if self.ID == 2 then
        local _active = GameCenter.ItemContianerSystem:GetEconomyWithType(ItemTypeCode.ActivePoint)
        self.IsOpen = _active > 0
    end
    if self.Complete then
        self.ShowSort = 4
    else
        if (not self.IsOpen) or (not self.Open) then
            self.ShowSort = 3
        else
            self.ShowSort = 1
        end
    end
end

-- Refresh event information
function DailyActivityData:UpdateInfo(info)
    -- self.Open = info.conditionOpen
    -- self.IsOpen = info.open
    self.RemindCount = info.remainCount
    self.CanBuyCount = info.canBuyCount
    -- Refresh data
    self:RefreshData(self.Cfg)
end

-- Set activity on and off
function DailyActivityData:SetActivityOpen(open)
    self.IsOpen = open
end

-- Is the minimum number of days to open?
function DailyActivityData:IsToMinOpenDay()
    local _openDayArr = Utils.SplitNumber(self.Cfg.DelayDays, "_");
    local _curOpenDay = Time.GetOpenSeverDay();
    for i=1, #_openDayArr do
        if _openDayArr[i] == 0 then
            return true;
        elseif _openDayArr[i] <= _curOpenDay and self.Cfg.IfGono == 1 then
            return true;
        elseif _openDayArr[i] == _curOpenDay and self.Cfg.IfGono == 0 then
            return true;
        end
    end
    return false;
end

-- Get the current status
function DailyActivityData:GetState()
    -- Level not satisfied
    local _curLevel = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
    if _curLevel < self.Cfg.OpenLevel then
        return ActivityState.UnreachedLevel
    end
    -- The minimum number of days of service opening has not been reached
    if not self:IsToMinOpenDay() then
        return ActivityState.UnreachedOpenDay
    end
    -- Function is enabled
    if self.Open and self.IsOpen then
        if self.RemindCount == 0 then
            if self.CanBuyCount > 0 then
                return ActivityState.CompleteCanBuy
            end
            -- Completed
            return ActivityState.CompleteNoBuyCount
        end
        return ActivityState.CanJoin
    end

    -- Not satisfied with the number of special service opening days
    if Time.GetOpenSeverDay() < self.Cfg.SpecialOpen then
        return ActivityState.NotInSpecialDay
    end

    return  ActivityState.Unopen
end

return DailyActivityData