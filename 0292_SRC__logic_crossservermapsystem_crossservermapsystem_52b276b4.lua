local CrossServerMapSystem = {
    -- All servers
    AllServer = nil,
    -- Cross-Server Event Information
    MsgCrossServerMapInfoList = List:New(),
    -- My server information
    MyServerID = nil,
    MsgMyCrossServer = nil,
    -- The group where the local player server is located is the key group and the value is the bool
    MyCrossServerGroup = {},
    -- Cross-server world level open state
    BaseWorldLvOpenDic = nil,
    -- Open status of cross-server opening time
    BaseOpenTimeOpenDic = nil,
    -- Event world level open status
    ActivityWorldLvOpenDic = nil,
    -- Cross-service classification by group
    CrossServerGroupDic = Dictionary:New()
}

function CrossServerMapSystem:Initialize()
   
end

function CrossServerMapSystem:UnInitialize()
    self.AllServer = nil
    self.MsgCrossServerMapInfoList:Clear();
    self.MyServerID = nil
    self.MsgMyCrossServer = nil
    self.MyCrossServerGroup = {}
    self.BaseWorldLvOpenDic = nil
    self.BaseOpenTimeOpenDic = nil
    self.ActivityWorldLvOpenDic = nil
    self.CrossServerGroupDic:Clear();
end

-- Game server Request public server Server grouping data
function CrossServerMapSystem:ReqCrossServerMatch()
    GameCenter.Network.Send("MSG_Dailyactive.ReqCrossServerMatch",{})
end

-- Cross-Server Event Map Data Update
function CrossServerMapSystem:GS2U_ResCrossServerMatch(msg)
    self:UnInitialize();
    local _myServerID = self:GetMyServerID();
    if msg then
        local _serverList = msg.serverMatch_8
        
        if _serverList then
            local _count = #_serverList
            for i=1, _count do
                local _server = _serverList[i];
                self.MsgCrossServerMapInfoList:Add(_server)
                if _server.serverid == _myServerID then
                    self.MyServerInBigMapIndex = math.floor((i-1)/8) + 1;
                    self.MsgMyCrossServer = _server;
                end
            end
        end
        self:SetWorldLvOpenState(32, 1);
        self:SetOpenTimeOpenState(32, 1)
        self:SetAllActivityWorldLvOpenState(32);
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_CROSSSERVER_REFRESH);
    end
end

-- Set level open status
function CrossServerMapSystem:SetWorldLvOpenState(crossServerGroupType, pos)
    local _list = self:GetCrossServer(crossServerGroupType, pos)
    local _baseWorldLv = self:GetBaseCrossWorldLv(crossServerGroupType);
    local _totalLv = 0;
    for i=1, #_list do
        _totalLv = _totalLv + _list[i].serverWroldLv;
    end
    local _isOpen = _totalLv/crossServerGroupType >= _baseWorldLv

    if not self.BaseWorldLvOpenDic then
        self.BaseWorldLvOpenDic = {};
    end
    if not self.BaseWorldLvOpenDic[crossServerGroupType] then
        self.BaseWorldLvOpenDic[crossServerGroupType] = {};
    end
    if self.BaseWorldLvOpenDic[crossServerGroupType][pos] then
        self.BaseWorldLvOpenDic[crossServerGroupType][pos].IsOpen = _isOpen;
        self.BaseWorldLvOpenDic[crossServerGroupType][pos].WorldLv = _totalLv/crossServerGroupType;
    else
        self.BaseWorldLvOpenDic[crossServerGroupType][pos] = {IsOpen = _isOpen, WorldLv = _totalLv/crossServerGroupType};
    end
    if crossServerGroupType / 2 >= 2 then
        self:SetWorldLvOpenState(crossServerGroupType/2, pos * 2 - 1)
        self:SetWorldLvOpenState(crossServerGroupType/2, pos * 2)
    end
end

