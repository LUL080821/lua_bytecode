
------------------------------------------------
-- Author:
-- Date: 2019-04-16
-- File: OfflineOnHookSystem.lua
-- Module: OfflineOnHookSystem
-- Description: Offline hang-up system
------------------------------------------------
local RedPointCustomCondition = CS.Thousandto.Code.Logic.RedPointCustomCondition

local OfflineOnHookSystem = {
    AddExpItemID = {1003, 1002, 1001},
    GoToShopItemID = 1002,
    AddOnHookTimeItemID = {1031, 1004},
    RemainOnHookTime = 0,   -- Accurate to seconds
    OfflineHookResult = {},
    CurWorldLevel = 0,  -- Current world level
    ExpAddRateDic = Dictionary:New(),        -- Experience bonus dictionary, key = type, value = bonus value

    -- Remaining time for medicine
    ItemRemainTime = 0,
    -- The time of drug synchronization, used to calculate the remaining time
    ItemSyncTime = 0,

    TimerEventID = 0,

    -- Retrievable time
    CanFindTime = 0,
    -- Retrievable experience points
    CanFindExpValue = 0,
}
function OfflineOnHookSystem:Initialize()
    self.TimerEventID = GameCenter.TimerEventSystem:AddTimeStampHourEvent(10, 1,
    true, nil, function(id, remainTime, param)
        self:ReqHookSetInfo()
    end)
end

function OfflineOnHookSystem:UnInitialize()
    GameCenter.TimerEventSystem:RemoveTimerEvent(self.TimerEventID)
end

function OfflineOnHookSystem:ReqHookSetInfo()
    GameCenter.Network.Send("MSG_Hook.ReqHookSetInfo", {})
end

function OfflineOnHookSystem:GS2U_ResHookSetInfo(result)
    self.RemainOnHookTime = result.hookRemainTime
    self.CurWorldLevel = result.worldlevel
    self.ExpAddRateDic = Dictionary:New()
    for i=1,#result.expAddRateList do
        local _type = result.expAddRateList[i].type
        local _rate = result.expAddRateList[i].rate
        local _cfg = DataConfig.DataOnHookC[_type]
        if _cfg ~= nil then
            self.ExpAddRateDic:Add(_type, _rate)
        end
    end
    self.ItemRemainTime = result.curExpItemRamineTime
    self.ItemSyncTime = Time.GetRealtimeSinceStartup()
    --self.ExpAddRateList = List:New(result.expAddRateList)
    self:CheckTimeRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_HOOKSITTING, result)
end

function OfflineOnHookSystem:GS2U_ResOfflineHookResult(result)
    self.RemainOnHookTime = result.hookRemainTime
    self.OfflineHookResult = result
    self:CheckTimeRedPoint()
    GameCenter.PushFixEvent(UIEventDefine.UIOnHookForm_OPEN)
end

-- Experience bonus changes
function OfflineOnHookSystem:GS2U_ResExpRateChange(result)
    if self.ExpAddRateDic == nil then
        self.ExpAddRateDic = Dictionary:New()
    end
    local _type = result.info.type
    local _rate = result.info.rate
    local _cfg = DataConfig.DataOnHookC[_type]
    if _cfg ~= nil then
        self.ExpAddRateDic[_type] = _rate
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_HOOKSITTING, result)
end

-- Returns an integer
function OfflineOnHookSystem:GetHourAndMinuteBySecond(second)
    local h = second / 3600
    second = second % 3600
    local m = second / 60
    -- Return integer
    return math.modf( h ), math.modf( m )
end

-- Get experience bonus, percentage, type = OnHookExpAddType
function OfflineOnHookSystem:GetMainFormShowExpRate(expAddType)
    local _retValue = 0
    self.ExpAddRateDic:Foreach(
        function(key, value)
            if key == expAddType then
                _retValue = _retValue + value
            end
        end
    )
    return _retValue
end

-- Get total experience bonus, percentage
function OfflineOnHookSystem:GetTotalExpAddRate()
    local _retValue = 0
    self.ExpAddRateDic:Foreach(
        function(key, value)
            if key == OnHookExpAddType.WorldLevel and GameCenter.VipSystem.CurRecharge <= 0 then
            else
                _retValue = _retValue + value
            end
        end
    )
    return _retValue
end

-- Get other experience bonuses, percentage
function OfflineOnHookSystem:GetOtherExpAddRate()
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return 0
    end
    local _result = (_lp.PropMoudle.KillMonsterExpPercent // 100) - self:GetTotalExpAddRate()
    if _result < 0 then
        _result = 0
    end
    return _result
end

-- Obtain current experience drug bonus ratio, percentage system
function OfflineOnHookSystem:GetCurItemAddRate()
    return self:GetMainFormShowExpRate(OnHookExpAddType.Drug)
end

-- Get the current world level
function OfflineOnHookSystem:GetCurWorldLevel()
    return self.CurWorldLevel
end

-- Get experience medicine remaining time
function OfflineOnHookSystem:GetItemExpRemainTime()
    local _time = self.ItemRemainTime - (Time.GetRealtimeSinceStartup() - self.ItemSyncTime)
    if _time < 0 then
        _time = 0
    end
    return _time
end

-- Detect red dots
function OfflineOnHookSystem:CheckTimeRedPoint()
    -- The remaining time is less than 5 and disappears. The red dots are displayed.
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.OnHookSettingForm)
    GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.OnHookSettingForm, 0, RedPointCustomCondition(self.RemainOnHookTime <= (5 * 60 * 60)))
end

-- Determine whether it is an offline experience prop
function OfflineOnHookSystem:IsOffLineTimeItem(itemId)
    for i = 1, #self.AddOnHookTimeItemID do
        if self.AddOnHookTimeItemID[i] == itemId then
            return true
        end
    end
    return false
end

-- Retrieve experience offline
function OfflineOnHookSystem:ResOfflineHookFindTime(msg)
    -- Retrievable time
    self.CanFindTime = msg.offlineTime
    -- Retrievable experience points
    self.CanFindExpValue = msg.exp
    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.OfflineFind, self.CanFindTime > 0 and self.CanFindExpValue > 0)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_OFFLINEFINDTIME)
end

return OfflineOnHookSystem