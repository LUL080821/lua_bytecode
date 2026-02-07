------------------------------------------------
-- Author:
-- Date: 2021-03-01
-- File: GuildSystem.lua
-- Module: GuildSystem
-- Description: Immortal Alliance System
------------------------------------------------
local L_BaseInfo = require("Logic.Guild.GuildBaseInfo")
local L_LogInfo = require("Logic.Guild.GuildLogData")
local L_MemberInfo = require("Logic.Guild.GuildMemberInfo")
local GuildSystem = {
    -- Is the current Immortal Alliance entering the top three combat powers?
    IsEnterRank = false,
    -- Whether the interface is created is open, it is used to have a mark after creating a guild to determine whether the interface is to be closed and the main interface of the guild is opened.
    IsCreateFormOpen = false,
    -- Job information int
    Rank = 0,
    -- Is it an agent leader?
    IsProxy = false,
    -- Current ranking of players among sects
    MyRankNum = 1,
    -- Can you get offline time?
    CanGetOfflineExpTime = false,
    -- Recommended guild list and search list to use the same data
    GuildRecommentList = List:New(),
    -- Guild basic information
    GuildInfo = nil,
    -- Guild Member Information
    GuildMemberList = List:New(),
    -- Guild application list information
    GuildApplyList = List:New(),
    -- Guild log data
    GuildLogList = List:New(),
    -- Building grade
    BuildLvDic = Dictionary:New(),
    -- Among the members, number of people in each position
    OfficalNumDic = Dictionary:New(),
    -- Treasure Box Data
    BoxDataList = List:New(),
    -- Treasure chest record data
    BoxLogList = List:New(),
    -- Number of treasure chests available
    BoxNum = 0,
    -- Red envelope log list
    RedPackageLogList = List:New(),
    -- Red envelope list
    RedPackageDic = Dictionary:New(),
}

function GuildSystem:Initialize()
    self.MyRankNum = 1
    self.BoxNum = 0
end

function GuildSystem:UnInitialize()
end

-- Heartbeat
function GuildSystem:Update(deltaTime)
    if self:HasJoinedGuild() and self.GuildInfo.recruitCd > 0 then
        self.GuildInfo.recruitCd = self.GuildInfo.recruitCd - deltaTime;
        if (self.GuildInfo.recruitCd < 0) then
            self.GuildInfo.recruitCd = 0;
        end
    end
    if self.BoxUpdate then
        self.BoxUpdate = false
        for i = 1, #self.BoxDataList do
            if self.BoxDataList[i].RemainTime > 0 then
                self.BoxUpdate = true
                self.BoxDataList[i].RemainTime = self.BoxDataList[i].RemainTime - deltaTime
            end
        end
    end
    if self.RedPackageUpdate then
        self.RedPackageUpdate = false
        self.RedPackageDic:ForeachCanBreak(function(k, v)
            if v.RemainTime > 0 then
                self.RedPackageUpdate = true
                v.RemainTime = v.RemainTime - deltaTime
            end
        end)
    end
    return true;
end
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Member list sorting Official position, contribution, online status
function GuildSystem:OnSortMemberList()
    if (#self.GuildMemberList == 0) then
        return;
    end

    self.GuildMemberList:Sort(function(x, y)
        if (x.RankNum ~= y.RankNum) then
            return x.RankNum < y.RankNum;
        else
            return x.fighting > y.fighting;
        end
    end);
    self.OfficalNumDic:Clear();
    for i = 1, #self.GuildMemberList do
        if (self.OfficalNumDic:ContainsKey(self.GuildMemberList[i].rank)) then
            self.OfficalNumDic[self.GuildMemberList[i].rank] = self.OfficalNumDic[self.GuildMemberList[i].rank] + 1;
        else
            self.OfficalNumDic:Add(self.GuildMemberList[i].rank, 1);
        end
    end
end

function GuildSystem:OnSortGuildList()
    self.GuildRecommentList:Sort(function(x, y)
        return x.fighting > y.fighting
    end);
end
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function GuildSystem:OnOpenPanel(index)
    if (self:HasJoinedGuild()) then
        GameCenter.PushFixEvent(UIEventDefine.UIGuildNewForm_OPEN);
    else
        GameCenter.PushFixEvent(UIEventDefine.UICreateGuildForm_OPEN);
    end
end

function GuildSystem:OnGetGuildOfficial()
    if self.IsProxy then
        return DataConfig.DataGuildOfficial[GuildOfficalType.Chairman]
    end
    if self:HasJoinedGuild() then
        return DataConfig.DataGuildOfficial[self.Rank]
    end
    return nil;
end

-- Is there any permission to upgrade building?
function GuildSystem:IsCanBuildUp()
    if self:HasJoinedGuild() then
        local item = self:OnGetGuildOfficial();
        if item then
            return item.CanUp == 1;
        end
    end
    return false;
end

-- Check the red dot on the settings main button
function GuildSystem:CheckMainGuildBtnRedPoint()
    -- No guild, display the red dot of the guild button on the main interface
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.Guild, not self:HasJoinedGuild());
end

