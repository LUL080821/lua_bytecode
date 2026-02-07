local LoginMapStateCode = require("Logic.LoginMapLogic.LoginMapStateCode");

local UnityEngine = CS.UnityEngine

local LoginMapLogicSystem = {
    CurrentState = 0,
    SceneRootGo = nil,
    SelectRoleListSceneGo = nil,
    LGSceneGo = nil,
    LGEnterEffectGo = nil,
    LGEnterEffectWaitTime = 0, 
    LGExitEffectAnim = nil,
    LGExitEffectGo = nil,
    LGExitEffectWaitTime = 0, 
    -- Waiting time for playback effects after creating a character
    LGCreatePlayerEffectWaitTime = 0,    

    -- Special effects after creating a role OK
    LGCreatePlayerOKEffectGO =nil,
    -- Showcase that needs to be loaded
    NeedCallLoadShow = false;
    --LogicGo = nil,
}

local L_LoginStateFunc;


function LoginMapLogicSystem:Initialize()    
    --self.LogicGo = GameObject("[Login]");
    --LuaBehaviourManager:Add(self.LogicGo.transform,self);
    self:SetState(LoginMapStateCode.Idle);
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_SDK_LOGIN_SUCCESS,self.OnSDKLoginSucess,self);
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_LOGINSCENE_READYOK,self.OnLoginSceneReadyOK,self);
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_ENTER_LOGINSTATE,self.OnEnterLoginState,self);
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_LEAVE_LOGINSTATE,self.OnLeaveLoginState,self);
    GameCenter.RegFixEventHandle(LogicLuaEventDefine.EID_EVENT_AGENT_LOGIN_SUCCESS,self.OnAgentLoginSucess,self)
    GameCenter.RegFixEventHandle(LogicLuaEventDefine.EID_EVENT_GAME_LOGIN_SUCCESS,self.OnGameLoginSucess,self)
end

function LoginMapLogicSystem:UnInitialize()
    self:SetState(LoginMapStateCode.Idle);
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_SDK_LOGIN_SUCCESS,self.OnSDKLoginSucess,self);
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_LOGINSCENE_READYOK,self.OnLoginSceneReadyOK,self);
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_ENTER_LOGINSTATE,self.OnEnterLoginState,self);
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_LEAVE_LOGINSTATE,self.OnLeaveLoginState,self);
    GameCenter.UnRegFixEventHandle(LogicLuaEventDefine.EID_EVENT_AGENT_LOGIN_SUCCESS,self.OnAgentLoginSucess,self)
    GameCenter.UnRegFixEventHandle(LogicLuaEventDefine.EID_EVENT_GAME_LOGIN_SUCCESS,self.OnGameLoginSucess,self)
    --LuaBehaviourManager:Remove(this);
    --GameObject.Destroy(self.LogicGo);
    --self.LogicGo = nil;
    
    self.LGExitEffectWaitTime = 0
    self:ClearChacheGo();
end

-- #region //External message processing
function LoginMapLogicSystem:OnLoginSceneReadyOK(obj,sender)
    self:SetState(LoginMapStateCode.LoginSceneFinished);
end

function LoginMapLogicSystem:OnSDKLoginSucess(obj,sender)
    -- After the SDK login is successful, open the game panel
    self:SetState(LoginMapStateCode.SDKLoginEnd);
end

function LoginMapLogicSystem:OnAgentLoginSucess(obj,sender)
    -- After the gateway server connection is successful, open the service list
    self:SetState(LoginMapStateCode.LoginAgentServerOK);
end

function LoginMapLogicSystem:OnGameLoginSucess(obj,sender)
    -- The game server connection is successful
    self:SetState(LoginMapStateCode.LoginGameServerOK);
end

function LoginMapLogicSystem:OnEnterLoginState(obj,sender)
    -- Enter LoginState
    if obj then        
        self.IsSwitchAccount = ((obj & 1) == 1);
        self.IsToSelectPlayer = ((obj & 2) == 2);       
    end
    self:ClearChacheGo();  
end

function LoginMapLogicSystem:OnLeaveLoginState(obj,sender)
    -- Leave LoginState
end

--#endregion

function LoginMapLogicSystem:SetState(state)
    if self.CurrentState ~= state then
        --Debug.LogError("LoginMapLogicSystem:SetState::" .. tostring(self.CurrentState) .. ";;;;;" .. tostring(state));
        self.CurrentState = state;    
        local _f = L_LoginStateFunc[self.CurrentState];
        if _f then
             _f(self,0);
        end
    end
end

function LoginMapLogicSystem:ClearChacheGo()    
    self.SceneRootGo = nil
    self.SelectRoleListSceneGo = nil
    self.LGSceneGo = nil
    self.LGEnterEffectGo = nil
    self.LGExitEffectAnim = nil
    self.LGExitEffectGo = nil
    self.LGCreatePlayerOKEffectGO = nil
end

