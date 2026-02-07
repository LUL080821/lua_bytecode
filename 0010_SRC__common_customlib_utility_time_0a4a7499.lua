------------------------------------------------
-- Author: 
-- Date: 2019-05-8
-- File: Time.lua
-- Module: Time
-- Description: Time-dependent function
------------------------------------------------
--local socket = require "socket"
local TimeUtils = CS.Thousandto.Core.Base.TimeUtils

-- The time from the start of the program
local L_RealtimeSinceStartup = 0.0
-- Time spent on the current frame
local L_DeltaTime = 0.0
local L_IsInit = false
local L_FrameCount = 0
-- Service opening time [time stamp seconds]
local L_OpenServerTime = 0
-- Total seconds from 0:00 to 0:00 on the first day of the server opening
local L_ZeroToOpenServerSec = 0
-- Server time zone (seconds)
local L_ServerZoneOffset = 0;
-- Client local time zone (seconds)
local L_ClientZoneOffset = 0;
-- Time zone difference (seconds: server time zone - client local time zone): When using os.date, the time zone difference must be added.
local L_ZoneOffset = 0;

local L_NextDayUTCTime = 0;
local Time = {}

-- Only call when main.lua is initialized, and it is not allowed elsewhere
function Time.Start(startTime)
    if L_IsInit ~= false then
        return
    end
    L_RealtimeSinceStartup = startTime
    L_IsInit = true
    L_FrameCount = CS.UnityEngine.Time.frameCount
    L_ClientZoneOffset = os.difftime(os.time(), os.time(os.date("!*t", os.time())));
end

-- Only call it when main.lua update is not allowed elsewhere
function Time.SetDeltaTime(deltaTime,realtimeSinceStartup,frameCount)
    L_RealtimeSinceStartup = realtimeSinceStartup;
    L_FrameCount = frameCount
    L_DeltaTime = deltaTime
end

-- Get the time from the start of the program
function Time.GetRealtimeSinceStartup()
    return L_RealtimeSinceStartup
end

-- Get the time consumed by a single frame
function Time.GetDeltaTime()
    return L_DeltaTime
end

-- Get the time consumed by a single frame
function Time.GetFrameCount()
    return L_FrameCount
end

-- Refer to the function StampToDateTime of the TimeUtils class in CS, convert seconds into date based on 1970-1-1
function Time.StampToDateTime(timeStamp,format)
    return TimeUtils.StampToDateTime(timeStamp,format)
end

function Time.StampToDateTimeNotZone(timeStamp,format)
    return TimeUtils.StampToDateTimeNotZone(timeStamp,format)
end

-- Get how many days the difference is, the parameter is a time-zone-free time stamp
function Time.GetDayOffset(startTime, curTime)
    return TimeUtils.GetDayOffsetNotZone(startTime + L_ServerZoneOffset, curTime + L_ServerZoneOffset)
end

-- Get how many days the difference is, the parameter is a time zone time stamp
function Time.GetDayOffsetNotZone(startTime, curTime)
    return TimeUtils.GetDayOffsetNotZone(startTime, curTime)
end

-- Get the number of seconds for the server's current time [timestamp seconds]
function Time.GetNowSeconds()
    return math.floor(GameCenter.HeartSystem.ServerTime)
end

-- Get the current server time [timestamp seconds]
function Time.ServerTime()
    return GameCenter.HeartSystem.ServerTime
end

---------------------------------------------------------------------------------------------
-- Server opening time
function Time.ResOpenServerTime(time)
    L_ServerZoneOffset = GameCenter.HeartSystem.ServerZoneOffset
    L_ZoneOffset = L_ServerZoneOffset - L_ClientZoneOffset;
    L_OpenServerTime = time * 0.001
    local _t = os.date("*t", math.floor(L_OpenServerTime) + L_ZoneOffset)
    L_ZeroToOpenServerSec = _t.hour * 3600 + _t.min * 60 + _t.sec
end

