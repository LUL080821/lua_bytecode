------------------------------------------------
-- Author:
-- Date: 2019-04-22
-- File: RankSystem.lua
-- Module: RankSystem
-- Description: Ranking system category
------------------------------------------------
-- Quote
local RankData = require "Logic.Rank.RankData"
local RankPlayerInfo = require "Logic.Rank.RankPlayerInfo"
local RankCompareData = require "Logic.Rank.ItemData.RankCompareData"
local RankSystem = {
    -- Current ranking id
    CurFunctionId        = -1,
    -- Selected ranking index
    CurSelectRankIndex   = -1,
    -- The number of worships remaining today
    TodayRemainPraiseNum = 0,
    -- Current ranking data List
    CurRankList          = nil,
    -- RankData
    Data                 = nil,
    -- Current ranking data
    CurRankData          = nil,
    -- Selected player data
    CurImageInfo         = nil,
    -- Comparison data
    CompareData          = nil,
    -- Is this server
    IsLocalServer        = false,
    -- Click attribute comparison type 0 = ranking 1 = Hall of Fame
    ClickCompareType     = 0,
    -- Basic mount data cache
    BaseMountCache       = nil,
    -- Pet data cache
    PetDataCache         = nil,
    -- Soul Armor Data Cache
    HunJiaDataCache      = nil,
    DefaultModelParam    = nil,
    -- The currently selected player Id
    CurSelectRoleId      = 0,
    RankStateList        = List:New(),
}

-- Initialization ranking Cfg
function RankSystem:Initialize()
    self.Data = RankData:New()
    DataConfig.DataRankBase:Foreach(function(k, v)
        if v.IsShow == 1 then
            self.Data:ParseCfg(v)
        end
    end)
end

-- Get the ranking data corresponding to the incoming submenu
function RankSystem:GetItemByChildMenuId(childMenuId)
    return self.Data:GetItemList(childMenuId)
end

function RankSystem:GetCrossItemByChildMenuUd(childMenuId)
    return self.Data:GetCrossItemList(childMenuId)
end

function RankSystem:GetRankDataByPlayerId(playerId)
    if self.CurRankList ~= nil then
        for i = 1, #self.CurRankList do
            if self.CurRankList[i].RoleId == playerId then
                return self.CurRankList[i]
            end
        end
    end
    return nil
end

function RankSystem:GetBaseMountCache()
    if self.BaseMountCache == nil then
        self.BaseMountCache = Dictionary:New()
        DataConfig.DataNatureHorse:Foreach(function(k, v)
            if v.ModelID ~= nil and v.ModelID ~= 0 then
                self.BaseMountCache[v.ModelID] = v
            end
        end)
    end
    return self.BaseMountCache
end

function RankSystem:GetPetDataCache()
    if self.PetDataCache == nil then
        self.PetDataCache = Dictionary:New()
        DataConfig.DataPet:Foreach(function(k, v)
            if v.Model ~= nil and v.Model ~= 0 then
                self.PetDataCache[v.Model] = v
            end
        end)
    end
    return self.PetDataCache
end

function RankSystem:GetHunJiaDataCache()
    if self.HunJiaDataCache == nil then
        self.HunJiaDataCache = Dictionary:New()
        DataConfig.DataSoulArmorBreach:Foreach(function(k, v)
            if v.Model ~= nil and v.Model ~= 0 then
                self.HunJiaDataCache[v.Model] = v
            end
        end)
    end
    return self.HunJiaDataCache
end

-- Get the model size
function RankSystem:GetModelParam(rankId, info)
    local size = 360
    local roatx = 0
    local roaty = 0
    local roatz = 0
    local x = 0
    local y = 0
    local modelId = 0
    local tab = nil
    local list = nil
    local cfg = DataConfig.DataRankBase[rankId]
    if cfg ~= nil then
        if cfg.IsShoweModel == RankCfgShowModelType.Mount then
            cfg = DataConfig.DataHuaxingHorse[info.HorseModel]
            if cfg == nil then
                local dic = self:GetBaseMountCache()
                if dic ~= nil then
                    cfg = dic[info.HorseModel]
                end
            end
            if cfg ~= nil then
                list = Utils.SplitNumber(cfg.MainTransfom, '_')
            end
            modelId = info.HorseModel
            --elseif rankId == RankModelType.Wing then
        elseif cfg.IsShoweModel == RankCfgShowModelType.FaBao then
            cfg = DataConfig.DataHuaxingfabao[info.FaBaoModel]
            if cfg ~= nil then
                list = Utils.SplitNumber(cfg.MainTransfom, '_')
                modelId = cfg.Id
            end
        elseif cfg.IsShoweModel == RankCfgShowModelType.Pet then
            local dic = self:GetPetDataCache()
            cfg = dic[info.PetModel]
            if cfg ~= nil then
                list = Utils.SplitNumber(cfg.MainTransfom, '_')
            end
            modelId = info.PetModel
        elseif cfg.IsShoweModel == RankCfgShowModelType.HunJia then
            --local dic = self:GetHunJiaDataCache()
            cfg = DataConfig.DataSoulArmorBreach[info.HunJiaModel]--dic[info.info.HunJiaModel]
            if cfg ~= nil then
                list = Utils.SplitNumber(cfg.MainTransfom, '_')
            end
            modelId = cfg.Model
        end
        if list ~= nil then
            size = list[1]
            roatx = list[2]
            roaty = list[3]
            roatz = list[4]
            x = list[5]
            y = list[6]
            tab = {
                Size    = size,
                Roat    = Vector3(roatx, roaty, roatz),
                X       = x,
                Y       = y,
                ModelId = modelId
            }
        end
    end
    return tab
