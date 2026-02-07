------------------------------------------------
--author:
--Date: 2021-03-08
--File: UITeamMatchForm.lua
--Module: UITeamMatchForm
--Description: Team matching interface
------------------------------------------------
local NGUITools = CS.NGUITools
local L_NetHandler = CS.Thousandto.Code.Logic.NetHandler

local UITeamMatchForm = {
    TeamClone = nil,
    TeamList = nil,
    RefreshBtn = nil,
    RefreshBtnLab = nil,
    CreatTeamBtn = nil,
    LeaveTeamBtn = nil,
    AutoMatchBtn = nil,
    EnterMapBtn = nil,
    AutoMatchBtnLabel = nil,
    NoTeamTips = nil,
    ActivityPanel = nil,
    LastClickObj = nil,
    BgTexture = nil,

    CloneSpan = 90,
    RefreshCDTime = 0,
    RefreshDeltaTime = 0,
    RefreshListCD = 10,
    CurSelectMapID = 0,
    OpenMapCfgDic = Dictionary:New(),
    MapIdGameObjectDic = Dictionary:New(),
    MapID = 0,
    HeadTables = nil,
}

function UITeamMatchForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UITeamMatchForm_OPEN, self.OnOpen, self)
    self:RegisterEvent(UIEventDefine.UITeamMatchForm_CLOSE, self.OnClose, self)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_UITEAMMATCHFORM_UPDATE, self.ShowTeamList, self)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_UITEAMAUTOMATCH_OVER, self.AutoMatchText, self)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_UITEAMFORM_UPDATE, self.UpdateButtonDiaplay, self)
end

function UITeamMatchForm:OnFirstShow()
    self.CSForm:AddAlphaScaleAnimation(nil, 0, 1, 1.05, 1.05, 1, 1, 0.3, true, false)
    local _trans = self.Trans
    self.TeamClone = UIUtils.FindGo(_trans, "TeamClone")
    self.TeamClone:SetActive(false)
    self.TeamList = UIUtils.FindGo(_trans, "TeamList")
    self.RefreshBtn = UIUtils.FindBtn(_trans, "Bottom/RefreshBtn")
    self.RefreshBtnLab = UIUtils.FindLabel(_trans, "Bottom/RefreshBtn/Label")
    self.CreatTeamBtn = UIUtils.FindBtn(_trans, "Bottom/CreatTeamBtn")
    self.LeaveTeamBtn = UIUtils.FindBtn(_trans, "Bottom/LeaveTeamBtn")
    self.AutoMatchBtn = UIUtils.FindBtn(_trans, "Bottom/AutoMatchBtn")
    self.AutoMatchBtnLabel = UIUtils.FindLabel(_trans, "Bottom/AutoMatchBtn/Label")
    self.BgTexture = UIUtils.FindTex(_trans, "NoTeamTips/BgTexture")
    self.NoTeamTips = UIUtils.FindGo(_trans, "NoTeamTips")
    self.ActivityPanel = UIUtils.FindTrans(_trans, "ActivityPanel")
    self.EnterMapBtn = UIUtils.FindBtn(_trans, "Bottom/EnterBtn")
    UIUtils.AddBtnEvent(self.RefreshBtn, self.OnClickRefreshBtn, self)
    UIUtils.AddBtnEvent(self.CreatTeamBtn, self.OnClickCreatTeamBtn, self)
    UIUtils.AddBtnEvent(self.LeaveTeamBtn, self.OnClickLeaveTeamBtn, self)
    UIUtils.AddBtnEvent(self.AutoMatchBtn, self.OnClickAutoMatchBtn, self)
    UIUtils.AddBtnEvent(self.EnterMapBtn, self.EnterMapOnClick, self)
    self.OpenMapCfgDic:Clear()
    self.MapIdGameObjectDic:Clear()
    self.LastClickObj = nil
    self.HeadTables = {}
end

function UITeamMatchForm:OnShowBefore()
    GameCenter.TeamSystem:ReqGetWaitList(0)
end