-- Have you joined the guild
function GuildSystem:HasJoinedGuild()
    return self.GuildInfo and self.GuildInfo.guildId ~= 0;
end

-- Get a job title
function GuildSystem:OnGetOfficalString(rank, isP)
    if isP then
        return DataConfig.DataMessageString.Get("C_GUILD_OFFICAL_DAILI");
    end
    local config = DataConfig.DataGuildOfficial[rank]
    if config then
        return config.Name
    end
    return nil;
end

-- - Calculate offline time according to the time difference of server issuance. 0 means online, and the unit is seconds
function GuildSystem:OnGetOnlineStateStr(time)
    if (time == 0) then
        return DataConfig.DataMessageString.Get("C_GUILD_STATE_ONLINE");
    elseif (time > 0 and time < 3600) then
        local num = math.floor(time / 60)
        if (num == 0) then
            num = 1;
        end
        return DataConfig.DataMessageString.Get("C_GUILD_STATE_OUTLINE_HOUR", num);
    elseif (time >= 3600 and time < 86400) then
        return DataConfig.DataMessageString.Get("C_GUILD_STATE_OUTLINE_HOUR1", math.floor(time / 3600));
    elseif(time >= 86400) then
        return DataConfig.DataMessageString.Get("C_GUILD_STATE_OUTLINE_HOUR2", 1);
    end
    return "";
end

-- Get the number of online players
function GuildSystem:OnGetOnLineNum()
    local index = 0;
    for i = 1, #self.GuildMemberList do
        if (self.GuildMemberList[i].lastOffTime == 0) then
            index = index + 1
        end
    end
    return index;
end

-- Get the application list ID
function GuildSystem:OnGetApplyIdList()
    local list = List:New()
    if #self.GuildApplyList > 0 then
        for i = 1, #self.GuildApplyList do
            list:Add(self.GuildApplyList[i].roleId);
        end
    end
    return list;
end

-- Determine whether it can be upgraded
function GuildSystem:OnChargeCanUp(currentType)
    if (not self:OnChargeMoney(currentType)) then
        return false;
    end
    if not self:OnChargeBuild(currentType) then
        return false;
    end
    return true;
end

-- Determine whether the gang funds are sufficient
function GuildSystem:OnChargeMoney(currentType)
    if not self:IsCanBuildUp() or not self.BuildLvDic:ContainsKey(currentType) then
        return false;
    end
    local guildLv = self.BuildLvDic[currentType];
    local item = DataConfig.DataGuildUp[currentType * 10000 + guildLv]
    local _cfg = nil;
    if (self.BuildLvDic:ContainsKey(1)) then
        _cfg = DataConfig.DataGuildUp[10000 + self.BuildLvDic[1]]
    end
    if (item == nil or _cfg == nil) then
        return false;
    end
    if (self.GuildInfo.guildMoney < item.NeedNum + _cfg.MaintenanceFund or item.NeedNum == 0) then
        return false;
    end
    return true;
end

