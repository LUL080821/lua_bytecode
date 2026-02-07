
--==============================--
--author:
--Date: 2020-07-02 14:16:21
--File: UISpriteHomeForm.lua
--Module: UISpriteHomeForm
--Description: Lingge Functional Panel
--==============================--

local L_FlySwordSpritePanel = require("UI.Forms.UISpriteHomeForm.UIFlySwordSpritePanel")
local PopupListMenu = require "UI.Components.UIPopoupListMenu.PopupListMenu"
local L_LingPoMenuName = {DataConfig.DataMessageString.Get("C_XIANGQIAN"), DataConfig.DataMessageString.Get("C_FENJIE"), DataConfig.DataMessageString.Get("C_DUIHUAN"), DataConfig.DataMessageString.Get("C_HECHENG"),
DataConfig.DataMessageString.Get("C_CHAIJIE")}
local L_SpriteMenuName = {DataConfig.DataMessageString.Get("C_UI_SPRITEHOME_Mingjian"), DataConfig.DataMessageString.Get("C_UI_SPRITEHOME_BASENAME"), DataConfig.DataMessageString.Get("C_UI_SPRITEHOME_TRAINNAME")}
local UISpriteHomeForm = {
	Param = 0,
}

--Register event function, provided to the CS side to call.
function UISpriteHomeForm:OnRegisterEvents()
	self:RegisterEvent(UIEventDefine.UISpriteHomeForm_OPEN, self.OnOpen)
	self:RegisterEvent(UIEventDefine.UISpriteHomeForm_CLOSE, self.OnClose)
	self:RegisterEvent(LogicEventDefine.EID_EVENT_FUNCTION_UPDATE, self.OnFuncUpdated);
	self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_FLYSWORD_ACTIVE_NEW, self.LvUpdate);
	self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_FLYSWORD_UPDATE, self.LvUpdate);
	self:RegisterEvent(LogicEventDefine.EID_EVENT_SUSPEND_ALL_FORM, self.HideMainAnimation);
	self:RegisterEvent(LogicEventDefine.EID_EVENT_MAIN_HIDEANIMATION, self.HideMainAnimation);	
	self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_LINGPO_EXCHANGE, self.OnLingPoExchange);
	self.CSForm.IsFullScreen = true
end

--The first display function is provided to the CS side to call.
function UISpriteHomeForm:OnFirstShow()
	self:FindAllComponents();
	self:RegUICallback();
end
--Find all components
function UISpriteHomeForm:FindAllComponents()
	local _myTrans = self.Trans;
	self.CloseBtn = UIUtils.FindBtn(_myTrans, "TopRight/CloseBtn")
	self.BackTexture = UIUtils.FindTex(_myTrans, "BgTexture")
	self.TopTexture = UIUtils.FindTex(_myTrans, "TopTex")
	self.RightTexture = UIUtils.FindTex(_myTrans, "RightTex")
	self.FlySwordSpritePanel = L_FlySwordSpritePanel:OnFirstShow(UIUtils.FindTrans(_myTrans, "Base"), self.CSForm)
	self.TitleLabel = UIUtils.FindLabel(_myTrans, "TopLeft/Title")
	self.TitleLabel1 = UIUtils.FindLabel(_myTrans, "TopLeft/Title/Title")
	self.PopupListMenu = PopupListMenu:CreateMenu(UIUtils.FindTrans(_myTrans, "Right/Panel/PopoupList"),Utils.Handler(self.OnClickChildMenu, self), 0)
	self.PopupListMenu.IsUseSelectName = true
	--Add Sword Spirit Menu
	local spriteMenuDataList = List:New()
	spriteMenuDataList:Add({Id = 101, Name = L_SpriteMenuName[1]})
	spriteMenuDataList:Add({Id = 103, Name = L_SpriteMenuName[3]})
	spriteMenuDataList:Add({Id = 102, Name = L_SpriteMenuName[2]})
	self.PopupListMenu:AddMenu(1, DataConfig.DataMessageString.Get("C_JIANLING"), spriteMenuDataList, 1)
	--Add the Spirit Menu
	local lingPoMenuDataList = List:New()
	for i=1,#L_LingPoMenuName do
		local _tab = {Id = 200 + i, Name = L_LingPoMenuName[i]}
		lingPoMenuDataList:Add(_tab)
	end
	self.PopupListMenu:AddMenu(2, DataConfig.DataMessageString.Get("C_LINGPO"), nil, 2, true)
	self.VfxSkinCom = UIUtils.RequireUIVfxSkinCompoent(UIUtils.FindTrans(_myTrans, "Base/UIVfxSkinCompoent"))
	-- self.CSForm.UIRegion = UIFormRegion.TopRegion
	self.MoenyForm = UIUtils.RequireUIMoneyForm(UIUtils.FindTrans(self.Trans, "TopRight/UIMoneyForm"));
	self.CSForm:AddNormalAnimation()