function UITeamMatchForm:OnShowAfter()
    self:UpdateBtnHide()
    self:DisplayButtons()
    self:ShowActivities()
    self:AutoMatchText(nil)
    --If there is a mapID transmitted from outside, automatically select it
    if self.MapID > 0 and self.OpenMapCfgDic:ContainsKey(self.MapID) then
        if self.MapIdGameObjectDic:ContainsKey(self.MapID) then
            self:ActivityItemOnClick({self.MapID, self.MapIdGameObjectDic[self.MapID]})
        end
    else
        -- Otherwise, the first "All Targets" is selected by default
        local _cloneRoot = UIUtils.FindTrans(self.ActivityPanel, "CloneRoot")
        if _cloneRoot.childCount > 0 then
            self:ActivityItemOnClick({0, _cloneRoot:GetChild(0).gameObject})
        end
    end
    self.CSForm:LoadTexture(self.BgTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_team_bg2"))
end

function UITeamMatchForm:OnHideBefore()
    self.MapID = 0
end

function UITeamMatchForm:OnOpen(obj, sender)
    if obj ~= nil and type(obj) == "number" then
        self.MapID = obj
    end
    self.CSForm:Show(sender)
end

function UITeamMatchForm:OnClose(obj, sender)
    self.RefreshBtn.isEnabled = true
    UIUtils.SetTextByEnum(self.RefreshBtnLab, "TEAM_REFRESHLIST")
    self.RefreshCDTime = 0
    self.CSForm:Hide()
end

function UITeamMatchForm:ClosePanel()
    self:OnClose(nil)
end

function UITeamMatchForm:AutoMatchText(obj, sender)
    if self.AutoMatchBtnLabel ~= nil then
        if GameCenter.TeamSystem.IsMatching then
            UIUtils.SetTextByEnum(self.AutoMatchBtnLabel, "TEAM_MATCHING")
        else
            UIUtils.SetTextByEnum(self.AutoMatchBtnLabel, "TEAM_AUTOPIPEI")
        end
    end
end

function UITeamMatchForm:UpdateButtonDiaplay(obj, sender)
    self:DisplayButtons()
    self:AutoMatchText(nil)
    self:UpdateBtnHide()
end

function UITeamMatchForm:UpdateBtnHide()
    local _enabled = GameCenter.TeamSystem:IsMemberFull()
    self.AutoMatchBtn.gameObject:SetActive(not _enabled)
    self.EnterMapBtn.gameObject:SetActive(_enabled)
end

function UITeamMatchForm:OnClickRefreshBtn()
    GameCenter.TeamSystem:ReqGetWaitList(self.CurSelectMapID)
    self.RefreshCDTime = self.RefreshListCD
    self:SetRefreshListCountDown()
end

function UITeamMatchForm:OnClickCreatTeamBtn()
    local _autoAccept = GameCenter.TeamSystem.MyTeamInfo.IsAutoAcceptApply
    GameCenter.TeamSystem:ReqCreateTeam(self.CurSelectMapID, _autoAccept)
    --After creating a team, you need to update the currently selected team list
    GameCenter.TeamSystem:ReqGetWaitList(self.CurSelectMapID)
end

function UITeamMatchForm:OnClickLeaveTeamBtn()
    Utils.ShowMsgBoxAndBtn(function(code)
        if code == MsgBoxResultCode.Button2 then
            --Sure
            GameCenter.TeamSystem:ReqTeamOpt(GameCenter.GameSceneSystem:GetLocalPlayerID(), 3)
            --After leaving the team, you must also update the currently selected team list
            GameCenter.TeamSystem:ReqGetWaitList(self.CurSelectMapID)
            GameCenter.TeamSystem.IsMatching = false
            self:AutoMatchText(nil)
        end
    end, "C_MSGBOX_CANCEL", "C_MSGBOX_AGREE", "TEAM_SUREQUITTEAM")
end

function UITeamMatchForm:OnClickAutoMatchBtn()
    if GameCenter.TeamSystem.IsMatching then
        local _myTeam = GameCenter.TeamSystem.MyTeamInfo
        GameCenter.TeamSystem:ReqMatchAll(_myTeam.Type, false)
        self:AutoMatchText(nil)
    else
        if self.CurSelectMapID == 0 then
            Utils.ShowPromptByEnum("TEAM_NEEDCHOOSETARGET")
        else
            GameCenter.TeamSystem:ReqMatchAll(self.CurSelectMapID, true)
            --If a different target than the current team is selected, the server will automatically modify the target. Therefore, the list needs to be refreshed.
            GameCenter.TeamSystem:ReqGetWaitList(self.CurSelectMapID)
            self:AutoMatchText(nil)
        end
    end
end

function UITeamMatchForm:EnterMapOnClick()
    -- GameCenter.Netword.Send("MSG_zone.ReqEnterZone", {modelId = GameCenter.TeamSystem.CurrSelectMapID})
    L_NetHandler.SendMessage_EnterCopyMap(GameCenter.TeamSystem.CurrSelectMapID)
end

function UITeamMatchForm:DisplayButtons()
    self.CreatTeamBtn.gameObject:SetActive(not GameCenter.TeamSystem:IsTeamExist())
    self.LeaveTeamBtn.gameObject:SetActive(GameCenter.TeamSystem:IsTeamExist())
end

function UITeamMatchForm:ShowTeamList(object, sender)
    self:UpdateTeamListInfos()
end

function UITeamMatchForm:UpdateTeamListInfos()
    local _listCount = 0
    local _list = GameCenter.TeamSystem.TeamInfos
    local _rootTrans = self.TeamList.transform

    if _list == nil or #_list <= 0 then
        self.NoTeamTips:SetActive(true)
    else
        local _myTeamID = GameCenter.TeamSystem.MyTeamInfo.TeamID
        self.NoTeamTips:SetActive(false)
        _listCount = #_list
        for i = 1, _listCount do
            local _go = nil
            local _member = _list[i]
            if i <= _rootTrans.childCount then
                _go = _rootTrans:GetChild(i - 1).gameObject
            else
                _go = NGUITools.AddChild(self.TeamList, self.TeamClone)
            end
            self:SetTeamItemInfo(_go, _member)
            _go:SetActive(true)
            local _btnGo = UIUtils.FindGo(_go.transform, "ApplyBtn")
            if _member.TeamID == _myTeamID then
                self:SetBtnColor(_btnGo, true)
            else
                self:SetBtnColor(_btnGo, false)
            end
        end
    end

    for i = _listCount + 1, _rootTrans.childCount do
        _rootTrans:GetChild(i - 1).gameObject:SetActive(false)
    end

    local _grid = UIUtils.FindGrid(_rootTrans)
    local _scrollView = UIUtils.FindScrollView(_rootTrans)
    _grid:Reposition()
    _scrollView:ResetPosition()
end

function UITeamMatchForm:SetTeamItemInfo(go, info)
    --avatar
    local _trans = go.transform
    local _head = self.HeadTables[go]
    if _head == nil then
        _head = PlayerHead:New(UIUtils.FindTrans(_trans, "PlayerHeadLua"))
        self.HeadTables[go] = _head
    end
    local _leaderInfo = info:GetLeader()
    _head:SetHeadByMsg(_leaderInfo.PlayerID, _leaderInfo.Career, _leaderInfo.Head)
    local _nameLab = UIUtils.FindLabel(_trans, "NameLabel")
    local _levelLab = PlayerLevel:OnFirstShow(UIUtils.FindTrans(_trans , "Level"))

    local _targetLab = UIUtils.FindLabel(_trans, "Target")
    --name, level, goal
    UIUtils.SetTextByString(_nameLab, _leaderInfo.PlayerName)
    _levelLab:SetLevel(_leaderInfo.Level, true)
    local _cloneMapCfg = DataConfig.DataCloneMap[info.Type]
    if _cloneMapCfg == nil then
        UIUtils.SetTextByEnum(_targetLab, "TEAM_WU")
    else
        UIUtils.SetTextByStringDefinesID(_targetLab,  _cloneMapCfg._DuplicateName)
    end
    --Number of people
    local _memberTrs = UIUtils.FindTrans(_trans, "Member")
    local _childCount = _memberTrs.childCount
    local _memCount = #info.MemberList
    for i = 1, _childCount do
        local _getGo = UIUtils.FindGo(_memberTrs:GetChild(i - 1), "Get")
        if i <= _memCount then
            _getGo:SetActive(true)
        else
            _getGo:SetActive(false)
        end
    end
    --Apply Button
    local _applyBtn = UIUtils.FindBtn(_trans, "ApplyBtn")
    UIUtils.AddBtnEvent(_applyBtn, self.ApplyBtnOnClick, self, info)
end

function UITeamMatchForm:ApplyBtnOnClick(teamInfo)
    GameCenter.TeamSystem:ReqApplyEnter(teamInfo.TeamID)
    GameCenter.TeamSystem:ReqGetWaitList(self.CurSelectMapID)
end

function UITeamMatchForm:SetRefreshListCountDown()
    if self.RefreshCDTime > 0 then
        self.RefreshBtn.isEnabled = false
        UIUtils.SetTextByEnum(self.RefreshBtnLab, "TEAM_REFRESHLISTCD", self.RefreshCDTime)
    else
        self.RefreshBtn.isEnabled = true
        UIUtils.SetTextByEnum(self.RefreshBtnLab, "TEAM_REFRESHLIST")
    end
end

function UITeamMatchForm:Update(dt)
    if self.RefreshCDTime > 0 then
        self.RefreshDeltaTime = self.RefreshDeltaTime + dt
        if self.RefreshDeltaTime >= 1 then
            self.RefreshDeltaTime = self.RefreshDeltaTime - 1
            self.RefreshCDTime = self.RefreshCDTime - 1
            self:SetRefreshListCountDown()
        end
    end
end

function UITeamMatchForm:CloneActivities()
    local _cloneRootTrs = UIUtils.FindTrans(self.ActivityPanel, "CloneRoot")
    local _activityCloneTrs = UIUtils.FindTrans(self.ActivityPanel, "ActivityClone")
    _activityCloneTrs.gameObject:SetActive(false)
    local _keys = self.OpenMapCfgDic:GetKeys()
    local _keyCount = #_keys
    for i = 1, _keyCount do
        local _keyValue = _keys[i]
        local _cloneCfg = self.OpenMapCfgDic[_keyValue]
        local _go = nil
        if i <= _cloneRootTrs.childCount then
            _go = _cloneRootTrs:GetChild(i - 1).gameObject
        else
            _go = NGUITools.AddChild(_cloneRootTrs.gameObject, _activityCloneTrs.gameObject)
        end
        local _trans = _go.transform
        local _disName = UIUtils.FindLabel(_trans, "NormalName")
        local _enName = UIUtils.FindLabel(_trans, "SelectSpr/SelectName")
        if _keyValue == 0 then
            UIUtils.SetTextByEnum(_disName, "TEAM_ALLTARGET")
            UIUtils.SetTextByEnum(_enName, "TEAM_ALLTARGET")
        else
            UIUtils.SetTextByStringDefinesID(_disName,  _cloneCfg._DuplicateName)
            UIUtils.SetTextByStringDefinesID(_enName,  _cloneCfg._DuplicateName)
        end

        if not self.MapIdGameObjectDic:ContainsKey(_keyValue) then
            self.MapIdGameObjectDic:Add(_keyValue, _go)
        end
        --local _texture = UIUtils.FindTex(_trans, "close")
        --self.CSForm:LoadTexture(_texture, ImageTypeCode.UI, "tex_n_b_zudui_" .. i)
        local _selectGo = UIUtils.FindGo(_trans, "SelectSpr")
        _selectGo:SetActive(false)
        
        local _btn = UIUtils.FindBtn(_trans)
        UIUtils.AddBtnEvent(_btn, self.ActivityItemOnClick, self, {_keyValue, _go})
        _go:SetActive(true)
    end
    for i = _keyCount + 1, _cloneRootTrs.childCount do
        _cloneRootTrs:GetChild(i - 1).gameObject:SetActive(false)
    end
    local _grid = UIUtils.FindGrid(_cloneRootTrs)
    local _scrollView = UIUtils.FindScrollView(_cloneRootTrs)
    _grid:Reposition()
    _scrollView:ResetPosition()
end

function UITeamMatchForm:ShowActivities()
    if not self.OpenMapCfgDic:ContainsKey(0) then
        --All activities
        self.OpenMapCfgDic:Add(0, {})
    end
    local _func = function(key, value)
        if value.Teamshow == 1 and self:IsCloneOpen(value) then
            if not self.OpenMapCfgDic:ContainsKey(key) then
                self.OpenMapCfgDic:Add(key, value)
            end
        end
    end
    DataConfig.DataCloneMap:Foreach(_func)
    self:CloneActivities()
end

function UITeamMatchForm:ActivityItemOnClick(params)
    if self.LastClickObj ~= nil then
        --local _openGo = UIUtils.FindGo(self.LastClickObj.transform, "open")
        --_openGo:SetActive(false)
        local _SelGo = UIUtils.FindGo(self.LastClickObj.transform, "SelectSpr")
        _SelGo:SetActive(false)
    end
    --local _goOpenGo = UIUtils.FindGo(params[2].transform, "open")
    --_goOpenGo:SetActive(true)
    local _selGo = UIUtils.FindGo(params[2].transform, "SelectSpr")
    _selGo:SetActive(true)

    self.LastClickObj = params[2]
    local _cfgID = params[1]
    self.CurSelectMapID = _cfgID
    GameCenter.TeamSystem:ReqGetWaitList(_cfgID)
end

function UITeamMatchForm:IsCloneOpen(cfg)
    local _isTaskOver = true
    if string.len(cfg.NeedTaskId) > 0 then
        local _taskStringList = UIUtils.SplitNumber(cfg.NeedTaskId)
        for i = 1, #_taskStringList do
            if _taskStringList[i] ~= 0 and not GameCenter.LuaTaskManager.IsMainTaskOver(_taskStringList[i]) then
                _isTaskOver = false
            end
        end
    end
    local _levelEnough = false
    local _playerLevel = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
    if cfg.MinLv ~= 0 and cfg.MaxLv ~= 0 then
        if _playerLevel >= cfg.MinLv and _playerLevel <= cfg.MaxLv then
            _levelEnough = true
        end
    end
    return _levelEnough and _isTaskOver
end

function UITeamMatchForm:SetBtnColor(go, isGray)
    local _trans = go.transform
    local _spr = UIUtils.FindSpr(_trans)
    if _spr ~= nil then
        _spr.IsGray = isGray
    end

    local _collider = UIUtils.FindBoxCollider(_trans)
    if _collider ~= nil then
        _collider.enabled = not isGray
    end
end

return UITeamMatchForm