-- Set the open status of the server opening time
function CrossServerMapSystem:SetOpenTimeOpenState(crossServerGroupType, pos)
    local _list = self:GetCrossServer(crossServerGroupType, pos)
    local _baseOpenDay = self:GetBaseCrossOpenTime(crossServerGroupType);
    local _minOpenDay = math.huge;
    for i=1, #_list do
        local _openTimeDay = Time.GetOpenSeverDayByOpenTime(_list[i].openTime * 0.001);
        _minOpenDay = _minOpenDay > _openTimeDay and _openTimeDay or _minOpenDay;
    end
    local _isOpen = _minOpenDay >= _baseOpenDay

    if not self.BaseOpenTimeOpenDic then
        self.BaseOpenTimeOpenDic = {};
    end
    if not self.BaseOpenTimeOpenDic[crossServerGroupType] then
        self.BaseOpenTimeOpenDic[crossServerGroupType] = {};
    end
    if self.BaseOpenTimeOpenDic[crossServerGroupType][pos] then
        self.BaseOpenTimeOpenDic[crossServerGroupType][pos].IsOpen = _isOpen;
        self.BaseOpenTimeOpenDic[crossServerGroupType][pos].MinOpenDay = _minOpenDay;
    else
        self.BaseOpenTimeOpenDic[crossServerGroupType][pos] = {IsOpen = _isOpen, MinOpenDay = _minOpenDay};
    end
    if crossServerGroupType / 2 >= 2 then
        self:SetOpenTimeOpenState(crossServerGroupType/2, pos * 2 - 1)
        self:SetOpenTimeOpenState(crossServerGroupType/2, pos * 2)
    end
end

-- Set the open status of the world level of the activity
function CrossServerMapSystem:SetActivityWorldLvOpenState(cfgItem)
    local _activityID = cfgItem.Id;
    local _t = Utils.SplitStrByTableS(cfgItem.CrossMatch);
    if not self.ActivityWorldLvOpenDic then
        self.ActivityWorldLvOpenDic = {};
    end

    local nilCrossServerGroupType = "";

    for i=1, #_t do
        local _crossServerGroupType = _t[i][1];
        -- Not to deal with 1 cross-server
        if _crossServerGroupType ~= 1 then
            local _needWorldLv = _t[i][2];
            if not self.ActivityWorldLvOpenDic[_crossServerGroupType] then
                self.ActivityWorldLvOpenDic[_crossServerGroupType] = {};
            end
            for j=1,32/_crossServerGroupType do
                local _allActivityDic = self.ActivityWorldLvOpenDic[_crossServerGroupType][j];
                if not _allActivityDic then
                    _allActivityDic = {}
                    self.ActivityWorldLvOpenDic[_crossServerGroupType][j] = _allActivityDic;
                end

                local _list = self:GetCrossServer(_crossServerGroupType, j);
                -- Is it open?
                local _isOpen = false;
                -- Progress World Level
                local _worldLv = 0;
                -- All reached
                if cfgItem.Crosstype == 0 then
                    local _minLv = math.huge;
                    for k=1, #_list do
                        _worldLv = _list[k].serverWroldLv;
                        _minLv = _worldLv < _minLv and _worldLv or _minLv;
                    end
                    _isOpen = _minLv >= _needWorldLv;
                    _worldLv = _minLv;
                -- Arrival by itself
                elseif cfgItem.Crosstype == 1 then
                    -- If it is a local player group, the progress will be displayed for the local player
                    if (self.MyCrossServerGroup[_crossServerGroupType] ~= nil) then
                        if self.MyCrossServerGroup[_crossServerGroupType][j] then
                            _worldLv = self.MsgMyCrossServer.serverWroldLv;
                            _isOpen = _worldLv >= _needWorldLv;
                        else
                            local _maxLv = 0;
                            for k=1, #_list do
                                _worldLv = _list[k].serverWroldLv;
                                _maxLv = _worldLv > _maxLv and _worldLv or _maxLv;
                            end
                            _isOpen = _maxLv >= _needWorldLv;
                            _worldLv = _maxLv;
                        end
                    else
                        nilCrossServerGroupType = nilCrossServerGroupType .. _crossServerGroupType .. " ";
                    end
                -- Average value arrives
                else
                    local _totalLv = 0;
                    for k=1, #_list do
                        _totalLv = _totalLv + _list[k].serverWroldLv;
                    end
                    local _averageLv = math.floor(_totalLv/_crossServerGroupType);
                    _isOpen = _averageLv >= _needWorldLv;
                    _worldLv = _averageLv;
                end
                if _allActivityDic[_activityID] then
                    _allActivityDic[_activityID].IsOpen = _isOpen;
                    _allActivityDic[_activityID].WorldLv = _worldLv;
                    _allActivityDic[_activityID].NeedWorldLv = _needWorldLv;
                    _allActivityDic[_activityID].Name = cfgItem.Name;
                else
                    _allActivityDic[_activityID] = {ID = _activityID,Name = cfgItem.Name, IsOpen = _isOpen, WorldLv = _worldLv, NeedWorldLv = _needWorldLv};
                end
            end
        end
    end

    if nilCrossServerGroupType  ~="" then
        Debug.LogError("CrossServerMapSystem MyCrossServerGroup _crossServerGroupTypes = " ..nilCrossServerGroupType .. " is null");
    end
