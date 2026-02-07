------------------------------------------------
-- Author:
-- Date: 2021-02-25
-- File: ServerListSystem.lua
-- Module: ServerListSystem
-- Description: Information on the server list
------------------------------------------------
local LoginStatus = require("Logic.Login.LoginStatus");
local ServerUrlInfo = require("Logic.ServerList.ServerUrlInfo");
local ServerDataInfo = require("Logic.ServerList.ServerDataInfo");
local ServerGroupInfo = require("Logic.ServerList.ServerGroupInfo");
local ServerCharInfo = require("Logic.ServerList.ServerCharInfo");
local SDKCacheData = CS.Thousandto.CoreSDK.SDKCacheData;

local L_MAX_SHOW_SERVER_GROUP = 50;
local L_CN_RECENT_SERVER_KEY = "RecentServerKey";



local ServerListSystem = {

    -- Get a list of all servers remotely
    AllList = List:New();
    -- List of all gateways
    AllAgentList = List:New();
    -- List of servers you have logged in
    RecentLoginList = List:New(),
    -- Recommended server list
    RecommendList = List:New(),
    -- A list of servers where roles exist
    ExistRoleList = List:New(),
    -- Get a list of maintained servers
    MaintenanceList = List:New(),
    -- Log in to the server
    LoginServer = nil,
    -- The last logged in to the server
    LastEnterServer = nil,
    -- Server grouping
    GroupedList = List:New(),

    -- Server manually selected by the player
    ChooseGameServerID = -1,
    -- Server list download tag:-1: No download, 0: Start download, >0: Successfully downloaded a list
    DownloadFlag = -1,

    -- Server download address information
    ServerUrlInfo = nil,

    -- The callback handle after downloading the game server list
    --OnGsServerDownloadFinishHandler = nil,      
    -- The login server list downloaded callback handle
    --OnLsServerDownloadFinishHandler = nil,

    -- The callback handle after the server list is downloaded
    OnServerDownloadFinishHandler = nil,  
    -- Server list download failed callback handle
    OnDownloadFailHandler = nil,
}

function ServerListSystem:Initialize(clearLoginData)
    Debug.Log("ServerListSystem:Initialize:" .. tostring(clearLoginData));
    -- Re-associate events, because all registered events will be cleaned up in a cycle of reincarnation.
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_SDK_LOGIN_SUCCESS,self.DownloadServerList,self);
    if clearLoginData then        
        self.ServerUrlInfo = ServerUrlInfo:New();
        --self.OnGsServerDownloadFinishHandler = Utils.Handler(self.OnGsServerDownloadFinish,self,nil,true);
        --self.OnLsServerDownloadFinishHandler = Utils.Handler(self.OnLsServerDownloadFinish,self,nil,true);
        self.OnServerDownloadFinishHandler = Utils.Handler(self.OnServerDownloadFinish,self,nil,true);
        self.OnDownloadFailHandler = Utils.Handler(self.OnDownloadFail,self,nil,true);
    end
end

function ServerListSystem:UnInitialize(clearLoginData)
    Debug.Log("ServerListSystem:UnInitialize:" .. tostring(clearLoginData));
    -- Re-associate events, because all registered events will be cleaned up in a cycle of reincarnation.
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_SDK_LOGIN_SUCCESS,self.DownloadServerList,self);
    if clearLoginData then
        self.ServerUrlInfo = nil;
        self.OnGsServerDownloadFinishHandler = nil;
        self.OnLsServerDownloadFinishHandler = nil;
        self.OnServerDownloadFinishHandler = nil;
        self.OnDownloadFailHandler = nil;  
    end
end


-- Clean up all server lists
function ServerListSystem:Clear()
    self.AllList:Clear();
    self.AllAgentList:Clear();
    self.RecentLoginList:Clear();
    self.RecommendList:Clear();
    self.ExistRoleList:Clear();
    self.GroupedList:Clear();
    self.LastEnterServer = nil;
    self.LoginServer = nil;
end


function ServerListSystem:GetLoginServer()
    if not self.LoginServer then
        if self.AllAgentList and self.AllAgentList:Count() > 0 then
            math.randomseed(os.time());
            local _idx = math.random(1,self.AllAgentList:Count());
            self.LoginServer = self.AllAgentList[_idx];
        else
            Debug.LogError("The current gateway server list is empty!!");
        end
    end
    return self.LoginServer;
end

