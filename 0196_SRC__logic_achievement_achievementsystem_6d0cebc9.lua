------------------------------------------------
-- Author:
-- Date: 2019-05-17
-- File: AchievementSystem.lua
-- Module: AchievementSystem
-- Description: Achievement System
------------------------------------------------
local AchievementInfo = require("Logic.Achievement.AchievementInfo")
local L_Sort = table.sort

local AchievementSystem = {
    -- Store all data in this class according to the major class {[1]={data1,data2,...},...}
    DataTypeDic = nil,
    -- Each id corresponds to a data {[101]=data1, [102]=data2,...}
    DataIdDic = nil,
    -- List of completed Ids
    FinishIdList = nil,
    -- List of rewards
    CanGetIdList = nil,
    -- Unfinished achievements and progress, this is sent by the server
    UnfinishedAchievementInfoDic = nil,
}

-- System initialization
function AchievementSystem:Initialize()
    self.FinishIdList = List:New();
    self.CanGetIdList = List:New();
    self.UnfinishedAchievementInfoDic = Dictionary:New();
end

-- System uninstall
function AchievementSystem:UnInitialize()
    self.DataTypeDic = nil;
    self.DataIdDic = nil;
    self.FinishIdList = nil;
    self.CanGetIdList = nil;
end

-- Whether the configuration table has the id
function AchievementSystem:IsContains(id)
    return not (not DataConfig.DataAchievement[id]);
end

-- Is the achievement completed or has received the award
function AchievementSystem:IsFinish(id)
    for i=1,#self.FinishIdList do
        if self.FinishIdList[i] == id then
            return true;
        end
    end
    for i=1,#self.CanGetIdList do
        if self.CanGetIdList[i] == id then
            return true;
        end
    end
    return false;
end

-- Get a dictionary that stores all data in that class according to a major class
function AchievementSystem:GetDataTypeDic()
    if not self.DataTypeDic then
        self:InitUIdata();
    end
    return self.DataTypeDic;
end

-- Get a dictionary for each id corresponding to a data
function AchievementSystem:GetDataIdDic()
    if not self.DataIdDic then
        self:InitUIdata();
    end
    return self.DataIdDic;
end

-- Get the corresponding data according to ID
function AchievementSystem:GetDataById(id)
    if not self.DataIdDic then
        self:InitUIdata();
    end
    return self.DataIdDic[id];
end

-- Initialize UI data
function AchievementSystem:InitUIdata()
    self.DataTypeDic = Dictionary:New();
    self.DataIdDic = Dictionary:New();
    AchievementInfo:NewAll(self.DataTypeDic, self.DataIdDic);
    for _, v in pairs(self.FinishIdList) do
        if self.DataIdDic[v] then
            self.DataIdDic[v].State = AchievementStateEnum.Finish;
        end
    end

    for _, v in pairs(self.CanGetIdList) do
        if self.DataIdDic[v] then
            self.DataIdDic[v].State = AchievementStateEnum.CanGet;
        end
    end
end

-- Clean up UI-related data
function AchievementSystem:ClearUIdata()
    self.DataTypeDic = nil;
    self.DataIdDic = nil;
end

-- Data sorting [Can be collected > Not completed > Completed > Small id > Large id]
function AchievementSystem:DataSort()
    if self.DataTypeDic then
        self.DataTypeDic:Foreach(function(_, v)
            v:Foreach(function(__, vv)
                table.sort(vv, function(a, b)
                    if a.State == b.State then
                        return a.Count < b.Count;
                    else
                        return a.State > b.State;
                    end
                end)
            end)
        end)
    end
end

-- Get FunctionId completion and total achievement points
function AchievementSystem:GetFinishAcievementCountByFunctionId(FunctionId)
    if self.DataTypeDic then
        for _,v in pairs(self.DataTypeDic) do
            for __,vv in pairs(v) do
                if vv[1].FunctionId == FunctionId then
                    local _curCnt = 0;
                    local _allCnt = 0;
                    for i=1,#vv do
                        local _addAchieve = vv[i].DataAchievementItem.AddAchievement;
                        if vv[i].State == AchievementStateEnum.Finish then
                            _curCnt = _curCnt + _addAchieve;
                        end
                        _allCnt = _allCnt + _addAchieve;
                    end
                    return _curCnt, _allCnt;
                end
            end
        end
    end
    return 0, 0;
