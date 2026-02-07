------------------------------------------------
-- Author: 
-- Date: 2019-08-07
-- File: UICreatePlayerForm.lua
-- Module: UICreatePlayerForm
-- Description: Login interface information
------------------------------------------------
-- Quote
local LoginSceneState = require("Logic.Login.LoginSceneState")
local UICreatePlayerPanel =  require "UI.Forms.UICreatePlayerForm.UICreatePlayerPanel"
local UISelectPlayerPanel =  require "UI.Forms.UICreatePlayerForm.UISelectPlayerPanel"
local UIOccupationDescPanel =  require "UI.Forms.UICreatePlayerForm.UIOccupationDescPanel"
local UIVideoPlayUtils = CS.Thousandto.Plugins.Common.UIVideoPlayUtils;
local L_AudioPlayer = CS.Thousandto.Core.Asset.AudioPlayer

local UICreatePlayerForm = {
    CreatePanel = nil, -- Create a role script
    SelectPanel = nil, -- Select a role script
    OccPanel = nil , -- Career description script
    ReturenBtn = nil, -- Back to button script
    DagListener = nil , -- Drag the component
    LeftContainer = nil, -- The container on the left
    RightContainer = nil, -- The container on the right
    RightBottomContainer = nil, -- The container on the right
    BottomContainer = nil, -- The container below

    RightTopReverseContainer = nil, -- The reverse container on the upper right is displayed during playback.
    SkipBtn = nil, -- Skipped button

    BloomCameraGo = nil,    
    AnimModule = nil, -- Animation components
    AnimValue01 = nil, -- Animation interpolation component
    OccSetAttrHandler = nil, -- Functions that set career attributes

    
    PlayableDirector_01 = nil,-- Timeline player -- Male Sword Character
    PlayableDirector_02 = nil,-- Timeline player -- female gun character
    PlayableDirector_03 = nil,-- Timeline player -- Monk character
    PlayableDirector_04 = nil,-- Timeline player -- Shura character

    -- Hide the parameters of the form
    HideParam = -1,


    -- Number of animation displays
    AnimShowTimes = nil,
   
    -- Sound Id
    SoundVoiceCreateId = 0,
    MusicVolumeTimer = 0
}

function UICreatePlayerForm:OnRegisterEvents()
	self:RegisterEvent(UIEventDefine.UICREATEPLAYERFORM_OPEN, self.OnOpen)
    self:RegisterEvent(UIEventDefine.UICREATEPLAYERFORM_CLOSE, self.OnClose)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_CREATE_PLAYER_ANIM_START,self.OnPlayAnim)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_CREATE_PLAYER_ANIM_RESET,self.OnPlayAnimReset)
end

