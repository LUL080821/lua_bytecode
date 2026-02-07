------------------------------------------------
-- Author: 
-- Date: 2019-03-25
-- File: UIFormManager.lua
-- Module: UIFormManager
-- Description: Lua-side Form Manager
------------------------------------------------
-- Quote
local UIBaseForm = require("UI.Base.UIBaseForm")

-- Define modules
local UIFormManager = {
	AllForms = {},
	UpdateForms = {},
	RenewForms = {}
}

-- Add reload interface
function UIFormManager:AddRenewForm(name)
	self.RenewForms[name] = true
end

-- Do you need to reload
function UIFormManager:IsRenew(name)
	return not(not self.RenewForms[name])
end

-- Create a Lua control script corresponding to ui
function UIFormManager:CreateLuaUIScript(name, gobj)
	-- if AppConfig.IsDestroyOnClose then
	-- 	self:DestroyForm(name)
	-- end
	self:CreateForm(name, gobj)
	if self.RenewForms[name] then
		self.RenewForms[name] = nil
	end
end

-- Create a form
function UIFormManager:CreateForm(name, gobj)
	if self.AllForms[name] then
		-- error(UIUtils.CSFormat(DataConfig.DataMessageString.Get("UIFormManagerTips"), name))
		-- Debug.LogError(string.format("Create UI duplicate %s", name))
		self:DestroyForm(name)
	end
	local _form = require(string.format("UI.Forms.%s.%s", name, name))

	_form._Name_ = name
	_form.GO = gobj
	_form.Trans = gobj.transform

	self.AllForms[name] = _form
	-- When the form that requires Update, place it in UpdateForms.
	if _form.Update then
		self.UpdateForms[name] = _form
	end
	UIBaseForm.BindCSForm(_form, gobj)
end

-- Uninstall a form
function UIFormManager:DestroyForm(name)
	if self.AllForms[name] then
		local _form = self.AllForms[name]
		-- Delete from the collection
		self.AllForms[name] = nil
		if self.UpdateForms[name] then
			self.UpdateForms[name] = nil
		end
		-- Unbind CS form
		UIBaseForm.UnBindCSForm(_form)
		-- Uninstall the form Lua script
		Utils.RemoveRequiredByName(string.format("UI.Forms.%s.%s", name, name))
	end
end

-- Form Update
function UIFormManager:Update(deltaTime)
	-- Determine whether the update container is empty, and then cycle through all forms to update
	if next(self.UpdateForms) ~= nil then
		for _, v in pairs(self.UpdateForms) do
			if v._ActiveSelf_ then
				v:Update(deltaTime)
			end
		end
	end
end

-- Get the UIFormManager on the CS side
function UIFormManager:GetCSUIFormManager()
	if not self.CSUIFormManager then
		self.CSUIFormManager = CS.Thousandto.Code.Center.GameUICenter.UIFormManager;
	end
	return self.CSUIFormManager;
end

-- Get UIRoot
function UIFormManager:GetUIRoot()
	return self:GetCSUIFormManager().UIRoot;
end

-- Get ShadowRoot
function UIFormManager:GetShadowRoot()
	return self:GetCSUIFormManager().UIShadowRoot;
end

-- Get width
function UIFormManager:GetWidth()
	local _screen = CS.UnityEngine.Screen;
	local _height = self:GetHeight();
	return _height * _screen.width / _screen.height;
end

-- Get high
function UIFormManager:GetHeight()
	return self:GetUIRoot().activeHeight;
end

-- Is it a bang screen?
function UIFormManager:IsNotchInScreen()
	return self:GetCSUIFormManager().IsNotchInScreen;
end

-- The current screen direction
function UIFormManager:CurrentOrientation()
	return self:GetCSUIFormManager().CurrentOrientation;
end

function UIFormManager:ShowUITop2DCamera(status)
	-- Debug.Log(string.format("ShowUITop2DCamera: %s", tostring(status)));
	if self:GetCSUIFormManager().UITop2DCamera then
		self:GetCSUIFormManager().UITop2DCamera.enabled = status;
	end
end

return UIFormManager

