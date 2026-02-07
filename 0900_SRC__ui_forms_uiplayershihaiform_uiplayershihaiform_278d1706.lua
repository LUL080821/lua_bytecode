------------------------------------------------
--author:
--Date: 2019-05-06
--File: UIPlayerShiHaiForm.lua
--Module: UIPlayerShiHaiForm
--Description: Character Realm Interface
------------------------------------------------

local CommonPanelRedPoint = require "Logic.Nature.Common.CommonPanelRedPoint"
local L_UIAnimDelayPlayer = require "UI.Components.UIAnimDelayPlayer"

--//Module definition
local UIPlayerShiHaiForm = {
    --Background picture
    BackTex = nil,
    --Current level
    CurLevel = nil,
    --Next level
    NextLevel = nil,
    FullLevel = nil,
    --Current combat power
    CurFightPower = nil,
    --Properties Table
    PropTable = nil,
    --Demand the number of levels of the Wan Yao scroll
    NeedCopyLevel = nil,
    --Go to Wan Yao Roll Button
    GoToCopyBtn = nil,
    --Require props
    NeedItems = nil,
    --Upgrade button
    LevelUpBtn = nil,
    --Red dot component
    RedPointCom = nil,
    --Full level
    MaxLevelGo = nil,

    --Peripheral light column special effects
    GuangVfxs = nil,
    --The special effect of the middle sword
    JianVfx = nil,
    JianActiveVfx = nil,
    --The level of the last refresh
    FrontFreshLevel = 0,
    FrontJianVfxId = 0,

    Grid = nil,
    CurTitleSpr = nil,
    NextTitleSpr = nil,
    JianTouGo = nil,
};

--Inherit the Form function
function UIPlayerShiHaiForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UIPlayerShiHaiForm_OPEN, self.OnOpen);
    self:RegisterEvent(UIEventDefine.UIPlayerShiHaiForm_CLOSE, self.OnClose);
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_PLAYER_SHIHAI, self.OnRefreshPage);
end

local UIVfxItem  = nil
local VFXState = nil

function UIPlayerShiHaiForm:OnFirstShow()
    self.BackTex = UIUtils.FindTex(self.Trans, "BackTex");
    self.CurLevel = UIUtils.FindLabel(self.Trans, "Right/CurLevel");
    self.NextLevel = UIUtils.FindLabel(self.Trans, "Right/NextLevel");
    self.FullLevel = UIUtils.FindLabel(self.Trans, "Right/FullLevel");
    self.CurFightPower = UIUtils.FindLabel(self.Trans, "BackTex/FightPower/Value");
    self.PropTable = {};
    for i = 1, 5 do
        self.PropTable[i] = {};
        self.PropTable[i].RootGo = UIUtils.FindGo(self.Trans, string.format("Right/Pro%d", i));
        self.PropTable[i].Name = UIUtils.FindLabel(self.Trans, string.format("Right/Pro%d/Name", i));
        self.PropTable[i].Value = UIUtils.FindLabel(self.Trans, string.format("Right/Pro%d/Value", i));
        self.PropTable[i].AddValue = UIUtils.FindLabel(self.Trans, string.format("Right/Pro%d/AddValue", i));
        self.PropTable[i].AddGo = UIUtils.FindGo(self.Trans, string.format("Right/Pro%d/AddSpr", i));
    end
    self.NeedCopyLevel = UIUtils.FindLabel(self.Trans, "Right/NeedCopy");
    self.GoToCopyBtn = UIUtils.FindBtn(self.Trans, "Right/GoToBtn");
    UIUtils.AddBtnEvent(self.GoToCopyBtn, self.OnGoToBtnClick, self)
    self.NeedItems = {};
    self.NeedItems[1] = UILuaItem:New(UIUtils.FindTrans(self.Trans, "Right/UIItem"));
    self.LevelUpBtn = UIUtils.FindBtn(self.Trans, "Right/LevelUp");
    UIUtils.AddBtnEvent(self.LevelUpBtn, self.OnLevelUPBtnClick, self)

    self.RedPointCom = CommonPanelRedPoint:New();
    self.RedPointCom:Add(FunctionStartIdCode.PlayerJingJie, self.LevelUpBtn.transform, 0, false)

    self.GuangVfxs = {}
    for i = 1, 9 do
        local vfx = UIUtils.RequireUIVfxSkinCompoent(UIUtils.FindTrans(self.Trans, string.format("BackTex/%d/Vfx", i)))
        local vfxEx = UIUtils.RequireUIVfxSkinCompoent(UIUtils.FindTrans(self.Trans, string.format("BackTex/%d/ExVfx", i)))
        self.GuangVfxs[i] = UIVfxItem:New(vfx, vfxEx)
    end
    self.JianVfx = UIUtils.RequireUIVfxSkinCompoent(UIUtils.FindTrans(self.Trans, "BackTex/JianVfx"))
    self.JianActiveVfx = UIUtils.RequireUIVfxSkinCompoent(UIUtils.FindTrans(self.Trans, "BackTex/JianActiveVfx"))
    self.MaxLevelGo = UIUtils.FindGo(self.Trans, "Right/MaxLevel")
    self.Grid = UIUtils.FindGrid(self.Trans, "BackTex/Grid")
    self.CurTitleSpr = UIUtils.FindSpr(self.Trans, "BackTex/Grid/Cur")
    self.NextTitleSpr = UIUtils.FindSpr(self.Trans, "BackTex/Grid/Next")
    self.JianTouGo = UIUtils.FindGo(self.Trans, "BackTex/Grid/JianTou")
    self.CenterTrans = self.BackTex.transform
	self.CSForm:AddAlphaScaleAnimation(self.CenterTrans, 0, 1, 1.1, 1.1, 1, 1, 0.3, false, false)
    self.RightTrans = UIUtils.FindTrans(self.Trans, "Right")
    self.CSForm:AddAlphaPosAnimation(self.RightTrans, 0, 1, 50, 0, 0.3, false, false)
	self.AnimPlayer = L_UIAnimDelayPlayer:New(self.CSForm.AnimModule)
