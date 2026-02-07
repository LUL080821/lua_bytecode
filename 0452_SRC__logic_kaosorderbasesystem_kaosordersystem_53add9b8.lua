------------------------------------------------
-- Author:
-- Date: 2021-04-13
-- File: KaosOrderSystem.lua
-- Module: KaosOrderSystem
-- Description: Reward Order System
------------------------------------------------

local L_HuangGuLingData = require"Logic.KaosOrderBaseSystem.HuangGuLingData"

local KaosOrderSystem = {
    KaosOrderType = KaosOrderType.HuangGuLing,
    -- Number of ancient orders
    HuangGuLingPoint = 0,
    -- Number of ancient orders obtained on that day
    HuangGuLingDayPoint = 0,
    -- Ancient orders are currently rank
    HuangGuLingCurRank = 1,
    -- Have you purchased privileges
    isBuySpecail = 0,
    -- Huangguling Data Model Dictionary {key == rank, value = HuangGuLingData:{CfgId, Cfg, RewardState}}
    HGLDicData = nil,
    -- Can I refresh the rounds
    CanRefreshRank = false,
}

function KaosOrderSystem:Initialize()
end

function KaosOrderSystem:UnInitialize()
    self.HGLDicData = nil
end

-- External call to obtain reward list information through rank
function KaosOrderSystem:GetDataList(rankId)
    if rankId == nil then 
        rankId = self.HuangGuLingCurRank
    end
    local _ret = nil
    local _dic = self:GetDatas()
    if _dic ~= nil then
        _ret = _dic[rankId]
    end
    return _ret
end

-- Get dictionary
function KaosOrderSystem:GetDatas()
    if self.HGLDicData  == nil then
        self.HGLDicData = Dictionary:New()
        self:GetHGLConfig()
    end
    return self.HGLDicData
end

-- Read configuration
function KaosOrderSystem:GetHGLConfig()
    local rank_1 = List:New()
    local rank_2 = List:New()
    local rank_3 = List:New()
    DataConfig.DataKaoShangLingHorse:Foreach(function(k,v)
        local data = L_HuangGuLingData:New(k)
        if     data.Rank == 1 then
            rank_1:Add(data)
        elseif data.Rank == 2 then
            rank_2:Add(data)
        elseif data.Rank == 3 then
            rank_3:Add(data)
        end
    end)
    self.HGLDicData[1] = rank_1
    self.HGLDicData[2] = rank_2
    self.HGLDicData[3] = rank_3
end

-- Update rewards to receive status
function KaosOrderSystem:SetHGLRewardsListState(ComList , SpecList)
    local curRewardsList = self:GetDataList(self.HuangGuLingCurRank)
    if ComList ~= nil then
        for i = 1, #curRewardsList do
            for j = 1, #ComList do
                if curRewardsList[i].Id == ComList[j] then 
                    curRewardsList[i]:SetFreeState(true)
                end
            end
        end
    end
    if SpecList~= nil then
        for i = 1, #curRewardsList do
            for j = 1, #SpecList do
                if curRewardsList[i].Id == SpecList[j] then 
                    curRewardsList[i]:SetSpecialState(true)
                end
            end
        end
    end
end

function KaosOrderSystem:ReSetHGLRewardsListState()
    local curRewardsList = self:GetDataList(self.HuangGuLingCurRank)
    for i = 1, #curRewardsList do
        curRewardsList[i]:SetFreeState(false)
        curRewardsList[i]:SetSpecialState(false)
    end
end


-- Is it the last one in the current reward list?
function KaosOrderSystem:IsLastReward(id)
    local keys = self.HGLDicData:GetKeys()
    for i = 1, #keys do
        for j = 1, #self.HGLDicData[i] do
            if  self.HGLDicData[i][j].Id == id then 
                return self.HGLDicData[i][j].IfLast == 1
            end
        end
    end
end

-- Get a list of rewards you can claim
function KaosOrderSystem:GetCanRewardList( isSpecail )
    if isSpecail ~= nil and isSpecail then 
        local _list = self:GetDataList(self.HuangGuLingCurRank)
        local _ret = List:New()
        for i = 1, #_list do
            if _list[i].Score <= self.HuangGuLingPoint then 
                _ret:Add(_list[i])
            end
        end
        return _ret
    end
end

