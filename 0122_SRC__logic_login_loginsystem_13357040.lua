------------------------------------------------
-- Author: 
-- Date: 2021-02-26
-- File: LoginSystem.lua
-- Module: LoginSystem
-- Description: Log in to the system
------------------------------------------------
local LoginFailRetCode = require("Logic.Login.LoginFailRetCode");
local LoginPostData = require("Logic.Login.LoginPostData");
local LoginStatus = require("Logic.Login.LoginStatus");
local LoginAgreement = require("Logic.Login.LoginAgreement");
local LoginMapLogicSystem = require("Logic.LoginMapLogic.LoginMapLogicSystem");
local SDKCacheData = CS.Thousandto.CoreSDK.SDKCacheData;
local GameGlobalData = CS.Thousandto.Core.Base.GameGlobalData;
local HardwareManager = CS.Thousandto.Core.Base.HardwareManager;
local MachineUUID = CS.UnityEngine.Gonbest.MagicCube.MachineUUID;
local PathUtils = CS.UnityEngine.Gonbest.MagicCube.PathUtils
local ActionEventCode = CS.Thousandto.Code.Logic.ActionEventCode;

-- Login token timeout is 2 hours Unit: seconds
local L_CN_TOKEN_TIME_OUT = 2 * 60 * 60;
-- The server list timeout is 2 minutes. Unit: seconds. If you do not enter the game server for more than 2 minutes on the login page, the server list will be downloaded again.
local L_CN_SERVERLIST_TIME_OUT = 5 * 60;

local LoginSystem = {
    -- Log in to IP
    LsIP = "";
    -- Submit login http port
    LsHttpPort = 80;-- LsHttpPort = -1;

    -- The last logged-in game server ID --- The ID sent by the server after logging in
    LastEnterGsID = -1;
    -- The last logged in role ID
    LastEnterRoleID = -1;

    -- Is it a whitelist account?
    IsWhiteUser = false;
    -- The time of the last login
    LastLoginSuccessTime = nil,

    -- account
    Account = "",
    -- Signal
    Sign = "",
    -- Platform User ID
    PlatformUID = "",
    -- Timestamp
    TimeStamp = 0,
    -- The unique ID assigned successfully by the server login
    Uid = 0,
    -- Server token saved after SDK login
    AccessToken = "",

    -- If the Flag of the login button is false, it will start to calculate and wait for a while, and start displaying the login button.
    LoginBtnStatusFlag = false,

    -- Account real name age
    Age = 0,

    -- Player's area
    Region = 0,

    -- Submit to the server, select role ID
    SerSelectedRoleID= -1,

    -- Is it a switch role login
    IsChangeRole = false,

    -- Callback Handler connecting to the login server
    OnConnectLoginServerCallBackHandler = nil,
    -- Callback Handler connecting to the game server
    OnConnectGameServerCallBackHandler = nil,

    -- Map logic
    MapLogic = nil,

    -- If the time after login is -1, it means that it is not timed, if it is greater than 0, it means that it is timed
    TimeAfterLogin = -1,
    -- Cache server role information
    Cache_SerNumInfos = nil,
    -- The server ID list of the roles exists
    Cache_ExistRoleServerIDs = nil,
    -- The last logged in server ID
    Cache_LastEnterServerID = nil,
    -- List of servers that change the name
    Cache_ChangeNameServerList = nil,

    -- Processing of login protocol
    Agreement = nil,
}

function LoginSystem:Initialize(clearLoginData)
    -- Debug.Log("LoginSystem:Initialize:" .. tostring(clearLoginData));
    self.MapLogic = LoginMapLogicSystem;
    self.MapLogic:Initialize();
    self.LastLoginSuccessTime = nil;    
    self.TimeAfterLogin = -1;
    self.Agreement = LoginAgreement:New();
    -- Re-associate events, because all registered events will be cleaned up in a cycle of reincarnation.
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_SDK_LOGIN_SUCCESS,self.OnSDKLoginSucess,self);
    if clearLoginData then
        LoginFailRetCode:Initialize(); 
        self.OnConnectLoginServerCallBackHandler = Utils.Handler(self.OnConnectLoginServerCallBack,self,nil,true);
        self.OnConnectGameServerCallBackHandler = Utils.Handler(self.OnConnectGameServerCallBack,self,nil,true);
    end
