-- ==============================--
-- author:
-- Date: 2020-02-19 17:15:23
-- File: UIXMBossForm.lua
-- Module: UIXMBossForm
-- Description: Xianmeng Boss main form
-- ==============================--
local UIToggleGroup = require("UI.Components.UIToggleGroup");
local UIXMBossForm = {
    TxtName = nil,
    TxtTime = nil,
    SliderHpPro = nil,
    TxtHpPro = nil,
    BtnRule = nil,
    BtnXMRank = nil,
    BtnPersonRank = nil,
    BtnGo = nil,
    OpenTime = 0,
    CloseTime = 0,
    RuleModule = nil,
    XMRankModule = nil,
    PersonRankModule = nil,
    StateToggleGroup = nil
}

-- Status switch group
local L_StateToggleProp = nil;

-- Register event function, provided to the CS side to call.
function UIXMBossForm:OnRegisterEvents()
    self:RegisterEvent(UILuaEventDefine.UIXMBossForm_OPEN, self.OnOpen);
    self:RegisterEvent(UILuaEventDefine.UIXMBossForm_CLOSE, self.OnClose);
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_XMBOSS_REFRSH, self.Refresh)
end

-- The first display function is provided to the CS side to call.
function UIXMBossForm:OnFirstShow()
    self:FindAllComponents();
    self:RegUICallback();
    self.Init = true;
end

-- The callback function that binds the UI component
function UIXMBossForm:RegUICallback()
    UIUtils.AddBtnEvent(self.BtnGo, self.OnClickBtnGoCallBack, self);
end

--Player model
function UIXMBossForm:FindAllComponents()
    local _myTrans = self.Trans;

    -- self.TexBg = UIUtils.FindTex(_myTrans, "Root/Left/Texture");
    self.TxtName = UIUtils.FindLabel(_myTrans, "Root/Left/TxtName");
    self.GoTimeTitle = UIUtils.FindGo(_myTrans, "Root/Left/TxtTimeTitle");
    self.TxtTime = UIUtils.FindLabel(_myTrans, "Root/Left/TxtTime");
    self.SliderHpPro = UIUtils.FindSlider(_myTrans, "Root/Left/HpPro");
    self.TxtHpPro = UIUtils.FindLabel(_myTrans, "Root/Left/HpPro/Label");
    self.BossSkin = UIUtils.RequireUIRoleSkinCompoent(UIUtils.FindTrans(_myTrans, "Root/Left/UIRoleSkin"))
    self.BossSkin:OnFirstShow(self.CSForm, FSkinTypeCode.Monster);
    self.BtnGo = UIUtils.FindBtn(_myTrans, "Root/Right/BtnGo");
    self.GobjBtnGoRedpoint = UIUtils.FindGo(_myTrans, "Root/Right/BtnGo/RedPoint");

    self.StateToggleGroup = UIToggleGroup:New(self, UIUtils.FindTrans(_myTrans, "Root/Right/TopBtns/Grid"), 2099, L_StateToggleProp);

    self.GoRuleRoot = UIUtils.FindGo(_myTrans, "Root/Right/Rule");
    self.GoXMRankRoot = UIUtils.FindGo(_myTrans, "Root/Right/XMRank");
    self.GoPersonRankRoot = UIUtils.FindGo(_myTrans, "Root/Right/PersonRank");

    self.RuleModule = self:GetRuleModule(self.GoRuleRoot);
    self.XMRankModule = self:GetRankModule(self.GoXMRankRoot);
    self.PersonRankModule = self:GetRankModule(self.GoPersonRankRoot);
    self.CSForm:AddAlphaPosAnimation(UIUtils.FindTrans(_myTrans, "Root/Right"), 0, 1, 30, 0, 0.3, true, false)
end