end

function UIPlayerShiHaiForm:OnShowBefore()
    self.RedPointCom:Initialize()
end

function UIPlayerShiHaiForm:OnShowAfter()
    GameCenter.PlayerShiHaiSystem:ReqShiHaiData()
    self.FrontFreshLevel = GameCenter.PlayerShiHaiSystem.CurCfgID % 10
    self.FrontJianVfxId = 0
    self:OnRefreshPage(nil, nil)
    self.CSForm:LoadTexture(self.BackTex,AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_b_shihai"))
    self.AnimPlayer:Stop()
    self.AnimPlayer:AddTrans(self.CenterTrans, 0)
    self.AnimPlayer:AddTrans(self.RightTrans, 0)
    self.AnimPlayer:Play()
end

function UIPlayerShiHaiForm:OnHideBefore()
    self.RedPointCom:UnInitialize()
    for i = 1, 9 do
        self.GuangVfxs[i]:Destory()
    end
    self.JianVfx:OnDestory()
    self.JianActiveVfx:OnDestory()
end

--Open event
function UIPlayerShiHaiForm:OnOpen(obj, sender)
    self.CSForm:Show(sender);
end

--Close event
function UIPlayerShiHaiForm:OnClose(obj, sender)
    self.CSForm:Hide();
end

--Go to the copy button to click
function UIPlayerShiHaiForm:OnGoToBtnClick()
    --GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.TowerCopyMap)
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.DailyActivity)
    -- Close Form
    self:OnClose() -- UIEventDefine.UIPlayerShiHaiForm_CLOSE
    GameCenter.PushFixEvent(UILuaEventDefine.UIPlayerBaseForm_CLOSE)
end

--Click the upgrade button
function UIPlayerShiHaiForm:OnLevelUPBtnClick()
    GameCenter.PlayerShiHaiSystem:ReqLevelUP()
end

function UIPlayerShiHaiForm:Update(dt)
    self.AnimPlayer:Update(dt)
    for i = 1, 9 do
        self.GuangVfxs[i]:Update(dt)
    end
end

