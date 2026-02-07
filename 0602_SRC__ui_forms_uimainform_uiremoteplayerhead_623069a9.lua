------------------------------------------------
--author:
--Date: 2021-02-26
--File: UIRemotePlayerHead.lua
--Module: UIRemotePlayerHead
--Description: Remote player avatar
------------------------------------------------
local L_UIMainSubBasePanel = require "UI.Forms.UIMainForm.UIMainSubBasePanel"
-- Countdown time
local L_CountDownTime = 10

local UIRemotePlayerHead = {
    Lv = nil,
    Name = nil,
    Info = nil,
    HeadBtn = nil,
    CloseBtn = nil,
    Head = nil,
    Player = nil,
    CacheTime = nil,
    SelectedPlayerID = 0,
    -- Whether to count down
    IsCountDown = false,
}
--Register events
function UIRemotePlayerHead:OnRegisterEvents()
    self:RegisterEvent(LogicEventDefine.EID_EVENT_SHOW_REMOTE_PLAYER_HEAD, self.OnOpen, self)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_CLOSE_REMOTE_PLAYER_ALTERNATELY, self.OnClose, self)
end

function UIRemotePlayerHead:OnFirstShow(trans, parent, rootForm)
    setmetatable(self, {__index = L_UIMainSubBasePanel.New()})
    self:BaseFirstShow(trans, parent, rootForm)
    self.Info = UIUtils.FindTrans(trans, "Info")
    self.Info.gameObject:SetActive(false)
    self.Lv = PlayerLevel:OnFirstShow(UIUtils.FindTrans(trans, "Info/Level"))
    self.Name = UIUtils.FindLabel(trans, "Info/Name")
    self.HeadBtn = UIUtils.FindBtn(trans, "Info/Head")
    self.CloseBtn = UIUtils.FindGo(trans, "Info/Close")
	self.Head = PlayerHead:New(UIUtils.FindTrans(trans, "Info/Head/PlayerHead"))
    UIUtils.AddBtnEvent(self.HeadBtn, self.OnHeadBtnClick, self)
    UIEventListener.Get(self.CloseBtn).onPress = Utils.Handler(self.OnCameraPress,self)
end

function UIRemotePlayerHead:Update(dt)
    if not self.IsVisible then
        return
    end
    if self.IsCountDown then
        self.CacheTime = self.CacheTime - dt
        if self.CacheTime <= 0 then
            self:OnHide()
            self.IsCountDown = false
            self.Info.gameObject:SetActive(false)
        end
    end
end
function UIRemotePlayerHead:OnOpen(player, sender)
    if player == nil then
        return
    end
    --Judge whether the player's avatar can be displayed
    if not self:CanShowRPhead(player) then
        return
    end
    self.Info.gameObject:SetActive(true)
    if player.ID ~= self.SelectedPlayerID then
        self.SelectedPlayerID = player.ID
        self.Player = player
        self.Lv:SetLevel(player.Level, false)
        UIUtils.SetTextByString(self.Name, player.Name)
        self.Head:SetHead(player.FashionHeadId, player.FashionFrameId, player.IntOcc, player.ID, player.TexHeadPicID, player.IsShowHeadPic)
        self.CacheTime = L_CountDownTime
        self.IsCountDown = true
    end
end
--Is it possible to select players
function UIRemotePlayerHead:CanShowRPhead(rp)
    if rp == nil then
        return false
    end
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return false
    end
    local _rpID = rp.ID
    if  GameCenter.TeamSystem:IsTeamMember(_rpID) then
        return true
    end
    local _mapCfg = GameCenter.MapLogicSystem.MapCfg
    if _mapCfg == nil then
        return false
    end
    if _mapCfg.PkState == 0 then
        return true
    end
    if _lp:IsStrikeBack(_rpID) then
        return false
    end

    local _pkModle = _lp.PropMoudle.PkModel
    if _pkModle == PKMode.PeaceMode then --Peaceful attack mode, cannot attack
        return true
    elseif _pkModle == PKMode.AllMode then --All Attack Mode
        return false
    elseif _pkModle == PKMode.SelfServer then --This server mode
        return _lp.PropMoudle.ServerID == rp.PropMoudle.ServerID
    elseif _pkModle == PKMode.SceneCampMode then --Scene camp mode
        return _lp.PropMoudle.SceneCampID == rp.PropMoudle.SceneCampID
    elseif _pkModle == PKMode.GuildMode then --guild
        if _lp.GuildID <= 0 then
            return false
        end
        return _lp.GuildID == rp.GuildID
    end
    return true
end
function UIRemotePlayerHead:OnClose(obj, sender)
    self:OnHide()
    self.CacheTime = L_CountDownTime
    self.IsCountDown = false
    self.Info.gameObject:SetActive(false)
    GameCenter.PushFixEvent(UIEventDefine.UISocialTipsForm_CLOSE)
end
function UIRemotePlayerHead:OnHide()
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp ~= nil then
        local seletedPlayer = _lp:GetCurSelectedTarget()
        if seletedPlayer ~= nil and self.Player ~= nil and seletedPlayer.ID == self.Player.ID then
            _lp:SetCurSelectedTargetId(0)
        end
    end
    self.SelectedPlayerID = 0
    self.Player = nil
end
function UIRemotePlayerHead:OnCameraPress(go, b)
    if b then
        self:OnClose(nil, nil)
    end
end
function UIRemotePlayerHead:OnHeadBtnClick()
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.LookOtherPlayer, self.SelectedPlayerID)
end

return UIRemotePlayerHead