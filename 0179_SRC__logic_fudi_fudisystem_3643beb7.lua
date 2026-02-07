------------------------------------------------
-- Author:
-- Date: 2019-05-10
-- File: FuDiSystem.lua
-- Module: FuDiSystem
-- Description: Blessed Land System
------------------------------------------------
-- Quote
local GuildRankData = require "Logic.FuDi.FuDiGuildRankData"
local FuDiPreviewData = require "Logic.FuDi.FuDiPreviewData"
local FuDiBossShowData = require "Logic.FuDi.FuDiBossShowData"
local FuDiDuoBaoCopyInfo = require "Logic.FuDi.FuDiDuoBaoCopyInfo"
local FuDiLunJian = require "Logic.FuDi.LunJianData"
local FuDiLunJianCopyData = require "Logic.FuDi.LunJianCopyData"
local TimeUtils = CS.Thousandto.Core.Base.TimeUtils;
local L_RoleBaseAttribute = CS.Thousandto.Code.Global.RoleBaseAttribute
local FuDiSystem = {
    PreviewData = nil,
    BossShowData = nil,
    DuoBaoCopyInfo = nil,
    -- Anger value
    Anger = 0,
    -- The boss ID currently clicked
    CurSelectBossId = 0,
    RankList = List:New(),
    GuildRankList = List:New(),
    PersonRankList = List:New(),
    -- {Id = Blessed ID, IsAllDead = Whether all deaths are dead, Time = all deaths}
    ListBornData = List:New(),
    -- All refresh times for the boss of the blessed land
    ListBornTime = List:New(),
    -- {Id = Blessed ID, ShowPoint = Whether to display red dots}
    ListMenuRedPoint = List:New(),

    -- Whether the current function displays red dots
    IsShowRedPoint = false,
    -- The currently entered blessed land ID
    EnterFuDiId = nil,
    -- What day is the current server opening
    OpenServeDay = 1,
    -- Current server opening time stamp
    OpenServeTime = 0,
    --
    PrevHour = 0,
    -- Countdown to the red dot on the first day of service opening
    RedPointTick = 0,
    -- When will the server be closed?
    CloseDay = 7,
    -- Is the function enabled?
    IsFuncOpen = false,
    -- Fudi Support Configuration Table ID
    HelpCfgId = 0,
    -- The bossID being attacked
    AttBossId = 0,
    AtkBossUId = 0,
    ListScore = List:New(),
    -- Following list
    ListGuanZhu = List:New(),
    -- Does the player have a union
    IsHaveGuild = false,
    -- Previous Player Union ID
    PrevGuildId = 0,
    -- My union ranking
    MyGuildRank = 0,
    -- My ranking
    MyRank = 0,
    -- Receive reward list
    ListRewarded = List:New(),

    CanSetLittleNil = true,
    -- Number of days of service
    ServeOpenTime = 0,
    -- Detailed data
    DetailDataList = List:New(),

    -- Blessed Swordsmanship Data
    LunJianData = nil,
    -- Blessed Sword Contest Data
    LunJianCopyData = nil,
    -- Whether to open the swordsman copy interface
    IsShowLjCopyForm = false,
    -- Have you checked the special effects display of unassigned blessed land?
    IsCheckEffectShow = false,
    FpTimeList = nil,
    StartSec = 0,
}

