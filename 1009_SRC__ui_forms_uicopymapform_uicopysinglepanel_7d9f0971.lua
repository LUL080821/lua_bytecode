------------------------------------------------
-- author:
-- Date: 2019-04-28
-- File: UICopySinglePanel.lua
-- Module: UICopySinglePanel
-- Description: Single copy pagination
------------------------------------------------

local UIListMenu = require "UI.Components.UIListMenu.UIListMenu"
local UITowerPanel = require "UI.Forms.UICopyMapForm.UITowerCopyPanel"
local UIStarPanel = require "UI.Forms.UICopyMapForm.UIStarCopyPanel"
local UITJZMCopyMapPanel = require "UI.Forms.UICopyMapForm.UITJZMCopyMapPanel"
local UIExpCopyMapPanel = require "UI.Forms.UICopyMapForm.UIExpCopyMapPanel"

-- //Module definition
local UICopySinglePanel = {
    -- Current transform
    Trans = nil,
    -- father
    Parent = nil,
    -- Animation module
    AnimModule = nil,
    -- List Menu
    ListMenu = nil,
    -- Tower climbing copy
    TowerCopyPanel = nil,
    -- Star Copy
    StarCopyPanel = nil,
    -- Copy of the Gate of Heaven
    TJZMCopyPanel = nil,
    -- Copy of experience
    ExpCopyPanel = nil,
    -- The currently selected page
    CurSelectPanel = nil,
}

function UICopySinglePanel:OnFirstShow(trans, parent, rootForm)
    self.Trans = trans
    self.Parent = parent
    self.RootForm = rootForm

    -- Create an animation module
    self.AnimModule = UIAnimationModule(self.Trans)
    -- Add an animation
    self.AnimModule:AddAlphaAnimation()

    self.ListMenu = UIListMenu:OnFirstShow(self.Parent.CSForm, UIUtils.FindTrans(self.Trans, "UIListMenu"))
    self.ListMenu:ClearSelectEvent()
    self.ListMenu:AddSelectEvent(Utils.Handler(self.OnMenuSelect, self))
    --self.ListMenu:AddIcon(UISingleCopyPanelEnum.TowerPanel, DataConfig.DataMessageString.Get("C_COPYNAME_WANYAOJUAN"), FunctionStartIdCode.TowerCopyMap)
    -- Block the relic of the Great Power
    --self.ListMenu:AddIcon(UISingleCopyPanelEnum.StarPanel, DataConfig.DataMessageString.Get("C_COPYNAME_DNYF"), FunctionStartIdCode.StarCopyMap)
    --self.ListMenu:AddIcon(UISingleCopyPanelEnum.TJZMPanel, DataConfig.DataMessageString.Get("C_COPYNAME_TJZM"), FunctionStartIdCode.TJZMCopyMap)
    self.ListMenu:AddIcon(UISingleCopyPanelEnum.ExpPanel, DataConfig.DataMessageString.Get("C_COPYNAME_LYYT"), FunctionStartIdCode.ExpCopyMap)
    self.ExpCopyPanel = UIExpCopyMapPanel:OnFirstShow(UIUtils.FindTrans(self.Trans, "ExpPanel"), self, self.RootForm)
    self.TowerCopyPanel = UITowerPanel:OnFirstShow(UIUtils.FindTrans(self.Trans, "TowerCopy"), self, self.RootForm)
    --self.StarCopyPanel = UIStarPanel:OnFirstShow(UIUtils.FindTrans(self.Trans, "StarCopy"), self, self.RootForm)
    self.TJZMCopyPanel = UITJZMCopyMapPanel:OnFirstShow(UIUtils.FindTrans(self.Trans, "TJZMCopy"), self, self.RootForm)
    

    self.Trans.gameObject:SetActive(false)
    return self
end

function UICopySinglePanel:Show(childId)
    local targetId = UISingleCopyPanelEnum.ExpPanel or childId  -- default
    self.ListMenu:SetSelectById(targetId)
    self.AnimModule:PlayEnableAnimation()
