
--==============================--
-- author:
-- Date: 2020-02-19 17:50:05
-- File: UIGuildActiveBaseForm.lua
-- Module: UIGuildActiveBaseForm
-- Description: Xianmeng movable base
--==============================--
local UIListMenu = require "UI.Components.UIListMenu.UIListMenu"
local UIGuildActiveBaseForm = {
}

-- Register event functions and provide them to the CS side to call.
function UIGuildActiveBaseForm:OnRegisterEvents()
	self:RegisterEvent(UIEventDefine.UIGuildActiveBaseForm_OPEN,self.OnOpen)
	self:RegisterEvent(UIEventDefine.UIGuildActiveBaseForm_CLOSE,self.OnClose)
end

-- The first display function is provided to the CS side to call.
function UIGuildActiveBaseForm:OnFirstShow()
	self:FindAllComponents();
	self:RegUICallback();
end
-- Find all components
function UIGuildActiveBaseForm:FindAllComponents()
	local _myTrans = self.Trans;
	local listTrans = UIUtils.FindTrans(_myTrans, "UIListMenu")
    self.ListMenu = UIListMenu:OnFirstShow(self.CSForm, listTrans)
    self.ListMenu:ClearSelectEvent();
    self.ListMenu:AddSelectEvent(Utils.Handler(self.OnClickCallBack, self))
    self.ListMenu.IsHideIconByFunc = true
end

-- Callback function that binds UI components
function UIGuildActiveBaseForm:RegUICallback()
end

-- The displayed operation is provided to the CS side to call.
function UIGuildActiveBaseForm:OnShowAfter()
end

-- Hide previous operations and provide them to the CS side to call.
function UIGuildActiveBaseForm:OnHideBefore()
end

function UIGuildActiveBaseForm:OnOpen(obj, sender)
    self.CSForm:Show(sender)
    self.CurPanel = FunctionStartIdCode.GuildBoss
    if obj ~= nil then
		self.CurPanel = obj
		if self.CurPanel ~= FunctionStartIdCode.GuildBoss and self.CurPanel ~= FunctionStartIdCode.GuildWar then
			self.CurPanel = FunctionStartIdCode.GuildBoss
		end
	end

	self.ListMenu:RemoveAll()
    self.ListMenu:AddIcon(FunctionStartIdCode.GuildBoss, nil, FunctionStartIdCode.GuildBoss)
    --self.ListMenu:AddIcon(FunctionStartIdCode.GuildWar, nil, FunctionStartIdCode.GuildWar)
    self.ListMenu:SetSelectById(self.CurPanel)
end

-- [Interface button callback begin]--

function UIGuildActiveBaseForm:OnClickCallBack(id, select)
	if select then
		-- Open the subfunction interface
		if id == FunctionStartIdCode.GuildBoss then
			GameCenter.XMBossSystem:ReqOpenGuildBossPannel()
			GameCenter.PushFixEvent(UILuaEventDefine.UIXMBossForm_OPEN,nil,self.CSForm)
		elseif id == FunctionStartIdCode.GuildWar then			
			--GameCenter.PushFixEvent(UILuaEventDefine.UIXmFightForm_OPEN,nil,self.CSForm);
		end
	else
		-- Turn off sub-function
		if id == FunctionStartIdCode.GuildBoss then
			GameCenter.PushFixEvent(UILuaEventDefine.UIXMBossForm_CLOSE,nil,self.CSForm)
		elseif id == FunctionStartIdCode.GuildWar then
			--GameCenter.PushFixEvent(UILuaEventDefine.UIXmFightForm_CLOSE,nil,self.CSForm);
		end
    end
end

-- -[Interface button callback end]---

return UIGuildActiveBaseForm;