end

--Binding UI components callback function
function UISpriteHomeForm:RegUICallback()
	UIUtils.AddBtnEvent(self.CloseBtn, self.OnClose, self)
end

--Show the previous operation and provide it to the CS side to call.
function UISpriteHomeForm:OnShowBefore()
end

--The operation after display is provided to the CS side to call.
function UISpriteHomeForm:OnShowAfter()
	self.FlySwordSpritePanel:OnClose()
	self.PopupListMenu:BindFuncId(1,FunctionStartIdCode.FlySwordSprite)
	self.PopupListMenu:BindFuncId(2,FunctionStartIdCode.XianPoMain)
	self:RefreshSowrdMenuList(100 + self.Param)
	self.RemainTime = 0
	self.ShowVfx = 0
	self:OnFuncUpdated(GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.FlySwordSpriteTrain));
	local _funcInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.XianPoInlay)
	self:OnFuncUpdated(_funcInfo);
	_funcInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.XianPoDecomposition)
	self:OnFuncUpdated(_funcInfo);
	_funcInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.XianPoExchange)
	self:OnFuncUpdated(_funcInfo);
	_funcInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.XianPoSynthetic)
	self:OnFuncUpdated(_funcInfo);
	if self.OpenFunc == FunctionStartIdCode.FlySwordSprite then
		self.PopupListMenu:OpenMenuList(100 + self.Param)
	else
		self.PopupListMenu:OpenMenuList(200 + self.Param)
	end

	self.CSForm:LoadTexture(self.BackTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_b_jianling"))
	self.CSForm:LoadTexture(self.TopTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_a_103_1"))
	self.CSForm:LoadTexture(self.RightTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_a_103"))
	-- GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_HIDEANIMATION)
    self.MoenyForm:SetMoneyList(3, 12, 2, 1)
	GameCenter.PushFixEvent(UIEventDefine.UISwordMandateForm_CLOSE)
end

--Hide previous operations and provide them to the CS side to call.
function UISpriteHomeForm:OnHideBefore()
	if self.VfxSkinCom ~= nil then
		self.VfxSkinCom:OnDestory()
	end
	GameCenter.PushFixEvent(UIEventDefine.UISpriteGrowUpForm_CLOSE)
	GameCenter.PushFixEvent(UIEventDefine.UIXianPoMainForm_CLOSE)
	-- GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_SHOWANIMATION)
	self.PopupListMenu:CloseAll()
	self.FlySwordSpritePanel:OnClose()
end

--The hidden operation is provided to the CS side to call.
function UISpriteHomeForm:OnHideAfter()
end

function UISpriteHomeForm:RefreshSowrdMenuList(OpenFuncID)
	local spriteMenuDataList = List:New()
	spriteMenuDataList:Add({Id = 101, Name = L_SpriteMenuName[1]})
	if GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.FlySwordSpriteTrain) then
		spriteMenuDataList:Add({Id = 103, Name = L_SpriteMenuName[3]})
	end
	spriteMenuDataList:Add({Id = 102, Name = L_SpriteMenuName[2]})
	self.PopupListMenu:RefreashMenu(1, spriteMenuDataList, OpenFuncID)