end

-- Set open status of all active world level
function CrossServerMapSystem:SetAllActivityWorldLvOpenState(crossServerGroupType)
    local _func = function (k,v)
        if v.Ifcross == 1 then
            self:SetActivityWorldLvOpenState(v);
        end
    end
    DataConfig.DataDaily:Foreach(_func);
    if crossServerGroupType / 2 >= 2 then
        self:SetAllActivityWorldLvOpenState(crossServerGroupType/2)
    end
end

-- ===================[Large, Small Map]=======================
-- Is the members sufficient?
function CrossServerMapSystem:IsEnoughMember(crossServerGroupType, pos)
    return #self:GetCrossServer(crossServerGroupType, pos) >= crossServerGroupType
end

-- Whether it reaches the basic level
function CrossServerMapSystem:IsOpenByBaseWorldLv(crossServerGroupType, pos)
    if not self.BaseWorldLvOpenDic then
        self:SetWorldLvOpenState(32, 1);
    end
    return self.BaseWorldLvOpenDic[crossServerGroupType][pos].IsOpen;
end

-- Whether the basic service opening time is reached
function CrossServerMapSystem:IsOpenByBaseTimeOpen(crossServerGroupType, pos)
    if not self.BaseOpenTimeOpenDic then
        self:SetOpenTimeOpenState(32, 1);
    end
    return self.BaseOpenTimeOpenDic[crossServerGroupType][pos].IsOpen;
end

-- Get the current server ID
function CrossServerMapSystem:GetMyServerID()
    if not self.MyServerID then
        self.MyServerID = GameCenter.ServerListSystem:GetCurrentServer().ReallyServerId;
    end
    return self.MyServerID;
end

-- Get the server name
function CrossServerMapSystem:GetServerName(serverId)
    if not self.AllServer then
        self.AllServer = Dictionary:New();
        local _allList = GameCenter.ServerListSystem.AllList;        
        for _, _server in ipairs(_allList) do            
            local _serverId = _server.ServerId;
            self.AllServer:Add(_serverId, {name = _server.Name});
        end
    end
    return self.AllServer[serverId] and self.AllServer[serverId].name or DataConfig.DataMessageString.Get("NotFind");
end

-- Is it a group of local player servers?
function CrossServerMapSystem:IsLocalPlayerServerGroup(crossServerGroupType, pos)
    self:GetCrossServer(crossServerGroupType, pos);
    return not not(self.MyCrossServerGroup[crossServerGroupType][pos])
end

-- Is X cross-server open?
function CrossServerMapSystem:IsOpenMyCrossServer(crossServerGroupType)
    for i=1, 32/crossServerGroupType do
        if self:IsLocalPlayerServerGroup(crossServerGroupType, i) then
            return self:IsOpenByBaseWorldLv(crossServerGroupType, i) and self:IsOpenByBaseTimeOpen(crossServerGroupType, i),i
        end
    end
end

-- ===================[Single information for cross-server activities]======================
-- Get all crossServerGroupType in the configuration table: crossServerGroupType: crossServer grouping type, such as 8 crossServer
function CrossServerMapSystem:GetCfgDataByGroupType(crossServerGroupType)
    if not self.AllCrossServerCfgDataDic then
        self.AllCrossServerCfgDataDic = Dictionary:New();
        local _func = function (k,v)
            if v.Ifcross == 1 then
                local _t = Utils.SplitStrByTableS(v.CrossMatch)
                for j=1, #_t do
                    if not self.AllCrossServerCfgDataDic[_t[j][1]] then
                        self.AllCrossServerCfgDataDic[_t[j][1]] = List:New();
                    end
                    self.AllCrossServerCfgDataDic[_t[j][1]]:Add({Cfg = v, ID = v.Id, Name = v.Name, CrossType = v.CrossType, CrossLv = _t[j][2]});
                end
            end
        end
        DataConfig.DataDaily:Foreach(_func);
    end
    return self.AllCrossServerCfgDataDic[crossServerGroupType]
end

