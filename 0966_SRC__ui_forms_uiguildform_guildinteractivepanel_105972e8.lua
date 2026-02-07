------------------------------------------------
-- author:
-- Date: 2019-05-23
-- File: GuildInterActivePanel.lua
-- Module: GuildInterActivePanel
-- Description: Denominational Member Interaction Button List Interface
------------------------------------------------

local GuildInterActivePanel = {
    Trans = nil,
    Go = nil,
    -- Private chat button
    ChatBtnGo = nil,
    -- Add as a friend
    AddFriendBtnGo = nil,
    -- Kick out of the sect
    KickBtnGo = nil,
    -- Check
    LookInfoBtnGo = nil,
    -- Team up
    TeamBtnGo = nil,
    Tabel = nil,
    -- Player information
    Data = nil,

    -- Animation module
    AnimModule = nil,
}

-- Create a new object
function GuildInterActivePanel:OnFirstShow(trans, cSharpForm)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m.CSForm = cSharpForm
    -- Create an animation module
    _m.AnimModule = UIAnimationModule(trans)
    -- Add an animation
    _m.AnimModule:AddNormalAnimation(0.3)
    _m:FindAllComponents()
    _m.Go:SetActive(false)
    _m.IsVisible = false
    return _m
end

 -- Find various controls on the UI
function GuildInterActivePanel:FindAllComponents()
    self.Grid = UIUtils.FindGrid(self.Trans, "Center/Offset/ListPanel")
    local _btn = UIUtils.FindBtn(self.Trans, "Center/Offset/ListPanel/Btn1")
    UIUtils.AddBtnEvent(_btn, self.OnChatClick, self)
    self.ChatBtnGo = UIUtils.FindGo(self.Trans, "Center/Offset/ListPanel/Btn1")
    _btn = UIUtils.FindBtn(self.Trans, "Center/Offset/ListPanel/Btn2")
    UIUtils.AddBtnEvent(_btn, self.OnAddFriendClick, self)
    self.AddFriendBtnGo = UIUtils.FindGo(self.Trans, "Center/Offset/ListPanel/Btn2")
    _btn = UIUtils.FindBtn(self.Trans, "Center/Offset/ListPanel/Btn8")
    UIUtils.AddBtnEvent(_btn, self.OnKickClick, self)
    self.KickBtnGo = UIUtils.FindGo(self.Trans, "Center/Offset/ListPanel/Btn8")
    _btn = UIUtils.FindBtn(self.Trans, "Center/Offset/ListPanel/Btn4")
    UIUtils.AddBtnEvent(_btn, self.OnShieldClick, self)
    self.ShieldBtnLabel = UIUtils.FindLabel(self.Trans, "Center/Offset/ListPanel/Btn4/Label")
    _btn = UIUtils.FindBtn(self.Trans, "Center/Offset/ListPanel/Btn6")
    UIUtils.AddBtnEvent(_btn, self.OnLookInfoBtnClick, self)
    self.LookInfoBtnGo = UIUtils.FindGo(self.Trans, "Center/Offset/ListPanel/Btn6")
    _btn = UIUtils.FindBtn(self.Trans, "Center/Offset/ListPanel/Btn7")
    UIUtils.AddBtnEvent(_btn, self.OnTeamBtnClick, self)
    self.TeamBtnGo = UIUtils.FindGo(self.Trans, "Center/Offset/ListPanel/Btn7")
    _btn = UIUtils.FindBtn(self.Trans, "Center/Offset/ListPanel/Btn5")
    UIUtils.AddBtnEvent(_btn, self.OnOfficalBtnClick, self)
    self.OfficalBtnGo = UIUtils.FindGo(self.Trans, "Center/Offset/ListPanel/Btn5")
    self.BackTexture = UIUtils.FindTex(self.Trans, "Center/Offset/BG1")

    self.PlayerNameLabel = UIUtils.FindLabel(self.Trans, "Center/Offset/PlayerInfo/Name")
    self.PlayerLevelLabel = UIUtils.FindLabel(self.Trans, "Center/Offset/PlayerInfo/Level")
    self.PlayerGuildNameLabel = UIUtils.FindLabel(self.Trans, "Center/Offset/PlayerInfo/Faction")
    self.PlayerFightLabel = UIUtils.FindLabel(self.Trans, "Center/Offset/PlayerInfo/Power")
    self.PlayerHead = PlayerHead:New(UIUtils.FindTrans(self.Trans, "Center/Offset/PlayerInfo/HeadBack"))

    _btn = UIUtils.FindBtn(self.Trans, "Box")
    UIUtils.AddBtnEvent(_btn, self.OnBack, self)
end

function GuildInterActivePanel:Open()
    self.AnimModule:PlayEnableAnimation()
    self.CSForm:LoadTexture(self.BackTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI,"tex_n_d_3_4"))
    self.IsVisible = true
end
function GuildInterActivePanel:Close()
    if self.IsVisible then
        self.AnimModule:PlayDisableAnimation()
    end
    self.IsVisible = false