function UICreatePlayerForm:FindAllComponents()
    self.LeftContainer = UIUtils.FindTrans(self.Trans,"FunPanel/Left/Container")
    self.RightContainer = UIUtils.FindTrans(self.Trans,"FunPanel/Right/Container")
    self.RightBottomContainer = UIUtils.FindTrans(self.Trans,"FunPanel/RightButtom/Container")
    self.BottomContainer = UIUtils.FindTrans(self.Trans,"FunPanel/Bottom/Container")
    self.RightTopReverseContainer = UIUtils.FindGo(self.Trans,"FunPanel/RightTop/Recontainer")
    self.SkipBtn = UIUtils.FindBtn(self.Trans,"FunPanel/RightTop/Recontainer/SkipBtn")
    -- hidden Skip Animation Button
    self.SkipBtnGo = UIUtils.FindGo(self.Trans,"FunPanel/RightTop/Recontainer/SkipBtn")
    self.SkipBtnGo:SetActive(false)

    self.ReturenBtn = UIUtils.FindBtn(self.Trans,"FunPanel/Left/Container/ReturnBtn")
    self.DagListener = UIUtils.FindEventListener(self.Trans,"DragPanel")
    self.CreatePanel = UICreatePlayerPanel:New(self.Trans,self)
    self.SelectPanel = UISelectPlayerPanel:New(self.Trans,self)
    self.OccPanel = UIOccupationDescPanel:New(UIUtils.FindTrans(self.Trans,"FunPanel/Right/Container/OccDesc"))
    --self.OccSetAttrHandler = Utils.Handler(self.OccPanel.ShowAttrPic,self.OccPanel);
    self.OccSetAttrHandler = Utils.Handler(self.OccPanel.SetAttr,self.OccPanel);
    self.AnimModule = UIAnimationModule(self.Trs)
    self.AnimValue01 = AnimValue01:New();
    self.AnimValue01:SetSpeed({10,10,10,5,4,3,2,1});
    self.AnimShowTimes = Dictionary:New();    
    --self.RightBackTex = UIUtils.FindTex(self.Trans,"Backgroup/Right");
    local _root = UnityUtils.FindSceneRoot("SceneRoot");
    if _root then
        if  UIUtils.FindGo(_root.transform,"[PlayerRoot]") ~= nil then
            self.PlayableDirector_01 = UIUtils.FindPlayableDirector(_root.transform,"[PlayerRoot]/Create/Player_0/[RotRoot]/[Timeline]");
            self.PlayableDirector_02 = UIUtils.FindPlayableDirector(_root.transform,"[PlayerRoot]/Create/Player_1/[RotRoot]/[Timeline]");
            self.PlayableDirector_03 = UIUtils.FindPlayableDirector(_root.transform,"[PlayerRoot]/Create/Player_2/[RotRoot]/[Timeline]");
            self.PlayableDirector_04 = UIUtils.FindPlayableDirector(_root.transform,"[PlayerRoot]/Create/Player_3/[RotRoot]/[Timeline]");
        end     
    end
end

function UICreatePlayerForm:OnOpen(obj, sender)
    self.CSForm:Show(sender)
    self.SelectPanel:SetPlayerList()
    if not GameCenter.PlayerRoleListSystem:CheckInCreateRole() then
        self:ChangePanel(LoginSceneState.SelectPlayer)
    else
        self:ChangePanel(LoginSceneState.CreatePlayer)
    end
    
end

function UICreatePlayerForm:OnClose(obj, sender)
    Debug.LogError("UICreatePlayerForm:OnClose::" ..  tostring(obj) .. tostring(sender));
    self.CreatePanel:PlayVideo(false)
    GameCenter.UIFormManager:ShowUITop2DCamera(true)
    self.HideParam = -1;
    if obj then
        self.HideParam = UnityUtils.GetObjct2Int(obj);    
    end
    self.CSForm:Hide();
    if self.GameNameOffGo then
        self.GameNameOffGo:SetActive(false);
    end
end

-- Register events on the UI, such as click events, etc.
function UICreatePlayerForm:RegUICallback()
    UIUtils.AddBtnEvent(self.ReturenBtn, self.OnReturnBtnClick, self)
    UIUtils.AddBtnEvent(self.SkipBtn,self.OnSkipBtnClick,self);
    self.DagListener.onDrag = Utils.Handler(self.OnDrag, self)
end

function UICreatePlayerForm:OnFirstShow()
    self:FindAllComponents()
    self:RegUICallback()
end

function UICreatePlayerForm:OnShowAfter()   
    GameCenter.LoadingSystem:Close();
    -- Close the announcement interface
    GameCenter.PushFixEvent(UIEventDefine.UI_LOGIN_NOTICE_CLOSE);

end

function UICreatePlayerForm:OnShowBefore()
    --self:LoadTexture(self.RightBackTex,ImageTypeCode.UI,"tex_newlogindi");    
    GameCenter.LoginSystem.MapLogic:SetState(LoginMapStateCode.RoleListFormOpened);
end

function UICreatePlayerForm:OnHideAfter()
    self.CreatePanel:OnClose(self.HideParam)
    self.SelectPanel:OnClose(self.HideParam)  
    self.OccPanel:OnClose() 
end

function UICreatePlayerForm:OnTryHide()
    self:OnReturnBtnClick()
    return false
end

function UICreatePlayerPanel:OnFormDestroy()
    self.CreatePanel:OnFormDestroy();
end