function FuDiSystem:Initialize()
    self.ListBornData:Clear()
    for i = 1, 4 do
        local tab = {
            Id = i,
            IsAllDead = false,
            Time = 0
        }
        self.ListBornData:Add(tab)
    end
    -- Initialize boss refresh time
    self.ListBornTime:Clear()
    local cfg = DataConfig.DataGlobal[GlobalName.GuildBattleBoss_refresh_cd]
    if cfg ~= nil then
        local list = Utils.SplitStr(cfg.Params, ';')
        if list ~= nil then
            for i = 1, #list do
                local time = tonumber(list[i]) / 60
                if time == 0 then
                    time = 24
                end
                self.ListBornTime:Add(time)
            end
        end
    end

    self.ListBornTime:Sort(function(a, b)
        return a < b
    end)

    self.ListMenuRedPoint:Clear()
    for i = 1, 4 do
        local tab = {
            Id = i,
            ShowPoint = false
        }
        self.ListMenuRedPoint:Add(tab)
    end
    -- Calculate the day when the server is opened
    local gCfg = DataConfig.DataGlobal[GlobalName.Guild_blessing_time]
    if gCfg ~= nil then
        self.CloseDay = tonumber(gCfg.Params)
    end
    self.IsShowFun = true

    -- Add timer
    self.TimerEventId = GameCenter.TimerEventSystem:AddTimeStampHourEvent(2, 3600, true, nil,
                            function(id, remainTime, param)
                                self:UpdateRedPoint()
        end)
    self.TimerID = GameCenter.TimerEventSystem:AddTimeStampDayEvent(10, 86400,
    true, nil, function(id, remainTime, param)
        self:InitSec()
    end)
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_GUILD_LEAVE, self.OnPlayerGuildChange, self)
    GameCenter.RegFixEventHandle(LogicLuaEventDefine.EID_EVENT_GUILD_BASEINFOCHANGE_UPDATE, self.OnPlayerGuildChange, self)
end

function FuDiSystem:UnInitialize()
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_GUILD_LEAVE, self.OnPlayerGuildChange, self)
    GameCenter.UnRegFixEventHandle(LogicLuaEventDefine.EID_EVENT_GUILD_BASEINFOCHANGE_UPDATE, self.OnPlayerGuildChange, self)
end

function FuDiSystem:InitSec()
    local _serverTime = math.floor( GameCenter.HeartSystem.ServerZoneTime )
    local _hour, _min, _sec = TimeUtils.GetStampTimeHHMMSSNotZone(_serverTime)
    local _curSec = _hour * 3600 + _min * 60 + _sec
    self.StartSec = GameCenter.HeartSystem.ServerZoneTime - _curSec
end

function FuDiSystem:OnEnterScene()
    if not self.IsCheckEffectShow then
        local _openDay = Time.GetOpenSeverDay()
        local _isShowEffect = false
        if _openDay > 1 then
            _isShowEffect = false
        else
            _isShowEffect = true
        end
        GameCenter.MainFunctionSystem:SetFunctionEffect(FunctionStartIdCode.FuDi, _isShowEffect)
        self.IsCheckEffectShow = true
    end
end

function FuDiSystem:SetServerOpenTime(time)
    self.ServeOpenTime = math.floor(time / 1000)
    -- self:CheckFuncVisible()
end

function FuDiSystem:CheckFunction(isOpen)
    self:CheckFuncVisible(isOpen)
end

function FuDiSystem:CheckFuncVisible(isOpen)
    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.FuDi, isOpen)
    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.FuDiRank, isOpen)
    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.FuDiLj, isOpen)
    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.FuDiBoss, isOpen)
    self.IsFuncOpen = isOpen
    if isOpen then
        self:UpdateRedPoint()
    end
end

function FuDiSystem:OnPlayerGuildChange(obj, sender)
    if self.IsHaveGuild and not GameCenter.GuildSystem:HasJoinedGuild() then
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FUDI_OWNCHAGE)
    end
    self.IsHaveGuild = GameCenter.GuildSystem:HasJoinedGuild()

    -- Detect red dots
    if self.IsHaveGuild then
        -- Update the death status of the boss in Fudi
        -- self:UpdateBornList()
        -- Detect red dots
        self:UpdateRedPoint()
    end
end

function FuDiSystem:BoxIsRecived(score)
    local b = false
    for i = 1, #self.PreviewData.ReceivedList do
        if self.PreviewData.ReceivedList[i] == score then
            b = true
        end
    end
    return b
end

-- Obtain the current Fudi Occupy Union ID
function FuDiSystem:GetGuildID()
    -- GameCenter.FuDiSystem.CurSelectBossId
    local cfg = DataConfig.DataGuildBattleBoss[GameCenter.FuDiSystem.CurSelectBossId]
    if cfg ~= nil then
        if self.PreviewData ~= nil then
            if cfg.Group <= #self.PreviewData.ReMainList then
                return self.PreviewData.ReMainList[cfg.Group].GuildId
            end
        end
    end
    return 0
end