end

function LoginSystem:UnInitialize(clearLoginData)
    -- Debug.Log("LoginSystem:UnInitialize:" .. tostring(clearLoginData));
    self.MapLogic:UnInitialize();
    -- Re-associate the event,
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_SDK_LOGIN_SUCCESS,self.OnSDKLoginSucess,self);   
    if clearLoginData then        
        self.OnConnectLoginServerCallBackHandler = nil;
        self.OnConnectGameServerCallBackHandler = nil;    
    end

end

function LoginSystem:Update(deltaTime)
    if self.TimeAfterLogin >= 0 then
        self.TimeAfterLogin = self.TimeAfterLogin + deltaTime;
        if self.TimeAfterLogin > L_CN_SERVERLIST_TIME_OUT then
            self.TimeAfterLogin = -1;
            -- Debug.Log("I have been on the login screen for a long time. Please update the server list again!!");
            GameCenter.ServerListSystem:DownloadServerList();
        end
    end
    self.MapLogic:Update(deltaTime);
end

function LoginSystem:OnSDKLoginSucess()
   -- Debug.Log("SDK login successful!!");
   self.LastLoginSuccessTime = nil;
   self.Account = ""; 
end

 -- Determine whether it is currently a valid token
function LoginSystem:GetIsValidToken()
    if self.LastLoginSuccessTime then
        local _s= (CS.System.DateTime.Now - self.LastLoginSuccessTime).TotalSeconds;
        return (_s < L_CN_TOKEN_TIME_OUT);    
    end
    return false;    
end


-- Connect to the login server
function LoginSystem:ConnectLoginServer()
   
    -- If the Token value is still valid, the gateway will not be requested again
    if self:GetIsValidToken() then
        -- Debug.Log("The current Token value is still valid, no need to log in to the gateway server again!");
        -- Refresh the server list again
        GameCenter.ServerListSystem:ProcessServerList(self.Cache_SerNumInfos, self.Cache_ExistRoleServerIDs, self.Cache_LastEnterServerID,self.Cache_ChangeNameServerListe);
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UISERVERLISTFORM_REFRESH_LIST);
        -- Start counting the countdown again
        self.TimeAfterLogin = 0;
        GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);   
        -- Login to the gateway successfully
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_AGENT_LOGIN_SUCCESS);
        return ;
    end

    local _ls = GameCenter.ServerListSystem:GetLoginServer();
    --_ls.Ip = "10.0.1.106";
    --_ls.Port = 9999;
    GameCenter.Network.Disconnect();     
    GameCenter.Network.SetIPAndPort(_ls.Ip,_ls.Port);
    -- Debug.Log("Start connecting to the login server!" .. _ls.Ip .."::".. _ls.Port);    
    
    
    if (CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.IPhonePlayer) then
        self:CallLoginStatus(LoginStatus.ConnectLS_v6);    
    else
        self:CallLoginStatus(LoginStatus.ConnectLS_v4);
    end

    -- Record the logged-in IP
    self.LsIP = _ls.Ip;    
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN, DataConfig.DataMessageString.Get("C_XIAOTIAN_TIPS1"));
    GameCenter.Network.Connect(self.OnConnectLoginServerCallBackHandler);
end


