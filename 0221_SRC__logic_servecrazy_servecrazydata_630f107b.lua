
------------------------------------------------
-- Author:
-- Date: 2019-07-11
-- File: ServeCrazyData.lua
-- Module: ServeCrazyData
-- Description: Server Carnival Data
------------------------------------------------
-- Quote
local TimeUtils = CS.Thousandto.Core.Base.TimeUtils;
local ItemData = require "Logic.ServeCrazy.ServeCrazyItemData"
local ServeCrazyData = {
    -- Type corresponds to the corresponding function type
    Type = 0,
    -- Open ranking type
    RankType = 0,
    -- Is the current function open?
    IsOpen = false,
    -- Whether the current function is over
    IsEnd = false,
    -- My ranking
    MyRank = 0,
    -- My level
    Mylevel = 0,
    -- Checkout time
    LeftTime = 0,
    SyncTime = 0,
    -- Settlement days How many days will the server be settled
    EndDay = 0,
    -- Duration
    HoldTime = 1,
    -- Menu button name
    MenuName = nil,
    -- Simple description
    UIDes = nil,
    -- Texture Name
    TextureName = nil,
    TexTetureName = nil,
    -- Receive description
    DicRewardDes = Dictionary:New(),
    -- Reward configuration table Id that needs to be processed by the client
    CfgId = 0,
    -- Rewards corresponding to CfgId 0: Not achieved 1: Can be collected 2: Received
    RewardState = 0,
    --
    ValueName = nil,
    -- Reward props key: Reward sequence
    DicItem = Dictionary:New(),
    -- Sort the configuration table IDs
    ListCfgId = List:New(),

    -- Quick improvement related
    ListFuncId = List:New(),
    ListFuncName = List:New(),
    ListFuncIcon = List:New(),

    -- Real-time reward status dictionary key: cfgId value: state
    DicRunTimeReward = Dictionary:New(),
    -- Subtype dictionary
    DicSubType = Dictionary:New(),

    LimitShopId = 0,
    LimitShopCondition = nil,
    LimitShopId2 = 0,
    LimitShopCondition2 = nil,
}
function ServeCrazyData:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

-- Analyze data
function ServeCrazyData:ParseCfg(cfg)
    if cfg == nil then
        return
    end
    self.Type = cfg.Type
    self.SubType = cfg.SubType
    self.RankType = cfg.RankType
    self.ValueName = cfg.ShowName
    self.IsOpen = false
    self.ListCfgId:Add(cfg.Id)
    self.DicRewardDes:Add(cfg.Id,cfg.Showstring)
    --self.DicRunTimeReward:Add(cfg.Id,0)
    self.DicSubType:Add(cfg.Id,cfg.SubType)
    local list = Utils.SplitStr(cfg.Rew,';')
    for i = 1,#list do
        local item = ItemData:New()
        item:Parase(list[i])
        local listItem = nil
        if self.DicItem:ContainsKey(cfg.Id) then
            listItem = self.DicItem[cfg.Id]
            listItem:Add(item)
        else
            listItem = List:New()
            listItem:Add(item)
            self.DicItem:Add(cfg.Id,listItem)
        end 
    end
    self:ParseRankCfg()
end

function ServeCrazyData:AddData(cfg)
    if cfg == nil then
        return
    end
    self.SubType = cfg.SubType
    self.ListCfgId:Add(cfg.Id)
    self.DicRewardDes:Add(cfg.Id,cfg.Showstring)
    --self.DicRunTimeReward:Add(cfg.Id,0)
    self.DicSubType:Add(cfg.Id,cfg.SubType)
    local list = Utils.SplitStr(cfg.Rew,';')
    for i = 1,#list do
        local item = ItemData:New()
        item:Parase(list[i])
        local listItem = nil
        if self.DicItem:ContainsKey(cfg.Id) then
            listItem = self.DicItem[cfg.Id]
            listItem:Add(item)
        else
            listItem = List:New()
            listItem:Add(item)
            self.DicItem:Add(cfg.Id,listItem)
        end 
    end
end

function ServeCrazyData:ParseRankCfg()
    local cfg = DataConfig.DataNewSeverRank[self.Type]
    if cfg == nil then
        return nil
    end
    self.MenuName = cfg.Showname
    self.UIDes = cfg.Des
    self.EndDay = cfg.ServerEndTime
    self.HoldTime = cfg.Time
    self.TexTetureName = cfg.DesTexture
    self.TextureName = cfg.ShowTexture
    self.LimitShopId = cfg.OpenLimitShop
    self.LimitShopCondition = cfg.LimitShopCondition
    self.LimitShopId2 = cfg.OpenLimitShop2
    self.LimitShopCondition2 = cfg.LimitShopCondition2
    self.ListFuncIcon:Clear()
    self.ListFuncName:Clear()
    self.ListFuncId:Clear()
    self.ListFuncName:Add(cfg.Iconname1)
    self.ListFuncName:Add(cfg.Iconname2)
    self.ListFuncName:Add(cfg.Iconname3)
    self.ListFuncIcon:Add(cfg.Icon1)
    self.ListFuncIcon:Add(cfg.Icon2)
    self.ListFuncIcon:Add(cfg.Icon3)
    self.ListFuncId:Add(cfg.Path1)
    self.ListFuncId:Add(cfg.Path2)
    self.ListFuncId:Add(cfg.Path3)
end