-- Download the server list
function ServerListSystem:DownloadServerList()
    if self.DownloadFlag >= 0 then
       return; 
    end
    self.DownloadFlag = 0;
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN, DataConfig.DataMessageString.Get("C_XIAOTIAN_TIPS3"));
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LOGIN_STATUS, LoginStatus.CallServerlist);
    --LuaCoroutineUtils.WebRequestText(self.ServerUrlInfo:GetServerListURL(), self.OnGsServerDownloadFinishHandler, self.OnDownloadFailHandler, nil);
    --LuaCoroutineUtils.WebRequestText(self.ServerUrlInfo:GetLoginServerURL(), self.OnLsServerDownloadFinishHandler, self.OnDownloadFailHandler, nil);
    
    -- LuaCoroutineUtils.WebRequestText(self.ServerUrlInfo:GetServerListNewURL(), self.OnServerDownloadFinishHandler, self.OnDownloadFailHandler, nil);
    if LOCAL_SVR_LIST then
        self:OnServerDownloadFinish("{  \"data\": {\"lg_server\": [{\"svr_host\": \"s33.oneteam.vn\",\"svr_port\": 9200,\"svr_name\": \"login\"}],\"servers\": [{\"svr_id\": 1003,\"svr_host\": \"s33.oneteam.vn\",\"svr_port\": 9103,\"register_num\": 0,\"svr_sort\": 1,\"svr_label\": \"3\",\"group_type\": 4,\"svr_status\": 1,\"svr_name\": \"DEV (Vie)\"},{\"svr_id\": 1001,\"svr_host\": \"s39.oneteam.vn\",\"svr_port\": 9101,\"register_num\": 0,\"svr_sort\": 1,\"svr_label\": \"2,3\",\"group_type\": 4,\"svr_status\": 1,\"svr_name\": \"DUO (Vie)\"},{\"svr_id\": 1004,\"svr_host\": \"127.0.0.1\",\"svr_port\": 9102,\"register_num\": 0,\"svr_sort\": 2,\"svr_label\": \"0,1,2\",\"group_type\": 5,\"svr_status\": 1,\"svr_name\": \"D100 (Local)\"},{\"svr_id\": 2001,\"svr_host\": \"103.9.205.71\",\"svr_port\": 9102,\"register_num\": 0,\"svr_sort\": 2,\"svr_label\": \"0,1,2\",\"group_type\": 5,\"svr_status\": 1,\"svr_name\": \"D100 (KCP)\"}]  }}");
    else
        LuaCoroutineUtils.WebRequestText(self.ServerUrlInfo:GetServerListNewURL(), self.OnServerDownloadFinishHandler, self.OnDownloadFailHandler, nil); 
    end
end

-- The server download has been completed
function ServerListSystem:OnServerDownloadFinish(wwwText)
    -- Download the data of the recharge list
    --GameCenter.PaySystem:DownLoadPayList();
    -- Close MessageBox
    GameCenter.MsgPromptSystem:CloseMsgBox();
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_UPDATE_RECORDER_STEP, { CS.Thousandto.Update.Recorder.StepType.RequestServerList, 0, "Success" });    
  
    -- If www is not empty, it means downloaded through the url.
    if wwwText ~= nil and wwwText ~= "" then      
        self:Clear();        
        self.AllList,self.AllAgentList = ServerDataInfo:ParseServersJsonNew(wwwText);
        if self.AllAgentList and self.AllList and self.AllAgentList:Count() > 0 then
            self.LoginServer = nil;
            Debug.LogError("Game server list downloaded!downloadFlag = " ..  self.DownloadFlag .. ";;Number of server lists:" ..  self.AllList:Count());        
            -- GameCenter.LoginSystem:ConnectLoginServer();  
            GameCenter.LoginSystem:OnConnectLoginServerCallBack(true);
        else
            Debug.LogError("The current server list is empty,wwwText:" .. tostring(wwwText));
        end
        self.DownloadFlag = -1;
    else    
        Debug.LogError("Error downloading game server list!downloadFlag = " .. self.DownloadFlag);
        self.DownloadFlag = -1;
        Utils.ShowMsgBoxAndBtn(nil,"C_MSGBOX_OK","C_LOGIN_DOWNLOAD_SERVER_LIST_FAIL");
    end
end


-- Download failed
function ServerListSystem:OnDownloadFail(errCode, error)
    if (errCode <= 0 ) then
       -- Download failed, completely failed, exit
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_UPDATE_RECORDER_STEP,  { CS.Thousandto.Update.Recorder.StepType.RequestServerList, 1, error });
        GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
        self.DownloadFlag = -1;
        -- Close MessageBox
        Utils.ShowMsgBox(function (x)
            if (x == MsgBoxResultCode.Button2) then
                self:DownloadServerList();            
            else            
                GameCenter.SDKSystem:ExitGame();
            end
        end,"C_GETSERVERLIST_ERROR");        
    else
        -- Download failed, trying again
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_UPDATE_RECORDER_STEP,  { CS.Thousandto.Update.Recorder.StepType.RequestServerList, 2, error });                
    end