-- Get refresh time
function FuDiSystem:GetRefreashTime()
    local hour, min, sec = TimeUtils.GetStampTimeHHMMSS(math.floor(GameCenter.HeartSystem.ServerTime))
    local curSeconds = hour * 3600 + min * 60 + sec
    if self.ListBornTime ~= nil then
        local list = List:New()
        for m = 1, #self.ListBornTime do
            local time = self.ListBornTime[m] * 3600
            if time >= curSeconds then
                list:Add(self.ListBornTime[m])
            end
        end
        list:Sort(function(a, b)
            return a < b
        end)
        if #list > 0 then
            return list[1] * 3600 - curSeconds
        end
    end
    return 0
end

-- Get the server opening time
function FuDiSystem:GetOpenServerTime()
    -- Time passed now
    local passTime = math.floor(GameCenter.HeartSystem.ServerTime - self.OpenServeTime)
    -- What time is the day when the server is launched
    local hour, min, sec = TimeUtils.GetStampTimeHHMMSS(math.floor(self.OpenServeTime))
    local openSeconds = hour * 3600 + min * 60 + sec
    -- The first day of the server is from early morning
    local disTime = 24 * 3600 - openSeconds
    local openTime = 0
    if passTime < disTime then
        openTime = 1
    else
        local realTime = passTime - disTime
        openTime = math.floor(realTime / (24 * 3600)) + 2
    end
    return openTime
end

function FuDiSystem:Update(dt)
    -- local _serverTime = GameCenter.HeartSystem.ServerTime
    -- local hour, min, sec = TimeUtils.GetStampTimeHHMMSS(math.floor(_serverTime))
    -- local curSeconds = hour * 3600 + min * 60 + sec
    -- local diffSec = 10 * 3600 - curSeconds

    -- if self.ServeOpenTime ~= 0 then
    --     if Time.GetFrameCount() % 10 == 0 then
    --         if self.ServeOpenTime == 2 and diffSec >=0 then
    --             if diffSec > 3600  then
    --                 local strTime = UIUtils.CSFormat(DataConfig.DataMessageString.Get("FUDISYSTEM_TISHI_1"), math.floor(diffSec / 3600))
    --                 GameCenter.MainFunctionSystem:SetFunctionLittleName(FunctionStartIdCode.FuDi, strTime)
    --             elseif diffSec > 60  then
    --                 local strTime = UIUtils.CSFormat(DataConfig.DataMessageString.Get("FUDISYSTEM_TISHI_2"),math.floor(diffSec / 60))
    --                 GameCenter.MainFunctionSystem:SetFunctionLittleName(FunctionStartIdCode.FuDi, strTime)
    --             else
    --                 local strTime = UIUtils.CSFormat(DataConfig.DataMessageString.Get("FUDISYSTEM_TISHI_3"),diffSec)
    --                 GameCenter.MainFunctionSystem:SetFunctionLittleName(FunctionStartIdCode.FuDi, strTime)
    --             end
    --             self.CanSetLittleNil = true
    --         else
    --             if self.CanSetLittleNil then
    --                 GameCenter.MainFunctionSystem:SetFunctionLittleName(FunctionStartIdCode.FuDi, "")
    --                 self.CanSetLittleNil = false
    --             end
    --         end
    --     end
    -- end
end

function FuDiSystem:UpdateBornList()
    for i = 1, #self.ListBornData do
        if self.ListBornData[i].IsAllDead then
            -- If all bosses die
            -- Check if the boss is refreshed
            -- GameCenter.HeartSystem.ServerTime
            local hour, min, sec = TimeUtils.GetStampTimeHHMMSS(math.floor(GameCenter.HeartSystem.ServerTime))
            local dHour, dMin, dSec = TimeUtils.GetStampTimeHHMMSS(math.floor(self.ListBornData[i].Time))
            local curSeconds = hour * 3600 + min * 60 + sec
            local bornTime = 0
            for m = 1, #self.ListBornTime do
                if self.ListBornTime[m] > dHour then
                    -- Take out the next resurrection time
                    bornTime = self.ListBornTime[m]
                    break
                end
            end
            -- If the time now is greater than the time of resurrection
            -- if hour == 0 and dHour > 0 then
            --     hour = 24
            -- end
            if hour >= bornTime then
                self.ListBornData[i].IsAllDead = false
                self.ListBornData[i].Time = 0
            end
        end
    end
