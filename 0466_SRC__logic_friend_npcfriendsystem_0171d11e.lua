------------------------------------------------
-- Author: Gao Ziyu
-- Date: 2021-07-13
-- File: NPCFriendSystem.lua
-- Module: NPCFriendSystem
-- Description: NPC friend system class
------------------------------------------------

-- NPC friend information structure
local NPCFriendData = {
    info = nil,
    Task = nil,
}

function NPCFriendData:New()
    local _m = Utils.DeepCopy(self)
    _m.info = {}
    _m.Task = Dictionary:New()
    return _m
end

--====================================================================--
local L_RoleBaseAttribute = CS.Thousandto.Code.Global.RoleBaseAttribute
local L_TimeUtils = CS.Thousandto.Core.Base.TimeUtils


local NPCFriendSystem = {
    -- NPC Friend Information Dictionary
    DicNpcInfo = Dictionary:New(),
    CurNPC = nil,
    CurNPCShipBtnType = nil,
    -- Prevent level change messages from being received when online
    IsInit_lv = false,
    IsInit_job = false,
    IsInit_OpenTime = false,
    -- Cache bot chat
    CacheRobotChat = List:New(),
}

function  NPCFriendSystem:Initialize()
    -- self.CurNPC =  self:GetNpcFriendInfo(10001) --===--TEMP
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_PLAYER_LEVEL_CHANGED, self.RiseLvCallBack, self)
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_TASKFINISH, self.OnTaskFinish, self)
    GameCenter.RegFixEventHandle(LogicLuaEventDefine.EID_EVENT_NPCFRIENFTRIGGERTYPE_SENDSHIP , self.CheckCondition ,self)
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_TALKTONPC_CLICK , self.TalkToNPC ,self)
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_PLAYER_BASE_ATTR_CHANGED , self.ChangeJob ,self)
    
end

function  NPCFriendSystem:UnInitialize()
    self.DicNpcInfo = nil
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_PLAYER_LEVEL_CHANGED, self.RiseLvCallBack, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_TASKFINISH , self.OnTaskFinish , self)
    GameCenter.UnRegFixEventHandle(LogicLuaEventDefine.EID_EVENT_NPCFRIENFTRIGGERTYPE_SENDSHIP , self.CheckCondition ,self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_TALKTONPC_CLICK , self.TalkToNPC ,self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_PLAYER_BASE_ATTR_CHANGED , self.ChangeJob ,self)
end


-- Get an npc information
function  NPCFriendSystem:GetNpcFriendInfo(id)
    if self.DicNpcInfo:Count() == 0 then
        self:GetNpcInfoByTable()
    end
    return self.DicNpcInfo[id]
end

-- Reading table
function NPCFriendSystem:GetNpcInfoByTable()
    DataConfig.DataNpcFriend:Foreach(function(k, v)
        local data = NPCFriendData:New()
        data.info = v
        local TaskList_1 = List:New()
        local TaskList_2 = List:New()
        local TaskList_3 = List:New()
        local TaskList_4 = List:New()
        local TaskList_5 = List:New()
        local TaskList_6 = List:New()
        local TaskList_7 = List:New() 
        data.Task:Add(1 , TaskList_1)
        data.Task:Add(2 , TaskList_2)
        data.Task:Add(3 , TaskList_3)
        data.Task:Add(4 , TaskList_4)
        data.Task:Add(5 , TaskList_5)
        data.Task:Add(6 , TaskList_6)
        data.Task:Add(7 , TaskList_7)
        self.DicNpcInfo:Add(k,data)
    end)

    self.DicNpcInfo:Foreach(
        function(a,b)
            DataConfig.DataNpcFriendTalk:Foreach(function(k, v)
                if v.Gruopid == b.info.Gruopid then
                    if v.Type == 1 then
                        self.DicNpcInfo[a].Task[1]:Add(v)
                    elseif v.Type == 2 then 
                        self.DicNpcInfo[a].Task[2]:Add(v)
                    elseif v.Type == 3 then 
                        self.DicNpcInfo[a].Task[3]:Add(v)
                    elseif v.Type == 4 then 
                        self.DicNpcInfo[a].Task[4]:Add(v)
                    elseif v.Type == 5 then 
                        self.DicNpcInfo[a].Task[5]:Add(v)
                    elseif v.Type == 6 then 
                        self.DicNpcInfo[a].Task[6]:Add(v)
                    elseif v.Type == 7 then
                        self.DicNpcInfo[a].Task[7]:Add(v)
                    end
                end 
            end)
        end
    )

