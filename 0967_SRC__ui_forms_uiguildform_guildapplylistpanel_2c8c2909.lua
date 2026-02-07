------------------------------------------------
-- author:
-- Date: 2019-05-24
-- File: GuildApplyListPanel.lua
-- Module: GuildApplyListPanel
-- Description: Denomination application list interface
------------------------------------------------
local L_ApplyItem = require "UI.Forms.UIGuildForm.GuildApplyItem"
local L_UICheckBox = require ("UI.Components.UICheckBox")
local GuildApplyListPanel = {
    Trans = nil,
    Go = nil,
    CSForm = nil,
    PlayerItem = nil,
    PlayerGrid = nil,
    PlayerItemList = List:New(),
    PlayerScroll = nil,
    -- Settings button
    SettingBtnGo = nil,
    -- background
    Texture = nil,

    -- Animation module
    AnimModule = nil,
}

-- Create a new object
function GuildApplyListPanel:OnFirstShow(trans, parent)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m.CSForm = parent
    -- Create an animation module
    _m.AnimModule = UIAnimationModule(trans)
    -- Add an animation
    _m.AnimModule:AddNormalAnimation(0.3)
    _m.Go:SetActive(false)
    _m:FindAllComponents()
    _m.IsVisible = false
    return _m
end

-- Find controls
function GuildApplyListPanel:FindAllComponents()
    self.PlayerGrid = UIUtils.FindGrid(self.Trans, "ListScroll/Grid")
    local _gridTrans = UIUtils.FindTrans(self.Trans, "ListScroll/Grid")
    self.PlayerScroll = UIUtils.FindScrollView(self.Trans, "ListScroll")
    for i = 0, _gridTrans.childCount - 1 do
        self.PlayerItem = L_ApplyItem:OnFirstShow(_gridTrans:GetChild(i))
        self.PlayerItemList:Add(self.PlayerItem)
    end
    self.CheckBox = L_UICheckBox:OnFirstShow(UIUtils.FindTrans(self.Trans, "CheckBox"))
    self.CheckBox.CallBack = Utils.Handler(self.OnClickCheckBox, self)
    self.SettingBtnGo = UIUtils.FindGo(self.Trans, "SettingBtn")
    self.Texture = UIUtils.FindTex(self.Trans, "Texture")
    self.NoTexture = UIUtils.FindTex(self.Trans, "NoTexture")
    self.NoTextureGo = UIUtils.FindGo(self.Trans, "NoTexture")
    local _btn = UIUtils.FindBtn(self.Trans, "AgreeAllBtn")
    UIUtils.AddBtnEvent(_btn, self.OnAgreeAllBtnClick, self)
    _btn = UIUtils.FindBtn(self.Trans, "RefuseAllBtn")
    UIUtils.AddBtnEvent(_btn, self.OnRefuseAllBtnClick, self)
    _btn = UIUtils.FindBtn(self.Trans, "SettingBtn")
    UIUtils.AddBtnEvent(_btn, self.OnClickSettingBtn, self)
    -- local _closeBtn = UIUtils.FindBtn(self.Trans, "Back")
    -- UIUtils.AddBtnEvent(_closeBtn, self.Close, self)
    _btn = UIUtils.FindBtn(self.Trans, "CloseBtn")
    UIUtils.AddBtnEvent(_btn, self.Close, self)
end

function GuildApplyListPanel:Open()
    self.AnimModule:PlayEnableAnimation()
    self:OnUpdateForm()
    local g = GameCenter.GuildSystem:OnGetGuildOfficial()
    if g then
        self.CheckBox.Go:SetActive(g.CanAlter == 1)
        self.SettingBtnGo:SetActive(g.CanAlter == 1)
    end
    self.CSForm:LoadTexture(self.Texture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI,"tex_n_d_2"))
    --self.CSForm:LoadTexture(self.NoTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI,"tex_n_z_4_4"))
    self.IsVisible = true
end

function GuildApplyListPanel:Close()
    if self.IsVisible then
        self.AnimModule:PlayDisableAnimation()
    end
    self.IsVisible = false
end

-- Open the settings interface
function GuildApplyListPanel:OnClickSettingBtn()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GUILD_OPENSETPANEL)
end

function GuildApplyListPanel:OnClickCheckBox(check)
    -- GameCenter.Network.Send("MSG_Guild.ReqChangeGuildSetting", {isAutoApply = check})
    GameCenter.GuildSystem:ReqChangeAutoApply(check)
end

-- Reject all
function GuildApplyListPanel:OnRefuseAllBtnClick()
    local _req = {}
    local _temp = GameCenter.GuildSystem:OnGetApplyIdList()
    if #_temp > 0 then
        _req.roleId = _temp
        _req.agree = false
        GameCenter.Network.Send("MSG_Guild.ReqDealApplyInfo", _req)
    end
    self:Close()
end

-- All agree
function GuildApplyListPanel:OnAgreeAllBtnClick()
    local _req = {}
    local _temp = GameCenter.GuildSystem:OnGetApplyIdList()
    if #_temp > 0 then
        _req.roleId = _temp
        _req.agree = true
        GameCenter.Network.Send("MSG_Guild.ReqDealApplyInfo", _req)
    end
    self:Close()
end

-- Refresh the list
function GuildApplyListPanel:OnUpdateForm()
    if not self.Go.activeSelf then
        return
    end
    self.CheckBox:SetChecked(GameCenter.GuildSystem.GuildInfo.isAutoJoin, false)
    local _info = GameCenter.GuildSystem.GuildApplyList;
    for i = 1, #_info do
        local _go = nil
        if (i > #self.PlayerItemList) then
            _go = self.PlayerItem:Clone()
            self.PlayerItemList:Add(_go)
        else
            _go = self.PlayerItemList[i]
        end

        if _go ~= nil then
            _go:SetData(_info[i])
            _go.Go:SetActive(true)
        end
    end
    for i = #_info + 1, #self.PlayerItemList do
        self.PlayerItemList[i].Go:SetActive(false)
    end
    self.NoTextureGo:SetActive(#_info <= 0)
    self.PlayerGrid.repositionNow = true
    self.PlayerScroll:ResetPosition()
end

function GuildApplyListPanel:SetCheckBox()
    if self.Go.activeSelf then
        self.CheckBox:SetChecked(GameCenter.GuildSystem.GuildInfo.isAutoJoin, false)
    end
end
return GuildApplyListPanel