end

function FuDiSystem:UpdateRedPoint()
    local have = self:CheckRdPoint()
    if self.IsShowRedPoint ~= have then
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.FuDiBoss, have)
        self.IsShowRedPoint = have
    end
end

-- Check the red dots
function FuDiSystem:CheckRdPoint()
    local isAlive = false
    local openTime = self:GetOpenServerTime()
    if openTime == 1 then
        local hour = TimeUtils.GetStampTimeHH(math.floor(GameCenter.HeartSystem.ServerTime))
        if hour < 24 then
            return false
        end
    end
    -- Determine whether the player has a union
    local lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if lp ~= nil then
        if lp.GuildID == 0 then
            -- The player does not show red dots if he does not join the union
            if self.ListMenuRedPoint ~= nil then
                for i = 1, #self.ListMenuRedPoint do
                    self.ListMenuRedPoint[i].ShowPoint = false
                end
            end
            isAlive = false
        else
            -- Players have joined the union to determine whether the union in which the player is located ranks in the top 3
            local rankId = -1
            if self.PreviewData ~= nil then
                if self.PreviewData.ReMainList ~= nil then
                    for i = 1, #self.PreviewData.ReMainList do
                        if self.PreviewData.ReMainList[i].GuildId == lp.GuildID then
                            rankId = i
                        end
                    end
                    if rankId ~= -1 then
                        -- Top 3 Players' Union
                        -- Judge the first 3 blessed places
                        if self.PreviewData ~= nil then
                            for k = 1, #self.PreviewData.ReMainList do
                                if self.PreviewData.ReMainList[k].GuildId ~= lp.GuildID then
                                    -- If the player does not belong to the blessed land
                                    -- Determine whether all bosses in the current blessed land are dead
                                    if self.ListBornData ~= nil then
                                        if self.ListBornData[k].IsAllDead then
                                            if self.ListMenuRedPoint ~= nil and k <= #self.ListMenuRedPoint then
                                                self.ListMenuRedPoint[k].ShowPoint = false
                                            end
                                        else
                                            if k ~= 4 then
                                                if self.ListMenuRedPoint ~= nil and k <= #self.ListMenuRedPoint then
                                                    self.ListMenuRedPoint[k].ShowPoint = true
                                                end
                                                if not isAlive then
                                                    isAlive = true
                                                end
                                            end
                                        end
                                    end
                                else
                                    self.ListMenuRedPoint[k].ShowPoint = false
                                end
                            end
                        end
                        if self.ListMenuRedPoint ~= nil and 4 <= #self.ListMenuRedPoint then
                            self.ListMenuRedPoint[4].ShowPoint = false
                        end
                    else
                        for i = 1, #self.ListMenuRedPoint do
                            self.ListMenuRedPoint[i].ShowPoint = false
                        end
                        -- Only trade unions that are not the top three will judge the fourth blessed land
                        if self.ListBornData ~= nil then
                            if self.ListBornData[4].IsAllDead then
                                -- All the bosses in this blessed land have died
                                if self.ListMenuRedPoint ~= nil and 4 <= #self.ListMenuRedPoint then
                                    self.ListMenuRedPoint[4].ShowPoint = false
                                end
                            else
                                if self.ListMenuRedPoint ~= nil and 4 <= #self.ListMenuRedPoint then
                                    self.ListMenuRedPoint[4].ShowPoint = true
                                end
                                if not isAlive then
                                    isAlive = true
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return isAlive
end

function FuDiSystem:GetProcessParam()
    local ret = nil
    local Score = 0
    local leftScore = 0
    local index = 1
    local lastKey = 0
    DataConfig.DataGuildBattleScore:ForeachCanBreak(function(k, v)
        if self.PreviewData.CurScore >= leftScore and self.PreviewData.CurScore < k and ret == nil then
            ret = {
                LeftScore = leftScore,
                Score = k,
                Index = index
            }
        end
        leftScore = k
        index = index + 1
        lastKey = k
    end)
    if leftScore ~= 0 and ret == nil then
        ret = {
            LeftScore = leftScore,
            Score = lastKey,
            Index = index
        }
    end
    return ret
