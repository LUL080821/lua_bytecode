------------------------------------------------
-- author:
-- Date: 2019-04-18
-- File: UIEnterGamePanel.lua
-- Module: UIEnterGamePanel
-- Description: Entering the game's Panel,
------------------------------------------------
-- Enter the game form
local UIEnterGamePanel = {
    -- Form
    Form = nil,
    -- Current Panel's Trans
    Trans = nil,
    -- Server Status UILabel
    StatusLabel = nil,
    -- Status Icon UISprite
    StatusIcon  = nil,
    -- Current server name UILabel
    ServerNameLabel = nil,

    -- The background of the lower part UITexture
    --BottomBGTexture = nil,


    -- Switch server button UIButton
    ChangeServerBtn = nil,
    -- Enter the game button UIButton
    EnterGameBtn = nil,
    -- Return to login UIButton
    ReturnLoginBtn = nil,
    -- This is the button to open the login announcement.
    OpenNoticeBtn = nil,

    -- Current server data
    CurrentServerData = nil,
    -- The time of the last click on the entry button
    LastClickEnterBtnTime = nil;
};

-- Panel initialization
function UIEnterGamePanel:Initialize(owner,trans)
    self.Form = owner;
    self.Trans = trans;
    self:FindAllComponents();
    self:RegUICallback();
    return self;
end

