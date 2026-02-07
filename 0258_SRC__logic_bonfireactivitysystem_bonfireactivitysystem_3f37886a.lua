
------------------------------------------------
-- Author:
-- Date: 2019-10-16
-- File: BonfireActivitySystem.lua
-- Module: BonfireActivitySystem
-- Description: Bonfire Activity System
------------------------------------------------
local GameUICenter = CS.Thousandto.Code.Center.GameUICenter

local BonfireActivitySystem = {
    -- Remaining time for the event
    ActivityRemindTime = 0,
    -- Bonfire level
    BonfireLv = 0,
    -- Maximum bonfire level
    BonfireTopLv = 0,
    -- The current bonfire is admiring
    BonfireExp = 0,
    -- Current level bonfire experience
    BonfireTotalExp = 0,
    -- Time of adding firewood stage
    AddWoodTime = 0,

    -- Is the last game a tie
    IsDraw = false,
    -- Team ID
    TeamID = 0,
    -- Have you received the award
    IsReward = false,
    -- Time of boxing
    HQActivityRemindTime = 0,
    -- Progress in victory in boxing
    HQWingProgress = 0,
    -- Fist-making victory target value
    HQWingTraget = 0,
    -- Progress in boxing
    HQJoinProgress = 0,
    -- Participate in the target value of boxing
    HQJoinTarget = 0,
    -- Boxing team information
    HQMatchList = List:New(),
    -- The currently selected gesture
    CurrSelectGesture = 1,
    -- The currently selected sum
    CurrSelectSum = 0,
    -- Initial amount of alcohol for punching
    GameHP = 0,
    -- Request to exit
    ReqExit = false,
    -- Match cooldown time
    MatchWait = 0,
    -- Preparation time for boxing
    HQReadyTime = 0,
    -- Select time for punching
    HQSelectTime = 0,
    -- End of punching interface display time
    HQEndTime = 0,
    -- Fisting task data
    HQTaskData = Dictionary:New(),
    -- The boxing game ends
    HQGameOver = false,
    -- Fist game results
    HQGameResult = 0,
    -- Whether the player left
    HQIsLeave = false,
    -- Is it in the event
    IsInActivity = false,
    -- Is it in a boxing activity
    IsInHQActivity = false,
    -- Activity end timestamp (seconds)
    ActivityEndUTCTime = 0,
}

function BonfireActivitySystem:Initialize()
    self.IsInActivity = false;
    local _str = DataConfig.DataGlobal[GlobalName.World_Bonfire_Game_Aim]
    local _targetCfg = Utils.SplitStr(_str.Params, "_")
    if _targetCfg and #_targetCfg >= 2 then
        self.HQWingTraget = tonumber(_targetCfg[1])
        self.HQJoinTarget = tonumber(_targetCfg[2])
    end
    local _s = DataConfig.DataGlobal[GlobalName.World_Bonfire_Stage]
    local _timeCfg = Utils.SplitStrBySeps(_s.Params, {";", "_"})
    if _timeCfg and #_timeCfg >= 3 then
        self.HQReadyTime = tonumber(_timeCfg[1][2] )
        self.HQSelectTime = tonumber(_timeCfg[2][2])
        self.HQEndTime = tonumber(_timeCfg[3][2] )
    end

    local _woodTimeCfg = DataConfig.DataGlobal[GlobalName.World_Bonfire_Wood_time]
    self.AddWoodTime = _woodTimeCfg.Params and tonumber(_woodTimeCfg.Params)

    local _hpCfg = DataConfig.DataGlobal[GlobalName.World_Bonfire_Game_Hp]
    self.GameHP = _hpCfg.Params and tonumber(_hpCfg.Params)

    local _matchCd = DataConfig.DataGlobal[GlobalName.World_Bonfire_Game_Match_wait]
    self.MatchWait = _matchCd.Params and tonumber(_matchCd.Params)

    local _topLv = DataConfig.DataGlobal[GlobalName.World_Bonfire_Fire_level_max]
    self.BonfireTopLv = _topLv.Params and tonumber(_topLv.Params)
    
    local _hqTime = DataConfig.DataGlobal[GlobalName.World_Bonfire_Game_Time]
    self.HQActivityRemindTime = _hqTime.Params and tonumber(_hqTime.Params)
end

function BonfireActivitySystem:UnInitialize()
    self.HQTaskData:Clear()
end

function BonfireActivitySystem:Update(dt)
    if self.IsInActivity then
        self.ActivityRemindTime = self.ActivityEndUTCTime - Time.ServerTime();
        if self.ActivityRemindTime <= 0 then
            self.IsInActivity = false;
            self:SendLeaveMapMsg();
        end

        if not self.IsInHQActivity then
            self.IsInHQActivity = self.ActivityRemindTime <= self.HQActivityRemindTime
            if self.IsInHQActivity then
                GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_BONFIRE_REFRESH_PANEL)
            end
        end
    end