function LoginSystem:OnConnectLoginServerCallBack(result)     
    result = true
    local _ls = GameCenter.ServerListSystem:GetLoginServer();
    -- When entering, cancel the reconnection state
    GameGlobalData.IsReconnecting = false;
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);   
    if (result) then                                
        local _errStr = "Connect ls success :" .. _ls.Ip .. ":" .. _ls.Port;
        Debug.Log(_errStr);
    else
        local _errStr = "Connect ls fail :" .. _ls.Ip .. ":" .. _ls.Port;
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_UPDATE_RECORDER_STEP, { CS.Thousandto.Update.Recorder.StepType.LoginLSServer, 2,  _errStr});                    
        Debug.LogError(_errStr);
    end        
    -- The connection is successful, wait a few frames before sending the message to the server. Prevent the message from failing at some point.
    LuaCoroutineUtils.AsynInvoke(function ()
        if result then           
            self:CallLoginStatus(LoginStatus.ConnectLS_OK);
            -- Start the message thread
            GameCenter.Network.StartThread();
            -- go loginmodule state
            -- self:SendLoginMsg();
            GameCenter.ServerListSystem:ProcessServerList(self.Cache_SerNumInfos, self.Cache_ExistRoleServerIDs, self.Cache_LastEnterServerID,self.Cache_ChangeNameServerListe);
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UISERVERLISTFORM_REFRESH_LIST);
            -- Start counting the countdown again
            self.TimeAfterLogin = 0;
            GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);   
            -- Login to the gateway successfully
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_AGENT_LOGIN_SUCCESS);
        
        else            
            self:CallLoginStatus(LoginStatus.ConnectLS_Fail);
            GameCenter.MsgPromptSystem:CloseMsgBox();
            Utils.ShowMsgBoxAndBtn(nil,"C_MSGBOX_OK",nil,"C_LOGIN_CONNECT_LS_FAIL");
        end
    end,3);
end

-- Reconnect to the game server
function LoginSystem:ReconnectGameServer(isChangeRole)
    self:ConnectGameServer(GameCenter.ServerListSystem.ChooseGameServerID,self.SerSelectedRoleID,isChangeRole)
end
-- Log in to the game server
function LoginSystem:ConnectGameServer(serID,CharID,isChangeRole)
    self.IsChangeRole  = isChangeRole;
    self.SerSelectedRoleID = CharID;
    GameCenter.ServerListSystem.ChooseGameServerID = serID;

    local _gs = GameCenter.ServerListSystem:FindServer(serID);
    
    if (_gs == nil) then
        Debug.LogError("No game server ID selected!" .. serID);
        return;
    else
        Debug.Log("Start connecting to the game server ID!" .. serID .."::".. _gs.Ip .."::".. _gs.Port) ;    
    end


    GosuSDK.DownloadServerList(function(allList)
        self.repeatCount = 0
        
        local server = GosuSDK.FindServerByID(allList, serID)

        if server then
            Debug.Log(string.format("✅ Found server: %s (ID=%d), Status=%d", server.svr_name, server.svr_id, server.svr_status))

            if server.svr_status == 1 then
                Debug.Log("🔓 Server is open")
                if _gs and _gs.Ip then
                    self:enterGameGosu(_gs)
                    -- return
                end
            else
                Debug.Log("🔒 Server is closed or under maintenance")
                
                GosuSDK.ShowMessageBox(
                    -- GosuSDK.Events.GOSU_AT_MAINTAIN,
                    GosuSDK.GetLangString("GOSU_AT_MAINTAIN"),
                    nil,
                    DataConfig.DataMessageString.Get("C_MSGBOX_OK"),
                    function()
                        -- GameCenter.SDKSystem:OpenURL(GosuSDK.Events.GG_STORE_LINK)
                    end
                )
                
            end
        else
            Debug.LogError("❌ Server with ID " .. tostring(serID) .. " not found.")
            Debug.Log("🔒 Server is closed or under maintenance")
            
            GosuSDK.ShowMessageBox(
                -- GosuSDK.Events.GOSU_AT_MAINTAIN,
                GosuSDK.GetLangString("GOSU_AT_MAINTAIN"),
                nil,
                DataConfig.DataMessageString.Get("C_MSGBOX_OK"),
                function()
                   -- GameCenter.SDKSystem:OpenURL(GosuSDK.Events.GG_STORE_LINK)
                end
            )
            
        end
    end)

    -- Non-whitelisted users and the server is in maintenance status, a maintenance prompt pops up
    -- if ((not self.IsWhiteUser) and _gs.IsMaintainServer) then
    --     Debug.Log("Server maintenance, not whitelisted, connection prohibited.");
       
    --     -- Utils.ShowMsgBoxAndBtn(nil,"C_MSGBOX_OK",nil,"C_LOGIN_SERVER_MAINTAIN");
    --     GosuSDK.ShowMessageBox(
    --         GosuSDK.Events.GOSU_AT_MAINTAIN,
    --         nil,
    --         DataConfig.DataMessageString.Get("C_MSGBOX_OK"),
    --         function()
               
    --         end
    --     )
    --     return;
    -- end



    -- GameCenter.SDKSystem:SetServerInfo(tostring(_gs.ServerId), _gs.Name);
    -- GameCenter.Network.Disconnect();
    -- GameCenter.Network.SetIPAndPort(_gs.Ip,_gs.Port);
    -- GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN, DataConfig.DataMessageString.Get("C_XIAOTIAN_TIPS2"));
    -- GameCenter.Network.Connect(self.OnConnectGameServerCallBackHandler);
