
------------------------------------------------
-- Author:
-- Date: 2019-07-19
-- File: ServerActiveSystem.lua
-- Module: ServerActiveSystem
-- Description: Service activation system
------------------------------------------------
-- Quote
local ActiveComData = require "Logic.ServerActive.ServerActiveComData"
local RedPacketData = require "Logic.ServerActive.ServeRedPacketData"
local ExChangeData = require "Logic.ServerActive.ServeExChangeData"
local TimeUtils = CS.Thousandto.Core.Base.TimeUtils
local ServerActiveSystem = {
    -- [Red envelope module data]-------------------
    -- Total red envelope amount available
    RpGoldNum = 0,
    -- Total data of red envelopes
    RedPacketNum = 7,
    -- Red envelope collection status 0: The collection conditions are not met 1: Can be collected 2: Received
    RpRewardState = 0,
    -- Seven-day red envelope remaining time
    RpLeftTime = 0,
    RpSyncTime = 0,
    -- Yuanbao Icon
    RpGoldIcon = 0,
    -- Red envelope data List
    ListRedPacketData = List:New(),
    -- [Red envelope module data]-------------------

    -- [Collected word redemption data]--------------------------------------------------------------------------------------------------------------------
    -- illustrate
    ExChangeExplain = nil,
    ExChangeTitlePicName = nil,
    ListExChangeData = List:New(),
    -- [Collected word redemption data]--------------------------------------------------------------------------------------------------------------------

    -- General Model Data Type Dictionary Contains several data on the same tab page
    DicActiveComData = Dictionary:New(),
    -- Red dot dictionary
    DicRedPoint = Dictionary:New(),
}

function ServerActiveSystem:Initialize()
    self.DicActiveComData:Clear()
    self.DicRedPoint:Clear()
    DataConfig.DataNewSeverActive:Foreach(function(k, v)
        local comData = nil
        local key = v.Type
        if self.DicActiveComData:ContainsKey(key) then
            comData = self.DicActiveComData[key]
            comData:AddData(v)
        else
            comData = ActiveComData:New()
            comData:ParaseCfg(v)
            self.DicActiveComData[key] = comData
        end
    end)

    -- Initialize the red envelope list
    local globCfg = DataConfig.DataGlobal[1573]  
    if globCfg ~= nil then
        local list = Utils.SplitStr(globCfg.Params,';')
        if list ~= nil then
            for i = 1,#list do
                local rpData = RedPacketData:New()
                rpData:Parase(list[i],i)
                self.ListRedPacketData:Add(rpData)
            end
        end
    end

    -- Initialize the word redemption data
    DataConfig.DataNewSeverExchange:Foreach(function(k, v)
        local exChangeData = ExChangeData:New()
        exChangeData:ParaseCfg(v)
        self.ListExChangeData:Add(exChangeData)
    end)

    -- Red dot
    for i = 1,ServerActiveEnum.Count -1 do
        self.DicRedPoint:Add(i,false)
    end
    -- Register props change message
    --GameCenter.RegFixEventHandle(LogicEventDefine.EVENT_ITEM_CHANGE_UPDATE, self.OnItemChanged,self)
end

function ServerActiveSystem:UnInitialize()
    --GameCenter.UnRegFixEventHandle(LogicEventDefine.EVENT_ITEM_CHANGE_UPDATE, self.OnItemChanged,self)
end

-- Props change
function ServerActiveSystem:OnItemChanged(obj, sender)
    if self.ListExChangeData~= nil then
        local itemID = obj
        local isEnable = true
        for i = 1,#self.ListExChangeData do
            local data = self.ListExChangeData[i]
            for m = 1,#data.ListCostItem do
                local ItemData = data.ListCostItem[m]
                local num = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(ItemData.Id)
                if num < ItemData.Num then
                    isEnable = false
                    break
                end
            end
        end
        if isEnable then
            -- Show main function red dots
            GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.ServerActive,true)
            self.DicRedPoint[ServerActiveEnum.Collect] = true
        else
            self.DicRedPoint[ServerActiveEnum.Collect] = false
        end
    end
end

-- Get the corresponding ComData data based on the id value
function ServerActiveSystem:GetComActiveDataById(id)
    if self.DicActiveComData:ContainsKey(id) then
        return self.DicActiveComData[id]
    end
    return nil
end

-- Get the corresponding ComData data according to cfgId
function ServerActiveSystem:GetComActiveDataByCfgId(cfgId)
    local cfg = DataConfig.DataNewSeverActive[cfgId]
    if cfg ~= nil then
        local key = cfg.Type
        if self.DicActiveComData:ContainsKey(key) then
            return self.DicActiveComData[key]
        end
    end
    return nil
end

-- Get taskdata in comdata according to cfgId
function ServerActiveSystem:GetTaskDataByCfgId(cfgId)
    local data = nil
    local cfg = DataConfig.DataNewSeverActive[cfgId]
    if cfg ~= nil then
        local key = cfg.Type
        if self.DicActiveComData:ContainsKey(key) then
            data = self.DicActiveComData[key]
        end
    end
    if data ~= nil then
        for i = 1,#data.ListTask do
            if data.ListTask[i].CfgId == cfgId then
                return data.ListTask[i]
            end
        end
    end
    return nil
