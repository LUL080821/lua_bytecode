------------------------------------------------
--author:
--Date: 2019-04-18
--File: UINewLoginForm.lua
--Module: UINewLoginForm
--Description: New game login form
------------------------------------------------
local UIEnterGamePanel = require("UI.Forms.UINewLoginForm.UIEnterGamePanel.UIEnterGamePanel");
local UIInputAccountPanel = require("UI.Forms.UINewLoginForm.UIInputAccountPanel.UIInputAccountPanel");
local UIChangeLanguagePanel = require("UI.Forms.UINewLoginForm.UIChangeLanguagePanel.UIChangeLanguagePanel");
local LoginStatus = require("Logic.Login.LoginStatus");
--local UIVideoPlayUtils = CS.Thousandto.Plugins.Common.UIVideoPlayUtils;
local RuntimePlatform = CS.UnityEngine.RuntimePlatform
local UnityEngine = CS.UnityEngine
local UINewLoginForm = {
    --The parent node of the background image
    BackgroundGo = nil,
    --Background picture UITexture
    TexBgTexture = nil,
    --Logo Picture UITexture
    TexLogoTexture = nil,
    --The node of background effects Transform
    VfxConpent = nil,
    --Game rating logo UITexture
    LevelTagTexture = nil,

    --GameObject for prompt message
    MsgContainerGO = nil,
    --Label of prompt message
    MsgLabel = nil,

    --Enter the account panel
    InputAccountPanel= nil,
    --Enter the game panel
    EnterGamePanel = nil,

    --Login button status
    LoginBtnIsShowed = false,

    
    ---Clean the cached background texture
    ClearCacheBgTexture = nil,
    
    --Time used for countdown
    --ElapseTimer = 0,
    --VideoTexture
    --VideoTexture = nil,
    --Whether to start timing
    --IsStartTime = false,
    --Is it gradually showing
    --IsFadeIn = false,
    --Steply showing whether it is completed
    --IsFadeInFinish = false,
    --Video VideoPalyer
    --VideoPlayer = nil,
    --Control login to gradually display
    --InputAccountPanelUIPanel = nil,
    --Login failed interface
    GobjLoginFailPanel = nil,
    --Login failed background
    TexLoginFailBg = nil,
    --Tips after opening
    TxtOpenTips = nil,
    --Countdown
    TxtCountdown = nil,
    --Close the failed login interface button
    BtnCloseLoginFailPanel = nil,
    --Copyright information
    CopyrightGO = nil,
    --Healthy Game Announcement UILabel
    ZhonggaoGO = nil,
    --The content of the version number
    BanHaoGO = nil,
    --Game rating mark
    GameLevelGO = nil,
    GameLevelSprite = nil,
    GameLevelBtn = nil,
    GameLevelTipsPanelGo = nil,
    GameLevelTipsPanelTrans = nil,
    GameLevelTipsCloseBtn = nil,
    ClearCacheScript = nil,
    DoClearLabel = nil,
    DoClearBtn = nil,
    DoClearGo = nil,

    --Privacy and User Agreement
    AgreementGo = nil,
    AgCheckedBox = nil,
    AgPrivacyBtn = nil,
    AgUserBtn = nil,
    AgreeValue = 0,
};

--Inherit the Form function
function UINewLoginForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UILOGINFORM_OPEN,self.OnOpenAccount);
    self:RegisterEvent(UIEventDefine.UILOGINFORM_SWITCHACCOUNT_OPEN,self.OnOpenSwitchAccount);
    self:RegisterEvent(UIEventDefine.UILOGINFORM_ENTERGAME_OPEN,self.OnOpenEnterGame);
    self:RegisterEvent(UIEventDefine.UILOGINFORM_CLOSE,self.OnClose);
    
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_LOGIN_HIDE_BTNS,self.OnHideInputAccountBtns);
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_LOGIN_SHOW_BTNS,self.OnShowInputAccountBtns);
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_LOGIN_STATUS,self.OnLoginStatus);
    --self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_GAME_LOGIN_SUCCESS,self.OnResLoginGameSuccess);

    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_UIENTERGAMEFORM_REFRESH,self.OnRefreshEnterGameForm);    
    
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_UISERVERLISTFORM_REFRESH_LIST, self.OnRefreshEnterGameForm);
    self:RegisterEvent(UIEventDefine.UILOGINFORM_SHOWLOGINFAILPANEL, self.OnOpenLoginFailPanel);    
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_LOGIN_REFRESH_AGREEMENT_CHECKBOX,self.OnRefreshAgreementCheckBox);

    self:RegisterEvent(UIEventDefine.UILOGINFORM_CHANGELANGUAGE_OPEN,self.OnChangeLanguageOpen);
    self:RegisterEvent(UIEventDefine.UILOGINFORM_CHANGELANGUAGE_CLOSE,self.OnChangeLanguageClose);
    self:RegisterEvent(LogicEventDefine.EID_EVENT_CHECKUPDATE, self.OnCheckUpdate);
