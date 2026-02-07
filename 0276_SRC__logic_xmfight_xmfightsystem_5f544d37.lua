-- Author: 
-- Date: 2020-02-18
-- File: XmFightSystem.lua
-- Module: XmFightSystem
-- Description: 1. This system is: Immortal Alliance War System, and it is also associated with the system: Immortal Alliance War Duplicate
-- 2. The panels are: UIXmFightForm (XianmZbCopyForm), UIXmTongJiForm (Xianm Statistical Interface), UIXmRankForm (Shengs List Interface), UIXmJieSuanForm (Reward Settlement Interface), (UIXmZbCopyForm) Xianmeng Competition Copy Interface
------------------------------------------------
local XmRateInfo = require("Logic.XmFight.XmRateInfo");
local XmRewardInfo = require("Logic.XmFight.XmRewardInfo");
local XmRewardBoxInfo = require("Logic.XmFight.XmRewardBoxInfo");
local XmFightRecordInfo= require("Logic.XmFight.XmFightRecordInfo");
local XmJieSuanInfo= require("Logic.XmFight.XmJieSuanInfo");
local XmFightPreviewRewardInfo= require("Logic.XmFight.XmFightPreviewRewardInfo");
local TimeUtils = CS.Thousandto.Core.Base.TimeUtils;

local XmFightSystem = 
{
    -- Ratings for all fairy alliances
    XmRateDict = nil,
    -- Already rated
    IsHasRated = nil,
    -- My Fairy Alliance Rating
    MeXmRateInfo = nil,
    -- Settlement data
    JieSuanInfo = nil,
    -- Data of the Investiture of the Gods (ranking list) [kill ranking (order), data]
    XmRankMemInfoList = nil,

    -- Immortal Alliance Reward List
    --XmRewardList = nil,
    -- Personal Reward List
    --PersonRewardList = nil,

    -- Winning reward dictionary
    LSRewardList = nil,
    -- End Reward Dictionary
    ZJRewardList = nil,

    -- Lianshengxian Alliance ID
    LSXmID = "",
    -- The name of Liansheng Immortal Alliance
    LSXmName = "",
    -- Number of times of winning the Immortal Alliance
    LSXmCount = 1,
    -- Winning reward type
    LSXmRewardType = 0,

    -- The ending object of the immortal alliance
    ZJXmName = "",
    -- The number of consecutive victories ended in the Immortal Alliance
    ZJXmCount = 1,

    -- Immortal Alliance Statistics List
    XmFightRecordList = nil,

    -- Definition of the pathfinding status of players in the Immortal Alliance Contest
    FindPathState = XmFightFindPath.Default,
    -- The city gate ID currently headed to repair
    RepareDoorId = 0,
    -- The ID of the current attack gate
    AttDoorId = 0,
    -- 0: Attack 1: Defensive
    Camp = 0,
    -- Whether to defend the city gate
    IsDefDoor = false,
    -- Whether to click on the God Rider
    IsClickChange = false,
    -- Whether to click to block the fix
    IsStopRepair = false,
    -- Message cache
    CopyMsgCache = List:New(),
    -- Quick chat data
    -- {Id = index, Des = "chat content"}
    ChatList1 = List:New(),
    ChatList2 = List:New(),
    -- Kill title data
    TitleTime = 3,
    TitleTick = 0,
    --{Killer = {HeadId , Occ},CfgId,Killed = {HeadId , Occ}}
    KillTitleList = List:New(),
    -- Whether to show red dots in a row
    IsLSRedPoint = false,
    -- Checked item information
    JieSuanItemList = nil,
    -- Personal Rewards
    OwnJieSuanItemList = nil,
    -- Whether to prepare for the stage
    IsReady = false,

    -- Preview reward list
    PreviewRewardList = nil,
}

-- Here is the definition of evaluation
local L_XM_RATE_TYPE = {DataConfig.DataMessageString.Get("XMFIGHT_SYSTEM_TISHI_1"),DataConfig.DataMessageString.Get("XMFIGHT_SYSTEM_TISHI_2"),DataConfig.DataMessageString.Get("XMFIGHT_SYSTEM_TISHI_3"),DataConfig.DataMessageString.Get("XMFIGHT_SYSTEM_TISHI_4")}