-- parse message data
function ServeCrazyData:ParaseMsg(msg)
    self.MyRank = msg.rank
    self.Mylevel = msg.curValue
    self.CfgId = 0--msg.level
    self.RewardState = 0--msg.state
    if msg.pList ~= nil then
        for i = 1,#msg.pList do
            if self.DicRunTimeReward:ContainsKey(msg.pList[i].id) then
                self.DicRunTimeReward[msg.pList[i].id] = msg.pList[i].state
            else
                self.DicRunTimeReward:Add(msg.pList[i].id,msg.pList[i].state) 
            end
            if msg.pList[i].state == 1 then
                -- Display the red dots on the main interface Icon
                --GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.ServeCrazy,true)
            end
        end
    end
end

-- Set the function to enable status
function ServeCrazyData:SetFunctionState()
    -- What day is the current server opening
    local curOpenTime = Time.GetOpenSeverDay()--GameCenter.ServeCrazySystem:GetCurOpenTime()
    local hour = TimeUtils.GetStampTimeHHNotZone(math.floor( GameCenter.HeartSystem.ServerZoneTime ))
    if curOpenTime<0 then
        return
    end
    if self.Type ==1 then
        if curOpenTime <=self.EndDay then
            self.IsOpen = true
            -- Determine whether the function is over
            if curOpenTime == self.EndDay then
                if hour >= GameCenter.ServeCrazySystem.ReFreshTime then
                    -- Determine whether it is greater than the refresh time. The event ends
                    self.IsEnd = true
                else 
                    self.IsEnd = false                  
                end
            end
        else
            -- The current activity has ended
            self.IsOpen = true
            self.IsEnd = true
        end
    else
        if curOpenTime <= self.EndDay then
            if curOpenTime == self.EndDay then
                -- The activity has come to an end. Determine whether it has exceeded the refresh time
                self.IsOpen = true
                if hour >= GameCenter.ServeCrazySystem.ReFreshTime then
                    -- Refresh time exceeded
                    self.IsEnd = true
                else
                    self.IsEnd = false
                end
            elseif self.EndDay - curOpenTime == self.HoldTime then
                -- Now the time is on the first day of the event. Determine whether it has been the refresh time for the event.
                self.IsEnd = false
                -- The planner said it would add one hour
                if hour>= GameCenter.ServeCrazySystem.ReFreshTime + 1 then
                    -- Refresh time has already started
                    self.IsOpen = true
                else
                    -- The event has not started yet
                    self.IsOpen = false
                end
            elseif self.EndDay - curOpenTime>1 then
                self.IsOpen = false
            end
        else 
            self.IsOpen = true
            self.IsEnd = true
        end
    end
    if self.IsOpen and not self.IsEnd then
        -- Calculate the end countdown
        local seconds = 23 * 3600
        local min = TimeUtils.GetStampTimeMMNotZone(math.ceil( GameCenter.HeartSystem.ServerZoneTime ))
        local sec = TimeUtils.GetStampTimeSSNotZone(math.ceil( GameCenter.HeartSystem.ServerZoneTime ))
        local curSeconds = hour * 3600 + min * 60 + sec
        local allSeconds = 24 * 3600
        self.LeftTime = (allSeconds- curSeconds) + seconds + (self.EndDay - curOpenTime - 1)*allSeconds
        self.SyncTime = Time.GetRealtimeSinceStartup()
    end
end

-- Get reward description based on id
function ServeCrazyData:GetRewardDesById(id)
    if self.DicRewardDes:ContainsKey(id) then
        return self.DicRewardDes[id]
    end
    return nil
end

-- Get real-time reward status based on id
function ServeCrazyData:GetRunTimeRewardState(id)
    if self.DicRunTimeReward:ContainsKey(id) then
        return self.DicRunTimeReward[id]
    end
    return 0
end

function ServeCrazyData:SetRunTimeRewardState(id, state)
    if self.DicRunTimeReward:ContainsKey(id) then
        self.DicRunTimeReward[id] = state
    end
end

function ServeCrazyData:HaveReward()
    local isHave = false
    self.DicRunTimeReward:Foreach(function(k, v)
        if v == 1 then
            isHave = true
        end
    end)
    return isHave
end

-- Get subType type according to id
function ServeCrazyData:GetSubType(id)
    if self.DicSubType:ContainsKey(id) then
        return self.DicSubType[id]
    end
    -- The default is 1
    return 1
end

function ServeCrazyData:GetSortCfgIdList()
    local dicSort = Dictionary:New()
    for i = 1,#self.ListCfgId do
        if self.DicRunTimeReward:ContainsKey(self.ListCfgId[i]) then
            local sort = 0
            local state = self.DicRunTimeReward[self.ListCfgId[i]]
            if state == 0 then
                sort = 1000
            elseif state == 1 then
                sort = 0
            elseif state == 2 then
                sort = 2000
            end
            dicSort:Add(self.ListCfgId[i],sort)
        else
            dicSort:Add(self.ListCfgId[i],1000)
        end
    end
     self.ListCfgId:Sort(function(a,b)
        local sort1 = dicSort[a]
        local sort2 = dicSort[b]
        return sort1 + a <sort2 + b
     end )
    return self.ListCfgId
end

-- Get the remaining time
function ServeCrazyData:GetLeftTime()
    if self.LeftTime == 0 then
        return -1
    end
    return self.LeftTime - (Time.GetRealtimeSinceStartup()- self.SyncTime)
end

-- Get reward prop list by configuring table id
function ServeCrazyData:GetRewardItems(cfgId)
    if self.DicItem:ContainsKey(cfgId) then
        return self.DicItem[cfgId]
    end
    return nil
end

return ServeCrazyData