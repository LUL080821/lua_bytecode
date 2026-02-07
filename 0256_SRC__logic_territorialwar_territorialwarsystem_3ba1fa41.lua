------------------------------------------------
-- Author: 
-- Date: 2019-09-23
-- File: TerritorialWarSystem.lua
-- Module: TerritorialWarSystem
-- Description: Territory War
------------------------------------------------
local L_CelebrityData = require("Logic.TerritorialWar.TerriCelebrityData")
local TerritorialWarSystem = {
    LocalBossInfoDic = Dictionary:New(),      -- This server's BOSS information dictionary
    CrossBossInfoDic = Dictionary:New(),      -- Cross-server BOSS information dictionary
    -- Current Anger Value
    CurAnger = 0,
    -- The greatest anger
    MaxAnger = 0,
    -- Boss selected when entering the copy
    CurSelectMonsterID = 0,
    -- Number of surviving guardians
    LocalLiveGuardianNum = 0,
    CrossLiveGuardianNum = 0,
    -- Elite Survival Number
    LocalLiveEliteNum = 0,
    CrossLiveEliteNum = 0,
    -- Lord's blood
    LocalLordBossBloodValue = 0,
    CrossLordBossBloodValue = 0,
    -- The remaining time of the event can be the opening time or the closing time of the event
    RemainTime = 0,
    -- Event preparation time
    WaitingTime = 0,
    -- Anger refresh reset time
    AngerUpdateTime = 0,
    -- Is the event open?
    IsOpen = false,
    -- Save a default map ID
    CloneMapID = 0,
    -- Player camp ID
    Camp = 1,
    -- Angry ICON
    NuqiIcon = 0,
    CurStateId = 0,
    -- Whether to display the store button effect
    ShowShopEffect = true,
    ListData = Dictionary:New(),
}

function TerritorialWarSystem:Initialize()
    self.ListData:Clear()
    self.ShowShopEffect = true
    DataConfig.DataUniverseRank:Foreach(function(k, v)
        local data = L_CelebrityData:New()
        data:Parase(v)
        self.ListData:Add(k, data)
    end)
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_CROSSDAY, self.OnCrossDay, self)
end


function TerritorialWarSystem:UnInitialize()
    self.LocalBossInfoDic:Clear()
    self.CrossBossInfoDic:Clear()
    self.CurSelectMonsterID = 0
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_CROSSDAY, self.OnCrossDay, self)
end

-- Initialize the BOSS list
function TerritorialWarSystem:InitBossInfo()
    self.IsInitCfg = true
    self:ReSetBossInfo()
    self:SetCrossRemainTime()
    self:InitAngerMax()
end

function TerritorialWarSystem:InitAngerMax()
    self.MaxAnger = tonumber(DataConfig.DataGlobal[GlobalName.Universe_Anger_Limit].Params)
    self.NuqiIcon = tonumber(DataConfig.DataGlobal[GlobalName.UniverseNuqiIcon].Params)
end

function TerritorialWarSystem:GetAngerMax()
    if self.MaxAnger <= 0 then
        self.MaxAnger = tonumber(DataConfig.DataGlobal[GlobalName.Universe_Anger_Limit].Params)
    end
    return self.MaxAnger
end

function TerritorialWarSystem:GetAngerIcon()
    if self.NuqiIcon <= 0 then
        self.NuqiIcon = tonumber(DataConfig.DataGlobal[GlobalName.UniverseNuqiIcon].Params)
    end
    return self.NuqiIcon
end

function TerritorialWarSystem:GetLocalBossInfoDic()
    if not self.IsInitCfg then
        self:InitBossInfo()
    end
    return self.LocalBossInfoDic
end

function TerritorialWarSystem:GetCrossBossInfoDic()
    if not self.IsInitCfg then
        self:InitBossInfo()
    end
    return self.CrossBossInfoDic
end

