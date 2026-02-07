------------------------------------------------
-- Author: 
-- Date: 2019-03-25
-- File: UIBaseForm.lua
-- Module: UIBaseForm
-- Description: Defines the basic class of Form, used to mount Lua scripts on gameObject
------------------------------------------------

-- ---:::Module definition:::--------
local UIBaseForm = {}

-- ---:::Definition of member variables in module:::--------
-- Set __index as module,
UIBaseForm.__index = UIBaseForm

-- ========Define a static method for binding and uninstalling LuaForm =========

-- Bind
function UIBaseForm.BindCSForm(form, gobj)
	-- Set UIBaseForm to form's parent class
	setmetatable(form, UIBaseForm);
	-- Get the script for UILuaForm
	local _csForm = UIUtils.FindLuaForm(gobj.transform)
	if _csForm == nil then
		_csForm = UIUtils.FindExtendLuaForm(gobj.transform)
	end
	form.CSForm = _csForm;
	form._ActiveSelf_ = _csForm.IsVisible;

	form._OnShowAfter_ = function(obj)
        if obj.OnShowAfter then
            obj:OnShowAfter();
        end
        form._ActiveSelf_ = true;
	end

	form._OnHideBefore_ = function(obj)
		obj:DestroyAllVFX()
		if obj.UISkinDic then
			obj.UISkinDic:Clear();
		end
		if obj.OnHideBefore then
			return not (obj:OnHideBefore() == false);
		end
		return true;
	end

	form._OnHideAfter_ = function(obj)
		if obj.OnHideAfter then
			obj:OnHideAfter();
		end
		form._ActiveSelf_ = false;
	end

	-- Bind the callback processing function to the CS form
	-- 1. After instantiating the form, register the event first
	_csForm.UIRegisterEvent = Utils.Handler(form.OnRegisterEvents, form);
	-- 2. Then load other sub-prefabricated
	if form.OnLoad then
		_csForm.UILoadEvent = Utils.Handler(form.OnLoad, form);
	end
	-- 3. Determine whether it is the first display
	if form.OnFirstShow then
		_csForm.UIFirstShowEvent = Utils.Handler(form.OnFirstShow, form);
	end
	-- 4. Show previous callbacks
	if form.OnShowBefore then
		_csForm.UIShowBefore = Utils.Handler(form.OnShowBefore, form);
	end
	-- Open the animation to start
	if form.OnShowAnimStart then
		_csForm.UIShowAnimStart = Utils.Handler(form.OnShowAnimStart, form);
	end
	-- Open animation end (onShowAfter if there is an animation)
	if form.OnShowAnimFinish then
		_csForm.UIShowAnimFinish = Utils.Handler(form.OnShowAnimFinish, form);
	end
	-- 5. Callback after display
	_csForm.UIShowAfter = Utils.Handler(form._OnShowAfter_, form);

	-- 1. Hide
	if form.OnTryHide then
		_csForm.UITryHideEvent = Utils.Handler(form.OnTryHide, form);
	end
	-- 2. Hide previous callbacks
	_csForm.UIHideBeforeEvent = Utils.Handler(form._OnHideBefore_, form);
	-- Close the animation start
	if form.OnHideAnimStart then
		_csForm.UIHideAnimStart = Utils.Handler(form.OnHideAnimStart, form);
	end
	-- 3. Hide the callback (closing the animation has ended)
	_csForm.UIHideAfterEvent = Utils.Handler(form._OnHideAfter_, form);
	-- 4. Logout event
	if form.OnUnRegisterEvents then
		_csForm.UIUnRegisterEvent = Utils.Handler(form.OnUnRegisterEvents, form);
	end
	-- 5. Uninstall
	if form.OnUnload then
		_csForm.UIUnLoadEvent = Utils.Handler(form.OnUnload, form);
	end
	-- Close the callback at the end of the animation
	if form.OnHideAnimFinish then
		_csForm.UIHideAnimFinish = Utils.Handler(form.OnHideAnimFinish, form);
	end

	-- Screen Switching
	if form.OnScreenOrientationChanged then
		_csForm.UIScreenOrientationChanged = Utils.Handler(form.OnScreenOrientationChanged, form);
	end

	_csForm.UIFormDestroyEvent = function()
		local _formName = form._Name_;
		if form.OnFormDestroy ~= nil  then
			form:OnFormDestroy();
		end
		if GameCenter.UIFormManager ~= nil then
			 GameCenter.UIFormManager:DestroyForm(_formName);
		end
	end

	-- Form activation
	if form.OnFormActive then
		_csForm.UIFormOnActiveEvent = Utils.Handler(form.OnFormActive, form);
	end
