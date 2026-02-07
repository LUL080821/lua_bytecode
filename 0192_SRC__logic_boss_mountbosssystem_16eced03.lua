local MountBossSystem = {
    BossInfoDic = Dictionary:New(),        -- BOSS information dictionary, key = configuration table id, value = {BossCfg, RefreshTime, IsFollow}
    LayerBossIDDic = Dictionary:New(),     -- page is K->value is the number of layers and bossID dictionary, key = number of layers, value = List<bossID>
    BossRankRewardMaxCount = 0,            -- The maximum number of rewards for BOSS rankings is called to increase the use of props
    BossReaminCount = 0,                   -- The number of times the boss earnings remain
    CurSelectBossID = 0,                   -- The currently selected BOSS id
    IsGiveupConfirm = true,
    BossAddCount = 0,
}
function MountBossSystem:Initialize()
    self:InitConfig()
end

function MountBossSystem:UnInitialize()
    self.BossInfoDic:Clear()
    self.CurSelectBossID = 0
    self.LayerBossIDDic:Clear()
    self.BossReaminCount = 0
    self.BossRankRewardMaxCount = 0
    self.StartCountDown = false
    self.IsGiveupConfirm = true
    self.BossAddCount = 0
end

function MountBossSystem:InitConfig()
    -- Initialize the BOSS dictionary
    DataConfig.DataBossnewHorseBoss:Foreach(function(k, v)
        if not self.LayerBossIDDic:ContainsKey(v.Layer) then
            local _bossIDList = List:New()
            _bossIDList:Add(k)
            local _bossInfo = {BossIDList = _bossIDList}
            _bossInfo.MinPower = v.Power
            self.LayerBossIDDic:Add(v.Layer, _bossInfo)
        else
            local _info = self.LayerBossIDDic[v.Layer]
            if not _info.BossIDList:Contains(k) then
                _info.BossIDList:Add(k)
            end
        end
        if not self.BossInfoDic:ContainsKey(k) then
            local _bossInfo = {BossCfg = v, RefreshTime = 0}
            self.BossInfoDic:Add(k, _bossInfo)
        end
    end)
    -- self.LayerBossIDDic:Foreach(function(key, value)
    --     value:SortKey(function(a, b) return a < b end)
    -- end)
end
-- renew
function MountBossSystem:Update(dt)
    if self.StartCountDown then
        local _haveDieBoss = false
        local _keys = self.BossInfoDic:GetKeys()
        for i=1,#_keys do
            local v = self.BossInfoDic[_keys[i]]
            if v.RefreshTime then
                if v.RefreshTime > 0 then
                    v.RefreshTime = v.RefreshTime - dt
                    _haveDieBoss = true
                elseif v.RefreshTime < 0 then
                    v.RefreshTime = 0
                end
            end
        end
        if not _haveDieBoss then
            self.StartCountDown = false
        end
    end
end

-- Request BOSS information
function MountBossSystem:ReqCrossHorseBossPanel(Layer)
    local _req = ReqMsg.MSG_CrossHorseBoss.ReqCrossHorseBossPanel:New()
    _req.level = Layer
    _req:Send()
end

-- Request to follow the BOSS
function MountBossSystem:ReqFollowBoss(bossId, isFollowed)
    local _req = ReqMsg.MSG_CrossHorseBoss.ReqFollowCrossHorseBoss:New()
    _req.bossId = bossId
    _req.followValue = isFollowed
    _req:Send()
end

-- Give up belonging
function MountBossSystem:ReqCancelAffiliation()
    local _req = ReqMsg.MSG_CrossHorseBoss.ReqCancelAffiliation:New()
    _req.cfgId = self.CurSelectBossID
    _req:Send()
end

-- -BOSS information issuance
function MountBossSystem:ResCrossHorseBossPanel(msg)
    self.BossRankRewardMaxCount = msg.maxCount
    self.BossReaminCount = msg.remainCount
    if msg.bossList then
        for i = 1, #msg.bossList do
            if self.BossInfoDic:ContainsKey(msg.bossList[i].bossId) then
                local _time = msg.bossList[i].refreshTime
                self.BossInfoDic[msg.bossList[i].bossId].RefreshTime = _time
                self.BossInfoDic[msg.bossList[i].bossId].IsFollow = msg.bossList[i].isFollowed
                if _time > 0 then
                    self.StartCountDown = true
                end
            end
        end
    end
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.MountECopy, self.BossReaminCount > 0)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_CROSSMOUNTBOSS_REFRESHTIME)
end

-- BOSS follow the results
function MountBossSystem:ResFollowCrossHorseBoss(msg)
    if self.BossInfoDic:ContainsKey(msg.bossId) then
        self.BossInfoDic[msg.bossId].IsFollow = msg.followValue
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_CROSSMOUNTBOSS_FOLLOW)
end

function MountBossSystem:ResCrossHorseBossRefreshTip(msg)
    -- BOSS prompts in advance that result.bossId is the BOSS configuration table id
    -- local _bossCfg = DataConfig.DataBossnewHorseBoss[msg.bossId]
    -- if _bossCfg then
    --     GameCenter.PushFixEvent(UIEventDefine.UIBossInfoTips_OPEN, {_bossCfg.Monsterid, _bossCfg.Cloneid, msg.bossId, BossType.CrossHorseBoss})
    -- end
end

function MountBossSystem:ResCancelAffiliationResult(msg)
    if msg.playerId == GameCenter.GameSceneSystem:GetLocalPlayerID() then
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MOUNTBOSS_GIVEUP)
    end
end
return MountBossSystem