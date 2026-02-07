------------------------------------------------
--author:
--Date: 2021-03-01
--File: UIMainTeamPanel.lua
--Module: UIMainTeamPanel
--Description: Team pagination on the left side of the main interface
------------------------------------------------

local L_UIMainSubBasePanel = require "UI.Forms.UIMainForm.UIMainSubBasePanel"

local UIMainTeamPanel = {
    NoTeamGo = nil,
    EnterTeamBtn = nil,
    BaseTeamGo = nil,
    TeamMembers = nil,
    LeaveTeamBtn = nil,
    MatchTeamGo = nil,
    CanelMatchBtn = nil,
    MatchTargetName = nil,
    CurMatchCount = nil,
    TeamInfoBtn = nil,
}
--Register events
function UIMainTeamPanel:OnRegisterEvents()
    --Update the team
    self:RegisterEvent(LogicEventDefine.EID_EVENT_UITEAMFORM_UPDATE, self.OnUpdateTeam, self)
end
local L_UIMainTeamItem = nil
function UIMainTeamPanel:OnFirstShow(trans, parent, rootForm)
    setmetatable(self, {__index = L_UIMainSubBasePanel.New()})
    self:BaseFirstShow(trans, parent, rootForm)
    self.NoTeamGo = UIUtils.FindGo(trans, "NoTeam")
    self.EnterTeamBtn = UIUtils.FindBtn(trans, "NoTeam/EnterTeam")
    UIUtils.AddBtnEvent(self.EnterTeamBtn, self.OnEnterTeamBtnClick, self)
    self.BaseTeamGo = UIUtils.FindGo(trans, "TeamInfo")
    self.TeamMembers = {}
    for i = 1, 3 do
        self.TeamMembers[i] = L_UIMainTeamItem:New(self, UIUtils.FindGo(trans, string.format("TeamInfo/%d", i - 1)))
    end
    self.LeaveTeamBtn = UIUtils.FindBtn(trans, "TeamInfo/LeaveBtn")
    UIUtils.AddBtnEvent(self.LeaveTeamBtn, self.OnLeaveTeamBtnClick, self)
    self.MatchTeamGo = UIUtils.FindGo(trans, "MatchTeam")
    self.CanelMatchBtn = UIUtils.FindBtn(trans, "MatchTeam/LeaveBtn")
    UIUtils.AddBtnEvent(self.CanelMatchBtn, self.OnCanelMatchBtnClick, self)
    self.MatchTargetName = UIUtils.FindLabel(trans, "MatchTeam/CopyName")
    self.CurMatchCount = UIUtils.FindLabel(trans, "MatchTeam/Count")
    self.TeamInfoBtn = UIUtils.FindBtn(trans,  "TeamInfo/TeamInfoBtn" )
    UIUtils.AddBtnEvent(self.TeamInfoBtn, self.OnTeamInfoBtnClick, self)
end

function UIMainTeamPanel:OnShowAfter()
    self:OnUpdateTeam(nil)
end
   
function UIMainTeamPanel:Update(dt)
    if not self.IsVisible then
        return
    end
    for i = 1, 3 do
        self.TeamMembers[i]:UpdateHP()
    end
end
-- Enter the team interface button to click
function UIMainTeamPanel:OnEnterTeamBtnClick()
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.Team)
end
---Out of the team button click
function UIMainTeamPanel:OnLeaveTeamBtnClick()
    if not GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.Team) then
        GameCenter.MainFunctionSystem:ShowNotOpenTips(FunctionStartIdCode.Team)
        return
    end
   
    Utils.ShowMsgBox(function(code)
        if code == MsgBoxResultCode.Button2 then
            GameCenter.TeamSystem:ReqTeamOpt(GameCenter.GameSceneSystem:GetLocalPlayerID(), 3)
        end
    end, "C_LEAVETEAM_ASK")
end
function UIMainTeamPanel:OnTeamInfoBtnClick()
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.Team)
end
--Cancel Match Button Click
function UIMainTeamPanel:OnCanelMatchBtnClick()
    local _myTeam = GameCenter.TeamSystem.MyTeamInfo
    GameCenter.TeamSystem:ReqMatchAll(_myTeam.Type, false)
