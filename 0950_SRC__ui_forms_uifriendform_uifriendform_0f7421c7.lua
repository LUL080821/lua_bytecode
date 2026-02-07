------------------------------------------------
-- Author: 
-- Date: 2021-02-25
-- File: UIFriendForm.lua
-- Module: UIFriendForm
-- Description: Friends interface
------------------------------------------------
local L_UIPingBiRoot = require("UI.Forms.UIFriendForm.Root.UIPingBiRoot")
local L_UIRecentRoot = require("UI.Forms.UIFriendForm.Root.UIRecentRoot")
local L_UIFriendRoot = require("UI.Forms.UIFriendForm.Root.UIFriendRoot")
local L_UIFriendApplyRoot = require("UI.Forms.UIFriendForm.Root.UIFriendApplyRoot")

local UIFriendForm = {
    -- Friends Button
    FriendBtn = nil,
    -- Block button
    ShieldBtn = nil,
    -- Recent Button
    RecentBtn = nil,
    -- Current button
    CurrBtn = nil,
    -- Friends interface
    FriendRoot = nil,
    -- Friend application interface
    FriendApplyRoot = nil,
    -- Blocking interface
    ShieldRoot = nil,
    -- Recent interface
    RecentRoot = nil,
    -- Current interface
    CurrentRoot = nil,
    -- Refresh interval
    OffsetTime = 5,
    -- Refresh the time next time
    NextRefreshTime = 0,
}

-- Register Events
function  UIFriendForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UIFriendForm_OPEN, self.OnOpen)
    self:RegisterEvent(UIEventDefine.UIFriendForm_CLOSE, self.OnClose)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_FRIEND_OPEN_FRIENDPANEL , self.OpenPanel)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_FRIEND_UPDATE_FRIENDLIST , self.OnUpdatePanel)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_FRIEND_UPDATE_INTIMACY , self.UpdateIntimacy)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_FRIEND_UPDATE_FRIENDSHIPPOINT , self.UpdateFriendShipState)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_FRIEND_UPDATE_REDPOINT , self.UpdateRedPointShow)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_FRIENDAPPLY_REFESH , self.ApplyRootRefresh)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_FRIEND_UPDATE_NEWFRIENDNOTIC , self.UpdateApplyBtnRed)
    -- self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_NPCFRIEND_SENDSHIP , self.NPCSendShip)
end

-- The first time the execution is enabled
function UIFriendForm:OnFirstShow()
    self:FindAllComponents()
    self:RegUICallback()
	self.CSForm:AddAlphaScaleAnimation(nil, 0, 1, 1.05, 1.05, 1, 1, 0.3, true, false)
end

-- Execute before opening the interface
function UIFriendForm:OnShowAfter()
    self:SetNextRefreshTime()
    self.FriendApplyRoot:Hide()
end

-- Refresh the friendship point every time you focus (avoid returning from other interfaces to this interface that is not the latest)
function UIFriendForm:OnFormActive()
    self:UpdateFriendShipPoint()
end

-- Set the next refresh time
function UIFriendForm:SetNextRefreshTime()
   self.NextRefreshTime = GameCenter.HeartSystem.ServerTime + self.OffsetTime
end

-- Execute after hidden
function UIFriendForm:OnHideAfter()
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE)
end

-- Execute before hiding
function UIFriendForm:OnHideBefore()
    if self.CurrentRoot ~= nil then 
        self.CurrentRoot:OnClose()  
    end
    GameCenter.FriendSystem.FriendPanelEanble = false
end

-- Event trigger opening interface
function UIFriendForm:OnOpen(obj , sender)
    self.CSForm:Show(sender)
    if obj ~= nil and tonumber(obj) == UnityUtils.GetObjct2Int(FunctionStartIdCode.AddFriend) then
        self:OnClickFriendBtn()
        self.FriendRoot:OnClickAddFriendBtn()
    elseif obj ~= nil and obj == SocialityFormSubPanel.RecentFriend then
        self:OnClickRecentBtn()
    else    
        self:OnClickFriendBtn()
    end
    GameCenter.FriendSystem.FriendPanelEanble = true
    if GameCenter.FriendSystem.isHaveNewFriendApply then
        self.FriendApplyRoot:Open()
    end