end


--Find all lists
function UINewLoginForm:FindAllComponents()
    local _myTrans = self.Trans;
    self.TexBgTexture = UIUtils.FindTex(_myTrans,"Background/Back/BackTexture");
    self.TexLogoTexture = UIUtils.FindTex(_myTrans,"Background/FrontTexture");
    --self.TexLogoTexture.gameObject:SetActive(false);
    self.BackgroundGo = UIUtils.FindGo(_myTrans,"Background");
    self.BackgroundGo:SetActive(true)
    self.VfxConpent =  UIUtils.RequireUIVfxSkinCompoent(UIUtils.FindTrans(self.Trans, "Background/VFXNode"))
    self.LevelTagTexture = UIUtils.FindTex(_myTrans,"Background/LevelTag");

    self.MsgContainerGO = UIUtils.FindGo(_myTrans,"MsgContainer");
    self.MsgLabel = UIUtils.FindLabel(_myTrans,"MsgContainer/MsgLabel");

    self.InputAccountPanel = UIInputAccountPanel:Initialize(self,_myTrans:Find("InputAccountPanel"));
    --self.InputAccountPanelUIPanel = UIUtils.FindPanel(_myTrans, "InputAccountPanel");
    self.EnterGamePanel = UIEnterGamePanel:Initialize(self,_myTrans:Find("UIEnterGamePanel"));
    self.ChangeLanguagePanel = UIChangeLanguagePanel:Initialize(self,_myTrans:Find("LanguageOption"));

    --Copyright, advice, version number
    self.CopyrightGO = UIUtils.FindGo(_myTrans,"OtherPanel/BottomCenter/Copyright");
    self.ZhonggaoGO = UIUtils.FindGo(_myTrans,"OtherPanel/BottomRight/Zhonggao");    
    self.BanHaoGO =  UIUtils.FindGo(_myTrans,"OtherPanel/BottomLeft/Banhao");     
    self.GameLevelSprite = UIUtils.FindSpr(_myTrans,"OtherPanel/TopLeft/GameLevel");
    self.GameLevelGO = self.GameLevelSprite.gameObject;
    self.GameLevelBtn = UIUtils.FindBtn(_myTrans,"OtherPanel/TopLeft/GameLevel");
    self.GameLevelTipsPanelGo = UIUtils.FindGo(_myTrans,"OtherPanel/Center/GameLevelTipsPanel");



    self.GameLevelTipsCloseBtn = UIUtils.FindBtn(_myTrans,"OtherPanel/Center/GameLevelTipsPanel/CloseBtn");
    --Protocol processing
    self.AgreementGo = UIUtils.FindGo(_myTrans,"OtherPanel/BottomCenter/Agreement");
    self.AgCheckedBox =  UIUtils.FindToggle(_myTrans,"OtherPanel/BottomCenter/Agreement/CheckBox");
    self.AgPrivacyBtn = UIUtils.FindBtn(_myTrans,"OtherPanel/BottomCenter/Agreement/Context/Privacy");
    self.AgUserBtn = UIUtils.FindBtn(_myTrans,"OtherPanel/BottomCenter/Agreement/Context/User");

    self.GameLevelTipsPanelTrans = self.GameLevelTipsPanelGo.transform
    self.CSForm:AddTransNormalAnimation(self.GameLevelTipsPanelTrans, 50, 0.3)

    self.CopyrightGO:SetActive(false);
    self.GameLevelGO:SetActive(false);
    self.ZhonggaoGO:SetActive(false);
    self.BanHaoGO:SetActive(false);
    self.GameLevelTipsPanelGo:SetActive(false);
    self.GameLevelTipsVisible = false

    --Vietnam needs to display reminder nodes
    local _hasVie = (GameCenter.SDKSystem.LocalFGI == 1301);
    local _hasCH = (GameCenter.SDKSystem.LocalFGI == 1101);

    --self.CopyrightGO:SetActive(_hasVie);
    --self.GameLevelGO:SetActive(_hasVie or _hasCH);
    
    
    --Click only if you include the mainland
    self.GameLevelTipsCloseBtn.isEnabled = _hasCH;

    --protocol
    self.AgreementGo:SetActive(_hasVie or _hasCH);
    self.AgCheckedBox.value = GameCenter.LoginSystem.Agreement:CheckAgree();

    self.GobjLoginFailPanel = UIUtils.FindGo(_myTrans, "LoginFailPanel");
    self.TexLoginFailBg = UIUtils.FindTex(_myTrans, "LoginFailPanel/TexBg")
    self.TxtOpenTips = UIUtils.FindLabel(_myTrans,"LoginFailPanel/TxtOpenTips");
    self.TxtCountdown = UIUtils.FindLabel(_myTrans,"LoginFailPanel/TxtCountdown");
    self.BtnCloseLoginFailPanel = UIUtils.FindBtn(_myTrans,"LoginFailPanel/Btn");
    self.GobjLoginFailPanel:SetActive(false);


    --Clean the background form of the resource
    self.ClearCacheBgTexture  = UIUtils.FindTex(_myTrans,"ClearCachePanel/Content/FormBg");
  
    self.ClearCacheScript = UIUtils.FindTrans(_myTrans, "ClearCachePanel"):GetComponent("UIClearCachePanelScript")
    self.DoClearLabel  = UIUtils.FindGo(_myTrans,"ClearCachePanel/Enter/DoClearBtn/Label");
    self.DoClearBtn  = UIUtils.FindBtn(_myTrans,"ClearCachePanel/Enter/DoClearBtn");
    self.DoClearGo  = UIUtils.FindGo(_myTrans,"ClearCachePanel/Enter/DoClearBtn");

    UIUtils.AddBtnEvent(self.BtnCloseLoginFailPanel, self.OnClickBtnCloseLoginFailPanel, self);
    UIUtils.AddBtnEvent(self.GameLevelBtn,self.OnGameLevelBtnClick,self);
    UIUtils.AddBtnEvent(self.GameLevelTipsCloseBtn,self.GameLevelTipsCloseBtnClick,self);
    UIUtils.AddBtnEvent(self.DoClearBtn,self.DoClearBtnClick,self);

    UIUtils.AddOnChangeEvent(self.AgCheckedBox,self.AgCheckedBoxClick,self);
    UIUtils.AddBtnEvent(self.AgPrivacyBtn,self.AgPrivacyBtnClick,self);
    UIUtils.AddBtnEvent(self.AgUserBtn,self.AgUserBtnClick,self);

    if GosuSDK.GetPlatformName() ~= "PC" then
       self:EnterServerPanel(obj,sender);
    else
       self:OnShowInputAccountBtns(obj,sender);
    end
   
    self.DoClearLabel:SetActive(false); -- ẩn 

    -- ẩn nút trên android
    -- if CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.Android then
    --     self.DoClearGo:SetActive(false); -- ẩn 
    -- end
    
    -- if (not GosuSDK.Events.SHOW_DELETE_BUTTON) then 
    --     self.DoClearGo:SetActive(false);
    -- end
  
    self:SetClearGoActive(GosuSDK.Events.SHOW_DELETE_BUTTON)

    