-- Quick Chat Definition
local L_CHAT_DES_1 = {DataConfig.DataMessageString.Get("XMFIGHT_SYSTEM_TISHI_5"),DataConfig.DataMessageString.Get("XMFIGHT_SYSTEM_TISHI_6"),DataConfig.DataMessageString.Get("XMFIGHT_SYSTEM_TISHI_7"),DataConfig.DataMessageString.Get("XMFIGHT_SYSTEM_TISHI_8"),
DataConfig.DataMessageString.Get("XMFIGHT_SYSTEM_TISHI_9"),DataConfig.DataMessageString.Get("XMFIGHT_SYSTEM_TISHI_10")}
local L_CHAT_DES_2 = {DataConfig.DataMessageString.Get("XMFIGHT_SYSTEM_TISHI_other_5"),DataConfig.DataMessageString.Get("XMFIGHT_SYSTEM_TISHI_other_6"),DataConfig.DataMessageString.Get("XMFIGHT_SYSTEM_TISHI_other_7"),DataConfig.DataMessageString.Get("XMFIGHT_SYSTEM_TISHI_other_8"),
DataConfig.DataMessageString.Get("XMFIGHT_SYSTEM_TISHI_other_9"),DataConfig.DataMessageString.Get("XMFIGHT_SYSTEM_TISHI_other_10")}

-- Immortal Alliance War Relief Definition: The number of surviving city gates corresponding to
local L_DISDAMAGE = {25,30,45}

-- Weekly timer ID
local L_WeekTipsTimerID = 0
local L_WeekTipsIconID = 0
local L_WeekOpenTimerID = 0
local L_WeekOpenIconID = 0

function XmFightSystem:Initialize()
    self.XmRateDict = Dictionary:New()    
    for i = 1,#L_XM_RATE_TYPE do
        self.XmRateDict[i] = List:New();
    end    
    --self.XmRewardList =nil;
    --self.PersonRewardList = nil;
    self.PreviewRewardList = nil;
    
    self.LSRewardList = nil;
    self.ZJRewardList = nil;
    self.XmRankMemInfoList = List:New();
    self.XmFightRecordList = List:New();
    self.IsHasRated = false;
    -- Initialize the chat
    self.ChatList1:Clear()
    for i = 1,#L_CHAT_DES_1 do
        local tab = {Id = i, Des = L_CHAT_DES_1[i] }
        self.ChatList1:Add(tab)
    end
    self.ChatList2:Clear()
    for i = 1,#L_CHAT_DES_2 do
        local tab = {Id = i, Des = L_CHAT_DES_2[i] }
        self.ChatList2:Add(tab)
    end
end

function XmFightSystem:UnInitialize()
    self.XmRateDict = nil;
    --self.XmRewardList =nil;
    --self.PersonRewardList = nil;
    self.PreviewRewardList = nil;
    
    self.LSRewardList = nil;
    self.ZJRewardList = nil;
    self.XmRankMemInfoList = nil;
    self.XmFightRecordList = nil;
end

-- Get damage-free value
function XmFightSystem:GetDisDamage(aliveCount)
    if aliveCount <= #L_DISDAMAGE then
        if aliveCount == 0 then
            return 0
        end
        return L_DISDAMAGE[aliveCount]
    end
    return 0
end

-- Get the list of immortal alliances
function XmFightSystem:GetXmListWithRate(rateType)
    if self.XmRateDict  == nil then
        self.XmRateDict = Dictionary:New()    
        for i = 1,#L_XM_RATE_TYPE do
            self.XmRateDict[i] = List:New();
        end
    end
    return self.XmRateDict[rateType];
end

-- Get the Immortal Alliance rating type name
function XmFightSystem:GetXmRateTypeName(rateType)    
    if rateType >=1 and rateType <= #L_XM_RATE_TYPE then       
        return L_XM_RATE_TYPE[rateType]
    else
       return DataConfig.DataMessageString.Get("XMFIGHT_SYSTEM_TISHI_11")
    end
end