-- Reset Monster Data
function TerritorialWarSystem:ReSetBossInfo()
    self.LocalBossInfoDic:Clear()
    self.CrossBossInfoDic:Clear()
    local _worldLv = GameCenter.OfflineOnHookSystem:GetCurWorldLevel()
    local function _forFunc(k, v)
        if v.Camp == self.Camp or v.Camp == 5 then
            if v.WorldLevel and v.WorldLevel ~= "" then
                local _ar = Utils.SplitNumber(v.WorldLevel, '_')
                if #_ar == 2 and _ar[1] <= _worldLv and _ar[2] >= _worldLv then
                    local _ownInfo = {}
                    if v then
                        _ownInfo.Id = k
                        _ownInfo.BossCfg = v
                        _ownInfo.BornTime = 0
                        _ownInfo.IsFollow = false
                        _ownInfo.IsKilled = false
                        _ownInfo.MonsterCfg = DataConfig.DataMonster[v.MonsterID]
                        if v.Camp ~= 5 then
                            self.LocalBossInfoDic:Add(k, _ownInfo)
                        else
                            self.CrossBossInfoDic:Add(k, _ownInfo)
                        end
                    end
                end
            end
        end
    end
    DataConfig.DataUniverseBoss:Foreach(_forFunc)
    self.LocalLordBossBloodValue = 100
    self.CrossLordBossBloodValue = 100
    self:SetMonsterLiveNum()
end

function TerritorialWarSystem:Update(dt)
    if self.RemainTime > 0 then
        self.RemainTime = self.RemainTime - dt
        if self.RemainTime <= 0 then
            self:SetCrossRemainTime()
            if not self.IsOpen then
                self:ReSetBossInfo()
            end
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MANORWAR_CROSSNOMAL_UPDATE)
        end
    end
    if self.WaitingTime > 0 then
        self.WaitingTime = self.WaitingTime - dt
        if self.WaitingTime <= 0 then
            self:SetCrossRemainTime()
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MANORWAR_CROSSNOMAL_UPDATE)
        end
    end
    self:UpdateBossBornTime(dt)
end

-- Get current Hall of Fame data through stateId
function TerritorialWarSystem:GetCurData()
    if self.ListData:ContainsKey(self.CurStateId) then
        return self.ListData[self.CurStateId]
    end
    return nil
end

-- Set the server opening time
function TerritorialWarSystem:SetOpenServerTime(time)
    self.ServerOpenTime = math.floor(time / 1000)
    if GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.TerritorialWar) then
        local _day = Time.GetDayOffset(self.ServerOpenTime, math.floor(GameCenter.HeartSystem.ServerTime)) + 1
        local _cfg = DataConfig.DataGlobal[GlobalName.UniverseSeverOpenTime]
        if _cfg then
            local _needDay = tonumber(_cfg.Params)
            if _day >= _needDay then
                GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.TerritorialWar, true)
            else
                GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.TerritorialWar, false)
            end
        end
    end
end

-- Recalculate whether the function is enabled during the cross-day
function TerritorialWarSystem:OnCrossDay(obj, sender)
    if self.ServerOpenTime then
        if GameCenter.MainFunctionSystem:FunctionIsEnabled(FunctionStartIdCode.TerritorialWar) then
            local _day = Time.GetDayOffset(self.ServerOpenTime, math.floor(GameCenter.HeartSystem.ServerTime)) + 1
            local _cfg = DataConfig.DataGlobal[GlobalName.UniverseSeverOpenTime]
            if _cfg then
                local _needDay = tonumber(_cfg.Params)
                if _day >= _needDay then
                    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.TerritorialWar, true)
                else
                    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.TerritorialWar, false)
                end
            end
        end
    end
end

-- Set the next angry reset time according to the current server time
function TerritorialWarSystem:SetAngerUpdateTime()
    local _nowTime = GameCenter.HeartSystem.ServerTime
    self.AngerUpdateTime = 0
    _nowTime = math.floor(_nowTime + 0.5)
    local _t = Time.GetNowTable();
    local _hour = _t.hour;
    local _min = _t.min;
    local _sec = _t.sec;
    local _curMin = _min + _hour * 60
    local _config = DataConfig.DataGlobal[GlobalName.UniverseNuqReset]
    if _config then
        local _arr = Utils.SplitNumber(_config.Params, '_')
        if #_arr >= 2 then
            for i = 1, #_arr - 1 do
                if _curMin >= _arr[i] and _curMin < _arr[i + 1] then
                    self.AngerUpdateTime = _arr[i + 1]
                    break
                end
                if i == #_arr - 1 and _curMin >= _arr[i + 1] then
                    self.AngerUpdateTime = _arr[1]
                end
            end
        elseif #_arr == 1 and _arr[1] then
            self.AngerUpdateTime = _arr[1]
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_TERRITORIALWAR_ANGERREMAINTIME_UPDATE)
end

