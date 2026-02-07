------------------------------------------------
-- author:
-- Date: 2019-04-28
-- File: UICopyMapForm.lua
-- Module: UICopyMapForm
-- Description: Copy interface
------------------------------------------------

local UIListMenu = require "UI.Components.UIListMenu.UIListMenuRight"
local UICopySinglePanel = require "UI.Forms.UICopyMapForm.UICopySinglePanel"
local UICopyManyPanel = require "UI.Forms.UICopyMapForm.UICopyManyPanel"
local UICopyMegrePanel = require "UI.Forms.UICopyMapForm.UICopyMegrePanel"
local UICopyMapAutoBuyPanel = require "UI.Forms.UICopyMapForm.UICopyMapAutoBuyPanel"

-- //Module definition
local UICopyMapForm = {
    -- Close button
    CloseBtn = nil,
    -- Single copy pagination
    SinglePanel = nil,
    -- Teaming dungeon pagination
    TeamPanel = nil,
    -- List Menu
    ListMenu = nil,
    -- Selected subpagination ID
    SelectChildID = nil,
    -- Background picture
    BackTex = nil,

    -- The currently selected page
    CurSelectID = 0,

    -- Merge interface
    MergePanel = nil,
    -- Purchase the sweeping volume interface
    BuyItemPanel = nil,
    BackTexPublic = nil,
}

-- Inheriting Form functions
function UICopyMapForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UICopyMapForm_OPEN, self.OnOpen)
    self:RegisterEvent(UIEventDefine.UICopyMapForm_CLOSE, self.OnClose)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_TIAOZHANFUBEN, self.OnTowerCopyUpdate)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_TIANJIEZHIMEN, self.OnTJZMCopyUpdate)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_COPY_VIPBUYCOUNT, self.OnBuyCountUpdate)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_MANYCOPYMAP, self.OnManyCopyUpdate)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_HOOKSITTING, self.OnRefreshExpAddInfo);
end

function UICopyMapForm:OnFirstShow()
    self.CSForm:AddNormalAnimation()

    self.CloseBtn = UIUtils.FindBtn(self.Trans, "Back/CloseBtn")
    UIUtils.AddBtnEvent(self.CloseBtn, self.OnCloseBtnClick, self)

    self.SinglePanel = UICopySinglePanel:OnFirstShow(UIUtils.FindTrans(self.Trans, "DanRenPanel"), self, self)
    self.TeamPanel = UICopyManyPanel:OnFirstShow(UIUtils.FindTrans(self.Trans, "DuoRenPanel"), self, self)

    self.ListMenu = UIListMenu:OnFirstShow(self.CSForm, UIUtils.FindTrans(self.Trans, "UIListMenu"))
    self.ListMenu:ClearSelectEvent()
    self.ListMenu:AddSelectEvent(Utils.Handler(self.OnMenuSelect, self))

    self.ListMenu:AddIcon(UICopyMainPanelEnum.SinglePanel, DataConfig.DataMessageString.Get("C_COPYNAME_DANREN"), FunctionStartIdCode.SingleCopyMap)
    self.ListMenu:AddIcon(UICopyMainPanelEnum.TeamPanel, DataConfig.DataMessageString.Get("C_COPYNAME_EQUIP"), FunctionStartIdCode.TeamCopyMap)

    self.BackTex = UIUtils.FindTex(self.Trans, "Back/BackTex")
    self.BackTexPublic = UIUtils.FindTex(self.Trans, "Back/BackTexPublic")

    self.MoenyForm = UIUtils.RequireUIMoneyForm(UIUtils.FindTrans(self.Trans, "UIMoneyForm"))
    self.MoenyForm:SetMoneyList(3, 12, 2, 1)
    
    self.MergePanel = UICopyMegrePanel:OnFirstShow(UIUtils.FindTrans(self.Trans, "MergePanel"), self, self)
    self.BuyItemPanel = UICopyMapAutoBuyPanel:OnFirstShow(UIUtils.FindTrans(self.Trans, "BuyPanel"), self, self)
end

