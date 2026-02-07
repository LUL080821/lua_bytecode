--==============================--
-- Author: 
-- Date: 2019-05-13
-- File: FeedBackInfo.lua
-- Module: FeedBackInfo
-- Description: Feedback information data
--==============================--

local FeedBackInfo = 
{
    -- Sender 0: indicates event, 1: indicates GM, 2: indicates my information
    Sender = 0,
    -- The type of current message, 1: player bug, 2. game suggestions, 3. question consultation, 4. Others
    Type = 0,
    -- Send time, used here for sorting, seconds
    SendTime = 0,
    -- content
    Content = "",
}

function FeedBackInfo:NewBase()
    local _m = Utils.DeepCopy(self);
    return _m;
end

function FeedBackInfo:New(s,t,st,c)
    local _m = Utils.DeepCopy(self);
    _m.Sender = s;
    _m.Type = t;
    _m.SendTime = st;
    _m.Content = c;
    return _m;
end

function FeedBackInfo:ToData()
    local _m = {};
    _m.Sender = self.Sender;
    _m.Type = self.Type;
    _m.SendTime = self.SendTime;
    _m.Content = self.Content;
    return _m;
end

function FeedBackInfo:FromData(dat)      
    return FeedBackInfo:New(dat.Sender,dat.Type, dat.SendTime,dat.Content);
end

-- filter
function FeedBackInfo:Filter(dataList,type)
    local _result = List:New();
    local _time = List:New();
    for i = 1, #dataList do
        -- Filter the discord conditions
        if type ~= 0 and type ~= dataList[i].Type then
            break;
        end
        _result.Add(dataList[i]);
        
        -- Processing date prompts
        local _curDay = dataList[i].SendTime - math.mod(dataList[i].SendTime,(60*60*24));
        local _find = false;
        for j = 1 , #_time do
            if _time[j] == _curDay then
                _find = true;
                break;
            end
        end
        if not _find then
            local _tmp = FeedBackInfo:New(0,type,_curDay,Time.StampToDateTime(_curDay));
            _result.Add(_tmp);
            _time.Add(_tmp);
        end
    end      
    _time = nil;
    -- Arrange in ascending order of time
    _result:Sort(function(a,b) return a.SendTime < b.SendTime end );
    return _result;
end

return FeedBackInfo;