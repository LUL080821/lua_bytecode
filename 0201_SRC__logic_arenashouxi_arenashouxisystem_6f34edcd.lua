------------------------------------------------
-- Author:
-- Date: 2019-05-28
-- File: ArenaShouXiSystem.lua
-- Module: ArenaShouXiSystem
-- Description: Chief Arena System
------------------------------------------------

local RedPointCustomCondition = CS.Thousandto.Code.Logic.RedPointCustomCondition;

local ArenaShouXiSystem = {
    -- Number of purchases
    BuyCount = 0, 
    IsWaiteSecKill = false,
    IsMiaoSha = false,
    WaiteTime = 3,
    WaiteTick = 0,
    LeftTime = 0,
}

local L_Sort = table.sort
local L_Tonumber = tonumber;
local L_SplitStr = Utils.SplitStr;
local L_Send = GameCenter.Network.Send;

-- integral
local L_Score = nil;
-- Ranking
local L_Rank = nil;
-- Number of remaining times
local L_RemainCount = nil;
-- Remaining CD time
local L_RemainCD = nil;
-- Challenge players
local L_FightPlayers = nil;
-- Record holder
local L_TopPlayers = nil;
-- Battle Record
local L_Reports = nil;
-- Yesterday's ranking
local L_YesterdayRank = nil;
-- Leave the arena map
local L_IsLevelArenaMap = nil;
-- Current target ID
local L_TargetID = nil;
-- Battle results
local L_BattleReport = nil;
-- Reset the remaining time for daily rankings
local L_RemainTimeByResetRank = nil;
-- First ranking reward
local L_FistRankAward = nil;
-- Data to be displayed for the first ranking
local L_ShowData = nil;
-- System initialization
function ArenaShouXiSystem:Initialize()
    L_Score = 0;
    L_Rank = 0;
    L_RemainCount = 0;
    L_RemainCD = 0;
end

-- System uninstall
function ArenaShouXiSystem:UnInitialize()
    L_Score = 0;
    L_Rank = 0;
    L_RemainCount = 0;
    L_RemainCD = 0;
    L_FightPlayers = nil;
    L_TopPlayers = nil;
    L_Reports = nil;
    L_YesterdayRank = nil;
    L_IsLevelArenaMap = false;
    L_TargetID = 0;
    L_BattleReport = nil;
end

-- Refresh the little red dots
function ArenaShouXiSystem:RefreshRedPoint()
    GameCenter.RedPointSystem:RemoveFuncCondition(FunctionStartIdCode.ArenaShouXi, 0)
    local _haveAward = false;
    if L_FistRankAward then
        local _curRank = L_FistRankAward.rank;
        local _awardList = L_FistRankAward.rewardList or {};
        DataConfig.DataJJCRank:Foreach(function(k, v)
            if k ~= 1 then
                if v.PosMax >= _curRank and _curRank ~= nil and _curRank ~= 0 and v.FirstRewardItem ~= ""  then
                    local isEqual = false
                    for i=1,#_awardList do
                        if v.Id == _awardList[i] then
                            isEqual = true
                        end
                    end
                    if not isEqual then
                        _haveAward = true
                    end
                end
            end
        end)
    end
    if _haveAward then
        GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.ArenaShouXi, 0, RedPointCustomCondition(true));
    end
end

-- Refreshing times small red dots
function ArenaShouXiSystem:RefreshCountRedPoint()
    GameCenter.RedPointSystem:RemoveFuncCondition(FunctionStartIdCode.ArenaShouXi, 1)
    if L_RemainCount > 0 then
        GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.ArenaShouXi, 1, RedPointCustomCondition(true));
    end
end

-- Refresh and buy small red dots
function ArenaShouXiSystem:RefreshBuyRedPoint()
    GameCenter.RedPointSystem:RemoveFuncCondition(FunctionStartIdCode.ArenaShouXi, 2)
    local totalBuyCount = GameCenter.VipSystem:GetCurVipPowerParam(23)
    if totalBuyCount > self.BuyCount then
        GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.ArenaShouXi, 2, RedPointCustomCondition(true));
    end
end

-- Get points
function ArenaShouXiSystem:GetScore()
    return L_Score;
end
-- Get rankings
function ArenaShouXiSystem:GetRank()
    return L_Rank;
end
-- Number of remaining times
function ArenaShouXiSystem:GetRemainCount()
    return L_RemainCount;
end
-- time left
function ArenaShouXiSystem:GetRemainCD()
    return L_RemainCD;
end
-- Challenge players
function ArenaShouXiSystem:GetFightPlayers()
    return L_FightPlayers;
end
-- Record holder
function ArenaShouXiSystem:GetTopPlayers()
    return L_TopPlayers;