-- Determine whether the gang building meets the upgrade needs
function GuildSystem:OnChargeBuild(currentType)
    if (not self:IsCanBuildUp() or not self.BuildLvDic:ContainsKey(currentType)) then
        return false;
    end
    local guildLv = self.BuildLvDic[currentType];
    local item = DataConfig.DataGuildUp[currentType * 10000 + guildLv]
    if (item == nil) then
        return false;
    end
    local strArr = Utils.SplitStr(item.Other, ';')
    if #strArr > 0 then
        for i = 1, #strArr do
            local buildArr = Utils.SplitNumber(strArr[i], '_')
            if (#buildArr == 2) then
                if (self.BuildLvDic[buildArr[1] - 102] < buildArr[2]) then
                    return false;
                end
            end
        end
    else
        return false;
    end
    return true;
end

-- Determine whether there is an application for joining the gang
function GuildSystem:OnChargeApply()
    local offical = self:OnGetGuildOfficial();
    if (offical == nil) then
        return false;
    end
    if (self.GuildInfo == nil or offical.CanAgree ~= 1) then
        return false;
    end
    if (#self.GuildApplyList > 0) then
        return true;
    end
    return false;
end

-- Get the building name
function GuildSystem:OnGetBuildName(type)
    local result = "";
    if type == 1 then
        result = DataConfig.DataMessageString.Get("C_GUILD_BUILDINGNAME1")
    elseif type == 2 then
        result = DataConfig.DataMessageString.Get("C_GUILD_BUILDINGNAME2")
    elseif type == 3 then
        result = DataConfig.DataMessageString.Get("C_GUILD_BUILDINGNAME3")
    elseif type == 4 then
        result = DataConfig.DataMessageString.Get("C_GUILD_BUILDINGNAME4")
    elseif type == 5 then
        result = DataConfig.DataMessageString.Get("C_GUILD_BUILDNAME5")
    end
    return result
end

-- Obtain the Immortal Alliance Building Level
function GuildSystem:OnGetGuildLevel(type)
    if (self.BuildLvDic:ContainsKey(type)) then
        return self.BuildLvDic[type];
    end
    return 0;
end

-- Red dot check and settings
function GuildSystem:OnSetRedPoint(allEnable)
    if not allEnable then
        allEnable = true
    end
    if not self:HasJoinedGuild() then
        allEnable = false;
    end
    local isShowPoint = false;
    local offical = self:OnGetGuildOfficial()

    if #self.BuildLvDic > 0 and offical and offical.CanUp == 1 then
        self.BuildLvDic:ForeachCanBreak(function(k, v)
            if self:OnChargeCanUp(k) then
                isShowPoint = true;
                return true
            end
        end)
    end

    local hasApply = self:OnChargeApply();
    -- Guild Master Function Interface
    -- Building upgrades
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.GuildBuildLvUp, allEnable and isShowPoint);
    -- Apply for membership
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.GuildTabApplyList, allEnable and hasApply);
end

-- Is it the leader or not
function GuildSystem:IsChairman()
    return self.Rank == GuildOfficalType.Chairman or self.IsProxy
end

-- Set basic information of the Immortal Alliance
function GuildSystem:SetGuildInfo(info)
    if (info == nil) then
        self.GuildInfo = nil;
        return;
    end
    self.GuildInfo = L_BaseInfo:New()
    self.GuildInfo.guildId = info.guildId;
    self.GuildInfo.icon = info.icon;
    self.GuildInfo.name = info.name;
    self.GuildInfo.lv = info.lv;
    self.GuildInfo.limitLv = info.limitLv;
    self.GuildInfo.guildMoney = info.guildMoney;
    self.GuildInfo.notice = info.notice;
    self.GuildInfo.limitFight = info.fightLv;
    self.GuildInfo.isAutoJoin = info.isAutoJoin;
    self.GuildInfo.recruitCd = info.recruitCd;
    self.GuildInfo.RankNum = info.rank;
    self.GuildInfo.Rate = info.rate;
    self.GuildInfo.MaxNum = info.maxNum;
    if info.power then
        self.GuildInfo.fighting = info.power
    else
        self.GuildInfo.fighting = 0
    end
    local _isEnterRank = false;
    if self.GuildInfo.RankNum > 0 and self.GuildInfo.RankNum <= 3 and GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.FuDi) then
        _isEnterRank = true;
    end
    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.GuildTabRankList, _isEnterRank);
    self.GuildMemberList:Clear();
    if (info.members and #info.members > 0) then
        for i = 1, #info.members do
            local _info = self:SetMemberInfo(info.members[i]);
            _info.RankNum = 0;
            if (info.titles and #info.titles > 0) then
                for index = 1, #info.titles do
                    if (info.titles[index].roleId == _info.roleId) then
                        _info.RankNum = info.titles[index].rank;
                        break;
                    end
                end
                if (_info.RankNum == 0) then
                    _info.RankNum = 999;
                end
            end
            self.GuildMemberList:Add(_info);
            if(_info.rank == 4) then
                self.GuildInfo.leaderName = _info.name;
            end
        end
    end
    self.GuildInfo.memberNum = #self.GuildMemberList;
    self:ResReceivedApply(info);
    self:ResBuldingLevel(info);
    self:OnSortMemberList();
end

-- Set basic data of Xianlian members
function GuildSystem:SetMemberInfo(info)
    local member = L_MemberInfo:NewByMsg(info);
    if (info.roleId == GameCenter.GameSceneSystem:GetLocalPlayerID()) then
        self.Rank = info.position;
        self.IsProxy = info.isProxy;
    end
    return member;
end

-- Get the sorted member list
function GuildSystem:OnGetSortMemberList()
    local list = List:New(self.GuildMemberList, true);
    list:Sort(function(x, y)
        if (x.OnLine ~= y.OnLine) then
            return x.OnLine < y.OnLine;
        else
            if (x.rank ~= y.rank) then
                return x.rank > y.rank;
            else
                return x.contribute > y.contribute;
            end
        end
    end);
    return list;
end

-- Get the sorted member list
function GuildSystem:OnGetSortMemberListByEnum(num)
    local list = List:New(self.GuildMemberList, true);
    if (num == 1) then
        list:Sort(function(x, y)
            if (x.lastOffTime ~= y.lastOffTime) then
                return x.lastOffTime < y.lastOffTime
            else
                return x.fighting > y.fighting
            end
        end);
    elseif (num == 2) then
        list:Sort(function(x, y)
            if (x.rank ~= y.rank) then
                return x.rank > y.rank
            else
                if (x.OnLine ~= y.OnLine) then
                    return x.OnLine < y.OnLine
                else
                    return x.fighting > y.fighting
                end
            end
        end);
    elseif (num == 3) then
        list:Sort(function(x, y)
            return x.contribute > y.contribute
        end);
    elseif (num == 4) then
        list:Sort(function(x, y)
            return x.fighting > y.fighting
        end);
    else
        list:Sort(function(x, y)
            if (x.OnLine ~= y.OnLine) then
                return x.OnLine < y.OnLine
            else
                if (x.rank ~= y.rank) then
                    return x.rank > y.rank
                else
                    return x.contribute > y.contribute
                end
            end
        end);
    end
    return list;
end

function GuildSystem:UpdateBoxRed()
    local _baseRed = false
    local _specialRed = false
    self.BoxNum = 0
    for i = 1, #self.BoxDataList do
        if self.BoxDataList[i].Cfg and self.BoxDataList[i].reward == nil then
            if self.BoxDataList[i].Cfg.Type == 0 then
                _baseRed = true
            else
                _specialRed = true
            end
            self.BoxNum = self.BoxNum + 1
        end
    end
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.GuildTabBoxNomal, _baseRed)
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.GuildTabBoxSpecial, _specialRed)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GUILDBOXLIST_UPDATE)
end

