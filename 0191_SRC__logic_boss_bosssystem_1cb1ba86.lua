------------------------------------------------
-- Author: 
-- Date: 2019-05-10
-- File: BossSystem.lua
-- Module: BossSystem
-- Description: BOSS system
------------------------------------------------
local RedPointCustomCondition = CS.Thousandto.Code.Logic.RedPointCustomCondition
local RedPointItemCondition = CS.Thousandto.Code.Logic.RedPointItemCondition

local BossSystem = {
    BossPersonal = Dictionary:New(), -- The stored configuration table data K is Layer
    MySelfBossRefshTime = 0,  -- Remaining refresh time for personal boss

    WorldBossInfoDic = Dictionary:New(),        -- World BOSS information dictionary, key = configuration table id, value = {BossCfg, RefreshTime, IsFollow}
    LayerBossIDDic = Dictionary:New(),          -- page is K->value is the number of layers and bossID dictionary, key = number of layers, value = List<bossID>
    WorldBossRankRewardMaxCount = 0,            -- The maximum number of rewards for world bosses is called to increase the use of props
    WorldBossReaminCount = 0,                   -- The remaining number of times the world boss earns
    CurSelectBossID = 0,                        -- The current selected world boss id
    CurWuxianBossId = 0,                        -- Current Unlimited BossId

    WuXianBossDict = Dictionary:New(),          -- Fake unlimited BOSS information, key = BossId, value = RefreshTime
    StartLeaveCountDown = false,                -- Whether to start the fake infinite boss leaving copy countdown
    LeaveReaminTime = 0,                        -- Fake Infinite BOSS Leaves the Remaining Time for the Copy
    Scourge = -1,                                -- The Heavenly Penalty Value of Sets and Gem Boss
    SuitGemBossType = -1,
    SuitBossCount = 0,
    SuitBossAllCount = 0,
    SuitBossAddCount = 0,                        -- Number of times the set of bosses has been purchased
    LeaveSuitCopyTime = 0,
    OlBossDict = Dictionary:New(),
    SuitGemOLDict = Dictionary:New(),
    WorldBossAddCount = 0,                      -- Number of times the world boss purchases
    -- Unlimited Boss Closed Time
    WuxianBossCloseTime = 0,
    -- The time when the infinite boss is about to be turned on
    WuxianBossOpenTime = 0,
    -- Timer ID
    TimerEventId = 0,

    NewBHReCount = 0, -- The number of times left of boss home
    NewBHMaxCount = 0, -- The maximum number of times the boss home
}

function BossSystem:Initialize()
    self:InitConfig()
    self:InitWorldBossInfo()
    -- Why is the first value executed (seconds), and the second value is the validity time of verification (for example, it can be executed within 1 second by 5 o'clock)
    self.TimerEventId = GameCenter.TimerEventSystem:AddTimeStampDayEvent(5 * 60 * 60, 1,
    true, nil, function(id, remainTime, param)
        -- Request data for the set of bosses
        local _msg = ReqMsg.MSG_Boss.ReqSuitGemBossPanel:New()
        -- 0 set of boss
        _msg.type = 0
        _msg:Send()
    end)
    local _bossHomeItemId = tonumber(DataConfig.DataGlobal[GlobalName.BossHome_Count_Item].Params)
    -- Boss House increases the number of times red dots
    GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.BossHome, 0, RedPointItemCondition(_bossHomeItemId, 1))
end

function BossSystem:UnInitialize()
    self.BossPersonal:Clear()
    self.CurSelectBossID = 0
    self.CurWuxianBossId = 0
    self.WorldBossInfoDic:Clear()
    self.LayerBossIDDic:Clear()
    if self.TimerEventId > 0 then
        GameCenter.TimerEventSystem:RemoveTimerEvent(self.TimerEventId)
    end
end