end
-- Battle Record
function ArenaShouXiSystem:GetReports()
    return L_Reports;
end
-- Yesterday's ranking
function ArenaShouXiSystem:GetYesterdayRank()
    return L_YesterdayRank;
end
-- Leave the arena map
function ArenaShouXiSystem:IsLevelArenaMap()
    return L_IsLevelArenaMap;
end
-- Current target ID
function ArenaShouXiSystem:GetTargetID()
    return L_TargetID;
end

-- Get the combat power of challenging players
function ArenaShouXiSystem:GetFightPowerByTarget(targetId)
    if L_FightPlayers ~= nil then
        for i = 1, #L_FightPlayers do
            if L_FightPlayers[i].roleID == targetId then
                return L_FightPlayers[i].fightPower
            end
        end
    end
end

-- Battle results
function ArenaShouXiSystem:GetBattleReport()
    return L_BattleReport;
end

-- First ranking reward information
function ArenaShouXiSystem:GetFistRankAward()
    return L_FistRankAward
end

-- Get first reward display data
function ArenaShouXiSystem:GetShowData()
    if not L_ShowData then
        L_ShowData = List:New();
        DataConfig.DataJJCRank:Foreach(function(_, v)
            if v.FirstRewardItem and v.FirstRewardItem ~= "" and v.Id ~= 1 then
                local _item = {};
                _item.Config = v;
                _item.Id = v.Id
                _item.RewardState = self:GetAwardState(v.Id)
                _item.Awards = List:New();
                local _t = L_SplitStr(v.FirstRewardItem, ";_");
                for i=1,#_t, 2 do
                    _item.Awards:Add({tonumber(_t[i]),tonumber(_t[i+1])});
                end
                L_ShowData:Add(_item);
            end
        end)
    else
        for i = 1,#L_ShowData do
            L_ShowData[i].RewardState = self:GetAwardState(L_ShowData[i].Config.Id)
        end
    end
    -- Sort data
    L_ShowData:Sort(function(a,b) 
        return a.Config.PosMax > b.Config.PosMax
     end )
    for i = 1, #L_ShowData do
        for j = 1, #L_ShowData - i do
            if L_ShowData[j].RewardState > L_ShowData[j + 1].RewardState then
                local temp = L_ShowData[j + 1];
                L_ShowData[j + 1] = L_ShowData[j];
                L_ShowData[j] = temp;
            end
        end
    end
    return L_ShowData;
end

-- Get whether the reward has been received
function ArenaShouXiSystem:GetAwardState(id)
    if L_FistRankAward.rank == 0 then
        return ArenaSXFirstAwardEnum.None
    end
    if L_FistRankAward then
        local _cfg = DataConfig.DataJJCRank[id];
        local _curRank = L_FistRankAward.rank;
        if _cfg.PosMax < _curRank then
            return ArenaSXFirstAwardEnum.None;
        else
            local _awardList = L_FistRankAward.rewardList or {};
            for i=1,#_awardList do
                if _cfg.Id == _awardList[i] then
                    return ArenaSXFirstAwardEnum.Finish;
                end
            end
            return ArenaSXFirstAwardEnum.CanGet;
        end
    end
    return ArenaSXFirstAwardEnum.None;
end

function ArenaShouXiSystem:Update(dt)
    if self.IsWaiteSecKill then
        if self.WaiteTick<self.WaiteTime then
            self.WaiteTick = self.WaiteTick + dt
        else
            self.IsWaiteSecKill = false
            self.WaiteTick = 0
        end
    end
end

--====[msg]====[msg]====[msg]====[msg]====[msg]====[msg]====[msg]====[msg]====[msg]====[msg]====[msg]====[msg]====[msg]====

--================[Req]================[Req]================[Req]================[Req]================[Req]================
-- Open jjc
function ArenaShouXiSystem:ReqOpenJJC()
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN, DataConfig.DataMessageString.Get("ArenaLoadingTips"));
    L_Send("MSG_JJC.ReqOpenJJC");
end

-- Replace opponent
function ArenaShouXiSystem:ReqChangeTarget()
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN, DataConfig.DataMessageString.Get("ArenaLoadingTips"));
    L_Send("MSG_JJC.ReqChangeTarget");
end

-- challenge
function ArenaShouXiSystem:ReqChallenge(targetID, isSecKill)
    if L_RemainCount <= 0 then
        Utils.ShowPromptByEnum("CountNotEnough")
    else
        --uint64 targetID
        if isSecKill then
            self.IsWaiteSecKill = true
            self.WaiteTick = 0
        end
        L_Send("MSG_JJC.ReqChallenge",{targetID = targetID, seckill = isSecKill});
    end
end

-- Receive the award
function ArenaShouXiSystem:ReqGetAward()
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN);
    L_Send("MSG_JJC.ReqGetAward");