function GuildSystem:SetRedPackageRed()
    local _red = false
    self.RedPackageDic:ForeachCanBreak(function(k, v)
        if not v.sent or (not v.mark and v.curnum > 0) then
            _red = true
            return true
        end
    end)
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.GuildTabRedPackage, _red)
end

function GuildSystem:GetRedPackageInfo(id)
    local _info = nil
    self.RedPackageDic:ForeachCanBreak(function(k, v)
        if v.rpId == id then
            _info = v
            return true
        end
    end)
    return _info
end
-- --------------------------------------------------------------------------------------------------------------------------------
function GuildSystem:OnExitGuildMsg(obj, sender)
    self.GuildInfo = nil;
    -- Clear red dots
    self:OnSetRedPoint(false);
    self.BuildLvDic:Clear();
    self.BoxLogList:Clear()
    self.BoxDataList:Clear()
    GameCenter.PushFixEvent(UIEventDefine.UIGuildNewForm_CLOSE);
    -- Exiting the union will update the task list once
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_TASKCHANG);
    self:CheckMainGuildBtnRedPoint();
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_GUILD_LEAVE);
end

-- Create a guild return
function GuildSystem:GS2U_ResCreateGuild(result)
    if result.g then
        self:SetGuildInfo(result.g);
        self.CanGetOfflineExpTime = not result.isGet;
        if self.IsCreateFormOpen then
            self.IsCreateFormOpen = false;
            -- Open the Guild Interface
            GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.Guild, nil);
            -- Close the creation interface
            GameCenter.PushFixEvent(UIEventDefine.UICreateGuildForm_CLOSE);
        end
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GUILD_BASEINFOCHANGE_UPDATE);
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.GuildWages, self.CanGetOfflineExpTime);
        Utils.ShowPromptByEnum("C_GUILD_CREATEGUILD_SUC");
    end
end

-- Join the Guild and Return
function GuildSystem:GS2U_ResJoinGuild(result)
    if result.g == nil then
        self:ReqRecommendGuild();
        Utils.ShowPromptByEnum("JoinGuilding");
    else
        if result.g.guildId <= 0 then
            self:ReqRecommendGuild();
            Utils.ShowPromptByEnum("JoinGuilding");
        else
            self:SetGuildInfo(result.g);
            self.CanGetOfflineExpTime = not result.isGet;
            if self.IsCreateFormOpen then
                self.IsCreateFormOpen = false;
                -- Open the Guild Interface
                GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.Guild);
                -- Close the creation interface
                GameCenter.PushFixEvent(UIEventDefine.UICreateGuildForm_CLOSE);
            end
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GUILD_BASEINFOCHANGE_UPDATE);
            GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.GuildWages, self.CanGetOfflineExpTime);
            Utils.ShowPromptByEnum("C_GUILD_JOINGUILD_SUC");
        end
    end