-- ######################################################
function BossSystem:InitWorldBossInfo()
    -- Initialize the world BOSS dictionary
    DataConfig.DataBossnewWorld:Foreach(function(k, v)
        local _mapnum = v.Mapnum
        if not self.LayerBossIDDic:ContainsKey(v.Page) then
            local _bossDic  = Dictionary:New()
            local _bossIDList = List:New()
            _bossIDList:Add(k)
            _bossDic:Add(_mapnum,_bossIDList)
            self.LayerBossIDDic:Add(v.Page, _bossDic)
        else
            if not self.LayerBossIDDic[v.Page]:ContainsKey(_mapnum) then
                local _bossIDList = List:New()
                _bossIDList:Add(k)
                self.LayerBossIDDic[v.Page]:Add(_mapnum, _bossIDList)
            else
                local _bossIDList = self.LayerBossIDDic[v.Page][_mapnum]
                if not _bossIDList:Contains(k) then
                    _bossIDList:Add(k)
                end
            end
        end
        if not self.WorldBossInfoDic:ContainsKey(k) then
            local _bossInfo = {BossCfg = v}
            self.WorldBossInfoDic:Add(k, _bossInfo)
        end
    end)
    self.LayerBossIDDic:Foreach(function(key, value)
        value:SortKey(function(a, b) return a < b end)
        value:Foreach(function(key1, value1)
            value1:Sort(function(a, b) return a < b end)
        end)
    end)
end

function BossSystem:RefreshBossInfo(msg)
    local _bossInfo = self.WorldBossInfoDic[msg.bossId]
    if _bossInfo ~= nil then
        _bossInfo.RefreshTime = msg.refreshTime
        _bossInfo.IsFollow = msg.isFollowed
        _bossInfo.SyncTime = Time.GetRealtimeSinceStartup()
    end
end

function BossSystem:GetRefreshTime(bossInfo)
    if bossInfo.RefreshTime == nil or bossInfo.SyncTime == nil then
        return 0
    end
    local _remienTime = bossInfo.RefreshTime - (Time.GetRealtimeSinceStartup() - bossInfo.SyncTime)
    if _remienTime < 0 then
        return 0
    end
    return _remienTime
end

-- When going up and down, check whether it is a wireless layer through the map ID
function BossSystem:GetWorldBossTypeByMapId(mapId)
    local _mapnum = 0
    self.LayerBossIDDic:ForeachCanBreak(        
        function(k, v)
            v:ForeachCanBreak(
                function(key,value)
                    for i=1,#value do
                        local _bossCfg = DataConfig.DataBossnewWorld[value[i]]
                        local _cloneMap = DataConfig.DataCloneMap[_bossCfg.CloneMap]
                        if _cloneMap.Mapid == mapId then
                            _mapnum = key
                            return true
                        end
                    end
                end
            )
            if _mapnum ~= 0 then
                return true
            end
        end
    )
    return _mapnum
end

function BossSystem:GetNewCompIsVisible(layer)
    local _dic = self.LayerBossIDDic[1]
    if layer and _dic and _dic:ContainsKey(layer) then
        if layer >= 0 then
            return true
        end
        local _idList = _dic[layer]
        for i = 1, #_idList do
            local _info = self.WorldBossInfoDic[_idList[i]]
            if _info and not _info.IsKilled then
                return true
            end
        end
    end
    return false
end

-- Enter the set BOSS and select the number of layers to enter according to the player level
function BossSystem:EnterSuitBossCopy()
    local _layerDic = GameCenter.BossSystem:GetLayerDirByPage(WorldBossPageEnum.SuitBoss)
    local _lpLevel = GameCenter.GameSceneSystem:GetLocalPlayer().Level
    local _maxLv = 0
    local _mapID = 0

    _layerDic:ForeachCanBreak(function(key, value)
        local _bossCfg = DataConfig.DataBossnewWorld[value[1]]
        local _mapCfg = DataConfig.DataCloneMap[_bossCfg.CloneMap]
        local _limtLevel = _mapCfg.MinLv
        if _limtLevel <= _lpLevel then
            if _limtLevel > _maxLv then
                _mapID = _bossCfg.CloneMap
                _maxLv = _limtLevel
            end
        else
            return true
        end
    end)
    GameCenter.DailyActivitySystem:ReqJoinActivity(12, _mapID)
end

-- Get layer dictionary by paging
function BossSystem:GetLayerDirByPage(page)
    return self.LayerBossIDDic[page]
end

-- Request all boss information, 1. World boss 2. Boss Home
function BossSystem:ReqAllWorldBossInfo(bossTyp)
    local _req = ReqMsg.MSG_Boss.ReqOpenDreamBoss:New()
    _req.bossType = bossTyp
    _req:Send()
    --GameCenter.Network.Send("MSG_Boss.ReqOpenDreamBoss")
