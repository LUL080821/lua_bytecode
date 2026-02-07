------------------------------------------------
-- author:
-- Date: 2019-05-21
-- File: UINewWorldBossForm.lua
-- Module: UINewWorldBossForm
-- Description: World BOSS interface
------------------------------------------------
local UIListMenu = require "UI.Components.UIListMenu.UIListMenu"
local NGUITools = CS.NGUITools
local L_UIBossKillPanel = require "UI.Forms.UINewWorldBossForm.UIBossKillPanel"
local L_BossItem = require "UI.Forms.UINewWorldBossForm.UIBossItem"
local L_BossItemData = require "Logic.Boss.BossItemData"
local L_TimeUtils = CS.Thousandto.Core.Base.TimeUtils
local L_UIAnimDelayPlayer = require "UI.Components.UIAnimDelayPlayer"

local UINewWorldBossForm = {
    LeftTrs = nil, -- Transform named "left" on the left
    BossCloneGo = nil, -- boss clone
    BossCloneRoot = nil, -- boss cloning root node
    BossCloneRootScrollView = nil, -- ScrollView component on the boss cloning root node
    BossCloneRootGrid = nil, -- Grid component on boss cloning root node
    BossItemList = nil,
    CenterTrs = nil, -- Transform named "Center" in the middle
    ItemCloneGo = nil, -- Prop clone
    ItemCloneRoot = nil, -- Prop cloning node
    ItemCloneRootGrid = nil, -- The grid component on the prop cloning root node
    LuxItemCloneGo = nil, -- Cherish falling
    LuxItemCloneRoot = nil, -- Cherish falling
    LuxItemCloneRootGrid = nil, -- Cherish falling
    FollowBtn = nil, -- Follow Button
    FollowSelectedGo = nil,
    KillRecordBtn = nil, -- Kill the record button
    UIBossKillPanel = nil,  --Kill the record panel
    BottomTrs = nil, -- Transform named "Bottom" at the bottom
    EnterRewardCountLab = nil, -- The number of remaining times of participation reward label
    EnterRewardGo = nil,
    WuXianDes = nil, -- Description of infinite layers
    WuxianTimeDes = nil, -- Description of the Infinite Layer Open Time
    GotoBtn = nil, --Enter button
    ModelBotTexture = nil, -- The picture below the model

    FootBotTexture = nil, 

    BossSkin = nil, -- Boss Model

    CurSelectBossID = 0, -- The currently selected bossid
    CurSelectLayer = 0, -- The number of layers currently selected
    RefreshTimeOffset = 0.1, -- Refreshing time interval
    CurTime = 0, -- Used to calculate the time interval
    StartRefreshTime = false,
    LayerBossIDDic = nil, -- Layer Dictionary
    AddCountBtn = nil, --Add times button
    AddCountRedPoint = nil,
    RemainCountLabel = nil, -- The remaining number of recoverable times
    WordBossType = 0, -- Boss type, 1 World Boss 2 Set Boss 3 Gem Boss
    OpenCloseTime = nil, -- Countdown to the switch copy interface
    CurOCTime = 0,
    CurBossType = BossType.WorldBoss,
    Params = nil, -- The parameter passed in, this parameter passes the id of the BossID and bossnewword table
    -- The copy ID that needs to be displayed for the opening time
    CurCloneMapId = 0,
    NeedShowTimeList = nil,
    NeedShowCloneMapId = 0,
    -- Is it an infinite layer?
    IsInfinite = false,
    CurSelectBossItem = nil,
    CurBossData = nil,
    -- Used to record the countdown of the infinite layer on and off
    CloneStartTime = 0,
    CloneEndTime = 0,
    WuxianBossOpenTime = 0,
    WuxianBossCloseTime = 0,

    ArrowLeftBtn = nil,
    ArrowRightBtn = nil,
    CurSelectBossIndex = 1,
    CurSelectLayerIndex = 1,

    IsHideGoToBtn = false,

    LayerScrollViewWidth = 686,
    LayerItemWidth = 128,
    LayerScrollX = 0,
    CurLayerCount = 0,

    BossCount = 0,
    StartIndexShow = 1,
    EndIndexShow = 3,
    CurIndexShow = 1,
    IndexList = List:New(),

    FirstGridPosX = 0,
    CurGridPosX = 0,
    LastX = 0,
}

function UINewWorldBossForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UINewWorldBossForm_OPEN, self.OnOpen)
    self:RegisterEvent(UIEventDefine.UINewWorldBossForm_CLOSE, self.OnClose)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_NEWWORLDBOSS_REFRESHTIME, self.RefreshBossTime)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_NEWWORLDBOSS_KILLRECORD, self.SetBossKillRecord)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_NEWWORLDBOSS_FOLLOW, self.SetFollowBoss)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_ADDWORLDRANKCOUNT, self.AddSuccess)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_UPDATERRCOVERTIME, self.UpDateRankTime)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_TASKCHANG, self.UpdateTask)

    self:RegisterEvent(LogicLuaEventDefine.EID_WORLD_BOSS_KILL_RECORD_CLOSE, self.OnCloseKillRecord)
end

function UINewWorldBossForm:OnOpen(obj, sender)
    if obj ~= nil then
        if #obj > 1 then
            self.WordBossType = obj[1]
            -- Block the parameters and open the tags based on the level
            self.Params = tonumber(obj[2])
            if self.Params and not GameCenter.BossSystem.WorldBossInfoDic:ContainsKey(self.Params) then
                self.Params = nil
            end
        else
            self.WordBossType = obj[1]
            self.Params = nil
        end
    end
    self.LayerBossIDDic = GameCenter.BossSystem:GetLayerDirByPage(self.WordBossType)
    self.CSForm:Show(sender)
end

function UINewWorldBossForm:OnClose(obj, sender)
    self.CSForm:Hide()
    self.StartRefreshTime = false
end

-- Register events on the UI, such as click events, etc.
function UINewWorldBossForm:RegUICallback()
    UIUtils.AddBtnEvent(self.FollowBtn, self.OnClickFollowBtn, self)
    UIUtils.AddBtnEvent(self.KillRecordBtn, self.OnClickKillRecordBtn, self)
    UIUtils.AddBtnEvent(self.GotoBtn, self.OnClickGotoBtn, self)
    UIUtils.AddBtnEvent(self.AddCountBtn, self.OnClickAddCountBtn, self)

    UIUtils.AddBtnEvent(self.ArrowLeftBtn, self.OnClickLeftBtn, self)
    UIUtils.AddBtnEvent(self.ArrowRightBtn, self.OnClickRightBtn, self)
