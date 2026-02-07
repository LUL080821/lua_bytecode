------------------------------------------------
-- Author: 
-- Date: 2020-08-08
-- File: YYHDBaseData.lua
-- Module: YYHDBaseData
-- Description: Basic data of operational activities
------------------------------------------------

-- Custom conditions
local RedPointCustomCondition = CS.Thousandto.Code.Logic.RedPointCustomCondition
-- Combat strength conditions
local RedPointFightPowerCondition = CS.Thousandto.Code.Logic.RedPointFightPowerCondition
-- Item Conditions
local RedPointItemCondition = CS.Thousandto.Code.Logic.RedPointItemCondition
-- Level conditions
local RedPointLevelCondition = CS.Thousandto.Code.Logic.RedPointLevelCondition
-- Task conditions
local RedPointTaskCondition = CS.Thousandto.Code.Logic.RedPointTaskCondition

local YYHDBaseData = {
    -- Activity Type
    TypeId = 0,
    -- Minimum open level
    MinLevel = 0,
    -- Maximum open level
    MaxLevel = 0,
    -- Tags (used to distinguish which activity tag is displayed)
    Tag = 0,
    -- Activity name
    Name = nil,
    -- Activity start time (UTC time, time zone needs to be added when performing calculations)
    BeginTime = 0,
    -- Activity end time (UTC time, time zone needs to be added when performing calculations)
    EndTime = 0,
    -- Is the event open?
    IsOpen = false,
    -- Sort values
    SortValue = 0,

    -- Red dot dataid list
    RedPointDataids = nil,
    -- Whether to display to the activity list
    IsShowInList = true,
    -- Whether to activate
    ActiveState = false,

    -- Logical Types Used
    UseLogicId = 0,
    -- UID used
    UseUIId = 0,
}

function YYHDBaseData:New(typeId)
    local _m = Utils.DeepCopy(self)
    _m.TypeId = typeId
    local _cfg = DataConfig.DataActivityYunying[typeId]
    _m.UseLogicId = _cfg.LogicId
    _m.UseUIId = _cfg.UseUiId
    return _m
end

-- Analyze basic configuration data
function YYHDBaseData:ParseBaseCfgData(jsonTable)
    self.MinLevel = jsonTable.minLv
    self.MaxLevel = jsonTable.maxLv
    self.Tag = jsonTable.tag

    --[Gosu fix]
    self.Name = GosuSDK.GetLocalizedName(jsonTable.name)

    self.BeginTime = math.floor(jsonTable.beginTime / 1000)
    self.EndTime = math.floor(jsonTable.endTime / 1000)
    self.IsOpen = jsonTable.isDelete == 0
    self.SortValue = jsonTable.sort

    -- Delete all red dots first
    self:RemoveRedPoint(nil)
    self.ActiveState = self:IsActive()
end

-- Determine whether the activity is on
function YYHDBaseData:IsActive()
    -- Is the event open?
    if not self.IsOpen then
        self.ActiveState = false
        return false
    end
    local _lpLevel = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
    -- Determine whether the player level is sufficient
    if _lpLevel < self.MinLevel or _lpLevel > self.MaxLevel then
        self.ActiveState = false
        return false
    end
    -- Determine whether it is within the turn-on time range (all UTC time, so just judge the value size directly)
    local _serverTime = GameCenter.HeartSystem.ServerTime
    if self.BeginTime > _serverTime or self.EndTime < _serverTime then
        self.ActiveState = false
        return false
    end
    self.ActiveState = true
    return true
end

function YYHDBaseData:ToUsedDataId(dataId)
    return self.Tag * 1000000000000 + self.UseLogicId * 1000000000 + dataId
end

-- Add red dot conditions and use the red dot system to make judgments
-- itemCon = {{itemid, item quantity},{itemid, item quantity}...}
-- levelCon = level value
-- fightPowerCon = combat power value
--cutCon = true or false
-- taskCon = task id
function YYHDBaseData:AddRedPoint(dataId, itemCon, levelCon, fightPowerCon, cutCon, taskCon)
    if dataId == nil then
        return
    end
    if dataId < 0 or dataId >= 1000000000 then
        Debug.LogError("Since the active red dot dataId cannot be greater than or equal to 100000000, the addition of red dots will fail!")
        return
    end
    if itemCon == nil and levelCon == nil and fightPowerCon == nil and cutCon == nil and taskCon == nil then
        return
    end
    if not self:IsActive() then
        -- No red dots added if unopened activities are
        return
    end
    -- Delete the old conditions first
    self:RemoveRedPoint(dataId)
    local _conTable = {}
    local _index = 1
    if itemCon ~= nil then
        for i = 1, #itemCon do
            _conTable[_index] = RedPointItemCondition(itemCon[i][1],itemCon[i][2])
            _index = _index + 1
        end
    end
    if levelCon ~= nil then
        _conTable[_index] = RedPointLevelCondition(levelCon)
        _index = _index + 1
    end
    if fightPowerCon ~= nil then
        _conTable[_index] = RedPointFightPowerCondition(fightPowerCon)
        _index = _index + 1
    end
    if cutCon ~= nil then
        _conTable[_index] = RedPointCustomCondition(cutCon)
        _index = _index + 1
    end
    if taskCon ~= nil then
        _conTable[_index] = RedPointTaskCondition(taskCon)
        _index = _index + 1
    end
    if _index > 1 then
        if self.RedPointDataids == nil then
            self.RedPointDataids = List:New()
        end
        self.RedPointDataids:Add(dataId)
        GameCenter.RedPointSystem:LuaAddFuncCondition(FunctionStartIdCode.YunYingHD, self:ToUsedDataId(dataId), _conTable)
    end
end

-- Delete the red dot condition, dataId is nil to clear all red dots in this activity
function YYHDBaseData:RemoveRedPoint(dataId)
    if dataId ~= nil then
        -- Delete a single
        if self.RedPointDataids ~= nil then
            self.RedPointDataids:Remove(dataId)
        end
        GameCenter.RedPointSystem:RemoveFuncCondition(FunctionStartIdCode.YunYingHD, self:ToUsedDataId(dataId))
    else
        -- Clear all
        if self.RedPointDataids ~= nil then
            for i = 1, #self.RedPointDataids do
                GameCenter.RedPointSystem:RemoveFuncCondition(FunctionStartIdCode.YunYingHD, self:ToUsedDataId(self.RedPointDataids[i]))
            end
            self.RedPointDataids:Clear()
        end
    end
end

-- Whether red dots are displayed, dataId is nil to indicate the red dots of this activity
function YYHDBaseData:IsShowRedPoint(dataId)
    if dataId == nil then
        if self.RedPointDataids ~= nil then
            for i = 1, #self.RedPointDataids do
                if GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.YunYingHD, self:ToUsedDataId(self.RedPointDataids[i])) then
                    return true
                end
            end
        end
        return false
    else
        return GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.YunYingHD, self:ToUsedDataId(dataId))
    end
end

return YYHDBaseData