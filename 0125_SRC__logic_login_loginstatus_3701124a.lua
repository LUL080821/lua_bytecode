
------------------------------------------------
-- Author: 
-- Date: 2021-02-26
-- File: LoginStatus.lua
-- Module: LoginStatus
-- Description: Login status
------------------------------------------------
local LoginStatus = {
    -- Call SDK to log in
    CallSDK = 1, 
    -- Get the server list
    CallServerlist = 2,     
    -- Connect to LS with ipv4
    ConnectLS_v4 = 3,       
    -- Connect to LS with ipv6
    ConnectLS_v6 = 4,       
    -- Connecting to LS successfully
    ConnectLS_OK = 5,       
    -- Connecting to LS failed, it may be that the IP is not working
    ConnectLS_Fail = 6,     
    -- Connection successfully
    RecvLSCallback_OK = 7,  
    -- Connection failed
    RecvLSCallback_Fail = 8,    
    -- Connecting to GS successfully
    ConnectGS_OK = 9,   
    -- Connecting to GS may fail, it may be that the IP is not working.
    ConnectGS_Fail = 10,   
}

return LoginStatus