end

function FuDiSystem:GetTotalScore()
    local lastKey = 0
    DataConfig.DataGuildBattleScore:ForeachCanBreak(function(k, v)
        lastKey = k
    end)
    return lastKey
end

function FuDiSystem:CanEnter(id)
    local _ret = false
    local _openDay = Time.GetOpenSeverDay()
    if _openDay > 1 then
        local _guildId = 0
        local lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if lp ~= nil then
            _guildId = lp.GuildID
        end
        if _guildId == 0 then
            Utils.ShowPromptByEnum("GUILD_BATTLE_entryprompt3")
        else
            local _isFind = false
            if self.PreviewData ~= nil then
                if self.PreviewData.ReMainList ~= nil then
                    for i = 1, #self.PreviewData.ReMainList do
                        local _reMain = self.PreviewData.ReMainList[i]
                        if _reMain ~= nil and _reMain.GuildId == _guildId then
                            _isFind = true
                            break
                        end
                    end
                end 
            end
            if _isFind then
                -- Top three players union
                if id ~= 4 then
                    _ret = true
                else
                    Utils.ShowPromptByEnum("GUILD_BATTLE_entryprompt2")
                end
            else
                -- Players' union does not rank in the top three
                if id == 4 then
                    _ret = true
                else
                    Utils.ShowPromptByEnum("GUILD_BATTLE_entryprompt1")
                end
            end
        end
    else
        Utils.ShowPromptByEnum("guide_not_open_motice")
    end
    return _ret
end

function FuDiSystem:GetFpTimes()
    if self.FpTimeList == nil then
        self.FpTimeList = List:New()
        --GuildBattleBoss_Openingtime
        local _cfg = DataConfig.DataGlobal[GlobalName.GuildBattleBoss_Openingtime]
        if _cfg ~= nil then
            local _list = Utils.SplitNumber(_cfg.Params, '_')
            for i = 1, #_list do
                self.FpTimeList:Add(_list[i])
            end
        end
    end
    return self.FpTimeList
end

function FuDiSystem:GetFpLeftTime()
    local _ret = 0
    local _list = self:GetFpTimes()
    local _curSec = GameCenter.HeartSystem.ServerZoneTime - self.StartSec
    local _isFind = false
    local _openDay = Time.GetOpenSeverDay()
    for i = 1, #_list do
        if _openDay > 1 and i == 1 then
        else
            local _sec = _list[i] * 60
            if _curSec < _sec then
                _ret = _sec - _curSec
                _isFind = true
                break
            end
        end
    end
    if not _isFind then
        if _openDay <= 1 then
            _ret = 24* 3600 - _curSec + _list[1] * 60
        end
    end
    return _ret
end

---------------------msg----------------------
-- Request to open the title ranking
function FuDiSystem:ReqOpenRankPanel()
    GameCenter.Network.Send("MSG_GuildActivity.ReqOpenRankPanel")
end
-- Request to open the boss of the blessed land
function FuDiSystem:ReqOpenAllBossPanel()
    GameCenter.Network.Send("MSG_GuildActivity.ReqOpenAllBossPanel")
end
-- Request for daily points rewards
function FuDiSystem:ReqDayScoreReward(id)
    GameCenter.Network.Send("MSG_GuildActivity.ReqDayScoreReward", {
        id = id
    })
end
-- Request to open the details of the boss sect in Fudi
function FuDiSystem:ReqOpenDetailBossPanel(fuDiIndex)
    GameCenter.Network.Send("MSG_GuildActivity.ReqOpenDetailBossPanel", {
        type = fuDiIndex
    })
end
-- Request to follow boss type = 1 Follow = 2 Unfollow
function FuDiSystem:ReqAttentionMonster(id, type)
    GameCenter.Network.Send("MSG_GuildActivity.ReqAttentionMonster", {
        monsterModelId = id,
        type = type
    })
end
-- Request to open the treasure hunt UI
function FuDiSystem:ReqSnatchPanel()
    GameCenter.Network.Send("MSG_GuildActivity.ReqSnatchPanel")