end

function UISpriteHomeForm:OnOpen(obj, sender)
	if obj ~= nil then
		self.OpenFunc = obj[1]
		self.Param = obj[2]
		self.SpriteSub = obj[3]
		self.OpenData = obj[4]
	else
		self.OpenFunc = FunctionStartIdCode.FlySwordSprite
	end
	if self.CSForm.IsVisible then
		if self.OpenFunc == FunctionStartIdCode.FlySwordSprite then
			if self.Param == nil then
				self.Param = 1
			end
			self.PopupListMenu:OpenMenuList(100 + self.Param)
		else
			self.PopupListMenu:OpenMenuList(200 + self.Param)
		end
	else
		self.CSForm:Show(sender)
	end
end

function UISpriteHomeForm:Update(dt)
	if self.RemainTime > 0 then
		self.RemainTime = self.RemainTime - dt
		if self.RemainTime <= 0 then
			self.FlySwordSpritePanel:UpdateData()
		end
	end
	if self.PopupListMenu then
        self.PopupListMenu:Update(dt)
	end
	if self.FlySwordSpritePanel then
		self.FlySwordSpritePanel:Update(dt)
	end
	if self.ShowVfx then
		self.ShowVfx = self.ShowVfx + 1
		if self.ShowVfx == 5 then
			self.ShowVfx = nil
			self.VfxSkinCom:OnCreateAndPlay(ModelTypeCode.UIVFX, 223, LayerUtils.GetUITopLayer())
		end
	end
end

--Function refresh
function UISpriteHomeForm:OnFuncUpdated(functioninfo, sender)
	--Add the Spirit Menu
	local checkXianPo = false
	local _visibleChange = functioninfo.CurUpdateType == 1 or functioninfo.CurUpdateType == 0
	if FunctionStartIdCode.FlySwordSpriteTrain == functioninfo.ID then
		self.RemainTime = 0.5
		self.PopupListMenu:ShowChildMenuRedPoint(103, functioninfo.IsShowRedPoint)
	elseif FunctionStartIdCode.XianPoInlay == functioninfo.ID then
		--mosaic
		if _visibleChange and functioninfo.IsVisible then
			checkXianPo = true
		end
	elseif FunctionStartIdCode.XianPoExchange == functioninfo.ID then
		--exchange
		if _visibleChange and functioninfo.IsVisible then
			checkXianPo = true
		end
	elseif FunctionStartIdCode.XianPoDecomposition == functioninfo.ID then
		--break down
		if _visibleChange and functioninfo.IsVisible then
			checkXianPo = true
		end
	elseif FunctionStartIdCode.XianPoSynthetic == functioninfo.ID then
		--synthesis
		if _visibleChange and functioninfo.IsVisible then
			checkXianPo = true
		end
	elseif FunctionStartIdCode.XianPoAnalyse == functioninfo.ID  then
		--Disassembly
		if _visibleChange and functioninfo.IsVisible then
			checkXianPo = true
		end
	end
	if checkXianPo then
		local lingPoMenuDataList = List:New()
		local funcInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.XianPoInlay)
		if funcInfo.IsVisible then
			local _tab = {Id = 201, Name = L_LingPoMenuName[1]}
			lingPoMenuDataList:Add(_tab)
		end
		funcInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.XianPoDecomposition)
		if funcInfo.IsVisible then
			local _tab = {Id = 202, Name = L_LingPoMenuName[2]}
			lingPoMenuDataList:Add(_tab)
		end
		funcInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.XianPoExchange)
		if funcInfo.IsVisible then
			local _tab = {Id = 203, Name = L_LingPoMenuName[3]}
			lingPoMenuDataList:Add(_tab)
		end
		funcInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.XianPoSynthetic)
		if funcInfo.IsVisible then
			local _tab = {Id = 204, Name = L_LingPoMenuName[4]}
			lingPoMenuDataList:Add(_tab)
		end
		funcInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.XianPoAnalyse)
		if funcInfo.IsVisible then
			local _tab = {Id = 205, Name = L_LingPoMenuName[5]}
			lingPoMenuDataList:Add(_tab)
		end
		self.PopupListMenu:RefreashMenu(2, lingPoMenuDataList, -2)
		self:OnLingPoExchange(nil, nil)
	end
