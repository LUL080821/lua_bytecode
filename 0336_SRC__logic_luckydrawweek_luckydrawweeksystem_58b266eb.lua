------------------------------------------------
-- Author: 
-- Date: 2020-08-25
-- File: LuckyDrawWeekSystem.lua
-- Module: LuckyDrawWeekSystem
-- Description: Weekly Benefits Lucky Lottery
------------------------------------------------
local LuckyDrawAwardItem = require "Logic.LuckyDrawWeek.LuckyDrawAwardItem";
local LuckyDrawRecord = require "Logic.LuckyDrawWeek.LuckyDrawRecord";
local LuckyDrawVolume = require "Logic.LuckyDrawWeek.LuckyDrawVolume";
local TimeUtils = CS.Thousandto.Core.Base.TimeUtils;

-- Number of reward levels
local CN_AWARD_TYPE_COUNT = 4;
-- Rewards that can be selected
local CN_AWARD_TYPE_CANSELECT = 2;

local LuckyDrawWeekSystem = {
    -- Configuration table reward list List
    CfgAwardsList = nil,
    -- Configuration table reward data obtained by type
    CfgAwardsDict = nil,
    -- Server lottery record
    GlobalRecords = nil,
    -- Your own lottery record
    MeRecords = nil,
    -- Receive the prize
    GetVolumesDict = nil,
    -- Number of lottery draws
    AwardTimes = 0,
    -- All reward data
    AwardList = nil,
}

function LuckyDrawWeekSystem:Initialize()
    -- Set all rewards to nil to determine whether the configuration has been read.
    self.CfgAwardsList = nil;
    self.CfgAwardsDict = Dictionary:New();
    -- Initialize the record
    self.GlobalRecords = List:New();
    self.MeRecords = List:New();
    -- Initial collection of information
    self.GetVolumesDict = Dictionary:New();
    self.AwardTimes = 0;
    self.AwardList = List:New()
end

function LuckyDrawWeekSystem:UnInitialize()
    self.CfgAwardsList = nil;
    self.CfgAwardsDict = nil;
    self.GlobalRecords = nil;
    self.MeRecords = nil;    
    self.GetVolumesDict = nil;
    self.AwardTimes = 0;
    self.AwardList = nil;
end

function LuckyDrawWeekSystem:PraseCfgAwards()
    if self.CfgAwardsList == nil then
        self.CfgAwardsList = List:New();
        self.CfgAwardsDict:Clear()
        local _occ = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
        DataConfig.DataWeekWelfareReward:Foreach(
            function(_,_cfgData)
                self.CfgAwardsList[_cfgData.Type+1] = _cfgData
                if _cfgData.Type < CN_AWARD_TYPE_CANSELECT then
                    if not self.CfgAwardsDict:ContainsKey(_cfgData.Type) then
                        local _rewards = Utils.SplitStr(_cfgData.RewardPool, ';');
                        local _list = List:New()
                        for i = 1, #_rewards do
                            local _reward = Utils.SplitNumber(_rewards[i], '_')
                            if _reward[4] == 9 or _reward[4] == _occ then
                                local _data = {
                                    Index = 0,
                                    Rewards = _rewards[i],
                                    RewardType = _cfgData.Type,
                                    MaxNum = _cfgData.Num,
                                    Selected = false,
                                }
                                _list:Add(_data)
                            end
                        end
                        self.CfgAwardsDict:Add(_cfgData.Type, _list)
                    end
                end
            end
        );
    end
    return self.CfgAwardsList;
end

function LuckyDrawWeekSystem:SetRedPoint()
    local _luckyDrawPoint = GameCenter.ItemContianerSystem:GetEconomyWithType(ItemTypeCode.LuckyDraw)
    local _days = Utils.SplitNumber(DataConfig.DataGlobal[1898].Params, "_")
    local _isLuckDay = false
    local _curServerTime = math.floor(GameCenter.HeartSystem.ServerTime + GameCenter.HeartSystem.ServerZoneOffset)
    local _curWeekDay = TimeUtils.GetStampTimeWeeklyNotZone(math.floor(_curServerTime))
    if _curWeekDay == 0 then
        _curWeekDay = 7
    end
    for i = 1, #_days do
        if _curWeekDay == _days[i] then
            _isLuckDay = true
            break
        end
    end
    local _showRedPoint = false
    if _isLuckDay and _luckyDrawPoint > 0 then
        _showRedPoint = true
    end
    if self.GetVolumesDict:Count() > 0 then
        local _keys = self.GetVolumesDict:GetKeys()
        for i = 1, #_keys do
            local _volumes = self.GetVolumesDict[_keys[i]]
            if not _volumes.IsGet and _volumes.Progress >= _volumes.MaxCount then
                _showRedPoint = true
                break
            end
        end
    end
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.LuckyDrawWeek, _showRedPoint)
end

