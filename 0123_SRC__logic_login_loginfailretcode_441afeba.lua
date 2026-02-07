------------------------------------------------
-- Author: 
-- Date: 2021-02-26
-- File: LoginFailRetCode.lua
-- Module: LoginFailRetCode
-- Description: Login failed return code
------------------------------------------------

local LoginFailRetCode = {
   LoginServer,
   LoginServerUnknowErr,
   LoginAgent,
   LoginAgentUnknowErr,
}

function LoginFailRetCode:Initialize()
    self:InitLoginServer();
    self:InitLoginAgent();
end

-- Description of the return error code of the initial login gateway server
function LoginFailRetCode:InitLoginAgent()
    if self.LoginAgent == nil then    
        self.LoginAgentUnknowErr = "C_LOGIN_ACCOUNT_VERIFY_FAIL"

        self.LoginAgent = Dictionary:New();
        -- Verification failed
        self.LoginAgent:Add(1,"C_LOGIN_ACCOUNT_VERIFY_FAIL");
        -- Verification failed, account blocked
        self.LoginAgent:Add(2,"C_LOGIN_ACCOUNT_VERIFY_FAIL_ACCOUNT");
        -- Verification failed, machine code was blocked
        self.LoginAgent:Add(3,"C_LOGIN_ACCOUNT_VERIFY_FAIL_MACCODE");
        -- Verification failed, mac address blocking
        self.LoginAgent:Add(4,"C_LOGIN_ACCOUNT_VERIFY_FAIL_MAC");
        -- Verification failed, IMEI address blocking
        self.LoginAgent:Add(5,"C_LOGIN_ACCOUNT_VERIFY_FAIL_IMEI");
        -- Verification failed, IP address blocking
        self.LoginAgent:Add(6,"C_LOGIN_ACCOUNT_VERIFY_FAIL_IP");
    end     
end



-- Description of the error code returned by initializing login to the game server

function LoginFailRetCode:InitLoginServer()
    if self.LoginServer == nil then        
    
        self.LoginServerUnknowErr = "LoginFailTips_Unknow_Error_Code"

        self.LoginServer = Dictionary:New();

        -- =================================================--
        -- Invalid date
        self.LoginServer:Add(-1,"C_LOGIN_ERROR_INVALIDATE");
        -- time out
        self.LoginServer:Add(-2,"C_LOGIN_ERROR_OVERTIME");
        -- Repeat login
        self.LoginServer:Add(-3,"C_MSG_REGISTER_MULTI_LOGIN");
        -- The area code is not on this server
        self.LoginServer:Add(-4,"LoginFailTips_NotAtThisServer");
        -- The number of online users has reached the limit
        self.LoginServer:Add(-5,"LoginFailTips_UserMax");
        -- The server opening time has not come
        self.LoginServer:Add(-6,"LoginFailTips_TimeNotUp");
        -- The number of people who have created a corner in this area has reached the upper limit, please change to the latest area server.
        self.LoginServer:Add(-7,"C_CREATEPLAYER_ERROR_REG_MAX");  

        -- ===================== The following are the prompts for SDK login exceptions======================--
        -- fail
        self.LoginServer:Add(0,"TishiFailure");
        -- success
        self.LoginServer:Add(1,"TishiSuccess");
        -- The game is invalid
        self.LoginServer:Add(2,"GAME_INVALID");
        -- Invalid channel
        self.LoginServer:Add(3,"CHANEL_INVALID");
        -- Authentication exception
        self.LoginServer:Add(5,"AUTH_EXCEPTION");
        -- Invalid user
        self.LoginServer:Add(6,"USER_INVALID");
        -- Verification exception
        self.LoginServer:Add(8,"CHECK_INVALID");
        -- The login ticket is invalid
        self.LoginServer:Add(9,"LOGIN_TOKEN_INVALID");
        -- Signature verification failed
        self.LoginServer:Add(12,"SING_CHECK_INVALID");
        -- Payment is prohibited
        self.LoginServer:Add(13,"PAY_FORRBIDDEN");
        -- Internal exception
        self.LoginServer:Add(15,"INTERNAL_INVALID");
        -- Parameter exception
        self.LoginServer:Add(16,"PARAMS_EXCEPTION");
        -- Login is prohibited, kicked
        self.LoginServer:Add(17,"LOGIN_FORBIDDEN");
        -- Invalid IP
        self.LoginServer:Add(18,"IP_INVALID");
        -- Requests too frequently
        self.LoginServer:Add(22,"REQUEST_TO_MUCH");
        -- District service under maintenance
        self.LoginServer:Add(23,"SERVER_MAINTAIN");
        -- There are too many IP login accounts
        self.LoginServer:Add(24,"CUR_IP_HAD_TO_MANY_ACCOUNT");

    end
end

-- Description of error code for logging into the gateway server
function LoginFailRetCode:GetLoginAgentErrDesc(code)
    local _key = self.LoginAgent[code];
    if _key then
        return DataConfig.DataMessageString.Get(_key);
    else
        return DataConfig.DataMessageString.Get(self.LoginAgentUnknowErr);
    end    
end



-- Error code description for logging into the game server
function LoginFailRetCode:GetLoginServerErrDesc(code)
    local _key = self.LoginServer[code];
    if _key then
        return DataConfig.DataMessageString.Get(_key);
    else
        return DataConfig.DataMessageString.Get(self.LoginServerUnknowErr);
    end    
end


return LoginFailRetCode