-- Get active status (whether it is turned on, progress) {Name = "", IsOpen = false, WorldLv = 100, NeedWorldLv = 200}
function CrossServerMapSystem:GetActivity(crossServerGroupType, pos, activityID)
    if not self.ActivityWorldLvOpenDic then
        self:SetAllActivityWorldLvOpenState(32);
    end
    return self.ActivityWorldLvOpenDic[crossServerGroupType][pos][activityID]
end

-- Get the basic server opening time of cross-server activities
function CrossServerMapSystem:GetBaseCrossOpenTime(crossServerGroupType)
    if not self.BaseCrossOpenTimeDic then
        self.BaseCrossOpenTimeDic = Dictionary:New();
        local _str = DataConfig.DataGlobal[GlobalName.Cross_Match_OpneTime].Params;
        local _t = Utils.SplitStrByTableS(_str);
        for i,v in ipairs(_t) do
            self.BaseCrossOpenTimeDic:Add(v[1],v[2]);
        end
    end
    return self.BaseCrossOpenTimeDic[crossServerGroupType] or 1
end

-- Minimum number of service days
function CrossServerMapSystem:GetMinOpenDay(crossServerGroupType, pos)
    if not self.BaseOpenTimeOpenDic then
        self:SetOpenTimeOpenState(32, 1);
    end
    return self.BaseOpenTimeOpenDic[crossServerGroupType][pos].MinOpenDay;
end

-- ===================[Server Progress]=========================
-- Obtain the basic world level of cross-server activities
function CrossServerMapSystem:GetBaseCrossWorldLv(crossServerGroupType)
    if not self.BaseCrossWorldLvDic then
        self.BaseCrossWorldLvDic = Dictionary:New();
        local _str = DataConfig.DataGlobal[GlobalName.Cross_Match_WroldLv].Params;
        local _t = Utils.SplitStrByTableS(_str);
        for i,v in ipairs(_t) do
            self.BaseCrossWorldLvDic:Add(v[1],v[2]);
        end
    end
    return self.BaseCrossWorldLvDic[crossServerGroupType] or 0
end

-- Obtain multi-cross server crossServerGroupType: cross-server group type, such as 8 cross-server, pos: location in this group
function CrossServerMapSystem:GetCrossServer(crossServerGroupType, pos)
    if not self.CrossServerGroupDic then
        self.CrossServerGroupDic = Dictionary:New();
    end
    if not self.CrossServerGroupDic[crossServerGroupType] then
        self.CrossServerGroupDic:Add(crossServerGroupType, Dictionary:New());
    end
    local _list = self.CrossServerGroupDic[crossServerGroupType][pos];
    if not _list then
        local _myServerID = self:GetMyServerID()
        _list = List:New()
        self.CrossServerGroupDic[crossServerGroupType]:Add(pos, _list)
        for i=crossServerGroupType-1, 0,-1 do
            local _MsgCrossServerMapInfo = self.MsgCrossServerMapInfoList[crossServerGroupType * pos -i];
            if _MsgCrossServerMapInfo then
                _list:Add(_MsgCrossServerMapInfo);
                if _MsgCrossServerMapInfo.serverid == _myServerID then
                    if not self.MyCrossServerGroup[crossServerGroupType] then
                        self.MyCrossServerGroup[crossServerGroupType] = {}
                    end
                    self.MyCrossServerGroup[crossServerGroupType][pos] = true;
                end
            else
                break;
            end
        end
    end
    return _list;
end

-- Get my maximum cross-server and location
function CrossServerMapSystem:GetMyMaxGroupTypeAndPos()
    local _crossServerGroupType = 8
    while _crossServerGroupType > 1 do
        local _isOpen, _pos = self:IsOpenMyCrossServer(_crossServerGroupType);
        if _isOpen then
            return math.floor(_crossServerGroupType), _pos;
        end
        _crossServerGroupType = _crossServerGroupType*0.5
    end
    return 0;