end

-- Determine whether the player model needs to be displayed in the current ranking
function RankSystem:IsShowPlayerModel(rankId)
    local ret = false
    local cfg = DataConfig.DataRankBase[rankId]
    if cfg ~= nil then
        ret = cfg.IsShoweModel == 1
    end
    return ret
end

function RankSystem:GetDefaultModelParam()
    if self.DefaultModelParam == nil then
        local cfg = DataConfig.DataGlobal[GlobalName.Rank_base_mainTransfom]
        if cfg ~= nil then
            local list = Utils.SplitNumber(cfg.Params, '_')
            self.DefaultModelParam = {
                Size = list[1],
                Roat = Vector3(list[2], list[3], list[4]),
                X    = list[5],
                Y    = list[6]
            }
        end
    end
    return self.DefaultModelParam
end

function RankSystem:GetRankState(id)
    local _ret = false
    for i = 1, #self.RankStateList do
        local _state = self.RankStateList[i]
        if _state.Id == id and _state.State == 1 then
            _ret = true
            break
        end
    end
    return _ret
end

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Request the ranking data corresponding to the type
function RankSystem:ReqRankInfo(type)
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN, DataConfig.DataMessageString.Get("RankDataLoading"));
    GameCenter.Network.Send("MSG_RankList.ReqRankInfo", {
        rankKind = type
    })
end

-- Request player appearance data
function RankSystem:ReqRankPlayerImageInfo(palyerId)
    GameCenter.Network.Send("MSG_RankList.ReqRankPlayerImageInfo", {
        rankPlayerId = palyerId
    })
end

-- Request to worship players
function RankSystem:ReqWorship(playerId)
    GameCenter.Network.Send("MSG_RankList.ReqWorship", {
        worshipPlayerId = playerId
    })
end

-- Request attribute comparison
function RankSystem:ReqCompareAttr(playerId)
    GameCenter.Network.Send("MSG_RankList.ReqCompareAttr", {
        comparePlayerId = playerId
    })
end

-- Request all ranking statuses
function RankSystem:ReqGetAllRankListState()
    GameCenter.Network.Send("MSG_RankList.ReqGetAllRankListState")
end

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function RankSystem:GS2U_ResRankInfo(result)
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
    self.TodayRemainPraiseNum = result.todayRemainWorshipNum
    self.Data:AddItemInfo(result.rankKind, result.rankInfoList, false)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_RANK_REFRESH)

    if self.TodayRemainPraiseNum > 0 then
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.Rank, true)
    else
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.Rank, false)
    end
end

function RankSystem:ResGetAllRankListStateResult(msg)
    if msg == nil then
        return
    end
    self.RankStateList:Clear()
    if msg.rankListStates ~= nil then
        for i = 1, #msg.rankListStates do
            local _state = msg.rankListStates[i]
            self.RankStateList:Add({ Id = _state.rankId, State = _state.state })
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_RANK_STATE_RESULT)
end

function RankSystem:GS2U_ResRankPlayerImageInfo(result)
    if self.CurImageInfo == nil then
        self.CurImageInfo = RankPlayerInfo:New()
    end
    self.CurImageInfo:Parase(result.imageInfo)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_RANK_UPDATE_MODEL, self.CurImageInfo)
end

function RankSystem:GS2U_ResWorship(result)
    if result.worshipResult == 0 then
        -- Worship failed
    elseif result.worshipResult == 1 then
        self.TodayRemainPraiseNum = result.todayRemainWorshipNum
        if self.CurSelectRoleId == result.worshipPlayerId then
            self.CurImageInfo.BePraiseNum = self.CurImageInfo.BePraiseNum + 1
        end
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_RANK_SHOWSHENG, result.worshipPlayerId)
        -- Prompt for success
        Utils.ShowPromptByEnum("PraiseSucced")
        if self.TodayRemainPraiseNum > 0 then
            GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.Rank, true)
        else
            GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.Rank, false)
        end
    end
end

function RankSystem:GS2U_ResRankRedPointTip(result)
    if result ~= nil then
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.Rank, result.hasWorshipNum)
    end
end

-- Return to the comparison data
function RankSystem:GS2U_ResRankCompareData(result)
    if result == nil then
        return
    end
    if self.CompareData == nil then
        self.CompareData = RankCompareData:New()
    end
    self.CompareData:SetData(result)
    GameCenter.PushFixEvent(UILuaEventDefine.UICompareForm_OPEN, self.CompareData)
end

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Request cross-server ranking information
function RankSystem:ReqCrossRankInfo()
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN, DataConfig.DataMessageString.Get("RankDataLoading"));
    GameCenter.Network.Send("MSG_CrossRank.ReqCrossRankInfo")
end

-- Return to cross-server ranking information
function RankSystem:ResCrossRankInfo(msg)
    if msg == nil then
        return
    end
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
    if msg.crossTypeRankList ~= nil then
        for i = 1, #msg.crossTypeRankList do
            local data = msg.crossTypeRankList[i]
            self.Data:AddItemInfo(data.type, data.crossRankList, true)
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_RANK_REFRESH)
end

return RankSystem