--Refresh event
function UIPlayerShiHaiForm:OnRefreshPage(obj, sender)
    local _level = GameCenter.PlayerShiHaiSystem.CurCfgID;
    local _cfg = DataConfig.DataPlayerShiHai[_level];
    if _cfg == nil then
        return
    end
    local _nextCfg = DataConfig.DataPlayerShiHai[_level + 1];
    if _nextCfg ~= nil then
        UIUtils.SetTextByStringDefinesID(self.CurLevel, _cfg._Name)
        UIUtils.SetTextByStringDefinesID(self.NextLevel, _nextCfg._Name)
        self.CurLevel.gameObject:SetActive(true)
        self.NextLevel.gameObject:SetActive(true)
        self.FullLevel.gameObject:SetActive(false)
        self.LevelUpBtn.gameObject:SetActive(true)
    else
        UIUtils.SetTextByStringDefinesID(self.FullLevel, _cfg._Name)
        self.CurLevel.gameObject:SetActive(false)
        self.NextLevel.gameObject:SetActive(false)
        self.FullLevel.gameObject:SetActive(true)
        self.LevelUpBtn.gameObject:SetActive(false)
    end
    UIUtils.SetTextByBigNumber(self.CurFightPower, _cfg.FightPower);
    local _cs = {';','_'}
    local _curAtt = Utils.SplitStrByTableS(_cfg.CurAttribute, _cs);
    local _addAtt = Utils.SplitStrByTableS(_cfg.AddAttribute, _cs);
    local _attCount = #_curAtt;
    local _attAddCount = #_addAtt;
    for i = 1, 5 do
        if i <= _attCount then
            self.PropTable[i].RootGo:SetActive(true);
            local _attCfg = DataConfig.DataAttributeAdd[_curAtt[i][1]];
            if _attCfg ~= nil then
                UIUtils.SetTextByString(self.PropTable[i].Name, _attCfg.Name .. ":")
            end
            UIUtils.SetTextByNumber(self.PropTable[i].Value, _curAtt[i][2]);
            if i <= _attAddCount then
                UIUtils.SetTextByNumber(self.PropTable[i].AddValue, _addAtt[i][2]);
            end
        else
            self.PropTable[i].RootGo:SetActive(false);
        end
    end

    --local _copyCfg = DataConfig.DataChallengeReward[_cfg.NeedCopyLevel]
    --if _copyCfg ~= nil then
    --    UIUtils.SetTextByString(self.NeedCopyLevel, _copyCfg.Name .. _copyCfg.LittleName)
    --end
    UIUtils.SetTextByString(self.NeedCopyLevel, _cfg.NeedCopyLevel)
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp and _lp.Level >= _cfg.NeedCopyLevel then
        UIUtils.SetColor(self.NeedCopyLevel, 255 / 255, 242 / 255, 199 / 255, 1)
    else
        UIUtils.SetColor(self.NeedCopyLevel, 1, 0, 0, 1)
    end
    --local _towerData = GameCenter.CopyMapSystem:FindCopyDataByType(CopyMapTypeEnum.TowerCopy)
    --if _towerData ~= nil and _towerData.CurLevel > _cfg.NeedCopyLevel then
    --    UIUtils.SetColor(self.NeedCopyLevel, 255 / 255, 242 / 255, 199 / 255, 1)
    --else
    --    UIUtils.SetColor(self.NeedCopyLevel, 1, 0, 0, 1)
    --end

    if string.len(_cfg.NeedItem) > 0 then
        local _curItem = Utils.SplitStrByTableS(_cfg.NeedItem, _cs);
        local _itemCount = #_curItem;
        for i = 1, 1 do
            if i <= _itemCount then
                self.NeedItems[i].RootGO:SetActive(true)
                self.NeedItems[i]:InItWithCfgid(_curItem[i][1], _curItem[i][2], false, true)
                self.NeedItems[i]:BindBagNum();
            else
                self.NeedItems[i].RootGO:SetActive(false)
            end
        end
        UnityUtils.SetLocalPositionX(self.LevelUpBtn.transform, 143)
    else
        for i = 1, 1 do
            self.NeedItems[i].RootGO:SetActive(false)
        end
        UnityUtils.SetLocalPositionX(self.LevelUpBtn.transform, 30)
    end
    local _littleLevel = _level % 10
    local _bigLevel = _level // 10 % 5
    for i = 1, 9 do
        if _littleLevel >= i then
            if self.FrontFreshLevel < i then
                --Play activation effect
                self.GuangVfxs[i]:ChangeState(VFXState.ActiveAnim, _bigLevel)
            else
                if self.GuangVfxs[i].State ~= VFXState.Actived then
                    self.GuangVfxs[i]:ChangeState(VFXState.Actived, _bigLevel)
                end
            end
        else
            self.GuangVfxs[i]:ChangeState(VFXState.NotActive, _bigLevel)
        end
    end
    if _littleLevel ~= self.FrontFreshLevel and _littleLevel == 0 then
        self.JianActiveVfx:OnCreateAndPlay(ModelTypeCode.UIVFX, 280 + _bigLevel, LayerUtils.GetAresUILayer())
    end
    if _level >= 10 then
        local _vfxId = 285 + (_level - 10) // 10 % 5
        if self.FrontJianVfxId ~= _vfxId then
            self.JianVfx:OnCreateAndPlay(ModelTypeCode.UIVFX, _vfxId, LayerUtils.GetAresUILayer())
            self.FrontJianVfxId = _vfxId
        end
    end
    self.FrontFreshLevel = _littleLevel;

    _nextCfg =  DataConfig.DataPlayerShiHai[_level + 1]
    self.MaxLevelGo:SetActive(_nextCfg == nil)

    if _cfg.Title > 0 then
        self.CurTitleSpr.gameObject:SetActive(true)
        self.CurTitleSpr.spriteName = tostring(_cfg.Title)
    else
        self.CurTitleSpr.gameObject:SetActive(false)
    end
    local _nextTtileCfg = DataConfig.DataPlayerShiHai[_level + 10]
    if _nextTtileCfg ~= nil then
        self.NextTitleSpr.gameObject:SetActive(true)
        self.NextTitleSpr.spriteName = tostring(_nextTtileCfg.Title)
    else
        self.NextTitleSpr.gameObject:SetActive(false)
    end
    self.JianTouGo:SetActive(_cfg.Title > 0 and _nextTtileCfg ~= nil)
    self.Grid:Reposition()
