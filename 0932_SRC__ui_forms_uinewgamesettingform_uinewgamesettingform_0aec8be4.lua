------------------------------------------------
-- author:
-- Date: 2019-05-07
-- File: UINewGameSettingForm.lua
-- Module: UINewGameSettingForm
-- Description: The game settings form
------------------------------------------------
local UISettingPanel = require("UI.Forms.UINewGameSettingForm.SettingPanel.UISettingPanel");
local UIFeedBackMainPanel = require("UI.Forms.UINewGameSettingForm.FeedBackPanel.UIFeedBackMainPanel");
local UILanguagePanel = require("UI.Forms.UINewGameSettingForm.LanguagePanel.UILanguagePanel");

local UINewGameSettingForm = {
	-- feedback
	FeedBackPanel = nil,
	-- set up
	SettingPanel = nil,	
	-- Language selection settings
	LanguagePanel = nil,
	-- Background board
	BgTexture = nil,	
	LanguagePanelBgTexture = nil,
	ClearCacheBgTexture = nil,
	ClearCacheScript = nil,
};


-- Register event functions and provide them to the CS side to call.
function UINewGameSettingForm:OnRegisterEvents()
	self:RegisterEvent(UIEventDefine.UIGameSettingForm_FB_OPEN, self.HandleOpenFeedbackForm);
	self:RegisterEvent(UIEventDefine.UIGameSettingForm_OPEN, self.OnOpen);
    self:RegisterEvent(UIEventDefine.UIGameSettingForm_CLOSE, self.OnClose);
	self:RegisterEvent(LogicEventDefine.EID_EVENT_UPDATEGAMESETTING_FORM, self.OnFormUpdate);
	self:RegisterEvent(LogicLuaEventDefine.EID_FEEDBACK_LIST_CHANGED, self.OnFeedBackListChanged);
	self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_HOOKSITTING, self.OnOfflineTimeChanged);
end

function UINewGameSettingForm:HandleOpenFeedbackForm()
	self:OnOpen()
	self:ShowFeedBackPanel()
end

-- The first display function is provided to the CS side to call.
function UINewGameSettingForm:OnFirstShow()
	self:FindAllComponents();	
    self.CSForm:AddNormalAnimation(0.3)
end

-- The displayed operation is provided to the CS side to call.
function UINewGameSettingForm:OnShowAfter()
	self:LoadTexture(self.BgTexture,ImageTypeCode.UI,"tex_n_d_2");
	self:ShowSettingPanel();
	if self.LanguagePanelBgTexture then
		self.CSForm:LoadTexture(self.LanguagePanelBgTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_3"))
	end
	if self.ClearCacheBgTexture then
		self.CSForm:LoadTexture(self.ClearCacheBgTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_3"))
	end
    --GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_HIDEANIMATION)
end


function UINewGameSettingForm:OnHideBefore()
    --GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_SHOWANIMATION)
end

-- The hidden operation is provided to the CS side to call.
function UINewGameSettingForm:OnHideAfter()
	self.FeedBackPanel:Hide();
	self.SettingPanel:Hide();
end

-- Find all components
function UINewGameSettingForm:FindAllComponents()
	local _myTrans = self.Trans;
	self.BgTexture = UIUtils.FindTex(_myTrans,"BGContainer/BackTex");
	self.SettingPanel = UISettingPanel:Initialize(self,_myTrans:Find("SettingPanel"));
	self.FeedBackPanel = UIFeedBackMainPanel:Initialize(self,_myTrans:Find("FeedBackPanel"));
	self.LanguagePanel = UILanguagePanel:Initialize(self,_myTrans:Find("LanguagePanel"));
	GameCenter.FeedBackSystem:Read();	
	self.LanguagePanelBgTexture  = UIUtils.FindTex(_myTrans,"LanguagePanel/BoxBG");
	-- Clean the background form of the resource
	self.ClearCacheBgTexture  = UIUtils.FindTex(_myTrans,"LanChangePanel/Content/FormBg");
	self.ClearCacheScript = UIUtils.FindTrans(_myTrans, "LanChangePanel"):GetComponent("UIClearCachePanelScript")
end

-- Show feedback interface
function UINewGameSettingForm:ShowFeedBackPanel()
	self.FeedBackPanel:Show();
	self.SettingPanel:Hide();
	self.LanguagePanel:Hide();
end
-- Display settings interface
function UINewGameSettingForm:ShowSettingPanel()
	self.FeedBackPanel:Hide();
	self.LanguagePanel:Hide();
	self.SettingPanel:Show();
end

-- Interface refresh
function UINewGameSettingForm:OnFormUpdate()

end

-- Feedback list changes
function UINewGameSettingForm:OnFeedBackListChanged()
	if self.CSForm.IsVisible  and self.FeedBackPanel.IsVisibled then
		self.FeedBackPanel:RefreshListPanel();
	end
end

-- Offline time changes
function UINewGameSettingForm:OnOfflineTimeChanged()
	if self.CSForm.IsVisible  and self.SettingPanel.IsVisibled then
		self.SettingPanel:RefreshOffLineTime();
	end
end
return UINewGameSettingForm;