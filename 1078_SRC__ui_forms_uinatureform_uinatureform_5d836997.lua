------------------------------------------------
-- author:
-- Date: 2019-04-16
-- File: UINatureForm.lua
-- Module: UINatureForm
-- Description: Creation Panel
------------------------------------------------
-- Quote
local UIListMenu = require "UI.Components.UIListMenu.UIListMenuRight"

local UINatureForm = {
    UIListMenu = nil,-- List
    Form = NatureEnum.Mount, -- Pagination Type
    TabForm = 1, -- Subpagination type
    CloseBtn = nil,-- Close button
    AnimModule = nil, -- Animation module
    BackTexture = nil, --Texture
}

function UINatureForm:OnRegisterEvents()
	self:RegisterEvent(UIEventDefine.UINatureForm_OPEN, self.OnOpen)
	self:RegisterEvent(UIEventDefine.UINatureForm_CLOSE, self.OnClose)
end

function UINatureForm:OnOpen(obj, sender)
    self.CSForm:Show(sender)
    self.Form = NatureEnum.Mount
	if obj then
		if type(obj) == "table" then
			if #obj == 2 then
				self.Form = obj[1]
				self.TabForm = obj[2]
			end
		else
			self.Form = obj
		end
    end
	self.UIListMenu:SetSelectById(self.Form)
end

-- Register events on the UI, such as click events, etc.
function UINatureForm:RegUICallback()
    UIUtils.AddBtnEvent(self.CloseBtn, self.OnClickCloseBtn, self)
end

function UINatureForm:OnFirstShow()
    self:FindAllComponents()
    self:RegUICallback()
end

function UINatureForm:OnShowAfter()
    self:LoadTextures()
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_HIDEANIMATION)
    self.MoenyForm:SetMoneyList(3, 12, 2, 1)
end

function UINatureForm:OnShowBefore()
    self.AnimModule:PlayEnableAnimation()
end

function UINatureForm:OnHideBefore()
    self.UIListMenu:SetSelectByIndex(-1);
    self.AnimModule:PlayDisableAnimation()
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_SHOWANIMATION)
end

-- Click the Close button on the interface
function UINatureForm:OnClickCloseBtn()
	self:OnClose(nil, nil)
end

function UINatureForm:FindAllComponents()
    local _myTrans = self.Trans
    self.CSForm:AddNormalAnimation()
    self.UIListMenu = UIListMenu:OnFirstShow(self.CSForm, UIUtils.FindTrans(_myTrans, "Right/UIListMenu"))
    -- self.UIListMenu:AddIcon(NatureEnum.Wing,DataConfig.DataMessageString.Get("NATUREWING"),FunctionStartIdCode.NatureWing)
    self.UIListMenu:AddIcon(NatureEnum.Mount, nil,FunctionStartIdCode.Mount)
    self.UIListMenu:AddIcon(NatureEnum.FaBao, nil,FunctionStartIdCode.RealmStifle)
    self.UIListMenu:AddIcon(NatureEnum.Pet, nil,FunctionStartIdCode.Pet)
    self.UIListMenu:AddIcon(NatureEnum.Weapon, nil,FunctionStartIdCode.NatureWeapon)
    self.UIListMenu:AddSelectEvent(Utils.Handler(self.OnMenuSelect,self))
    self.UIListMenu.IsHideIconByFunc = true
    self.CloseBtn = UIUtils.FindBtn(_myTrans,"CloseButton")
    self.BackTexture = UIUtils.FindTex(_myTrans,"BgTexture")
    self.AnimModule = UIAnimationModule(_myTrans)
	self.MoenyForm = UIUtils.RequireUIMoneyForm(UIUtils.FindTrans(_myTrans, "UIMoneyForm"));
end

function UINatureForm:OnMenuSelect(id, sender)
    self.Form = id
    if sender then
        self:OpenSubForm(id)
    else
        self:CloseSubForm(id)
    end
end

function UINatureForm:OpenSubForm(id)
    if id == NatureEnum.Wing then -- wing
        GameCenter.PushFixEvent(UIEventDefine.UINatureWingForm_OPEN, self.TabForm, self.CSForm)
    elseif id == NatureEnum.FaBao then -- magic weapon
        GameCenter.PushFixEvent(UIEventDefine.UIRealmStifleForm_OPEN, self.TabForm, self.CSForm)
    elseif id == NatureEnum.Mount then -- Mount
        GameCenter.PushFixEvent(UIEventDefine.UIMountGrowUpForm_OPEN, self.TabForm, self.CSForm)
    elseif id == NatureEnum.Pet then -- pet
        GameCenter.PushFixEvent(UIEventDefine.UIPetForm_OPEN, self.TabForm, self.CSForm)
    elseif id == NatureEnum.Weapon then -- Divine Soldier
        GameCenter.PushFixEvent(UIEventDefine.UINatureWeaponForm_OPEN, self.TabForm, self.CSForm)
    end
    self.TabForm = nil
end

function UINatureForm:CloseSubForm(id)
    if id == NatureEnum.Wing then -- wing
        GameCenter.PushFixEvent(UIEventDefine.UINatureWingForm_CLOSE, nil, self.CSForm)
    elseif id == NatureEnum.FaBao then-- magic weapon
        GameCenter.PushFixEvent(UIEventDefine.UIRealmStifleForm_CLOSE, nil, self.CSForm)
    elseif id == NatureEnum.Mount then-- Mount
        GameCenter.PushFixEvent(UIEventDefine.UIMountGrowUpForm_CLOSE, nil, self.CSForm)
    elseif id == NatureEnum.Pet then -- pet
        GameCenter.PushFixEvent(UIEventDefine.UIPetForm_CLOSE, nil, self.CSForm)
    elseif id == NatureEnum.Weapon then -- Divine Soldier
        GameCenter.PushFixEvent(UIEventDefine.UINatureWeaponForm_CLOSE, nil, self.CSForm)
    end
end

-- Loading texture
function UINatureForm:LoadTextures()
    self.CSForm:LoadTexture(self.BackTexture,AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_b_jianling"))
end


return UINatureForm