function UICopyMapForm:OnShowAfter()
    self.CSForm:LoadTexture(self.BackTex,AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_1_2"))
    self.CSForm:LoadTexture(self.BackTexPublic,AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "n_tex_pb"))
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_HIDEANIMATION)

    -- Request all replica information when opening the interface
    GameCenter.CopyMapSystem:ReqOpenStarPanel()
    GameCenter.CopyMapSystem:ReqOpenChallengePanel()
    GameCenter.CopyMapSystem:ReqOpenTJZMPanel()
    GameCenter.CopyMapSystem:ReqOpenManyCopyPanel(GameCenter.CopyMapSystem.ExpCopyID)
    GameCenter.CopyMapSystem:ReqOpenManyCopyPanel(GameCenter.CopyMapSystem.XinMoCopyID)
    GameCenter.CopyMapSystem:ReqOpenManyCopyPanel(GameCenter.CopyMapSystem.WuXingCopyID)
    self.MergePanel:Hide()
    self.BuyItemPanel:Hide()
end

function UICopyMapForm:OnHideBefore()
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_SHOWANIMATION)
end

-- Turn on the event
function UICopyMapForm:OnOpen(obj, sender)
    self.CSForm:Show(sender)
    self.SelectChildID = obj[2]
    self.ListMenu:SetSelectById(obj[1])
end

-- Close Event
function UICopyMapForm:OnClose(obj, sender)
    self.CSForm:Hide()
end

-- Click the Close button
function UICopyMapForm:OnCloseBtnClick()
    self.CSForm:Hide()
end

-- Refresh event for purchases
function UICopyMapForm:OnBuyCountUpdate(obj, sender)
    if self.CurSelectID == UICopyMainPanelEnum.SinglePanel then
        self.SinglePanel:OnBuyCountUpdate()
    elseif self.CurSelectID == UICopyMainPanelEnum.TeamPanel then
        self.TeamPanel:RefreshPaghe()
    end
end

-- Challenge dungeon refresh event
function UICopyMapForm:OnTowerCopyUpdate(obj, sender)
    if self.CurSelectID == UICopyMainPanelEnum.SinglePanel then
        self.SinglePanel:OnTowerCopyUpdate()
    end
end

-- Refresh event of the Gate of Heaven
function UICopyMapForm:OnTJZMCopyUpdate(obj, sender)
    if self.CurSelectID == UICopyMainPanelEnum.SinglePanel then
        self.SinglePanel:OnTJZMCopyUpdate()
    end
end

-- Multiplayer dungeon refresh event
function UICopyMapForm:OnManyCopyUpdate(obj, sender)
    if self.CurSelectID == UICopyMainPanelEnum.TeamPanel then
        self.TeamPanel:RefreshPaghe()
    elseif self.CurSelectID == UICopyMainPanelEnum.SinglePanel then
        self.SinglePanel:OnManyCopyUpdate()
    end
end

-- Experience bonus refresh
function UICopyMapForm:OnRefreshExpAddInfo(obj, sender)
    if self.CurSelectID == UICopyMainPanelEnum.SinglePanel then
        self.SinglePanel:OnRefreshExpAddInfo()
    end
end

-- Menu Select Events
function UICopyMapForm:OnMenuSelect(id, select)
    if select == true then
        self.CurSelectID = id
        if id == UICopyMainPanelEnum.SinglePanel then
            self.SinglePanel:Show(self.SelectChildID)
        elseif id == UICopyMainPanelEnum.TeamPanel then
            self.TeamPanel:Show(self.SelectChildID)
        end
        self.SelectChildID = nil
    else
        if id == UICopyMainPanelEnum.SinglePanel then
            self.SinglePanel:Hide()
        elseif id == UICopyMainPanelEnum.TeamPanel then
            self.TeamPanel:Hide()
        end
    end
end

function UICopyMapForm:Update(dt)
    if self.CurSelectID == UICopyMainPanelEnum.TeamPanel then
        self.TeamPanel:Update(dt)
    elseif self.CurSelectID == UICopyMainPanelEnum.SinglePanel then
        self.SinglePanel:Update(dt)
    end
end

return UICopyMapForm