end

-- Processing server list
--List<MSG_Login.serverNumInfo> serNumInfos,List<int> existRoleIDs,int lastEnterID,List<MSG_Login.serverChangeName> changeNameList = null)
function ServerListSystem:ProcessServerList(serNumInfos,existRoleIDs,lastEnterID,changeNameList)

    -- Here is annotated to eliminate the server whitelist. Now the server list is directly filtered through the user ID parameters.
    -- 1. If there is a name change, replace the server name first.
    self:UpdateServerNames(changeNameList);

    -- 2. Add other data of the server to the server list data
    self:UpdateServerNums(serNumInfos);

    -- 3. Handle servers with roles
    self:UpdateExistRoleServer(existRoleIDs);

    -- 4. Process the recommended server
    self:ProcessRecommendServer();

    -- 5. Handle the last login server
    self:ProcessLastEnterServer(lastEnterID);

    -- 6. Process the list of recently logged in servers
    self:ProcessRecentServer();

    -- 7. Process server grouping
    self:ProcessGroupedServerList(L_MAX_SHOW_SERVER_GROUP);

    -- 8. Processing the maintenance list of servers
    self:ProcessMaintenanceServerList();

    -- 9. Process the default current server
    local _defaultCurSer = self:GetCurrentServer();
    if _defaultCurSer then
        SDKCacheData.ServerID = tostring(_defaultCurSer.ServerId);
    end
end

-- Update server name
function ServerListSystem:GS2U_ResChangeServerNameSuccess(serverId,changeName)

    local _cs = self:FindServer(serverId)
    if _cs then
        _cs.Name = changeName;
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SERVER_CHANGNAME_SUCCESS );
    end   
end


-- Find server information through server ID,
-- Dear friends, please note that there are many cases that cannot be found here.
function ServerListSystem:FindServer(id)
    return self.AllList:Find(function(a)
        return a.ServerId == id;
    end);
end

-- Update the server name
function ServerListSystem:UpdateServerNames(changeNameList)
    if changeNameList then
        for i = 1, changeNameList:Count() do
            local info = self:FindServer(changeNameList[i].serverId)
            if info then
                info.Name = changeNameList[i].changeName;
            end
        end      
    end
end

-- Populate other data of the server
function ServerListSystem:UpdateServerNums(serNumInfos)
    if serNumInfos then
        for _, _si in ipairs(serNumInfos) do            
            local _info = self:FindServer(_si.serverId)
            if _info then              
                for i, value in ipairs(_si.roles) do
                    local _sci = ServerCharInfo:New();
                    _info.CharacterList:Add(_sci);
                    _sci.ID = value.roleId;
                    _sci.ServerId = _si.serverId;
                    _sci.Career = value.career;
                    _sci.Level = value.lv;
                    _sci.Name = value.name;
                    _sci.PowerValue = value.fight;
                end
            end
        end    
    end
end


-- Processing servers with roles
function ServerListSystem:UpdateExistRoleServer(existRoleIDs)
    self.ExistRoleList:Clear();
    if existRoleIDs then        
        for _, _sid in ipairs(existRoleIDs) do
            local _info = self:FindServer(_sid);
            if _info then
                _info.HasRole = true;   
                self.ExistRoleList:Add(_info);
            end
        end
    end
     -- All recommended servers need to be sorted
    self.ExistRoleList:Sort(function (x,y)        
        return x.ShowOrder > y.ShowOrder;
    end);
end

-- Get the recommended server, if not, return to the latest 10 servers
function ServerListSystem:ProcessRecommendServer()
    self.RecommendList:Clear();
    local _tmp = List:New();
    for index, value in ipairs(self.AllList) do
        local _item = value;
        if _item  and _item.IsRecommendServer then
            self.RecommendList:Add(_item);
        end
        if index <= 10 then            
            _tmp:Add(_item);
        end

    end
    -- If there is no recommended server, the latest 10 servers will be displayed by default
    if self.RecommendList:Count() == 0 then
        self.RecommendList:AddRange(_tmp);
    end
    
    -- All recommended servers need to be sorted
    self.RecommendList:Sort(function (x,y) 
        if x.PlayerNum == y.PlayerNum then
            return x.ShowOrder > y.ShowOrder;
        else
            return x.PlayerNum < y.PlayerNum;    
        end
    end);
end

                                              


