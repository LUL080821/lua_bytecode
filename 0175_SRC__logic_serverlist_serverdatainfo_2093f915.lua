------------------------------------------------
-- Author:
-- Date: 2021-02-25
-- File: ServerDataInfo.lua
-- Module: ServerDataInfo
-- Description: Information about server data
------------------------------------------------

local L_INT_MAX = 2147483648

local ServerDataInfo = {
    -- Server ID
    ServerId = 0,
    -- Real server ID. If there is a server combination, it means that the current server logs into the real server ID.
    ReallyServerId = 0,
    -- The server ID displayed,
    ShowServerId = 0,
    -- Service name
    Name = "",
    -- Grouping Type
    GroupType = 0,
    -- Payment callback
    PayCallURL = "",
    -- The sequence number of the server, used for sorting
    ShowOrder = 0,
    -- The IP address of the server
    Ip = "",
    -- Server Port
    Port = 0,
    -- Current server tags
    Labels = List:New(),
    -- Current server status
    Status = 0,
    -- The number of players on the current server
    PlayerNum = L_INT_MAX,
    -- List of current server roles
    CharacterList = List:New(),
    -- Is there any player's role in the current server
    HasRole = false,
    -- Whether to log in to the server
    IsLoginServer = false,
    -- hide
    IsHideServer = false,
    -- Maintenance status
    IsMaintainServer = false,
    -- Is it a new server
    IsNewServer = false,
    -- Is the current server full?
    IsFullServer = false,
    -- Is it recommended to the server
    IsRecommendServer = false,
}

function ServerDataInfo:New()
    local _m = Utils.DeepCopy(self);
    return _m;
end



-- Parse the game server json
-- {"data":{"servers":[{"group_type":1,"svr_host":"127.0.0.1","svr_id":"20017","svr_idx":"20017","svr_label":"3","svr_name":"local server","svr_pay_callback":"xxx","svr_port":8587,"svr_sort":3,"svr_status":1}]},"state":1}
function ServerDataInfo:ParseGameServerListJson(jsonStr)
    Debug.Log("Server list string:" ..  jsonStr);
    local _result = List:New();
    local _jsonTable = Json.decode(jsonStr);
    if _jsonTable and  _jsonTable.data then
        local _serArray = _jsonTable.data.servers;
        if _serArray and #_serArray > 0 then
            for _, value in ipairs(_serArray) do     
                if value then
                    _result:Add(ServerDataInfo:New():ParseGameServerNode(value))
                end
            end
        else
            Debug.LogError("Game server is empty!" .. tostring(jsonStr));
        end
    else
        Debug.LogError("The obtained game server Json string has no data:" .. tostring(jsonStr));
    end
    -- Sort by ShowOder -- Sort from small to large
    _result:Sort(function(a,b) return a.ShowOrder < b.ShowOrder  end );
    return _result;
end

-- Parse the Json string of the server list
-- {"data":{"lg_server":[{"svr_host":"10.0.0.59","svr_name":"Intranet login server","svr_port":8888}],"servers":[{"svr_sort":0,"svr_host":"10.0.0.60","svr_name":"Client test server","svr_id":20016,"group_type":1,"svr_label":"0","svr_status":1,"svr_port":8586}]}}
function ServerDataInfo:ParseServersJsonNew(jsonStr)
    Debug.Log("Server list string:" ..  jsonStr);
    -- jsonStr = {"data":{"lg_server":[{"svr_host":"222.255.168.248","svr_name":"login","svr_port":9101}],"servers":[{"svr_sort":0,"svr_host":"222.255.168.248","svr_name":"test","svr_id":20016,"group_type":1,"svr_label":"0","svr_status":1,"svr_port":9101}]}}
    -- Debug.Log("Server list string:" ..  jsonStr);
    local _serverList;
    local _lgServer;
    local _jsonTable = Json.decode(jsonStr);
    if _jsonTable and  _jsonTable.data then
        _serverList = ServerDataInfo:ParseGameServerListNode(_jsonTable.data.servers);
        _lgServer = ServerDataInfo:New():ParseAgentServerListNode(_jsonTable.data.lg_server)
    else
        Debug.LogError("The obtained game server Json string has no data:" .. tostring(jsonStr));
    end   
    return _serverList,_lgServer;
end

-- Resolve the list node of the gateway server
-- lg_server":[{"svr_host":"10.0.0.59","svr_name":"Intranet login server","svr_port":8888},{"svr_host":"10.0.0.66","svr_name":"Intranet login server 2","svr_port":8888}]
function ServerDataInfo:ParseAgentServerListNode(servers)
    local _result = List:New();
    local _serArray = servers;
    if _serArray and next(_serArray) then
        if type(_serArray[1]) == "table" then
            for _, value in ipairs(_serArray) do     
                if value then
                    _result:Add(ServerDataInfo:New():ParseAgentServerNode(value))
                end
            end
        else
            _result:Add(ServerDataInfo:New():ParseAgentServerNode(_serArray)) 
        end
    else
        Debug.LogError("The gateway server list is empty!");
    end
    return _result;
end