end

function UINewWorldBossForm:OnFirstShow()
    self:FindAllComponents()
    self:RegUICallback()
    local _cloneMapIds = Utils.SplitNumber(DataConfig.DataGlobal[1764].Params, "_")
    if self.NeedShowTimeList ~= nil then
        self.NeedShowTimeList:Clear()
    else
        self.NeedShowTimeList = List:New()
    end
    for i = 3, #_cloneMapIds do
        self.NeedShowTimeList:Add(_cloneMapIds[i])
    end
	self.AnimPlayer = L_UIAnimDelayPlayer:New(self.CSForm.AnimModule)
end

function UINewWorldBossForm:OnShowBefore()
    GameCenter.BossSystem:ReqAllWorldBossInfo(BossType.WorldBoss)
    self.CurBossType = BossType.WorldBoss
end

function UINewWorldBossForm:OnShowAfter()
     --self.CSForm:LoadTexture(self.ModelBotTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_b_wujixuyu"))
     self.CSForm:LoadTexture(self.FootBotTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_foot_boss"))
    self:UpdateTopLayerList()
    self.CurOCTime = 0
    local _serverTime = math.floor(GameCenter.HeartSystem.ServerZoneTime)
    local _hour, _min, _sec = L_TimeUtils.GetStampTimeHHMMSSNotZone(_serverTime)
    local _todayStartTime = _serverTime - _hour * 3600 - _min * 60 - _sec
    local _cloneMapIds = Utils.SplitNumber(DataConfig.DataGlobal[1764].Params, "_")
    --Open 02
    self.CloneStartTime = _todayStartTime + (_cloneMapIds[1] * 60)
    --End 10
    self.CloneEndTime = _todayStartTime + (_cloneMapIds[2] * 60)
    --Server time
    local _heartTime = _serverTime
    --The time at 2 o'clock the next day, used to calculate the closing countdown
    local _secondDayStartTime = self.CloneStartTime + 86400
    --The server time is displayed on 02-10 and countdown is enabled -- The countdown is based on 10 points
    --The closing countdown not displayed on 02-10 to the next 02
    self.WuxianBossOpenTime = 0
    self.WuxianBossCloseTime = 0
    if self.CloneStartTime <= _heartTime and _heartTime <= self.CloneEndTime then
        --Show on countdown
        self.WuxianBossOpenTime = self.CloneEndTime - _heartTime
    else
        --Show the countdown
        self.WuxianBossCloseTime = _secondDayStartTime - _heartTime
    end

    self.StartIndexShow = 1
    self.EndIndexShow = 3
end

function UINewWorldBossForm:OnHideBefore()
    self.UIListMenu:SetSelectByIndex(-1)
end

function UINewWorldBossForm:OnTryHide()
    if self.UIBossKillPanel.IsVisible then
        self.UIBossKillPanel:Hide()
        return false
    end
    return true
end

function UINewWorldBossForm:Update(dt)
    self.AnimPlayer:Update(dt)
    if self.StartRefreshTime then
        if self.CurTime > self.RefreshTimeOffset then
            self:RefreshLeftListTime()
            self.CurTime = 0
        else
            self.CurTime = self.CurTime + dt
        end
    end
    self:UpdateOpenCloseTime()
    
    if self:IsScrolling() then
        self:OnGridScroll()
    else
        UnityUtils.SetPosition(self.BossCloneRootGrid.transform, self.FirstGridPosX, self.BossCloneRootGrid.transform.position.y, self.BossCloneRootGrid.transform.position.z)
        self.CurGridPosX = self.FirstGridPosX
    end
end

function UINewWorldBossForm:IsScrolling()
    local currentX = self.BossCloneRootGrid.transform.position.x
    local isMoving = currentX ~= self.LastX
    self.LastX = currentX
    
    return isMoving
end

function UINewWorldBossForm:OnGridScroll()

    self.CurGridPosX = self.BossCloneRootGrid.transform.position.x

    if self.CurGridPosX < (self.FirstGridPosX + self.FirstGridPosX * 0.5) then
        if self.CurIndexShow < self.BossCount then

            UnityUtils.SetPosition(self.BossCloneRootGrid.transform, self.FirstGridPosX, self.BossCloneRootGrid.transform.position.y, self.BossCloneRootGrid.transform.position.z)
            self:OnClickRightBtn()
        end
    end

    if self.CurGridPosX > (self.FirstGridPosX - self.FirstGridPosX * 0.5) then
        if self.CurIndexShow <= self.BossCount and self.CurIndexShow > 1 then

            UnityUtils.SetPosition(self.BossCloneRootGrid.transform, self.FirstGridPosX, self.BossCloneRootGrid.transform.position.y, self.BossCloneRootGrid.transform.position.z)
            self:OnClickLeftBtn()
        end
    end
end
--------------------------------------------------------------------------------------------------------------------------------

------
-- Turn on and close time update
function UINewWorldBossForm:UpdateOpenCloseTime()
    -- This time is displayed only in infinite layers
    if self.IsInfinite and self.NeedShowTimeList:Contains(tonumber(self.CurCloneMapId)) then
        if self.WuxianBossOpenTime > 0 then
            local _time = self.WuxianBossOpenTime
            if _time ~= nil then
                if (self.CurOCTime < _time) then
                    self.CurOCTime = self.CurOCTime + Time.GetDeltaTime();
                    local _lostTime = _time - self.CurOCTime;
                    if _lostTime > 0 then
                        local _hour = math.modf((_lostTime % 86400) / 3600);
                        local _minute = math.modf(_lostTime % 3600 / 60);
                        local _second = math.modf(_lostTime % 3600 % 60);
                        UIUtils.SetTextByEnum(self.OpenCloseTime, "WuXianOpenTime", _hour, _minute, _second)
                        if not self.OpenCloseTime.gameObject.activeSelf then
                            self.OpenCloseTime.gameObject:SetActive(true)
                        end
                    end
                end
            end
        else
            if self.OpenCloseTime.gameObject.activeSelf then
                self.OpenCloseTime.gameObject:SetActive(false)
            end
        end

        if self.WuxianBossCloseTime > 0 then
            local _time = self.WuxianBossCloseTime
            if _time ~= nil then
                if (self.CurOCTime < _time) then
                    self.CurOCTime = self.CurOCTime + Time.GetDeltaTime();
                    local _lostTime = _time - self.CurOCTime;
                    if _lostTime > 0 then
                        local _hour = math.modf((_lostTime % 86400) / 3600);
                        local _minute = math.modf(_lostTime % 3600 / 60);
                        local _second = math.modf(_lostTime % 3600 % 60);
                        UIUtils.SetTextByEnum(self.OpenCloseTime, "WuXianCloseTime", _hour, _minute, _second)
                        if not self.OpenCloseTime.gameObject.activeSelf then
                            self.OpenCloseTime.gameObject:SetActive(true)
                        end
                    end
                end
            end
        else
            if self.OpenCloseTime.gameObject.activeSelf and self.WuxianBossOpenTime <= 0 then
                self.OpenCloseTime.gameObject:SetActive(false)
            end
        end
    else
        self.OpenCloseTime.gameObject:SetActive(false)
    end
end

function UINewWorldBossForm:SetFollowBoss(obj, sender)
    local _bossInfo = GameCenter.BossSystem.WorldBossInfoDic[self.CurSelectBossID]
    if _bossInfo then
        self.FollowSelectedGo:SetActive(_bossInfo.IsFollow)
    else
        self.FollowSelectedGo:SetActive(false)
    end
    self.CurSelectBossItem:SetFollow(self.FollowSelectedGo.activeSelf)
end

function UINewWorldBossForm:SetBossKillRecord(obj, sender)
    if obj then
        local _killedRecList = List:New()
        if obj.bossId == self.CurSelectBossID then
            if obj.killedRecordList and #obj.killedRecordList > 0 then
                --Sort
                for i = 1, #obj.killedRecordList do
                    _killedRecList:Add(obj.killedRecordList[i])
                end
                _killedRecList:Sort(function(a, b)
                    return a.killTime > b.killTime
                end)
            end
        end
        self.UIBossKillPanel:Show(_killedRecList)
    end
end

function UINewWorldBossForm:RefreshBossTime(obj, sender)
    self:OnLayerSelected(false, self.CurSelectLayer, true)
    self.StartRefreshTime = true
    self:SetRemainCount()
end

function UINewWorldBossForm:UpdateNormalReward(bossCfg)
    local _bossCfg = bossCfg
    local _rewardItemList = Utils.SplitStrByTableS(_bossCfg.Drop)
    local _occ = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
    local _index = 0
    for i = 1, #_rewardItemList do
        if _occ == tonumber(_rewardItemList[i][1]) then
            local _itemID = tonumber(_rewardItemList[i][2])
            local _go
            if _index < self.ItemCloneRoot.childCount then
                _go = self.ItemCloneRoot:GetChild(_index).gameObject
            else
                _go = UnityUtils.Clone(self.ItemCloneGo, self.ItemCloneRoot)
            end
            local _item = UILuaItem:New(_go.transform)
            if _item then
                _item:InItWithCfgid(_itemID, 0, false, false)
            end
            _go:SetActive(true)
            _index = _index + 1
        end
    end
    for i = _index, self.ItemCloneRoot.childCount - 1 do
        self.ItemCloneRoot:GetChild(i).gameObject:SetActive(false)
    end
    self.ItemCloneRootGrid.repositionNow = true
end

function UINewWorldBossForm:UpdateTask(obj, sender)
    --Judge whether the task has been completed
    local _isFinished1 = GameCenter.LuaTaskManager:IsMainTaskOver(990406)
    local _isFinished2 = GameCenter.LuaTaskManager:IsMainTaskOver(991141)
    --The task completion will only remove the novice layer
    if _isFinished1 then
        self.UIListMenu:RemoveIcon(self.LayerBossIDDic:GetKeys()[1])
    end
    if _isFinished2 then
        self.UIListMenu:RemoveIcon(self.LayerBossIDDic:GetKeys()[2])
    end
end

function UINewWorldBossForm:UpdateTopLayerList()
    self.UIListMenu:RemoveAll()
    local _lpLevel = GameCenter.GameSceneSystem:GetLocalPlayer().Level
    local _maxLv = 0
    local _index = 1
    self.LayerBossIDDic:SortKey(function(a, b) return a < b end)
    local _firstKey = self.LayerBossIDDic:GetKeys()[1]
    self.LayerBossIDDic:Foreach(function(key, value)
        local _newComerStr = DataConfig.DataMessageString.Get("C_XINSHOUCENG")
        --local _infiniteStr = DataConfig.DataMessageString.Get("NEWWORLDBOSS_INFINITELAYER")
        local _infiniteStr = DataConfig.DataMessageString.Get("BOSS_WORLD_WUXIANCENG")
        local _layerNumStr = DataConfig.DataMessageString.Get("NEWWORLDBOSS_LAYERNUM")

        local _bossCfg = DataConfig.DataBossnewWorld[value[1]]
        local _mapCfg = DataConfig.DataCloneMap[_bossCfg.CloneMap]
        local _limtLevel = CommonUtils.GetLevelDesc(_mapCfg.MinLv)
        -- Is it an infinite layer?
        local _isInfinite = _bossCfg.Infinite == 1
        -- Only used to show the level
        local _layerTitle = _bossCfg.Layer
        local _title = nil
        --Judge whether the task has been completed
        local _isFinished1 = GameCenter.LuaTaskManager:IsMainTaskOver(990406)
        local _isFinished2 = GameCenter.LuaTaskManager:IsMainTaskOver(991141)
        if key < 0 then
            _title = UIUtils.CSFormat(DataConfig.DataMessageString.Get("WorldBoss_Open_Level"), _newComerStr, _limtLevel)
        else
            if _isInfinite then
                _title = _infiniteStr
            else
                -- [OLD] -- Because the layer starts from -2,-1,0 (bossnew_world.xlsx) -> so +1
                -- _title = UIUtils.CSFormat(DataConfig.DataMessageString.Get("WorldBoss_Open_Level"), UIUtils.CSFormat(_layerNumStr, _layerTitle + 1), _limtLevel)

                -- [GOSU] Because delete boss page 2, layer -2,-1,0 (bossnew_world.xlsx) -> start from layer 1
                _title = UIUtils.CSFormat(DataConfig.DataMessageString.Get("WorldBoss_Open_Level"), UIUtils.CSFormat(_layerNumStr, _layerTitle), _limtLevel)
            end
        end
        self.UIListMenu:AddIcon(key, _title)
        --Judge whether the boss on the novice level has died
        if key < 0 and _isFinished1 and _index == 1 then
            self.UIListMenu:RemoveIcon(key)
            _firstKey = self.LayerBossIDDic:GetKeys()[_index + 1]
        elseif key < 0 and _isFinished2 and _index == 2 then
            self.UIListMenu:RemoveIcon(key)
            _firstKey = self.LayerBossIDDic:GetKeys()[_index + 1]
        else
            if self.Params ~= nil and DataConfig.DataBossnewWorld:IsContainKey(self.Params) then
                if DataConfig.DataBossnewWorld:IsContainKey(self.Params) then
                    if value:Contains(self.Params) then
                        -- Positioning to the current number of layers
                        self.CurSelectLayer = key
                        self.CurSelectLayerIndex = _index
                    end
                end
            else
                if _lpLevel <= 180 then
                    if key == _firstKey then
                        self.CurSelectLayer = key
                        self.CurSelectLayerIndex = _index
                    end
                else
                    local lv = _mapCfg.MinLv
                    if lv <= _lpLevel then
                        if lv > _maxLv then
                            self.CurSelectLayer = key
                            self.CurSelectLayerIndex = _index
                            _maxLv = lv
                        end
                    end
                end
            end
        end
        _index = _index + 1
    end)
    self.UIListMenu:SetSelectById(self.CurSelectLayer)
    self:SetRemainCount()


    self.CurLayerCount = _index - 1
    self:setShowPosLayerItem()
end

-- CUSTOM - đi đến vị trí mà item boss đang chọn trong 1 tầng
function UINewWorldBossForm:setShowPosLayerItem()
    local _index = 1
    local count = 0
    self.LayerBossIDDic:Foreach(function(key, value)
        if self.CurSelectLayer == key then
            self.CurSelectLayerIndex = _index
        end

        _index = _index + 1
        count = count + 1
    end)

    if count <= 5 then
        self.LayerScrollX = 0
    else

        if self.CurSelectLayerIndex == self.CurLayerCount then        
            self.LayerScrollX = 1
        else
            local GridWidth = self.LayerItemWidth * self.CurLayerCount
            self.LayerScrollX = ((self.CurSelectLayerIndex * self.LayerItemWidth - self.LayerItemWidth * 0.5) - self.LayerScrollViewWidth * 0.5) / (GridWidth - self.LayerScrollViewWidth)
        end

    end

    self.BossLayerScrollView:SetDragAmount(self.LayerScrollX, 0.0, false)

end
-- CUSTOM - đi đến vị trí mà item boss đang chọn trong 1 tầng

-- Synchronous ranking recovery time
function UINewWorldBossForm:UpDateRankTime()
    self:AddSuccess()
end

-- Added number returns
function UINewWorldBossForm:AddSuccess()
    self:SetRemainCount()
end

-- Whether to display the number of returns
function UINewWorldBossForm:SetBossCountShow()
    -- Description of countdown
    self.WuxianTimeDes.gameObject:SetActive(self.IsInfinite)
    self.EnterRewardGo:SetActive(not self.IsInfinite and self.CurSelectLayer > 0)
    -- self.AddCountBtn.gameObject:SetActive(not self.IsInfinite and self.CurSelectLayer > 0)

    --self.WuXianDes.gameObject:SetActive(self.IsInfinite)-- old code
    self.WuXianDes.gameObject:SetActive(self.IsInfinite)-- new code demo
    UIUtils.SetTextByEnum(self.WuXianDes, "WorldBoss_Count_UnLimit")
end

function UINewWorldBossForm:SetRemainCount()
    local _totalRankCount = GameCenter.BossSystem.WorldBossRankRewardMaxCount
    local _haveRewardCount = GameCenter.BossSystem.WorldBossReaminCount
    UIUtils.SetTextByEnum(self.EnterRewardCountLab, "Progress", _haveRewardCount, _totalRankCount)
    self.EnterRedPoint:SetActive(_haveRewardCount > 0 and not self.IsInfinite and self.CurSelectLayer > 0)

    -- CUSTOM - handle show/hide GotoBtn
    self.GotoBtnSpr.IsGray = self.IsHideGoToBtn
    self.EnterRedPoint:SetActive(not self.IsHideGoToBtn)
    -- CUSTOM - handle show/hide GotoBtn

    --Calculate the number of purchases red dots
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end
    local _curLevel = _lp.VipLevel
    if _curLevel < 0 then
        _curLevel = 0
    end
    local _addRedPoint = false
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
        local _curBuyCount = GameCenter.BossSystem.WorldBossAddCount
        if _curLevelCanBuy > _curBuyCount then
            _addRedPoint = true
        end
    end
    self.AddCountRedPoint:SetActive(_addRedPoint)
end

function UINewWorldBossForm:SetIndexValues(IsBtnClick, _dic)

    local _maxLv = 0
    local _lpLevel = GameCenter.GameSceneSystem:GetLocalPlayer().Level

    for i = 1, self.BossCount do

        local _bossId = _dic[i]
        local BossDatas = L_BossItemData:New(_bossId)
        local _bossLv = BossDatas.BossLv
        if _bossLv <= _lpLevel then
            if _bossLv > _maxLv then
                _maxLv = _bossLv
                self.CurIndexShow = i
            end
        end

    end

    if self.CurIndexShow == self.BossCount then
        if not IsBtnClick then
            if _maxLv > 0 then
                self.StartIndexShow = self.CurIndexShow
                self.EndIndexShow = self.CurIndexShow
            else
                self.CurIndexShow = 1
                self.StartIndexShow = 1
                self.EndIndexShow = self.CurIndexShow + 2
            end
        else
            self.CurIndexShow = self.StartIndexShow
        end
    else
        if _maxLv > 0 then
            if not IsBtnClick then
                self.StartIndexShow = self.CurIndexShow
                self.EndIndexShow = self.CurIndexShow + 2
                if self.EndIndexShow > self.BossCount then
                    self.EndIndexShow = self.BossCount
                end
            else
                self.CurIndexShow = self.StartIndexShow
            end
        else
            if not IsBtnClick then
                self.CurIndexShow = 1
                self.StartIndexShow = 1
                self.EndIndexShow = self.CurIndexShow + 2
            end
        end
    end

end

function UINewWorldBossForm:SetLeftBossList(layer, playAnim, IsBtnClick)

    self.CurSelectBossItem = nil
    self.CurBossData = nil
    local _dic = self.LayerBossIDDic[layer]
    self.BossCount = #_dic
    local _countIndex = 1
    local _maxLv = 0
    local _lpLevel = GameCenter.GameSceneSystem:GetLocalPlayer().Level

    self:SetIndexValues(IsBtnClick, _dic)

    self.ArrowLeftBtn.gameObject:SetActive(self.CurIndexShow > 1)
    self.ArrowRightBtn.gameObject:SetActive(self.EndIndexShow < self.BossCount)

    local _animList = nil
    if playAnim then
        _animList = List:New()
        self.AnimPlayer:Stop()
    end

    self.BossItemList = List:New()
    for i = 0, self.BossCloneRootGrid.transform.childCount - 1 do
        local _bossItem = L_BossItem:New(self.BossCloneRootGrid.transform:GetChild(i), self)
        self.BossItemList:Add(_bossItem)
    end
    local _bossItemCount = #self.BossItemList

    for i = 1, self.BossCount do
        if i >= self.StartIndexShow and i <= self.EndIndexShow then

            local _bossId = _dic[i]
            local BossDatas = L_BossItemData:New(_bossId)
            self.CurCloneMapId = BossDatas.CurCloneMapId
            -- Is it an infinite layer?
            self.IsInfinite = BossDatas.IsInfinite
            local _go = nil
            if _countIndex <= #self.BossItemList then
                _go = self.BossItemList[_countIndex]
            else
                _go = L_BossItem:New(UnityUtils.Clone(self.BossCloneGo).transform, self)
                -- _go.SingleClick = Utils.Handler(self.OnBossItemClick, self, _go)
                self.BossItemList:Add(_go)
            end
            if _go then
                _go:RefreshData(BossDatas)
                if not self.AnimPlayer.Playing then
                    _go:SetActive(true)

                    -- CUSTOM - check curBoss is timeout
                    -- if _go.BossInfo ~= nil then
                    --     if _go.Data.BossID == self.CurSelectBossID and _go.BossInfo.RefreshTime ~= nil then
                    --         self.IsHideGoToBtn = _go.BossInfo.RefreshTime > 0
                    --     end
                    -- end
                    -- CUSTOM - check curBoss is timeout

                end
                _go:SetSelected(false)

                --Determine which boss is currently located
                local _bossLv = BossDatas.BossLv
                if self.Params ~= nil and DataConfig.DataBossnewWorld:IsContainKey(self.Params) then
                    if DataConfig.DataBossnewWorld:IsContainKey(self.Params) then
                        if self.Params == _bossId then
                            -- Positioning to the current boss
                            self.CurSelectBossItem = _go
                        end
                    end
                else
                    if _bossLv <= _lpLevel then
                        if _bossLv > _maxLv then
                            _maxLv = _bossLv
                            -- self.CurSelectBossItem = _go
                            -- self.CurSelectBossIndex = i
                        end
                    end
                end

                -- CUSTOM - hiển thị VP hiếm PreciousDrop
                local _bossCfg = DataConfig.DataBossnewWorld[_bossId]
                local _career = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
                local _rewardItemList = Utils.SplitStrByTableS(_bossCfg.GoldDrop)
                local _rewardCount = #_rewardItemList

                --Set LuxuryDrop rewards
                local ItemCloneRootGrid = UIUtils.FindGrid(_go.Trans, "LuxuryDrop/Scroll View/ItemRoot")
                local ItemCloneRootScroll = UIUtils.FindScrollView(_go.Trans, "LuxuryDrop/Scroll View")
                local _itemGridTrans = UIUtils.FindTrans(_go.Trans, "LuxuryDrop/Scroll View/ItemRoot")
                local Item = nil
                local ItemList = List:New()
                for i = 0, _itemGridTrans.childCount - 1 do
                    Item = UILuaItem:New(_itemGridTrans:GetChild(i))
                    ItemList:Add(Item)
                end
                local _index = 1
                if _rewardCount > 0 then
                    for i = 1, _rewardCount do
                        local _occ = tonumber(_rewardItemList[i][1])
                        if (_career == 9) or (_occ == _career) then
                            local _itemID = tonumber(_rewardItemList[i][2])
                            local _item
                            if _index <= #ItemList then
                                _item = ItemList[_index]
                            else
                                _item = Item:Clone()
                                ItemList:Add(_item)
                            end
                            if _item then
                                _item.RootGO:SetActive(true)
                                _item:InItWithCfgid(_itemID)
                                _index = _index + 1
                                if _index > 6 then
                                    break
                                end
                            end
                        end
                    end
                    for i = _index, #ItemList do
                        ItemList[i].RootGO:SetActive(false)
                    end

                else
                    for i = 1, #ItemList do
                        ItemList[i].RootGO:SetActive(false)
                    end
                end
                -- CUSTOM - hiển thị VP hiếm PreciousDrop

                -- ẩn bậc + đồ quý > chỉ hiện khi item được selected
                local LuxuryDrop = UIUtils.FindTrans(self.BossItemList[_countIndex].Trans, "LuxuryDrop")
                LuxuryDrop.gameObject:SetActive(false)
                local StageGo = UIUtils.FindLabel(self.BossItemList[_countIndex].Trans, "Stage")
                StageGo.gameObject:SetActive(false)

                -- ItemCloneRootScroll.repositionWaitFrameCount = 3
                -- ItemCloneRootGrid.repositionNow = true

            end

            _countIndex = _countIndex + 1

            if playAnim then
                _animList:Add(_go.Trans)
            end

        end

    end

    --Hide the excess
    for i = _countIndex, #self.BossItemList do
        self.BossItemList[i]:SetActive(false)
    end
    self.BossCloneRootGrid:Reposition()
    self.BossCloneRootScrollView:ResetPosition()
    --Set the default selected boss
    if self.CurSelectBossItem ~= nil then
        self.CurBossData = self.CurSelectBossItem.Data
        self.CurSelectBossItem:SetSelected(true)
    else
        self.CurSelectBossItem = self.BossItemList[1]
        self.CurBossData = self.CurSelectBossItem.Data
        self.CurSelectBossItem:SetSelected(true)
    end
    self:OnClickLeftBoss()
    self:RefreshLeftListTime()

    if playAnim then
        for i = 1, #_animList do
            self.CSForm:RemoveTransAnimation(_animList[i])
            self.CSForm:AddAlphaPosAnimation(_animList[i], 0, 1, -50, 0, 0.3, false, false)
            self.AnimPlayer:AddTrans(_animList[i], (i - 1) * 0.075)
        end
        self.AnimPlayer:AddTrans(self.RightTrans, 0)
        self.AnimPlayer:Play()
    end
end

function UINewWorldBossForm:RefreshLeftListTime()
    local _count = #self.BossItemList
    for i = 1, _count do
        if self.BossItemList[i].Data ~= nil then
            local _bossId = self.BossItemList[i].Data.BossID
            local _bossInfo = GameCenter.BossSystem.WorldBossInfoDic[_bossId]
            self.BossItemList[i]:NewSetUpdateTime(_bossInfo, self.CurSelectLayer)
        end
    end
end
--------------------------------------------------------------------------------------------------------------------------------

------
-- Open the Add Times panel
function UINewWorldBossForm:OnClickAddCountBtn()
    GameCenter.PushFixEvent(UIEventDefine.UIBossAddCountForm_OPEN, BossType.WorldBoss)
end

--The click event of the boss on the left
function UINewWorldBossForm:OnBossItemClick(clickItem)
    if self.CurSelectBossItem ~= clickItem then
        clickItem:SetSelected(true)
        self.CurSelectBossItem:SetSelected(false)
        self.CurSelectBossItem = clickItem
        self.CurBossData = self.CurSelectBossItem.Data
        self:OnClickLeftBoss()
    end
end

function UINewWorldBossForm:OnClickLeftBtn()

    if self.CurIndexShow == self.BossCount then

        self.CurIndexShow = self.StartIndexShow
        self.StartIndexShow = self.StartIndexShow - 1
        self.CurIndexShow = self.CurIndexShow - 1

    elseif self.StartIndexShow == self.BossCount - 1 then

        self.StartIndexShow = self.StartIndexShow - 1
        self.CurIndexShow = self.CurIndexShow - 1
        self.EndIndexShow = self.BossCount

    else

        self.CurIndexShow = self.CurIndexShow - 1
        self.StartIndexShow = self.StartIndexShow - 1
        self.EndIndexShow = self.EndIndexShow - 1

    end

    self:SetLeftBossList(self.CurSelectLayer, true, true)

    self.ArrowLeftBtn.gameObject:SetActive(self.CurIndexShow > 1)

    self.ArrowRightBtn.gameObject:SetActive(self.CurIndexShow < self.BossCount)

end

function UINewWorldBossForm:OnClickRightBtn()

    self.CurIndexShow = self.CurIndexShow + 1
    self.StartIndexShow = self.StartIndexShow + 1

    if self.EndIndexShow < self.BossCount then
        self.EndIndexShow = self.EndIndexShow + 1
    else
        self.EndIndexShow = self.BossCount
    end

    self:SetLeftBossList(self.CurSelectLayer, true, true)

    self.ArrowLeftBtn.gameObject:SetActive(self.CurIndexShow > 1)

    self.ArrowRightBtn.gameObject:SetActive(self.CurIndexShow < self.BossCount)

end

function UINewWorldBossForm:OnClickFollowBtn()
    if GameCenter.BossSystem.WorldBossInfoDic:ContainsKey(self.CurSelectBossID) then
        local _isFollow = GameCenter.BossSystem.WorldBossInfoDic[self.CurSelectBossID].IsFollow
        GameCenter.BossSystem:ReqFollowBoss(self.CurSelectBossID, not _isFollow, self.CurBossType)
    end
end

function UINewWorldBossForm:OnClickKillRecordBtn()
    GameCenter.BossSystem:ReqBossKilledInfo(self.CurSelectBossID, self.CurBossType)

    -- CUSTOM - ẩn model + đồ hiếm khi show popup KillRecord
    local UIRoleSkinCompoent = UIUtils.FindTrans(self.CurSelectBossItem.Trans, "UIRoleSkinCompoent")
    UIRoleSkinCompoent.gameObject:SetActive(false)

    local LuxuryDrop = UIUtils.FindTrans(self.CurSelectBossItem.Trans, "LuxuryDrop")
    LuxuryDrop.gameObject:SetActive(false)
    -- CUSTOM - ẩn model + đồ hiếm khi show popup KillRecord
end

-- CUSTOM - hiện model khi show popup KillRecord tắt
function UINewWorldBossForm:OnCloseKillRecord()
    local UIRoleSkinCompoent = UIUtils.FindTrans(self.CurSelectBossItem.Trans, "UIRoleSkinCompoent")
    UIRoleSkinCompoent.gameObject:SetActive(true)

    local LuxuryDrop = UIUtils.FindTrans(self.CurSelectBossItem.Trans, "LuxuryDrop")
    LuxuryDrop.gameObject:SetActive(true)
end
-- CUSTOM - hiện model khi show popup KillRecord tắt

function UINewWorldBossForm:OnClickGotoBtn()

    if self.IsHideGoToBtn then
        Utils.ShowPromptByEnum("C_NOSS_ALREADY_DEAD")
    else
        local _bossCfg = GameCenter.BossSystem.WorldBossInfoDic[self.CurSelectBossID]
        if _bossCfg then
            GameCenter.BossSystem.CurSelectBossID = self.CurSelectBossID
            local _cloneCfg = DataConfig.DataCloneMap[_bossCfg.BossCfg.CloneMap]
            if GameCenter.MapLogicSystem.MapCfg.MapId == _cloneCfg.Mapid then
                local _posList = Utils.SplitStr(_bossCfg.BossCfg.Pos, "_")
                local _pos = Vector2(tonumber(_posList[1]), tonumber(_posList[2]))
                GameCenter.PathSearchSystem:SearchPathToPosBoss(true, _pos, self.CurSelectBossID)
                GameCenter.PushFixEvent(UIEventDefine.UIBossForm_CLOSE)
            else
                if _cloneCfg.MinLv > GameCenter.GameSceneSystem:GetLocalPlayerLevel() then
                    Utils.ShowPromptByEnum("CLONEENTERNEEDLEVEL", CommonUtils.GetLevelDesc(_cloneCfg.MinLv))
                else
                    if self.CurSelectLayer >= 0 then
                        if self.IsInfinite then
                            -- if self.CurOCTime < self.WuxianBossOpenTime then
                            --     Utils.ShowPromptByEnum("Daily_Not_In_Time")
                            --     return
                            -- end
                            GameCenter.DailyActivitySystem:ReqJoinActivity(20, _bossCfg.BossCfg.CloneMap)
                        else
                            GameCenter.DailyActivitySystem:ReqJoinActivity(4, _bossCfg.BossCfg.CloneMap)
                        end
                    else
                        if _bossCfg.IsKilled then
                            Utils.ShowPromptByEnum("C_NOSS_ALREADY_DEAD")
                        else
                            GameCenter.CopyMapSystem:ReqEnterCopyMap(_bossCfg.BossCfg.CloneMap);
                        end
                    end
                end
            end

            if _bossCfg.BossCfg.Mapnum < 0 then
                GameCenter.BISystem:ReqClickEvent(BiIdCode.WXSLGoNewPlayerLayer);
            elseif _bossCfg.BossCfg.Mapnum == 0 then
                GameCenter.BISystem:ReqClickEvent(BiIdCode.WXSLGo1NewPlayerLayer);
            elseif _bossCfg.BossCfg.Mapnum == 1 then
                GameCenter.BISystem:ReqClickEvent(BiIdCode.WXSLGo2NewPlayerLayer);
            elseif _bossCfg.BossCfg.Mapnum == 2 then
                GameCenter.BISystem:ReqClickEvent(BiIdCode.WXSLGo3NewPlayerLayer);
            elseif _bossCfg.BossCfg.Mapnum == 3 then
                GameCenter.BISystem:ReqClickEvent(BiIdCode.WJXYGo1Layer);
            elseif _bossCfg.BossCfg.Mapnum == 4 then
                GameCenter.BISystem:ReqClickEvent(BiIdCode.WJXYGo2Layer);
            elseif _bossCfg.BossCfg.Mapnum == 5 then
                GameCenter.BISystem:ReqClickEvent(BiIdCode.WJXYGo3Layer);
            elseif _bossCfg.BossCfg.Mapnum == 6 then
                GameCenter.BISystem:ReqClickEvent(BiIdCode.WJXYGo4Layer);
            elseif _bossCfg.BossCfg.Mapnum == 7 then
                GameCenter.BISystem:ReqClickEvent(BiIdCode.WJXYGo5Layer);
            elseif _bossCfg.BossCfg.Mapnum == 8 then
                GameCenter.BISystem:ReqClickEvent(BiIdCode.WJXYGo6Layer);
            end
        end
    end
end

function UINewWorldBossForm:OnLayerSelected(playAnim, layer, sender)
    self.CurSelectLayer = layer
    if sender then
        if self.LayerBossIDDic:ContainsKey(layer) then
            self.CurSelectBossIndex = 1
            self:SetLeftBossList(layer, playAnim, false)
            self:SetBossCountShow()
        end
    end

    self.BossLayerScrollView:ResetPosition()
    if self.CurLayerCount > 0 then
        self:setShowPosLayerItem(self.CurLayerCount)
    end
end

function UINewWorldBossForm:OnClickLeftBoss()
    local _bossID = self.CurBossData.BossID
    self.CurSelectBossID = _bossID
    local _bossCfg = DataConfig.DataBossnewWorld[_bossID]
    if _bossCfg then

        -- CUSTOM - set model
        for i = 1, #self.BossItemList do
            local HeadIconItem = UIUtils.FindSpr(self.BossItemList[i].Trans, "HeadIcon");
            HeadIconItem.gameObject:SetActive(true)
            local UIRoleSkinCompoentItem = UIUtils.FindTrans(self.BossItemList[i].Trans, "UIRoleSkinCompoent")
            UIRoleSkinCompoentItem.gameObject:SetActive(false)
        end

        local HeadIcon = UIUtils.FindSpr(self.CurSelectBossItem.Trans, "HeadIcon");
        local UIRoleSkinCompoent = UIUtils.FindTrans(self.CurSelectBossItem.Trans, "UIRoleSkinCompoent")
        local SkinComp = UIUtils.RequireUIRoleSkinCompoent(UIUtils.FindTrans(self.CurSelectBossItem.Trans, "UIRoleSkinCompoent"));
        if SkinComp then
            SkinComp:OnFirstShow(self.CSForm, FSkinTypeCode.Custom)
            local _monsterCfg = DataConfig.DataMonster[_bossID]
            if _monsterCfg then
                SkinComp:SetEquip(FSkinPartCode.Body, _monsterCfg.Res);
                SkinComp:SetLocalScale(_bossCfg.Size)
                if _bossCfg.ModelYPos then
                    SkinComp:SetSkinPos(Vector3(0, _bossCfg.ModelYPos / _bossCfg.Size , 0))
                end
            end
        end
        HeadIcon.gameObject:SetActive(false)
        UIRoleSkinCompoent.gameObject:SetActive(true)
        -- CUSTOM - set model

        -- hiện bậc + đồ quý khi item được selected
        local LuxuryDrop = UIUtils.FindTrans(self.CurSelectBossItem.Trans, "LuxuryDrop")
        LuxuryDrop.gameObject:SetActive(true)
        local StageGo = UIUtils.FindLabel(self.CurSelectBossItem.Trans, "Stage")
        StageGo.gameObject:SetActive(true)

        --Ordinary drop
        self:UpdateNormalReward(_bossCfg)

        -- Set the boss's model
        self.FollowBtn.gameObject:SetActive(_bossCfg.Mapnum >= 0)
        self.KillRecordBtn.gameObject:SetActive(_bossCfg.Mapnum >= 0)
        if _bossCfg.Mapnum >= 0 then
            local _bossInfo = GameCenter.BossSystem.WorldBossInfoDic[_bossID]
            if _bossInfo then
                self.FollowSelectedGo:SetActive(_bossInfo.IsFollow)
            else
                self.FollowSelectedGo:SetActive(false)
            end
            self.CurSelectBossItem:SetFollow(self.FollowSelectedGo.activeSelf)
        end
    end
    -- CUSTOM - check and handle curBoss is timeout + enough level
    -- local _bossCfg = GameCenter.BossSystem.WorldBossInfoDic[_bossID]
    -- if _bossCfg then
    --     local _cloneCfg = DataConfig.DataCloneMap[_bossCfg.BossCfg.CloneMap]

    --     if _cloneCfg.MinLv > GameCenter.GameSceneSystem:GetLocalPlayerLevel() then
    --         self.GotoBtnSpr.IsGray = true
    --         self.EnterRedPoint:SetActive(false)
    --     else
    --         if self.CurSelectBossItem.Data.BossID == self.CurSelectBossID and _bossCfg.RefreshTime then
    --             self.IsHideGoToBtn = _bossCfg.RefreshTime > 0
    --             self.GotoBtnSpr.IsGray = self.IsHideGoToBtn
    --             self.EnterRedPoint:SetActive(not self.IsHideGoToBtn)
    --         else
    --             self.IsHideGoToBtn = false
    --             self.GotoBtnSpr.IsGray = false
    --             self.EnterRedPoint:SetActive(true)
    --         end
    --     end
    -- end
    -- CUSTOM - check and handle curBoss is timeout + enough level

end
--------------------------------------------------------------------------------------------------------------------------------

------
function UINewWorldBossForm:FindAllComponents()
    local _myTrans = self.Trans
    self.LeftTrs = UIUtils.FindTrans(_myTrans, "Left")
    local _leftTrs = self.LeftTrs
    self.BossCloneGo = UIUtils.FindGo(_leftTrs, "BossRoot/Grid/BossClone")
    self.BossCloneRoot = UIUtils.FindTrans(_leftTrs, "BossRoot")
    -- self.BossCloneRoot:DisableSpring()
    self.BossCloneRootGrid = UIUtils.FindGrid(_leftTrs, "BossRoot/Grid")
    self.FirstGridPosX = self.BossCloneRootGrid.transform.position.x
    
    self.BossCloneRootScrollView = UIUtils.FindScrollView(_leftTrs, "BossRoot")
    self.BossItemList = List:New()
    for i = 0, self.BossCloneRootGrid.transform.childCount - 1 do
        local _bossItem = L_BossItem:New(self.BossCloneRootGrid.transform:GetChild(i), self)
        -- _bossItem.SingleClick = Utils.Handler(self.OnBossItemClick, self, _bossItem)
        self.BossItemList:Add(_bossItem)
    end
    self.CenterTrs = UIUtils.FindTrans(_myTrans, "Center")
    self.RightTrans = UIUtils.FindTrans(_myTrans, "Right")
    local _centerTrs = self.CenterTrs
    local _rightTrs = self.RightTrans
    self.ItemCloneGo = UIUtils.FindGo(_rightTrs, "EquipDrop/Scroll View/ItemRoot/ItemClone")
    self.ItemCloneRoot = UIUtils.FindTrans(_rightTrs, "EquipDrop/Scroll View/ItemRoot")
    self.ItemCloneRootGrid = UIUtils.FindGrid(_rightTrs, "EquipDrop/Scroll View/ItemRoot")
    self.LuxItemCloneGo = UIUtils.FindGo(_rightTrs, "LuxuryDrop/Scroll View/ItemRoot/ItemClone")
    self.LuxItemCloneRoot = UIUtils.FindTrans(_rightTrs, "LuxuryDrop/Scroll View/ItemRoot")
    self.LuxItemCloneRootGrid = UIUtils.FindGrid(_rightTrs, "LuxuryDrop/Scroll View/ItemRoot")
    self.FollowBtn = UIUtils.FindBtn(_centerTrs, "Follow")
    self.FollowSelectedGo = UIUtils.FindGo(_centerTrs, "Follow/selected")
    self.KillRecordBtn = UIUtils.FindBtn(_rightTrs, "KillRecordBtn")

    self.UIBossKillPanel = L_UIBossKillPanel:OnFirstShow( UIUtils.FindTrans(_centerTrs, "KillRecordPanel"), self)
    self.BossSkin = UIUtils.RequireUIRoleSkinCompoent(UIUtils.FindTrans(_centerTrs, "UIRoleSkinCompoent"))
    self.BossSkin:OnFirstShow(self.CSForm, FSkinTypeCode.Monster);
    local _bottomTrs = UIUtils.FindTrans(_myTrans, "Bottom")
    self.UIListMenu = UIListMenu:OnFirstShow(self.CSForm,
                          UIUtils.FindTrans(self.Trans, "Bottom/Scroll View/UIListMenuTop"))
    self.UIListMenu:ClearSelectEvent();
    self.UIListMenu:AddSelectEvent(Utils.Handler(self.OnLayerSelected, self, true))

    self.BossLayerScrollView = UIUtils.FindScrollView(self.Trans, "Bottom/Scroll View")

    self.UIListMenu.IsHideIconByFunc = true
    self.WuXianDes = UIUtils.FindLabel(_myTrans, "Right/WuXianDes")
    self.EnterRewardGo = UIUtils.FindGo(_myTrans, "Right/EnterRewardCount")
    self.EnterRewardCountLab = UIUtils.FindLabel(_myTrans, "Right/EnterRewardCount/Label")
    self.EnterRedPoint = UIUtils.FindGo(_myTrans, "Right/GoBtn/RedPoint")
    self.GotoBtn = UIUtils.FindBtn(_myTrans, "Right/GoBtn")
    self.GotoBtnSpr = UIUtils.FindSpr(_myTrans, "Right/GoBtn")
    self.ModelBotTexture = UIUtils.FindTex(_myTrans, "Center/ModelBotTexture")
    self.FootBotTexture = UIUtils.FindTex(_myTrans, "Center/FootBotTexture")
    self.AddCountBtn = UIUtils.FindBtn(_myTrans, "Right/AddCount")
    self.AddCountRedPoint = UIUtils.FindGo(_myTrans, "Right/AddCount/RedPoint")

    self.RemainCountLabel = UIUtils.FindLabel(_myTrans, "Right/RemainTime")
    self.RemainCountLabel.gameObject:SetActive(false)

    self.WuxianTimeDes = UIUtils.FindLabel(_myTrans, "Right/WuxianTimeDes")

    self.OpenCloseTime = UIUtils.FindLabel(_bottomTrs, "OpenCloseTime")
    self.OpenCloseTime.gameObject:SetActive(false)
    self.CSForm:AddAlphaPosAnimation(_rightTrs, 0, 1, 50, 0, 0.3, false, false)

    self.ArrowLeftBtn = UIUtils.FindBtn(_myTrans, "ArrowLeftBtn")
    self.ArrowRightBtn = UIUtils.FindBtn(_myTrans, "ArrowRightBtn")
end

return UINewWorldBossForm
