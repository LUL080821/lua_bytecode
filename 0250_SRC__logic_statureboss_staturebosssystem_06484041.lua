------------------------------------------------
-- Author: 
-- Date: 2019-08-21
-- File: StatureBossSystem.lua
-- Module: StatureBossSystem
-- Description: Realm BOSS
------------------------------------------------

local StatureBossSystem = {
    BossInfoDic = Dictionary:New(),      -- BOSS information dictionary, key = configuration table id, value = {BossCfg, IsFirstCross, IsKilled}
    CurSelectMonsterID = 0,              -- The currently selected BOSS
    CurMaxLayer = 0,                     -- The largest level of challenge now
    CurCount = 0,                        -- Current access times
    BoughtCount = 0,                     -- Number of times purchased
}

function StatureBossSystem:Initialize()
    self.IsGuide = 0
    self.PlayerLvChangeEvent = Utils.Handler(self.OnLvChange, self)
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_PLAYER_LEVEL_CHANGED, self.PlayerLvChangeEvent)
end


function StatureBossSystem:UnInitialize()
    self.BossInfoDic:Clear()
    self.CurSelectMonsterID = 0
    GameCenter.UnRegFixEventHandle(LogicLuaEventDefine.EID_EVENT_REALM_LEVELUP, self.PlayerLvChangeEvent)
end

function StatureBossSystem:InitBossInfo()
    -- Initialize Boss
    self.IsInitCfg = true
    DataConfig.DataBossstate:Foreach(function(k, v)
        if not self.BossInfoDic:ContainsKey(k) then
            local _bossInfo = {BossCfg = v, IsShow = false, FirstCrossed = false, Killed = false, Layer = k}
            self.BossInfoDic:Add(k, _bossInfo)
        end
    end)
    self.BossInfoDic:SortKey(function(a, b) return a < b end)
end

function StatureBossSystem:GetBossInfoDic()
    if not self.IsInitCfg then
        self:InitBossInfo()
    end
    return self.BossInfoDic
end

function StatureBossSystem:IsRedPoint()
    local _isRed = false
    if not self.IsInitCfg then
        self:InitBossInfo()
    end
    self.BossInfoDic:ForeachCanBreak(function(k, v)
        if v.Type ~= StatureBossState.UnActive and v.IsShow then
            if (not v.IsFirst and v.Type ~= StatureBossState.WaitOpen) or (v.IsFirst and not v.IsFirstGet)
                or (v.Type == StatureBossState.Alive and self.CurCount > 0) then
                _isRed = true
                return true
            end
        end
    end)
    return _isRed or self:CanBuyCount()
end

function StatureBossSystem:CanBuyCount()
    local _copyVipCfgId  = 20
    local _vipPowerCfg = DataConfig.DataVipPower[_copyVipCfgId]
    if _vipPowerCfg == nil then
        -- mistake
        return false
    end
    local _prices = Utils.SplitNumber(_vipPowerCfg.VipPowerPrice, '_')
    if _prices == nil or #_prices <= 0 then
        -- mistake
        return
    end
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        -- mistake
        return
    end
    local _curLevel = _lp.VipLevel
    if _curLevel < 0 then
        _curLevel = 0
    end
    local _curVipCfg = DataConfig.DataVip[_curLevel]

    local _curLevelCanBuy = 0
    if _curVipCfg ~= nil then
        local _cfgTable = Utils.SplitStrByTableS(_curVipCfg.VipPowerPra, {';', '_'})
        for i = 1, #_cfgTable do
            if _cfgTable[i][1] == _copyVipCfgId then
                _curLevelCanBuy = _cfgTable[i][3]
                break
            end
        end
    end

    if _curVipCfg == nil then
        return false
    end
    return _curLevelCanBuy > self.BoughtCount
end

-- Listen to change the level, reset the status
function StatureBossSystem:OnLvChange(lv, sender)
    if not self.IsInitCfg then
        self:InitBossInfo()
    end
    self.BossInfoDic:Foreach(function(k, v)
        self:SetBossState(v, lv)
    end)
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.StatureBoss, self:IsRedPoint())
end

