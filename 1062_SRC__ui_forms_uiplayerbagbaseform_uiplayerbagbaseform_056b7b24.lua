------------------------------------------------
--author:
--Date: 2019-04-17
--File: UIPlayerBagBaseForm.lua
--Module: UIPlayerBagBaseForm
--Description: Backpack base, mainly for list buttons
------------------------------------------------
local UIListMenu = require "UI.Components.UIListMenu.UIListMenuRight"
local UIPlayerBagBaseForm = {
    --UIListMenu
    ListMenu = nil,
    --UIButton
    CloseBtn = nil,
    --BagFormSubPanel Save the open tag
    CurPanel = 0,
    --itemModel The data used to open the interface
    CurData = nil,
    TitleLabel = nil,
    BackTexture = nil,
    BackTexture2 = nil,
}

--Inherit the Form function
function UIPlayerBagBaseForm:OnRegisterEvents()
	self:RegisterEvent(UIEventDefine.UIPlayerBagBaseForm_OPEN,self.OnOpen)
	self:RegisterEvent(UIEventDefine.UIPlayerBagBaseForm_CLOSE,self.OnClose)
end

function UIPlayerBagBaseForm:OnFirstShow()
	self:FindAllComponents()
    self.CSForm:AddNormalAnimation()
end
function UIPlayerBagBaseForm:OnHideBefore()
    self.CurPanel = BagFormSubEnum.Bag
    self.ListMenu:SetSelectById(-1)
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_SHOWANIMATION)

    GameCenter.PushFixEvent(UIEventDefine.UIPlayerBagForm_CLOSE)
    GameCenter.PushFixEvent(UIEventDefine.UIPlayerStoreForm_CLOSE)
    GameCenter.PushFixEvent(UIEventDefine.UIItemSynthForm_CLOSE)
end
function UIPlayerBagBaseForm:OnShowAfter()
    self:LoadTextures()
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_HIDEANIMATION)
    self.MoenyForm:SetMoneyList(3, 12, 2, 1)
end

function UIPlayerBagBaseForm:OnOpen(obj, sender)
    self.CSForm:Show(sender)
    if obj ~= nil then
        self.CurPanel = obj[1]
        if obj[2] ~= nil then
            self.CurData = obj[2]
        end
    end
    self.ListMenu:RemoveAll()
    self.ListMenu:AddIcon(BagFormSubEnum.Bag, DataConfig.DataMessageString.Get("C_JUESE_BEIBAO"), FunctionStartIdCode.BagSub)
    -- self.ListMenu:AddIcon(BagFormSubEnum.Store, DataConfig.DataMessageString.Get("C_JUESE_CANGKU"), FunctionStartIdCode.Store)
    self.ListMenu:AddIcon(BagFormSubEnum.Synth, DataConfig.DataMessageString.Get("C_UI_FunctionName_ItemSynth"), FunctionStartIdCode.BagSynth)
    -- self.ListMenu:AddIcon(BagFormSubEnum.EquipSyn, DataConfig.DataMessageString.Get("C_UI_FunctionName_EquipSynth"), FunctionStartIdCode.EquipSynthesis, "moneybg_3", nil, "moneybg_14")
    self.ListMenu:SetSelectById(self.CurPanel)
end

--Find various controls on the UI
function UIPlayerBagBaseForm:FindAllComponents()
    local trans = self.Trans
    self.BackTexture = UIUtils.FindTex(trans, "BgTexture")
    self.BackTexture2 = UIUtils.FindTex(trans, "BgTexture2")
    local listTrans = trans:Find("UIListMenu")
    self.ListMenu = UIListMenu:OnFirstShow(self.CSForm, listTrans)
    self.ListMenu:ClearSelectEvent();
    self.ListMenu:AddSelectEvent(Utils.Handler(self.OnClickCallBack, self))
    self.ListMenu.IsHideIconByFunc = true

    self.TitleLabel = UIUtils.FindLabel(trans, "Title")

    self.CloseBtn = UIUtils.FindBtn(trans, "CloseBtn")
    self.CloseBtn.onClick:Clear()
    UIUtils.AddBtnEvent(self.CloseBtn, self.OnClickCloseBtn, self)
	self.MoenyForm = UIUtils.RequireUIMoneyForm(UIUtils.FindTrans(self.Trans, "UIMoneyForm"));
