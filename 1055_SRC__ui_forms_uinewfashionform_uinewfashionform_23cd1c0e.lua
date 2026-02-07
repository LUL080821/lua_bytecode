
--==============================--
-- author:
-- Date: 2020-03-23 09:58:45
-- File: UINewFashionForm.lua
-- Module: UINewFashionForm
-- Description: {New fashion function basic interface!}
--==============================--
local UIListMenu = require ("UI.Components.UIListMenu.UIListMenuRight");
local UINewFashionForm = {
	BgModel = nil,
	TexBg = nil,
	RdTex = nil,
	TopTex = nil,
	CloseBtn = nil,
	ListMenu = nil,
	Param = 0,
	IsCheckMask = true,
}

-- Register event functions and provide them to the CS side to call.
function UINewFashionForm:OnRegisterEvents()
	self:RegisterEvent(UILuaEventDefine.UINewFashionForm_OPEN,self.OnOpen)
	self:RegisterEvent(UILuaEventDefine.UINewFashionForm_CLOSE,self.OnClose)
	--self:RegisterEvent(LogicEventDefine.EID_EVENT_UISCENEN_LOADFINISH,self.OnLoadFinish)

	-- CUSTOM - handle close Dogiam
	self:RegisterEvent(LogicLuaEventDefine.EID_DOGIAM_CLOSE,self.OnCloseDoGiam)
	-- CUSTOM - handle close Dogiam
end

function UINewFashionForm:OnLoadFinish(obj, sender)
	--self.Mask:SetActive(false)
end

-- The first display function is provided to the CS side to call.
function UINewFashionForm:OnFirstShow()
	self:FindAllComponents();
	self:RegUICallback();
	self.CSForm.UIRegion = UIFormRegion.TopRegion;
end

-- Find all components
function UINewFashionForm:FindAllComponents()
	local _myTrans = self.Trans;
	local listMenuTrans = _myTrans:Find("Right/UIListMenu")
	self.ListMenu = UIListMenu:OnFirstShow(self.CSForm, listMenuTrans)
	self.ListMenu:ClearSelectEvent()
	self.ListMenu:AddIcon(1, DataConfig.DataMessageString.Get("C_SHIZHUANG"),FunctionStartIdCode.Fashion, "sz_biaoqianlan", "sz_biaoqianhuang")
	self.ListMenu:AddIcon(2, DataConfig.DataMessageString.Get("C_TUJIAN"),FunctionStartIdCode.FashionTj, "sz_biaoqianlan", "sz_biaoqianhuang")
	self.ListMenu:AddIcon(3, DataConfig.DataMessageString.Get("C_YIGUI"),FunctionStartIdCode.Wardrobe, "sz_biaoqianlan", "sz_biaoqianhuang")
	self.ListMenu:AddSelectEvent(Utils.Handler(self.OnMenuSelect,self))
	self.ListMenu.IsHideIconByFunc = true
	self.TexBg = UIUtils.FindTex(_myTrans,"Center/BgTex")
	self.RdTex = UIUtils.FindTex(_myTrans,"Center/RdTex")
	self.TopTex = UIUtils.FindTex(_myTrans,"Top/TopTex")
	self.CloseBtn = UIUtils.FindBtn(_myTrans,"Top/Close")
	self.Mask = UIUtils.FindGo(_myTrans, "Center/Mask")
	self.MoenyForm = UIUtils.RequireUIMoneyForm(UIUtils.FindTrans(_myTrans, "Top/UIMoneyForm"));
    self.MoenyForm:SetMoneyList(3, 12, 2, 1)
end

function UINewFashionForm:OnOpen(obj, sender)
	-- CUSTOM - refresh DoGiam redpoint
	GameCenter.NewFashionSystem:UpdateTjRedPoint()
	-- CUSTOM - refresh DoGiam redpoint
	self.Param = 0
	GameCenter.PushFixEvent(UIEventDefine.UIGetNewItemForm_CLOSE)
	self.CSForm:Show(sender)
	self.OpenParams = obj
end

function UINewFashionForm:OnClose(obj, sender)
	self.ListMenu:SetSelectByIndex(-1)
	self.CSForm:Hide()
end