end
-- Request for treasure hunt copy data
function FuDiSystem:ReqPanelReady()
    GameCenter.Network.Send("MSG_GuildActivity.ReqPanelReady")
end
-- Request details
function FuDiSystem:ReqMyFightingBoss()
    GameCenter.Network.Send("MSG_GuildActivity.ReqMyFightingBoss")
end

-- Return to the Fudi Title Panel Data
function FuDiSystem:ResOpenRankPanel(result)
    self.RankList:Clear()
    if result.guildRank ~= nil then
        for i = 1, #result.guildRank do
            local guildRankInfo = GuildRankData:New(result.guildRank[i])
            self.RankList:Add(guildRankInfo)
        end
    end
    self.MyGuildRank = result.myGuildRank
    self.MyRank = result.myRank
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_FUDIRANKFORM)
end

-- Return to the total data of the blessed land
function FuDiSystem:ResOpenAllBossPanel(result)
    if result == nil then
        return
    end
    if self.PreviewData == nil then
        self.PreviewData = FuDiPreviewData:New(result)
    else
        self.PreviewData:SetData(result)
    end
    if self.BossShowData == nil then
        self.BossShowData = FuDiBossShowData:New(result)
    end
    self.ListScore:Clear()
    self.ListGuanZhu:Clear()
    if result.infos ~= nil then
        for i = 1, #result.infos do
            self.BossShowData:SetData(result.infos[i])
            self.ListScore:Add(result.infos[i].score)
        end
    end
    -- Update to receive the award list
    self.ListRewarded:Clear()
    if result.rewards ~= nil then
        for i = 1, #result.rewards do
            self.ListRewarded:Add(result.rewards[i])
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FUDIBOSS_ZONGLAN_UPDATE)
end

-- Return to the details of the boss sect in Fudi
-- function FuDiSystem:ResOpenDetailBossPanel(result)
--     if result == nil then
--         return
--     end
--     if self.BossShowData == nil then
--         self.BossShowData = FuDiBossShowData:New(result)
--     end
--     self.BossShowData:SetData(result)
--     GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FUDIBOSS_INFO_UPDATE)
-- end

-- Return to the Blessed Land to receive the prize
function FuDiSystem:ResDayScoreReward(result)
    if result.success then
        -- Notify the client to close the preview interface for award collection
        if not self.ListRewarded:Contains(result.id) then
            self.ListRewarded:Add(result.id)
        end
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_SCOREREWARD, result.id)
    end
end
--
function FuDiSystem:ResUpdateMonsterResurgenceTime(result)
    if result == nil then
        return
    end
    if result.state == 1 then
        GameCenter.PushFixEvent(UIEventDefine.UIFuDiCopyInfoForm_Open, result)
    else
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FUDIBOSS_INFO_UPDATE, result)
    end
end
-- Return to follow monster id
function FuDiSystem:ResAttentionMonster(result)
    if result == nil then
        return
    end
    -- local bossData = self.BossShowData:GetBossById(result.attention)
    -- if bossData ~= nil then
    --     if result.type == 1 then
    --         bossData.IsAttention = true
    --     elseif result.type ==2 then
    --         bossData.IsAttention = false
    --     end
    -- end
    -- Update your follower list
    self:UpdateAttionList(result.attention, result.type)
end
-- Update your follower list
function FuDiSystem:UpdateAttionList(cfgId, type)
    if type == 1 then
        -- focus on
        if not self.ListGuanZhu:Contains(cfgId) then
            self.ListGuanZhu:Add(cfgId)
        end
    else
        -- Unfollow
        local index = 0
        for i = 1, #self.ListGuanZhu do
            if self.ListGuanZhu[i] == cfgId then
                index = i
                break
            end
        end
        if index ~= 0 then
            self.ListGuanZhu:RemoveAt(index)
        end
    end