end

function UIPlayerBagBaseForm:OnClickCallBack(id, select)
    if select then
        if id == BagFormSubEnum.Bag then
            self.CurPanel = id
            UIUtils.SetTextByEnum(self.TitleLabel, "C_JUESE_BEIBAO")
            self.CSForm:LoadTexture(self.BackTexture,AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_1_1"))
            GameCenter.PushFixEvent(UIEventDefine.UIPlayerBagForm_OPEN, id, self.CSForm)
        end
        if id == BagFormSubEnum.Store then
            if self:OnCheckStoreVisable() then
                self.CurPanel = id
                UIUtils.SetTextByEnum(self.TitleLabel, "C_JUESE_CANGKU")
                self.CSForm:LoadTexture(self.BackTexture,AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_1_2"))
                GameCenter.PushFixEvent(UIEventDefine.UIPlayerBagForm_OPEN, id, self.CSForm)
                GameCenter.PushFixEvent(UIEventDefine.UIPlayerStoreForm_OPEN, nil, self.CSForm)
            else
                self.ListMenu:SetSelectById(self.CurPanel)
            end
        end
        if id == BagFormSubEnum.Synth then
            self.CurPanel = id
            UIUtils.SetTextByEnum(self.TitleLabel, "C_UI_FunctionName_ItemSynth")
            GameCenter.PushFixEvent(UIEventDefine.UIItemSynthForm_OPEN, self.CurData, self.CSForm)
            GameCenter.PushFixEvent(UIEventDefine.UIPlayerBagForm_CLOSE)
            self.CSForm:LoadTexture(self.BackTexture,AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_1_2"))
        end
        if id == BagFormSubEnum.EquipSyn then
            self.CurPanel = id
            UIUtils.SetTextByEnum(self.TitleLabel, "C_UI_FunctionName_EquipSynth")
            GameCenter.PushFixEvent(UIEventDefine.UIEquipSynthBaseForm_OPEN, self.CurData, self.CSForm)
            GameCenter.PushFixEvent(UIEventDefine.UIPlayerBagForm_CLOSE)
        end
    else
        if id == BagFormSubEnum.Store then
            GameCenter.PushFixEvent(UIEventDefine.UIPlayerStoreForm_CLOSE)
        end
        if id == BagFormSubEnum.Synth then
            GameCenter.PushFixEvent(UIEventDefine.UIItemSynthForm_CLOSE)
            self.CurData = nil
        end
        if id == BagFormSubEnum.EquipSyn then
            GameCenter.PushFixEvent(UIEventDefine.UIEquipSynthBaseForm_CLOSE)
        end
    end
end

function UIPlayerBagBaseForm:OnClickCloseBtn()
    self:OnClose()
end

--Loading texture
function UIPlayerBagBaseForm:LoadTextures()
    self.CSForm:LoadTexture(self.BackTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_1_1"))
    self.CSForm:LoadTexture(self.BackTexture2, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_1_1"))
end

function UIPlayerBagBaseForm:OnCheckStoreVisable()
    local _cfg = DataConfig.DataGlobal[GlobalName.StoreOpenConditionl]
    if _cfg then
        self.NeedVipLevel = tonumber(_cfg.Params)
        if self.NeedVipLevel > GameCenter.GameSceneSystem:GetLocalPlayer().VipLevel then
            Utils.ShowPromptByEnum("C_UI_PlayerStore_Open_Msg", self.NeedVipLevel)
            return false
        end
    end
    return true
end
return UIPlayerBagBaseForm