end

--[[
--Login successfully
function UINewLoginForm:OnResLoginGameSuccess(obj,sender)
    if self.SelectInSceneGo then
        self.SelectInSceneGo:SetActive(true);
    end
    if self.LoginInSceneGo then
        self.LoginInSceneGo:SetActive(false);
    end
    LuaCoroutineUtils.AsynInvoke(function ()
        --Open the role form
        GameCenter.PushFixEvent(UIEventDefine.UICREATEPLAYERFORM_OPEN);     
    end,1500,1);
    
end
]]

function UINewLoginForm:SetClearGoActive(active)
    if CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.Android then
        self.DoClearGo:SetActive(false); -- ẩn 
    else
        self.DoClearGo:SetActive(active)
    end
    -- self.DoClearGo:SetActive(active)
end

function UINewLoginForm:DoClearBtnClick(object,sender)
    GosuSDK.TrackingEvent("deleteAccount", GosuSDK.GetLocalValue("saveUserSdkId"))
end

-- [Gous custom function] enter server game

function UINewLoginForm:EnterServerPanel(obj,sender)
    
    local _account = GosuSDK.GetLocalValue("account")
    if (_account == "") then
        GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
         -- khởi tạo sdk và show form 
        --GosuSDK.InitSdk("SDK_Object", "OnSdkCallback") -- SDK_Object phải có hàm OnSdkCallback để lắng nghe dữ liệu từ sdk trả về
        -- GosuSDK.CallCSharpMethod("CallShowLogin")
        -- GosuSDK.CallCSharpMethod("BridgeTrackingFunction", "Login") -- hàm mới

        GosuSDK.CorrectFuntionIOS("CallShowLogin")
    else
        -- GosuSDK.CallCSharpMethod("CallShowLogin") -- gọi thêm 1 lần nữa để làm mới token
        -- GosuSDK.CallCSharpMethod("BridgeTrackingFunction", "Login") -- hàm mới

        GosuSDK.CorrectFuntionIOS("CallShowLogin")

        GosuSDK.RecordValue("account", _account);     
        UINewLoginForm:OnLoginGame(_account);                   
    end