-- Get reward preview information
function XmFightSystem:GetRewardPreview(worldLevel)
    if self.PreviewRewardList == nil then        
        local lp = GameCenter.GameSceneSystem:GetLocalPlayer() 
        if lp then
            self.PreviewRewardList = List:New();
            DataConfig.DataGuildWarRewardpreview:Foreach(
                function(k,v)
                    local _wlArr = Utils.SplitNumber(v.WorldLevel, "_");
                    local _grArr = XmRewardInfo:ParseStr(v.GuildReward,lp.Occ);
                    local _prArr = XmRewardInfo:ParseStr(v.PersonalReward,lp.Occ);
                    self.PreviewRewardList:Add(XmFightPreviewRewardInfo:New(_wlArr[1],_wlArr[2],_grArr,_prArr));
                end
            );
             -- Sort processing
            XmFightPreviewRewardInfo:SortList(self.PreviewRewardList);
        end
       
    end
    if self.PreviewRewardList then
        -- Judging by world level
        for i = 1,#self.PreviewRewardList do
            if self.PreviewRewardList[i].StartLevel <= worldLevel and self.PreviewRewardList[i].EndLevel >= worldLevel then
                return self.PreviewRewardList[i];
            end
        end
    end
    return nil;
end

--[[
-- Get the reward list of Xianlian
function XmFightSystem:GetXmRewardItemList()
    
    if self.XmRewardList == nil then
        local lp = GameCenter.GameSceneSystem:GetLocalPlayer() 
        if lp then
            self.XmRewardList = XmRewardInfo:ParseStr(DataConfig.DataGlobal[1754].Params,lp.Occ);
        end
    end
    return self.XmRewardList;
end

-- Get a personal reward list
function XmFightSystem:GetPersonRewardItemList()
    if self.PersonRewardList == nil then
        local lp = GameCenter.GameSceneSystem:GetLocalPlayer() 
        if lp then
            self.PersonRewardList = XmRewardInfo:ParseStr(DataConfig.DataGlobal[1755].Params,lp.Occ);
        end
    end
    return self.PersonRewardList;
end
]]
-- Get a winning streak reward
function XmFightSystem:GetLSRewardItemList()
    if self.LSRewardList == nil then
        local lp = GameCenter.GameSceneSystem:GetLocalPlayer() 
        if lp then
            self.LSRewardList = List:New();        
            DataConfig.DataGuildWarReward:Foreach(
                function(k,v)
                    local _l = XmRewardInfo:ParseStr(v.ShowContinueReward,lp.Occ);
                    local _t = XmRewardBoxInfo:New(k,v.Count,_l,UIUtils.CSFormat(DataConfig.DataMessageString.Get("XMFIGHT_SYSTEM_TISHI_12"),v.Count),0,0);
                    self.LSRewardList:Add(_t);                    
                end
            );
        end
    end
    return self.LSRewardList;
end

-- Get the Final Reward
function XmFightSystem:GetZJRewardItemListBySort()
    if self.ZJRewardList == nil then
        local lp = GameCenter.GameSceneSystem:GetLocalPlayer() 
        if lp then
            self.ZJRewardList = List:New();        
            DataConfig.DataGuildWarReward:Foreach(
                function(k,v)
                    local _l = XmRewardInfo:ParseStr(v.ShowEndReward,lp.Occ);
                    local _t = XmRewardBoxInfo:New(k,v.Count,_l,DataConfig.DataMessageString.Get("C_HUODEJIANGLI"),0,1);
                    self.ZJRewardList:Add(_t);        
                end
            );
            -- Arranged from large to small
            self.ZJRewardList:Sort(function(x,y) return x.Count > y.Count end);
        end

    end
    return self.ZJRewardList;
end


-- Get the Immortal Alliance Statistics List
function XmFightSystem:GetXmRecordList()
    return self.XmFightRecordList;
end

-- Clean up the list of immortal alliance records
function XmFightSystem:ClearXmRecordList()
    if self.XmFightRecordList ~= nil then
        self.XmFightRecordList:Clear();
    end
end