end

VFXState = {
    NotActive = 1,  -- Not activated
    ActiveAnim = 2, --Play active animation
    Actived = 3,    --Activated
}

UIVfxItem = {
    --Special effects
    Vfx = nil,
    VfxEx = nil,
    --price
    State = VFXState.NotActive, 
    --Status timer
    StateTimer = 0,
}
function UIVfxItem:New(vfx, vfxEx)
    local _m = Utils.DeepCopy(self)
    _m.Vfx = vfx
    _m.VfxEx = vfxEx
    _m.State = VFXState.NotActive
    _m.StateTimer = 0
    return _m
end
function UIVfxItem:ChangeState(state, vfxLevel)
    self.State = state
    self.VfxLevel = vfxLevel
    if state == VFXState.NotActive then
        self.Vfx:OnDestory()
        self.VfxEx:OnDestory()
    elseif state == VFXState.ActiveAnim then
        self.VfxEx:OnCreateAndPlay(ModelTypeCode.UIVFX, 290, LayerUtils.GetAresUILayer())
        self.StateTimer = 0.1
    elseif state == VFXState.Actived then
        self.Vfx:OnCreateAndPlay(ModelTypeCode.UIVFX, 275 + self.VfxLevel, LayerUtils.GetAresUILayer())
    end
end

--Flight time
function UIVfxItem:Update(dt)
    if self.State == VFXState.NotActive then
    elseif self.State == VFXState.ActiveAnim then
        self.StateTimer = self.StateTimer - dt
        if self.StateTimer <= 0 then
            self:ChangeState(VFXState.Actived, self.VfxLevel)
        end
    elseif self.State == VFXState.Actived then
    end
end
function UIVfxItem:Destory()
    self.Vfx:OnDestory()
    self.VfxEx:OnDestory()
    self.State = VFXState.NotActive
end
return UIPlayerShiHaiForm;