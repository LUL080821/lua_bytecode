local LoginMapStateCode = {

    -- idle
    Idle = 1,
    -- Login scene has been loaded
    LoginSceneFinished = 3,
    -- The form system is ready
    FormSystemReadyOK = 4,
    -- Start login and open
    LoginFormReadyOk = 5,    
    -- SDK login
    StartSDKLogin = 6,
    -- SDK login completed
    SDKLoginEnd = 7,
    -- Server list download
    StartDownLoadServerList = 8,    
    -- Log in to the gateway server
    LoginAgentServerOK = 9,
    -- Wait for the effect to enter
    WaitEnterEffectShow = 10,
    -- Wait for the effect to enter
    StartEnterGamePanelOpen = 11,
    -- The game server connection is successful
    LoginGameServerOK = 12,
    -- Wait for the effect of leaving
    WaitLeaveEffectShow = 13,
    -- Enter the role list
    StartRoleListFormOpen = 14,    
    -- Role List Form Opens
    RoleListFormOpened = 15,  
    -- The character selection panel opens
    SelectRolePanelOpened = 16,  
    -- Create Role Panel Open
    CreateRolePanelOpened = 17,  
    -- Automatic reconnection
    StartAutoToSelectPlayer = 18,
    -- Create role completion
    CreatePlayerOK = 19,
    -- Wait for the role to leave effect after creating it
    WaitCreateRoleLeavelEffect = 20,        
    -- After the creation of the role effect is played, the process of changing the scene is entered.
    CreateRoleChangeMap = 21,        
    
}

return LoginMapStateCode