-- Refresh the cross-server opening time according to the current server time
function TerritorialWarSystem:SetCrossRemainTime()
    local _nowTime = GameCenter.HeartSystem.ServerTime
    self.RemainTime = 0
    _nowTime = math.floor(_nowTime + 0.5)
    local _t = Time.GetNowTable();
    local _hour = _t.hour;
    local _min = _t.min;
    local _sec = _t.sec;
    local _curMin = _min + _hour * 60
    local _config = DataConfig.DataDaily[109]
    if _config then
        local _arr = Utils.SplitStr(_config.Time, ';')
        local _mapArr = Utils.SplitNumber(_config.CloneID, '_')
        local _firstOpenMin = 0
        for i = 1, #_arr - 1 do
            local _timeArr = Utils.SplitNumber(_arr[i], '_')
            local _nextArr = Utils.SplitNumber(_arr[i + 1], '_')
            if _curMin >= _timeArr[2] and _curMin < _nextArr[1] then
                self.RemainTime = (_nextArr[1] - _curMin) * 60 - _sec
                self.IsOpen = false
                break
            end
            if _curMin < _timeArr[1] and i == 1 then
                self.RemainTime = (_timeArr[1] - _curMin) * 60 - _sec
                self.IsOpen = false
                break
            end
            if _curMin >= _timeArr[1] and _curMin < _timeArr[2] then
                self.IsOpen = true
                self.RemainTime = (_timeArr[2] - _curMin) * 60 - _sec
                local _mapCfg = DataConfig.DataCloneMap[_mapArr[i]]
                if _mapCfg then
                    local _maxWaitingTime = _mapCfg.EnterTime / 1000
                    self.CloneMapID = _mapArr[i]
                    self.WaitingTime = _maxWaitingTime + _timeArr[1] * 60 - _curMin * 60 - _sec
                    if self.WaitingTime < 0 then
                        self.WaitingTime = 0
                    end
                end
                break
            end
            if _curMin >= _nextArr[1] and _curMin < _nextArr[2] then
                self.IsOpen = true
                self.RemainTime = (_nextArr[2] - _curMin) * 60 - _sec
                local _mapCfg = DataConfig.DataCloneMap[_mapArr[i]]
                if _mapCfg then
                    local _maxWaitingTime = _mapCfg.EnterTime / 1000
                    self.CloneMapID = _mapArr[i]
                    self.WaitingTime = _maxWaitingTime + _nextArr[1] * 60 - _curMin * 60 - _sec
                    if self.WaitingTime < 0 then
                        self.WaitingTime = 0
                    end
                end
                break
            end
            if i == #_arr - 1 and _curMin >= _nextArr[2] then
                self.RemainTime = (1440 - _curMin + _firstOpenMin) * 60 - _sec
                self.IsOpen = false
            end
            if i == 1 then
                _firstOpenMin = _timeArr[1]
            end
        end
    end
end

-- Get the ID of the Lord BOSS
function TerritorialWarSystem:GetLordBossID(type)
    local _id = 0
    if not self.IsInitCfg then
        self:InitBossInfo()
    end
    if type == 1 then
        self.LocalBossInfoDic:ForeachCanBreak(function(k, v)
            if v.BossCfg.Type == 1 then
                _id = v.BossCfg.MonsterID
                return true
            end
        end)
    else
        self.CrossBossInfoDic:ForeachCanBreak(function(k, v)
            if v.BossCfg.Type == 1 then
                _id = v.BossCfg.MonsterID
                return true
            end
        end)
    end
    return _id
end

