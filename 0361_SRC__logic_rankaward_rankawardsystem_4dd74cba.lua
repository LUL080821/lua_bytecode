------------------------------------------------
-- Author:
-- Date: 2020-12-09
-- File: RankAwardSystem.lua
-- Module: RankAwardSystem
-- Description: Ranking Reward System
------------------------------------------------
local TimeUtils = CS.Thousandto.Core.Base.TimeUtils

local RankAwardSystem = {
    TimerID = nil,
    ServerOpenTime = 0,
    ShowIconList = nil,
    BindFuncList = nil,
    TimeTable = nil,
    RedPointTable = nil,
}

function RankAwardSystem:Initialize()
    self.ShowIconList = List:New()
    self.BindFuncList = List:New()
    self.RedPointTable = {}
    self.TimeTable = {}
    local _func = function(_, value)
        if value.LinkFuncId > 0 then
            self.BindFuncList:Add(value.LinkFuncId)
        end
    end
    DataConfig.DataRankAwardType:Foreach(_func)
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_FUNCTION_UPDATE, self.OnFuncUpdated, self)
end

function RankAwardSystem:UnInitialize()
    if self.TimerID ~= nil then
        GameCenter.TimerEventSystem:RemoveTimerEvent(self.TimerID)
    end
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_FUNCTION_UPDATE, self.OnFuncUpdated, self)
end

function RankAwardSystem:OnEnterScene()
    -- Check the displayed list when switching scenes
    self:CheckShowList()
end

function RankAwardSystem:OnFuncUpdated(funcInfo, sender)
    local _funcId = funcInfo.ID
    if _funcId == FunctionStartIdCode.Rank then
        self:CheckShowList()
    elseif _funcId == FunctionStartIdCode.RankAward then
        self:CheckShowList()
    elseif self.BindFuncList:Contains(_funcId) then
        self:CheckShowList()
    end
end

-- Set the server opening time
function RankAwardSystem:SetOpenServerTime(time)
    self.ServerOpenTime = math.floor(time / 1000) + GameCenter.HeartSystem.ServerZoneOffset
    if self.TimerID ~= nil then
        GameCenter.TimerEventSystem:RemoveTimerEvent(self.TimerID)
    end
    -- Perform at 1 second every morning
    self.TimerID = GameCenter.TimerEventSystem:AddTimeStampDayEvent(1, 86400,
    true, nil, function(id, remainTime, param)
        self:CheckShowList()
    end)
end

-- Detecting the icon
function RankAwardSystem:CheckShowList()
    for i = 1, #self.ShowIconList do
        GameCenter.MainCustomBtnSystem:RemoveBtn(self.ShowIconList[i][2])
    end
    self.ShowIconList:Clear()
    if not GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.Rank) then
        return
    end
    if not GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.RankAward) then
        return
    end
    self.TimeTable = {}
    -- Current service days
    local _serverTime = math.floor(GameCenter.HeartSystem.ServerZoneTime)
    -- Get the current number of seconds
    local _h, _m, _s = TimeUtils.GetStampTimeHHMMSSNotZone(_serverTime)
    local _curSec = _h * 3600 + _m * 60 + _s

    local _openServerDay = TimeUtils.GetDayOffsetNotZone(self.ServerOpenTime, _serverTime) + 1
    local _func = function(key, value)
        if _openServerDay >= value.StartDay and _openServerDay <= value.EndDay and
            (value.LinkFuncId <= 0 or GameCenter.MainFunctionSystem:FunctionIsVisible(value.LinkFuncId)) then
            local _remainDayCount = value.EndDay - _openServerDay
            local _remainTime = 86400 - _curSec + _remainDayCount * 86400
            self.TimeTable[key] = {SyncTime = Time.GetRealtimeSinceStartup(), RemainTime = _remainTime}
            local _showRedPoint = self.RedPointTable[key]
            if _showRedPoint == nil then
                _showRedPoint = false
            end
            local _iconId = GameCenter.MainCustomBtnSystem:AddLimitBtn(value.Icon, value.Name, _remainTime, key,
                function(data)
                    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.RankAward, data.CustomData)
                end,
            false, _showRedPoint, nil, true)
            self.ShowIconList:Add({key, _iconId})
        end
    end
    DataConfig.DataRankAwardType:Foreach(_func)
end

function RankAwardSystem:SetRedPoint(typeId, showRedpoint)
    for i = 1, #self.ShowIconList do
        if typeId == self.ShowIconList[i][1] then
            GameCenter.MainCustomBtnSystem:SetShowRedPoint(self.ShowIconList[i][2], showRedpoint)
            break
        end
    end
    self.RedPointTable[typeId] = showRedpoint
end

return RankAwardSystem