end

function LoginSystem:enterGameGosu(_gs)
    GameCenter.SDKSystem:SetServerInfo(tostring(_gs.ServerId), _gs.Name);
    GameCenter.Network.Disconnect();
    GameCenter.Network.SetIPAndPort(_gs.Ip,_gs.Port);
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN, DataConfig.DataMessageString.Get("C_XIAOTIAN_TIPS2"));
    GameCenter.Network.Connect(self.OnConnectGameServerCallBackHandler);

end



function LoginSystem:OnConnectGameServerCallBack(result)     
    if (self.repeatCount ~=nil and self.repeatCount > 0) then
        Debug.LogError("OnConnectGameServerCallBack repeat count:" .. tostring(self.repeatCount));
        return
    end
    self.repeatCount = self.repeatCount + 1;

     local _isChangeRole = self.IsChangeRole;
     local _CharID = self.SerSelectedRoleID;
     local _serID = GameCenter.ServerListSystem.ChooseGameServerID;
     local _gs = GameCenter.ServerListSystem:FindServer(_serID);
     -- When entering, cancel the reconnection state
     GameGlobalData.IsReconnecting = false;
     GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);        
     if (result) then
  

        -- Save recent server
        local key = GosuSDK.GetRecentServerKey(GosuSDK.Events.GOSU_RECENT_SERVER)
        GosuSDK.RecordValue(key, _gs.ServerId)
        -- print("Saved Value:", GosuSDK.GetLocalValue(key))


        GameCenter.ServerListSystem:SetLastEnterServer(_gs);
        local _errStr = "Connect gs success :" .. _gs.Ip .. ":" .. _gs.Port;
        Debug.Log(_errStr);
     else
         local _errStr = "Connect gs fail :" .. _gs.Ip .. ":" .. _gs.Port;
         GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_UPDATE_RECORDER_STEP, { CS.Thousandto.Update.Recorder.StepType.EnterGSServer, 8, _errStr });         
         Debug.LogError(_errStr);
     end
     -- The connection is successful, wait a few frames before sending the message to the server. Prevent the message from failing at some point.
     LuaCoroutineUtils.AsynInvoke(function ()
         if result then           
             self:CallLoginStatus(LoginStatus.ConnectGS_OK);
             -- Start the message thread
             GameCenter.Network.StartThread();
             self:SendLoginGameMSg(_serID,_CharID,_isChangeRole);            
         else            
             self:CallLoginStatus(LoginStatus.ConnectGS_Fail);
             GameCenter.MsgPromptSystem:CloseMsgBox();
             Utils.ShowMsgBoxAndBtn(nil,"C_MSGBOX_OK",nil,"C_LOGIN_CONNECT_SERVER_FAIL");
         end
     end,3);
end

-- #region //Send network messages

-- Send login message
function LoginSystem:SendLoginMsg()
    local _ip,_port = GameCenter.Network:GetIPAndPort();
    Debug.Log(string.format("login ls: ip %s port %s", _ip, _port));
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN, DataConfig.DataMessageString.Get("C_XIAOTIAN_TIPS1"));    
    if (GameCenter.SDKSystem:IsSDKLogin()) then
        self:SendLoginMsgForSDK();    
    else    
        self:SendLoginMsgWithoutSDK();
    end