end
-- The monster you follow has been refreshed
function FuDiSystem:ResAttentionMonsterRefresh(result)
    if result == nil then
        return
    end
    local monsterId = 0
    local cfg = DataConfig.DataGuildBattleBoss[result.monsterModelId]
    if cfg == nil then
        return
    end
    local cloneId = cfg.MapID
    local _openDay = Time.GetOpenSeverDay()
    -- Set monster id
    local _monsterStrList = Utils.SplitStr(cfg.MonsterID,';')
    if _monsterStrList ~= nil then
        for i = 1, #_monsterStrList do
            local _strList = Utils.SplitNumber(_monsterStrList[i], '_')
            if _strList ~= nil then
                if #_strList >= 2 then
                    if _strList[1] == _openDay then
                        monsterId = _strList[2]
                        break
                    end
                end
            end
        end
    end
    GameCenter.PushFixEvent(UIEventDefine.UIBossInfoTips_OPEN, {monsterId, cloneId, result.monsterModelId, 12})
end
-- Synchronous Rage Value
function FuDiSystem:ResSynAnger(result)
    if result == nil then
        return
    end
    self.Anger = result.anger
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FUDIBOSS_INFO_UPDATE)
end
-- Synchronous wave count and remaining monster count
function FuDiSystem:ResSynMonster(result)
    if result == nil then
        return
    end
    if self.DuoBaoCopyInfo == nil then
        self.DuoBaoCopyInfo = FuDiDuoBaoCopyInfo:New()
    end
    self.DuoBaoCopyInfo:SetData(result)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_FUDIDUOBAO_COPYINFO)
end
-- Synchronous damage ranking
function FuDiSystem:ResSynHarmRank(result)
    if result == nil then
        return
    end
    if result.rank ~= nil then
        self.DuoBaoCopyInfo:SetDamage(result)
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_FUDIDUOBAO_COPYINFO)
end
-- Return to the single treasure hunt panel a
function FuDiSystem:ResSnatchPanel(result)
    if result == nil then
        return
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_FUDIDUOBAO, result.guildScore)
end
-- Return to the damage ranking of the boss dungeon
function FuDiSystem:ResHarmData(result)
    if result == nil then
        return
    end
    self.GuildRankList:Clear()
    self.PersonRankList:Clear()
    for i = 1, #result.guildHarmData do
        self.GuildRankList:Add(result.guildHarmData[i])
    end
    for i = 1, #result.personHarmData do
        self.PersonRankList:Add(result.personHarmData[i])
    end
    -- bossModelId
    self.AttBossId = result.bossModelId
    self.AtkBossUId = result.bossUid
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FUDIBOSS_INFO_UPDATE, 99)
end

-- Server red dot notification
function FuDiSystem:ResRedPointInfo(result)
    if result == nil then
        return
    end

    for i = 1, #self.ListBornData do
        local data = self.ListBornData[i]
        data.IsAllDead = true
    end

    if result.type ~= nil then
        for i = 1, #result.type do
            self.ListBornData[result.type[i]].IsAllDead = false
        end
    end

    -- Detect red dots
    self:UpdateRedPoint()
end

function FuDiSystem:ResFudiCanHelp(result)
    if result == nil then
        return
    end
    if result.canHelp then
        -- If support is possible
        self.HelpCfgId = result.cfgId
        local _bossCfg = DataConfig.DataGuildBattleBoss[result.cfgId]
        local cloneId = _bossCfg.MapID
        local mapId = DataConfig.DataCloneMap[cloneId].Mapid
        local _curMapId = GameCenter.MapLogicSystem.MapId
        if mapId == _curMapId then
            -- If you go directly in the Immortal Alliance Blessing Land
            local monsterId = self.BossShowData:GetBossById(self.HelpCfgId).MonterId
            local list = Utils.SplitStr(_bossCfg.Pos, '_')
            local pos = Vector2(tonumber(list[1]), tonumber(list[2]))
            GameCenter.PathSearchSystem:SearchPathToPosBoss(true, pos, monsterId)
        else
            -- Enter the copy
            GameCenter.DailyActivitySystem:ReqJoinActivity(207, cloneId)
        end
    else
        -- Support failed
        Utils.ShowPromptByEnum("FUDISYSTEM_TISHI_4")
    end
end

