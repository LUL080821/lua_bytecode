------------------------------------------------
-- author:
-- Date: 2019-05-23
-- File: UIGuildForm.lua
-- Module: UIGuildForm
-- Description: Sectarian basic information processing interface
------------------------------------------------
local L_SetPanel = require "UI.Forms.UIGuildForm.GuildSetPanel"
local L_InfoPanel = require ("UI.Forms.UIGuildForm.GuildInfoPanel")
local L_MemberPanel = require ("UI.Forms.UIGuildForm.GuildMenberPanel")
local UIListMenu = require ("UI.Components.UIListMenu.UIListMenu")
local L_ItemBase = CS.Thousandto.Code.Logic.ItemBase
local UIGuildForm = {
    -- Enter the sect
    EnterSceneBtnGo = nil,
    -- Permission Management
    OfficalBtnGo = nil,
    -- Application List
    ApplyListBtnGo = nil,
    ApplyListRedPoint = nil,

    MemberItem = nil,
    MemberTable = nil,
    MemberTableTrans = nil,
    MemberScroll = nil,
    MemberList = List:New(),
    SelectItem = nil,

    -- Member interaction panel
    InterActivePanel = nil,
    -- Job Change Interface
    OfficalPanel = nil,
    -- Application List Interface
    ApplyPanel = nil,
    -- Settings interface
    SetPanel = nil,
    -- Information interface
    InfoPanel = nil,
}

-- Inheriting Form functions
function UIGuildForm:OnRegisterEvents()
	self:RegisterEvent(UIEventDefine.UIGuildForm_OPEN, self.OnOpen)
    self:RegisterEvent(UIEventDefine.UIGuildForm_CLOSE, self.OnClose)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_GUILD_BASEINFOCHANGE_UPDATE, self.OnUpdateForm)
    self:RegisterEvent(LogicEventDefine.EVENT_COIN_CHANGE_UPDATE, self.SetUnionContribution)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_GUILD_SETTING_UPDATE, self.EventOnSetBack)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_GUILD_MEMBERLIST_UPDATE, self.OnUpdateMemberList)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_GUILD_OPENSETPANEL, self.OnSetPanelOpen)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_GUILD_GUILDAPPLYLIST_UPDATE, self.OnApplyListUpdate)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_GUILD_OUTLINEITEM_UPDATE, self.OnUpdateWagesCount)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_GUILD_GUILDLOGLIST_UPDATE, self.OnUpdateLogList)
end

function UIGuildForm:OnTryHide()
    if self.SetPanel.IsVisible then
        self.SetPanel:Close()
        return false
    end
    if self.InfoPanel.IsVisible then
        return self.InfoPanel:OnTryHide()
    end
    if self.MemberPanel.IsVisible then
        return self.MemberPanel:OnTryHide()
    end
    return true
end

function UIGuildForm:OnFirstShow()
    self:FindAllComponents()
    self.CSForm:AddAlphaAnimation()
end
function UIGuildForm:OnHideBefore()
end
function UIGuildForm:OnShowAfter()
    GameCenter.Network.Send("MSG_Guild.ReqGuildInfo", {})
    self:OnUpdateForm()
    self.SetPanel:Close()
    self.MemberPanel:Close()
end

function UIGuildForm:OnOpen(obj, sender)
    self.CSForm:Show(sender)
    self.CurPanel = GuildSubEnum.Info_Base
    if obj ~= nil then
        self.CurPanel = obj
    end
    self.InfoPanel:Close()
    self.ListMenu:RemoveAll()
    self.ListMenu:AddIcon(GuildSubEnum.Info_Base, nil, FunctionStartIdCode.GuildTabBaseInfo)
    self.ListMenu:AddIcon(GuildSubEnum.Info_Member, nil, FunctionStartIdCode.GuildTabMemberInfo)
    self.ListMenu:AddIcon(GuildSubEnum.Info_RankList, nil, FunctionStartIdCode.GuildTabRankList)
    self.ListMenu:AddIcon(GuildSubEnum.Info_List, nil, FunctionStartIdCode.GuildTabGuildList)
    -- self.ListMenu:AddIcon(GuildSubEnum.Info_Boss, nil, FunctionStartIdCode.GuildBoss)
    -- self.ListMenu:AddIcon(GuildSubEnum.Info_RedPackage, nil, FunctionStartIdCode.GuildTabRedPackage)
    self.ListMenu:SetSelectById(self.CurPanel)
end