-- Get the server opening time [timestamp seconds]
function Time.GetOpenServerTime()
    return L_OpenServerTime
end

-- Get the time zone difference (seconds: server time zone-client local time zone)
function Time.GetZoneOffset()
    return L_ZoneOffset
end

-- Cut the second data into days, hours, minutes, seconds
function Time.SplitTime(timeData)
    local d = math.floor(timeData / 86400)
    timeData = timeData % 86400;
    local h = math.floor(timeData / 3600)
    timeData = timeData % 3600;
    local m = math.floor(timeData / 60)
    local s = math.floor(timeData % 60)
    return d,h,m,s
end

-- {
--     day    = 13,
--     hour   = 16,
--     isdst  = false,
--     min    = 33,
--     month  = 11,
--     sec    = 59,
-- wday = 6, [1-7 Week 7 to 6 Week, the first day of Western countries is Zhoutian]
--     yday   = 318,
--     year   = 2020,
-- }
-- Get the current time (os.date return value)
function Time.GetNowTable()
    return os.date("*t", Time.GetNowSeconds() + L_ZoneOffset)
end

-- Get the number of days this month
function Time.GetThisMonthTotalDays()
    local _t = Time.GetNowTable()
    local days = os.date("%d",os.time({year=_t.year, month=_t.month+1, day=0}))
    if days then
        return days
    end
    return 0
end

-- Get the current month
function Time.GetThisMonth()
    local _t = Time.GetNowTable()
    return tonumber(_t.month)
end

-- Get the current server opening day
function Time.GetOpenSeverDay()
    local _time =  GameCenter.HeartSystem.ServerTime - Time.GetOpenServerTime() + L_ZeroToOpenServerSec
    return math.floor(_time/86400) + 1
end

-- Get the opening date of the server opening
function Time.GetOpenSeverDayByOpenTime(openTime)
    local _t = os.date("*t", math.floor(openTime) + L_ZoneOffset)
    local _zeroToOpenServerSec = _t.hour * 3600 + _t.min * 60 + _t.sec
    local _time =  GameCenter.HeartSystem.ServerTime - openTime + _zeroToOpenServerSec
    return math.floor(_time/86400) + 1
end

-- When the input is obtained, what day is the server opening time: timestamp seconds
function Time.GetToOpenSeverDay(time)
    return math.floor((time - Time.GetOpenServerTime() + L_ZeroToOpenServerSec)/86400) + 1
end

-- Get the time (timestamp seconds)
function Time.GetTime(second, minute, hour, day, month, year)
    local _t = os.date("*t",Time.GetNowSeconds() + L_ZoneOffset);
    return os.time({year = year or _t.year, month = month or _t.month, day = day or _t.day, hour = hour or _t.hour, min = minute or _t.min, sec = second or _t.sec})
end

-- Get time (timestamp seconds) minute integer type 1440>minute>=0
function Time.GetTimeByMinute(minute)
    local _t = Time.GetNowTable()
    return os.time(
        {
            year  = _t.year,
            month = _t.month,
            day   = _t.day,
            hour  = 0,
            min   = minute,
            sec   = 0
        }
    )
end

-- Get the number of seconds of the current time (0-86399)
function Time.GetCurSeconds()
    local _t = os.date("*t",Time.GetNowSeconds() + L_ZoneOffset);
    return _t.hour * 3600 + _t.min * 60 + _t.sec
end

-- Get the total number of seconds to 0 o'clock on the next day
function Time.GetToNextDaySeconds()
    local _curTime = Time.GetNowSeconds();
    if L_NextDayUTCTime == 0 or L_NextDayUTCTime < _curTime or L_NextDayUTCTime - _curTime > 86400 then
        local _t = os.date("*t", _curTime + L_ZoneOffset);
        L_NextDayUTCTime = _curTime - _t.hour * 3600 - _t.min * 60 - _t.sec + 86400;
    end
    return L_NextDayUTCTime - _curTime;
end

return Time