end

-- Log in through SDK information.
function LoginSystem:SendLoginMsgForSDK()
    Debug.Log("SendLoginMsgForSDK");
    self.AccessToken = SDKCacheData.Token;

    local reqLogin = ReqMsg.MSG_Login.ReqLogin:New();   
    reqLogin.accessToken = self.AccessToken;
    reqLogin.platformName = self:GetPlatformName();
    reqLogin.platformUid = SDKCacheData.PlatformUID;
    reqLogin.platformAccount = SDKCacheData.PlatUserName;
    reqLogin.machineCode = MachineUUID.Value;
    reqLogin.imei = HardwareManager.DeviceInfo:GetPhoneImei();
    reqLogin.mac = HardwareManager.DeviceInfo:GetMacAddress();
    reqLogin.cpdid = SDKCacheData.CPDid;
    if (reqLogin.imei == nil or reqLogin.imei == "") then
        reqLogin.imei = "null";
    end

    if reqLogin.mac == nil or reqLogin.mac == "" then
        reqLogin.mac = "null";
    end
    -- Record the account name, used to upload logs
    AppPersistData.UserName = reqLogin.platformUid;
    reqLogin:Send();
    Debug.Log(string.format("SDK send connect ls: imei=%s  mac=%s machineCode=%s", reqLogin.imei, reqLogin.mac, reqLogin.machineCode));
    Debug.Log(string.format("login: platformName=%s  uid=%s account=%s funcellUUID=%s", reqLogin.platformName, reqLogin.platformUid, reqLogin.platformAccount, SDKCacheData.PlatformUID));
end

--/ <summary>
-- / Login processing without SDK
--/ </summary>
function LoginSystem:SendLoginMsgWithoutSDK()
    Debug.Log("SendLoginMsgWithoutSDK");
    local reqLogin = ReqMsg.MSG_Login.ReqLogin:New();
    self.AccessToken = self.Account;
    reqLogin.accessToken = self.AccessToken;
    -- Only use PC under Editor
    reqLogin.platformName = "PC";
    reqLogin.platformUid = self.Account;
    reqLogin.platformAccount = "";
    reqLogin.imei = HardwareManager.DeviceInfo:GetPhoneImei();
    reqLogin.mac = HardwareManager.DeviceInfo:GetMacAddress();
    reqLogin.machineCode = MachineUUID.Value;
    reqLogin.cpdid = "";
    -- Record the account name, used to upload logs
    AppPersistData.UserName = reqLogin.platformUid;

    reqLogin:Send();

    Debug.Log(string.format("PC send connect ls: imei=%s  mac=%s machineCode=%s platformName=%s",  reqLogin.imei, reqLogin.mac, reqLogin.machineCode, reqLogin.platformName));
end