end

-- Determine whether the NPC dialogue conditions are met
function NPCFriendSystem:CheckCondition(type , obj)
    if self.CurNPC.info.Level < 0 then
        self.CurNPC.info.Level = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
    end
    if type == 1 then
        GameCenter.ChatSystem:RobotChatEx(self.CurNPC.info.Id, self.CurNPC.info.Occ, self.CurNPC.info.Name,self.CurNPC.info.Level, self.CurNPC.info.Icon, 0 , 0 ,self.CurNPC.Task[3][1].Talk , 3 ,0 )
    elseif type == 2 then
        GameCenter.ChatSystem:RobotChatEx(self.CurNPC.info.Id, self.CurNPC.info.Occ, self.CurNPC.info.Name,self.CurNPC.info.Level, self.CurNPC.info.Icon, 0 , 0 ,self.CurNPC.Task[4][1].Talk , 3 ,0 )
    end
end

-- Upgrade callback
function NPCFriendSystem:RiseLvCallBack(obj , sender)
    if not self.IsInit_lv then
        self.IsInit_lv = true
        return
    end
    if self.CurNPC == nil then
        return
    end
    local _curLevel = tonumber(obj)
    for i = 1, #self.CurNPC.Task[1] do
        if _curLevel == tonumber(self.CurNPC.Task[1][i].Parm) then
            if self.CurNPC.info.Level < 0 then
                self.CurNPC.info.Level = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
            end
            GameCenter.ChatSystem:RobotChatEx(self.CurNPC.info.Id, self.CurNPC.info.Occ, self.CurNPC.info.Name,self.CurNPC.info.Level, self.CurNPC.info.Icon, 0 , 0 ,self.CurNPC.Task[1][i].Talk , 3 ,0 )
        end
    end
end

function NPCFriendSystem:OnTaskFinish(obj, sender)
    if self.CurNPC == nil then
        return
    end
    if obj ~= nil then
        local modelId = tonumber(obj)
        for i = 1, #self.CurNPC.Task[2] do
            if modelId == tonumber(self.CurNPC.Task[NPCFriendTask.Task][i].Parm) then
                if self.CurNPC.info.Level < 0 then
                    self.CurNPC.info.Level = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
                end
                GameCenter.ChatSystem:RobotChatEx(self.CurNPC.info.Id, self.CurNPC.info.Occ, self.CurNPC.info.Name,self.CurNPC.info.Level, self.CurNPC.info.Icon, 0 , 0 ,self.CurNPC.Task[2][i].Talk , 3 ,0 )
            end
        end
        
	end
end

function NPCFriendSystem:TalkToNPC(obj, sender)
    if self.CurNPC == nil then
        return
    end
    if self.CurNPC.info.Level < 0 then
        self.CurNPC.info.Level = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
    end
    local _chatData = {
        GroupId = self.CurNPC.info.Gruopid,
        Name = self.CurNPC.info.Name,
        Level = self.CurNPC.info.Level,
        Text = self:DealWitchTalkStr(self.CurNPC.Task[5][1].Talk),
        Id = self.CurNPC.info.Id,
        CanShow = false,
        Occ = self.CurNPC.info.Occ,
        HeadId = self.CurNPC.info.Icon,
        Tick = 1
    }
    self.CacheRobotChat:Add(_chatData)
end

function NPCFriendSystem:DealWitchTalkStr(str)
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return ""
    end
    local _occ = _lp.IntOcc
    local _sb = ""
    local _strs = Utils.SplitStr(str, '<')
    for i = 1, #_strs do
        if string.find(_strs[i], '>', 1) ~= nil then
            if string.find(_strs[i], "-n", 1) ~= nil then
                -- Handle character names
                local _replaceStr = string.gsub(_strs[i], "-n", "")
                local _param1 = ""
                local _param2 = ""
                local _param3 = ""
                local _strs1 = Utils.SplitStr(_replaceStr, '>')
                for m = 1, #_strs1 do
                    if string.find(_strs1[m], '/', 1) ~= nil then
                        local _strs2 = Utils.SplitStr(_strs1[m], '/')
                        _param1 = _strs2[1]
                        _param2 = _strs2[2]
                        _param3 = _strs2[3]
                    else
                        local _param = ""
                        if _occ == 0 then
                            _param = _param1
                        elseif _occ == 1 then
                            _param = _param2
                        elseif _occ == 2 then
                            _param = _param3
                        end
                        _sb = _sb .. UIUtils.CSFormat(_strs1[m], _param)
                    end
                end
            end
        else
            _sb = _sb .. _strs[i]
        end
    end
    return _sb