-- CUSTOM - handle close DoGiam
function UINewFashionForm:OnCloseDoGiam()
	self.ListMenu:SetSelectByIndex(-1)
	self.CSForm:Hide()
end
-- CUSTOM - handle close DoGiam

function UINewFashionForm:OnMenuSelect(id, open)
    self.Form = id
    if open then
        self:OpenSubForm(id)
    else
        self:CloseSubForm(id)
    end
end

function UINewFashionForm:OpenSubForm(id)
	if id == 2 then
		self.BgModel:ResetSkin()
		GameCenter.PushFixEvent(UILuaEventDefine.UIFashionTjForm_OPEN)
	elseif id == 3 then
		GameCenter.PushFixEvent(UILuaEventDefine.UIWardrobeForm_OPEN, self.BgModel)
	elseif id == 1 then
		GameCenter.PushFixEvent(UILuaEventDefine.UIFashionForm_OPEN, {Bg = self.BgModel, Param = self.Param})
	end
end

function UINewFashionForm:CloseSubForm(id)
	if id == 2 then
		GameCenter.PushFixEvent(UILuaEventDefine.UIFashionTjForm_CLOSE, self)
	elseif id == 3 then
		GameCenter.PushFixEvent(UILuaEventDefine.UIWardrobeForm_CLOSE)
	elseif id == 1 then
		GameCenter.PushFixEvent(UILuaEventDefine.UIFashionForm_CLOSE)
	end
end

-- Callback function that binds UI components
function UINewFashionForm:RegUICallback()
	UIUtils.AddBtnEvent(self.CloseBtn,self.OnClickClose, self)
end

-- Displays the previous operation and provides it to the CS side to call.
function UINewFashionForm:OnShowBefore()
end

-- The displayed operation is provided to the CS side to call.
function UINewFashionForm:OnShowAfter()
	self.SetFullScrees = false
	self:LoadTextures(self.TexBg,"tex_sz_beijing")
	self:LoadTextures(self.TopTex,"tex_n_a_107_1")
	-- Add a model background
	self.BgIsLoadFinish = false
	self.BgModel = GameCenter.UISceneManager:GetInstance():CreateUIScene(1,2)
	self.BgModel:SetRotaTrans(self.Skin)
	self.Mask:SetActive(true)
	--GameCenter.PushFixEvent(UILuaEventDefine.UIWardrobeForm_LOAD)
end

-- Hide previous operations and provide them to the CS side to call.
function UINewFashionForm:OnHideBefore()
	self.ListMenu:SetSelectByIndex(-1)
	self.BgModel:Destory()
	self.Mask:SetActive(true)
	self.IsCheckMask = true
	GameCenter.UISceneManager:GetInstance():RemoveScene(self.BgModel)
	if self.SetFullScrees then
		GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_DEC_MAINCAMERA_HIDECOUNTER)
	end
end

-- The hidden operation is provided to the CS side to call.
function UINewFashionForm:OnHideAfter()
end

-- Loading texture
function UINewFashionForm:LoadTextures(tex, name)
    self.CSForm:LoadTexture(tex,AssetUtils.GetImageAssetPath(ImageTypeCode.UI, name))
end

function UINewFashionForm:Update(dt)
	if self.BgModel.IsLoadFinish and not self.BgIsLoadFinish then
		self.BgIsLoadFinish = true
		if self.OpenParams ~= nil then
			if self.OpenParams.Param ~= nil and self.OpenParams.Param.Length > 0 then
				self.Param = self.OpenParams.Param[0]
			end
			self.ListMenu:SetSelectById(self.OpenParams.SubForm)
		else
			self.ListMenu:SetSelectById(1)
		end
	end
	if self.IsCheckMask then
		if self.BgModel ~= nil then
			self.Mask:SetActive(false)
			self.IsCheckMask = false
		end
	end
	if self.BgModel.IsLoadFinish and not self.SetFullScrees then
		self.SetFullScrees = true
		GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_ADD_MAINCAMERA_HIDECOUNTER)
	end
end

-- [Interface button callback begin]--

function UINewFashionForm:OnClickClose()
    self:OnClose()
end
-- -[Interface button callback end]---

return UINewFashionForm;
