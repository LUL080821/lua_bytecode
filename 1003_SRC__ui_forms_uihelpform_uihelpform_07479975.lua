
--==============================--
-- Author: xsp
-- Date: 2019-07-22
-- File: UIHelpForm.lua
-- Module: UIHelpForm
-- Description: Help interface
--==============================--
local UIHelpForm = {
	CloseBtn = nil,           -- Close button
	CloseBg = nil,            -- Clicking on the background can also close the prompt page
	TipLabel = nil,           -- Prompt text
	TipWidget = nil,          -- The size of the prompt text
	BgTexture = nil,          -- Background material
	BgCollider = nil,         -- Background collider, usually closed, open when there is too much text to move
	ScrollView = nil,         -- Finger Stroke Function
	ID = nil,                 -- help and functionstart table id
    CN_BG_MAX_HEIGHT = 350,   -- Difference between text and background
    CN_HEIGHT_DIFF_VALUE = 50, -- Maximum background height
	BgTextureTop = nil,
	BgTextureBottom = nil,

}

-- Register event functions and provide them to the CS side to call.
function UIHelpForm:OnRegisterEvents()
	self:RegisterEvent(UIEventDefine.UI_HELP_FORM_OPEN, self.OnOpen)
	self:RegisterEvent(UIEventDefine.UI_HELP_FORM_CLOSE, self.OnClose)
end

-- Load function, provided to the CS side to call.
function UIHelpForm:OnLoad()
	self.CSForm.UIRegion = UIFormRegion.TopRegion;
end

-- The first display function is provided to the CS side to call.
function UIHelpForm:OnFirstShow()
	self:FindAllComponents();
	self:RegUICallback();
	self.CSForm:AddNormalAnimation(0.3)
end

-- Callback function that binds UI components
function UIHelpForm:RegUICallback()
	UIUtils.AddBtnEvent(self.CloseBtn,self.OnClickCloseBtn,self);
	UIUtils.AddBtnEvent(self.CloseBg,self.OnClickCloseBtn,self);	
	--self.TipLabel.onChange = Utils.Handler(self.OnLabelChange, self);
end

-- The displayed operation is provided to the CS side to call.
function UIHelpForm:OnShowAfter()	
	self.ID = self.CSForm.ShowParamObj
	self:SetTipLabel();
end

-- Find all components
function UIHelpForm:FindAllComponents()
	local _myTrans = self.Trans;
	self.CloseBtn = UIUtils.FindBtn(_myTrans,"Container/ButtonClose");
	self.CloseBg = UIUtils.FindBtn(_myTrans,"Container/BigBack")
	self.TipLabel = UIUtils.FindLabel(_myTrans,"Container/Panel/Text")
	self.TipWidget = UIUtils.FindWid(_myTrans,"Container/Panel/Text")
	self.BgTextureWid = UIUtils.FindWid(_myTrans,"Container/Background")
	self.BgCollider = UIUtils.FindBoxCollider(_myTrans,"Container/Background")
	self.ScrollView = UIUtils.FindScrollView(_myTrans,"Container/Panel")
	self.BgTextureTop = UIUtils.FindTex(_myTrans,"Container/Background/Tex_top")
	self.BgTextureBottom = UIUtils.FindTex(_myTrans,"Container/Background/Tex_bottom")
	self:LoadTexture(self.BgTextureTop,ImageTypeCode.UI,"tex_help2_new_t")
	self:LoadTexture(self.BgTextureBottom,ImageTypeCode.UI,"tex_help_new_t")

end

-- function UIHelpForm:OnOpen(object,sender)
-- 	if self.CSForm ~= nil then
-- 		if object ~= nil then
-- 			self.ID = object;
-- 	    end
-- 		self.CSForm:Show(sender)
-- 	end
-- end

-- Set prompt text
function UIHelpForm:SetTipLabel()
	if self.ID ~= nil then
		if DataConfig.DataHelp[self.ID] ~= nil then
			local _helpText = DataConfig.DataHelp[self.ID]._Content
			UIUtils.SetTextByStringDefinesID(self.TipLabel, _helpText)
		else
			UIUtils.SetTextByEnum(self.TipLabel, "HELPFORM_MEIZHAODAOXIANGGUANNEIRONG", self.ID)
		end
	else
		UIUtils.SetTextByEnum(self.TipLabel, "HELPFORM_MEIZHAODAOXIANGGUANNEIRONG", self.ID)
	end
	self:OnLabelChange()
	self.ScrollView.repositionWaitFrameCount = 1
	--self.ScrollView:ResetPosition()
end

-- Change the form size when text changes
function UIHelpForm:OnLabelChange()
	
	local _nH = self.TipWidget.height + self.CN_HEIGHT_DIFF_VALUE
	if _nH > self.CN_BG_MAX_HEIGHT then
		_nH = self.CN_BG_MAX_HEIGHT
		self.BgCollider.enabled = true
	else
		self.BgCollider.enabled = false
	end
	self.BgTextureWid.height = _nH
end

-- [Interface button callback begin]--

function UIHelpForm:OnClickCloseBtn()
	self:OnClose();
end

-- -[Interface button callback end]---

return UIHelpForm;