end



function UINewLoginForm:OnOpenAccount(obj,sender)
    self:OnOpen(obj,sender);
    self:OnShowInputAccountBtns(); 
    self:Login();


end


function UINewLoginForm:OnOpenSwitchAccount(obj,sender)
    -- reset lại input và show form login
    if GosuSDK.GetPlatformName() ~= "PC" then
        GosuSDK.RecordValue("account", "")
        -- GosuSDK.CallCSharpMethod("CallLogOut")
        -- GosuSDK.CallCSharpMethod("CallShowLogin")
        
        -- GosuSDK.CallCSharpMethod("BridgeTrackingFunction", "Logout") -- hàm mới
        -- GosuSDK.CallCSharpMethod("BridgeTrackingFunction", "Login") -- hàm mới

        GosuSDK.CorrectFuntionIOS("CallLogOut")
        GosuSDK.CorrectFuntionIOS("CallShowLogin")
        
    end

    self:OnOpen(obj,sender);
    self:OnShowInputAccountBtns(); 
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN, DataConfig.DataMessageString.Get("C_XIAOTIAN_TIPS1"));
	--Wait for one second to execute
    self.CSForm:WaitActionAsyn(Utils.Handler(GameCenter.SDKSystem.SwitchAccount,GameCenter.SDKSystem),1,0);
end


function UINewLoginForm:OnOpenEnterGame(obj,sender)

    self:OnOpen(obj,sender);
    self:OnHideInputAccountBtns();

end

function UINewLoginForm:OnFirstShow()
    self:FindAllComponents();    
end

