------------------------------------------------
-- Author: xc
-- Date: 2019-08-07
-- File: UISelectPlayerPanel.lua
-- Module: UISelectPlayerPanel
-- Description: Select role information
------------------------------------------------
-- Quote
local UISelectPlayerHead =  require "UI.Forms.UICreatePlayerForm.UISelectPlayerHead"
local UISelectPlayerSkin = require("Logic.PlayerRoleList.UISelectPlayerSkin");
local LoginSceneState = require("Logic.Login.LoginSceneState")

local UISelectPlayerPanel = {
    Trs = nil, -- node
    Go = nil, -- node
    PlayerHeads = List:New(), -- avatar
    Parent = nil, -- Parent class
    Skin = nil, -- Select a role SKIN
    SelectTrans = nil, -- Select a role
    EnterBtn = nil,-- Enter button
    DeleteBtn = nil, -- Delete button
    RecoverBtn = nil, --
    CurSelectHead = nil, -- Current character avatar
    AnimModule = nil, -- Animation components
    OnlyHaveGoList = List:New(), -- List of unique objects
    -- Special effects decoration after selection
    VfxDecorate_02 = nil,
    VfxDecorate_03 = nil,
    TipsGo = nil, -- Prompt node

    IsNeedShowDeleteBtn = true,
}
UISelectPlayerPanel.__index = UISelectPlayerPanel

function UISelectPlayerPanel:New(trs,prent)
    local _M = Utils.DeepCopy(self)
    _M.Trs = trs
    _M.Go = trs.gameObject
    _M.Parent = prent
    _M:Init()
    return _M
end

function UISelectPlayerPanel:HavePlayer()
    for i = 1,self.PlayerHeads:Count() do
        if self.PlayerHeads[i].PlayerInfo ~= nil then
            return true
        end
    end
    return false
end

-- Get Components
function UISelectPlayerPanel:FindAllComponents()
    self.Skin = UISelectPlayerSkin:New();
    for i = 0,3 do
        self.PlayerHeads:Add(UISelectPlayerHead:New(UIUtils.FindGo(self.Trs,string.format("FunPanel/Left/Container/SelectOccPanel/0/%d", i)), self))
    end
    self.EnterBtn = UIUtils.FindBtn(self.Trs,"FunPanel/RightButtom/Container/SelectEnterBtn");
    self.SelectTrans = UIUtils.FindTrans(self.Trs,"FunPanel/Left/Container/SelectOccPanel/0/Select")
    self.DeleteBtn = UIUtils.FindBtn(self.SelectTrans,"Content/DeleteBtn")
    self.RecoverBtn =  UIUtils.FindBtn(self.SelectTrans,"Content/RecoverBtn");
    self.VfxDecorate_02 = UIUtils.RequireUIVfxSkinCompoent(UIUtils.FindTrans(self.SelectTrans,"Content/Decorate_02"))
    self.VfxDecorate_03 = UIUtils.RequireUIVfxSkinCompoent(UIUtils.FindTrans(self.SelectTrans,"Content/Decorate_03"))

    self.OnlyHaveGoList:Add(UIUtils.FindGo(self.Trs, "FunPanel/Left/Container/SelectOccPanel"));
    self.OnlyHaveGoList:Add(UIUtils.FindGo(self.Trs, "FunPanel/RightButtom/Container/SelectEnterBtn"));
    self.OnlyHaveGoList:Add(UIUtils.FindGo(self.Trs, "FunPanel/Right/Container/OccDesc/BG"));

    self.TipsGo = UIUtils.FindGo(self.Trs, "FunPanel/RightButtom/Container/GoalTips")

    local _root = UnityUtils.FindSceneRoot("SceneRoot")
    if _root ~= nil then
        local _tran = UIUtils.FindTrans(_root.transform,"[PlayerRoot]/Select")
        if _tran ~= nil then
            self.Skin.PlayerRoot = _tran
        end    
    end
    -- Hong Kong, Macao and Taiwan, block role deletion button
    self.IsNeedShowDeleteBtn = not ((GameCenter.SDKSystem.LocalFGI == 1601) or (GameCenter.SDKSystem.LocalFGI == 1602)or (GameCenter.SDKSystem.LocalFGI == 1603));
    self.DeleteBtn.gameObject:SetActive(self.IsNeedShowDeleteBtn);
    self.AnimModule = UIAnimationModule(self.Trs)  