--     if childId ~= nil then
--        self.ListMenu:SetSelectById(childId) 
--     else
--         self.ListMenu:SetSelectById(UISingleCopyPanelEnum.TowerPanel)
--     end
--     -- Play the start-up picture
--     self.AnimModule:PlayEnableAnimation()
     end

function UICopySinglePanel:Hide()
    -- Play Close animation
    self.AnimModule:PlayDisableAnimation()
end

function UICopySinglePanel:OnMenuSelect(id, select)
    if select then
        self.CurSelectPanel = id
        if id == UISingleCopyPanelEnum.ExpPanel then
            self.ExpCopyPanel:Show()
            GameCenter.BISystem:ReqClickEvent(BiIdCode.LYYTCopyMapEnter)
        elseif id == UISingleCopyPanelEnum.StarPanel then
            --self.StarCopyPanel:Show()
        elseif id == UISingleCopyPanelEnum.TJZMPanel then
            self.TJZMCopyPanel:Show()
            GameCenter.BISystem:ReqClickEvent(BiIdCode.TJZMCopyMapEnter)
        elseif id == UISingleCopyPanelEnum.TowerPanel then
            self.TowerCopyPanel:Show()
            GameCenter.BISystem:ReqClickEvent(BiIdCode.WYJCopyMapEnter)
        end
    else
        if id == UISingleCopyPanelEnum.TowerPanel then
            self.TowerCopyPanel:Hide()
        elseif id == UISingleCopyPanelEnum.StarPanel then
            --self.StarCopyPanel:Hide()
        elseif id == UISingleCopyPanelEnum.TJZMPanel then
            self.TJZMCopyPanel:Hide()
        elseif id == UISingleCopyPanelEnum.ExpPanel then
            self.ExpCopyPanel:Hide()
        end
    end
end

-- Refresh event for purchases
function UICopySinglePanel:OnBuyCountUpdate()
    if self.CurSelectPanel == UISingleCopyPanelEnum.TJZMPanel then
        self.TJZMCopyPanel:RefreshPage()
    elseif self.CurSelectPanel == UISingleCopyPanelEnum.ExpPanel then
        self.ExpCopyPanel:RefreshPage()
    elseif self.CurSelectPanel == UISingleCopyPanelEnum.StarPanel then
        --self.StarCopyPanel:RefreshPage()
    end
end

-- Refresh the challenge copy
function UICopySinglePanel:OnTowerCopyUpdate()
    self.TowerCopyPanel:RefreshPage()
end

-- Refresh multiplayer copy
function UICopySinglePanel:OnManyCopyUpdate()
    if self.CurSelectPanel == UISingleCopyPanelEnum.ExpPanel then
        self.ExpCopyPanel:RefreshPage()
    elseif self.CurSelectPanel == UISingleCopyPanelEnum.TJZMPanel then
        self.TJZMCopyPanel:RefreshPage()
    elseif self.CurSelectPanel == UISingleCopyPanelEnum.StarPanel then
        --self.StarCopyPanel:RefreshPage()
    end
end

-- Refresh experience bonus
function UICopySinglePanel:OnRefreshExpAddInfo()
    if self.CurSelectPanel == UISingleCopyPanelEnum.ExpPanel then
        self.ExpCopyPanel:RefreshPage()
    end
end

function UICopySinglePanel:OnTJZMCopyUpdate()
    self.TJZMCopyPanel:RefreshPage()
end

function UICopySinglePanel:Update(dt)
    if self.CurSelectPanel == UISingleCopyPanelEnum.TJZMPanel then
        self.TJZMCopyPanel:Update(dt)
    elseif self.CurSelectPanel == UISingleCopyPanelEnum.ExpPanel then
        self.ExpCopyPanel:Update(dt)
    end
end

return UICopySinglePanel