-- Can you receive a winning streak reward
-- And I am the leader or deputy leader of the Immortal Alliance where I am, and I can get it.
function XmFightSystem:CanGetLSReward(type)    
    if type == self.LSXmRewardType then
        local _gInfo = GameCenter.GuildSystem.GuildInfo;
        if _gInfo then
            -- No matter which reward is, the current winning Immortal Alliance will win
            if _gInfo.name == self.LSXmName
            and (GameCenter.GuildSystem:IsChairman()
            or GameCenter.GuildSystem.Rank == GuildOfficalType.ViceChairman)
            then
                return true;
            end
        end
    end
    return false; 
end

-- Determine whether it is between the rating and the end of the battle
function XmFightSystem:IsBetweenActive()
    local startTime = 0
    local endTime = 0
    local _serverTime = GameCenter.HeartSystem.ServerTime + GameCenter.HeartSystem.ServerZoneOffset
    local hour = TimeUtils.GetStampTimeHHNotZone(math.floor(_serverTime))
	local min = TimeUtils.GetStampTimeMMNotZone(math.floor(_serverTime))
    local sec = TimeUtils.GetStampTimeSSNotZone(math.floor(_serverTime))
    local curSeconds = hour * 3600 + min * 60 + sec
    local dCfg = DataConfig.DataDaily[110]
    -- Calculate the end time
    if dCfg ~= nil then
        local list = Utils.SplitStr(dCfg.Time,'_')
        if list ~= nil then
            startTime = tonumber(list[1]) / 60 - 1
            endTime = tonumber(list[2]) /60
        end
        startTime = startTime * 3600
        endTime = endTime * 3600
        if curSeconds >= startTime and  curSeconds <= endTime then
            -- During active period
            return true
        end
    end
    return false
end

-- Determine whether it is on the battlefield
function XmFightSystem:JudgeInFight()
    local isFight = true
    if self.XmFightRecordList ~= nil then
        for i = 1,#self.XmFightRecordList do
            if self.XmFightRecordList[i].IsWin then
                isFight = false
            end
        end
    end
    return isFight
end

-- Is the winning streak showing a red dot?
function XmFightSystem:ShowLSRedPoint()
    local _list =nil;
    if self.LSXmRewardType ==0 then
        _list = self:GetLSRewardItemList();
    else
        self.IsLSRedPoint = false
        return false
    end
    -- Do a winning streak red dot test
    local havePoint = false
    for i = 1,#_list do
        if not havePoint then
            havePoint = _list[i]:EnableGet()
        else
            break
        end
    end
    self.IsLSRedPoint = havePoint
    return havePoint
end

-- Updated service time
function XmFightSystem:SetOpenServerTime(serverOpenTime)
    self.ServerOpenTime = math.floor(serverOpenTime / 1000) + GameCenter.HeartSystem.ServerZoneOffset
end

function XmFightSystem:GetOpeUI(data)
    local _openUICfg = Utils.SplitStr(data.CustomData.OpenUI, "_")
    local _param = _openUICfg[2] and tonumber(_openUICfg[2]) or nil;
    return tonumber(_openUICfg[1]) , _param
end

-- Heartbeat
function XmFightSystem:Update(dt)
    -- if self.TitleTick > 0 then
    --     self.TitleTick = self.TitleTick - dt
    -- else
    --     self.TitleTick = 0
    --     if #self.KillTitleList > 0 then
    -- --If there is data, get the first data
    --         local data = self.KillTitleList[1]
    -- --Close the title interface first
    --         GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_XMCOPY_HIDETITLE)
    -- --The notification interface displays title
    --         GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_XMCOPY_SHOWTITLE,data)
    -- --Delete this data and enter the heartbeat countdown
    --         self.KillTitleList:RemoveAt(1)
    --         self.TitleTick = self.TitleTime
    --     end
    -- end
end

-- ============================================--

-- ===============================================--

-- List of evaluations for the Immortal Alliance in the Battle of Immortal Alliance
function XmFightSystem:ReqGuildBattleRateList()  
    GameCenter.Network.Send("MSG_GuildBattle.ReqGuildBattleRateList",{});
end

-- Request list of the Immortal Alliance battle record
function XmFightSystem:ReqGuildBattleRecordList()  
    GameCenter.Network.Send("MSG_GuildBattle.ReqGuildBattleRecordList",{});
end

