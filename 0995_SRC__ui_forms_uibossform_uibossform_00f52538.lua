------------------------------------------------
-- Author: 
-- Date: 2019-05-10
-- File: UIBossForm.lua
-- Module: UIBossForm
-- Description: BOSS Panel
------------------------------------------------
-- Quote
local UIListMenu = require "UI.Components.UIListMenu.UIListMenuRight"

local UIBossForm = {
    UIListMenu = nil, -- List
    Form = NatureEnum.Begin, -- Pagination Type
    Params = nil, -- Parameters transmitted from outside
    CloseBtn = nil, -- Close button

    AnimModule = nil, -- Animation module
    BackTexture = nil -- Texture
    -- ListMenuPanel = nil,
}

function UIBossForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UIBossForm_OPEN, self.OnOpen)
    self:RegisterEvent(UIEventDefine.UIBossForm_CLOSE, self.OnClose)
end

function UIBossForm:OnOpen(obj, sender)
    self.CSForm:Show(sender)
    if obj ~= nil then
        if #obj > 1 then
            self.Form = obj[1]
            self.Params = obj[2]
        else
            self.Form = obj[1]
        end
    end
    local _lpLevel = GameCenter.GameSceneSystem:GetLocalPlayer().Level
    -- Judging the level, see if you should enter the infinite layer or the world boss
    local _cfgLv = 0
    if DataConfig.DataMonster:IsContainKey(11101) then
        _cfgLv = DataConfig.DataMonster[11101].Level
    end
    if self.Form == BossEnum.WorldBoss and _lpLevel < _cfgLv then
        self.Form = BossEnum.WuxianBoss
    end
    self.UIListMenu:SetSelectById(self.Form)
end

function UIBossForm:OnClose(obj, sender)
    self.CSForm:Hide()
end

-- Register events on the UI, such as click events, etc.
function UIBossForm:RegUICallback()
    UIUtils.AddBtnEvent(self.CloseBtn, self.OnClickCloseBtn, self)
end

function UIBossForm:OnFirstShow()
    self:FindAllComponents()
    self:RegUICallback()
    self.CSForm:AddNormalAnimation()
end

function UIBossForm:OnShowAfter()
    self:LoadTextures()
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_HIDEANIMATION)
end

function UIBossForm:OnShowBefore()
    self.AnimModule:PlayEnableAnimation()
    -- self.ListMenuPanel.clipOffset = Vector2(0, 0)
    -- UnityUtils.SetLocalPosition(self.ListMenuPanel.transform,0, 0, 0)
end

function UIBossForm:OnHideBefore()
    self.UIListMenu:SetSelectByIndex(-1);
    self.AnimModule:PlayDisableAnimation()
    self.CSForm:UnloadTexture(self.BackTexture)
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_SHOWANIMATION)
end

-- Click the Close button on the interface
function UIBossForm:OnClickCloseBtn()
    self:OnClose(nil, nil)
end

function UIBossForm:FindAllComponents()
    self.UIListMenu = UIListMenu:OnFirstShow(self.CSForm, UIUtils.FindTrans(self.Trans, "UIListMenuRight"))
    self.UIListMenu:ClearSelectEvent()
    self.UIListMenu:AddSelectEvent(Utils.Handler(self.OnMenuSelect, self))
    self.UIListMenu.IsHideIconByFunc = true
    -- self.UIListMenu:AddIcon(BossEnum.WuxianBoss, DataConfig.DataMessageString.Get("WuXian_Boss_Title"),
    --     FunctionStartIdCode.WuXianBoss)
    self.UIListMenu:AddIcon(BossEnum.WorldBoss, DataConfig.DataMessageString.Get("BOSS_WORLD_TITTLE"),
        FunctionStartIdCode.WorldBoss)
    self.UIListMenu:AddIcon(BossEnum.SuitBoss, DataConfig.DataMessageString.Get("Boss_Suit_Title"),
        FunctionStartIdCode.WorldBoss1)
    -- self.UIListMenu:AddIcon(BossEnum.GemBoss,DataConfig.DataMessageString.Get("Boss_Gem_Title"),FunctionStartIdCode.WorldBoss2)
    -- self.UIListMenu:AddIcon(BossEnum.MySelfBoss,DataConfig.DataMessageString.Get("BOSS_MYSELF_TITTLE"),FunctionStartIdCode.MySelfBoss)
    self.UIListMenu:AddIcon(BossEnum.BossHome, DataConfig.DataMessageString.Get("Boss_Home_Title"),FunctionStartIdCode.BossHome)
    self.UIListMenu:AddIcon(BossEnum.SoulMonsterCopy, DataConfig.DataMessageString.Get("Boss_HunShow_Title"),
        FunctionStartIdCode.SoulMonsterCopy)
    self.UIListMenu:AddIcon(BossEnum.StatureBoss, DataConfig.DataMessageString.Get("Boss_JinJie_Title"),
        FunctionStartIdCode.StatureBoss)
    self.UIListMenu:AddIcon(BossEnum.TrainBoss, DataConfig.DataMessageString.Get("BOSS_TRAIN_TITTLE"),
        FunctionStartIdCode.TrainBoss)
    self.CloseBtn = UIUtils.FindBtn(self.Trans, "Back/CloseBtn")
    self.AnimModule = UIAnimationModule(self.Trans)
    self.AnimModule:AddAlphaAnimation(UIUtils.FindTrans(self.Trans, "Back"))
    self.BackTexture = UIUtils.FindTex(self.Trans, "Back/BackTex")
    self.MoenyForm = UIUtils.RequireUIMoneyForm(UIUtils.FindTrans(self.Trans, "UIMoneyForm"))
    self.MoenyForm:SetMoneyList(3, 12, 2, 1)