--/ <summary>
-- / Send messages entering the game and log in to GS
-- / If it is -999, it means the default last selected role.
-- / If it is -1 means that the role is created
--/ </summary>
function LoginSystem:SendLoginGameMSg(serID,charID,isChangeRole)
    self.Uid = GameCenter.LoginSystem.Account;

    local _ip,_port = GameCenter.Network:GetIPAndPort();
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN, DataConfig.DataMessageString.Get("C_XIAOTIAN_TIPS2"));
    Debug.Log(string.format("Login gs: ip=%s port=%s serverid=%s, uid = %s", _ip,_port, serID, self.Uid));


    local _roleID = charID or -999;
    if self.LastEnterGsID == serID then
        if (_roleID == -999) then
            _roleID = self.LastEnterRoleID;
        end
    end

    local loginGame = ReqMsg.MSG_Register.ReqLoginGame:New();
    local utime = os.time();
    local sign = string.format("account=%s+utime=%s+key=%s", GosuSDK.GetLocalValue("account"), utime, GosuSDK.NewMd5)
       
    loginGame.accessToken = self.AccessToken;
    loginGame.machineCode = MachineUUID.Value;
    loginGame.platformName = self:GetPlatformName();
    loginGame.sign = string.lower(MD5Utils.MD5String((sign)));
    loginGame.time = utime;
    loginGame.languageType = GosuSDK.SendLangToServer();
    loginGame.userId = -999; --self.Uid;
    loginGame.serverId = serID;
    loginGame.funcelUUid = SDKCacheData.PlatformUID;
    loginGame.platUserName = tostring(self.Uid); --SDKCacheData.PlatUserName;
    loginGame.roleId = _roleID;
    loginGame.isWhite = self.IsWhiteUser;
    loginGame.isCertify = GameCenter.SDKSystem:IsRealNameAuthorized();
    loginGame.isChangeRole = isChangeRole;
    




    local type = PathUtils.GetBuildType();
    if (type == 0) then
        loginGame.os = "editor";
    elseif (type == 1)then
        loginGame.os = "ios";
    elseif (type == 2)then
        loginGame.os = "android";
    elseif(type == 3) then
        loginGame.os = "win";
    end
    loginGame.os = "android";

    if (loginGame.funcelUUid == nil  or loginGame.funcelUUid == "")then
        loginGame.funcelUUid = "test_" .. tostring(SDKCacheData.Token);
    end

    -- Processing additional data - a hidden rule, all keys of additional data are lowercase strings.
    -- The global platform ID of the game
    loginGame.extension:Add({key="fgi",value=tostring(GameCenter.SDKSystem.LocalFGI)});
    -- Related extensions of QQ Hall
    if GameCenter.SDKSystem:IsQQPC() then
        local _dats = GameCenter.SDKSystem:GetPCParams();
        Debug.LogError("GameCenter.SDKSystem:GetPCParams:Count:::" .. tostring(_dats.Count));    
        for _k,_v in pairs(_dats) do         
            loginGame.extension:Add({key=string.lower(_k),value=tostring(_v)});
        end
    end
    -- Debug.LogTable(loginGame);
    loginGame:Send();
end


--#endregion


-- #region--process network messages
--/ <summary>
-- / Log in to the server successfully
--/ </summary>
--/ <param name="result">MSG_Login.ResLoginSuccess </param>
function LoginSystem:OnGS2U_LoginSuccess(result)
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_UPDATE_RECORDER_STEP, { CS.Thousandto.Update.Recorder.StepType.LoginLSServer });

    -- LoginLogic.StopLoginStepBox("Login Verification Successfully", null, false);
    self.LoginBtnStatusFlag = true;

    self:CallLoginStatus(LoginStatus.RecvLSCallback_OK);
   
    -- Whitelisted users
    Debug.Log("Login gateway verification is successful, whether it is a whitelist user:" .. tostring(result.isWhite) .. ";;lastServer:" .. tostring(result.lastEnterSeverId) .. ";;;" ..  tostring(result.lastEnterRoleId) .. ";;region;" .. tostring(result.region));

    -- Save the data after login successfully
    self.Region = result.region;
    self.Sign = result.sign;
    self.TimeStamp = result.time;
    self.Uid = result.userId;
    self.LsHttpPort = result.httpPort;
    self.LastEnterGsID = result.lastEnterSeverId;
    self.LastEnterRoleID = result.lastEnterRoleId;
    self.IsWhiteUser = result.isWhite;
    -- Cache server role information
    self.Cache_SerNumInfos = result.serverInfo;
    -- The server ID list of the roles exists
    self.Cache_ExistRoleServerIDs = result.creatRoleServerIDList;
    -- The last logged in server ID
    self.Cache_LastEnterServerID = result.lastEnterSeverId;
    -- List of servers that change the name
    self.Cache_ChangeNameServerList = result.serverChangeName;

    AppPersistData.GameUserID = tostring(result.userId);

    GameCenter.ServerListSystem:ProcessServerList(self.Cache_SerNumInfos, self.Cache_ExistRoleServerIDs, self.Cache_LastEnterServerID,self.Cache_ChangeNameServerListe);
    -- Record the last successful login time
    self.LastLoginSuccessTime = CS.System.DateTime.Now;    
    
    GameCenter.MsgPromptSystem:CloseMsgBox();   
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
    -- After logging in successfully, disconnect from the gateway server
    GameCenter.Network.Disconnect();
    self.TimeAfterLogin = 0;
     -- Login to the gateway successfully
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_AGENT_LOGIN_SUCCESS);
end