end

-- Obtain completed achievement points
function AchievementSystem:GetFinishAcievementCountByType(type)
    local _typeCounts = {};
    for _,v in pairs(self.FinishIdList) do
        local _data = self.DataIdDic[v];
        local _bigType = _data.DataAchievementItem.BigType;
        if not _typeCounts[_bigType] then
            _typeCounts[_bigType] = 0;
        end
        _typeCounts[_bigType] = _typeCounts[_bigType] + _data.DataAchievementItem.AddAchievement;
    end
    return _typeCounts[type] or 0;
end

-- Obtain the completed total achievement
function AchievementSystem:GetFinishAcievementCount()
    local _count = 0;
    for _,v in pairs(self.FinishIdList) do
        _count = _count + self.DataIdDic[v].DataAchievementItem.AddAchievement;
    end
    return _count;
end

-- Is there a red dot [the achievement of the id]
function AchievementSystem:IsRedPointById(FunctionId)
    local _DataAchievement = DataConfig.DataAchievement;
    for _, v in pairs(self.CanGetIdList) do
        local _item = _DataAchievement[v];
        if _item then
            local _t = Utils.SplitStr(_item.Condition, "_");
            if tonumber(_t[1]) == FunctionId then
                return true;
            end
        end
    end
    return false;
end

-- Get keyQueue based on id
function AchievementSystem:GetKeyQueueById(id)
    local _info = self.DataIdDic[id];
    return {_info.DataAchievementItem.BigType, _info.FunctionId}
end

-- Get keyQueue based on id
function AchievementSystem:GetKeyQueueByCanGetIdList()
    if #self.CanGetIdList > 0 then
        return self:GetKeyQueueById(self.CanGetIdList[1])
    end
    return {0}
end

-- Is there a red dot [all achievements of this type]
function AchievementSystem:IsRedPointByType(bigType)
    local _DataAchievement = DataConfig.DataAchievement;
    for _, v in pairs(self.CanGetIdList) do
        local _item = _DataAchievement[v];
        if _item then
            if _item.BigType == bigType then
                return true;
            end
        end
    end
    return false;
end
-- Is there a red dot [the achievement system]
function AchievementSystem:IsRedPoint()
    return self.CanGetIdList:Count() > 0;
end

-- Refresh the little red dots
function AchievementSystem:RefreshRedPoint()
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.ChengjiuBase, self:IsRedPoint());
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.ChengJiu, self:IsRedPoint());
end
--========================================================[msg]========================================================
-- Send to receive rewards
function AchievementSystem:SendGetMsg(id)
    GameCenter.Network.Send("MSG_Achievement.ReqGetAchievement", {id = id});
end