-- Resolve the node of the gateway server
-- lg_server":{"svr_host":"10.0.0.59","svr_name":"Intranet login server","svr_port":8888}
function ServerDataInfo:ParseAgentServerNode(node)
    if node then
         -- Initialize some variables
        self.IsLoginServer = true;    
        self.ServerId = 0;    
        self.GroupType = 0;
        self.PlayerNum = 0;
        self.ShowOrder = 0;    
        self.Status = 0;
        self.Labels = List:New();    
        self.ReallyServerId = 0;
        self.ShowServerId = 0;    
        self.IsHideServer = false;
        self.IsMaintainServer = false;
        self.IsNewServer = false;
        self.IsFullServer = false;
        self.IsRecommendServer = false;
        -- Start populating data from nodes
        self.Name = node.svr_name;
        math.randomseed(os.time());
        if type(node.svr_host) == "table" then
            self.Ip = node.svr_host[math.random(1,_arr:Count())];    
        else
            self.Ip = node.svr_host;
        end
        
        if type(node.svr_port) == "table" then
            self.Port = tonumber(node.svr_port[math.random(1,_arr:Count())]);    
        else
            self.Port = tonumber(node.svr_port);   
        end
    else
        Debug.LogError("The login server is empty!");
    end
    return self;
end

-- Parse the array list of game servers
-- servers":[{"group_type":1,"svr_host":"127.0.0.1","svr_id":"20017","svr_idx":"20017","svr_label":"3","svr_name":"local server","svr_pay_callback":"xxx","svr_port":8587,"svr_sort":3,"svr_status":1}]}
function ServerDataInfo:ParseGameServerListNode(servers)
    local _result = List:New();
    local _serArray = servers;
    if _serArray and next(_serArray) then
        if type(_serArray[1]) == "table" then
            for _, value in ipairs(_serArray) do     
                if value then
                    _result:Add(ServerDataInfo:New():ParseGameServerNode(value))
                end
            end
        else
            _result:Add(ServerDataInfo:New():ParseGameServerNode(_serArray)) 
        end
    else
        Debug.LogError("The game server is empty!");
    end
    -- Sort by ShowOder -- Sort from small to large
    _result:Sort(function(a,b) return a.ShowOrder < b.ShowOrder  end );
    return _result;
end


-- Parse a game server node
-- {"group_type":1,"svr_host":"127.0.0.1","svr_id":"20017","svr_idx":"20017","svr_label":"3","svr_name":"local server","svr_pay_callback":"xxx","svr_port":8587,"svr_sort":3,"svr_status":1}
function ServerDataInfo:ParseGameServerNode(node)    
    self.ServerId = tonumber(node.svr_id);    
    self.GroupType = tonumber(node.group_type);
    self.ShowOrder = tonumber(node.svr_sort);
    self.Name = UIUtils.StripLanSymbol(node.svr_name,FLanguage.Default);
    self.PayCallURL = node.svr_pay_callback;
    self.PlayerNum = tonumber(node.register_num);
    self.Status = tonumber(node.svr_status);
    if node.svr_label then
        self.Labels = Utils.SplitNumber(node.svr_label,",");
    else
        self.Labels = List:New();
    end 
    self.Ip = node.svr_host;
    self.Port = tonumber(node.svr_port);    
    self.ReallyServerId = self.ServerId;
    self.ShowServerId = self.ShowOrder;
    self.IsLoginServer = false;
    self.IsHideServer = (self.Status == 0);
    self.IsMaintainServer = (self.Status == 2);
    self.IsNewServer = (self.Labels:IndexOf(3) > 0);
    self.IsFullServer = (self.Labels:IndexOf(1) > 0);
    self.IsRecommendServer = (self.Labels:IndexOf(2) > 0);
    return self;
end

--[[
-- Resolve login server
-- {data:{extParams:{svr_private_chids:73|74,svr_port:8888,svr_host:10.0.0.59|212.64.100.197,svr_name:gateway server}},state:1}
function ServerDataInfo:ParserLoginServerListJson(jsonStr,chnId)   
    Debug.Log("Login server string:" ..  jsonStr .. ";aisle:" .. tostring(chnId)); 
    local _jsonTable = Json.decode(jsonStr);
    if _jsonTable and  _jsonTable.data then
        local _extParams = _jsonTable.data.extParams;
        if _extParams then
            return ServerDataInfo:New():ParseLoginServerNode(_extParams,chnId);
        else
            Debug.LogError("The login server is empty!" .. tostring(jsonStr));
        end
    else
        Debug.LogError("The obtained login server Json string has no data:" .. tostring(jsonStr));
    end    
    return nil;
end

-- Resolve a node that logs into the server server
-- {svr_private_chids:73|74,svr_port:8888,svr_host:10.0.0.59|212.64.100.197,svr_name:gateway server}
function ServerDataInfo:ParseLoginServerNode(node,chnId)

    -- Initialize some variables
    self.IsLoginServer = true;    
    self.ServerId = 0;    
    self.GroupType = 0;
    self.ShowOrder = 0;    
    self.Status = 0;
    self.Labels = List:New();    
    self.ReallyServerId = 0;
    self.ShowServerId = 0;    
    self.IsHideServer = false;
    self.IsMaintainServer = false;
    self.IsNewServer = false;
    self.IsFullServer = false;
    self.IsRecommendServer = false;

    -- Start populating data from nodes
    self.Name = node.svr_name;
    self.Port = tonumber(node.svr_port);    
    -- IP address list
    local _ips = Utils.SplitStr(node.svr_host,'|');
    -- Private channel list
    local _chns = Utils.SplitStr(node.svr_private_chids,'|');
    -- In the list of private channels
    local _findIdx = nil;
    if chnId then
        _findIdx = _chns:IndexOf(chnId);
    else
        _findIdx = 1;
    end
    if _findIdx == nil or _findIdx <= 0 or _findIdx > _ips:Count() then
        _findIdx = _ips:Count();
    end
    self.Ip = _ips[_findIdx];
    return self;
end
]]

return ServerDataInfo;