end

-- Is the current stage a stage of adding firewood?
function BonfireActivitySystem:IsAddWood()
    return self.ActivityRemindTime > self.HQActivityRemindTime
end

-- Get punch gesture
function BonfireActivitySystem:GetGesture()
    local _min = 0
    local _max = 2
    math.randomseed(os.time())
    return math.random(_min, _max) * 5
end

-- Get the total punch
function BonfireActivitySystem:GetSum()
    local _min = 0
    local _max = 4
    math.randomseed(os.time())
    return math.random(_min, _max) * 5
end

-- Check whether you can receive a reward
function BonfireActivitySystem:CheckIsReward()
    if self.IsReward then
        return false
    else
        return self.HQWingProgress >= self.HQWingTraget or self.HQJoinProgress >= self.HQJoinTarget
    end
end

-- Update the amount of alcohol the player has drunk
function BonfireActivitySystem:UpdatePlayerWine(msg)
    if ( not msg.fingers ) or #msg.fingers < 2 then
        return
    end
    if self.IsDraw then
        local _i = 0
        for i=1, #self.HQMatchList do
            if self.HQMatchList[i].roleId == msg.fingers[1].roleId then
                if msg.fingers[1].res == 2 or msg.fingers[1].res == 3 then
                    self.HQMatchList[i].remainWine = self.HQMatchList[i].remainWine + 1
                end
            elseif self.HQMatchList[i].roleId == msg.fingers[2].roleId then
                if msg.fingers[2].res == 2 or msg.fingers[2].res == 3 then
                    self.HQMatchList[i].remainWine = self.HQMatchList[i].remainWine + 1
                end
            end
        end
    else
        for j=1, #self.HQMatchList do
            if self.HQMatchList[j].roleId == msg.fingers[1].roleId then
                if msg.fingers[1].res == 2 then
                    self.HQMatchList[j].remainWine = self.HQMatchList[j].remainWine + 1
                end
            elseif self.HQMatchList[j].roleId == msg.fingers[2].roleId then
                if msg.fingers[2].res == 2 then
                    self.HQMatchList[j].remainWine = self.HQMatchList[j].remainWine + 1
                end
            end
        end
    end
    self.IsDraw = msg.fingers[1].res == 3 and msg.fingers[2].res == 3
end

-- Check if any player has finished drinking
function BonfireActivitySystem:CheckGameOver()
    for i=1, #self.HQMatchList do
        if self.HQMatchList[i].remainWine >= self.GameHP then
            return true
        end
    end
    return false
end

-- Get game results
function BonfireActivitySystem:GetGameResult(id)
    for i=1, #self.HQMatchList do
        if self.HQMatchList[i].roleId == id then
            if self.HQMatchList[i].remainWine < self.GameHP then
                return 1
            else
                return 2
            end
        end
    end
    return 2
end

-----------------------msg---------------------
-- Request to add to the firewood
function BonfireActivitySystem:ReqAddWood()
    GameCenter.Network.Send("MSG_WorldBonfire.ReqWorldBonfireAddWood",{})
end

-- Request a match for the punching opponent
function BonfireActivitySystem:ReqMacht()
    GameCenter.Network.Send("MSG_WorldBonfire.ReqWorldBonfireMatch",{})
end 

-- Request for boxing rewards
function BonfireActivitySystem:ReqReward()
    GameCenter.Network.Send("MSG_WorldBonfire.ReqWorldBonfireReward",{})
end

-- Request a punch
function BonfireActivitySystem:ReqHuaQuan()
    local _req = {}
    _req.total = self.CurrSelectSum
    _req.type = self.CurrSelectGesture
    _req.teamId = self.TeamID
    GameCenter.Network.Send("MSG_WorldBonfire.ReqWorldBonfireFinger", _req)
end

-- Request to leave the punching
function BonfireActivitySystem:ReqLeavel()
    self.ReqExit = true
    local _req = {}
    _req.teamId = self.TeamID
    GameCenter.Network.Send("MSG_WorldBonfire.ReqWorldBonfireLeave",_req)
end

-- Request to cancel the match
function BonfireActivitySystem:ReqCancelMatch()
    GameCenter.Network.Send("MSG_WorldBonfire.ReqWorldBonfireCancelMatch",{})
end