function UINewLoginForm:OnShowBefore()  
    --self.GameLevelSprite:MakePixelPerfect();
  --self.VfxConpent:OnCreateAndPlay(ModelTypeCode.CollectionVFX, 1, LayerUtils.GetAresUILayer());    
  --self.CSForm:LoadTexture(self.TexBgTexture,AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_b_denglu"), self.OnTextureLoadedFinished)
  --self.CSForm:LoadTexture(self.TexLogoTexture,AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_logo"))
  self.CSForm:LoadTexture(self.TexLoginFailBg,AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_3"))
  if self.ClearCacheBgTexture then
    self.CSForm:LoadTexture(self.ClearCacheBgTexture,AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_3"))
  end

  

  self:OnTextureLoadedFinished();
  
end


function UINewLoginForm:OnShowAfter()
    self.MsgContainerGO:SetActive(false); 
    GameCenter.LoginSystem.MapLogic:SetState(LoginMapStateCode.LoginFormReadyOk);
end

--When the player uses ESC, return false
function UINewLoginForm:OnTryHide()
    if self.GameLevelTipsPanelGo.activeSelf then
        self:GameLevelTipsCloseBtnClick()
        return false
    end
    GameCenter.SDKSystem:ExitGame()
    Debug.LogError("Login exits the game!!" .. Time.GetFrameCount())
    return false
end

function UINewLoginForm:OnTextureLoadedFinished()
   
end

function UINewLoginForm:OnHideBefore()
    self.EnterGamePanel:Hide();
    self.InputAccountPanel:Hide();
    self.VfxConpent:OnDestory();
end

--Initialize the video
function UINewLoginForm:InitVideo()

    -- if not UIVideoPlayUtils.IsPlaying() then
    --     UIVideoPlayUtils.PlayVideo("video_login",
    --         function()
    --             self.IsStartTime = true;
    --         end, nil,false,true);
    -- end
end


function UINewLoginForm:OnLoginGame(account)   
    GameCenter.LoginSystem.Account = account;
    self.InputAccountPanel:Hide();
    --self:ShowMessage("...");
    GameCenter.ServerListSystem:DownloadServerList();
end

function UINewLoginForm:ShowMessage(msg)
    if not self.MsgContainerGO.ActiveSelf then
        self.MsgContainerGO:SetActive(true);    
    end
    UIUtils.SetTextByString(self.MsgLabel, msg)
end



function UINewLoginForm:OnHideInputAccountBtns(object,sender)
   self.InputAccountPanel:HideBtns();
   self.InputAccountPanel:Hide();
   self.EnterGamePanel:Show();
   self.AgreementGo:SetActive(true);  --[Gosu custom] hiện lại đăng nhập lúc chọn server
    -- if CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.IPhonePlayer then
    --     self.DoClearGo:SetActive(true); -- hiện 
    -- end
    self:SetClearGoActive(GosuSDK.Events.SHOW_DELETE_BUTTON)
end

function UINewLoginForm:OnShowInputAccountBtns(object,sender)
    self.EnterGamePanel:Hide();
    self.InputAccountPanel:Show();
    if GosuSDK.GetPlatformName() ~= "PC" then
        self.InputAccountPanel:HideBtns(); --[Gosu custom]
    else
        self.InputAccountPanel:ShowBtns()
    end
    -- self.InputAccountPanel:ShowBtns();
    self.AgreementGo:SetActive(false);  --[Gosu custom] ẩn điều khoản và điều kiện khi load form đăng nhập

    -- if CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.IPhonePlayer then
    --     self.DoClearGo:SetActive(false); -- ẩn 
    -- end
    self:SetClearGoActive(GosuSDK.Events.SHOW_DELETE_BUTTON)

end

function UINewLoginForm:Login()
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN, DataConfig.DataMessageString.Get("C_XIAOTIAN_TIPS1"));
    --If there is saved role information, skip login
    if (GameCenter.SDKSystem:IsSDKLogin()) then
        self:OnLoginStatus(LoginStatus.CallSDK);
        GameCenter.SDKSystem:Login();
    else
        -- local _account = self.InputAccountPanel:GetLocalAccount();  
        -- if _account ~= nil and #_account ~= 0 then
            -- self:OnLoginStatus(LoginStatus.CallSDK);        
            -- self:OnLoginGame(_account);
        -- end 
    end
end


function UINewLoginForm:OnLoginStatus(object,sender)   
    --No need to display it here, because there is no login server verification now, and the server list is obtained before logging in, so the prompt here becomes meaningless
    --dinghuaqiang
    --2019/12/26
    -- local _status = object;
    -- local _msg = "";
    
    -- if LoginStatus.CallSDK == _status then
    -- _msg = "Login the account server...";

    -- elseif LoginStatus.CallServerlist == _status then
    -- _msg = "Fetching server list...";

    -- elseif LoginStatus.ConnectLS_v4 == _status then
    -- _msg = "Connection using IPV4...

    -- elseif LoginStatus.ConnectLS_v6 == _status then
    -- _msg = "Connection using IPV6...

    -- elseif LoginStatus.ConnectLS_OK == _status then
    -- _msg = "Login to the account server successfully!";

    -- elseif LoginStatus.ConnectLS_Fail == _status then
    -- _msg ="Login to the account server failed!";

    -- elseif LoginStatus.RecvLSCallback_OK == _status then
    -- _msg = "Login server verification was successful!

    -- elseif LoginStatus.RecvLSCallback_Fail == _status then
    -- _msg = "Login server verification failed!
    -- end
    
    -- self:ShowMessage(_msg);
end

--function UINewLoginForm:OnCameraMove(object,sender)
--    GameCenter.PushFixEvent(UIEventDefine.UICREATEPLAYERFORM_OPEN);
--end

function UINewLoginForm:OnRefreshEnterGameForm(object,sender)
    self.EnterGamePanel:Refresh();

end

function UINewLoginForm:OnClickBtnCloseLoginFailPanel(object,sender)
    self.GobjLoginFailPanel:SetActive(false);
end

function UINewLoginForm:OnGameLevelBtnClick(object,sender)
    if not self.GameLevelTipsVisible then
        self.CSForm:PlayShowAnimation(self.GameLevelTipsPanelTrans)
    end
    self.GameLevelTipsVisible = true
end

function UINewLoginForm:GameLevelTipsCloseBtnClick(object,sender)
    if self.GameLevelTipsVisible then
        self.CSForm:PlayHideAnimation(self.GameLevelTipsPanelTrans)
    end
    self.GameLevelTipsVisible = false
end


--Open the server prompt interface
function UINewLoginForm:OnOpenLoginFailPanel(currentTime, openTime)
    --[[
    self.GobjLoginFailPanel:SetActive(true);
    self.isCheck = true;
    UIUtils.SetTextYYMMDDHHMMSS(self.TxtOpenTips, openTime);
    self.curRemainTime = openTime - currentTime;
    self.curShowTime = math.floor(self.curRemainTime);
    UIUtils.SetTextDDHHMMSS(self.TxtCountdown, self.curRemainTime < 0 and 0 or self.curRemainTime);
    ]]
    Utils.ShowMsgBox(function (code) 
        if code ==  MsgBoxResultCode.Button2 then
            GameCenter.PushFixEvent(UIEventDefine.UI_LOGIN_NOTICE_OPEN, LoginNoticeType.Login);
        end
    end,"C_GAMESERVER_CLOSED");
end

function UINewLoginForm:OnRefreshAgreementCheckBox(object,sender)
    self.AgCheckedBox.value = GameCenter.LoginSystem.Agreement:CheckAgree();
end

function UINewLoginForm:OnCheckUpdate(needUpdate,sender)
    self.EnterGamePanel:OnCheckUpdate(needUpdate);
end
function UINewLoginForm:Update(dt)
    if self.isCheck then
        self.curRemainTime = self.curRemainTime - dt;
        if self.curRemainTime >= 0 then
            if self.curShowTime ~= self.curRemainTime then
                self.curShowTime = self.curRemainTime;
                UIUtils.SetTextDDHHMMSS(self.TxtCountdown, self.curShowTime < 0 and 0 or self.curShowTime);
            end
        else
            self.isCheck = false;
            self.GobjLoginFailPanel:SetActive(false);
        end
    end
end



function UINewLoginForm:AgUserBtnClick(object,sender)
    
    -- GameCenter.LoginSystem.Agreement:ReadUserAgreement("http://www.qxgame.com.cn/1.html");
end

function UINewLoginForm:AgPrivacyBtnClick(object,sender)
    
    -- GameCenter.LoginSystem.Agreement:ReadPrivacyAgreement("http://www.qxgame.com.cn/2.html");
end

function UINewLoginForm:AgCheckedBoxClick(object,sender)
   if not GameCenter.LoginSystem.Agreement:SetIsAgree(self.AgCheckedBox.value) then
       self.AgCheckedBox.value = false;
   end
end

function UINewLoginForm:OnChangeLanguageOpen()
    self.EnterGamePanel:Hide();
    self.InputAccountPanel:Hide();
    self.ChangeLanguagePanel:Show();
end

function UINewLoginForm:OnChangeLanguageClose()
    self.ChangeLanguagePanel:Hide();    
end

return UINewLoginForm;