-- Request for the Immortal Alliance to win in a row
function XmFightSystem:ReqGuildBattleRecordWin()  
    GameCenter.Network.Send("MSG_GuildBattle.ReqGuildBattleRecordWin",{});   
end

-- Receive a final or winning streak reward
-- grade: Get the grade
function XmFightSystem:ReqGuildBattleRecordReward(grade)  
    GameCenter.Network.Send("MSG_GuildBattle.ReqGuildBattleRecordReward",{id = grade});
end

-- Request to return to the city
function XmFightSystem:ReqGuildBattleBack(grade)  
    GameCenter.Network.Send("MSG_GuildBattle.ReqGuildBattleBack",{});
end

-- Request a like
-- likeRoleId: Liked character ID
function XmFightSystem:ReqGuildBattleLike(likeRoleId)  
    GameCenter.Network.Send("MSG_GuildBattle.ReqGuildBattleLike",{roleId = likeRoleId});
end

-- Request results
function XmFightSystem:ReqGuildBattleResult()  
    GameCenter.Network.Send("MSG_GuildBattle.ReqGuildBattleResult",{});
end

-- Request statistics (the same as the list in the game, the returned data structure is the same)
function XmFightSystem:ReqGuildBattleStat()  
    GameCenter.Network.Send("MSG_GuildBattle.ReqGuildBattleStat",{});
end

-- Barrage news
function XmFightSystem:ReqSendBulletScreen(t, ty)
    GameCenter.Network.Send("MSG_GuildBattle.ReqSendBulletScreen",{context = t, type = ty});
end

-- Enter the battlefield
function XmFightSystem:EnterFightScene()
    -- Determine whether the player has a team
    if GameCenter.TeamSystem:IsTeamExist() then
        -- If there is a team, a prompt pops up
        Utils.ShowMsgBox(function (code)
            if (code == MsgBoxResultCode.Button2) then
                local lp = GameCenter.GameSceneSystem:GetLocalPlayer()
                if lp ~= nil then
                    GameCenter.TeamSystem:ReqTeamOpt(lp.ID, 3)
                    GameCenter.DailyActivitySystem:ReqJoinActivity(110,0);
                end
            end
        end, "XMFIGHT_SYSTEM_TISHI_13")
    else
        --todo
        GameCenter.DailyActivitySystem:ReqJoinActivity(110,0); 
    end
end
-- =================================================--

-- ================================================--

-- Get the evaluation list of the Immortal Alliance in the Immortal Alliance Battle
function XmFightSystem:GS2U_ResGuildBattleRateList(msg)
    -- Clean up old data
    self.XmRateDict:Foreach(function(k,v)
        v:Clear();
    end);
    -- My Immortal Alliance Information Initialization
    local _meGuildName = nil;
    if GameCenter.GuildSystem.GuildInfo then
        _meGuildName = GameCenter.GuildSystem.GuildInfo.name;
    end
    
    self.MeXmRateInfo = nil;
    
    -- Fill in new data
    local _list = msg.rateList;
    if _list ~= nil then
        for i = 1, #_list do
            local _item = XmRateInfo:New(_list[i]);
            -- After the data conversion is saved correctly
            if _item then
                local _tmp = self.XmRateDict[_item.Type];
                if not _tmp then
                    _tmp = List:New();
                self.XmRateDict[_item.Type]= _tmp;    
                end
                _tmp:Add(_item);

                -- Assign values to your gang
                if self.MeXmRateInfo == nil then
                    -- Determine whether your own gang
                    if _item.Name == _meGuildName then
                        self.MeXmRateInfo = _item;
                    end
                end
            end
        end
        self.XmRateDict:Foreach(function(k,v)
            XmRateInfo:SortList(v);
        end);
        -- Already rated
        self.IsHasRated = #_list > 0;
    end
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_XM_RATE_LIST);
end

-- List of Immortal Alliance Contest Results
function XmFightSystem:GS2U_ResGuildBattleRecordList(msg)   
    -- Fill in new data
    self.XmFightRecordList = XmFightRecordInfo:Parse(msg.recordList,self.XmFightRecordList);
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_XM_RECORD_LIST);
end