function UICreatePlayerForm:ChangePanel(state)
    -- Debug.Log("UICreatePlayerForm:ChangePanel::" .. tostring(state));
    if LoginSceneState.CreatePlayer == state then                      
        self.SelectPanel:OnClose()
        self.CreatePanel:OnOpen()
        GameCenter.UIFormManager:ShowUITop2DCamera(true)
    elseif LoginSceneState.SelectPlayer == state then
        self.CreatePanel:OnClose()
        self.SelectPanel:OnOpen()
        GameCenter.UIFormManager:ShowUITop2DCamera(true)
        self:OnPlayAnim("True");
    end
end

function UICreatePlayerForm:SetCurSelectOcc(csocc, changeNum)
    local _occ = csocc;
    -- This includes processing Shura
    local _maxocc = Occupation.Count;    
    if _occ > _maxocc or _occ < 0 then
        self.OccPanel:OnClose()
        self.OccPanel:SetOccupation(_occ, changeNum)
    else
        self.OccPanel:OnOpen()
        self.OccPanel:SetOccupation(_occ, changeNum)
        -- No delay is required when switching manually
        self.AnimValue01:Start(0,1,self.OccSetAttrHandler);
    end
end
-- Gesture sliding effect
function UICreatePlayerForm:OnDrag(go,delta)
    if self.SelectPanel ~= nil and self.SelectPanel.IsVisible and self.SelectPanel.Skin ~= nil then
        self.SelectPanel.Skin:AddCurRotY(-delta.x * 0.3)
    elseif self.CreatePanel ~= nil and self.CreatePanel.IsVisible then 
        self.CreatePanel:AddRotY(-delta.x * 0.3)
    end
end

-- Return to the previous level
function UICreatePlayerForm:OnReturnBtnClick()
    if self.SelectPanel.IsVisible then
        -- Return to the selection interface and return to the server selection interface
        self:ReturnToEnterGamePanel()
    elseif self.CreatePanel.IsVisible then
        -- Create a role interface
        if self.SelectPanel:HavePlayer() then
            -- If there is role information in the account, return to the selection interface
            self:ChangePanel(LoginSceneState.SelectPlayer)
        else
            -- Otherwise, return to the server selection interface
            self:ReturnToEnterGamePanel()
        end
    end
end

function UICreatePlayerForm:OnSkipBtnClick()
    if self.PlayableDirector_01 then
        self.PlayableDirector_01.time = self.PlayableDirector_01.duration;        
    end
    if self.PlayableDirector_02 then
        self.PlayableDirector_02.time = self.PlayableDirector_02.duration;        
    end
    if self.PlayableDirector_03 then
        self.PlayableDirector_03.time = self.PlayableDirector_03.duration;        
    end
    if self.PlayableDirector_04 then
       self.PlayableDirector_04.time = self.PlayableDirector_04.duration;        
    end
   self:OnPlayAnim()
end

-- Return to the server selection interface
function UICreatePlayerForm:ReturnToEnterGamePanel()    
    -- Close the role interface
    GameCenter.PushFixEvent(UIEventDefine.UICREATEPLAYERFORM_CLOSE)
    if GameCenter.LoginSystem:GetIsValidToken() then
        -- Open the login interface
        GameCenter.PushFixEvent(UIEventDefine.UILOGINFORM_ENTERGAME_OPEN)
        -- Login to the gateway successfully
        GameCenter.LoginSystem.MapLogic:SetState(LoginMapStateCode.LoginAgentServerOK);
    else

        -- GameCenter.PushFixEvent(UIEventDefine.UILOGINFORM_SWITCHACCOUNT_OPEN)
        GameCenter.PushFixEvent(UIEventDefine.UILOGINFORM_ENTERGAME_OPEN);
        
    end
end

function UICreatePlayerForm:Update(dt)
    if self.SelectPanel then
        self.SelectPanel:Update(dt)
    end
    -- Animation components now
    self.AnimValue01:Update();

    -- Check if we need to reset the music volume
    -- self:CheckResetMusicVolume(dt)
