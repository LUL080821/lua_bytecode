------------------------------------------------
-- author:
-- Date: 2019-05-22
-- File: UIGuildNewForm.lua
-- Module: UIGuildNewForm
-- Description: Sectarian interface base
------------------------------------------------
local UIListMenu = require "UI.Components.UIListMenu.UIListMenuRight"
local UIGuildNewForm = {
    --UIListMenu
    ListMenu = nil,
    --UIButton
    CloseBtn = nil,
    -- BagFormSubPanel Save the open tag
    CurPanel = GuildSubEnum.TYPE_INFO,
    -- itemModel The data used to open the interface
    CurData = nil,
    TitleLabel = nil,
    BackTexture = nil
}

-- Inheriting Form functions
function UIGuildNewForm:OnRegisterEvents()
	self:RegisterEvent(UIEventDefine.UIGuildNewForm_OPEN,self.OnOpen)
    self:RegisterEvent(UIEventDefine.UIGuildNewForm_CLOSE,self.OnClose)
    self:RegisterEvent(UILuaEventDefine.UIXMBossForm_OPEN,self.OnOpenXMBossForm)		
    self:RegisterEvent(UILuaEventDefine.UIXmFightForm_OPEN,self.OnOpenXmFightForm);
end

function UIGuildNewForm:OnFirstShow()
	self:FindAllComponents()
    self.CSForm:AddNormalAnimation()
end

function UIGuildNewForm:OnHideBefore()
    self.CurPanel = GuildSubEnum.TYPE_INFO
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_SHOWANIMATION)
end

function UIGuildNewForm:OnShowAfter()
    self:LoadTextures()
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_HIDEANIMATION)
    self.MoenyForm:SetMoneyList(3, 12, 2, 1)
end

function UIGuildNewForm:OnOpen(obj, sender)
    self.CSForm:Show(sender)
    self.CurPanel = GuildSubEnum.TYPE_INFO
    if obj ~= nil and type(obj) == "table" then
        self.CurPanel = obj[1]
        if #obj >= 2 then
            self.SubPanel = obj[2]
        end
    end
    -- self.BuildTextureGo:SetActive(false)
    self.ListMenu:RemoveAll()
    self.ListMenu:AddIcon(GuildSubEnum.TYPE_INFO, nil, FunctionStartIdCode.GuildFuncTypeInfo)
    self.ListMenu:AddIcon(GuildSubEnum.TYPE_BUILD, nil, FunctionStartIdCode.GuildBuild)
    self.ListMenu:AddIcon(GuildSubEnum.TYPE_ACTION, nil, FunctionStartIdCode.GuildFuncTypeAction)
    self.ListMenu:AddIcon(GuildSubEnum.TYPE_BOX, nil, FunctionStartIdCode.GuildFuncTypeBox)
    self.ListMenu:AddIcon(GuildSubEnum.Type_RedPackage, nil, FunctionStartIdCode.GuildTabRedPackage)
    self.ListMenu:SetSelectById(self.CurPanel)
end

-- Find various controls on the UI
function UIGuildNewForm:FindAllComponents()
    local trans = self.Trans
    self.BackTexture = UIUtils.FindTex(trans, "Texture")
    -- self.BuildTexture = UIUtils.FindTex(trans, "BuildTexture")
    -- self.BuildTextureGo = UIUtils.FindGo(trans, "BuildTexture")
    local listTrans = trans:Find("Right/RightMenu")
    self.ListMenu = UIListMenu:OnFirstShow(self.CSForm, listTrans)
    self.ListMenu:ClearSelectEvent();
    self.ListMenu:AddSelectEvent(Utils.Handler(self.OnClickCallBack, self))
    self.ListMenu.IsHideIconByFunc = true

    -- self.TitleLabel = UIUtils.FindLabel(trans, "Title")

    self.CloseBtn = UIUtils.FindBtn(trans, "CloseBtn")
    self.CloseBtn.onClick:Clear()
    UIUtils.AddBtnEvent(self.CloseBtn, self.OnClickCloseBtn, self)
	self.MoenyForm = UIUtils.RequireUIMoneyForm(UIUtils.FindTrans(trans, "UIMoneyForm"))
end

function UIGuildNewForm:OnClickCallBack(id, select)
    if select then
        if id == GuildSubEnum.TYPE_BUILD then
            GameCenter.PushFixEvent(UIEventDefine.UIGuildBuildBaseForm_OPEN, nil, self.CSForm)
            -- self.BuildTextureGo:SetActive(true)
            self.CSForm:LoadTexture(self.BackTexture,AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_b_xianmeng_1"))
        elseif id == GuildSubEnum.TYPE_INFO then
            GameCenter.PushFixEvent(UIEventDefine.UIGuildForm_OPEN, self.SubPanel, self.CSForm)
            self.CSForm:LoadTexture(self.BackTexture,AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_1_2"))
        elseif id == GuildSubEnum.TYPE_ACTION then
            GameCenter.PushFixEvent(UIEventDefine.UIGuildActiveBaseForm_OPEN, self.SubPanel, self.CSForm)
        elseif id == GuildSubEnum.TYPE_BOX then
            GameCenter.PushFixEvent(UILuaEventDefine.UIGuildBoxForm_OPEN, nil, self.CSForm)
            self.CSForm:LoadTexture(self.BackTexture,AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_1_2"))
        elseif id == GuildSubEnum.Type_RedPackage then
            GameCenter.PushFixEvent(UILuaEventDefine.UIGuildRedPackageForm_OPEN, nil, self.CSForm)
            self.CSForm:LoadTexture(self.BackTexture,AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_1_2"))
        end
        self.SubPanel = nil
    else
        if id == GuildSubEnum.TYPE_BUILD then
            GameCenter.PushFixEvent(UIEventDefine.UIGuildBuildBaseForm_CLOSE)
        elseif id == GuildSubEnum.TYPE_INFO then
            GameCenter.PushFixEvent(UIEventDefine.UIGuildForm_CLOSE)
            self.CurData = nil
        elseif id == GuildSubEnum.TYPE_ACTION then
            GameCenter.PushFixEvent(UIEventDefine.UIGuildActiveBaseForm_CLOSE)
        elseif id == GuildSubEnum.TYPE_BOX then
            GameCenter.PushFixEvent(UILuaEventDefine.UIGuildBoxForm_CLOSE)
        elseif id == GuildSubEnum.Type_RedPackage then
            GameCenter.PushFixEvent(UILuaEventDefine.UIGuildRedPackageForm_CLOSE)
        end
    end
end

function UIGuildNewForm:OnOpenXMBossForm()
    self.CSForm:LoadTexture(self.BackTexture,AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_b_xianmengshouling"))
end

function UIGuildNewForm:OnOpenXmFightForm()
    self.CSForm:LoadTexture(self.BackTexture,AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_1_2"))
end

function UIGuildNewForm:OnClickCloseBtn()
    self:OnClose()
end

-- Loading texture
function UIGuildNewForm:LoadTextures()
    -- self.CSForm:LoadTexture(self.BackTexture,AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_1_2"))
    -- self.CSForm:LoadTexture(self.BuildTexture,AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_b_xianmeng_1"))
end
return UIGuildNewForm