end

-- Update red dot data
function ServerActiveSystem:UpdateRedPoint()
    self.DicActiveComData:Foreach(function(k, v)
        local haveRedPoint = false
        for i = 1, #v.ListTask do
            if v.ListTask[i].RewardState == 1 then
                haveRedPoint = true
                break
            end
        end
        if self.DicRedPoint:ContainsKey(k) then
            self.DicRedPoint[k] = haveRedPoint
        end
    end)
end

-- Get the remaining time of the seven-day red envelope event
-- Get the remaining time
function ServerActiveSystem:GetLeftTime()
    return self.RpLeftTime - (Time.GetRealtimeSinceStartup()- self.RpSyncTime)
end

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Request activity list
function ServerActiveSystem:ReqOpenServerSpecAc()
    GameCenter.Network.Send("MSG_OpenServerAc.ReqOpenServerSpecAc")
end

-- Request for a prize
function ServerActiveSystem:ReqOpenServerSpecReward(cfgId)
    GameCenter.Network.Send("MSG_OpenServerAc.ReqOpenServerSpecReward", {id = cfgId})
end

-- Request to receive red envelopes
function ServerActiveSystem:ReqOpenServerSpecRed()
    GameCenter.Network.Send("MSG_OpenServerAc.ReqOpenServerSpecRed")
end

-- Request redemption
function ServerActiveSystem:ReqOpenServerSpecExchange(id)
    GameCenter.Network.Send("MSG_OpenServerAc.ReqOpenServerSpecReward", {type = id})
end

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Push red dots online
function ServerActiveSystem:ResOpenServerSpecRedDot(result)
    if result  == nil then
        return
    end
    -- Controls whether red dots are displayed on the main interface
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.ServerActive,result.state)
    -- Set the remaining redemption times
    if result.exchangeList ~= nil then
        for i = 1,#self.ListExChangeData do
            self.ListExChangeData[i]:ParaseMsg(result.exchangeList[i])
        end
    end
end

-- Request activity list return
function ServerActiveSystem:ResOpenServerSpecAc(result)
    if result  == nil then
        return
    end
    if result.specList ~= nil then
        for i = 1,#result.specList do
            -- Get the page type
             local data = self:GetComActiveDataByCfgId(result.specList[i].id)
             if data~= nil then
                data:ParaseMsg(result.specList[i])
             end
        end
    end
    -- Set up red envelopes to receive the total amount
    self.RpGoldNum = 0
    if result.redList ~= nil then
        for i = 1,#result.redList do
            self.RpGoldNum = self.RpGoldNum + result.redList[i]
            self.ListRedPacketData[i]:ParaseMsg(result.redList[i])
        end
    else
    end
    self.RpRewardState = result.redState
    -- Set redemption data
    if result.exchangeList ~= nil then
        for i = 1,#self.ListExChangeData do
            self.ListExChangeData[i]:ParaseMsg(result.exchangeList[i])
        end
    end
    self:UpdateRedPoint()
    -- Get the current server opening time
    local time = math.floor( GameCenter.HeartSystem.ServerTime - result.openTime )
    self.CurDay = math.floor( time/(24*3600) ) + 1
    local totalDay = tonumber(DataConfig.DataGlobal[1572].Params)
    local liveSeconds = totalDay * (24 * 60 *60)

    local seconds = 24 * 3600
    local hour, min, sec = TimeUtils.GetStampTimeHHMMSS(math.floor(GameCenter.HeartSystem.ServerTime))
    local curSeconds = hour * 3600 + min * 60 + sec
    self.RpLeftTime = liveSeconds - ((self.CurDay - 1) * (24 * 60 *60) + curSeconds )
    self.RpSyncTime = Time.GetRealtimeSinceStartup()
    -- Send update UI message
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SERVERACTIVEFORM_UPDATE)
end

-- Receive the prizes in the first four activities
function ServerActiveSystem:ResOpenServerSpecReward(result)
    if result  == nil then
        return
    end
    local taskData = self:GetTaskDataByCfgId(result.id)
    if taskData ~= nil then
        taskData.RewardState = 2
        taskData.LeftNum = result.remain
    end
    -- Send update UI message
    self:UpdateRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SERVERACTIVEFORM_UPDATE)
end

-- Return after receiving the red envelope
function ServerActiveSystem:ResOpenServerSpecRed(result)
    if result  == nil then
        return
    end
    -- Send update UI message
    self.IsRewardRedPacket = true
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SERVERACTIVEFORM_UPDATE)
end

-- Redeem back
function ServerActiveSystem:ResOpenServerSpecExchange(result)
    if result  == nil then
        return
    end
    -- Send update UI message
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SERVERACTIVEFORM_UPDATE)
end
return ServerActiveSystem