end

-- Setting modification returns
function GuildSystem:ResChangeGuildSetting(result)
    self.GuildInfo.isAutoJoin = result.isAutoApply;
    self.GuildInfo.limitFight = result.fightPoint;
    self.GuildInfo.icon = result.icon;
    self.GuildInfo.limitLv = result.lv;
    if result.notice and result.notice ~= "" then
        self.GuildInfo.notice = result.notice;
    end
    Utils.ShowPromptByEnum("ChangeGuildSettingSuccess");
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GUILD_SETTING_UPDATE);
end

-- Guild information issuance
function GuildSystem:ResGuildInfo(result)
    self:SetGuildInfo(result.g);
    self.CanGetOfflineExpTime = not result.isGet;
    -- Update the basic information interface of the gang
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.GuildWages, self.CanGetOfflineExpTime);
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GUILD_BASEINFOCHANGE_UPDATE);
end

-- Receive offline experience time message back
function GuildSystem:GS2U_ResReceiveItem(result)
    self.CanGetOfflineExpTime = false;
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.GuildWages, false);
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GUILD_OUTLINEITEM_UPDATE);
end

-- Gang search and recommendation gang return
function GuildSystem:ResRecommendGuild(result)
    self.GuildRecommentList:Clear();
    if result.infoList then
        for i = 1, #result.infoList do
            local info = L_BaseInfo:New();
            info.guildId = result.infoList[i].guildId;
            info.name = result.infoList[i].name;
            info.notice = result.infoList[i].notice;
            info.lv = result.infoList[i].lv;
            info.memberNum = result.infoList[i].memberNum;
            info.limitLv = result.infoList[i].limitLv;
            info.isApply = result.infoList[i].isApply;
            info.fighting = result.infoList[i].fighting;
            info.leaderName = result.infoList[i].member.name;
            info.limitFight = result.infoList[i].limitfight;
            info.isAutoJoin = result.infoList[i].isAutoJoin;
            info.LeaderInfo = self:SetMemberInfo(result.infoList[i].member);
            info.Rate = result.infoList[i].rate;
            info.MaxNum = result.infoList[i].maxNum;

            self.GuildRecommentList:Add(info);
        end
    end
    self:OnSortGuildList();
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GUILD_CREATEGUILD_RECOMMENDGUILDLIST_UPDATE);
end

-- Return to the list of gang members to add
function GuildSystem:ResGuildMemeberList(result)
    if result.infoList then
        for i = 1, #result.infoList do
            local info = self:SetMemberInfo(result.infoList[i]);
            if (self.GuildInfo.RankNum > 0 and self.GuildInfo.RankNum <= 3) then
                info.RankNum = 999;
            else
                info.RankNum = 0;
            end
            self.GuildMemberList:Add(info);
            if self.OfficalNumDic:ContainsKey(info.rank) then
                self.OfficalNumDic[info.rank] = self.OfficalNumDic[info.rank] + 1;
            else
                self.OfficalNumDic:Add(info.rank, 1);
            end
        end
    end
    self.GuildInfo.memberNum = #self.GuildMemberList;
    self:OnSortMemberList();
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GUILD_MEMBERLIST_UPDATE);
end

-- Job Changes
function GuildSystem:ResPlayerGuildRankChange(result)
    local lp = GameCenter.GameSceneSystem:GetLocalPlayerID()
    for i = 1, #self.GuildMemberList do
        if (self.GuildMemberList[i].roleId == result.roleId) then
            self.GuildMemberList[i].rank = result.rank;
            if (result.roleId == lp) then
                self.Rank = result.rank;
            else
                if (result.rank == GuildOfficalType.Chairman) then
                    self.Rank = GuildOfficalType.Member;
                    for j = 1, #self.GuildMemberList do
                        if (self.GuildMemberList[j].roleId == lp) then
                            self.GuildMemberList[j].rank = self.Rank;
                            break;
                        end
                    end
                end
            end
            break;
        end
    end
    self:OnSortMemberList();
    self:OnSetRedPoint();
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GUILD_BASEINFOCHANGE_UPDATE);
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GUILD_MEMBERLIST_UPDATE);
end

-- Kick out or exit the gang and return
function GuildSystem:ResQuitGuild(result)
    if (result.roleId == GameCenter.GameSceneSystem:GetLocalPlayerID() or result.roleId == 0) then
        self:OnExitGuildMsg();
    else
        for i = 1, #self.GuildMemberList do
            if self.GuildMemberList[i].roleId == result.roleId then
                self.GuildMemberList:RemoveAt(i);
                break;
            end
        end
        self:OnSortMemberList();
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GUILD_MEMBERLIST_UPDATE);
    end
