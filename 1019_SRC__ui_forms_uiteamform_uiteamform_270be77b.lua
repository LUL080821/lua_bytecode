------------------------------------------------
--author:
--Date: 2021-03-11
--File: UITeamForm.lua
--Module: UITeamForm
--Description: Team interface
------------------------------------------------
local L_UIListMenu = require "UI.Components.UIListMenu.UIListMenuRight"

local UITeamForm = {
    CloseBtn = nil,
    FormId = TeamFormSubPanel.Team ,
    UIListMenu = nil,
    UiTexture = nil,
    TeamMatchFormData = nil,
    MoenyForm  = nil,
}

function UITeamForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UITeamForm_OPEN, self.OnOpen, self)
    self:RegisterEvent(UIEventDefine.UITeamForm_CLOSE, self.OnClose, self)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_UITEAM_TEAM_SUCC, self.TeamSucc, self)
end

function UITeamForm:OnFirstShow()
    local _trans = self.Trans
	self.UIListMenu = L_UIListMenu:OnFirstShow(self.CSForm, UIUtils.FindTrans(_trans, "UIListMenu"))
    self.UIListMenu:AddIcon(TeamFormSubPanel.Team, DataConfig.DataMessageString.Get("C_MIAN_TEAM"), FunctionStartIdCode.TeamInfo, "bag_1", "bag_2")
    self.UIListMenu:AddIcon(TeamFormSubPanel.Match, DataConfig.DataMessageString.Get("TEAM_MATCH"), FunctionStartIdCode.TeamMatch, "bag_1", "bag_2")
    self.UIListMenu:AddSelectEvent(Utils.Handler(self.OnMenuSelect,self))
    self.UIListMenu.IsHideIconByFunc = true
    self.CloseBtn = UIUtils.FindBtn(_trans, "closeButton")
    UIUtils.AddBtnEvent(self.CloseBtn, self.OnClickCloseBtn, self)
    self.UiTexture = UIUtils.FindTex(_trans, "Title/BgTexture")
    self.MoenyForm = UIUtils.RequireUIMoneyForm(UIUtils.FindTrans(_trans, "UIMoneyForm"))
	self.MoenyForm:SetMoneyList(3, 12, 2, 1)
    self.CSForm:AddNormalAnimation()
end

function UITeamForm:OnShowAfter()
    self.CSForm:LoadTexture(self.UiTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_1_1"))
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_HIDEANIMATION)
end

function UITeamForm:OnHideBefore()
    self.UIListMenu:SetSelectByIndex(-1)
    self.TeamMatchFormData = nil
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_SHOWANIMATION)
end

--Event trigger opening interface
function UITeamForm:OnOpen(obj, sender)
    self.CSForm:Show(sender)
    self.TeamMatchFormData = nil
    self.FormId = TeamFormSubPanel.Team
    if obj ~= nil then
        local _type = type(obj)
        if _type == "table" then
            self.FormId = obj[1]
            self.TeamMatchFormData = obj[2]
        elseif _type == "number" then
            self.FormId = obj
        end
    end
    self.UIListMenu:SetSelectById(self.FormId)
end

--Event triggers to close the interface
function UITeamForm:OnClose(obj, sender)
    self.CSForm:Hide()
end

function UITeamForm:TeamSucc(obj, sender)
    GameCenter.PushFixEvent(UIEventDefine.UITeamApplyForm_CLOSE)
    GameCenter.PushFixEvent(UIEventDefine.UITeamInviteForm_CLOSE)
    self.UIListMenu:SetSelectById(TeamFormSubPanel.Team)
end

--Click the Close button on the interface
function UITeamForm:OnClickCloseBtn()
    self:OnClose(nil)
end

function UITeamForm:OnMenuSelect(id, b)
    self.FormId = id
    if b then
        self:OpenSubForm(id)
    else
        self:CloseSubForm(id)
    end
end

function UITeamForm:OpenSubForm(id)
    if id == TeamFormSubPanel.Team then
        GameCenter.PushFixEvent(UIEventDefine.UITeamInfoForm_OPEN, nil, self.CSForm)
    elseif id == TeamFormSubPanel.Match then
        GameCenter.PushFixEvent(UIEventDefine.UITeamMatchForm_OPEN, self.TeamMatchFormData, self.CSForm)
    end
end

function UITeamForm:CloseSubForm(id)
    if id == TeamFormSubPanel.Team then
        GameCenter.PushFixEvent(UIEventDefine.UITeamInfoForm_CLOSE)
    elseif id == TeamFormSubPanel.Match then
        GameCenter.PushFixEvent(UIEventDefine.UITeamMatchForm_CLOSE)
    end
end

return UITeamForm
