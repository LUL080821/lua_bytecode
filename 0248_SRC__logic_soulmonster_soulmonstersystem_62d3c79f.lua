------------------------------------------------
-- Author: 
-- Date: 2019-08-19
-- File: SoulMonsterSystem.lua
-- Module: SoulMonsterSystem
-- Description: The Island of the Divine Beast
------------------------------------------------
local L_SoulMonsterInfo = require "Logic.SoulMonster.SoulMonsterInfo"

local SoulMonsterSystem = {
    SoulMonsterBossInfoDic = Dictionary:New(),    -- Soul Beast Forest BOSS Information Dictionary, key = configuration table id, value = {BossCfg, RefreshTime, IsFollow}
    SoulMonsterLayerBossIDDic = Dictionary:New(), -- Dictionary of Soul Beast Forest Layers and BossID, key = Number of Layers, value = List<bossID>
    CrossLayerBossIDDic = Dictionary:New(),
    SoulMonsterStartCountDown = false,            -- The countdown to refresh the soul beast forest begins
    SoulMonsterRankRewardCount = 0,               -- Soul Beast Forest Ranking Rewards used times
    SoulMonsterRankRewardMaxCount = 5,            -- Soul Beast Forest Ranking Maximum Rewards
    CrystalHaveNum = 0,                           -- The remaining number of times the Beast God Crystal
    CrystalBloodHaveNum = 0,                      -- The remaining number of times the beast blood crystal
    CurSelectSoulMonsterID = 0,                   -- The currently selected BOSS
    CrystalID = 0,                                -- Beast God Crystal ID
    CrystalBloodID = 0,                           -- Beast Blood Crystal ID
    TimerEventId = 0,
    SoulMonsterCfgJoinMaxCount = 0,               -- Soul Beast Forest Configure the number of participations Times with daily table id=14

}

function SoulMonsterSystem:Initialize()
    self.mapPlayerNum = 0
    -- Why is the first value executed (seconds), and the second value is the validity time of verification (for example, it can be executed within 1 second by 5 o'clock)
    self.TimerEventId = GameCenter.TimerEventSystem:AddTimeStampDayEvent(5 * 60 * 60, 1,
    true, nil, function(id, remainTime, param)
		self:ReqSoulAnimalForestCrossPanel()
    end)
end


function SoulMonsterSystem:UnInitialize()
    self.IsInitCfg = false
    self.SoulMonsterBossInfoDic:Clear()
    self.SoulMonsterLayerBossIDDic:Clear()
    self.CrossLayerBossIDDic:Clear()
    self.CurSelectSoulMonsterID = 0
    self.SoulMonsterRankRewardCount = 5
    self.SoulMonsterRankRewardMaxCount = 5
    self.CrystalHaveNum = 0
    self.CrystalBloodHaveNum = 0
    if self.TimerEventId > 0 then
        GameCenter.TimerEventSystem:RemoveTimerEvent(self.TimerEventId)
    end
end

function SoulMonsterSystem:CrystalIsMax(id)
    local _mapConfig = GameCenter.GameSceneSystem:GetActivedMapSetting()
    if _mapConfig then
        if _mapConfig.MapLogicType == MapLogicTypeDefine.MonsterLand then
            if id == self.CrystalID then
                return self.CrystalHaveNum > 0
            elseif id == self.CrystalBloodID then
                return self.CrystalBloodHaveNum > 0
            end
        end
    end
    return true
end

function SoulMonsterSystem:InitBossInfo()
    -- local _countStr = DataConfig.DataGlobal[1517]
    -- if _countStr then
    --     local _countList = Utils.SplitStrByTableS(_countStr.Params)
    --     self.WorldBossRankRewardMaxCount = tonumber(_countList[1][3])
    --     self.WorldBossEnterRewardMaxCount = tonumber(_countList[1][4])
    -- end
    if self.IsInitCfg then
        return
    end
    self.IsInitCfg = true
    local _dailyCfg = DataConfig.DataDaily[14];
    self.SoulMonsterCfgJoinMaxCount = _dailyCfg and _dailyCfg.Times or 0;
    -- Initialized Soul Beast Forest Dictionary
    DataConfig.DataBossnewSoulBeasts:Foreach(function(k, v)
        if v.CanShow == 1 then
            if v.CrossSever == 1 then
                if not self.CrossLayerBossIDDic:ContainsKey(v.Layer) then
                    local _bossIDList = List:New()
                    _bossIDList:Add(k)
                    self.CrossLayerBossIDDic:Add(v.Layer, _bossIDList)
                else
                    local _bossIDList = self.CrossLayerBossIDDic[v.Layer]
                    if not _bossIDList:Contains(k) then
                        _bossIDList:Add(k)
                    end
                end
            else
                if not self.SoulMonsterLayerBossIDDic:ContainsKey(v.Layer) then
                    local _bossIDList = List:New()
                    _bossIDList:Add(k)
                    self.SoulMonsterLayerBossIDDic:Add(v.Layer, _bossIDList)
                else
                    local _bossIDList = self.SoulMonsterLayerBossIDDic[v.Layer]
                    if not _bossIDList:Contains(k) then
                        _bossIDList:Add(k)
                    end
                end
            end
            if not self.SoulMonsterBossInfoDic:ContainsKey(k) then
                local _bossInfo = L_SoulMonsterInfo:New(v)
                self.SoulMonsterBossInfoDic:Add(k, _bossInfo)
            end
            if v.Type == SoulMonsterItemType.GodCrystal then
                self.CrystalID = v.Monsterid
            elseif v.Type == SoulMonsterItemType.BloodCrystal then
                self.CrystalBloodID = v.Monsterid
            end
        end
    end)
    self.SoulMonsterLayerBossIDDic:SortKey(function(a, b) return a < b end)
    self.SoulMonsterLayerBossIDDic:Foreach(function(k, v)
        v:Sort(function(a, b) return a < b end)
        -- local _last = v[v:Count()]
        -- v:Insert(_last, 1)
        -- v:RemoveAt(v:Count())
    end)
    self.CrossLayerBossIDDic:SortKey(function(a, b) return a < b end)
    self.CrossLayerBossIDDic:Foreach(function(k, v)
        v:Sort(function(a, b) return a < b end)
        -- local _last = v[v:Count()]
        -- v:Insert(_last, 1)
        -- v:RemoveAt(v:Count())
    end)
end

-- Request all BOSS information
function SoulMonsterSystem:ReqSoulAnimalForestLocalPanel()
    local _req = ReqMsg.MSG_SoulAnimalForest.ReqSoulAnimalForestLocalPanel:New()
    _req.level = 0
    _req:Send()
end
function SoulMonsterSystem:ReqSoulAnimalForestCrossPanel(layer)
    local _req = ReqMsg.MSG_SoulAnimalForest.ReqSoulAnimalForestCrossPanel:New()
    if layer then
        _req.level = layer
    else
        _req.level = 0
    end
    _req:Send()
end

-- Return of the interface of the local soul beast forest
function SoulMonsterSystem:ResSoulAnimalForestLocalPanel(result)
    self:InitBossInfo()
    if result then
        local _bossList = result.bossList
        if _bossList then
            for i=1, #_bossList do
                local _bossInfo = self.SoulMonsterBossInfoDic[_bossList[i].bossId]
                if _bossInfo ~= nil then
                    _bossInfo:Refresh(_bossList[i])
                end
            end
        end
        self.SoulMonsterRankRewardCount = result.remainCount
        self.SoulMonsterRankRewardMaxCount = result.maxCount
        self.CrystalBloodHaveNum = result.crystalBloodHaveNum
        self.CrystalHaveNum = result.crystalHaveNum
        self.SoulMonsterStartCountDown = true
        if result.mapPlayerNum then
            self.mapPlayerNum = result.mapPlayerNum
        else
            self.mapPlayerNum = 0
        end
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.GodIsland, self.SoulMonsterRankRewardCount > 0)
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_HUNSHOUSENLIN_UPDATE)
    end