-- Display the previous operation and provide it to the CS side to call.
function UIXMBossForm:OnShowBefore()
    self:SetBossInfo(GameCenter.XMBossSystem.BossID)
    -- self.CSForm:LoadTexture(self.TexBg, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_z_4"));
end

-- The operation after display is provided to the CS side to call.
function UIXMBossForm:OnShowAfter()
    -- Right:
    self.State = 1
    self.StateToggleGroup:Refresh();
    self:Refresh()
end

-- [Interface button callback begin]-
function UIXMBossForm:OnClickBtnGoCallBack()
    -- ebug.Log("OnClickBtnGoCallBack",self.OpenTime,GameCenter.HeartSystem.ServerTime)
    if GameCenter.GameSceneSystem.ActivedScene.MapId == 2021 then
        Utils.ShowPromptByEnum("InCopyMap")
        return
    end

    local _curMapType = GameCenter.MapLogicSystem.MapCfg.Type;
    if _curMapType == UnityUtils.GetObjct2Int(MapTypeDef.Copy) or _curMapType == UnityUtils.GetObjct2Int(MapTypeDef.CrossCopy) then
        Utils.ShowPromptByEnum("C_LEAVE_COPY_TIPS")
        return
    end

    self:EnterActivityMap()
end

-- Enter the event map
function UIXMBossForm:EnterActivityMap()
    local _curMapType = GameCenter.MapLogicSystem.MapCfg.Type;
    if self.OpenTime > GameCenter.HeartSystem.ServerTime then
        Utils.ShowMsgBox(function(code)
            if code == MsgBoxResultCode.Button2 then
                GameCenter.Network.Send("MSG_Guild.ReqGuildBaseEnter", {})
            end
        end, "EnterXMMapTips")
    else
        GameCenter.XMBossSystem.IsFindPath = true;
        Utils.ShowMsgBox(function(code)
            if (code == MsgBoxResultCode.Button2) then
                GameCenter.Network.Send("MSG_Guild.ReqGuildBaseEnter", {})
            end
        end, "C_GUILD_ENTERBASE_CONFIRM")
    end
end
---[Interface button callback end]---

-- Set the boss model
function UIXMBossForm:SetBossInfo(bossID)
    local _monsterCfg = nil
    if DataConfig.DataMonster:IsContainKey(bossID) then
        _monsterCfg = DataConfig.DataMonster[bossID]
    end

    -- Set the boss's model
    self.BossSkin:ResetSkin();

    if _monsterCfg then
        UIUtils.SetTextByStringDefinesID(self.TxtName, _monsterCfg._Name)
        self.BossSkin:SetEquip(FSkinPartCode.Body, _monsterCfg.Res);
        --Set ModelRoot Scaling Size
        self.BossSkin:SetLocalScale(140)
        self.BossSkin:SetSkinRot(Vector3(0, 0, 0))
    else
        -- Debug.LogError("Monster table not found" .. bossID)
    end
end

-- Refresh the interface
function UIXMBossForm:Refresh()
    -- Debug.LogError("===============[Refresh]======================= 1")
    if not self.Init then
        return
    end
    -- Debug.LogError("===============[Refresh]======================= 2")
    -- Left:
    self:RefreshLeft()
    -- Right side
    self:RefreshRight()
    -- Little Red Dot
    self.GobjBtnGoRedpoint:SetActive(GameCenter.XMBossSystem:IsRepoint())
end

function UIXMBossForm:RefreshLeft()
    local _MsgOCTimeData = GameCenter.XMBossSystem.MsgOCTimeData;
    if _MsgOCTimeData then
        local _ServerTime = GameCenter.HeartSystem.ServerTime;
        self.OpenTime = _MsgOCTimeData.openTime;
        self.CloseTime = _MsgOCTimeData.closeTime;
        self.ActivityTotalTime = self.CloseTime - self.OpenTime;
        self.IsUpdateTime = _ServerTime < self.OpenTime;
        self.TxtTime.gameObject:SetActive(self.IsUpdateTime);
        self.GoTimeTitle:SetActive(self.IsUpdateTime);
        self.SliderHpPro.gameObject:SetActive(not self.IsUpdateTime);
    else
        -- Debug.LogError("==================[No time data]================================== 2")
    end
end

function UIXMBossForm:RefreshRight()
    local _MsgPannelData = GameCenter.XMBossSystem.MsgPannelData;
    if _MsgPannelData then
        if self.State == 2 then
            self:SetXMRankData(_MsgPannelData.guildInfo)
        elseif self.State == 3 then
            self:SetPersonRankData(_MsgPannelData.personInfo)
        end
    else
        -- Error("==================[No ranking data]=============================== 2")
    end
    if self.State == 1 then
        self:SetRoleData();
    end
end

function UIXMBossForm:Update(dt)
    if self.IsUpdateTime then
        local _remaindTime = self.OpenTime - GameCenter.HeartSystem.ServerTime;
        -- Debug.LogError("OpenTime = ",self.OpenTime,"ServerTime = ",GameCenter.HeartSystem.ServerTime,"remaindTime",_remaindTime);
        if _remaindTime <= 0 then
            self.IsUpdateTime = false;
            self:RefreshLeft();
        else
            UIUtils.SetTextHHMMSS(self.TxtTime, math.floor(_remaindTime))
        end
    elseif self.CloseTime and self.ActivityTotalTime then
        local _progress = math.floor((self.CloseTime - GameCenter.HeartSystem.ServerTime) * 100 // self.ActivityTotalTime)
        _progress = _progress > 0 and _progress or 0;
        self.SliderHpPro.value = _progress / 100
        UIUtils.SetTextByEnum(self.TxtHpPro, "Percent", _progress)
    end
end

function UIXMBossForm:GetRuleModule(gobj)
    local _trans = gobj.transform
    local _m = {
        -- TxtTimeDes = UIUtils.FindLabel(_trans, "TxtTimeDes"),
        -- TxtRuleDes = UIUtils.FindLabel(_trans, "TxtRuleDes"),
        UIGridRoot = UIUtils.FindGrid(_trans, "Rewards/Grid"),
        TfItemParent = UIUtils.FindTrans(_trans, "Rewards/Grid"),
        GoItemBase = UIUtils.FindGo(_trans, "Rewards/Grid/UIItem1"),
        UIScroll = UIUtils.FindScrollView(_trans, "Rewards"),
        ItemList = List:New()
    }
    _m.ItemList:Add(self:CreatItem(_m.GoItemBase, _m.TfItemParent, true))
    return _m;
end

function UIXMBossForm:CreatItem(gobj, tfParent, isBase)
    local _gobj = isBase and gobj or UnityUtils.Clone(gobj, tfParent);
    local _uiItem = UILuaItem:New(_gobj.transform)
    return {
        Gobj = _gobj,
        UIItem = _uiItem,
        GobjAuction = UIUtils.FindGo(_gobj.transform, "SprAuction")
    }
end

function UIXMBossForm:SetRoleData()
    local _m = self.RuleModule;
    local _worldLevel = GameCenter.OfflineOnHookSystem.CurWorldLevel;
    local _auctionRewards = nil
    local _personalReward = nil
    local function _forFunc(key, value)
        local _dataItem = value;
        local strArr = Utils.SplitNumber(_dataItem.WorldLevel, "_");
        if _worldLevel >= strArr[1] and _worldLevel <= strArr[2] then
            _auctionRewards = Utils.SplitNumber(_dataItem.PaipinShow, "_");
            _personalReward = Utils.SplitNumber(_dataItem.RewardShow, "_")
        end
    end
    DataConfig.DataGuildBossReward:Foreach(_forFunc)

    -- Set lot rewards
    local _auctionRewardCount = _auctionRewards and #_auctionRewards or 0
    local _personalRewardCount = _personalReward and #_personalReward or 0
    local _totalCnt = _auctionRewardCount + _personalRewardCount;
    for i = 1, _auctionRewardCount do
        local _item = _m.ItemList[i];
        if not _item then
            _item = self:CreatItem(_m.GoItemBase, _m.TfItemParent);
            _m.ItemList:Add(_item)
        end
        _item.Gobj:SetActive(true)
        _item.UIItem:InItWithCfgid(_auctionRewards[i], 1, false, false)
        _item.GobjAuction:SetActive(true)
    end

    -- Set rewards
    for i = _auctionRewardCount + 1, _totalCnt do
        local _item = _m.ItemList[i];
        if not _item then
            _item = self:CreatItem(_m.GoItemBase, _m.TfItemParent);
            _m.ItemList:Add(_item)
        end
        _item.Gobj:SetActive(true)
        _item.UIItem:InItWithCfgid(_personalReward[i - _auctionRewardCount], 1, false, false)
        _item.GobjAuction:SetActive(false)
    end

    -- Hide the excess
    self:HideNeedless(_m.ItemList, _totalCnt)
    _m.UIGridRoot:Reposition();
    _m.UIScroll:ResetPosition();
end

function UIXMBossForm:GetRankModule(gobj)
    local _trans = gobj.transform
    local _m = {
        TxtRank = UIUtils.FindLabel(_trans, "TxtRank"),
        TxtDamage = UIUtils.FindLabel(_trans, "TxtDamage"),
        UIGridRoot = UIUtils.FindGrid(_trans, "ScrollView/Grid"),
        TfItemParent = UIUtils.FindTrans(_trans, "ScrollView/Grid"),
        GoItemBase = UIUtils.FindGo(_trans, "ScrollView/Grid/Item"),
        UIScroll = UIUtils.FindScrollView(_trans, "ScrollView"),
        RankItemList = List:New()
    }
    _m.RankItemList:Add(self:CreatRankItem(_m.GoItemBase, _m.TfItemParent, true))
    return _m;
end

-- Create a ranking element
function UIXMBossForm:CreatRankItem(gobj, tfParent, isBase)
    local _gobj = isBase and gobj or UnityUtils.Clone(gobj, tfParent);
    local _tf = _gobj.transform;
    return {
        Gobj = _gobj,
        Trans = _tf,
        TxtName = UIUtils.FindLabel(_tf, "TxtName"),
        TxtCount = UIUtils.FindLabel(_tf, "TxtCount"),
        GobjSprRank1 = UIUtils.FindGo(_tf, "SprRank1"),
        GobjSprRank2 = UIUtils.FindGo(_tf, "SprRank2"),
        GobjSprRank3 = UIUtils.FindGo(_tf, "SprRank3"),
        GobjTxtRank = UIUtils.FindGo(_tf, "TxtRank"),
        TxtRank = UIUtils.FindLabel(_tf, "TxtRank")
    }
end

-- Set ranking information (Xianlian, individual)
function UIXMBossForm:SetRankData(data, myModule, id)
    local _m = myModule;
    UIUtils.SetTextByEnum(_m.TxtRank, "C_FRIEND_NOGUILD")
    UIUtils.SetTextByNumber(_m.TxtDamage, 0);
    if data then
        for i = 1, #data do
            local _item = _m.RankItemList[i];
            if not _item then
                _item = self:CreatRankItem(_m.GoItemBase, _m.TfItemParent);
                _m.RankItemList:Add(_item)
            end
            _item.Gobj:SetActive(true)
            UIUtils.SetTextByString(_item.TxtName, data[i].name)
            UIUtils.SetTextByNumber(_item.TxtCount, data[i].damage, true, 4)
            UIUtils.SetTextByNumber(_item.TxtRank, i)
            _item.GobjSprRank1:SetActive(i == 1);
            _item.GobjSprRank2:SetActive(i == 2);
            _item.GobjSprRank3:SetActive(i == 3);
            _item.GobjTxtRank:SetActive(i > 3);
            if data[i].id == id then
                UIUtils.SetTextByNumber(_m.TxtRank, i)
                UIUtils.SetTextByNumber(_m.TxtDamage, data[i].damage, true, 4)
            end
        end
    end

    -- Hide the excess
    self:HideNeedless(_m.RankItemList, data and #data or 0)
    _m.UIGridRoot:Reposition();
    _m.UIScroll:ResetPosition()
end

-- Set the Xianmeng Ranking Interface
function UIXMBossForm:SetXMRankData(data)
    local _myGuildID = GameCenter.GameSceneSystem:GetLocalPlayer().PropMoudle.GuildId
    self:SetRankData(data, self.XMRankModule, _myGuildID)
end

-- Set up a personal ranking interface
function UIXMBossForm:SetPersonRankData(data)
    local _id = GameCenter.GameSceneSystem:GetLocalPlayerID()
    self:SetRankData(data, self.PersonRankModule, _id)
end

-- Hide the excess
function UIXMBossForm:HideNeedless(list, showCnt)
    local _listCnt = list:Count()
    local _needHideCnt = _listCnt - showCnt
    for i = _listCnt, _listCnt - _needHideCnt + 1, -1 do
        list[i].Gobj:SetActive(false)
    end
end

-- Set the status switch
function UIXMBossForm:SetState(val)
    self.State = val;
    self.GoRuleRoot:SetActive(val == 1)
    self.GoXMRankRoot:SetActive(val == 2)
    self.GoPersonRankRoot:SetActive(val == 3)
    self:RefreshRight()
end

-- Properties of the status switch
L_StateToggleProp = {
    [1] = {
        Get = function()
            return UIXMBossForm.State == 1;
        end,
        Set = function(checked)
            if checked then
                UIXMBossForm:SetState(1);
            end
        end
    },
    [2] = {
        Get = function()
            return UIXMBossForm.State == 2;
        end,
        Set = function(checked)
            if checked then
                UIXMBossForm:SetState(2);
            end
        end
    },
    [3] = {
        Get = function()
            return UIXMBossForm.State == 3;
        end,
        Set = function(checked)
            if checked then
                UIXMBossForm:SetState(3);
            end
        end
    }
};

return UIXMBossForm;