-- Is the BOSS alive?
function TerritorialWarSystem:MonsterIsLive(type, monsterId)
    local _id = 0
    local _live = 0
    if not self.IsInitCfg then
        self:InitBossInfo()
    end
    local _monstArr = Utils.SplitNumber(monsterId, '_')
    if type ~= 5 then
        self.LocalBossInfoDic:ForeachCanBreak(function(k, v)
            if _monstArr and _monstArr:Contains(k) then
                if v.BornTime == 0 then
                    _id = k
                    _live = 1
                end
                return true
            end
        end)
    else
        self.CrossBossInfoDic:ForeachCanBreak(function(k, v)
            if _monstArr and _monstArr:Contains(k) then
                if v.BornTime == 0 then
                    _id = k
                    _live = 1
                end
                return true
            end
        end)
    end
    return _live, _id
end

function TerritorialWarSystem:GetBossTypeName(type)
    if type == 1 then
        return DataConfig.DataMessageString.Get("C_TERRITORIAL_BOSSTYPE1")
    elseif type == 2 then
        return DataConfig.DataMessageString.Get("C_TERRITORIAL_BOSSTYPE2")
    else
        return DataConfig.DataMessageString.Get("C_TERRITORIAL_BOSSTYPE3")
    end
end

-- Get attention status
function TerritorialWarSystem:GetMonsterFollow(monsterId)
    if not self.IsInitCfg then
        self:InitBossInfo()
    end
    if self.LocalBossInfoDic[monsterId] then
        return self.LocalBossInfoDic[monsterId].IsFollow
    elseif self.CrossBossInfoDic[monsterId] then
        return self.CrossBossInfoDic[monsterId].IsFollow
    end
    return false
end

function TerritorialWarSystem:SetMonsterLiveNum()
    self.LocalLiveEliteNum = 0
    self.LocalLiveGuardianNum = 0
    self.CrossLiveEliteNum = 0
    self.CrossLiveGuardianNum = 0
    self.LocalBossFresh = false
    self.CrossBossFresh = false
    if not self.IsInitCfg then
        self:InitBossInfo()
    end
    self.LocalBossInfoDic:ForeachCanBreak(function(k, v)
        if v.BossCfg.Type == 3 and v.BornTime == 0 then
            self.LocalLiveGuardianNum = self.LocalLiveGuardianNum + 1
        end
        if v.BossCfg.Type == 2 and v.BornTime == 0 then
            self.LocalLiveEliteNum = self.LocalLiveEliteNum + 1
        end
        if v.BornTime > 0 then
            self.LocalBossFresh = true
        end
    end)
    self.CrossBossInfoDic:ForeachCanBreak(function(k, v)
        if v.BossCfg.Type == 2 and v.BornTime == 0 then
            self.CrossLiveEliteNum = self.CrossLiveEliteNum + 1
        end
        if v.BossCfg.Type == 3 and v.BornTime == 0 then
            self.CrossLiveGuardianNum = self.CrossLiveGuardianNum + 1
        end
        if v.BornTime > 0 then
            self.CrossBossFresh = true
        end
    end)
end

-- Update Refresh Countdown
function TerritorialWarSystem:UpdateBossBornTime(dt)
    local _isUpdateState = false
    if self.LocalBossFresh then
        if not self.IsInitCfg then
            self:InitBossInfo()
        end
        self.LocalBossInfoDic:ForeachCanBreak(function(k, v)
            if v.BornTime > 0 then
                v.BornTime = v.BornTime - dt
                if v.BornTime <= 0 then
                    _isUpdateState = true
                end
            end
        end)
    end
    if self.CrossBossFresh then
        if not self.IsInitCfg then
            self:InitBossInfo()
        end
        self.CrossBossInfoDic:ForeachCanBreak(function(k, v)
            if v.BornTime > 0 then
                v.BornTime = v.BornTime - dt
                if v.BornTime <= 0 then
                    _isUpdateState = true
                end
            end
        end)
    end
    if _isUpdateState then
        self:SetMonsterLiveNum()
    end
end

-- Open the panel
function TerritorialWarSystem:OpenPanel()
    local _msg = ReqMsg.MSG_Universe.ReqUniverseWarPanel:New()
    _msg:Send()
    GameCenter.Network.Send("MSG_RankList.ReqUniverseRankPanel")
end