end

function UIBossForm:OnMenuSelect(id, sender)
    self.Form = id
    if sender then
        self:OpenSubForm(id)
    else
        self.Params = nil
        self:CloseSubForm(id)
    end
end

function UIBossForm:OpenSubForm(id)
    if id == BossEnum.WuxianBoss then -- Unlimited BOSS
        GameCenter.PushFixEvent(UIEventDefine.UINewWorldBossForm_OPEN, {WorldBossPageEnum.WuXianBoss, self.Params}, self.CSForm)
        GameCenter.BISystem:ReqClickEvent(BiIdCode.WXSLCopyMapEnter)
        self.CSForm:LoadTexture(self.BackTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_b_wujixuyu"))
    elseif id == BossEnum.WorldBoss then -- World BOSS
        GameCenter.PushFixEvent(UIEventDefine.UINewWorldBossForm_OPEN, {WorldBossPageEnum.WordBoss, self.Params}, self.CSForm)
        GameCenter.BISystem:ReqClickEvent(BiIdCode.WJXYCopyMapEnter)
        self.CSForm:LoadTexture(self.BackTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_b_wujixuyu"))
    elseif id == BossEnum.MySelfBoss then -- Personal BOSS
        GameCenter.PushFixEvent(UIEventDefine.UIMySelfBossForm_OPEN, nil, self.CSForm)
    elseif id == BossEnum.BossHome then -- BOSS Home
        GameCenter.PushFixEvent(UILuaEventDefine.UINewBossHomeForm_OPEN, self.Params, self.CSForm)
    elseif id == BossEnum.SoulMonsterCopy then -- Soul Beast Forest
        GameCenter.PushFixEvent(UIEventDefine.UIHunShouShenLinForm_OPEN, nil, self.CSForm)
    elseif id == BossEnum.SuitBoss then -- Boss set
        GameCenter.PushFixEvent(UIEventDefine.UISuitGemWorldBossForm_OPEN, {WorldBossPageEnum.SuitBoss, self.Params}, self.CSForm)
        self.CSForm:LoadTexture(self.BackTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_b_jingjiaheyu"))
    elseif id == BossEnum.GemBoss then -- Gem Boss
        GameCenter.PushFixEvent(UIEventDefine.UISuitGemWorldBossForm_OPEN, {WorldBossPageEnum.GemBoss, self.Params}, self.CSForm)
        GameCenter.BISystem:ReqClickEvent(BiIdCode.GemBoss)
    elseif id == BossEnum.StatureBoss then -- Realm BOSS
        GameCenter.PushFixEvent(UIEventDefine.UIStatureBossForm_OPEN, nil, self.CSForm)
        GameCenter.BISystem:ReqClickEvent(BiIdCode.JJSYCopyMapEnter)
        self.CSForm:LoadTexture(self.BackTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_b_jingjieshengyu"))
    elseif id == BossEnum.TrainBoss then -- Train BOSS
        GameCenter.PushFixEvent(UIEventDefine.UINewWorldBossForm_OPEN, {WorldBossPageEnum.TrainBoss, self.Params}, self.CSForm)
        GameCenter.BISystem:ReqClickEvent(BiIdCode.WJXYCopyMapEnter)
        self.CSForm:LoadTexture(self.BackTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_b_wujixuyu"))
    end
    self.Params = nil
end

function UIBossForm:CloseSubForm(id)
    if id == BossEnum.WuxianBoss then -- Unlimited Boss
        GameCenter.PushFixEvent(UIEventDefine.UINewWorldBossForm_CLOSE, nil, self.CSForm)
    elseif id == BossEnum.WorldBoss then -- World BOSS
        GameCenter.PushFixEvent(UIEventDefine.UINewWorldBossForm_CLOSE, nil, self.CSForm)
    elseif id == BossEnum.MySelfBoss then -- Personal BOSS
        GameCenter.PushFixEvent(UIEventDefine.UIMySelfBossForm_CLOSE, nil, self.CSForm)
    elseif id == BossEnum.SoulMonsterCopy then -- Soul Beast Forest
        GameCenter.PushFixEvent(UIEventDefine.UIHunShouShenLinForm_CLOSE, nil, self.CSForm)
    elseif id == BossEnum.BossHome then -- BOSS Home
        GameCenter.PushFixEvent(UILuaEventDefine.UINewBossHomeForm_CLOSE, nil, self.CSForm)
    elseif id == BossEnum.SuitBoss then -- Boss set
        GameCenter.PushFixEvent(UIEventDefine.UISuitGemWorldBossForm_CLOSE, nil, self.CSForm)
    elseif id == BossEnum.GemBoss then -- Gem Boss
        GameCenter.PushFixEvent(UIEventDefine.UISuitGemWorldBossForm_CLOSE, nil, self.CSForm)
    elseif id == BossEnum.StatureBoss then -- Realm BOSS
        GameCenter.PushFixEvent(UIEventDefine.UIStatureBossForm_CLOSE, nil, self.CSForm)
    elseif id == BossEnum.TrainBoss then -- Train BOSS
        GameCenter.PushFixEvent(UIEventDefine.UINewWorldBossForm_CLOSE, nil, self.CSForm)
    end
end
-- Loading texture
function UIBossForm:LoadTextures()
    self.CSForm:LoadTexture(self.BackTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_1_1"))
end

return UIBossForm