end

-- Event triggers the close interface
function UIFriendForm:OnClose(obj , sender)
    GameCenter.FriendSystem.PageType = FriendType.Undefine    
    self.CSForm:Hide()
end

-- Open the friend interface
function UIFriendForm:OpenPanel(obj , sender)
    if obj == FriendType.Recent then
        self:OnClickRecentBtn()
    elseif obj == FriendType.Friend then 
        self:OnClickFriendBtn()
    end
end

-- Refresh the red dots
function UIFriendForm:UpdateRedPointShow(obj , sender)
    if GameCenter.FriendSystem.PageType == FriendType.Undefine then return end 
     
    if obj == FriendType.Recent then
        self.RecentRoot:UpdateRedPointShow()
    elseif obj == FriendType.Friend then 
        self.FriendRoot:UpdateRedPointShow()
    end
    local _recentRed = GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.Friend , FriendType.Recent)
    UIUtils.FindGo(self.RecentBtn.transform , "RedPoint"):SetActive(_recentRed)
    local _friendRed = GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.Friend , FriendType.Friend)
    UIUtils.FindGo(self.FriendBtn.transform , "RedPoint"):SetActive(_friendRed)
end

-- Refresh the list
function UIFriendForm:OnUpdatePanel(obj , sender)
    if obj == nil then return end
    if obj == UnityUtils.GetObjct2Int(GameCenter.FriendSystem.PageType) then
        if obj == UnityUtils.GetObjct2Int(FriendType.Friend) then 
            self.FriendRoot:UpdatePanelInfo()
        elseif obj == UnityUtils.GetObjct2Int(FriendType.Recent) then
            self.RecentRoot:UpdatePanelInfo()
        elseif obj == UnityUtils.GetObjct2Int(FriendType.Shield) then 
            self.ShieldRoot:UpdatePanelInfo()
        end
    end
end

-- Update intimacy
function UIFriendForm:UpdateIntimacy(roleId, intimacy)
    local _pageType = GameCenter.FriendSystem.PageType
    if _pageType == FriendType.Friend then 
        self.FriendRoot:UpdateIntimacy(roleId , intimacy)
    elseif _pageType == FriendType.Recent then
        self.RecentRoot:UpdateIntimacy(roleId , intimacy)
    end
end

-- Refresh the red dot for the application button
function UIFriendForm:UpdateApplyBtnRed(isShow)
    self.FriendRoot:ApplyBtnRed(isShow)
    self.RecentRoot:ApplyBtnRed(isShow)
end


-- Update the status of the friendship point button
function UIFriendForm:UpdateFriendShipState(data)
    if data[1].friendInfo  then
        self.FriendRoot:UpdateFriendshipState(data[1].friendInfo , data[2])
        self.RecentRoot:UpdateFriendshipState(data[1].friendInfo , data[2])
    elseif data[1].npcFriendInfo then
        if GameCenter.FriendSystem.PageType == FriendType.Friend then
            self.FriendRoot.NPCFrienditem:UpdateFriendshipState()
        elseif GameCenter.FriendSystem.PageType == FriendType.Recent then
            self.RecentRoot.NPCFrienditem:UpdateFriendshipState()
        end
    end
    self.FriendRoot:UpdateFriendshipPoint()
    self.RecentRoot:UpdateFriendshipPoint()
end

-- Update the friendship point
function UIFriendForm:UpdateFriendShipPoint(msg)
    self.FriendRoot:UpdateFriendshipPoint()
    self.RecentRoot:UpdateFriendshipPoint()
end