end
function CrossServerMapSystem:Test()
    GameCenter.ServerListSystem = {}
    GameCenter.ServerListSystem.AllList = {        
        [1]={ServerId = 1002, Name = "1002"},
        [2]={ServerId = 1003, Name = "1003"},
        [3]={ServerId = 1004, Name = "1004"},
        [4]={ServerId = 1005, Name = "1005"},
        [5]={ServerId = 1006, Name = "1006"},
        [6]={ServerId = 1007, Name = "1007"},
        [7]={ServerId = 1008, Name = "1008"},
        [8]={ServerId = 1009, Name = "1009"},
        [9]={ServerId = 1010, Name = "1010"},
        [10]={ServerId = 1011, Name = "1011"},
        [11]={ServerId = 1012, Name = "1012"},
        [12]={ServerId = 1013, Name = "1013"},
        [13]={ServerId = 1014, Name = "1014"},
        [14]={ServerId = 1015, Name = "1015"},
        [15]={ServerId = 1016, Name = "1016"},
        [16]={ServerId = 1017, Name = "1017"},
        [17]={ServerId = 1018, Name = "1018"},
        [18]={ServerId = 1019, Name = "1019"},
        [19]={ServerId = 1020, Name = "1020"},
        [20]={ServerId = 1021, Name = "1021"},
        [21]={ServerId = 1022, Name = "1022"},
        [22]={ServerId = 1023, Name = "1023"},
        [23]={ServerId = 1024, Name = "1024"},
        [24]={ServerId = 1025, Name = "1025"},
        [25]={ServerId = 1026, Name = "1026"},
        [26]={ServerId = 1027, Name = "1027"},
        [27]={ServerId = 1028, Name = "1028"},
        [28]={ServerId = 1029, Name = "1029"},
        [29]={ServerId = 1030, Name = "1030"},
        [30]={ServerId = 1031, Name = "1031"},
        [31]={ServerId = 1032, Name = "1032"},     
    };
    GameCenter.ServerListSystem.GetCurrentServer = function(sender)
        return {ServerId = 1002}
    end
    GameCenter.CrossServerMapSystem.MyServerID = 1002;
    GameCenter.CrossServerMapSystem:GS2U_ResCrossServerMatch({
        serverMatch_32 = {            
            {serverid = 1002,serverWroldLv = 200,openTime = 1583892000000},
            {serverid = 1003,serverWroldLv = 500,openTime = 1583892000000},
            {serverid = 1004,serverWroldLv = 600,openTime = 1583892000000},
            {serverid = 1005,serverWroldLv = 200,openTime = 1583892000000},
            {serverid = 1006,serverWroldLv = 200,openTime = 1583892000000},
            {serverid = 1007,serverWroldLv = 200,openTime = 1583892000000},
            {serverid = 1008,serverWroldLv = 200,openTime = 1583892000000},
            {serverid = 1009,serverWroldLv = 200,openTime = 1583892000000},
            {serverid = 1010,serverWroldLv = 200,openTime = 1583892000000},
            {serverid = 1011,serverWroldLv = 300,openTime = 1583892000000},
            {serverid = 1012,serverWroldLv = 200,openTime = 1583892000000},
            {serverid = 1013,serverWroldLv = 500,openTime = 1583892000000},
            {serverid = 1014,serverWroldLv = 600,openTime = 1583892000000},
            {serverid = 1015,serverWroldLv = 200,openTime = 1583892000000},
            {serverid = 1016,serverWroldLv = 200,openTime = 1583892000000},
            {serverid = 1017,serverWroldLv = 200,openTime = 1583892000000},
            {serverid = 1018,serverWroldLv = 200,openTime = 1583892000000},
            {serverid = 1019,serverWroldLv = 200,openTime = 1583892000000},
            {serverid = 1020,serverWroldLv = 200,openTime = 1583892000000},
            {serverid = 1021,serverWroldLv = 300,openTime = 1583892000000},
            {serverid = 1022,serverWroldLv = 200,openTime = 1583892000000},
            {serverid = 1023,serverWroldLv = 500,openTime = 1583892000000},
            {serverid = 1024,serverWroldLv = 600,openTime = 1583892000000},
            {serverid = 1025,serverWroldLv = 200,openTime = 1583892000000},
            {serverid = 1026,serverWroldLv = 200,openTime = 1583892000000},
            {serverid = 1027,serverWroldLv = 200,openTime = 1583892000000},
            {serverid = 1028,serverWroldLv = 200,openTime = 1583892000000},
            {serverid = 1029,serverWroldLv = 200,openTime = 1583892000000},
            {serverid = 1030,serverWroldLv = 200,openTime = 1583892000000},
            {serverid = 1031,serverWroldLv = 200,openTime = 1583892000000},
            {serverid = 1032,serverWroldLv = 200,openTime = 1583892000000},
        }
    });
    GameCenter.PushFixEvent(UILuaEventDefine.UICrossServerMapForm_OPEN)
end

return CrossServerMapSystem