end

-- Register events on the UI, such as click events, etc.
function UISelectPlayerPanel:RegUICallback()
    UIUtils.AddBtnEvent(self.EnterBtn, self.OnEnterBtnClick, self)
    UIUtils.AddBtnEvent(self.DeleteBtn, self.OnDeleteBtnClick, self)
    UIUtils.AddBtnEvent(self.RecoverBtn, self.OnRecoverBtnClick, self)
end

function UISelectPlayerPanel:OnRegisterEvents()
    self.OnDelPlayerEvent = Utils.Handler(self.OnDelPlayer, self)
    self.OnRecoverPlayerEvent = Utils.Handler(self.OnRecoverPlayer, self)
    self.OnForbidPlayerResultEvent = Utils.Handler(self.OnForbidPlayerResult, self)
    GameCenter.RegFixEventHandle(LogicLuaEventDefine.EID_EVENT_CREATEPLAYER_DELPLAYER, self.OnDelPlayerEvent)
    GameCenter.RegFixEventHandle(LogicLuaEventDefine.EID_EVENT_CREATEPLAYER_RECOVERPLAYER, self.OnRecoverPlayerEvent)
    GameCenter.RegFixEventHandle(LogicLuaEventDefine.EID_EVENT_PLAYER_FORBIDDEN, self.OnForbidPlayerResultEvent)
end

-- De-initialization
function UISelectPlayerPanel:OnUnRegisterEvents()
    GameCenter.UnRegFixEventHandle(LogicLuaEventDefine.EID_EVENT_CREATEPLAYER_DELPLAYER, self.OnDelPlayerEvent)
    GameCenter.UnRegFixEventHandle(LogicLuaEventDefine.EID_EVENT_CREATEPLAYER_RECOVERPLAYER, self.OnRecoverPlayerEvent)
    GameCenter.UnRegFixEventHandle(LogicLuaEventDefine.EID_EVENT_PLAYER_FORBIDDEN, self.OnForbidPlayerResultEvent)
end

function UISelectPlayerPanel:OnOpen()
    self:OnShowBefore()
    self:OnRegisterEvents()
    for i = 1, #self.OnlyHaveGoList do
        self.OnlyHaveGoList[i]:SetActive(true);
    end
    self.TipsGo:SetActive(false);
    self.IsVisible = true
    self:OnShowAfter()
end

function UISelectPlayerPanel:OnClose()
    self:OnHideBefore()
    for i = 1, #self.OnlyHaveGoList do
        self.OnlyHaveGoList[i]:SetActive(false);
    end
    self.IsVisible = false
    self:OnHideAfter()
    self:OnUnRegisterEvents()
  
end


function UISelectPlayerPanel:Init()
    self:FindAllComponents()
    self:RegUICallback()
end

function UISelectPlayerPanel:OnShowAfter()
    self.Skin:Init()
    local _selectHead = nil
    local _usePlayerID = GameCenter.PlayerRoleListSystem:GetUsedCharacter()
    for i=1,self.PlayerHeads:Count() do
        if self.PlayerHeads[i].PlayerInfo ~= nil and self.PlayerHeads[i].PlayerInfo.RoleId == _usePlayerID then
            _selectHead = self.PlayerHeads[i]
            break;
        end
    end
    if _selectHead == nil then
        _selectHead = self.PlayerHeads[1]
    end
    self:SetSelectHead(_selectHead, false)
end

function UISelectPlayerPanel:OnShowBefore()
    if self.VfxDecorate_02 then
        self.VfxDecorate_02:OnCreateAndPlay(ModelTypeCode.UIVFX, 258,LayerUtils.GetAresUILayer())
    end
    GameCenter.LoginSystem.MapLogic:SetState(LoginMapStateCode.SelectRolePanelOpened);
end

function UISelectPlayerPanel:OnHideAfter()
    self.Skin:UnInit()
    if self.VfxDecorate_02 then
        self.VfxDecorate_02:OnDestory();
    end
    
    if self.VfxDecorate_03 then
        self.VfxDecorate_03:OnDestory();
    end
end

function UISelectPlayerPanel:OnHideBefore()

end