-- Processing the last login server
function ServerListSystem:ProcessLastEnterServer(lastEnterID)  
    self.LastEnterServer = self:FindServer(lastEnterID);
    if (self.LastEnterServer == nil and self.RecommendList:Count() > 0) then
        self.LastEnterServer = self.RecommendList[1];
    end
    if (self.LastEnterServer == nil and self.AllList:Count() > 0) then
        self.LastEnterServer = self.AllList[1];
    end
end


-- Add the nearest server to the local
function ServerListSystem:AddRecentServer(ID)    


    -- local _jsonStr = PlayerPrefs.GetString(L_CN_RECENT_SERVER_KEY, "{\"data\":[]}"); -- old code
    local GOSU_KEY_RECENT = GosuSDK.GetRecentServerKey(GosuSDK.Events.GOSU_L_CN_RECENT_SERVER_KEY)
    local _jsonStr = PlayerPrefs.GetString(GOSU_KEY_RECENT, "{\"data\":[]}");

    local _tab = Json.decode(_jsonStr);
    for index, value in ipairs(_tab.data) do
        if value == ID then
            table.remove(_tab.data,index);
            break;
        end
    end
    table.insert(_tab.data,1,ID); 
    _jsonStr = Json.encode(_tab);
    PlayerPrefs.SetString(GOSU_KEY_RECENT, _jsonStr);
    -- PlayerPrefs.SetString(L_CN_RECENT_SERVER_KEY, _jsonStr);
    PlayerPrefs.Save();
end

-- Get the list of recently logged in server IDs
function ServerListSystem:GetRecentServerIDList()
    -- local _jsonStr = PlayerPrefs.GetString(L_CN_RECENT_SERVER_KEY, "{\"data\":[]}");  -- old code
    local GOSU_KEY_RECENT = GosuSDK.GetRecentServerKey(GosuSDK.Events.GOSU_L_CN_RECENT_SERVER_KEY)
    local _jsonStr = PlayerPrefs.GetString(GOSU_KEY_RECENT, "{\"data\":[]}"); 

    -- print("-----------------------------------------------------------------------------")
    -- print(Inspect(_jsonStr))

    local _tab = Json.decode(_jsonStr);
    return List:New(_tab.data);
end

-- Handle the most recently logged-in server
function ServerListSystem:ProcessRecentServer()
    self.RecentLoginList:Clear();           
    local _ids = self:GetRecentServerIDList();
    for _, value in ipairs(_ids) do
        local _item = self:FindServer(value);
        if _item then
            _item.HasRole = true;
            self.RecentLoginList:Add(_item);
        end
    end
   
end
       

-- The grouped list is group counted as one group
function ServerListSystem:ProcessGroupedServerList(groupCount)

    self.GroupedList:Clear();
    
    -- Test server grouptype = 0
    local _testList = List:New();
    -- Pioneer server group type = 1
    local _tryList = List:New();
    -- Formal server group type = 2
    local _noSortList = List:New();
    local _sortList = List:New();
    for _, value in ipairs(self.AllList) do
        --value.GroupType = math.random(0,3)
        if value.GroupType == 0 then
            _testList:Add(value)
        elseif value.GroupType == 1 then
            _tryList:Add(value)
        else
            if value.ShowOrder <= 0 then
                _noSortList:Add(value);
            else
               _sortList:Add(value);     
            end        
        end        
    end    
    -- Set up disordered set bits
    if _testList:Count() > 0 then
        self.GroupedList:Add(ServerGroupInfo:New(0,0,_testList,DataConfig.DataMessageString.Get("C_TEST_SERVER_AREA")));    
    end
    
    if _tryList:Count() > 0 then
        self.GroupedList:Add(ServerGroupInfo:New(0,0,_tryList,DataConfig.DataMessageString.Get("C_DNF_SERVER_AREA")));    
    end
    
    if _noSortList:Count() > 0 then
        self.GroupedList:Add(ServerGroupInfo:New(0,0,_noSortList,DataConfig.DataMessageString.Get("C_INVALID_SERVER_AREA")));    
    end
    
    -- Sort
    _sortList:Sort(function (x,y)
        return x.ShowOrder < y.ShowOrder;
    end)

    while _sortList:Count() > 0 do
        local _gi = ServerGroupInfo:Create(_sortList,_sortList[1].ShowOrder,_sortList[1].ShowOrder + groupCount - 1);
        if _gi then
            self.GroupedList:Add(_gi);
        end
    end   
    self.GroupedList:Sort(function (x,y)
        if ( x.EndID == y.EndID) then
            return false;
        elseif(x.EndID == 0)then
            return true;
        elseif(y.EndID == 0)then
            return false;
        else
            return x.EndID > y.EndID;     
        end        
    end) 
