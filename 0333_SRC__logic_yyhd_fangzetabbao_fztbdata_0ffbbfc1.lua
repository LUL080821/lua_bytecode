------------------------------------------------
-- Author:
-- Date: 2021-11-12
-- File: FZTBData.lua
-- Module: FZTBData
-- Description: Operational activity model data
------------------------------------------------
local BaseData = require("Logic.YYHD.YYHDBaseData")

local FZTBData = {
    ShowBigRewrdsList = nil,
    MapDataList = {},    
    DrawItemId = nil,
    DrawItemNeedCost = nil,
    PlayerData = nil,
    IsJumpAskBuy = false,
}

local MapData = nil

function FZTBData:New(typeId)
    local _n = Utils.DeepCopy(self)
    local _mn = setmetatable(_n, {__index = BaseData:New(typeId)})
    return _mn
end


-- Parse activity configuration data
function FZTBData:ParseSelfCfgData(jsonTable)
    self.DrawItemId = jsonTable.drawItemId
    self.DrawItemNeedCost = jsonTable.drawItemNeedLingyu
    if jsonTable.FZTBMapList then
        for i = 1, #jsonTable.FZTBMapList do
            self.MapDataList[i] = MapData:New(jsonTable.FZTBMapList[i])
        end
    else
        Debug.LogError(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> No Fangze Treasure Tabernacle Map Data<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
    end
end

-- Analyze the data of active players
function FZTBData:ParsePlayerData(jsonTable)
    self.PlayerData = jsonTable
end

-- Refresh data
function FZTBData:RefreshData()
    
end

-- Send a lottery request
function FZTBData:ReqChouJiang(mapIndex , cellIndex)
    local _json = string.format("{\"operate\":1,\"mapIndex\":%d,\"cellIndex\":%d}",mapIndex - 1, cellIndex)
    GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {type = self.TypeId, data = _json})
end

-- Send lottery interface to open a request
function FZTBData:ReqDrawOpenView(mapIndex , cellIndex)
    local _json = string.format("{\"operate\":3,\"mapIndex\":%d,\"cellIndex\":%d}",mapIndex - 1, cellIndex)
    GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {type = self.TypeId, data = _json})
end

-- Send a reset request
function FZTBData:ReqReSetMap(mapIndex)
    local _json = string.format("{\"operate\":2,\"mapIndex\":%d}", mapIndex - 1)
    GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {type = self.TypeId, data = _json})
end

function FZTBData:ResActivityDeal(_jsonTable)
    if _jsonTable.operate == 1 then
        if self.PlayerData.mapDataMap then
            self.PlayerData.mapDataMap[tostring(_jsonTable.mapIndex)] = _jsonTable
        else
            self.PlayerData.mapDataMap = {}
            self.PlayerData.mapDataMap[tostring(_jsonTable.mapIndex)] = _jsonTable
        end
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FZTB_REFRESH , _jsonTable.mapIndex)
    elseif _jsonTable.operate == 2 then
        if self.PlayerData.mapDataMap then
            self.PlayerData.mapDataMap[tostring(_jsonTable.mapIndex)] = _jsonTable
        else
            self.PlayerData.mapDataMap = {}
            self.PlayerData.mapDataMap[tostring(_jsonTable.mapIndex)] = _jsonTable
        end
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FZTB_REFRESH , _jsonTable.mapIndex)
    elseif _jsonTable.operate == 3 then
        if self.PlayerData.mapDataMap then
            self.PlayerData.mapDataMap[tostring(_jsonTable.mapIndex)] = _jsonTable
        else
            self.PlayerData.mapDataMap = {}
            self.PlayerData.mapDataMap[tostring(_jsonTable.mapIndex)] = _jsonTable
        end
        local cellId = _jsonTable.cellIndex
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FZTB_OPENDRAWVIEW , cellId)
    end
end



function FZTBData:GetBigShowRewrdsList()
    local _list = List:New()
    for i = 1, #self.MapDataList do
        _list:Add( self.MapDataList[i].RewardsList[1])
    end
    return  _list
end

function FZTBData:GetShowRewrdsList()
    local _list = List:New()
    for i = 1, #self.MapDataList do
        _list:Add( self.MapDataList[i].RewardsList[1])
    end
    return  _list
end


function FZTBData:GetOpenMapId()
    local _list = List:New()
    _list:Add(1)
    return  _list
end


function FZTBData:GetCurNeedPropCost(mapid , cell)
    local times = -1 
    if self.PlayerData.mapDataMap and self.PlayerData.mapDataMap[tostring(mapid - 1)] then
        local _data = self.PlayerData.mapDataMap[tostring(mapid - 1)]
        if _data.consumeMap and _data.consumeMap[tostring(cell)] then
            times = _data.consumeMap[tostring(cell)]
        end
    end
    return  times
end

-------------------------------------MAP--DATA-----------------------------
local Reward = nil
MapData = {
    ClearRewrdCount = nil,
    OpenNextNeedNum = nil,
    ReSetNeedCost = nil,
    RewardsList = {},
    RewardsCostList = {},
}

function MapData:New(data)
    local _m = Utils.DeepCopy(self)
    _m.ClearRewrdCount = data.allFinishDrawItemNum
    _m.OpenNextNeedNum = data.openNextMapDrawNum
    _m.ReSetNeedCost = data.resetNeedlingyu
    for i = 1,  #data.FZTBMapRewardBeanList do
        _m.RewardsList[i] = Reward:New(data.FZTBMapRewardBeanList[i])
    end
    for i = 1,  #data.costNumList do
        _m.RewardsCostList[i] = data.costNumList[i]
    end
    return _m
end


Reward = {
    ItemId = nil,
    isBlend = nil,
    Num = nil,
    Occ = nil,
}

function Reward:New(data)
    local _m = Utils.DeepCopy(self)
    _m.ItemId = data.reward[1].i
    _m.isBlend = data.reward[1].b
    _m.Num = data.reward[1].n
    _m.Occ = data.reward[1].c
    return _m
end
-------------------------------------MAP--DATA-----------------------------

return FZTBData