function UISelectPlayerPanel:SetPlayerList()
    local _playerList = GameCenter.PlayerRoleListSystem.RoleList
    for i=1,self.PlayerHeads:Count() do
        if _playerList~= nil and i <= _playerList:Count()  then
            self.PlayerHeads[i]:SetInfo(_playerList[i])
        else
            self.PlayerHeads[i]:SetInfo(nil)
        end
    end
end

function UISelectPlayerPanel:Update(dt)
    local _deleteHead = nil
    for i = 1, self.PlayerHeads:Count() do
        if (self.PlayerHeads[i] ~= nil and self.PlayerHeads[i].PlayerInfo ~= nil) then
            self.PlayerHeads[i]:Update(dt)
            if self.PlayerHeads[i].PlayerInfo == nil then
                _deleteHead = self.PlayerHeads[i]
            end
        end
    end

    if self.CurSelectHead ~= nil and self.CurSelectHead == _deleteHead then
        self:SetSeleftFirstHead()
    end

    if self.Skin ~= nil then
        self.Skin:Update(dt)
    end
end


function UISelectPlayerPanel:OnEnterBtnClick()
    if self.CurSelectHead ~= nil and self.CurSelectHead.PlayerInfo ~= nil then
        if self.CurSelectHead.DeleteTime > 0 then
            Utils.ShowMsgBoxAndBtn(nil, "C_MSGBOX_OK", nil, "C_SELECT_PLAYER_DEL_ROLE_WAITING")
        else
            -- Turn off the 2D top-level camera
            GameCenter.UIFormManager:ShowUITop2DCamera(false)
            -- Set up role continuation information
            GameCenter.ImmortalResSystem:ClearImmortalAll()
            local _tmp = self.CurSelectHead.PlayerInfo
            GameCenter.ImmortalResSystem:SetImmortalResourceFirst(_tmp.Career);

            GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN);
            
            GameCenter.Network.Send("MSG_Register.ReqSelectCharacter",{playerId = self.CurSelectHead.PlayerInfo.RoleId});

            -- Players enter the game for the first time, initialize the level
            GameCenter.SDKSystem:SetLevelInfoWhileFirstEnterGame(_tmp.Level)
            GameCenter.PlayerRoleListSystem.CreateRoleTime = _tmp.CreateTime
        end
        --CS.Thousandto.Code.Logic.BISystem.ReqBiDevice();
    else
        self.Parent:ChangePanel(LoginSceneState.CreatePlayer)
    end
end

-- Click the delete button
function UISelectPlayerPanel:OnDeleteBtnClick()
    if self.CurSelectHead ~= nil and self.CurSelectHead.PlayerInfo ~= nil then
        Utils.ShowMsgBoxAndBtn(function(code)
            if self.CurSelectHead ~= nil and self.CurSelectHead.PlayerInfo ~= nil and code == MsgBoxResultCode.Button2 then
                GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN);
                local reqMsg = ReqMsg.MSG_Register.ReqDeleteRole:New()
                reqMsg.roleId = self.CurSelectHead.PlayerInfo.RoleId;
                reqMsg:Send()
            end
        end, "C_MSGBOX_CANCEL", "C_MSGBOX_OK", "C_SELECT_PLAYER_DEL_ROLE_CONFIRM")
    end
end


-- Click on the Recovery Button
function UISelectPlayerPanel:OnRecoverBtnClick()
    if self.CurSelectHead ~= nil and self.CurSelectHead.PlayerInfo ~= nil then
        Utils.ShowMsgBoxAndBtn(function(code)
            if self.CurSelectHead ~= nil and self.CurSelectHead.PlayerInfo ~= nil and code == MsgBoxResultCode.Button2 then
               GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN);
                local reqMsg = ReqMsg.MSG_Register.ReqRegainRole:New()
                reqMsg.roleId = self.CurSelectHead.PlayerInfo.RoleId
                reqMsg:Send()
           end
       end, "C_MSGBOX_CANCEL", "C_MSGBOX_OK", "C_SELECT_PLAYER_REGAIN_ROLE_CONFIRM")
    end
end

-- Set the first role as the object to choose
function UISelectPlayerPanel:SetSeleftFirstHead()
    local _setect = false
    for i=1,self.PlayerHeads:Count() do        
        if self.PlayerHeads[i].PlayerInfo ~= nil then
            _setect = true 
            self:SetSelectHead(self.PlayerHeads[i], false)
            break;
        end
    end

    if not _setect then
        self:SetSelectHead(self.PlayerHeads[0], false)
    end