function LoginMapLogicSystem:RefreshSceneNode()
    -- Always check if SceneRootGo is nil or destroyed before using it
    if self.SceneRootGo == nil or (self.SceneRootGo and UnityEngine.Object.Equals(self.SceneRootGo, nil)) then
        self.SceneRootGo = UnityUtils.FindSceneRoot("SceneRoot");    
    end
    
    if self.SceneRootGo then
        -- The background of choosing a character
        if self.SelectRoleListSceneGo == nil then
            self.SelectRoleListSceneGo = UIUtils.FindGo(self.SceneRootGo.transform,"[SelectBackScene]");    
        end
        
        -- Login background
        if self.LGSceneGo == nil then
            self.LGSceneGo = UIUtils.FindGo(self.SceneRootGo.transform,"[LoginBackScene]");    
        end

        -- Log in to enter the name effect
        if self.LGEnterEffectGo == nil then
            self.LGEnterEffectGo = UIUtils.FindGo(self.SceneRootGo.transform,"[LoginBackScene]/[Name_on]");    
        end
        
        -- Log in to leave the name animation
        if self.LGExitEffectAnim == nil then
            local _a = UIUtils.FindTrans(self.SceneRootGo.transform,"[LoginBackScene]/[Name_on]/Name/mingzi")
            if _a then
                self.LGExitEffectAnim = UIUtils.RequireAnimator(_a);    
                self.LGExitEffectAnim.enabled = false;
            end
        end

        -- Log in to leave the name effect object
        if self.LGExitEffectGo == nil  then
            self.LGExitEffectGo = UIUtils.FindGo(self.SceneRootGo.transform,"[LoginBackScene]/[Name_off]");    
        end

        -- Special effects object after creating a role
        if self.LGCreatePlayerOKEffectGO == nil then
            self.LGCreatePlayerOKEffectGO = UIUtils.FindGo(self.SceneRootGo.transform,"[PlayerRoot]/Enter");    
        end

    end
end
-- Clean up the processing status of scene nodes
function LoginMapLogicSystem:InitSceneNodeState()
   -- 1. Refresh nodes
   self:RefreshSceneNode()    
   -- 2. Login node activation
   if self.LGSceneGo then
       self.LGSceneGo:SetActive(true);
   end 

   -- 3. Hidden scenes for selecting people
   if self.SelectRoleListSceneGo then
       self.SelectRoleListSceneGo:SetActive(false);
   end  

   -- 4. Enter the effect to hide
   if self.LGEnterEffectGo then
       self.LGEnterEffectGo:SetActive(false);
   end

   -- 5. Leave the effect hidden
   if self.LGExitEffectAnim then
       self.LGExitEffectAnim.enabled = false;
   end

   -- 6. Leave the effect hidden
   if self.LGExitEffectGo then
       self.LGExitEffectGo:SetActive(false);
   end

   -- 7. The effect object is hidden after creating a role
   if self.LGCreatePlayerOKEffectGO then
    self.LGCreatePlayerOKEffectGO:SetActive(false);
end
end


function LoginMapLogicSystem:Update(deltaTime)
   local _f = L_LoginStateFunc[self.CurrentState];
   if _f then
        _f(self,deltaTime);
   end
 
end

