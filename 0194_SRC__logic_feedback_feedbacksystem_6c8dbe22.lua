------------------------------------------------
-- Author: 
-- Date: 2019-05-15
-- File: FeedBackSystem.lua
-- Module: FeedBackSystem
-- Description: Player feedback system
------------------------------------------------
local FeedBackInfo = require("Logic.FeedBack.FeedBackInfo");
local FeedBackSystem ={
    -- data
    FeedbackList = List:New(),
    -- Whether the data has been modified
    IsDirty = false,

    -- The last time of submission
    LastPostDateTime = 0
};

local L_CN_FD_KEY = "FeedbackList4";
local L_CN_FD_MAX_COUNT = 10;

-- ==Public method==--
function FeedBackSystem:Initialize()
   
end

function FeedBackSystem:UnInitialize()
   
end

-- Time to get the last feedback
function FeedBackSystem:GetLastPostDateTime()
    if self.LastPostDateTime <= 0 then
        if self.FeedbackList:Count() > 0 then
            for _,v in ipairs(self.FeedbackList) do            
                if v.Type == 1 and v.SendTime > self.LastPostDateTime then
                    self.LastPostDateTime = v.SendTime;
                end
            end
        end
    end
    return self.LastPostDateTime;
end
-- Read data
function FeedBackSystem:Read()
    local _key = L_CN_FD_KEY .. PlayerPrefs.GetString("account", "");
    self.IsDirty = false;
    local _feedStr = PlayerPrefs.GetString(_key,"");
    if string.len(_feedStr ) > 10 then
        local _tab = Utils.StrToTable(_feedStr);    
        self.FeedbackList:Clear();  
        for k,v in ipairs(_tab) do
            self.FeedbackList:Add(FeedBackInfo:FromData(v)); 
        end        
    end   
end

-- Save data
function FeedBackSystem:Save()
    if self.IsDirty then     
        local _key = L_CN_FD_KEY .. PlayerPrefs.GetString("account", "");   
        self.IsDirty = false;   
        local _tab = {};
        local _startIdx = #self.FeedbackList - L_CN_FD_MAX_COUNT;
        if _startIdx <=0 then _startIdx = 1; end
        for i = _startIdx, #self.FeedbackList do            
            _tab[i] = self.FeedbackList[i]:ToData();
        end
        local _feedStr = Utils.TableToStr(_tab);
        PlayerPrefs.SetString(_key,_feedStr);
    end
end

-- Convert List
function FeedBackSystem:ConvertList(msgList)    
    local _result = List:New();    
    for i = 0, msgList.Count do
        -- Convert data
        _result:Add(FeedBackInfo:New(msgList[i].Sender,msgList[i].Type,msgList[i].SendTime,msgList[i].Contend));
    end
    return _result;
end

-- Get feedback list through type
function FeedBackSystem:GetFeedBackByType(type)
    local _result = List:New();
    local _time = List:New();
    local dataList = self.FeedbackList;
    for i = 1, #dataList do
        -- Filter the discord conditions
        if type == 0 or type == dataList[i].Type then
            _result:Add(dataList[i]);
            -- Processing date prompts
            local _curDay = math.modf(dataList[i].SendTime/86400) ;--(60*60*24)
            _curDay = _curDay * 86400;
            local _find = false;
            for j = 1 , #_time do            
                if _time[j] == _curDay then
                    _find = true;
                    break;
                end
            end
            if not _find then
                local _tmp = FeedBackInfo:New(0,type,_curDay,Time.StampToDateTime(_curDay,"yyyy-MM-dd"));
                _result:Add(_tmp);
                _time:Add(_curDay);
            end
        end
    end      
    _time = nil;
    -- Arrange in ascending order of time
    _result:Sort(function(a,b) return a.SendTime < b.SendTime end );
    return _result;
end

-- ==Processing network messages==--

-- Accept GM feedback information
function FeedBackSystem:GS2U_ResGMFeedback(msg)  
    self.IsDirty = true;    
    for k,v in ipairs(msg.list) do        
        local _fb = FeedBackInfo:New(1,v.type,Time.GetNowSeconds()+1,v.content);
        self.FeedbackList:Add(_fb);
    end
    self:Save();
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_FEEDBACK_LIST_CHANGED);
end

-- Return whether the feedback information is submitted successfully
function FeedBackSystem:GS2U_ResCommitFeedback(msg)
    if msg.success then        
        self:Save();
    else
        self:Read();
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_FEEDBACK_LIST_CHANGED);
end

-- Submit feedback to the server
function FeedBackSystem:PostFeedBack(t,c)
    local _fb = FeedBackInfo:New(2,t,Time.GetNowSeconds(),c);
    self.FeedbackList:Add(_fb);
    self.IsDirty = true;
    self.LastPostDateTime = _fb.SendTime;
    GameCenter.Network.Send("MSG_Setting.ReqCommitFeedback", {type = t, content = c});
end


return FeedBackSystem;