function FuDiSystem:ResQuitTip(result)
    if result == nil then
        return
    end
    local des = nil
    if result.reason == 1 then
        des = "FUDISYSTEM_TISHI_5"
    elseif result.reason == 2 then
        des = "FUDISYSTEM_TISHI_6"
    elseif result.reason == 3 then
        des = "FUDISYSTEM_TISHI_7"
    end
    Utils.ShowMsgBoxAndBtn(function(code)
        if code == MsgBoxResultCode.Button2 then
            -- Leave the copy
            -- GameCenter.MapLogicSystem:SendLeaveMapMsg(false)
        end
    end, nil, "C_MSGBOX_OK", des)
end

-- Trade union ranking changes
function FuDiSystem:ResGuildRankChange(result)
    if result == nil then
        return
    end
    if result.info ~= nil then
        for i = 1, #result.info do
            if self.PreviewData ~= nil then
                self.PreviewData:UpdateReMain(result.info[i], i)
            end
        end
    end
    -- Debug.LogError("Received union change message sent by the server")
    -- Update the death status of the boss in Fudi
    -- self:UpdateBornList()
    -- Updated red dots once
    self:UpdateRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FUDI_OWNCHAGE)
end

-- Return to details
function FuDiSystem:ResMyFightingBoss(result)
    if result == nil then
        return
    end
    self.DetailDataList:Clear()
    if result.boss ~= nil then
        for i = 1, #result.boss do
            local info = result.boss[i]
            if info ~= nil then
                local data = {
                    CfgId = info.configId,
                    Level = info.level,
                    Hp = info.hp,
                    Type = info.type
                }
                self.DetailDataList:Add(data)
            end
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FUDI_DETAIL_INFO)
end

-- =================================================================================================================

-- Get the swordsman data
function FuDiSystem:GetLunJianData()
    if self.LunJianData == nil then
        self.LunJianData = FuDiLunJian:New()
    end
    return self.LunJianData
end

-- Get data on the sword contest
function FuDiSystem:GetLunJianCopyData()
    if self.LunJianCopyData == nil then
        self.LunJianCopyData = FuDiLunJianCopyData:New()
    end
    return self.LunJianCopyData
end

-- Request a winning streak (the client requests it every certain time)
function FuDiSystem:ReqGuildLastBattleRoleKill()
    GameCenter.Network.Send("MSG_GuildActivity.ReqGuildLastBattleRoleKill")
end

-- The countdown to the sword contest begins
function FuDiSystem:ResGuildLastBattleTimeCalc(msg)
    if msg == nil then
        return
    end
    local _data = self:GetLunJianCopyData()
    if _data ~= nil then
        _data:SetReadyTime(msg.time)
    end
end

-- War report
function FuDiSystem:ResGuildLastBattleReport(msg)
    if msg == nil then
        return
    end
    local _data = self:GetLunJianCopyData()
    if _data == nil then
        return
    end
    if msg.fud ~= nil then
        for i = 1, #msg.fud do
            _data:SetFuDiRank(msg.fud[i])
        end
    end
    if msg.roles ~= nil then
        for i = 1, #msg.roles do
            _data:SetPersonRank(msg.roles[i])
        end
    end
    if not self.IsShowLjCopyForm then
        -- Open the copy interface
        GameCenter.PushFixEvent(UILuaEventDefine.UIFuDiLjCopyForm_OPEN)
    else
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FUDI_LUNJIAN_ZHANBAO)
    end
end

-- Winning in a row
function FuDiSystem:ResGuildLastBattleRoleKill(msg)
    if msg == nil then
        return
    end
    local _data = self:GetLunJianCopyData()
    if _data == nil then
        return
    end
    _data:SetZhanJiData(msg)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FUDI_LUNJIAN_ZHANJI)
end

-- Broadcasting wins
function FuDiSystem:ResGuildLastBattleKill(msg)
    if msg == nil then
        return
    end
    local _data = self:GetLunJianCopyData()
    if _data == nil then
        return
    end
    _data:SetShowTitleData(msg)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FUDI_LUNJIAN_BROADCAST)
end

-- Sword settlement
function FuDiSystem:ResGuildLastBattleGameOver(msg)
    if msg == nil then
        return
    end
    local _data = self:GetLunJianCopyData()
    if _data == nil then
        return
    end
    _data:SetResultData(msg)
end

return FuDiSystem