end

-- Guild application list issuance
function GuildSystem:ResReceivedApply(result)
    self.GuildApplyList:Clear();
    if result.applys then
        for i = 1, #result.applys do
            local info = L_MemberInfo:New();
            info.roleId = result.applys[i].roleId;
            info.name = result.applys[i].name;
            info.lv = result.applys[i].lv;
            info.fighting = result.applys[i].fighting;
            info.career = result.applys[i].career;
            info.head = result.applys[i].head;
            self.GuildApplyList:Add(info);
        end
    end
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.GuildTabApplyList, self:OnChargeApply());
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GUILD_GUILDAPPLYLIST_UPDATE);
end

-- New application list
function GuildSystem:ResApplyAdd(result)
    if result.apply then
        local info = L_MemberInfo:New();
        info.roleId = result.apply.roleId;
        info.name = result.apply.name;
        info.lv = result.apply.lv;
        info.fighting = result.apply.fighting;
        info.career = result.apply.career;
        info.head = result.apply.head
        self.GuildApplyList:Add(info);
    end
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.GuildTabApplyList, self:OnChargeApply());
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GUILD_GUILDAPPLYLIST_UPDATE);
end

function GuildSystem:ResDealApplyInfo(result)
    if result.roleId then
        for i = 1, #result.roleId do
            for index = 1, #self.GuildApplyList do
                if (self.GuildApplyList[index].roleId == result.roleId[i]) then
                    self.GuildApplyList:RemoveAt(index);
                    break;
                end
            end
        end
    else
        self.GuildApplyList:Clear();
    end
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.GuildTabApplyList, self:OnChargeApply());
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GUILD_GUILDAPPLYLIST_UPDATE);
end

-- Guild log data return
function GuildSystem:ResGuildLogList(result)
    self.GuildLogList:Clear();
    if result.infoList then
        for i = 1, #result.infoList do
            local info = L_LogInfo:New();
            info.Type = result.infoList[i].type;
            info.Time = result.infoList[i].time;
            info.str = result.infoList[i].str;
            local format = nil;
            local paramList = List:New()
            -- Change language
            format = DataConfig.DataMessageString.GetByKey(info.Type);

            for index = 1, #info.str do
                local _res = string.find(info.str[index],"&_", 0, true)
                if _res and _res > 0 then
                    local str = string.gsub(info.str[index], "&_", "_");
                    local arr = Utils.SplitStr(str, '_')
                    if #arr >= 2 then
                        local paramStr = CommonUtils.ConvertParamStruct(tonumber(arr[1]), arr[2]);
                        if (paramStr) then
                            paramList:Add(paramStr);
                        end
                    end
                else
                    paramList:Add(info.str[index]);
                end
            end
            if #paramList > 0 then
                info.formate = UIUtils.CSFormatLuaTable(format, paramList);
            else
                info.formate = format;
            end
            self.GuildLogList:Add(info);
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GUILD_GUILDLOGLIST_UPDATE);
end

-- Building level return
function GuildSystem:ResBuldingLevel(result)
    self.BuildLvDic:Clear();
    if result.builds then
        for i = 1, #result.builds do
            self.BuildLvDic:Add(result.builds[i].type, result.builds[i].level);
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GUILD_GUILDBUILDINGLV_UPDATE);
    self:OnSetRedPoint();
end

-- Building Upgrade Return
function GuildSystem:ResUpBuildingSucces(result)
    if result.b then
        if (self.BuildLvDic:ContainsKey(result.b.type)) then
            self.BuildLvDic[result.b.type] = result.b.level;
        end
    end
    self.GuildInfo.guildMoney = result.guildMoney;
    self:OnSetRedPoint();
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GUILD_GUILDBUILDINGLV_UPDATE);
end

function GuildSystem:ResImpeach(result)
    if (result.res == 0) then
        Utils.ShowPromptByEnum("Impeachment_Succeed")
        local lp = GameCenter.GameSceneSystem:GetLocalPlayerID();
        for i = 1, #self.GuildMemberList do
            if (lp == self.GuildMemberList[i].roleId) then
                self.GuildMemberList[i].isProxy = true;
                self.IsProxy = true;
            end
        end
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GUILD_BASEINFOCHANGE_UPDATE);
    elseif (result.res == 1) then
        Utils.ShowPromptByEnum("C_GUILD_REPEATAPPLY_TIPS")
    elseif (result.res == 2) then
        Utils.ShowPromptByEnum("C_GUILD_APPLYTIMEOUT_TIPS")
    elseif (result.res == 3) then
        Utils.ShowPromptByEnum("C_GUILD_APPLYHAVE_TIPS")
    end