end
--Update the team interface
function UIMainTeamPanel:OnUpdateTeam(obj, sender)
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end
    --Judge whether the team exists
    if GameCenter.TeamSystem:IsTeamExist() then
        self.NoTeamGo:SetActive(false)
        GameCenter.TeamSystem:MyTeamMemberSort()
        local _menbers = GameCenter.TeamSystem.MyTeamInfo.MemberList
        local _menCount = #_menbers
        if GameCenter.TeamSystem.IsMatching then
            --Automatic matching
            self.BaseTeamGo:SetActive(false)
            self.MatchTeamGo:SetActive(true)
            UIUtils.SetTextByProgress(self.CurMatchCount, _menCount, GameCenter.TeamSystem.MaxPlayerNum)
            UIUtils.SetTextByString(self.MatchTargetName, GameCenter.TeamSystem:GetTeamTargetTypeName())
        else
            --There is a team
            self.BaseTeamGo:SetActive(true)
            self.MatchTeamGo:SetActive(false)
            local selfMapID = GameCenter.TeamSystem.MyTeamInfo:GetSelfMapID()
            local _resIndex = 2
            for i = 1, #self.TeamMembers do
                if i <= _menCount then
                    local _mem = _menbers[i]
                    if _mem.IsLeader then
                        self.TeamMembers[1]:SetInfo(_mem, selfMapID)
                    else
                        if _resIndex <= #self.TeamMembers then
                            self.TeamMembers[_resIndex]:SetInfo(_mem, selfMapID)
                            _resIndex = _resIndex + 1
                        end
                    end
                end
            end
            for i = _resIndex, #self.TeamMembers do
                self.TeamMembers[i]:SetInfo(nil, nil)
            end
        end
    else
        --Button Component
        self.BaseTeamGo:SetActive(false)
        self.MatchTeamGo:SetActive(false)
        self.NoTeamGo:SetActive(true)
    end
end

-- Team Member UI
L_UIMainTeamItem = {
    RootGo = nil,
    Btn = nil,
    Level = nil,
    Name = nil,
    Head = nil,
    LiXian = nil,
    Info = nil,
    Parent = nil,
    HPBar = nil,
    LeaderGo = nil,
    PlyaerInfoGo = nil,
    AddPlayerGo = nil,
    AddPlayerBtn = nil,
}

function L_UIMainTeamItem:New(parent, go)
    local _m = Utils.DeepCopy(self)
    _m.RootGo = go
    _m.Parent = parent
    local _trans = go.transform
    _m.PlyaerInfoGo = UIUtils.FindGo(_trans, "PlayerInfo")
    _m.Btn = UIUtils.FindBtn(_trans)
    UIUtils.AddBtnEvent(_m.Btn, _m.OnClick, _m)
    _m.Level = PlayerLevel:OnFirstShow(UIUtils.FindTrans(_trans, "PlayerInfo/Level"))
    _m.Name = UIUtils.FindLabel(_trans, "PlayerInfo/Name")
    _m.Head = PlayerHead:New(UIUtils.FindTrans(_trans, "PlayerInfo/PlayerHeadLua"))
    _m.LiXian = UIUtils.FindGo(_trans, "PlayerInfo/LiXian")
    _m.HPBar = UIUtils.FindSpr(_trans, "PlayerInfo/HpBar")
    _m.LeaderGo = UIUtils.FindGo(_trans, "PlayerInfo/Leader")
    _m.AddPlayerGo = UIUtils.FindGo(_trans, "AddPlayer")
    _m.AddPlayerBtn = UIUtils.FindBtn(_trans, "AddPlayer/AddBtn")
    UIUtils.AddBtnEvent(_m.AddPlayerBtn, _m.AddPlayerBtnOnClick, _m)
    return _m
end
function L_UIMainTeamItem:AddPlayerBtnOnClick()
    if not GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.Team) then
        GameCenter.MainFunctionSystem:ShowNotOpenTips(FunctionStartIdCode.Team)
        return
    end
    GameCenter.PushFixEvent(UIEventDefine.UITeamInviteForm_OPEN)
end
function L_UIMainTeamItem:UpdateHP()
    if self.Info ~= nil then
        self.HPBar.fillAmount = self.Info.HpPro * 0.01
    end
end
function L_UIMainTeamItem:OnClick()
    if self.Info.PlayerID ~= GameCenter.GameSceneSystem:GetLocalPlayerID() then
        GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.LookOtherPlayer, self.Info.PlayerID)
    end
end
function L_UIMainTeamItem:SetInfo(info, selfMapID)
    self.Info = info
    if info == nil then
        self.PlyaerInfoGo:SetActive(false)
        self.AddPlayerGo:SetActive(true)
    else 
        self.PlyaerInfoGo:SetActive(true)
        self.AddPlayerGo:SetActive(false)
        self.HPBar.fillAmount = info.HpPro * 0.01
        UIUtils.SetTextByString(self.Name, info.PlayerName)
        self.Level:SetLevel(info.Level, false)
        self.Head:SetHeadByMsg(info.PlayerID, info.Career, info.Head)
        self.LeaderGo:SetActive(info.IsLeader)
        self.LiXian:SetActive(not info.IsOnline)
    end
end

return UIMainTeamPanel