end


function NPCFriendSystem:OpenDayTime()
    local _openDay = Time.GetOpenSeverDay();
    for i = 1, #self.CurNPC.Task[6] do
        local str = Utils.SplitNumber(self.CurNPC.Task[6][i].Parm , "_")
        if _openDay == str[1] then
            self.TimerId = GameCenter.TimerEventSystem:AddCountDownEvent( str[2] * 60,
            false, nil, function(id, remainTime, param)
                if self.CurNPC.info.Level < 0 then
                    self.CurNPC.info.Level = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
                end
                GameCenter.ChatSystem:RobotChatEx(self.CurNPC.info.Id, self.CurNPC.info.Occ, self.CurNPC.info.Name,self.CurNPC.info.Level, self.CurNPC.info.Icon, 0 , 0 ,self.CurNPC.Task[6][i].Talk , 3 ,0 )
            end)
        end
    end
    
end

function NPCFriendSystem:ChangeJob(prop , sender)
    if self.CurNPC == nil then
        return
    end
    if prop.CurrentChangeBasePropType == L_RoleBaseAttribute.ChangeJobLevel  then
        for i = 1, #self.CurNPC.Task[7] do
            local p = GameCenter.GameSceneSystem:GetLocalPlayer()
            if self.CurNPC.info.Level < 0 then
                self.CurNPC.info.Level = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
            end
            if tonumber(self.CurNPC.Task[7][i].Parm) == tonumber(p.ChangeJobLevel) then
                GameCenter.ChatSystem:RobotChatEx(self.CurNPC.info.Id, self.CurNPC.info.Occ, self.CurNPC.info.Name,self.CurNPC.info.Level, self.CurNPC.info.Icon, 0 , 0 ,self.CurNPC.Task[7][i].Talk , 3 ,0 )
            end
        end
    end
end

function NPCFriendSystem:OpenTimer()
    local time = tonumber(self.CurNPC.info.QingyiTime)
    local _hour, _min, _sec = L_TimeUtils.GetStampTimeHHMMSSNotZone(math.floor(GameCenter.HeartSystem.ServerZoneTime))
    if _hour*60 + _min > time then
        GameCenter.FriendSystem:ReqNpcFriendGiveShipPoint(self.CurNPC.info.Id)
        return
    end
    self.TimerEventId = GameCenter.TimerEventSystem:AddTimeStampDayEvent(60*time, 1 ,
    false, nil, function(id, remainTime, param)
        if self.CurNPCShipBtnType == FriendShipType.Send then
            GameCenter.FriendSystem:ReqNpcFriendGiveShipPoint(self.CurNPC.info.Id)
        end
    end)
end

-- Receive npc messages sent by the server
function NPCFriendSystem:ResFriendNpcList(msg)
    if msg == nil then
        return
    end
    self.CurNPC = self:GetNpcFriendInfo(msg)
    if self.CurNPC ~= nil then
        local _lv = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
        self:RiseLvCallBack(_lv)
        self:OpenDayTime()
        self:OpenTimer()
    end
end

function NPCFriendSystem:Update(dt)
    if self.CacheRobotChat ~= nil and #self.CacheRobotChat > 0 then
        local _data = self.CacheRobotChat[1]
        if _data ~= nil then
            if _data.Tick > 0 then
                -- Send bot chat
                _data.Tick = _data.Tick - dt
            else
                GameCenter.ChatSystem:RobotChatEx( _data.Id , _data.Occ, _data.Name, _data.Level, _data.HeadId , 0 , 0  ,_data.Text , 3 ,0)
                self.CacheRobotChat:RemoveAt(1)
            end
        end
    end
end

function NPCFriendSystem:ReqNpcFriendGiveShipPoint(id)
    local _msg = ReqMsg.MSG_Friend.ReqNpcFriendGiveShipPoint:New()
    _msg.npcId = id
    _msg:Send()
end


return NPCFriendSystem