end

-- One-click recruitment message returns
function GuildSystem:ResGuildJoinPlayer(result)
    self.GuildInfo.recruitCd = result.cd;
end

-- Treasure chest list
function GuildSystem:ResGuildGiftList(msg)
    self.BoxDataList:Clear()
    if msg.gifts then
        for i = 1, #msg.gifts do
            local _tmp = msg.gifts[i]
            _tmp.RemainTime = msg.gifts[i].timeOut / 1000 - GameCenter.HeartSystem.ServerTime
            _tmp.Cfg = DataConfig.DataGuildGift[msg.gifts[i].gift]
            if _tmp.RemainTime > 0 then
                self.BoxUpdate = true
            end
            self.BoxDataList:Add(_tmp)
        end
    end
    if msg.history then
        for i = 1, #msg.history do
            local _tmp = msg.history[i]
            _tmp.Cfg = DataConfig.DataGuildGift[msg.history[i].gift]
            self.BoxLogList:Add(_tmp)
        end
    end
    self:UpdateBoxRed()
end

-- Treasure chest record added
function GuildSystem:ResGuildGiftHistory(msg)
    if msg.history then
        local _tmp = msg.history
        _tmp.Cfg = DataConfig.DataGuildGift[msg.history.gift]
        self.BoxLogList:Add(_tmp)
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GUILDBOXLOG_UPDATE)
end

-- Treasure chest data update
function GuildSystem:ResGuildGiftUpdate(msg)
    if msg.gift then
        local _tmp = msg.gift
        _tmp.Cfg = DataConfig.DataGuildGift[msg.gift.gift]
        _tmp.RemainTime = msg.gift.timeOut / 1000 - GameCenter.HeartSystem.ServerTime
        if _tmp.RemainTime > 0 then
            self.BoxUpdate = true
        end
        local _find = false
        for i = 1, #self.BoxDataList do
            if self.BoxDataList[i].id == msg.gift.id then
                self.BoxDataList[i] = _tmp
                _find = true
            end
        end
        if not _find then
            self.BoxDataList:Add(_tmp)
        end
    end
    self:UpdateBoxRed()
end

-- Delete the treasure chest
function GuildSystem:ResGuildGiftDelete(msg)
    if msg.ids then
        for i = 1, #msg.ids do
            for ii = 1, #self.BoxDataList do
                if self.BoxDataList[ii].id == msg.ids[i] then
                    self.BoxDataList:RemoveAt(ii)
                    break
                end
            end
        end
    end
    self:UpdateBoxRed()
end

-- Return to the red envelope list (including log list)
function GuildSystem:ResRedpacketList(msg)
    self.RedPackageDic:Clear()
    self.RedPackageLogList:Clear()
    if msg.rpinfo then
        for i = 1, #msg.rpinfo do
            local _tmp = msg.rpinfo[i]
            _tmp.RemainTime = msg.rpinfo[i].expiretime / 1000 - GameCenter.HeartSystem.ServerTime
            if _tmp.RemainTime < 0 then
                _tmp.RemainTime = 0
            end
            if _tmp.mark == false and _tmp.curnum > 0 then
                _tmp.SortNum = 8000000 + _tmp.RemainTime
            elseif _tmp.mark == true and _tmp.curnum > 0 then
                _tmp.SortNum = 7000000 + _tmp.RemainTime
            elseif _tmp.mark == true and _tmp.curnum == 0 then
                _tmp.SortNum = 6000000 + _tmp.RemainTime
            else
                _tmp.SortNum = _tmp.RemainTime
            end
            if _tmp.sent == false then
                _tmp.SortNum = 9000000 + _tmp.RemainTime
            end
            self.RedPackageDic:Add(msg.rpinfo[i].rpId, _tmp)
        end
        self.RedPackageUpdate = true
        self.RedPackageDic:SortValue(function(a, b)
            return a.SortNum > b.SortNum
        end)
    end
    if msg.rploginfo then
        for i = 1, #msg.rploginfo do
            self.RedPackageLogList:Add(msg.rploginfo[i])
        end
    end
    self:SetRedPackageRed()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GUILDREDPACKAGE_UPDATE)
end
-- Return to the specified red envelope grabbing situation, the client needs to calculate the best red envelope grabbing person
function GuildSystem:ResGetRedPacketInfo(msg)
    GameCenter.PushFixEvent(UILuaEventDefine.UIGuildRedPackageOpenForm_OPEN, msg)
end
-- Return to grab red envelopes
function GuildSystem:ResClickRedpacket(msg)
    GameCenter.PushFixEvent(UILuaEventDefine.UIGuildRedPackageOpenForm_OPEN, msg)