-- The Immortal Alliance wins in a row
function XmFightSystem:GS2U_ResGuildBattleWin(msg)
    self.LSXmID = msg.guildId;
    self.LSXmName = msg.guildName;
    self.LSXmRewardType = msg.type;
    if msg.type == 0 then  
        -- A winning streak is issued
        local _list = self:GetLSRewardItemList();
        for _,v in ipairs(_list) do
            local _b = (1<<(v.CfgID-1));
            if msg.hasGet & _b == _b then
                v.State = 1;
            else 
                v.State = 0; 
            end
        end

        -- Reset the ending reward state
        _list = self:GetZJRewardItemListBySort();
        for _,v in ipairs(_list) do
            v.State = 0;
        end

        -- If it is a winning streak reward, then it means there is no end reward.
        self.LSXmCount = msg.num;
        self.ZJXmCount = msg.num;
        self.ZJXmName =  msg.guildName;
    elseif msg.type == 1 then  
        -- The final reward is issued
        local _list = self:GetZJRewardItemListBySort();
        for _,v in ipairs(_list) do
            if msg.hasGet == v.CfgID then
                v.State = 1;
            else 
                v.State = 0; 
            end
        end
        -- Reset the reward status of winning streak
        _list = self:GetLSRewardItemList();
        for _,v in ipairs(_list) do
            v.State = 0;
        end
        -- If it is a final reward, the default number of wins is 1.
        self.LSXmCount = 1;
        self.ZJXmCount = msg.num;
        self.ZJXmName =  msg.beguildName;
    else
        Debug.LogError("XmFightSystem:GS2U_ResGuildBattleWin:type = "..tostring(msg.type));
    end
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_XM_LSREWARD_LIST);
end

-- Receive a final or winning streak reward
function XmFightSystem:GS2U_ResGuildBattleRecordReward(msg)
    local _list =nil;
    if self.LSXmRewardType ==0 then
        _list = self:GetLSRewardItemList();
    else
        _list = self:GetZJRewardItemListBySort();
    end

    local _dat = nil;
    for _,v in ipairs(_list) do        
        if msg.id == v.CfgID then
            v.State = 1;  
            _dat = v;      
        end
    end
    if _dat == nil then
        Debug.LogError("XmFightSystem:GS2U_ResGuildBattleRecordReward: No reward for the current level was found:" .. msg.id);
    else
        GameCenter.PushFixEvent(UIEventDefine.UIWelfareGetItemForm_OPEN,_dat.ItemList,{FormName = _dat.Desc});
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_XM_LSREWARD_LIST);
    end
    local havePoint = self:ShowLSRedPoint()
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.GuildWar,havePoint) 
end

-- Immortal Alliance Battle Panel Information
function XmFightSystem:GS2U_ResGuildBattlePanel(msg)
    self.CopyMsgCache:Add(msg)
end

-- Faction conversion
function XmFightSystem:GS2U_ResGuildBattleTranCamp(msg)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_CHANGEATTACK_XM, msg)
end

-- Like Return
function XmFightSystem:GS2U_ResGuildBattleLike(msg)

end

-- Return information after the Immortal Alliance Battle
function XmFightSystem:GS2U_ResGuildBattleEnd(msg)
    local _records = msg.records
    self.XmRankMemInfoList:Clear()
    if _records and #_records > 0 then
        for i = 1, #_records do
            self.XmRankMemInfoList:Add(_records[i])
        end
        -- Sort by kill ranking
        self.XmRankMemInfoList:Sort(
            function (a, b)
                -- Sort by points
                return a.record > b.record
            end
        )
        -- Pop up the Xianmeng auction prompt interface
        GameCenter.PushFixEvent(UILuaEventDefine.UIXmAuctionTipsForm_OPEN)
        -- Popup checkout interface
        GameCenter.PushFixEvent(UILuaEventDefine.UIXmRankForm_OPEN)
    end
    self.JieSuanItemList = msg.items
    self.OwnJieSuanItemList = msg.personal
end