-- Login to the proxy server failed
--MSG_Login.ResLoginFailed
function LoginSystem:GS2U_ResLoginFailed(result)

    Debug.LogError("Login ls fail,errorCode:" .. result.reason);

    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
    self.LoginBtnStatusFlag = true;
    self:CallLoginStatus(LoginStatus.RecvLSCallback_Fail);
    local _errorMsg = LoginFailRetCode:GetLoginAgentErrDesc(result.reason);
    if(result.reason > 1 and result.reason <= 6) then
        _errorMsg = UIUtils.CSFormat(_errorMsg,result.reason)
    else
        _errorMsg = string.format("%s--%s",_errorMsg,result.reason)
    end   
	Debug.LogError("Failed to log in to the gateway server:" ..  _errorMsg);
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_UPDATE_RECORDER_STEP, { CS.Thousandto.Update.Recorder.StepType.LoginLSServer, 1, _errorMsg }); 
    -- After login failed, disconnect from the gateway server
    GameCenter.Network.Disconnect();
    -- Click OK before switching account
    GameCenter.MsgPromptSystem:ShowMsgBox( 
        _errorMsg,
        DataConfig.DataMessageString.Get("C_MSGBOX_OK"), 
        nil,
        function (x)             
            GameCenter.PushFixEvent(UIEventDefine.UILOGINFORM_SWITCHACCOUNT_OPEN);
        end
    );  
end


--/ <summary>
-- / failed to log in to the game server
--/ </summary>
--/ <param name="result">MSG_Register.ResLoginGameFailed</param>
function LoginSystem:GS2U_ResLoginGameFailed(result)

    Debug.LogError("Login gs fail,errorCode:" .. result.reason);

    local _errorStr = LoginFailRetCode:GetLoginServerErrDesc(result.reason);    
    if _errorStr then
        if result.reason > 0  then
            _errorStr = DataConfig.DataMessageString.Get("LoginFailTips_SDK_ERROR_CODE",_errorStr,result.reason); 
        end        
    else
        _errorStr = DataConfig.DataMessageString.Get("LoginFailTips_Unknow_Error_Code",result.reason);
    end 

    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
    GameCenter.PushFixEvent(UIEventDefine.UISERVERLISTFORM_CLOSE);
    GameCenter.MsgPromptSystem:CloseMsgBox();

    Debug.LogError("Failed to log into the game server:" ..  _errorStr);
    -- Login ticket is invalid and login is prohibited, kicked, and you can directly open the UI to switch account
    if result.reason == 9 or result.reason == 17 then        
        GameCenter.PushFixEvent(UIEventDefine.UILOGINFORM_SWITCHACCOUNT_OPEN);        
    elseif result.reason == -6 then
        -- It’s not that the server opening time has not come, or you’ll just give me a prompt.
        GameCenter.PushFixEvent(UIEventDefine.UILOGINFORM_SHOWLOGINFAILPANEL, result.currentTime, result.openTime);
    else
        GameCenter.MsgPromptSystem:ShowMsgBox( 
            _errorStr,
            DataConfig.DataMessageString.Get("C_MSGBOX_OK"), 
            nil,
            function (x) 
                GameCenter.LoginSystem:SwitchAccount();
            end
        );
    end

end