end
-- Feedback from sending red envelopes
function GuildSystem:ResSendRedPacket(msg)
end
function GuildSystem:ResMineHaveRedpacket(msg)
	local _msg = ReqMsg.MSG_redpacket.ReqRedpacketList:New()
	_msg:Send()
end
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- type: 1 default sort; type: 2 change to a batch
function GuildSystem:ReqRecommendGuild()
    local msg = ReqMsg.MSG_Guild.ReqRecommendGuild:New();
    msg:Send();
end

-- Request for offline experience time
function GuildSystem:ReqGetOfflineExpTime()
    local msg = ReqMsg.MSG_Guild.ReqReceiveItem:New();
    msg:Send();
end

-- Apply to join the designated guild
function GuildSystem:ReqJoinGuild(guildID)
    local info = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.Guild);
    if info then
        if info.IsEnable == false then
            Utils.ShowPromptByEnum("C_MAIN_GONGNENGWEIKAIQI", info.Cfg.FunctionName)
            return;
        end
    else
        return;
    end
    local _lsit = List:New()
    _lsit:Add(guildID)
    local msg = ReqMsg.MSG_Guild.ReqJoinGuild:New();
    msg.ids = _lsit
    msg:Send();
end


-- One click application
function GuildSystem:ReqJoinGuildByList(idList)
    local info = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.Guild);
    if info then
        if info.IsEnable == false then
            Utils.ShowPromptByEnum("C_MAIN_GONGNENGWEIKAIQI", info.Cfg.FunctionName)
            return;
        end
    else
        return;
    end
    local msg = ReqMsg.MSG_Guild.ReqJoinGuild:New();
    msg.ids = idList
    msg:Send()
end

function GuildSystem:ReqGuildActiveBabyInfo()
    local msg = ReqMsg.MSG_Guild.ReqGuildActiveBabyInfo:New()
    msg:Send()
end

-- Building upgrades
function GuildSystem:ReqUpBuildingLevel(type)
    local msg = ReqMsg.MSG_Guild.ReqUpBuildingLevel:New()
    msg.type = type
    msg:Send()
end

function GuildSystem:ReqChangeNotice(value)
    local msg = ReqMsg.MSG_Guild.ReqChangeGuildSetting:New()
    msg.isAutoApply = self.GuildInfo.isAutoJoin;
    msg.notice = value;
    msg.lv = self.GuildInfo.limitLv;
    msg.fightPoint = self.GuildInfo.limitFight;
    msg.icon = self.GuildInfo.icon;
    msg:Send();
end

function GuildSystem:ReqChangeAutoApply(value)
    local msg = ReqMsg.MSG_Guild.ReqChangeGuildSetting:New()
    msg.isAutoApply = value;
    msg.notice = self.GuildInfo.notice;
    msg.lv = self.GuildInfo.limitLv;
    msg.fightPoint = self.GuildInfo.limitFight;
    msg.icon = self.GuildInfo.icon;
    msg:Send();
end

-- Request information from the Immortal Alliance
function GuildSystem:ReqGuildInfo()
    local msg = ReqMsg.MSG_Guild.ReqGuildInfo:New()
    msg:Send();
end

function GuildSystem:ReqSetRank(roleID, rank)
    -- If it is a transfer leader, you must determine whether the player is the leader, and it also depends on whether the transferred player is the deputy leader.
    if rank == GuildOfficalType.Chairman then
        if self.Rank ~= GuildOfficalType.Chairman then
            Utils.ShowPromptByEnum("C_GUILD_OFFICALLEADER_TIPS")
        end
        for i = 1, #self.GuildMemberList do
            if roleID == self.GuildMemberList[i].roleId then
                if self.GuildMemberList[i].rank ~= GuildOfficalType.ViceChairman then
                    Utils.ShowPromptByEnum("C_GUILD_OFFICALLEADER_TIPS2")
                    return;
                end
                break;
            end
        end
    end
    local msg = ReqMsg.MSG_Guild.ReqSetRank:New()
    msg.roleId = roleID
    msg.rank = rank
    msg:Send()
end

-- Exit the Immortal Alliance
function GuildSystem:ReqExitQuit()
    if (self.Rank == GuildOfficalType.Chairman or self.IsProxy) and #self.GuildMemberList > 1 then
        Utils.ShowPromptByEnum("Master_Not_Quit")
    else
        Utils.ShowMsgBox(function(x)
            if (x == MsgBoxResultCode.Button2) then
                local msg = ReqMsg.MSG_Guild.ReqQuitGuild:New()
                msg:Send()
            end
        end, "GuildChirchamanExiteTips")
    end
end
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
return GuildSystem