-- List of achievements received online
function AchievementSystem:ResAchievementInfo(msg)
    -- Debug.LogTableRed(msg, "MSG_Achievement.ResAchievementInfo");
    -- examine
    local _checkTable = {};
    local _DataAchievement = DataConfig.DataAchievement;
    local _finishIds = msg.hasGetIds;
    if _finishIds then
        for i=#_finishIds,1,-1 do
            local _finishId = _finishIds[i];
            if not _DataAchievement[_finishId] then
                table.remove(_finishIds, i)
            else
                if _checkTable[_finishId] == 1 then
                    table.remove(_finishIds, i)
                else
                    _checkTable[_finishId] = 1;
                end
            end
        end
    end

    local _canGetIds = msg.canGetIds;
    if _canGetIds then
        for i=#_canGetIds,1,-1 do
            local _canGetId = _canGetIds[i];
            if not _DataAchievement[_canGetId] then
                table.remove(_canGetIds, i)
            else
                if _checkTable[_canGetId] == 2 then
                    table.remove(_canGetIds, i)
                elseif _checkTable[_canGetId] == 1 then
                    table.remove(_canGetIds, i)
                else
                    _checkTable[_canGetId] = 2;
                end
            end
        end
    end

    local _unfinishInfos = msg.infos;
    if _unfinishInfos then
        for i=#_unfinishInfos,1,-1 do
            local _item = _unfinishInfos[i];
            if not _DataAchievement[_item.id] then
                table.remove(_unfinishInfos, i)
            else
                if _checkTable[_item.id] == 3 then
                    table.remove(_canGetIds, i)
                elseif _checkTable[_item.id] == 2 then
                    table.remove(_canGetIds, i)
                elseif _checkTable[_item.id] == 1 then
                    table.remove(_canGetIds, i)
                else
                    _checkTable[_item.id] = 3;
                end
            end
            if not self.UnfinishedAchievementInfoDic:ContainsKey(_item.id) then
                self.UnfinishedAchievementInfoDic:Add(_item.id, _item)
            else
                self.UnfinishedAchievementInfoDic[_item.id] = _item
            end
        end
    end

    self.FinishIdList = List:New(_finishIds);
    self.CanGetIdList = List:New(_canGetIds);
    self.CanGetIdList:Sort();
    -- Refresh the little red dots
    self:RefreshRedPoint()
end

-- Get the Achievement Reward Return
function AchievementSystem:ResGetAchievement(msg)
    local _msgid = msg.id;
    if not _msgid then
        -- Debug.LogTableRed(msg, "MSG_Achievement.ResGetAchievement");
        return;
    end
    if self:IsContains(_msgid) then
        if self.CanGetIdList:Contains(_msgid) then
            self.CanGetIdList:Remove(_msgid)
        else
        end
        if not self.FinishIdList:Contains(_msgid) then
            self.FinishIdList:Add(_msgid);
            if self.DataIdDic then
                self.DataIdDic[_msgid].State = AchievementStateEnum.Finish;
                -- self:DataSort();
            end
        else
            return;
        end
    else
        -- Debug.LogTableRed(msg, "MSG_Achievement.ResGetAchievement");
        return;
    end
    -- Refresh the little red dots
    self:RefreshRedPoint()
    -- Update the interface
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_ACHFORM);
end

-- Update the achievement list
function AchievementSystem:ResUpdateAchivement(msg)
    -- Debug.LogTableRed(msg, "MSG_Achievement.ResUpdateAchivement");
    if not msg.infos then
        -- Debug.LogTableRed(msg, "MSG_Achievement.ResUpdateAchivement");
        return;
    end
    for k,v in pairs(msg.infos) do
        if self.DataIdDic then
            local _item = self.DataIdDic[v.id]
            if _item then
                _item.Progress = v.pro;
                _item.State = v.state == 0 and AchievementStateEnum.None or (v.state == 1 and AchievementStateEnum.CanGet or AchievementStateEnum.Finish);
            end
        end

        local _unfinishItem = self.UnfinishedAchievementInfoDic[v.id];
        if v.state == 0 then
            if _unfinishItem then
                _unfinishItem.pro = v.pro;
                _unfinishItem.state = v.state;
            else
                self.UnfinishedAchievementInfoDic:Add(v.id, v);
            end
        elseif v.state == 1 then
            if not self.CanGetIdList:Contains(v.id) then
                self.CanGetIdList:Add(v.id);
                if _unfinishItem then
                    self.UnfinishedAchievementInfoDic:Remove(v.id);
                end
            end
        elseif v.state == 2 then
            if not self.FinishIdList:Contains(v.id) then
                self.FinishIdList:Add(v.id);
                if _unfinishItem then
                    self.UnfinishedAchievementInfoDic:Remove(v.id);
                end
            end
            if self.CanGetIdList:Contains(v.id) then
                self.CanGetIdList:Remove(v.id);
            end
            if self.UnfinishedAchievementInfoDic[v.id] then
                self.UnfinishedAchievementInfoDic:Remove(v.id);
            end
        end
    end
    self.CanGetIdList:Sort();
    -- Refresh the little red dots
    self:RefreshRedPoint()
    -- Update the interface
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_ACHFORM);
end

return AchievementSystem