-- Panel display
function UIEnterGamePanel:Show()
    self.Trans.gameObject:SetActive(true);    
    --self.CSForm:LoadTexture(self.BottomBGTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_Denglu"));
    UIEnterGamePanel:Refresh(); 
    -- Data for requesting announcements
    GameCenter.NoticeSystem:ReqNoticeData(LoginNoticeType.Login);
end

-- Panel Hide
function UIEnterGamePanel:Hide()
    self.Trans.gameObject:SetActive(false);
end

-- Find all lists
function UIEnterGamePanel:FindAllComponents()
    local _myTrans = self.Trans;
    self.StatusLabel = UIUtils.FindLabel(_myTrans,"Container/ServerShow/Status/Label");
    self.StatusIcon = UIUtils.FindSpr(_myTrans,"Container/ServerShow/Status");
    self.ServerNameLabel = UIUtils.FindLabel(_myTrans,"Container/ServerShow/ServerNameLabel");
    --self.BottomBGTexture = UIUtils.FindTex(_myTrans,"BottomTexture");

    self.ChangeServerBtn = UIUtils.FindBtn(_myTrans,"Container/ServerShow/ChangeServerBtn");
    self.EnterGameBtn = UIUtils.FindBtn(_myTrans,"Container/EnterGameBtn");
    self.ReturnLoginBtn = UIUtils.FindBtn(_myTrans,"Container/TopRight/ChangeAccountBtn");
    self.OpenNoticeBtn = UIUtils.FindBtn(_myTrans,"Container/TopRight/NoticeBtn");
    self.FaceBookBtn = UIUtils.FindBtn(_myTrans,"Container/TopRight/FaceBookBtn");
    self.ChangeLanBtn = UIUtils.FindBtn(_myTrans,"Container/TopRight/ChangeLanBtn");
    -- Switch accounts only in PC mode
    self.ReturnLoginBtn.gameObject:SetActive(not UnityUtils.IsUseUsePCMOdel())
    self:RegUICallback();
end

-- Callback operation for binding UI buttons
function UIEnterGamePanel:RegUICallback()  
    UIUtils.AddBtnEvent(self.ChangeServerBtn,self.OnChangeServerBtnClick,self);
    -- UIUtils.AddBtnEvent(self.EnterGameBtn,self.OnEnterGameBtnClick,self);
    UIUtils.AddBtnEvent(self.EnterGameBtn,self.DoCheckUpdate,self);
    UIUtils.AddBtnEvent(self.ReturnLoginBtn,self.OnReturnLoginBtnClick,self);
    UIUtils.AddBtnEvent(self.OpenNoticeBtn,self.OnOpenNoticeBtnClick,self);
    UIUtils.AddBtnEvent(self.FaceBookBtn,self.OnFaceBookBtnClick,self);
    UIUtils.AddBtnEvent(self.ChangeLanBtn,self.OnChangeLanBtnClick,self);
end


-- Refresh the UI interface
function UIEnterGamePanel:Refresh()
    self.CurrentServerData = GameCenter.ServerListSystem:GetCurrentServer();
    local _sDat = self.CurrentServerData;

   
    -- Gosu custom

    -- Nếu chưa từng chọn server (ChooseGameServerID = -1), thì lấy từ cache
    if GameCenter.ServerListSystem.ChooseGameServerID == -1 then
        local key = GosuSDK.GetRecentServerKey(GosuSDK.Events.GOSU_RECENT_SERVER)
        local serverIdStr = GosuSDK.GetLocalValue(key)

        if serverIdStr ~= "" then
            local serverId = tonumber(serverIdStr)
            if serverId then
                local cachedServer = GameCenter.ServerListSystem:FindServer(serverId)
                if cachedServer ~= nil then
                    _sDat = cachedServer
                   
                    GameCenter.ServerListSystem.ChooseGameServerID = serverId -- set lại server cho đúng khi load từ cache
                  
                end
            end
        end
    end


    if _sDat ~= nil then
        UIUtils.SetTextByString(self.ServerNameLabel, _sDat.Name)
        UIUtils.SetTextByString(self.StatusLabel, self:GetFlagText(_sDat))
        self.StatusIcon.spriteName = self:GetStatusSpriteName(_sDat);
        self.StatusIcon.IsGray = _sDat.IsMaintainServer;
    else
        UIUtils.SetTextByEnum(self.ServerNameLabel, "Not_Select_Server")
        UIUtils.SetTextByEnum(self.StatusLabel, "C_SERVER_STATE_GENERAL")
        self.StatusIcon.spriteName = "n_z_88_1";
        self.StatusIcon.IsGray = false;
    end

    -- The Taiwanese version needs to be switched and shared with Facebook
    local _isTw = (GameCenter.SDKSystem.LocalFGI == 1601);    
    self.FaceBookBtn.gameObject:SetActive(_isTw)
    -- self.ChangeLanBtn.gameObject:SetActive(_isTw and (FLanguage.EnabledSelectLans().Count > 1))
end

-- Change the server button to open the server list
function UIEnterGamePanel:OnChangeServerBtnClick()
    GameCenter.PushFixEvent(UIEventDefine.UISERVERLISTFORM_OPEN);
end

-- Enter the game
function UIEnterGamePanel:OnEnterGameBtnClick()    
    if not GameCenter.LoginSystem.Agreement:CheckAgree() then
        Utils.ShowMsgBoxAndBtn(function(x) 
            if x == MsgBoxResultCode.Button1 then
                GameCenter.LoginSystem.Agreement:SetIsAgree(false);
                GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LOGIN_REFRESH_AGREEMENT_CHECKBOX);
            elseif x == MsgBoxResultCode.Button2 then
                GameCenter.LoginSystem.Agreement:SetIsAgree(true);
                GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LOGIN_REFRESH_AGREEMENT_CHECKBOX);                
            end
        end,"C_BTN_DONT_AGREE","C_BTN_AGREE","C_DONT_AGREE_AGREEMENT");
        -- GameCenter.MsgPromptSystem:ShowMsgBox("Please read carefully and agree to the [00ff00] Game User Agreement [-] and [00ff00] Privacy Protection Agreement [-]", DataConfig.DataMessageString.Get("C_MSGBOX_OK"));
    else
        if (not self.LastClickEnterBtnTime) or (CS.System.DateTime.Now - self.LastClickEnterBtnTime).TotalSeconds > 3  then
            self.LastClickEnterBtnTime = CS.System.DateTime.Now;
            if (self.CurrentServerData) then
                -- Debug.Log("OnEnterGameBtnClick ServerId:" .. tostring(self.CurrentServerData.ServerId));
                GameCenter.LoginSystem:ConnectGameServer(self.CurrentServerData.ServerId);    
            else
                Utils.ShowMsgBox(function (code) 
                    if code ==  MsgBoxResultCode.Button2 then
                        GameCenter.PushFixEvent(UIEventDefine.UI_LOGIN_NOTICE_OPEN, LoginNoticeType.Login);
                    end
                end,"C_GAMESERVER_CLOSED");
            end
        end
    end
  
end

-- Return to login--Switch account
function UIEnterGamePanel:OnReturnLoginBtnClick()
    -- Delete the saved original account information
    --GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LOGIN_SHOW_BTNS);
    -- Gosu custom -- clear recent server cache 
    -- local GOSU_KEY_RECENT = GosuSDK.GetRecentServerKey(GosuSDK.Events.GOSU_L_CN_RECENT_SERVER_KEY)
    -- GosuSDK.RecordValue(GOSU_KEY_RECENT, "{\"data\":[]}")
    GameCenter.ServerListSystem.ChooseGameServerID = -1 -- reset lại giá trị
    GameCenter.LoginSystem:SwitchAccount();