end

-- Request data for the set of bosses
function BossSystem:ReqSuitBossInfo()
    local _msg = ReqMsg.MSG_Boss.ReqSuitGemBossPanel:New()
    -- 0 set of bosses
    _msg.type = 0
    _msg:Send()
end

-- Synchronous revenue times
function BossSystem:ResUpDateWorldBossReMainRankCount(result)
    if result.bossType == BossType.WorldBoss then
        self.WorldBossReaminCount = result.remainCount
        self.WorldBossRankRewardMaxCount = result.maxCount
        self:CheckWorldBossRedPoint()
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATEREMINRANKCOUNT)
    elseif result.bossType == BossType.SuitBoss then
        self.SuitBossCount = result.remainCount
        self.SuitGemBossType = result.bossType
        self:CheckSuitBossRedPoint()
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFESH_REMAINCOUNT, self.SuitGemBossType)
        if self.SuitBossCount == 0 then
            --GameCenter.PushFixEvent(UIEventDefine.UINewWorldBossEarningsNumberForm_OPEN, self.SuitGemBossType)
        end
    elseif result.bossType == BossType.NewBossHome then
        self.NewBHReCount = result.remainCount -- The number of times left of boss home
        self.NewBHMaxCount = result.maxCount -- The maximum number of times the boss home
        if self.NewBHReCount <= 0 then
            -- The remaining number of times is insufficient, the interface will be opened directly to increase the number of times
            GameCenter.PushFixEvent(UIEventDefine.UINewWorldBossEarningsNumberForm_OPEN, BossType.NewBossHome)
        end
        self:CheckNewBossHomeRedPoint()
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_BOSSHOME_COUNT)
    elseif result.bossType == BossType.TrainBoss then
        self.TrainBossReaminCount = result.remainCount
        self.TrainBossRankRewardMaxCount = result.maxCount
        -- self:CheckWorldBossRedPoint()
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATEREMINRANKCOUNT)
    end
end

-- Tips for the number of returns
function BossSystem:ResRankCountTips(result)
    local _bossID = GameCenter.BossSystem.CurSelectBossID
    if _bossID <= 0 then
        _bossID = GameCenter.BossInfoTipsSystem.CustomCfgID
    end
    local _bossCfg = DataConfig.DataBossnewWorld[_bossID]
    local _curCfgPage = 0
    if _bossCfg == nil then
        return
    end
    _curCfgPage = _bossCfg.Page
    -- The infinite layer is less than or equal to 0, and the number of times the return is not bounced
    if _curCfgPage > 0 then
        -- Crystal Boss
        if _curCfgPage == WorldBossPageEnum.SuitBoss then
            --GameCenter.PushFixEvent(UIEventDefine.UINewWorldBossEarningsNumberForm_OPEN, SuitGemBossEnum.SuitBoss)
        elseif _curCfgPage == WorldBossPageEnum.WordBoss then
            GameCenter.PushFixEvent(UIEventDefine.UINewWorldBossEarningsNumberForm_OPEN, BossType.WorldBoss)
        elseif _curCfgPage == WorldBossPageEnum.BossHome then
            GameCenter.PushFixEvent(UIEventDefine.UINewWorldBossEarningsNumberForm_OPEN, BossType.NewBossHome)
        else
            GameCenter.PushFixEvent(UIEventDefine.UINewWorldBossEarningsNumberForm_OPEN)
        end
    end
end

