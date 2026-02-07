------------------------------------------------
-- Author: 
-- Date: 2021-07-06
-- File: UIFriendApplyRoot.lua
-- Module: UIFriendApplyRoot
-- Description: Friends interface
------------------------------------------------
local L_UIFriendApplyItem = require("UI.Forms.UIFriendForm.Base.UIFriendApplyItem")

local UIFriendApplyRoot = {
    CloseBtn = nil,
    AllAgreeBtn = nil,
    TexBg = nil,
    Trans = nil,
    FriendApplyItem = nil,
    Grid = nil,
    RootForm = nil,
    Parent = nil,
    ApplyList = List:New(),
    -- Animation
    AnimModule = nil,
    IsVisible = false,
}



function UIFriendApplyRoot:OnFirstShow(trans , parent , rootForm)
    self.Trans = trans
    self.Parent = parent
    self.RootForm = rootForm
    self.TexBg = UIUtils.FindTex(trans , "BGTex")
    self.CloseBtn = UIUtils.FindBtn(trans , "BtnClose")
    self.AllAgreeBtn = UIUtils.FindBtn(trans , "ApplyBtn")
    self.Grid = UIUtils.FindGrid(trans , "Scroll View/Grid")
    UIUtils.AddBtnEvent(self.CloseBtn, self.Hide, self)
    UIUtils.AddBtnEvent(self.AllAgreeBtn, self.ApplyBtnClick, self)

    self.FriendApplyItem = nil
    local _parentTrans = self.Grid.transform
    local _childCount = _parentTrans.childCount
    self.ApplyList:Clear()
    for i = 1, _childCount do
        local _child = _parentTrans:GetChild(i - 1)
        if self.FriendApplyItem == nil then
            self.FriendApplyItem = _child.gameObject
        end
        local item = L_UIFriendApplyItem:New(_child)
        self.ApplyList:Add(item)
    end

    self.AnimModule = UIAnimationModule(self.Trans)
    self.AnimModule:AddNormalAnimation(0.3)
    self.IsVisible = false
    return self
end

function UIFriendApplyRoot:RefreshApplyList()
    local infos = GameCenter.FriendSystem:GetApplyList()
    local _infoCount = #infos
    for i = 1, _infoCount do
        if i <= #self.ApplyList then
            local item = self.ApplyList[i]
            item:Init(infos[i])
            item.gameObject:SetActive(true)
        else 
            local item = L_UIFriendApplyItem:New(UnityUtils.Clone(self.FriendApplyItem).transform)
            item:Init(infos[i])
            item.gameObject:SetActive(true)
            self.ApplyList:Add(item)
        end
    end
    for i = _infoCount + 1, #self.ApplyList do
        self.ApplyList[i].gameObject:SetActive(false)
    end
    self.Grid:Reposition()
end

function UIFriendApplyRoot:Open()
    self:RefreshApplyList()
    self.Parent.CSForm:LoadTexture(self.TexBg, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_3"))
    GameCenter.FriendSystem.isHaveNewFriendApply = false
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FRIEND_UPDATE_NEWFRIENDNOTIC, false)
    if not self.IsVisible then
        self.AnimModule:PlayEnableAnimation()
    end
    self.IsVisible = true
end

function UIFriendApplyRoot:Hide()
    for i = 1, self.Grid.transform.childCount do
        self.Grid.transform:GetChild(i-1).gameObject:SetActive(false)
    end
    if self.IsVisible then
        self.AnimModule:PlayDisableAnimation()
    end
    self.IsVisible = false
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FRIEND_UPDATE_NEWFRIENDNOTIC, false)
end

function UIFriendApplyRoot:ApplyBtnClick()
    if #GameCenter.FriendSystem:GetApplyList() == 0 then
        self:Hide()
        return
    end
    for i = 1, #self.ApplyList do
        self.ApplyList[i]:OnAgreeBtnClick()
    end
    self:Hide()
end




return UIFriendApplyRoot