end

-- Open an announcement
function UIEnterGamePanel:OnOpenNoticeBtnClick()
    GameCenter.PushFixEvent(UIEventDefine.UI_LOGIN_NOTICE_OPEN, LoginNoticeType.Login)--CS.Thousandto.Code.Logic.NoticeType.Login);
end

-- Jump Facebook
function UIEnterGamePanel:OnFaceBookBtnClick()
    GameCenter.SDKSystem:DoShare(DataConfig.DataGlobal[GlobalName.TW_ShareLink].Params);
end

-- Switch language
function UIEnterGamePanel:OnChangeLanBtnClick()

    -- chỉnh sửa để thực hiện đổi lang
    -- if CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.IPhonePlayer then
    --     GosuSDK.ShowMessageBox(
    --         GosuSDK.GetLangString("CHANGE_LANG_ALERT_IOS"),
    --         nil,
    --         DataConfig.DataMessageString.Get("C_MSGBOX_OK"),
    --         function()
                
    --         end
    --     )
    --     else
    --         Utils.ShowMsgBox(function(code)
    --             if code == MsgBoxResultCode.Button2 then
    --                 GameCenter.PushFixEvent(UIEventDefine.UILOGINFORM_CLOSE)
    --                 self.Form.ClearCacheScript:DoChangeLang() -- [Gosu Lang] call hàm C#
    --             end
    --         end, "C_RESTART_GAME_TIPS")

    -- end

    
    if(LOAD_LANG_INGAME) then
        GameCenter.PushFixEvent(UIEventDefine.UILOGINFORM_CHANGELANGUAGE_OPEN);
    else
        Utils.ShowMsgBox(function(code)
            if code == MsgBoxResultCode.Button2 then
                GameCenter.PushFixEvent(UIEventDefine.UILOGINFORM_CLOSE)
                self.Form.ClearCacheScript:DoChangeLang("",true) -- [Gosu Lang] call hàm C#
            end
        end, "C_RESTART_GAME_TIPS")
    end

    -- Utils.ShowMsgBox(function(code)
    --     if code == MsgBoxResultCode.Button2 then
    --         GameCenter.PushFixEvent(UIEventDefine.UILOGINFORM_CLOSE)
    --         self.Form.ClearCacheScript:DoChangeLang("",true) -- [Gosu Lang] call hàm C#
    --     end
    -- end, "C_RESTART_GAME_TIPS")

    -- GameCenter.PushFixEvent(UIEventDefine.UILOGINFORM_CHANGELANGUAGE_OPEN);

    
end

-- -This is exactly the same as UIServerItem,
function UIEnterGamePanel:GetFlagText(sInfo)
    if sInfo.IsFullServer then
        return DataConfig.DataMessageString.Get("C_SERVER_STATE_HOT");
    elseif sInfo.IsRecommendServer then
        return DataConfig.DataMessageString.Get("Hot_Server");
    elseif sInfo.IsNewServer then
        return DataConfig.DataMessageString.Get("C_SERVER_STATE_NEW");
    else
        return DataConfig.DataMessageString.Get("C_SERVER_STATE_GENERAL");
    end  
 end
 -- -This is exactly the same as UIServerItem,
 function UIEnterGamePanel:GetStatusSpriteName(sInfo)
    if not sInfo.IsFullServer then
        return "n_z_88_1";
    else
        return "n_z_88";
    end
end

function UIEnterGamePanel:DoCheckUpdate()
    GameCenter.SDKSystem:CheckNeedUpdate();
end

function UIEnterGamePanel:OnCheckUpdate(needUpdate,sender)
    Debug.Log("Receive check update event!! " .. tostring(needUpdate))
    if needUpdate == true then
        
        GameCenter.MsgPromptSystem:ShowMsgBox( 
            -- DataConfig.DataMessageString.Get("C_RESTART_GAME_TIPS"), 
            GosuSDK.GetLangString("NEED_UPDATE_ALERT"),
            DataConfig.DataMessageString.Get("C_MSGBOX_OK"), 
            nil,
            function (x)             
               
            end
        );  
        return
    end
    self:OnEnterGameBtnClick()
end

return UIEnterGamePanel;