function KaosOrderSystem:CanReward()
    local _can = false
    local _RewardsList = self:GetDataList()
    for i = 1, #_RewardsList do
        if _RewardsList[i].Score > self.HuangGuLingPoint then 
            break
        end
        if self.isBuySpecail == 1 then
            if _RewardsList[i].SpecialItemState == false  then
                _can = true
                return _can
            end
        else  
            if _RewardsList[i].FreeItemState == false  then
                _can = true
                return _can
            end
        end
    end
    return _can
end


-- Send open panel message to the server
function KaosOrderSystem:ReqOpenKaoShangLingPanel(typeId)
    local _msg = ReqMsg.MSG_KaoShangLing.ReqOpenKaoShangLingPanel:New()
	_msg.type = typeId -- 1 Ancient Order
	_msg:Send()
end

-- Send reward message to the server
function KaosOrderSystem:ReqKaoShangLingReward(typeId , isOneKey , key)
    local _msg = ReqMsg.MSG_KaoShangLing.ReqKaoShangLingReward:New()
	_msg.type = typeId -- 1 Ancient Order
    _msg.isOneKey = isOneKey
    _msg.key = key
	_msg:Send()
end

-- Send refresh messages to the server
function KaosOrderSystem:ReqKaoShangLingRefreshRank(typeId)
    local _msg = ReqMsg.MSG_KaoShangLing.ReqKaoShangLingRefreshRank:New()
	_msg.type = typeId -- 1 Ancient Order
	_msg:Send()
end

-- Send advanced reward message to the server
function KaosOrderSystem:ReqBuySpecailKaoShangLing(typeId)
    local _msg = ReqMsg.MSG_KaoShangLing.ReqBuySpecailKaoShangLing:New()
	_msg.type = typeId -- 1 Ancient Order
	_msg:Send()
end



-- Server accepts Open panel message
function KaosOrderSystem:ResOpenKaoShangLingPanel(msg)
    self.CanRefreshRank = false
    local _HuangGuLingData = msg.kaoShangLingInfoList[1]
    -- kaoShangLingInfoList[] 1 = Ancient Order 2 = Other
    if _HuangGuLingData ~= nil then 
        self.HuangGuLingPoint = _HuangGuLingData.scoreTotal
        self.KaosOrderType = _HuangGuLingData.type
        self.HuangGuLingCurRank = _HuangGuLingData.rank
        self.HuangGuLingDayPoint = _HuangGuLingData.scoreDay
        self.isBuySpecail = _HuangGuLingData.isBuySpecail 
        self:SetHGLRewardsListState(_HuangGuLingData.commonRewardList , _HuangGuLingData.specailRewardist)
        if _HuangGuLingData.commonRewardList ~= nil then
            for i = 1, #_HuangGuLingData.commonRewardList do
                if  self:IsLastReward(_HuangGuLingData.commonRewardList[i]) then 
                    self.CanRefreshRank = true
                end
            end
        end
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_CROSSMOUNTBOSS_REFRESBTNREDPOINR , self:CanReward())
    end
end

-- Server receives reward message
function KaosOrderSystem:ResKaoShangLingReward(msg)
    self.CanRefreshRank = false
    self:SetHGLRewardsListState(msg.commonRewardList , msg.specailRewardist)
    for i = 1, #msg.commonRewardList do
        if  self:IsLastReward(msg.commonRewardList[i]) then 
            self.CanRefreshRank = true
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_HuangGuLing_UPDATE)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_CROSSMOUNTBOSS_REFRESBTNREDPOINR , self:CanReward())
end

-- Server receives refresh round message
function KaosOrderSystem:ResKaoShangLingRefreshRank(msg)
    self.CanRefreshRank = false
    self:ReSetHGLRewardsListState()
	local playerId = GameCenter.GameSceneSystem:GetLocalPlayerID()
	PlayerPrefs.SetInt("HuangGuLingRankRefreshTipOverd" .. playerId, 0)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_HuangGuLing_UPDATE)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_HuangGuLing_REFRESHRANK)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_CROSSMOUNTBOSS_REFRESBTNREDPOINR , self:CanReward())
end

-- Server receives advanced reward messages
function KaosOrderSystem:ResBuySpecailKaoShangLing(msg)
    self.isBuySpecail = msg.isBuySpecail
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_HuangGuLing_UPDATE)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_HuangGuLing_BUYSUCCESS)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_CROSSMOUNTBOSS_REFRESBTNREDPOINR , self:CanReward())
end

return KaosOrderSystem