-- Enter the event
function TerritorialWarSystem:ReqJoinActivity(MapID)
    if MapID then
        self.CloneMapID = MapID
    end
    if self.IsOpen then
        if MapLogicTypeDefine.TerritorialWar == GameCenter.MapLogicSystem.MapCfg.MapLogicType then
            Utils.ShowPromptByEnum("C_TERRIALWAR_ENTERCOPY_ERR")
        else
            -- Determine whether the player has a team
            if GameCenter.TeamSystem:IsTeamExist() then
                Utils.ShowMsgBox(function(code)
                    if code == MsgBoxResultCode.Button2 then
                        local lp = GameCenter.GameSceneSystem:GetLocalPlayer()
                        if lp ~= nil then
                            GameCenter.TeamSystem:ReqTeamOpt(lp.ID, 3)
                            GameCenter.DailyActivitySystem:ReqJoinActivity(109, self.CloneMapID)
                            GameCenter.BISystem:ReqClickEvent(BiIdCode.TXZCEnter)
                        end
                    end
                end, "XMFIGHT_SYSTEM_TISHI_13")
            else
                GameCenter.DailyActivitySystem:ReqJoinActivity(109, self.CloneMapID)
                GameCenter.BISystem:ReqClickEvent(BiIdCode.TXZCEnter)
            end
        end
    else
        Utils.ShowPromptByEnum("C_TERRITORIAL_CLOSE")
    end
end

-- Follow the monsters
function TerritorialWarSystem:ReqAttentionMonster(bossid, isFollowed)
    local _msg = ReqMsg.MSG_Universe.ReqCareMonster:New()
    _msg.modelId = bossid
    _msg.type = isFollowed and 1 or 2
    _msg:Send()
end

-- Request damage list
function TerritorialWarSystem:ReqDamageRank(monsterId)
    local _msg = ReqMsg.MSG_Universe.ReqDamageRank:New()
    _msg.monsterId = monsterId
    _msg:Send()
end

-- Request Hall of Fame Data
function TerritorialWarSystem:ReqUniverseRankPanel()
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN, DataConfig.DataMessageString.Get("RankDataLoading"));
    GameCenter.Network.Send("MSG_RankList.ReqUniverseRankPanel")
end

-- Hall of Fame data return
function TerritorialWarSystem:ResUniverseRankPanel(result)
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
    if result == nil then
        return
    end
    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.TerritorialWarCelebrity, result.stage == 1 or result.stage == 2)
    self.CurStateId = result.stage
    local data = self:GetCurData()
    if data == nil then
        return
    end
    data:ParaseMsg(result)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_TERRITORIALWAR_CELEBRITY_RANKLIST)
end

-- The server returns the message to open the panel, the main content is the boss list
function TerritorialWarSystem:ResUniverseWarPanel(msg)
    self.LocalBossInfoDic:Clear()
    self.CrossBossInfoDic:Clear()
    self.IsInitCfg = true
    for i = 1, #msg.monsterInfos do
        local _info = msg.monsterInfos[i]
        local _ownInfo = {}
        local _cfg = DataConfig.DataUniverseBoss[_info.modelId]
        if _cfg then
            _ownInfo.Id = _info.modelId
            _ownInfo.BossCfg = _cfg
            _ownInfo.BornTime = 0
            _ownInfo.IsFollow = false
            _ownInfo.IsKilled = false
            _ownInfo.MonsterCfg = DataConfig.DataMonster[_cfg.MonsterID]
            if _ownInfo then
                _ownInfo.IsFollow = _info.care
                if _info.refreshTime then
                    _ownInfo.BornTime = _info.refreshTime
                end
            end
            if _cfg.Camp ~= 5 then
                self.Camp = _cfg.Camp
                self.LocalBossInfoDic:Add(_info.modelId, _ownInfo)
            else
                self.CrossBossInfoDic:Add(_info.modelId, _ownInfo)
            end
        end
    end
    self.CurAnger = msg.anger
    self.LocalLordBossBloodValue = msg.campBossHP
    self.CrossLordBossBloodValue = msg.finalBossHP
    self:SetMonsterLiveNum()
    self:SetCrossRemainTime()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MANORWAR_BOSSLIST_UPDATE)
end

