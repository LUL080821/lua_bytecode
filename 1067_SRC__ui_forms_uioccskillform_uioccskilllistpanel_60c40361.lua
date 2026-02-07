--==============================--
-- author:
-- Date: 2019-12-17
-- File: UIOccSkillListPanel.lua
-- Module: UIOccSkillListPanel
-- Description: Skill List Interface
--==============================--
local L_UIListMenu = require "UI.Components.UIListMenu.UIListMenu"
local L_UIOccSkillCellPanel = require "UI.Forms.UIOccSkillForm.UIOccSkillCellPanel"
local L_UIOccSkillStarPanel = require "UI.Forms.UIOccSkillForm.UIOccSkillStarPanel"
local L_UIOccSkillPosPanel = require "UI.Forms.UIOccSkillForm.UIOccSkillPosPanel"

local UIOccSkillListPanel = {
    --transform
    Trans = nil,
    -- Parent node
    Parent = nil,
    -- The form belongs to
    RootForm = nil,
    -- Animation module
    AnimModule = nil,

    -- menu
    ListMenu = nil,
    -- Slot interface
    CellPanel = nil,
    -- Star-up interface
    StarPanel = nil,
    -- Assembly interface
    PosPanel = nil,

    -- Currently selected page
    CurSelectPanel = -1,
}

function UIOccSkillListPanel:OnFirstShow(trans, parent, rootForm)
    self.Trans = trans
    self.Parent = parent
    self.RootForm = rootForm
    -- Create an animation module
    self.AnimModule = UIAnimationModule(self.Trans)
    -- Add an animation
    self.AnimModule:AddAlphaAnimation()
    self.Trans.gameObject:SetActive(false)
    self.IsVisible = false

    self.ListMenu = L_UIListMenu:OnFirstShow(rootForm.CSForm, UIUtils.FindTrans(trans, "UIListMenuTop"))
	self.ListMenu:AddSelectEvent(Utils.Handler(self.OnMenuSelect, self))
	self.ListMenu:AddIcon(FunctionStartIdCode.PlayerSkillCell, nil, FunctionStartIdCode.PlayerSkillCell)
	self.ListMenu:AddIcon(FunctionStartIdCode.PlayerSkillPos, nil, FunctionStartIdCode.PlayerSkillPos)
    self.ListMenu:AddIcon(FunctionStartIdCode.PlayerSkillStar, nil, FunctionStartIdCode.PlayerSkillStar)
    self.ListMenu.IsHideIconByFunc = true
    
    self.CellPanel = L_UIOccSkillCellPanel:OnFirstShow(UIUtils.FindTrans(trans, "CellPanel"), self, rootForm)
    self.StarPanel = L_UIOccSkillStarPanel:OnFirstShow(UIUtils.FindTrans(trans, "StarPanel"), self, rootForm)
    self.PosPanel = L_UIOccSkillPosPanel:OnFirstShow(UIUtils.FindTrans(trans, "EquipPanel"), self, rootForm)
    return self
end

function UIOccSkillListPanel:Show(param)
    -- Play the start-up picture
    self.AnimModule:PlayEnableAnimation()
    if param == nil then
        self.ListMenu:SetSelectByIndex(1)
    else
        self.ListMenu:SetSelectById(param)
    end
    self.IsVisible = true
end

function UIOccSkillListPanel:Hide()
    -- Play Close animation
    self.AnimModule:PlayDisableAnimation()
    self.ListMenu:SetSelectByIndex(-1)
    self.IsVisible = false
end

function UIOccSkillListPanel:OnTryHide()
    if self.PosPanel.IsVisible and not self.PosPanel:OnTryHide() then
        return false
    end
    return true
end

-- Skill transformation
function UIOccSkillListPanel:OnSkillUPCell()
    if self.CurSelectPanel == FunctionStartIdCode.PlayerSkillCell then
        self.CellPanel:RefreshPanel()
    end
end

-- Skill upgrade
function UIOccSkillListPanel:OnSkillOnStar()
    if self.CurSelectPanel == FunctionStartIdCode.PlayerSkillStar then
        self.StarPanel:RefreshPanel()
    end
end

function UIOccSkillListPanel:OnMenuSelect(id, select)
    if select then
        self.CurSelectPanel = id
        if id == FunctionStartIdCode.PlayerSkillCell then
            self.CellPanel:Show()
        elseif id == FunctionStartIdCode.PlayerSkillStar then
            self.StarPanel:Show()
        elseif id == FunctionStartIdCode.PlayerSkillPos then
            self.PosPanel:Show()
        end
    else
        if id == FunctionStartIdCode.PlayerSkillCell then
            self.CellPanel:Hide()
        elseif id == FunctionStartIdCode.PlayerSkillStar then
            self.StarPanel:Hide()
        elseif id == FunctionStartIdCode.PlayerSkillPos then
            self.PosPanel:Hide()
        end
    end
end

function UIOccSkillListPanel:Update(dt)
    if not self.IsVisible then
        return
    end
    self.CellPanel:Update(dt)
end

return UIOccSkillListPanel