-- Returns the number of added earnings
function BossSystem:ResAddWorldBossRankCount(result)
    if result.bossType == BossType.WorldBoss then
        -- Total times
        self.WorldBossRankRewardMaxCount = result.maxCount
        -- Number of remaining times
        self.WorldBossReaminCount = result.remainCount
        -- Increased times
        self.WorldBossAddCount = result.buyCount
        self:CheckWorldBossRedPoint()
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_ADDWORLDRANKCOUNT)
    elseif result.bossType == BossType.SuitBoss then
        self.SuitBossAllCount = result.maxCount
        self.SuitBossAddCount = result.buyCount
        self.SuitBossCount = result.remainCount
        self:CheckSuitBossRedPoint()
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFESH_REMAINCOUNT, BossType.SuitBoss)
    elseif result.bossType == BossType.SoulMonster then
        GameCenter.SoulMonsterSystem.SoulMonsterRankRewardMaxCount = result.maxCount
        -- Number of remaining times
        GameCenter.SoulMonsterSystem.SoulMonsterRankRewardCount = result.remainCount
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.GodIsland, result.remainCount > 0)
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_HUNSHOUSENLIN_UPDATE)
    elseif result.bossType == BossType.CrossHorseBoss then
        -- Total times
        GameCenter.MountBossSystem.BossRankRewardMaxCount = result.maxCount
        -- Number of remaining times
        GameCenter.MountBossSystem.BossReaminCount = result.remainCount
        -- Increased times
        GameCenter.MountBossSystem.BossAddCount = result.buyCount
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.MountECopy, GameCenter.MountBossSystem.BossReaminCount > 0)
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_CROSSMOUNTBOSS_ADDCOUNT)
    elseif result.bossType == BossType.NewBossHome then
        self.NewBHReCount = result.remainCount -- The number of times left of boss home
        self.NewBHMaxCount = result.maxCount -- The maximum number of times the boss home
        self:CheckNewBossHomeRedPoint()
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_ADDWORLDRANKCOUNT)
    elseif result.bossType == BossType.TrainBoss then
        -- Total times
        self.TrainBossRankRewardMaxCount = result.maxCount
        -- Number of remaining times
        self.TrainBossReaminCount = result.remainCount
        -- Increased times
        self.TrainBossAddCount = result.buyCount
        -- self:CheckWorldBossRedPoint()
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_ADDWORLDRANKCOUNT)
    end
    Utils.ShowPromptByEnum("BossSystemAddCount", result.remainCount)
end

function BossSystem:ResOpenDreamBoss(result)
    if result then
        if result.mapOlList ~= nil then
            for i = 1, #result.mapOlList do
                local _bossMapNum = result.mapOlList[i]
                if not self.OlBossDict:ContainsKey(_bossMapNum.mapModelId) then
                    self.OlBossDict:Add(_bossMapNum.mapModelId, _bossMapNum.num)
                else
                    self.OlBossDict[_bossMapNum.mapModelId] = _bossMapNum.num
                end
            end
        end

        if result.bossList == nil or #result.bossList == 0 then
            Debug.LogError("No boss information returned")
            return
        end

        if result.bossType == BossType.WorldBoss then
            for i = 1, #result.bossList do
                self:RefreshBossInfo(result.bossList[i])
            end
            self.WorldBossRankRewardMaxCount = result.maxCount
            self.WorldBossReaminCount = result.remainCount
            -- Number of times purchased
            self.WorldBossAddCount = result.buyCount
            self:CheckWorldBossRedPoint()
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATEREMINRANKCOUNT)
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_NEWWORLDBOSS_REFRESHTIME)
        elseif result.bossType == BossType.NewBossHome then
            for i = 1, #result.bossList do
                self:RefreshBossInfo(result.bossList[i])
            end
            self.NewBHReCount = result.remainCount-- The number of times left of boss home
            self.NewBHMaxCount = result.maxCount-- The maximum number of times the boss home
            self:CheckNewBossHomeRedPoint()
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATEREMINRANKCOUNT)
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_NEWWORLDBOSS_REFRESHTIME)
        elseif result.bossType == BossType.TrainBoss then
            for i = 1, #result.bossList do
                self:RefreshBossInfo(result.bossList[i])
            end
            self.TrainBossRankRewardMaxCount = result.maxCount
            self.TrainBossReaminCount = result.remainCount
            -- Number of times purchased
            self.TrainBossAddCount = result.buyCount
            -- self:CheckWorldBossRedPoint()
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATEREMINRANKCOUNT)
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_NEWWORLDBOSS_REFRESHTIME)
        end
    end
end

-- Request BOSS kill information
function BossSystem:ReqBossKilledInfo(bossID, bossTyp)
    GameCenter.Network.Send("MSG_Boss.ReqBossKilledInfo", {bossId = bossID, bossType = bossTyp})
end

