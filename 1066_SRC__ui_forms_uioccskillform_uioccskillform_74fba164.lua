
--==============================--
-- author:
-- Date: 2019-12-14 17:35:00
-- File: UIOccSkillForm.lua
-- Module: UIOccSkillForm
-- Description: Skill System Interface
--==============================--

local UIListMenu = require "UI.Components.UIListMenu.UIListMenuRight"
local L_UIOccSkillListPanel = require "UI.Forms.UIOccSkillForm.UIOccSkillListPanel"
local L_UIOccPassSkillPanel = require "UI.Forms.UIOccSkillForm.UIOccPassSkillPanel"
local L_UIOccSkillMeridianPanel = require "UI.Forms.UIOccSkillForm.UIOccSkillMeridianPanel"
local L_UIOccXinFaPanel = require "UI.Forms.UIOccSkillForm.UIOccXinFaPanel"

local UIOccSkillForm = {
    -- Close button
    CloseBtn = nil,
    -- menu
    ListMenu = nil,
    -- Background picture
    BackTex = nil,

    -- Skill List
    SkillListPanel = nil,
    -- Passive skills list
    PassListPanel = nil,
    -- Meridians
    MeridianPanel = nil,
    -- The currently selected interface
    CurSelectPanel = 0,
    -- Open interface parameters
    OpenSubParam = nil,
}

-- Register event functions and provide them to the CS side to call.
function UIOccSkillForm:OnRegisterEvents()
	self:RegisterEvent(UIEventDefine.UIOccSkillForm_Open, self.OnOpen)
    self:RegisterEvent(UIEventDefine.UIOccSkillForm_Close, self.OnClose)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_PLAYER_SKILL_UPCELL, self.OnSkillUPCell)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_PLAYER_SKILL_UPSTAR, self.OnSkillOnStar)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_PLAYER_SKILL_UPMERIDIAN, self.OnSkillUpMeridian)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_PLAYER_XINFA_CHANGED,self.RefreshXinFaPanel)
end


-- The first display function is provided to the CS side to call.
function UIOccSkillForm:OnFirstShow()
    self.CSForm:AddNormalAnimation()

    self.CloseBtn = UIUtils.FindBtn(self.Trans, "Back/CloseBtn")
    UIUtils.AddBtnEvent(self.CloseBtn, self.OnCloseBtnClick, self)
    self.BackTex = UIUtils.FindTex(self.Trans, "Back/BackTex")

    self.ListMenu = UIListMenu:OnFirstShow(self.CSForm, UIUtils.FindTrans(self.Trans, "UIListMenu"))
    self.ListMenu:ClearSelectEvent()
    self.ListMenu:AddSelectEvent(Utils.Handler(self.OnMenuSelect, self))
    self.ListMenu.IconOnClick = Utils.Handler(self.OnMenuIconClick,self)

    self.ListMenu:AddIcon(OccSkillSubPanel.AtkPanel, DataConfig.DataMessageString.Get("C_EQUIP_MENUE4"), FunctionStartIdCode.PlayerSkillList)
    self.ListMenu:AddIcon(OccSkillSubPanel.XinFa, nil, FunctionStartIdCode.PlayerSkillXinFa)
    self.ListMenu:AddIcon(OccSkillSubPanel.PassPanel, DataConfig.DataMessageString.Get("Passivity"), FunctionStartIdCode.PassSkill)
    self.ListMenu.IsHideIconByFunc = true
    self.SkillListPanel = L_UIOccSkillListPanel:OnFirstShow(UIUtils.FindTrans(self.Trans, "SkillPanel"), self, self)
    self.PassListPanel = L_UIOccPassSkillPanel:OnFirstShow(UIUtils.FindTrans(self.Trans, "PassPanel"), self, self)
    self.MeridianPanel = L_UIOccSkillMeridianPanel:OnFirstShow(UIUtils.FindTrans(self.Trans, "MeridianPanel"), self, self)
    self.XinFaPanel = L_UIOccXinFaPanel:OnFirstShow(UIUtils.FindTrans(self.Trans, "XinFaPanel"), self, self)

    self.MoenyForm = UIUtils.RequireUIMoneyForm(UIUtils.FindTrans(self.Trans, "UIMoneyForm"))
	self.MoenyForm:SetMoneyList(3, 12, 2, 1)

    self.UIListMenuTop = UIUtils.FindTrans(self.Trans, "SkillPanel/UIListMenuTop")
    self.UIListMenuTop.gameObject:SetActive(true)
end

-- The displayed operation is provided to the CS side to call.
function UIOccSkillForm:OnShowAfter()
    self.CSForm:LoadTexture(self.BackTex,AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_b_jineng"))
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_HIDEANIMATION)
end