--/ <summary>
-- / Log in to the game server successfully
--/ </summary>
--/ <param name="result">MSG_Register.ResLoginGameSuccess</param>
function LoginSystem:GS2U_ResLoginGameSuccess(result)
    
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_UPDATE_RECORDER_STEP, { CS.Thousandto.Update.Recorder.StepType.EnterGSServer });
    
    Debug.Log("Enter the game successfully,Age:" .. tostring(result.age));
    -- Log in to successfully obtain the role age
    self.Age = result.age;    
    self.userId = result.userId;
    -- Set whether to create a role tag
    GameCenter.SDKSystem.IsCreatePlayerFlag = false;
    AppPersistData.LastServerID = tostring(GameCenter.ServerListSystem.LastEnterServer.ServerId);
    AppPersistData.LastServerName = GameCenter.ServerListSystem.LastEnterServer.Name; 
    GameCenter.ServerListSystem.LastEnterServer.ReallyServerId = result.reallyServerId;

    -- Set the address of the avatar system
    --GameCenter.HeadPicSystem:SetUrl(result.iconUpUrl);
    -- New data statistics interface
    GameCenter.SDKSystem:SendEventLogin();
    -- Statistics
    GameCenter.SDKSystem:ActionEvent(ActionEventCode.EnterServer,
        tostring(GameCenter.ServerListSystem.LastEnterServer.ServerId), 
        GameCenter.ServerListSystem.LastEnterServer.Name
    );
    -- Save the server ID and server name when login is successful
    GameCenter.SDKSystem:SetServerInfo(tostring(GameCenter.ServerListSystem.LastEnterServer.ServerId), GameCenter.ServerListSystem.LastEnterServer.Name);


    -- Log in to the game successfully
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GAME_LOGIN_SUCCESS, result);
    -- Close, message form, waiting for form, enter the game form, server list form
    GameCenter.MsgPromptSystem:CloseMsgBox();

    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);

    GameCenter.PushFixEvent(UIEventDefine.UISERVERLISTFORM_CLOSE);        
    self.TimeAfterLogin = -1;  
end
--#endregion


-- #region--Member Function Function

-- Change account
function LoginSystem:SwitchAccount()            
    ---LoginMapLogicSystem:ClearChacheGo();
    self.LastLoginSuccessTime = nil;    
    GameCenter.GameSceneSystem:ReturnToLogin(true);
end


--/ <summary>
-- / Get the platform name
--/ </summary>
--/ <returns></returns>
function LoginSystem:GetPlatformName()
    if (CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.WindowsEditor or CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.OSXEditor) then
        -- Unified with the server,
        -- 1. In the future, when testing the PC environment, here is "PC"
        -- 2. The real environment is subject to the channel ID returned by the SDK
        return "PC";
    
    else
        -- If all this is empty,
        if (SDKCacheData.Token == nil or SDKCacheData.Token == "") then
            return "PC";
        end
        return GameCenter.SDKSystem.PlatformName;
    end    
end

-- The login process sends some status to the interface to display
function LoginSystem:CallLoginStatus(status)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LOGIN_STATUS, status);
end

-- Submit data that changes login
function LoginSystem:PostChangeLoginData(roleID)
    -- If the last entered game server ID sent by the server is the same as the server ID selected by the local player to enter, then it will be returned.
    --if (_lastEnterGsID == GameCenter.ServerListSystem.SelectedGameServerID) return;
    local _dat = LoginPostData:New();
    _dat.userId = self.Uid;
    _dat.sign = self.Sign;
    _dat.accessToken = self.AccessToken;
    _dat.machineCode = MachineUUID.Value;
    _dat.time = self.TimeStamp;
    _dat.enterServerId = GameCenter.ServerListSystem.ChooseGameServerID;
    _dat.addServerId = GameCenter.ServerListSystem.ChooseGameServerID;
    _dat.deleteServerId = "-1";
    _dat.platformName = self:GetPlatformName();
    _dat.roleId = roleID;

    --[Gosu custom]
    GosuSDK.RecordValue("saveEnterServerId", _dat.enterServerId)
    GosuSDK.RecordValue("saveRoleId", _dat.roleId)

    -- local _url = string.format("http://%s:%d/changelogindata?%s", self.LsIP, self.LsHttpPort,_dat:ToString());
  
    -- LuaCoroutineUtils.WebRequestTextThread(_url);
end

--#endregion


return LoginSystem