-- Find all components
function UIFriendForm:FindAllComponents()
    local _trans = self.Trans
    self.FriendBtn = UIUtils.FindBtn(_trans , "Center/TagBtns/friendBtn")
    self.ShieldBtn = UIUtils.FindBtn(_trans , "Center/TagBtns/pingBiBtn")
    self.RecentBtn = UIUtils.FindBtn(_trans , "Center/TagBtns/recentBtn")
    UIUtils.FindGo(self.FriendBtn.transform , "Select"):SetActive(false)
    UIUtils.FindGo(self.ShieldBtn.transform , "Select"):SetActive(false)
    UIUtils.FindGo(self.RecentBtn.transform , "Select"):SetActive(false)
     
    self.FriendRoot = L_UIFriendRoot:OnFirstShow(UIUtils.FindTrans(_trans, "Center/friendRoot"),self,self)
    self.ShieldRoot = L_UIPingBiRoot:OnFirstShow(UIUtils.FindTrans(_trans, "Center/pingBiRoot"),self,self)
    self.RecentRoot = L_UIRecentRoot:OnFirstShow(UIUtils.FindTrans(_trans, "Center/recentRoot"),self,self)
    self.FriendApplyRoot = L_UIFriendApplyRoot:OnFirstShow(UIUtils.FindTrans(_trans, "Center/FriendApplyRoot"),self,self)
end

function UIFriendForm:OnTryHide()
    if self.FriendApplyRoot.IsVisible then
        self.FriendApplyRoot:Hide()
        return false
    end
    self.CSForm.Parent:Hide()
    return true
end

-- Register UI events
function UIFriendForm:RegUICallback()
    UIUtils.AddBtnEvent(self.FriendBtn, self.OnClickFriendBtn, self)
    UIUtils.AddBtnEvent(self.ShieldBtn, self.OnClickShieldBtn, self)
    UIUtils.AddBtnEvent(self.RecentBtn, self.OnClickRecentBtn, self)
end

-- Recent Friends Button Click Event
function UIFriendForm:OnClickFriendBtn()
    self:OnClickCallBack(self.FriendBtn)
    self.CurrentRoot = self.FriendRoot
    self.CurrentRoot:OnOpen()
    GameCenter.FriendSystem.PageType = FriendType.Friend
    GameCenter.FriendSystem:ReqGetRelationList(FriendType.Friend)
end

-- Friend button click event
function UIFriendForm:OnClickRecentBtn()
    self:OnClickCallBack(self.RecentBtn)
    self.CurrentRoot = self.RecentRoot
    self.CurrentRoot:OnOpen()
    GameCenter.FriendSystem.PageType = FriendType.Recent
    GameCenter.FriendSystem:ReqGetRelationList(FriendType.Recent)
end

-- Block friend click events
function UIFriendForm:OnClickShieldBtn()
    self:OnClickCallBack(self.ShieldBtn)
    self.CurrentRoot = self.ShieldRoot
    self.CurrentRoot:OnOpen()
    GameCenter.FriendSystem.PageType = FriendType.Shield
    GameCenter.FriendSystem:ReqGetRelationList(FriendType.Shield)
    GameCenter.PushFixEvent(UIEventDefine.UICHATPRIVATEFORM_CLOSE)
end

-- Button click callback
function UIFriendForm:OnClickCallBack(btn)
    if self.CurrBtn ~= nil then
        UIUtils.FindGo(self.CurrBtn.transform , "Select"):SetActive(false)
    end
    self.CurrBtn = btn
    UIUtils.FindGo(self.CurrBtn.transform , "Select"):SetActive(true)
    if self.CurrentRoot ~= nil then 
        self.CurrentRoot:OnClose()
    end
end

--Update
function UIFriendForm:Update()
    if GameCenter.FriendSystem.PageType == FriendType.Recent or GameCenter.FriendSystem.PageType == FriendType.Friend then 
        if GameCenter.HeartSystem.ServerTime >= self.NextRefreshTime then 
            self:SetNextRefreshTime()
            GameCenter.FriendSystem:ReqGetRelationList(GameCenter.FriendSystem.PageType , false)
        end
    end
end

-- Open the friend application interface
function UIFriendForm:OpenApplyRoot()
    self.FriendApplyRoot:Open()
end

-- Refresh the friend application interface
function UIFriendForm:ApplyRootRefresh()
    self.FriendApplyRoot:RefreshApplyList()
end



return UIFriendForm