-- Return to the bonfire activity Related
-- message ResWorldBonfirePanel
-- {
-- 	enum MsgID { eMsgID = 520101;};
-- required int32 remainTime =1;//Remaining time
-- required int32 param1 =2;// Bonfire level or boxing victory
-- required int32 param2 =3;// Tianchai experience or number of participation in boxing
-- 	optional int32 param3 =4;
-- }
function BonfireActivitySystem:GS2U_ResBonfireActivityInfo(msg)
    if not msg then
        return
    end
    self.ActivityRemindTime = math.floor(msg.remainTime / 1000 + 0.5)
    self.ActivityEndUTCTime = self.ActivityRemindTime + Time.ServerTime();
    if self.ActivityRemindTime > self.HQActivityRemindTime then
        local _levelUp = self.BonfireLv < msg.param1
        self.BonfireLv = msg.param1
        self.BonfireExp = msg.param2
        local _cfg = DataConfig.DataWorldBonfire[self.BonfireLv]
        if _cfg then
            self.BonfireTotalExp = _cfg.LevelExp
        end
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_BONFIRE_ADD_WOOD, _levelUp)
    else
        self.HQWingProgress = msg.param1
        self.HQJoinProgress = msg.param2
        if msg.param1 > self.HQWingTraget then
            self.HQWingProgress = self.HQWingTraget
        end
        if msg.param2 > self.HQJoinTarget then
            self.HQJoinProgress = self.HQJoinTarget
        end
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_BONFIRE_REFRESH_PANEL)
    end
    self.IsReward = msg.param3 == 1
    self.IsInActivity = self.ActivityRemindTime > 0.5;
    self.IsInHQActivity = self.ActivityRemindTime <= self.HQActivityRemindTime
    if msg.gatherCount ~= nil then
        self.GatherCount = msg.gatherCount
    end
    if not self.IsInActivity then
        self:SendLeaveMapMsg();
    end
end

-- Return to the boxing team
-- message ResWorldBonfireMatchList
-- {
-- 	enum MsgID { eMsgID = 520102;};
-- 	repeated WorldBonfireMember members = 1;
-- 	required int64 teamId = 2; 
-- }
function BonfireActivitySystem:GS2U_ResHQMatchList(msg)
    self.HQMatchList:Clear()
    if not msg or not msg.members then
        return
    end
    self.HQGameOver = false
    self.HQGameResult = 0
    self.TeamID = msg.teamId
    self.HQMatchList = List:New(msg.members)
    GameCenter.PushFixEvent(UIEventDefine.UIHuaQuanForm_OPEN)
end

-- Receive rewards for boxing activities
-- message ResWorldBonfireReward
-- {
-- 	enum MsgID { eMsgID = 520103;};
-- }
function BonfireActivitySystem:GS2U_ResHQActivityReward(msg)
    self.IsReward = true
    Utils.ShowPromptByEnum("GetSuccess")
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_BONFIRE_HQ_REWARD)
end

-- Fist-making summary
-- message ResWorldBonfireFinger
-- {
-- 	enum MsgID { eMsgID = 520104;};
-- 	repeated Finger fingers = 1;
-- }
function BonfireActivitySystem:GS2U_ResSingleResult(msg)
    if msg.fingers then
        self:UpdatePlayerWine(msg)
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_BONFIRE_HQ_SINGLE_OVER, msg.fingers)
    end
end

-- Fist settlement
-- message ResWorldBonfireAllFinger
-- {
-- 	enum MsgID { eMsgID = 520105;};
-- required int32 res = 1; //1 Victory 2 Failed 3 draws
-- 	required int32 joinNum = 2; 
-- 	required int32 winNum = 3; 
-- 	optional bool isLeave =4;
-- }
function BonfireActivitySystem:GS2U_ResGameOver(msg)
    if msg then
        if msg.isLeave and not self.ReqExit then
            Utils.ShowPromptByEnum("OtherPlayerLeave")
        end
        self.HQWingProgress = msg.winNum
        self.HQJoinProgress = msg.joinNum
        self.HQGameResult = msg.res
        self.HQIsLeave = msg.isLeave
        self.HQGameOver = true
        if msg.winNum > self.HQWingTraget then
            self.HQWingProgress = self.HQWingTraget
        end
        if msg.joinNum > self.HQJoinTarget then
            self.HQJoinProgress = self.HQJoinTarget
        end
        if self.ReqExit then
            self.ReqExit = false
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_BONFIRE_EXIT_GAME)
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_BONFIRE_CANCEL_MATCH, true)
        else
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_BONFIRE_HQ_GAME_OVER, msg.res)
        end
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_BONFIRE_REFRESH_PANEL)
    end
    self.IsDraw = false;
end

-- Unmatch
-- message ResWorldBonfireCancelMatch
-- {
-- 	enum MsgID { eMsgID = 520106;};
-- required int32 res = 1; //1 Success 2 Failed (matched successfully)
-- }
function BonfireActivitySystem:GS2U_ResCancelMatch(msg)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_BONFIRE_CANCEL_MATCH)
end

-- Leave the event map
function BonfireActivitySystem:SendLeaveMapMsg()
    GameCenter.MapLogicSystem:SendLeaveMapMsg(false)
end

return BonfireActivitySystem