end


-- Process maintenance server list
function ServerListSystem:ProcessMaintenanceServerList()
    self.MaintenanceList:Clear();
    for _, value in ipairs(self.AllList) do
        self.MaintenanceList:Add(value);
    end
end

-- Set up the last entry server
function ServerListSystem:SetLastEnterServer(gs)
    if gs == nil then return; end
    self:AddRecentServer(gs.ServerId);
    self.LastEnterServer = gs;
end

-- Obtain the current server
function ServerListSystem:GetCurrentServer()
    local _result = nil;
    
    -- If the currently selected game server ID is greater than 0
    if (self.ChooseGameServerID >= 0) then    
        _result = self:FindServer(self.ChooseGameServerID);
    end

    -- Select the server to which the server was last logged in
    if (_result == nil and self.LastEnterServer) then
        _result = self.LastEnterServer;
    end    

    -- Select the last logged-in local server
    if _result == nil and self.RecentLoginList:Count() > 0 then
        _result = self.RecentLoginList[1];
    end

    -- If all are still empty, take the first server with the list containing the roles
    if (_result == nil and self.ExistRoleList:Count() > 0) then
        _result = self.ExistRoleList[1];      
    end
    
    -- If all are still empty, take the first server in the recommendation list
    if (_result == nil and self.RecommendList:Count() > 0) then
        _result = self.RecommendList[1];      
    end

    -- If all are still empty, take the first server in the full list
    if (_result == nil and self.AllList:Count() > 0) then
        _result = self.AllList[1];      
    end

    -- If it's still empty, just report an error
    if (_result == nil) then
        Debug.LogError("GetCurrentServer: Get the current server is empty!");
    end
    return _result;
end

--[[

-- -Parse x8 server list--Abandoned-2021-08-06.
-- The game server list download callback
function ServerListSystem:OnGsServerDownloadFinish(wwwText)
    -- Download the data of the recharge list
    GameCenter.PaySystem:DownLoadPayList();
    -- Close MessageBox
    GameCenter.MsgPromptSystem:CloseMsgBox();
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_UPDATE_RECORDER_STEP, { CS.Thousandto.Update.Recorder.StepType.RequestServerList, 0, "Success" });    
  
    -- If www is not empty, it means downloaded through the url.
    if wwwText ~= nil and wwwText ~= "" then      
        self:Clear();        
        self.AllList = ServerDataInfo:ParseGameServerListJson(wwwText);
        Debug.Log("The game server list has been downloaded!downloadFlag =" ..  self.DownloadFlag .. ";;Number of server list:" ..  self.AllList:Count());
        self.DownloadFlag = self.DownloadFlag | 2;
        if ((self.DownloadFlag & 3) == 3) then
            GameCenter.LoginSystem:ConnectLoginServer();
            self.DownloadFlag = -1;
        end
    else    
        Debug.LogError("DownloadFlag =" .. self.DownloadFlag);
        self.DownloadFlag = -1;
        Utils.ShowMsgBoxAndBtn(nil,"C_MSGBOX_OK","C_LOGIN_DOWNLOAD_SERVER_LIST_FAIL");
    end
end

-- Download the login server list and complete -- callback
function ServerListSystem:OnLsServerDownloadFinish(wwwText)    
    -- Close MessageBox
    GameCenter.MsgPromptSystem:CloseMsgBox();
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_UPDATE_RECORDER_STEP, { CS.Thousandto.Update.Recorder.StepType.RequestServerList, 0, "Success" });    
     
    -- If www is not empty, it means downloaded through the url.
    if wwwText ~= nil and wwwText ~= "" then 
        self.LoginServer = null;
        -- Remove wildcards
        --wwwText = Utils.ReplaceString(wwwText, "\"", "");
        --wwwText = Utils.ReplaceString(wwwText, "\\", "");             
        self.LoginServer = ServerDataInfo:ParserLoginServerListJson(wwwText, SDKCacheData.ChannelID);
        Debug.Log("The login server list has been downloaded!downloadFlag =" .. self.DownloadFlag);
        self.DownloadFlag = self.DownloadFlag | 1;
        if ((self.DownloadFlag & 3) == 3) then
            GameCenter.LoginSystem:ConnectLoginServer();
            self.DownloadFlag = -1;
        end
    else    
        Debug.LogError("Download login server list error!downloadFlag =" .. self.DownloadFlag);
        self.DownloadFlag = -1;
        Utils.ShowMsgBoxAndBtn(nil,"C_MSGBOX_OK","C_LOGIN_DOWNLOAD_SERVER_LIST_FAIL");
    end
end


]]
return ServerListSystem;