end

-- Unbind
function UIBaseForm.UnBindCSForm(form)
	local _csForm = form.CSForm
	_csForm:ClearAllEvent()
	_csForm:SetHasEverShowed(false)
end

-- ======== Define some functions encapsulations that call CSForm on the Lua side========

-- Register Message
function UIBaseForm:RegisterEvent(eid, func, caller)
	if eid == nil then
		Debug.LogError("UIBaseForm:RegisterEvent(eid=nil)");
		return;
	end
	if func == nil then
		Debug.LogError(string.format("UIBaseForm:RegisterEvent(eid=%s,func=nil)",tostring(eid)));
		return;
	end
	if self.CSForm ~= nil then
		if caller == nil then
			self.CSForm:RegisterEvent(eid, Utils.Handler(func,self));
		else
			self.CSForm:RegisterEvent(eid, Utils.Handler(func,caller));
		end
	else
		Debug.LogError("self.CSForm == nil");
	end
end

-- Setting Texture
function UIBaseForm:LoadTexture(uiTex,type,name,cbFunc,caller)
	if uiTex == nil or type == nil or name == nil or name == "" then 
		Debug.LogError("UIBaseForm:LoadTexture param is invalid!");
		return; 
	end
	if self.CSForm == nil then 
		Debug.LogError("self.CSForm == nil!");
		return;
	end
	if caller == nil then
		self.CSForm:LoadTexture(uiTex,type,name,cbFunc and Utils.Handler(cbFunc,self));
	else
		self.CSForm:LoadTexture(uiTex,type,name,cbFunc and Utils.Handler(cbFunc,caller));
	end
end


-- Open form function called by subclasses
function UIBaseForm:OnOpen(object,sender)
	if self.CSForm ~= nil then
		self.CSForm:OnOpen(object,sender);
	end
end

-- Close form function called by subclasses
function UIBaseForm:OnClose(object,sender)
	if self.CSForm ~= nil then
		self.CSForm:OnClose(object,sender);
	end
end

-- Get the displayed parameters
function UIBaseForm:GetShowParam()
	if self.CSForm ~= nil then
		return self.CSForm.ShowParamObj;
	end
	return nil;
end

-- Get the default hidden parameters
function UIBaseForm:GetHideParam()
	if self.CSForm ~= nil then
		return self.CSForm.HideParamObj;
	end
	return nil;
end

-- Create special effects (One object can only create one special effects)
function UIBaseForm:CreateVFX(trans, id, modelTypeCode, OnFinishedCallBack, isNotSynRQ, layer)
	if not self.VFXDic then
		self.VFXDic = Dictionary:New();
	end
	if self.VFXDic:ContainsKey(trans) then
		self.VFXDic[trans]:OnPlay()
		return self.VFXDic[trans];
	end
	local _uiVfx = UIUtils.RequireUIVfxSkinCompoent(trans);
	self.VFXDic:Add(trans, _uiVfx);
	_uiVfx:OnCreateAndPlay(modelTypeCode or ModelTypeCode.UIVFX, id, layer or LayerUtils.AresUI, OnFinishedCallBack, not isNotSynRQ)
	return _uiVfx;
end

-- Delete special effects
function UIBaseForm:DestroyVFX(trans)
	if self.VFXDic then
		if self.VFXDic:ContainsKey(trans) then
			self.VFXDic[trans]:OnDestory();
			self.VFXDic:Remove(trans)
		end
	end
end

-- Delete all effects
function UIBaseForm:DestroyAllVFX()
	if self.VFXDic then
		local _keys = self.VFXDic:GetKeys();
		for i=1, #_keys do
			self.VFXDic[_keys[i]]:OnDestory();
		end
		self.VFXDic:Clear();
	end
end

-- Set the hierarchy of the form UIFormRegion.cs
-- NoticRegion = 1500000, // Display prompts, automatic deletion and other processing, without player operation
-- TopRegion = 100000, //Top layer,
-- MiddleRegion = 0, //The main functions of the forms are in this level
-- MainRegion = -1000000, //Main interface layer
-- BottomRegion = -2000000, // Similar to HUD, it belongs to the lowest level in this level
function UIBaseForm:SetRegion(FormRegion)
	self.CSForm.UIRegion = FormRegion or UIFormRegion.MiddleRegion
end

return UIBaseForm