-- Players kill monsters to update monster resurrection time
function TerritorialWarSystem:ResUpdateMonsterRefresh(msg)
    if not self.IsInitCfg then
        self:InitBossInfo()
    end
    if msg and msg.monsterInfos then
        for i = 1, #msg.monsterInfos do
            local _info = msg.monsterInfos[i]
            local _ownInfo = self.LocalBossInfoDic[_info.modelId]
            if not _ownInfo then
                _ownInfo = self.CrossBossInfoDic[_info.modelId]
            end
            if _ownInfo then
                _ownInfo.IsFollow = _info.care
                if _info.refreshTime then
                    _ownInfo.BornTime = _info.refreshTime
                end
                local _cfg = _ownInfo.BossCfg
                if _cfg and _cfg.Camp ~= 5 then
                    self.Camp = _cfg.Camp
                    if _cfg.Type == 1 then
                        if _ownInfo.BornTime ~= 0 then
                            self.LocalLordBossBloodValue = 0
                        end
                    end
                elseif _cfg and _cfg.Camp == 5 then
                    if _cfg.Type == 1 then
                        if _ownInfo.BornTime ~= 0 then
                            self.CrossLordBossBloodValue = 0
                        end
                    end
                end
            else
                _ownInfo = {}
                local _cfg = DataConfig.DataUniverseBoss[_info.modelId]
                if _cfg then
                    _ownInfo.Id = _info.modelId
                    _ownInfo.BossCfg = _cfg
                    _ownInfo.BornTime = 0
                    _ownInfo.IsFollow = _info.care
                    _ownInfo.IsKilled = false
                    _ownInfo.MonsterCfg = DataConfig.DataMonster[_cfg.MonsterID]
                    if _info.refreshTime then
                        _ownInfo.BornTime = _info.refreshTime
                    end
                    if _cfg.Camp ~= 5 then
                        self.Camp = _cfg.Camp
                        self.LocalBossInfoDic:Add(_info.modelId, _ownInfo)
                        if _cfg.Type == 1 then
                            if _ownInfo.BornTime ~= 0 then
                                self.LocalLordBossBloodValue = 0
                            end
                        end
                    else
                        self.CrossBossInfoDic:Add(_info.modelId, _ownInfo)
                        if _cfg.Type == 1 then
                            if _ownInfo.BornTime ~= 0 then
                                self.CrossLordBossBloodValue = 0
                            end
                        end
                    end
                end
            end
        end
    end
    self:SetMonsterLiveNum()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MANORWAR_BOSSLIST_UPDATE)
end

-- Synchronous Rage Value
function TerritorialWarSystem:ResSynAnger(msg)
    if msg then
        self.CurAnger = msg.anger
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MANORWAR_ANGER_UPDATE)
end

-- Return to follow monsters
function TerritorialWarSystem:ResCareMonster(msg)
    if msg then
        if not self.IsInitCfg then
            self:InitBossInfo()
        end
        if self.LocalBossInfoDic:ContainsKey(msg.modelId) then
            if msg.type == 1 then
                Utils.ShowPromptByEnum("AttentionSucceed")
            end
            self.LocalBossInfoDic[msg.modelId].IsFollow = msg.type == 1 and true or false
        end
        if self.CrossBossInfoDic:ContainsKey(msg.modelId) then
            if msg.type == 1 then
                Utils.ShowPromptByEnum("AttentionSucceed")
            end
            self.CrossBossInfoDic[msg.modelId].IsFollow = msg.type == 1 and true or false
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MANORWAR_BOSSLIST_UPDATE)
end

-- The monster you follow has been refreshed
function TerritorialWarSystem:ResAttentionMonsterRefresh(monsterModelId)
    local cfg = DataConfig.DataUniverseBoss[monsterModelId]
    if cfg then
        local _mapID = cfg.MapID
        GameCenter.PushFixEvent(UIEventDefine.UIBossInfoTips_OPEN, {cfg.MonsterID, _mapID, monsterModelId, BossType.TianXuWar})
    end
end

-- Injury data issuance
function TerritorialWarSystem:ResDamageRank(msg)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MANOR_HARMLIST_UPDATE, msg)
end
return TerritorialWarSystem
