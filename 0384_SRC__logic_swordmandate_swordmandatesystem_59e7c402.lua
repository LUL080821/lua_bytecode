
------------------------------------------------
-- Author: 
-- Date: 2021-03-02
-- File: SwordMandateSystem.lua
-- Module: SwordMandateSystem
-- Description: Jianlingge hang-up system
------------------------------------------------

local L_RedPointCustomCondition = CS.Thousandto.Code.Logic.RedPointCustomCondition
local L_RedPointFightPowerCondition = CS.Thousandto.Code.Logic.RedPointFightPowerCondition
local L_ShowRedPointTime = 60 * 60

local SwordMandateSystem = {
    -- Time to synchronize data
    SyncTime = 0,
    -- The current total time of hang-up
    CurAllTime = 0,
    -- Whether to display red dots
    ShowRedPoint = false,
    -- Current number of layers
    CurLevel = 0,
    -- The number of layers when entering the copy
    EnterCopyLevel = 0,
    -- Current configuration
    CurCfg = nil,
    -- Maximum hang-up time configured
    MaxTime = 0,
    -- The configured single reward time, unit is minutes
    SingleAwardTime  = 0,
    -- Number of single fast rewards
    QuickGetAwardCount = 0,
    -- Fast profit time for a single time
    QuickGetTime = 0,
    -- Quick return remaining times
    QuickGetRemainCount = 0,
    -- Maximum number of fast returns
    QuickGetMaxCount  = 0,
    -- Fast earnings price data
    QuickGetPrices = nil,

    -- Cache jump data
    CacheTiaoGuanData = nil,
}

-- The current total hang-up time, the client will increase automatically
function SwordMandateSystem:GetCurAllTime()
    local _allTime = Time.GetRealtimeSinceStartup() - self.SyncTime + self.CurAllTime
    if _allTime > self.MaxTime then
        _allTime = self.MaxTime
    end
    return _allTime
end
-- Set whether to display hongd
function SwordMandateSystem:SetShowRedPoint(value)
    if self.ShowRedPoint == value then
        return
    end
    self.ShowRedPoint = value
    if self.ShowRedPoint then
        GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.FlySwordMandate, 1, L_RedPointCustomCondition(true))
    else
        GameCenter.RedPointSystem:RemoveFuncCondition(FunctionStartIdCode.FlySwordMandate, 1)
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVEMT_UPDATE_SWORDMANDATE)
end
-- Is the time full
function SwordMandateSystem:IsFullTime()
    return self.CurAllTime >= self.MaxTime
end

-- initialization
function SwordMandateSystem:Initialize()
    local _gCfg = DataConfig.DataGlobal[GlobalName.Sword_Soul_MaxMandateTime]
    if _gCfg ~= nil then
        self.MaxTime = tonumber(_gCfg.Params)
    end
    _gCfg = DataConfig.DataGlobal[GlobalName.Sword_Soul_SingleRewordTime]
    if _gCfg ~= nil then
        self.SingleAwardTime = tonumber(_gCfg.Params) / 60
    end
    _gCfg = DataConfig.DataGlobal[GlobalName.Sword_Soul_quicktimes]
    if _gCfg ~= nil then
        self.QuickGetAwardCount = tonumber(_gCfg.Params)
        self.QuickGetTime = self.QuickGetAwardCount * self.SingleAwardTime * 60
    end
    -- Calculate the fast purchase price
    local _vipPowerCfg = DataConfig.DataVipPower[36]
    if _vipPowerCfg ~= nil then
        self.QuickGetPrices = Utils.SplitNumber(_vipPowerCfg.VipPowerPrice, '_')
    end
    self.EnterCopyLevel = nil
end
-- uninstall
function SwordMandateSystem:UnInitialize()
end
-- renew
function SwordMandateSystem:Update(dt)
    if self.SyncTime <= 0 then
        return
    end
    if Time.GetFrameCount() % 30 == 0 then
        self:SetShowRedPoint(self.CurAllTime >= L_ShowRedPointTime)
    end
end

-- Setting up data
function SwordMandateSystem:ResSwordSoulPannel(msg)
    self.CurLevel = msg.layer
    if self.EnterCopyLevel == nil then
        self.EnterCopyLevel = self.CurLevel
    end
    self.CurCfg = DataConfig.DataSwordSoulCopy[msg.layer]
    self.CurAllTime = msg.hookTime
    self.SyncTime = Time.GetRealtimeSinceStartup()
    self.QuickGetRemainCount = msg.remainCount
    self.QuickGetMaxCount = msg.maxCount
    GameCenter.RedPointSystem:RemoveFuncCondition(FunctionStartIdCode.FlySwordMandate, 2)
    GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.FlySwordMandate, 2, L_RedPointFightPowerCondition(self.CurCfg.NeedFightPower))
    if self.ShowRedPoint ~= (self.CurAllTime >= L_ShowRedPointTime) then
        self:SetShowRedPoint(self.CurAllTime >= L_ShowRedPointTime)
    else
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVEMT_UPDATE_SWORDMANDATE)
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_JLG_DATA_RESULT)
end

-- Fast profit return
function SwordMandateSystem:ResQuickEarn(msg)
    self.QuickGetRemainCount = msg.remainCount
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVEMT_QUICL_SWORDMANDATE_RESULT, msg)
end

-- Enter the Sword Spirit Pavilion dungeon
function SwordMandateSystem:OnEnterSoulCopy()
    self.EnterCopyLevel = self.CurLevel
end

-- Open the Sword Ling Pavilion interface
function SwordMandateSystem:OnOpenSwordForm()
    self.EnterCopyLevel = self.CurLevel
end

-- Quickly clear the return
function SwordMandateSystem:ResSkipSoulCopyResult(msg)
    local _oldLevel = self.CurLevel
    self.CurLevel = msg.layer
    self.CurCfg = DataConfig.DataSwordSoulCopy[msg.layer]
    GameCenter.RedPointSystem:RemoveFuncCondition(FunctionStartIdCode.FlySwordMandate, 2)
    GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.FlySwordMandate, 2, L_RedPointFightPowerCondition(self.CurCfg.NeedFightPower))
    if self.ShowRedPoint ~= (self.CurAllTime >= L_ShowRedPointTime) then
        self:SetShowRedPoint(self.CurAllTime >= L_ShowRedPointTime)
    else
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVEMT_UPDATE_SWORDMANDATE)
    end
    self.CacheTiaoGuanData = {_oldLevel, msg}
    -- Quickly clear the return
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_JLG_TIAOGUAN_RESULT)
end

return SwordMandateSystem