function BossSystem:ResBossKilledInfo(result)
    if result.bossType == BossType.WorldBoss or result.bossType == BossType.GemBoss or result.bossType == BossType.SuitBoss then
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_NEWWORLDBOSS_KILLRECORD, result)
    elseif result.bossType == BossType.SoulMonster then
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_HUNSHOU_SHOWKILLINFO, result)
    elseif result.bossType == BossType.NewBossHome then
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_BOSSHOME_KILLRECORD, result)
    end
end

-- Request attention to the boss. Follow = Request method, true: follow, false: unfollow, 1. World boss 2. Boss Home
function BossSystem:ReqFollowBoss(bossID, isFollow, bossTyp)
    -- In the agreement: 1: Follow, 2: Unfollow
    local _followType = isFollow and 1 or 2
    GameCenter.Network.Send("MSG_Boss.ReqFollowBoss", {bossId = bossID, type = _followType, bossType = bossTyp})
end

function BossSystem:ResFollowBoss(result)
    if result and result.isSuccess then
        if result.bossType == BossType.WorldBoss or result.bossType == BossType.SuitBoss or result.bossType == BossType.GemBoss or result.bossType == BossType.NewBossHome or result.bossType == BossType.TrainBoss then
            if self.WorldBossInfoDic:ContainsKey(result.bossId) then
                self.WorldBossInfoDic[result.bossId].IsFollow = result.type == 1
                GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_NEWWORLDBOSS_FOLLOW)
                if result.type == 1 then
                    Utils.ShowPromptByEnum("AttentionSucceed")
                end
            end
        elseif result.bossType == BossType.SoulMonster then
            GameCenter.SoulMonsterSystem:InitBossInfo()
            if GameCenter.SoulMonsterSystem.SoulMonsterBossInfoDic:ContainsKey(result.bossId) then
                GameCenter.SoulMonsterSystem.SoulMonsterBossInfoDic[result.bossId].IsFollow = result.type == 1
                GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_HUNSHOU_GUANZHUREFREASH)
                if result.type == 1 then
                    Utils.ShowPromptByEnum("AttentionSucceed")
                end
            end
        end
    end
end

-- BOSS information refresh
function BossSystem:ResBossRefreshInfo(result)
    if result and result.bossRefreshList then
        if result.bossType == BossType.WorldBoss or result.bossType == BossType.SuitBoss or result.bossType == BossType.GemBoss or result.bossType == BossType.NewBossHome or result.bossType == BossType.TrainBoss then
            for i = 1, #result.bossRefreshList do
                self:RefreshBossInfo(result.bossRefreshList[i])
            end
            if result.bossType == BossType.SuitBoss then
                self.SuitGemBossType = SuitGemBossEnum.SuitBoss
                if self.SuitBossAllCount <= 0 then
                    local _msg = ReqMsg.MSG_Boss.ReqSuitGemBossPanel:New()
                    -- 0 set of boss
                    _msg.type = 0
                    _msg:Send()
                end
            elseif result.bossType == BossType.GemBoss then
                self.SuitGemBossType = SuitGemBossEnum.GemBoss
            end
        -- Fake wireless boss [Ding Huaqiang 2019/9/6]
        elseif result.bossType == BossType.WuXianBoss then
            local _newBossInfoList = result.bossRefreshList
            for i=1, #_newBossInfoList do
                if _newBossInfoList[i].refreshTime == 0 then
                    self.CurWuxianBossId = _newBossInfoList[i].bossId
                    break
                end
            end
            for i = 1, #_newBossInfoList do
                self:RefreshBossInfo(_newBossInfoList[i])
                local _msgInfo = _newBossInfoList[i]
                self.WuXianBossDict[_msgInfo.bossId] = _msgInfo.refreshTime
            end
            local _result = self:CheckWuxianBossStates()
            if _result then
                self.LeaveReaminTime = 5
                self.StartLeaveCountDown = true
            end
        end
    end
end

-- Test whether the boss is dead or not
function BossSystem:CheckWuxianBossStates()
    local _isBossAllDead = true
    local _time = -1
    self.WuXianBossDict:ForeachCanBreak(
        function(_, _refeshTime)
            -- boss information 0 dead 1
            if _refeshTime == 0 then
                _isBossAllDead = false
                return true
            end
        end
    )
    return _isBossAllDead
end