-- Immortal Alliance Battle Results Information
function XmFightSystem:GS2U_ResGuildBattleResult(msg)
    self.JieSuanInfo = XmJieSuanInfo:New(msg)
    -- Pop up reward settlement interface
    GameCenter.PushFixEvent(UILuaEventDefine.UIXmJieSuanForm_OPEN)
    -- Updated winning streak red dots
    local _list = self:GetZJRewardItemListBySort();
    if msg.res == 1 then
        -- Ended
        self.IsLSRedPoint = false
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.GuildWar,false) 
    end
end

-- Winning red dots
function XmFightSystem:ResGuildBattleRedPoint(msg)
    if msg == nil then
        return
    end
    self.IsLSRedPoint = msg.redPoint
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.GuildWar,msg.redPoint) 
end

-- Kill information
function XmFightSystem:ResGuildBattleKillNum(msg)
    if msg == nil then
        return
    end
    local tab = {
        CfgId = msg.cfgId,
        Killer = {
            RoleID = msg.attId,
            Head = msg.attHead,
            Occ = msg.attCareer,
            Name = msg.attName,
        },
        Killed = {
            RoleID = msg.defId,
            Head = msg.defHead,
            Occ = msg.defCareer,
            Name = msg.defName,
        }
    }
    self.KillTitleList:Add(tab)
end

-- Received the call message from the server
function XmFightSystem:ResGuildBattleCall(msg)
    if GameCenter.MapLogicSystem.MapCfg.MapId == 72001 then
        return
    end
    Utils.ShowMsgBox(function(code)
		if code == MsgBoxResultCode.Button2 then
			-- If the player prompts in the dungeon, he cannot go to the dungeon.
			if GameCenter.MapLogicSystem.MapCfg.Type == UnityUtils.GetObjct2Int(MapTypeDef.Copy) then

				-- The player is prompted to exit the dungeon before going to
                Utils.ShowPromptByEnum("XMFIGHT_SYSTEM_TISHI_15")
				return
			end
			-- If the player dies, it prompts that the player is currently in a dead state and cannot go to
			local lp = GameCenter.GameSceneSystem:GetLocalPlayer()
			if lp ~= nil then
				if lp:IsDead() then
					-- If the player dies
                    Utils.ShowPromptByEnum("XMFIGHT_SYSTEM_TISHI_16")
					return
				end
			end
			if GameCenter.GameSceneSystem.ActivedScene.MapId == 72001 then
				-- If in the Immortal Alliance Battle
				return
            end
            self:EnterFightScene() 
        end
    end, "XMFIGHT_SYSTEM_TISHI_14", msg.name)
end

-- Collection update
function XmFightSystem:ResGuildBattleGatherUpdate(msg)
    if msg == nil then
        return
    end
    
end

-- Experience update
function XmFightSystem:ResGuildBattleExp(msg)
    if msg == nil then
        return
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_XMFIGHT_EXP_UPDATE, msg.expReward)
end

-- Barrage news
function XmFightSystem:ResSendBulletScreen(msg)
    if msg == nil then
        return
    end
    local _text = ""
    if msg.type == 0 then
        _text = DataConfig.DataMessageString.Get("Marry_DanMu_MaoHao", msg.roleName, msg.context)     
        GameCenter.PushFixEvent(UIEventDefine.UIBulletChatForm_OPEN, _text)
    elseif msg.type == 1 then
        _text = DataConfig.DataMessageString.Get("C_PRAISE_CHAT_TISHI_0", msg.roleName)
        GameCenter.PushFixEvent(UIEventDefine.UIBulletChatForm_OPEN, {Text = _text, UIRegion = UIFormRegion.TopRegion})
    elseif msg.type == 2 then
        _text = DataConfig.DataMessageString.Get("C_PRAISE_CHAT_TISHI_1", msg.roleName)
        GameCenter.PushFixEvent(UIEventDefine.UIBulletChatForm_OPEN, {Text = _text, UIRegion = UIFormRegion.TopRegion})
    elseif msg.type == 3 then
        _text = DataConfig.DataMessageString.Get("C_PRAISE_CHAT_TISHI_2", msg.roleName)
        GameCenter.PushFixEvent(UIEventDefine.UIBulletChatForm_OPEN, {Text = _text, UIRegion = UIFormRegion.TopRegion})
    end
end
-- ===============================================--
-- =============================================--


return XmFightSystem
