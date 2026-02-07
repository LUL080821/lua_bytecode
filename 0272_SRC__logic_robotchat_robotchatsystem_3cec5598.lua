------------------------------------------------
-- Author:
-- Date: 2020-01-01
-- File: RobotChatSystem.lua
-- Module: RobotChatSystem
-- Description: Robot dialogue system
------------------------------------------------

local RobotChatSystem = {
    LevelCfgDic = nil,
    ServerOpenTime = 0, -- Service opening time

    -- Dialogue list, from start to end
    ChatList = List:New(),
    -- Current conversation
    CurChat = nil,
}

local L_ChatItem = nil
-- initialization
function RobotChatSystem:Initialize()
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_PLAYER_LEVEL_CHANGED, self.OnLevelChanged, self)

    self.LevelCfgDic = Dictionary:New()

    local function  _forFunc(key, value)
        local _cfg = value
        local _levelList = nil
        if self.LevelCfgDic:ContainsKey(_cfg.NeedLevel) then
            _levelList = self.LevelCfgDic[_cfg.NeedLevel]
        else
            _levelList = List:New()
            self.LevelCfgDic:Add(_cfg.NeedLevel, _levelList)
        end
        _levelList:Add(_cfg)
    end
    DataConfig.DataRobotChat:Foreach(_forFunc)
end

-- De-initialization
function RobotChatSystem:UnInitialize()
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_PLAYER_LEVEL_CHANGED, self.OnLevelChanged, self)
end


-- Set the server opening time
function RobotChatSystem:SetOpenServerTime(time)
    self.ServerOpenTime = math.floor(time / 1000) + GameCenter.HeartSystem.ServerZoneOffset
    -- Do a test when online
    local _level = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
    local _day = Time.GetDayOffsetNotZone(self.ServerOpenTime, math.floor(GameCenter.HeartSystem.ServerZoneTime)) + 1
    local function  _forFunc(key, cfg)
        if _level >= cfg.NeedLevel and not self:ChatIsExecute(key) then
            if cfg.NeedOpenStart > 0 or cfg.NeedOpenEnd > 0 then
                if _day >= cfg.NeedOpenStart and _day <= cfg.NeedOpenEnd then
                    self.ChatList:Add(L_ChatItem:New(cfg, self))
                end
            end
        end
    end
    DataConfig.DataRobotChat:Foreach(_forFunc)
end

-- Level changes
function RobotChatSystem:OnLevelChanged(obj, sender)
    -- Calculate the current number of days of service
    local _day = Time.GetDayOffsetNotZone(self.ServerOpenTime, math.floor(GameCenter.HeartSystem.ServerZoneTime)) + 1
    -- Current level
    local _level = obj
    local _levelList = self.LevelCfgDic[_level]
    if _levelList == nil then
        return
    end

    -- Add to the conversation list
    for i = 1, #_levelList do
        local _cfg = _levelList[i]
        if not self:ChatIsExecute(_cfg.Id) and (_cfg.NeedOpenStart <= 0 or _day >= _cfg.NeedOpenStart) and (_cfg.NeedOpenEnd <= 0 or _day <= _cfg.NeedOpenEnd) then
            self.ChatList:Add(L_ChatItem:New(_levelList[i], self))
        end
    end
end

-- Is the conversation executed?
function RobotChatSystem:ChatIsExecute(id)
    local _lpID = GameCenter.GameSceneSystem:GetLocalPlayerID()
    local _key = string.format("RotbotChat_%d_%d", _lpID, id)
    if PlayerPrefs.HasKey(_key) then
        return true
    else
        return false
    end
end

-- Setting up the conversation has been executed
function RobotChatSystem:SetChatExecute(id)
    local _lpID = GameCenter.GameSceneSystem:GetLocalPlayerID()
    local _key = string.format("RotbotChat_%d_%d", _lpID, id)
    PlayerPrefs.SetInt(_key, 1)
end

-- renew
function RobotChatSystem:Update(dt)
    if self.CurChat ~= nil then
        self.CurChat:Update(dt)
        if self.CurChat.IsFinish then
            self.CurChat = nil
        end
    end

    if self.CurChat == nil and #self.ChatList > 0 then
        self.CurChat = self.ChatList[1]
        local _succ = self.CurChat:Init()
        self.ChatList:RemoveAt(1)
        if not _succ then
            self.CurChat = nil
        end
    end
end

L_ChatItem = {
    Cfg = nil,
    Robots = nil,   -- Robot list
    RobotCount = 0, -- Number of robots
    ChatList = nil, -- Conversation List

    Timer = 0,    -- Timer
    IsFinish = false,  -- Whether it's over
    CurChat = nil,
    Parent = nil,
    IsSetExecute = false,
}

function L_ChatItem:New(cfg, parent)
    local _m = Utils.DeepCopy(self)
    _m.Cfg = cfg
    _m.Parent = parent
    return _m
end

function L_ChatItem:CheckName(name)
    local _result = true
    for i = 1, #self.Robots do
        if self.Robots[i].Name == name then
            _result = false
            break
        end
    end
    return _result
end

-- initialization
function L_ChatItem:Init()
    -- Set random seeds
    math.randomseed(os.time())
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    local _lpName = _lp.Name
    self.Timer = 0
    local _rots = Utils.SplitStrByTableS(self.Cfg.RobotCfg, {';', '_'})

    -- Random robot
    self.Robots = List:New()
    for i = 1, #_rots do
        local _ranDCount = 0
        while true do
            local _name = GameCenter.PlayerRoleListSystem:GetRandomName(_rots[i][1])
            if _name ~= _lpName and self:CheckName(_name) then
                local _level = 0
                if _rots[i][2] == _rots[i][3] then
                    _level = _rots[i][2]
                else
                    _level = math.random(_rots[i][2], _rots[i][3])
                end
                self.Robots:Add({Occ = _rots[i][1], Name = _name, Level = _level})
                break
            end
            _ranDCount = _ranDCount + 1
            if _ranDCount >= 100 then
                Debug.LogError("Random robot name failed" .. _name)
                return false
            end
        end
    end

    self.ChatList = List:New()
    local _chatParams = Utils.SplitStrBySeps(self.Cfg.Chats, {';', '_'})
    for i = 1, #_chatParams do
        local _index = tonumber(_chatParams[i][1])
        local _timeStart = tonumber(_chatParams[i][2])
        local _timeEnd = tonumber(_chatParams[i][3])
        local _text = UIUtils.CSFormat("<t=0>,,{0}</t>",_chatParams[i][4])
        local _chatText = _text
        self.ChatList:Add({RIndex = _index, WaitTime = math.random(_timeStart, _timeEnd), Text = _chatText})
    end
    self.CurChat = nil
    self.IsFinish = false
    self.IsSetExecute = false
    return true
end

function L_ChatItem:Update(dt)
    if self.CurChat ~= nil then
        self.Timer = self.Timer + dt
        if self.Timer >= self.CurChat.WaitTime then
            local _robot = self.Robots[self.CurChat.RIndex]
            GameCenter.MapLogicSwitch:RobotChat(_robot.Name, _robot.Occ, _robot.Level, self.CurChat.Text)
            -- Execute the speech
            self.CurChat = nil
            if not self.IsSetExecute then
                self.IsSetExecute = true
                self.Parent:SetChatExecute(self.Cfg.Id)
            end
        end
    end

    if self.CurChat == nil then
        if #self.ChatList > 0 then
            self.CurChat = self.ChatList[1]
            self.ChatList:RemoveAt(1)
            self.Timer = 0.0
        else
            self.IsFinish = true
        end
    end
end

return RobotChatSystem