-- Set the BOSS status
function StatureBossSystem:SetBossState(_bossInfo, lv)
    if _bossInfo then
        local _condition = Utils.SplitNumber(_bossInfo.BossCfg.StateLevel, "_")
        local _cfgLv = _condition[2]
        local _playerLevel = 1
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if _lp ~= nil then
            _playerLevel = _lp.Level
        elseif lv ~= nil then
            _playerLevel = lv
        end
        if _cfgLv <= _playerLevel then
            if _bossInfo.Layer <= self.CurMaxLayer then
                _bossInfo.Type = StatureBossState.Alive
            else
                _bossInfo.Type = StatureBossState.WaitOpen
            end
        else
            _bossInfo.Type = StatureBossState.UnActive
        end
    end
end

-- Open the Realm BOSS interface and the server issues all BOSS information
function StatureBossSystem:ResOpenBossStatePanle(result)
    self.CurMaxLayer = result.maxLayer
    self.CurCount = result.count
    if result.boughtCount then
        self.BoughtCount = result.boughtCount
    end
    if not self.IsInitCfg then
        self:InitBossInfo()
    end
    if result.bossList then
        for i = 1, #result.bossList do
            if self.BossInfoDic:ContainsKey(result.bossList[i].layer) then
                local _bossInfo = self.BossInfoDic[result.bossList[i].layer]
                -- _bossInfo.Killed = not result.bossList[i].live
                -- _bossInfo.FirstCrossed = not result.bossList[i].first
                _bossInfo.Layer = result.bossList[i].layer
                _bossInfo.IsShow = true
                if result.bossList[i].first ~= nil then
                    _bossInfo.IsFirst = result.bossList[i].first
                    if result.bossList[i].first and _bossInfo.BossCfg.ShowBoss == 0 then
                        _bossInfo.IsShow = false
                    end
                else
                    _bossInfo.IsFirst = false
                end
                if result.bossList[i].isGetReward ~= nil then
                    _bossInfo.IsFirstGet = result.bossList[i].isGetReward
                else
                    _bossInfo.IsFirstGet = true
                end
                self:SetBossState(_bossInfo)
            end
        end
    end
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.StatureBoss, self:IsRedPoint())
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UIPDATESTATUREBOSSDATA, true)
end

-- Update BOSS information
function StatureBossSystem:ResupdateBossState(result)
    self.CurMaxLayer = result.maxLayer
    if not self.IsInitCfg then
        self:InitBossInfo()
    end
    if result.bossList then
        if self.BossInfoDic:ContainsKey(result.bossList.layer) then
            local _bossInfo = self.BossInfoDic[result.bossList.layer]
            _bossInfo.IsShow = true
            if result.bossList.first ~= nil then
                _bossInfo.IsFirst = result.bossList.first
                if result.bossList.first and _bossInfo.BossCfg.ShowBoss == 0 then
                    _bossInfo.IsShow = false
                end
            else
                _bossInfo.IsFirst = false
            end
            if result.bossList.isGetReward ~= nil then
                _bossInfo.IsFirstGet = result.bossList.isGetReward
            else
                _bossInfo.IsFirstGet = true
            end
            _bossInfo.Layer = result.bossList.layer
            self:SetBossState(_bossInfo)
        end
    end
    self:OnLvChange()
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.StatureBoss, self:IsRedPoint())
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UIPDATESTATUREBOSSDATA, false)
end

-- After killing the BOSS, open the checkout panel
function StatureBossSystem:ResBossStateResultPanl(result)
    GameCenter.PushFixEvent(UIEventDefine.UIStatureBossCopyResultForm_OPEN, result)
end

-- The server returns the number of access times
function StatureBossSystem:ResBuyBossStateCount(result)
    if result then
        self.CurCount = result.count
    end
    -- Request data, the number of purchases was sent when the interface was opened
    local _msg = ReqMsg.MSG_copyMap.ReqOpenBossStatePanle:New()
    _msg:Send()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_ADDSTATUREBOSSCOUNT)
end
return StatureBossSystem