end

-- Added challenges
function ArenaShouXiSystem:ReqAddChance()
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN);
    L_Send("MSG_JJC.ReqAddChance");
end

-- Get yesterday's ranking
function ArenaShouXiSystem:ReqGetYesterdayRank()
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN);
    L_Send("MSG_JJC.ReqGetYesterdayRank");
end

-- Get the war report
function ArenaShouXiSystem:ReqGetReport()
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN);
    L_Send("MSG_JJC.ReqGetReport");
end

-- Exit jjc
function ArenaShouXiSystem:ReqJJCexit()
    if GameCenter.GameSceneSystem.ActivedScene.MapId == 8000 then
        GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN);
        L_Send("MSG_JJC.ReqJJCexit");
    else
        --GameCenter.PushFixEvent(UIEventDefine.UIArenaShouXiForm_Close);
	end;
end

-- Request one-click swipe
function ArenaShouXiSystem:ReqOneKeySweep()
    L_Send("MSG_JJC.ReqOneKeySweep");
end

-- Get first ranking rewards
function ArenaShouXiSystem:ReqGetFirstReward(excelId)
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN);
    L_Send("MSG_JJC.ReqGetFirstReward",{excelId = excelId})
end

--================[Res]================[Res]================[Res]================[Res]================[Res]================
-- Open the arena UI interface to obtain information
function ArenaShouXiSystem:ResOpenJJCresult(msg)
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
    L_Rank = msg.rank;
    L_RemainCount = msg.count;
    L_RemainCD = msg.cd;
    L_Score = msg.score;
    self:RefreshCountRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_JJC_UPDATECOUNT);

    L_FightPlayers = List:New(msg.players);
    L_TopPlayers = List:New(msg.rank123);
    -- Sort
    L_FightPlayers:Sort(function(a,b)
            return a.rank>b.rank
        end);
     L_TopPlayers:Sort(function(a,b)
            return a.rank>b.rank
        end);
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_JJC_UPDATEPLAYERS);
end

-- Updated challenges, ranking
function ArenaShouXiSystem:ResUpdateChance(msg)
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
    L_Rank = msg.rank;
    L_RemainCount = msg.count;
    L_RemainCD = msg.cd;
    self:RefreshCountRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_JJC_UPDATECOUNT);
end

-- Replace the challenger
function ArenaShouXiSystem:ResUpdatePlayers(msg)
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
    L_FightPlayers = List:New(msg.players);
    L_TopPlayers = List:New(msg.rank123);
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_JJC_UPDATEPLAYERS);
end

-- Return to yesterday's ranking
function ArenaShouXiSystem:ResYesterdayRank(msg)
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
    L_YesterdayRank = msg.rank;
    L_RemainTimeByResetRank = msg.time;
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_JJC_UPDATEYESTERDAY_RANK,msg.rank);
end

-- Return to the battle report data
function ArenaShouXiSystem:ResReports(msg)
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
    L_Reports = List:New(msg.reports);
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_JJC_RECORDUPDATE);
end

-- Arena Notification
function ArenaShouXiSystem:ResJJCTargetID(msg)
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
    L_TargetID = msg.targetID;
end

-- Checkout interface
function ArenaShouXiSystem:ResJJCBattleReport(msg)
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
    L_BattleReport = msg;
    L_Score = L_Score + msg.score;
    L_Rank = msg.curRank;
    -- Close the countdown interface
    GameCenter.PushFixEvent(UIEventDefine.UIArenaSXCountdownForm_Close)
    if self.IsMiaoSha then
        self.IsMiaoSha = false
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_JJC_MIAOSHA_RESULT)
    else
        GameCenter.PushFixEvent(UIEventDefine.UIArenaSXResultForm_OPEN)
    end
end

-- Send jjc prompt information online
function ArenaShouXiSystem:ResOnlineJJCInfo(msg)
    L_RemainCount = msg.r_count;
    self:RefreshCountRedPoint()
end
-- Challenge starts to return
function ArenaShouXiSystem:ResStartBattleRes(msg)
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
    -- Close the interface
    GameCenter.PushFixEvent(UIEventDefine.UIArenaForm_Close);
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_JJC_FIGHTSTART)
end

-- Rewards for the first time
function ArenaShouXiSystem:ResGetFirstReward(msg)
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
    L_FistRankAward = msg;
    ArenaShouXiSystem:RefreshRedPoint();
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_JJC_UPDATECOUNT);
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_JJC_FIRSTAWARD);
end

function ArenaShouXiSystem:ResBuyJJCTimes(msg)
    self.BuyCount = msg.buyTimes
    self:RefreshBuyRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_JJC_UPDATECOUNT)
end

return ArenaShouXiSystem;