end
function UICreatePlayerForm:OnPlayAnimReset(obj,sender)    
    UnityUtils.SetLocalPosition(self.LeftContainer, -600, 0, 0)
    UnityUtils.SetLocalPosition(self.RightContainer, 400, -720, 0)
    UnityUtils.SetLocalPosition(self.BottomContainer, 0, -200, 0)
    UnityUtils.SetLocalPosition(self.RightBottomContainer, 400, 0, 0)
    self.AnimValue01:Stop();
    self.OccPanel:SetAttr(0);    
    if not self.AnimShowTimes:ContainsKey(self.OccPanel.SelectOcc) then
        self.RightTopReverseContainer:SetActive(true);
        self.AnimShowTimes[self.OccPanel.SelectOcc] = 1;
    else
        self.RightTopReverseContainer:SetActive(true);
    end    
end
function UICreatePlayerForm:OnPlayAnim(obj, sender)
    self.AnimModule:RemoveTransAnimation(self.LeftContainer)
    self.AnimModule:RemoveTransAnimation(self.RightContainer)
    self.AnimModule:RemoveTransAnimation(self.BottomContainer)
    self.AnimModule:RemoveTransAnimation(self.RightBottomContainer)
    self.AnimValue01:Stop();

    UnityUtils.SetLocalPosition(self.LeftContainer, 0, 0, 0)
    UnityUtils.SetLocalPosition(self.RightContainer, 0, -720, 0)
    UnityUtils.SetLocalPosition(self.BottomContainer, 0, 0, 0)
    UnityUtils.SetLocalPosition(self.RightBottomContainer, 0, 0, 0)
    
    -- The animation will only be played when obj is not null
    if obj ~= nil then
        self.AnimModule:AddPositionAnimation(-600, 0, self.LeftContainer, 0.3, false, false)
        self.AnimModule:AddPositionAnimation(400, 0, self.RightContainer, 0.3, false, false)
        self.AnimModule:AddPositionAnimation(0,-200, self.BottomContainer, 0.3, false, false)
        self.AnimModule:AddPositionAnimation(400, 0, self.RightBottomContainer, 0.3, false, false)
        self.AnimModule:PlayShowAnimation(self.LeftContainer)
        self.AnimModule:PlayShowAnimation(self.RightContainer)
        self.AnimModule:PlayShowAnimation(self.BottomContainer)
        self.AnimModule:PlayShowAnimation(self.RightBottomContainer)

        UnityUtils.SetLocalPosition(self.LeftContainer, -600, 0, 0)
        UnityUtils.SetLocalPosition(self.RightContainer, 400, -720, 0)
        UnityUtils.SetLocalPosition(self.BottomContainer, 0, -200, 0)
        UnityUtils.SetLocalPosition(self.RightBottomContainer, 400, 0, 0)
        
        -- After waiting for the main animation to be played, start playing the attribute animation
        self.AnimValue01:Start(0.3,1,self.OccSetAttrHandler);     
    else
        self.OccPanel:SetAttr(1);   
    end
    self.RightTopReverseContainer:SetActive(false);
    
end

function UICreatePlayerForm:PlayVoiceOnOpen(status)
    -- Debug.LogError("UICreatePlayerForm:PlayVoiceOnOpen::" .. tostring(status));
    -- Play the create role sound
    -- if self.SoundVoiceCreateId > 0 then
    if self.SoundVoiceCreateId ~= 0 then
        L_AudioPlayer.Stop(self.SoundVoiceCreateId)
        self.SoundVoiceCreateId = 0
        self.MusicVolumeTimer = 0
        -- if self.SelectPanel.IsVisible then
            L_AudioPlayer.SetVolume(AudioTypeCode.Music, 1)
        -- end
        UIVideoPlayUtils.StopVideo()
    end

    if status == true then
        L_AudioPlayer.SetVolume(AudioTypeCode.Music, 0)
        self.MusicVolumeTimer = 7 -- delay 7 seconds to reset music volume
        self.SoundVoiceCreateId = L_AudioPlayer.PlayUI("snd_ui_login_create")
    end
end

-- function UICreatePlayerForm:CheckResetMusicVolume(dt)
--     if self.MusicVolumeTimer > 0 then
--         self.MusicVolumeTimer = self.MusicVolumeTimer - dt
--         if self.MusicVolumeTimer <= 0 then
--             L_AudioPlayer.SetVolume(AudioTypeCode.Music, 1)
--             self.MusicVolumeTimer = 0
--         end
--     end
-- end

return UICreatePlayerForm