end

-- Calculate the background length
-- function GuildInterActivePanel:ResetBGSize()
--     local height = 0
--     for i = 1, #self.BtnList do
--         if self.BtnList[i].activeSelf then
--             height = height + self.BtnHeight
--         end
--     end
--     height = height + self.BtnHeight

--     self.BgSpr.height = height
-- end

-- Update interface button
function GuildInterActivePanel:OnUpdateItem(role)
    self.Data = role
    if self.Data == nil then
        Debug.LogError("GuildInterActivePanel role data is nil")
    end
    if self.Data.roleId == GameCenter.GameSceneSystem:GetLocalPlayerID() then
        self:OnBack()
    else
        UIUtils.SetTextByString(self.PlayerNameLabel, role.name)
        UIUtils.SetTextByEnum(self.PlayerLevelLabel, "C_UI_GUILD_LEVELTIPS", CommonUtils.GetLevelDesc(role.lv))
        UIUtils.SetTextByEnum(self.PlayerGuildNameLabel, "C_GUILD_NAMETIPS", GameCenter.GuildSystem.GuildInfo.name)
        UIUtils.SetTextByEnum(self.PlayerFightLabel, "C_GUILD_FIGHT", role.fighting)
        self.PlayerHead:SetHeadByMsg(role.roleId, role.career, role.Head)
        self.AddFriendBtnGo:SetActive(not GameCenter.FriendSystem:IsFriend(self.Data.roleId))
        if GameCenter.FriendSystem:IsShield(self.Data.roleId) then
            self.ChatBtnGo:SetActive(false)
            UIUtils.SetTextByEnum(self.ShieldBtnLabel, "C_FRIEND_SCORIALITY_DELETESHIELD")
        else
            self.ChatBtnGo:SetActive(true)
            UIUtils.SetTextByEnum(self.ShieldBtnLabel, "C_FRIEND_SCORIALITY_SHIELD")
        end
        local item = GameCenter.GuildSystem:OnGetGuildOfficial()
        if item ~= nil then
            if (item.CanKick == 1) and not GameCenter.GuildSystem.IsProxy then
                self.KickBtnGo:SetActive(true)
            else
                self.KickBtnGo:SetActive(false)
            end
            if (item.CanSetOfficial == 1) then
                self.OfficalBtnGo:SetActive(true)
            else
                self.OfficalBtnGo:SetActive(false)
            end
        else
            self.KickBtnGo:SetActive(false)
            self.OfficalBtnGo:SetActive(false)
        end
    end
    self.Grid.repositionNow = true
end

-- Private chat click event
function GuildInterActivePanel:OnChatClick()
    GameCenter.FriendSystem:JumpToChatPrivate( self.Data.roleId, self.Data.name, self.Data.career, self.Data.lv)
    self:OnBack()
end

-- Add friends click event
function GuildInterActivePanel:OnAddFriendClick()
    GameCenter.FriendSystem:AddRelation(FriendType.Friend, self.Data.roleId)
    self:OnBack()
end

-- Appoint a position
function GuildInterActivePanel:OnOfficalBtnClick()
    if self.CallBack then
        self.CallBack(self.Data)
    end
    self:OnBack()
end

-- Kick out the gang click event
function GuildInterActivePanel:OnKickClick()
    if GameCenter.GuildSystem.Rank <= self.Data.rank then
        Utils.ShowPromptByEnum("KickOutGuildFailed")
    else
        Utils.ShowMsgBox(function (x)
            if (x == MsgBoxResultCode.Button2) then
                GameCenter.Network.Send("MSG_Guild.ReqKickOutGuild", {roleId = self.Data.roleId})
            end
        end, "C_GUILD_KICKTIPS", self.Data.name)
    end

    self:OnBack()
end

-- Block events
function GuildInterActivePanel:OnShieldClick()
    if GameCenter.FriendSystem:IsShield(self.Data.roleId) then
        GameCenter.FriendSystem:DeleteRelation(FriendType.Shield, self.Data.roleId)
    else
        GameCenter.FriendSystem:AddRelation(FriendType.Shield, self.Data.roleId)
    end
    self:OnBack()
end

function GuildInterActivePanel:OnLookInfoBtnClick()
    -- GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.LookOtherPlayer, self.Data.roleId)
    local _req = ReqMsg.MSG_Player.ReqLookOtherPlayer:New();
    _req.otherPlayerId = self.Data.roleId
    _req:Send();
    self:OnBack()
end

-- Team up
function GuildInterActivePanel:OnTeamBtnClick()
    if self.Data.lastOffTime > 0 then
        Utils.ShowPromptByEnum("Team_PlayerOfflineInfo")
    else
        GameCenter.TeamSystem:ReqInvite(self.Data.roleId);
        -- GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.InviteTeam, self.Data.roleId)
    end
    self:OnBack()
end

function GuildInterActivePanel:OnBack()
    self:Close()
end
return GuildInterActivePanel