end

function UISpriteHomeForm:OnLingPoExchange(obj, sender)
	self.PopupListMenu:ShowChildMenuRedPoint(201, GameCenter.MainFunctionSystem:GetAlertFlag(FunctionStartIdCode.XianPoInlay))
	self.PopupListMenu:ShowChildMenuRedPoint(203, GameCenter.MainFunctionSystem:GetAlertFlag(FunctionStartIdCode.XianPoExchange))
	self.PopupListMenu:ShowChildMenuRedPoint(202, GameCenter.MainFunctionSystem:GetAlertFlag(FunctionStartIdCode.XianPoDecomposition))
	self.PopupListMenu:ShowChildMenuRedPoint(204, GameCenter.MainFunctionSystem:GetAlertFlag(FunctionStartIdCode.XianPoSynthetic))
end

--Upgrade or upgrade
function UISpriteHomeForm:LvUpdate(obj, sender)
	self.RemainTime = 0.5
end

--Hide the main UI camera
function UISpriteHomeForm:HideMainAnimation(obj, sender)
	self:OnClose()
end
--[Interface button callback begin]-

function UISpriteHomeForm:OnClickChildMenu(id)
	if id == -1 then
        return
    end
	if id < 200 and id ~= 2 then
		--The sword spirit page is opened
		GameCenter.PushFixEvent(UIEventDefine.UIXianPoMainForm_CLOSE)
		UIUtils.SetTextByEnum(self.TitleLabel, "C_JIANLING")
		UIUtils.SetTextByEnum(self.TitleLabel1, "C_JIANLING")
		if id > 100 then
			self.Param = id - 100
			if self.Param == 0 then
				self.Param = XianPoMainSubPanel.Begin
			end
		else
			self.Param = id
		end
		if self.Param == 1 then
			self.FlySwordSpritePanel:OnOpen()
			GameCenter.PushFixEvent(UIEventDefine.UISpriteGrowUpForm_CLOSE)
		else
			self.FlySwordSpritePanel:OnClose()
			if self.Param == 2 then
				GameCenter.PushFixEvent(UIEventDefine.UISpriteGrowUpForm_OPEN, {self.SpriteSub, FunctionStartIdCode.FlySwordSpriteBase})
			else
				GameCenter.PushFixEvent(UIEventDefine.UISpriteGrowUpForm_OPEN, {self.OpenData, FunctionStartIdCode.FlySwordSpriteTrain, self.SpriteSub})
			end
			self.SpriteSub = nil
		end
	elseif math.floor( id/200 ) == 1 then
		self.Param = id - 200
		if self.Param == 0 then
			self.Param = XianPoMainSubPanel.Begin
		end
		self.FlySwordSpritePanel:OnClose()
		GameCenter.PushFixEvent(UIEventDefine.UISpriteGrowUpForm_CLOSE)
		GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.XianPoMain, self.Param)
		UIUtils.SetTextByEnum(self.TitleLabel, "C_UI_SPRITEHOME_BTN2")
		UIUtils.SetTextByEnum(self.TitleLabel1, "C_UI_SPRITEHOME_BTN2")
	end
	self.OpenData = nil
end
---[Interface button callback end]---

return UISpriteHomeForm;