-- 1. Request lottery panel information
function LuckyDrawWeekSystem:ReqOpenLuckyDrawPanel()
    GameCenter.Network.Send("MSG_LuckyDraw.ReqOpenLuckyDrawPanel", {})
end
-- 2. Make a lottery request
function LuckyDrawWeekSystem:ReqLuckyDraw()
    GameCenter.Network.Send("MSG_LuckyDraw.ReqLuckyDraw", {})
end
-- 3. Request to obtain the lottery ticket
function LuckyDrawWeekSystem:ReqGetLuckyDrawVolume(vid)
    GameCenter.Network.Send("MSG_LuckyDraw.ReqGetLuckyDrawVolume", {id = vid})
end
-- 4. Replace reward request
function LuckyDrawWeekSystem:ReqChangeAwardIndex(param)
    -- Parameter format: { items = { { awardType = 0, indexes = { 1 } }, { awardType = 1, indexes = { 1 , 2 } } } } };
    GameCenter.Network.Send("MSG_LuckyDraw.ReqChangeAwardIndex", param)
end
-- 6. Close the message of the lottery panel
function LuckyDrawWeekSystem:ReqCloseLuckyDrawPanel()
    GameCenter.Network.Send("MSG_LuckyDraw.ReqCloseLuckyDrawPanel", {})
end

-- Online news
function LuckyDrawWeekSystem:ResLuckyDrawOnlineResult(msg)
    self:PraseCfgAwards()
    -- 0. Record the number of lottery draws
    self.AwardTimes = msg.awardtimes;
    self.AwardList:Clear()
    -- Reward list
    local _sItems = msg.items;
    -- Here will be 4 data, corresponding to several levels of rewards
    for i = 1, #_sItems do
        local _sAwardInfo = _sItems[i]
        local _cfgData = self.CfgAwardsList[_sAwardInfo.awardType + 1]
        for j = 1, #_sAwardInfo.indexes do
            local _rewardItem = LuckyDrawAwardItem:New(_cfgData, _sAwardInfo.indexes[j])
            self.AwardList:Add(_rewardItem)
        end
    end

    -- 2.Fill server records
    local _recs = msg.records;
    self.GlobalRecords:Clear();
    if _recs then
        for i = 1, #_recs do
            local _rec = _recs[i]
            if _rec.awardType <= 2 then
                self.GlobalRecords:Add(
                    LuckyDrawRecord:New(_recs[i], 0)
                );
            end
        end
    end
    self.GlobalRecords = self:ReverseList(self.GlobalRecords)
    -- 3. Fill in personal records
    _recs = msg.selfRecords;
    self.MeRecords:Clear();
    if _recs then
        for i = 1, #_recs do
            self.MeRecords:Add(
                LuckyDrawRecord:New(_recs[i], 1)
            );
        end
    end
    self.MeRecords = self:ReverseList(self.MeRecords)
    -- 4. Award receipt information
    local _getVs = msg.getVolumes;
    self.GetVolumesDict:Clear();
    for i = 1, #_getVs do
        local _id = _getVs[i].id
        if not self.GetVolumesDict:ContainsKey(_id) then
            self.GetVolumesDict:Add(_id, LuckyDrawVolume:New(_getVs[i]))
        else
            self.GetVolumesDict[_id] = LuckyDrawVolume:New(_getVs[i])
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LUCK_DRAW_WEEK_DATA_REFESH)
    self:SetRedPoint()
end

