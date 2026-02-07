------------------------------------------------
-- Author:
-- Date: 2020-08-24
-- File: MarryDatingWallSystem.lua
-- Module: MarryDatingWallSystem
-- Description: Blind date wall system
------------------------------------------------
local TimeUtils = CS.Thousandto.Core.Base.TimeUtils
local RedPointCustomCondition = CS.Thousandto.Code.Logic.RedPointCustomCondition
local RedPointLevelCondition = CS.Thousandto.Code.Logic.RedPointLevelCondition

local MarryDatingWallSystem = {
    -- Timer ID
    TimerID = nil,
    -- Days to start the event
    BeginDay = 0,
    -- Days ending
    EndDay = 0,
    -- Service opening time
    ServerOpenTime = 0,
    -- Have you received a level reward
    IsGetLevelAward = false,
    -- CD time for sending a declaration
    CDTime = 0,
    CDSyncTime = 0,
    -- Level of award
    GetAwardLevel = 0,
    -- Reward items
    AwardItems = nil,
    -- Number of seconds to end the activity
    EndSec = 0,

    -- CD timer
    CDTimerID = nil,
}

function MarryDatingWallSystem:Initialize()
    local _gCfg = DataConfig.DataGlobal[GlobalName.Marry_Wall_OpenTime]
    if _gCfg ~= nil then
        local _params = Utils.SplitNumber(_gCfg.Params, '_')
        self.BeginDay = _params[1]
        self.EndDay = _params[2]
    end

    _gCfg = DataConfig.DataGlobal[GlobalName.Marry_Wall_Award_Level]
    if _gCfg ~= nil then
        self.GetAwardLevel = tonumber(_gCfg.Params)
    end

    _gCfg = DataConfig.DataGlobal[GlobalName.Marry_Wall_Award_Items]
    if _gCfg ~= nil then
        self.AwardItems = Utils.SplitStrByTableS(_gCfg.Params, {';', '_'})
    end
end

function MarryDatingWallSystem:UnInitialize()
    if self.TimerID ~= nil then
        GameCenter.TimerEventSystem:RemoveTimerEvent(self.TimerID)
    end
    self.TimerID = nil

    if self.CDTimerID ~= nil then
        GameCenter.TimerEventSystem:RemoveTimerEvent(self.CDTimerID)
    end
    self.CDTimerID = nil
end

-- Get the Declaration CD
function MarryDatingWallSystem:GetXuanYanCDTime()
    local _result = self.CDTime - (Time.GetRealtimeSinceStartup() - self.CDSyncTime)
    if _result <= 0 then
        _result = 0
    end
    return _result
end

-- Set the server opening time
function MarryDatingWallSystem:SetOpenServerTime(time)
    self.ServerOpenTime = math.floor(time / 1000) + GameCenter.HeartSystem.ServerZoneOffset
    if self.TimerID ~= nil then
        GameCenter.TimerEventSystem:RemoveTimerEvent(self.TimerID)
    end
    -- Perform at 1 second every morning
    self.TimerID = GameCenter.TimerEventSystem:AddTimeStampDayEvent(1, 86400,
    true, nil, function(id, remainTime, param)
        self:CheckFuncOpenState()
    end)

    local _h, _m, _s = TimeUtils.GetStampTimeHHMMSSNotZone(self.ServerOpenTime)
    self.EndSec = self.ServerOpenTime - (_h * 3600 + _m * 60 + _s) + self.EndDay * 86400

    -- Friend red dots are displayed by default
    GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.MarryWallLevel, 0, RedPointCustomCondition(true))
end

function MarryDatingWallSystem:CheckFuncOpenState()
    local _day = TimeUtils.GetDayOffsetNotZone(self.ServerOpenTime, math.floor(GameCenter.HeartSystem.ServerZoneTime)) + 1
    if _day >= self.BeginDay and _day <= self.EndDay then
        GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.MarryWall, true)
    else
        GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.MarryWall, false)
    end
end

function MarryDatingWallSystem:CheckCDRedPoint()
    local _cdTime = self:GetXuanYanCDTime()
    if self.CDTimerID ~= nil then
        GameCenter.TimerEventSystem:RemoveTimerEvent(self.CDTimerID)
    end
    if _cdTime <= 0 then
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.MarryWallXuanYan, true)
    else
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.MarryWallXuanYan, false)
        self.CDTimerID = GameCenter.TimerEventSystem:AddCountDownEvent(_cdTime + 3,
        true, nil, function(id, remainTime, param)
            self:CheckCDRedPoint()
        end)
    end
end

-- Request a level reward
function MarryDatingWallSystem:ReqMarryWallReward()
    GameCenter.Network.Send("MSG_Marriage.ReqMarryWallReward", {})
end

-- Send a declaration
function MarryDatingWallSystem:ReqPushMarryDeclaration(id)
    GameCenter.Network.Send("MSG_Marriage.ReqPushMarryDeclaration", {declarationId = id})
end

-- List of request declarations
function MarryDatingWallSystem:ReqMarryWallDeclaration()
    GameCenter.Network.Send("MSG_Marriage.ReqMarryWallDeclaration", {})
end

-- Request to develop relationships
function MarryDatingWallSystem:ReqMarryAddFriend(id)
    GameCenter.Network.Send("MSG_Marriage.ReqMarryAddFriend", {roleId = id})
end

-- Receive level rewards and return
function MarryDatingWallSystem:ResMarryWallRewardInfo(msg)
    self.IsGetLevelAward = msg.haveReward == 0
    self.CDTime = msg.cd
    self.CDSyncTime = Time.GetRealtimeSinceStartup()
    self:CheckCDRedPoint()
    -- Receive the award red dot
    GameCenter.RedPointSystem:RemoveFuncCondition(FunctionStartIdCode.MarryWallLevel, 1)
    if not self.IsGetLevelAward then
        -- If you don't receive a reward, add a level to receive a red dot
        GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.MarryWallLevel, 1, RedPointLevelCondition(self.GetAwardLevel))
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_MARRY_WALL_GETREWARD)
end

-- Love declaration list
function MarryDatingWallSystem:ResMarryWallInfo(msg)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_MARRY_WALL_XUANYAN_LIST, msg)
end

-- Development Relations Notice
function MarryDatingWallSystem:ResMarryAddFriendNotify(msg)
    local _roleId = msg.roleId
    Utils.ShowMsgBox(function(code)
        if code == MsgBoxResultCode.Button2 then
            GameCenter.Network.Send("MSG_Marriage.ReqMarryAddFriendOpt", {roleId = _roleId, opt = 1})
        else
            GameCenter.Network.Send("MSG_Marriage.ReqMarryAddFriendOpt", {roleId = _roleId, opt = 0})
        end
    end, "C_MARRY_FRIEND_ASK", msg.roleName)
end

return MarryDatingWallSystem