-- The world boss refresh is one minute in advance
function BossSystem:ResBossRefreshTip(result)
    if result.bossType == BossType.WorldBoss or result.bossType == BossType.GemBoss or result.bossType == BossType.SuitBoss or result.bossType == BossType.NewBossHome then
        -- The world boss prompts in advance that result.bossId is the world boss configuration table id
        local _bossCfg = DataConfig.DataBossnewWorld[result.bossId]
        if _bossCfg then
            -- _bossCfg.ID is also the monster table id
            GameCenter.PushFixEvent(UIEventDefine.UIBossInfoTips_OPEN, {_bossCfg.ID, _bossCfg.CloneMap, result.bossId, result.bossType})
        end
    elseif result.bossType == BossType.TianXuWar then
        GameCenter.TerritorialWarSystem:ResAttentionMonsterRefresh(result.bossId)
    end
end

-- Synchronous damage ranking information
function BossSystem:ResSynHarmRank(result)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_NEWWORLDBOSS_HARMRANKREFRESH, result)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_BOSSHOME_HARMRANKREFRESH, result)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_HUNSHOU_HURTRANKINFO, result)
    if result.bossType == BossType.CrossHorseBoss then
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MOUNTBOSS_HURTRANKINFO, result)
    elseif result.bossType == BossType.SlayerBoss then
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SLAYERCOPY_BOSSHARM, result)
    elseif result.bossType == BossType.XuMiBaoKu then
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_XUMIBAOKU_BOSSHARM, result)
    end
end

-- After killing the BOSS, open the checkout panel
function BossSystem:ResBossStateResultPanl(result)
    GameCenter.PushFixEvent(UIEventDefine.UINewCompCopyResultForm_OPEN, result)
end
-- #####################################################

-- Return to personal BOSS refresh time
function BossSystem:ResMySelfBossRemainTime(msg)
    self.MySelfBossRefshTime = msg.remaintime
    GameCenter.PushFixEvent(LogicLuaEventDefine.BOSS_EVENT_MYSELF_REMAINTEAM,self.MySelfBossRefshTime)
end 

-- Data return of the set of gem boss opening interface
function BossSystem:ResSuitGemBossPanel(msg)
    if msg ~= nil then
        -- Boss Type
        self.SuitGemBossType = msg.type
        -- BOSS information
        if msg.bossList ~= nil then
            for i = 1, #msg.bossList do
                self:RefreshBossInfo(msg.bossList[i])
            end
        end
        if msg.mapOlList ~= nil then
            for i = 1, #msg.mapOlList do
                local _bossMapNum = msg.mapOlList[i]
                if not self.SuitGemOLDict:ContainsKey(_bossMapNum.mapModelId) then
                    self.SuitGemOLDict:Add(_bossMapNum.mapModelId, _bossMapNum.num)
                else
                    self.SuitGemOLDict[_bossMapNum.mapModelId] = _bossMapNum.num
                end
            end
        end
        self.SuitBossCount = msg.remainCount
        self.SuitBossAllCount = msg.maxCount
        -- Number of times purchased
        self.SuitBossAddCount = msg.buyCount
        self:CheckSuitBossRedPoint()
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFESH_REMAINCOUNT, self.SuitGemBossType)
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_NEWWORLDBOSS_REFRESHTIME)
    end
end

function BossSystem:ResSuitGemBossScourge(msg)
    if msg ~= nil then
        -- Real-time update of Tianfa value
        if msg.scourge and msg.scourge > 100 then
            self.Scourge = 100
        else
            self.Scourge = msg.scourge
        end
        GameCenter.PushFixEvent(LogicLuaEventDefine.BOSS_EVENT_SUIT_GEM_BOSS_REFESH)
    end
end

-- Time for Infinite Layer Boss to be turned on and off
function BossSystem:ResWuXianBossOCTime(msg)
    -- Unlimited Boss Closed Time
    --self.WuxianBossCloseTime = msg.closeTime
    -- The time when the infinite boss is about to be turned on
    --self.WuxianBossOpenTime = msg.openTime
end