-- 1. Return all information about the lottery
function LuckyDrawWeekSystem:ResOpenLuckyDrawPanelResult(msg)
    self.AwardTimes = msg.awardtimes
    -- 4. Award receipt information
    local _getVs = msg.getVolumes;
    self.GetVolumesDict:Clear();
    for i = 1, #_getVs do
        local _id = _getVs[i].id
        if not self.GetVolumesDict:ContainsKey(_id) then
            self.GetVolumesDict:Add(_id, LuckyDrawVolume:New(_getVs[i]))
        else
            self.GetVolumesDict[_id] = LuckyDrawVolume:New(_getVs[i])
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LUCK_DRAW_WEEK_DATA_REFESH)
    self:SetRedPoint()
end

-- 2. Results of the lottery
function LuckyDrawWeekSystem:ResLuckyDrawResult(msg)
    local _resultCode = msg.retcode
    if _resultCode >= 0 then
        local _rewardData =
        {
            -- The prize level won: 0: Special prize, 1: First prize, 2: Second prize, 3: Third prize
            AwardType = msg.awardType,
            -- The index in the reward list configured in the draw.
            AwardIndex = msg.awardIndex,
        }
        self.AwardTimes = self.AwardTimes + 1
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LUCK_DRAW_WEEK_DATA_REFESH)
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LUCK_DRAW_REWARD_REFESH, _rewardData)
        self:SetRedPoint()
    else
        -- Error message
        if _resultCode == -1 then
            Utils.ShowPromptByEnum("LUCK_DRAW_ERROR_TIPS_1")
        elseif _resultCode == -8 then
            Utils.ShowPromptByEnum("LUCK_DRAW_ERROR_TIPS_2")
        else
            Utils.ShowPromptByEnum("MainTaskNoBagCell")
        end
    end
end

-- 3. Obtain the results of the lottery ticket
function LuckyDrawWeekSystem:ResGetLuckyDrawVolumeResult(msg)
    local _volumeData = msg.getVolume
    if self.GetVolumesDict:ContainsKey(_volumeData.id) then
        self.GetVolumesDict[_volumeData.id]:UpdateSdata(_volumeData)
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LUCK_DRAW_WEEK_DATA_REFESH)
    self:SetRedPoint()
end

-- 4. Replace reward results
function LuckyDrawWeekSystem:ResChangeAwardIndexResult(msg)
    if msg.retcode >= 0 then
        local _sItems = msg.items;
        local _awardIndex = 1
        for i = 1, #_sItems do
            local _indexs = _sItems[i].indexes
            local _awardType = _sItems[i].awardType
            local _cfgData = self.CfgAwardsList[_awardType + 1]
            for j = 1, #_indexs do
                self.AwardList[_awardIndex]:RefeshData(_cfgData, _indexs[j])
                _awardIndex = _awardIndex + 1
            end
        end
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LUCK_DRAW_CHANGE_SUCCESS)
    end
end

-- 5. Lottery records
function LuckyDrawWeekSystem:ResDrawnRecord(msg)
    if msg.record then
        local _p = GameCenter.GameSceneSystem:GetLocalPlayer()
        if _p ~= nil and _p.Name == msg.record.playername then
            local _record = LuckyDrawRecord:New(msg.record, 1);
            self.MeRecords:Insert(_record, 1)
            if #self.MeRecords > 20 then
                self.MeRecords:RemoveAt()
            end
        end
        -- Only records of 2 or above are retained in the entire server
        if msg.record.awardType <= 2 then
            local _record = LuckyDrawRecord:New(msg.record, 0);
            self.GlobalRecords:Insert(_record, 1)
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LUCK_DRAW_WEEK_RECORD_REFESH)
end

-- Reverse order
function LuckyDrawWeekSystem:ReverseList(targetList)
	local _tmpList = List:New()
	for i = 1, #targetList do
        _tmpList[i] = table.remove(targetList)
	end
    return _tmpList
end

-- Check the maximum limit and limit the data
function LuckyDrawWeekSystem:RemoveMoreData(targetList)
    local _count = #targetList
    -- Maximum number of saved
    local _maxNum = 20
    if _count > _maxNum then
        for i = _maxNum, _count do
            targetList:RemoveAt(i)
        end
    end
end

return LuckyDrawWeekSystem