end

-- Restore all avatar changes
function UISelectPlayerPanel:ResetHead()    
    for i = 1, self.PlayerHeads:Count() do
        self.PlayerHeads[i]:SetSelected(false)
    end
end

-- Set the currently selected avatar
function UISelectPlayerPanel:SetSelectHead(head,moveAnim)
    if self.VfxDecorate_02 then
        self.VfxDecorate_02:OnCreateAndPlay(ModelTypeCode.UIVFX, 258,LayerUtils.GetAresUILayer())
    end
    if self.VfxDecorate_03 then
        self.VfxDecorate_03:OnCreateAndPlay(ModelTypeCode.UIVFX, 259,LayerUtils.GetAresUILayer()) 
    end
    self.CurSelectHead = head
    if not head then
        return
    end
    -- Recover the previous ones first
    self:ResetHead();
    -- Then set the current avatar
    head:SetSelected(true)
    self.AnimModule:RemoveTransAnimation(self.SelectTrans)
    local _endPos = self.CurSelectHead.Trs.localPosition
    local _curPos = self.SelectTrans.localPosition
    self.SelectTrans.localPosition = _endPos
    if moveAnim then
        self.AnimModule:AddPositionAnimation(_curPos.x - _endPos.x, _curPos.y - _endPos.y, self.SelectTrans, 0.3, false, false)
        self.AnimModule:PlayShowAnimation(self.SelectTrans)
        self.SelectTrans.localPosition = _curPos
    end

    if self.CurSelectHead.PlayerInfo ~= nil then
        if self.CurSelectHead.DeleteTime > 0 then
            self.RecoverBtn.gameObject:SetActive(true)
            self.DeleteBtn.gameObject:SetActive(false)
        else
            self.RecoverBtn.gameObject:SetActive(false)
            self.DeleteBtn.gameObject:SetActive(self.IsNeedShowDeleteBtn)
        end
        self.Skin:SetCurSelectPlayer(self.CurSelectHead.PlayerInfo.RoleId)
        self.Parent:SetCurSelectOcc(self.CurSelectHead.PlayerInfo.Career, 0)
    else
        self.Skin:SetCurSelectPlayer(0)
        self.Parent:SetCurSelectOcc(-1, -1)
    end
end


-- Delete roles
function UISelectPlayerPanel:OnDelPlayer(obj,sender)
    local _playerId = obj
    for i = 1, self.PlayerHeads:Count() do       
        if self.PlayerHeads[i].PlayerInfo ~= nil and self.PlayerHeads[i].PlayerInfo.RoleId == _playerId then
            if self.PlayerHeads[i].PlayerInfo.Level >= GameCenter.PlayerRoleListSystem.DelayDeleteLevel  then
                -- If it is greater than or equal to 110, set to 48 hours to delete
                self.PlayerHeads[i]:SetDeleteTime(48 * 60 * 60)
                self:SetSelectHead(self.PlayerHeads[i], false)
            else
                self.Skin:RemoveSelectPlayer(self.PlayerHeads[i].PlayerInfo.RoleId)
                self.PlayerHeads[i]:SetInfo(nil)
                if self.PlayerHeads[i] == self.CurSelectHead then
                    self:SetSeleftFirstHead()
                end
            end
            break
        end
    end
    -- If all the current users are deleted, go to the role creation interface
    if GameCenter.PlayerRoleListSystem:CheckInCreateRole() then        
        self.Parent:ChangePanel(LoginSceneState.CreatePlayer)
    end
end

-- Restore role
function UISelectPlayerPanel:OnRecoverPlayer(obj,object)
    local _playerId = obj
    for i = 1,self.PlayerHeads:Count() do
        if self.PlayerHeads[i].PlayerInfo ~= nil and self.PlayerHeads[i].PlayerInfo.RoleId == _playerId then
            self.PlayerHeads[i]:SetDeleteTime(0)
            self:SetSelectHead(self.PlayerHeads[i], false)        
            break
        end
    end
end


-- I have selected the blocked account, and the result is returned here to indicate that it is being blocked.
function UISelectPlayerPanel:OnForbidPlayerResult( obj,  sender)
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
end



return UISelectPlayerPanel