-- Novice BOSS kill list
function BossSystem:ResNoobBossPannel(msg)
    if msg ~= nil then
        -- BOSS information
        local _bossList = msg.bossList
        if _bossList then
            for i=1, #_bossList do
                if self.WorldBossInfoDic:ContainsKey(_bossList[i]) then
                    local _bossInfo = self.WorldBossInfoDic[_bossList[i]]
                    _bossInfo.IsKilled = true
                end
            end
        end
    end
end

-- Initialize the personal BOSS configuration table
function BossSystem:InitConfig()
    DataConfig.DataBossnewPersonal:Foreach(function(k, v)
        if not self.BossPersonal:ContainsKey(v.Layer) then
            local _list = List:New()
            _list:Add(v)
            self.BossPersonal:Add(v.Layer, _list)
        else
            self.BossPersonal[v.Layer]:Add(v)
        end
    end)
    self.BossPersonal:SortKey(
        function(a,b)
            return a < b
        end
    )
    for k, v in pairs(self.BossPersonal) do
        v:Sort(
            function(a,b)
                return a.Monsterid < b.Monsterid
            end
        )
    end
end

-- Obtain rebirth time through BOSSID
function BossSystem:GetBossReviewTimeByIs(layer,bossid)
    if self.BossPersonal:ContainsKey(layer) then
        local _info = self.BossPersonal[layer]:Find(
            function(code)
                return code.Monsterid == bossid
            end
        )
        if _info then
            return _info.ReviveTime
        end
    end
    return 0
end

-- Obtain the position through the BOSSID
function BossSystem:GetBossPos(monsterid,layer)
    if self.BossPersonal:ContainsKey(layer) then
        local _info = self.BossPersonal[layer]:Find(
            function(code)
                return code.Monsterid == monsterid
            end
        )
        if _info then
            return _info.Pos
        end
    end
    return nil
end

-- Parsing the string to get coordinates
function BossSystem:AnalysisPos(str)
    if str then
        local _attr = Utils.SplitStr(str,'_')
        if #_attr == 2 then
            return tonumber(_attr[1]),tonumber(_attr[2])
        end
    end
end

-- Parsing the string to get props
function BossSystem:AnalysisItem(str)
    if str then
        local _attr = Utils.SplitStr(str,';')
        local _list = List:New()
        for i=1,#_attr do
            _list:Add(tonumber(_attr[i]))
        end
        return _list
    end
    return nil
end

function BossSystem:GetMonsterNameByCfgName(cfgName)
    return string.match(cfgName, ".+%f[(]")
end

function BossSystem:GetMonsterLvByCfgName(cfgName)
    return string.match(cfgName, "%d+")
end

-- renew
function BossSystem:Update(dt)
end

-- Check the world boss red dots
function BossSystem:CheckWorldBossRedPoint()
    local _showRedPoint = false
    if self.WorldBossReaminCount > 0 then
        _showRedPoint = true
    end
    -- Calculate whether the number of purchases can be purchased
    -- Calculate the number of purchases red dots
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp ~= nil then
        local _curLevel = _lp.VipLevel
        if _curLevel < 0 then
            _curLevel = 0
        end
        local _copyVipCfgId = 16
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
            local _curBuyCount = self.WorldBossAddCount
            if _curLevelCanBuy > _curBuyCount then
                _showRedPoint = true
            end
        end
    end
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.WorldBoss, _showRedPoint)
end

-- Check out the red dots for boss
function BossSystem:CheckSuitBossRedPoint()
    local _showRedPoint = false
    if self.SuitBossCount > 0 then
        _showRedPoint = true
    end
    -- Calculate whether the number of purchases can be purchased
    -- Calculate the number of purchases red dots
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp ~= nil then
        local _curLevel = _lp.VipLevel
        if _curLevel < 0 then
            _curLevel = 0
        end
        local _copyVipCfgId = 17
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
            local _curBuyCount = self.SuitBossAddCount
            if _curLevelCanBuy > _curBuyCount then
                _showRedPoint = true
            end
        end
    end
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.WorldBoss1, _showRedPoint)
end

-- Check out the new boss home red dots
function BossSystem:CheckNewBossHomeRedPoint()
    GameCenter.RedPointSystem:RemoveFuncCondition(FunctionStartIdCode.BossHome, 1)
    if self.NewBHReCount > 0 then
        -- Red dots remaining times
        GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.BossHome, 1, RedPointCustomCondition(true))
    end
end

return BossSystem