-- Hide previous operations and provide them to the CS side to call.
function UIOccSkillForm:OnHideBefore()
    self.ListMenu:SetSelectByIndex(-1)
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_SHOWANIMATION)
    self.CurSelectPanel = -1
end

-- The hidden operation is provided to the CS side to call.
function UIOccSkillForm:OnHideAfter()
end

function UIOccSkillForm:OnTryHide()
    if self.SkillListPanel.IsVisible and not self.SkillListPanel:OnTryHide() then
        return false
    end
    if self.PassListPanel.IsVisible and not self.PassListPanel:OnTryHide() then
        return false
    end
    if self.XinFaPanel.IsVisible and not self.XinFaPanel:OnTryHide() then
        return false
    end
    return true
end

-- Refresh the interface
function UIOccSkillForm:OnFormActive(isActive)
    if isActive then
        if self.CurSelectPanel == OccSkillSubPanel.AtkPanel then
            --self.SkillListPanel:Show()
        elseif self.CurSelectPanel == OccSkillSubPanel.PassPanel then
            self.PassListPanel:Show()
        elseif self.CurSelectPanel == OccSkillSubPanel.XinFa then
            self.XinFaPanel:RefreshPanel()
        end
    end
end

-- Turn on the event
function UIOccSkillForm:OnOpen(obj, sender)
    self.CSForm:Show(sender)
    local _type = type(obj)
    if _type == "number" then
        self.ListMenu:SetSelectById(obj)
    elseif _type == "table" then
        self.OpenSubParam = obj[2]
        self.ListMenu:SetSelectById(obj[1])
    else
        self.ListMenu:SetSelectByIndex(1)
    end
end

-- Close Event
function UIOccSkillForm:OnClose(obj, sender)
    self.CSForm:Hide()
    self.ListMenu:SetSelectByIndex(-1)
end

function UIOccSkillForm:Update(dt)
    self.SkillListPanel:Update(dt)
end

-- Click Close button
function UIOccSkillForm:OnCloseBtnClick()
    self:OnClose(nil, nil)
end

-- Skill transformation
function UIOccSkillForm:OnSkillUPCell()
    if self.CurSelectPanel == OccSkillSubPanel.AtkPanel then
        self.SkillListPanel:OnSkillUPCell()
    end
end

-- Skill upgrade
function UIOccSkillForm:OnSkillOnStar()
    if self.CurSelectPanel == OccSkillSubPanel.AtkPanel then
        self.SkillListPanel:OnSkillOnStar()
    end
end

function UIOccSkillForm:OnSkillUpMeridian()
    if self.CurSelectPanel == OccSkillSubPanel.XinFa then
        self.MeridianPanel:RefreshPanel()
    end
end

function UIOccSkillForm:RefreshXinFaPanel()
    if self.CurSelectPanel == OccSkillSubPanel.XinFa then
        self.XinFaPanel:RefreshPanel()
    end
end

function UIOccSkillForm:RefreshMeridianPanel()
    self.MeridianPanel:Show()
    self.XinFaPanel:Hide()
end

function UIOccSkillForm:OnMenuIconClick(iconData)
    if iconData.ID == OccSkillSubPanel.Meridian then
        -- If you do not choose the mind method, open the mind method selection interface
        local _merId = GameCenter.PlayerSkillSystem.CurSelectMerId
        if _merId == 0 then
            GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.PlayerSkillXinFa)
            return false
        end
    end
    return true
end

-- Page click
function UIOccSkillForm:OnMenuSelect(id, select)
    if select then
        self.CurSelectPanel = id
        if id == OccSkillSubPanel.AtkPanel then
            self.SkillListPanel:Show(self.OpenSubParam)
            self.OpenSubParam = nil
        elseif id == OccSkillSubPanel.PassPanel then
            self.PassListPanel:Show()
        -- elseif id == OccSkillSubPanel.FuZhou then
        --     GameCenter.GodBookSystem.ReqGodBookInfo();
        --     GameCenter.PushFixEvent(UIEventDefine.UIGodBookForm_OPEN, nil, self.CSForm)
        elseif self.CurSelectPanel == OccSkillSubPanel.XinFa then
            self.XinFaPanel:RefreshPanel()
        end
    else
        if id == OccSkillSubPanel.AtkPanel then
            self.SkillListPanel:Hide()
        elseif id == OccSkillSubPanel.PassPanel then
            self.PassListPanel:Hide()
        -- elseif id == OccSkillSubPanel.FuZhou then
        --     GameCenter.PushFixEvent(UIEventDefine.UIGodBookForm_CLOSE)
        elseif self.CurSelectPanel == OccSkillSubPanel.XinFa then
            self.XinFaPanel:Hide()
            self.MeridianPanel:Hide()
        end
    end
end

return UIOccSkillForm
