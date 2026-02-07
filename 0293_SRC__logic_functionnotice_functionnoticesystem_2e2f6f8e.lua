------------------------------------------------
-- Author: 
-- Date: 2020-05-12
-- File: FunctionNoticeSystem.lua
-- Module: FunctionNoticeSystem
-- Description: Functional preview system
------------------------------------------------
local TimeUtils = CS.Thousandto.Core.Base.TimeUtils;

local FunctionNoticeSystem = {
    TimerEventID = 0,
    CloseDayCount = nil,
    ServerOpenTime = nil,
    CurNoticeCfg = nil,
    CurNoticeRemianTime = 0,
    IsUpdateData = false,

    FrontLevel = nil,
}

-- initialization
function FunctionNoticeSystem:Initialize()
    local _gCfg = DataConfig.DataGlobal[GlobalName.Function_Notice_Open_Time]
    if _gCfg ~= nil then
        self.CloseDayCount = tonumber(_gCfg.Params)
    else
        self.CloseDayCount = 0
    end
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_TASKFINISH, self.OnTaskChanged, self);
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_PLAYER_LEVEL_CHANGED, self.OnLevelChanged, self);
end

-- De-initialization
function FunctionNoticeSystem:UnInitialize()
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_TASKFINISH, self.OnTaskChanged, self);
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_PLAYER_LEVEL_CHANGED, self.OnLevelChanged, self);
end

-- Level changes
function FunctionNoticeSystem:OnLevelChanged(level, sender)
    self.IsUpdateData = true
    local _frontLevel = self.FrontLevel
    self.FrontLevel = level
    if _frontLevel ~= nil and not CommonUtils.IsDFLevel(_frontLevel) and CommonUtils.IsDFLevel(level) then
        -- Open the upgrade level prompt interface
        GameCenter.PushFixEvent(UILuaEventDefine.UIFeiShengBoxForm_OPEN)
    end
end

-- Task changes
function FunctionNoticeSystem:OnTaskChanged(obj, sender)
    self.IsUpdateData = true
end

-- renew
function FunctionNoticeSystem:Update(dt)
    if self.IsUpdateData then
        self:UpdateData()
        self.IsUpdateData = false
    end

    local _curCfg = self.CurNoticeCfg
    if _curCfg ~= nil and self.CurNoticeRemianTime > 0 then
        self.CurNoticeRemianTime = self.CurNoticeRemianTime - dt
        if self.CurNoticeRemianTime <= 0 then
            self.IsUpdateData = true
        end
    end
end

-- Update data
function FunctionNoticeSystem:UpdateData()
    local _curMM = nil
    local _curAllSS = nil
    local _isOpen = false
    if self.ServerOpenTime ~= nil then
        local _serverTime = GameCenter.HeartSystem.ServerTime + GameCenter.HeartSystem.ServerZoneOffset
        local _openServerTime = self.ServerOpenTime + GameCenter.HeartSystem.ServerZoneOffset
        local _offsetDay = TimeUtils.GetDayOffsetNotZone(math.floor(_openServerTime), math.floor(_serverTime))
        local hour = TimeUtils.GetStampTimeHHNotZone(math.floor(_serverTime))
        local min = TimeUtils.GetStampTimeMMNotZone(math.floor(_serverTime))
        local ss = TimeUtils.GetStampTimeSSNotZone(math.floor(_serverTime))
        _curMM = _offsetDay * 1440 + hour * 60 + min
        _isOpen = _offsetDay < self.CloseDayCount
        _curAllSS = _curMM * 60 + ss
    end

    local _noticeCfg = nil
    self.CurNoticeRemianTime = 0
    if _isOpen then
        local _curLevel = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
        local _func = function(key, value)
            if _noticeCfg == nil then
                if value.OpenCondition == 0 then    -- grade
                    if _curLevel < value.OpenParam then
                        _noticeCfg = value
                    end
                elseif value.OpenCondition == 1 then -- Complete the task
                    if not GameCenter.LuaTaskManager:IsMainTaskOver(value.OpenParam) then
                        _noticeCfg = value
                    end
                elseif value.OpenCondition == 2 then -- Service opening time
                    if _curMM ~= nil and _curMM < value.OpenParam then
                        _noticeCfg = value
                        self.CurNoticeRemianTime = value.OpenParam * 60 - _curAllSS
                    end
                end
            end
            return false
        end
        DataConfig.DataFunctionNotice:ForeachCanBreak(_func)
    end
    self.CurNoticeCfg = _noticeCfg
    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.FunctionNotice, _noticeCfg ~= nil)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATEFUNCNOTICE_INFO)
end

function FunctionNoticeSystem:SetServerOpenTime(time)
    self.ServerOpenTime = math.floor(time / 1000)
    self.IsUpdateData = true
end

return FunctionNoticeSystem