-- Find various controls on the UI
function UIGuildForm:FindAllComponents()
    local trans = self.Trans

    local listTrans = trans:Find("UIListMenu")
    self.ListMenu = UIListMenu:OnFirstShow(self.CSForm, listTrans)
    self.ListMenu:ClearSelectEvent();
    self.ListMenu:AddSelectEvent(Utils.Handler(self.OnClickCallBack, self))
    self.ListMenu.IsHideIconByFunc = true

    self.SetPanel = L_SetPanel:OnFirstShow(UIUtils.FindTrans(trans, "SetPanel"), self.CSForm)
    self.InfoPanel = L_InfoPanel:OnFirstShow(UIUtils.FindTrans(trans, "InfoPanel"), self.CSForm)
    self.MemberPanel = L_MemberPanel:OnFirstShow(UIUtils.FindTrans(trans, "MemberPanel"), self.CSForm)
    -- local btn = UIUtils.FindBtn(trans, "Bottom/GuildOfficalBtn")
    -- UIUtils.AddBtnEvent(btn, self.OnClickOfficalBtn, self)
    -- btn = UIUtils.FindBtn(trans, "Bottom/GuildApplyBtn")
    -- UIUtils.AddBtnEvent(btn, self.OnClickApplyListBtn, self)
end

function UIGuildForm:OnClickCallBack(id, select)
    if select then
        if id == GuildSubEnum.Info_Base then
            self.InfoPanel:Open()
        end
        if id == GuildSubEnum.Info_Member then
            self.MemberPanel:Open(id)
        end
        if id == GuildSubEnum.Info_List then
            GameCenter.PushFixEvent(UIEventDefine.UIGuildListForm_OPEN, nil, self.CSForm)
        end
        if id == GuildSubEnum.Info_RankList then
            self.MemberPanel:Open(id)
            GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.GuildTabRankList, false)
        end
        if id == GuildSubEnum.Info_RedPackage then

        end
    else
        if id == GuildSubEnum.Info_Base then
            self.InfoPanel:Close()
        end
        if id == GuildSubEnum.Info_Member then
            self.MemberPanel:Close()
        end
        if id == GuildSubEnum.Info_RankList then
            self.MemberPanel:Close()
        end
        if id == GuildSubEnum.Info_List then
            GameCenter.PushFixEvent(UIEventDefine.UIGuildListForm_CLOSE)
        end
        if id == GuildSubEnum.Info_RedPackage then

        end
    end
end

-- Member list click
function UIGuildForm:OnClickList(item)
    if self.SelectItem ~= nil then
    self.SelectItem:OnSetIsEnable(true)
    end
    self.SelectItem = item
    self.SelectItem:OnSetIsEnable(false)
    self.InterActivePanel.Go:SetActive(true)

    if self.SelectItem.Data ~= nil then
        self.InterActivePanel:OnUpdateItem(self.SelectItem.Data)
    end
end

-- Interface data update
function UIGuildForm:OnUpdateForm(obj, sender)

    self:OnSetButtonShow()
    self.InfoPanel:OnUpdateForm()
end

-- Changes to the tribute
function UIGuildForm:SetUnionContribution(obj, sender)

end

-- Announcement settings return
function UIGuildForm:EventOnSetBack(obj, sender)
    -- self.InfoPanel:OnUpdateForm()
    self.MemberPanel:UpdateSetInfo()
    self.InfoPanel:SetNotice()
end

-- Member list update
function UIGuildForm:OnUpdateMemberList(obj, sender)
    self.MemberPanel:OnUpdateForm()
end

-- Event Trigger Settings Panel Opens
function UIGuildForm:OnSetPanelOpen(obj, sender)
    self.SetPanel:Open()
end

-- Event triggers application list update
function UIGuildForm:OnApplyListUpdate(obj, sender)
    -- self.ApplyListRedPoint:SetActive(GameCenter.MainFunctionSystem:GetAlertFlag(FunctionStartIdCode.GuildTabApplyList))
    self.MemberPanel:UpdateApplyList()
end

-- Event triggers salary collection update
function UIGuildForm:OnUpdateWagesCount(obj, sender)
    -- self.ApplyListRedPoint:SetActive(GameCenter.MainFunctionSystem:GetAlertFlag(FunctionStartIdCode.GuildTabApplyList))
    self.InfoPanel:SetWageCount()
end

-- Log update
function UIGuildForm:OnUpdateLogList()
    self.InfoPanel:SetLogList()
end

-- Display of buttons according to player position settings interface
function UIGuildForm:OnSetButtonShow()
    -- local g = DataConfig.DataGuildOfficial[GameCenter.GuildSystem.Rank]
    -- if g ~= nil then
    --     self.EnterSceneBtnGo:SetActive(true)
    --     self.OfficalBtnGo:SetActive(g.ModifyOfficeAccording == 1)
    --     self.ApplyListBtnGo:SetActive(g.CanAgree == 1)
    --     self.ApplyListRedPoint:SetActive(GameCenter.MainFunctionSystem:GetAlertFlag(FunctionStartIdCode.GuildTabApplyList))
    -- else
    --     self.EnterSceneBtnGo:SetActive(false)
    --     self.OfficalBtnGo:SetActive(false)
    --     self.ApplyListBtnGo:SetActive(false)
    -- end
end
return UIGuildForm