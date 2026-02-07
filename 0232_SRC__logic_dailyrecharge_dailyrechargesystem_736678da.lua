------------------------------------------------
-- Author: 
-- Date: 2020-9-3
-- File: DailyRechargeSystem.lua
-- Module: DailyRechargeSystem
-- Description: Daily charging system
------------------------------------------------
local DailyRechargeSystem = {
    MsgData = nil,
    BoxCount = 0,
}

local L_IsInit = false;
local L_AllData = {};
local L_AllPos = {};
local L_State = {};

function DailyRechargeSystem:Initialize()
    self.MsgData = nil
    for k, v in pairs(L_State) do
        L_State[k] = RewardState.None
    end
end

function DailyRechargeSystem:UnInitialize()

end

function DailyRechargeSystem:InitData()
    if not L_IsInit then
        local function func(k, v)
            if not L_AllData[v.Position] then
                L_AllData[v.Position] = {}
                table.insert(L_AllPos, v.Position);
            end
            L_AllData[v.Position][v.Type] = v
            L_State[k] = RewardState.None
        end
        DataConfig.DataRechargeDaily:Foreach(func)
        table.sort(L_AllPos, function(a, b)
            return a < b
        end)
        L_IsInit = true;
    end
end

-- Get configuration data
function DailyRechargeSystem:GetPos()
    self:InitData()
    return L_AllPos
end

-- Get configuration data
function DailyRechargeSystem:GetConfigData()
    self:InitData()
    return L_AllData
end

-- Get status return RewardState
function DailyRechargeSystem:GetStateById(id)
    self:InitData()
    return L_State[id]
end

-- Get if there are red dots
function DailyRechargeSystem:IsRedpointByPos(pos)
    self:InitData()
    local _datas = L_AllData[pos];
    for k, v in pairs(_datas) do
        if L_State[v.ID] == RewardState.CanReceive then
            return true;
        end
    end
    return false
end

-- Settings of red dots
function DailyRechargeSystem:RefreshRedpoint()
    self:InitData()
    local _redPoint = false;
    for k, v in pairs(L_State) do
        if v == RewardState.CanReceive then
            _redPoint = true;
            break
        end
    end
    local _canReceive = self.BoxCount <= 0
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.DailyRechargeForm, _redPoint or _canReceive)
end

-- Receive the award
function DailyRechargeSystem:ReqGetRechargeReward(id)
    local _req = ReqMsg.MSG_Commercialize.ReqGetRechargeReward:New()
    _req.rewarId = id
    _req:Send()
end

-- Return daily cumulative configuration data
function DailyRechargeSystem:ResDailyRechargeInfo(msg)
    self:InitData()
    self.MsgData = msg
    for k, v in pairs(L_State) do
        L_State[k] = RewardState.None
    end
    if msg then
        local _rechargeTotal = msg.rechargeTotal or 0
        local _consumeTotal = msg.consumeTotal or 0
        for k, v in pairs(L_State) do
            local _cfg = DataConfig.DataRechargeDaily[k];
            if _cfg.Type == 1 and _rechargeTotal >= _cfg.Money or _cfg.Type == 2 and _consumeTotal >= _cfg.Money then
                L_State[k] = RewardState.CanReceive
            end
        end
        local _rechargeIdList = msg.rechargeIdList;
        if _rechargeIdList then
            for i = 1, #_rechargeIdList do
                L_State[_rechargeIdList[i]] = RewardState.Received;
            end
        end
        local _consumeIdList = msg.consumeIdList;
        if _consumeIdList then
            for i = 1, #_consumeIdList do
                L_State[_consumeIdList[i]] = RewardState.Received;
            end
        end
    end
    if msg.boxRewardCount ~= nil then
        self.BoxCount = msg.boxRewardCount
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_DAY_RECHARGEINFO)
    self:RefreshRedpoint()
end

function DailyRechargeSystem:ResGetBoxRewardResult(msg)
    if msg.boxRewardCount ~= nil then
        self.BoxCount = msg.boxRewardCount
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_DAY_RECHARGEINFO)
    self:RefreshRedpoint()
end

return DailyRechargeSystem