L_LoginStateFunc = {    
    -- Getting into the game
    [LoginMapStateCode.LoginSceneFinished] = function (self,deltaTime)  
        self:ClearChacheGo();      
        self:InitSceneNodeState();
        self:SetState(LoginMapStateCode.Idle);
    end,
    -- The login form is ready
    [LoginMapStateCode.LoginFormReadyOk] = function (self,deltaTime)        
        -- 1. Delete the UIRoot left behind in the update process. Save the UIRoot to this stage before to avoid black screen
        local _updateRootUI = GameObject.Find("[UILauncherForm]");
        if (_updateRootUI ~= nil) then    
            GameObject.Destroy(_updateRootUI);
        end
        GameCenter.LoadingSystem:Close();
        self:InitSceneNodeState();        
        self:SetState(LoginMapStateCode.Idle);
    end, 

    -- SDK login successfully
    [LoginMapStateCode.SDKLoginEnd] = function (self,deltaTime)    
        self:SetState(LoginMapStateCode.Idle);
    end, 
    
    -- Login to the gateway server successfully
    [LoginMapStateCode.LoginAgentServerOK] = function (self,deltaTime)
        -- Hide login button, keep background
        self.LGEnterEffectWaitTime = 0;    
        if self.LGEnterEffectGo then
            self.LGEnterEffectGo:SetActive(true);
            self.LGEnterEffectWaitTime = 2;
        end
        self:SetState(LoginMapStateCode.WaitEnterEffectShow);
    end, 

     -- Wait for the effect playback to be completed
     [LoginMapStateCode.WaitEnterEffectShow] = function (self,deltaTime)
        -- Hide login button, keep background
        if self.LGEnterEffectWaitTime > 0 then
            self.LGEnterEffectWaitTime = self.LGEnterEffectWaitTime - deltaTime;       
       end
        if self.LGEnterEffectWaitTime <= 0 then
            self:SetState(LoginMapStateCode.StartEnterGamePanelOpen);
        end
    end, 

    -- Open the game panel
    [LoginMapStateCode.StartEnterGamePanelOpen] = function (self,deltaTime)
        -- Hide login button, keep background
        GameCenter.PushFixEvent(UIEventDefine.UILOGINFORM_ENTERGAME_OPEN);        
        self:SetState(LoginMapStateCode.Idle);
    end, 

    -- Log in to the game server successfully, leave the login page
    [LoginMapStateCode.LoginGameServerOK] = function (self,deltaTime)
        self:RefreshSceneNode()    
        if self.LGExitEffectAnim then
            self.LGExitEffectAnim.enabled = true;
        end
        self.LGExitEffectWaitTime = 0;
        if self.LGExitEffectGo then
            self.LGExitEffectGo:SetActive(true);
            self.LGExitEffectWaitTime = 2;
        end  
        GameCenter.PushFixEvent(UIEventDefine.UILOGINFORM_CLOSE);
        self:SetState(LoginMapStateCode.WaitLeaveEffectShow);
    end, 

    -- Wait for the display of the effect of leaving
    [LoginMapStateCode.WaitLeaveEffectShow] = function (self,deltaTime)
       if self.LGExitEffectWaitTime > 0 then
            self.LGExitEffectWaitTime = self.LGExitEffectWaitTime - deltaTime;
       end     
        if self.LGExitEffectWaitTime <= 0 then
            self:SetState(LoginMapStateCode.StartRoleListFormOpen);
        end       
    end, 

    -- Start opening the role list form
    [LoginMapStateCode.StartRoleListFormOpen] = function (self,deltaTime)
        self:SetState(LoginMapStateCode.Idle);
        if self.LGExitEffectGo then
            self.LGExitEffectGo:SetActive(false);          
        end  
        if self.LGExitEffectAnim then
            self.LGExitEffectAnim.enabled = false;
        end
        GameCenter.PushFixEvent(UIEventDefine.UICREATEPLAYERFORM_OPEN);        
    end, 


    -- The role list form is opened
    [LoginMapStateCode.RoleListFormOpened] = function (self,deltaTime)         
        self:SetState(LoginMapStateCode.Idle);
        self:RefreshSceneNode() 
        if self.LGSceneGo then
            self.LGSceneGo:SetActive(false);
        end         
        if self.SelectRoleListSceneGo then
            self.SelectRoleListSceneGo:SetActive(true);
        end
    end, 

    -- Open the select panel
    [LoginMapStateCode.SelectRolePanelOpened] = function (self,deltaTime)        
        self:SetState(LoginMapStateCode.Idle);
        self:RefreshSceneNode()    
        if self.LGSceneGo then
            self.LGSceneGo:SetActive(false);
        end       
        if self.SelectRoleListSceneGo then
            self.SelectRoleListSceneGo:SetActive(true);
        end
    end, 

    -- Create Role Panel Open
    [LoginMapStateCode.CreateRolePanelOpened] = function (self,deltaTime)     
        self:SetState(LoginMapStateCode.Idle);   
        self:RefreshSceneNode()     
        if self.LGSceneGo then
            self.LGSceneGo:SetActive(false);
        end       
        if self.SelectRoleListSceneGo then
            self.SelectRoleListSceneGo:SetActive(false);
        end        
    end, 

    -- Create role completion
    [LoginMapStateCode.CreatePlayerOK] = function (self,deltaTime)     
        self.LGCreatePlayerEffectWaitTime = 3.5;
        self.NeedCallLoadShow = false;
        if self.LGCreatePlayerOKEffectGO then
            self.LGCreatePlayerOKEffectGO:SetActive(true);
        end
        -- self:SetState(LoginMapStateCode.WaitCreateRoleLeavelEffect);

        -- [Gosu] Fix: Hidden Enter Effect
        Debug.Log("Hidden Enter Effect");
        self:SetState(LoginMapStateCode.CreateRoleChangeMap);
    end, 

    -- Wait for the creation of the role effect to complete
    [LoginMapStateCode.WaitCreateRoleLeavelEffect] = function (self,deltaTime)     
        if self.LGCreatePlayerEffectWaitTime > 0 then
            self.LGCreatePlayerEffectWaitTime = self.LGCreatePlayerEffectWaitTime - deltaTime;
        end     

        if self.LGCreatePlayerEffectWaitTime <= 0 then
            self:SetState(LoginMapStateCode.CreateRoleChangeMap);
        end  
    end, 

    -- Create a role to start switching scenes
    [LoginMapStateCode.CreateRoleChangeMap] = function (self,deltaTime)        
        self:SetState(LoginMapStateCode.Idle);
        if self.LGCreatePlayerOKEffectGO then
            self.LGCreatePlayerOKEffectGO:SetActive(false);
        end
        if self.NeedCallLoadShow then
            GameCenter.LoadingSystem:SetShowing(true);	    
        end  
        self.NeedCallLoadShow = false;      
    end,
}

return LoginMapLogicSystem