end

-- Request BOSS kill information
function SoulMonsterSystem:ReqBossKilledInfo(bossID)
    GameCenter.Network.Send("MSG_SoulAnimalForest.ReqCrossSoulAnimalForestBossKiller", {bossConfigId = bossID})
end

function SoulMonsterSystem:ResBossKilledInfo(result)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_HUNSHOU_SHOWKILLINFO, result)
end

-- Request attention to the boss. Follow = Request method, true: follow, false: unfollow
function SoulMonsterSystem:ReqFollowBoss(bossID, isFollow)
    local _followType = isFollow
    GameCenter.Network.Send("MSG_SoulAnimalForest.ReqFollowSoulAnimalForestCrossBoss", {bossId = bossID, followValue = _followType})
end

function SoulMonsterSystem:ResFollowBoss(result)
    if result then
        self:InitBossInfo()
        local _bossInfo = self.SoulMonsterBossInfoDic[result.bossId]
        if _bossInfo ~= nil then
            _bossInfo.IsFollow = result.followValue
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_HUNSHOU_GUANZHUREFREASH)
            if result.state == 0 and result.followValue then
                Utils.ShowPromptByEnum("AttentionSucceed")
            end
        end
    end
end

-- BOSS information refresh
function SoulMonsterSystem:ResSoulAnimalForestLocalRefreshInfo(result)
    if result and result.bossRefreshList then
        self:InitBossInfo()
        local _newBossInfoList = result.bossRefreshList
        for i=1, #_newBossInfoList do
            local _bossInfo = self.SoulMonsterBossInfoDic[_newBossInfoList[i].bossId]
            if _bossInfo ~= nil then
                _bossInfo:Refresh(_newBossInfoList[i])
            end
        end
        self.SoulMonsterStartCountDown = true
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_HUNSHOUSENLIN_UPDATE)
end

-- The boss you follow is one minute in advance to refresh the message
function SoulMonsterSystem:ResSoulAnimalForestLocalBossRefreshTip(result)
    self:InitBossInfo()
    -- Soul Beast Forest prompts in advance, result.bossId is the Soul Beast Forest configuration table id
    local _bossCfg = self.SoulMonsterBossInfoDic[result.bossId]
    if _bossCfg then
        GameCenter.PushFixEvent(UIEventDefine.UIBossInfoTips_OPEN, {_bossCfg.BossCfg.Monsterid, _bossCfg.BossCfg.Cloneid, result.bossId, BossType.SoulMonster})
    end
end

-- Synchronous damage ranking information
function SoulMonsterSystem:ResSynHarmRank(result)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_NEWWORLDBOSS_HARMRANKREFRESH, result)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_BOSSHOME_HARMRANKREFRESH, result)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_HUNSHOU_HURTRANKINFO, result)
end

return SoulMonsterSystem
