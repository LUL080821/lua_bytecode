------------------------------------------------
-- Author:
-- Date: 2019-07-15
-- File: GrowthWaySystem.lua
-- Module: GrowthWaySystem
-- Description: Growth Road System
------------------------------------------------
-- Quote
local TaskData = require "Logic.GrowthWay.GrowthWayTaskData"
local TreasureData = require "Logic.GrowthWay.GrowthWayTreasureData"
local AttrData = require "Logic.GrowthWay.GrowthWayAttrData"
local TimeUtils = CS.Thousandto.Core.Base.TimeUtils;
local GrowthWaySystem = {
    -- What day
    CurDay = 0,
    -- Remaining time for the event
    LeftTime = 0,
    SyncTime = 0,
    -- Magic weapon props Id
    FbItemId = 0,
    -- Current number of stars
    CurStarNum = 0,
    -- Treasure Box Reward
    ListTreasure = nil,
    -- Daily missions
    DicDailyTask = Dictionary:New(),
    -- Menu red dots
    DicMenuRedPoint = Dictionary:New(),

    IsShowModel = false,
    ShowModelId = 0
}

-- Initialization ranking Cfg
function GrowthWaySystem:Initialize()
    self.DicDailyTask:Clear()
    self.DicMenuRedPoint:Clear()
    DataConfig.DataNewSeverGrowup:Foreach(function(k, v)
        local task = TaskData:New()
        task:Parase(v)
        local key = v.Day
        local list = nil
        if self.DicDailyTask:ContainsKey(key) then
            list = self.DicDailyTask[key]
            list:Add(task)
        else
            list = List:New()
            list:Add(task)
            self.DicDailyTask:Add(key, list)
        end
    end)
    self.TimerEventId = GameCenter.TimerEventSystem:AddTimeStampDayEvent(10, 10, true, nil,
                            function(id, remainTime, param)
            -- It's time to get the server opening time again
            self.CurDay = Time.GetOpenSeverDay()
        end)

    -- Initialize menu button red dot
    for i = 1, GrowthWayType.Count - 1 do
        self.DicMenuRedPoint:Add(i, false)
    end
    -- Set magic weapon information
    self:SetFaBaoInfo()
end

function GrowthWaySystem:UnInitialize()
    self.ListTreasure = nil
end

function GrowthWaySystem:GetListTreasure()
    if self.ListTreasure == nil then
        self.ListTreasure = List:New()
        -- Initialization of treasure chest reward configuration
        DataConfig.DataNewSeverGrowuprew:Foreach(function(k, v)
            local treasure = TreasureData:New()
            treasure:Parase(v)
            self.ListTreasure:Add(treasure)
        end)
    end
    return self.ListTreasure
end

-- Get the total score of the corresponding key reward
function GrowthWaySystem:GetTasksScore(key)
    local score = 0
    if self.DicDailyTask:ContainsKey(key) then
        local tasks = self.DicDailyTask[key]
        for i = 1, #tasks do
            score = score + tasks[i].Cfg.Rate
        end
    end
    return score
end

-- Obtain the completed task points corresponding to the key
function GrowthWaySystem:GetFinishTasksScore(key)
    local score = 0
    if self.DicDailyTask:ContainsKey(key) then
        local tasks = self.DicDailyTask[key]
        for i = 1, #tasks do
            if tasks[i].CurCount >= tasks[i].TotalCount and tasks[i].IsRward then
                score = score + tasks[i].Cfg.Rate
            end
        end
    end
    return score
end

-- Get the task list corresponding to the key
function GrowthWaySystem:GetTaskListByIndex(day, subId)
    local listTask = self.DicDailyTask[day]
    if listTask == nil then
        return nil
    else
        listTask:Sort(function(a, b)
            if a.State == b.State then
                return a.Cfg.Id < b.Cfg.Id
            else
                return a.State < b.State
            end
        end)
        local list = List:New()
        for i = 1, #listTask do
            if listTask[i].Cfg.SubId == subId then
                list:Add(listTask[i])
            end
        end
        return list
    end
end

function GrowthWaySystem:CanSubmitTask(day, subId)
    local listTask = self.DicDailyTask[day]
    if listTask ~= nil then
        for i = 1, #listTask do
            local task = listTask[i]
            if task.CurCount >= task.TotalCount and not task.IsRward and task.Cfg.SubId == subId then
                return true
            end
        end
    end
    return false
end

function GrowthWaySystem:GetProcessParam()
    local ret = nil
    local Score = 0
    local leftScore = 0
    local _listTreasure = self:GetListTreasure()
    for i = 1, #_listTreasure do
        if self.CurStarNum >= leftScore and self.CurStarNum < _listTreasure[i].StarNum then
            ret = {
                LeftScore = leftScore,
                Score = _listTreasure[i].StarNum,
                Index = i
            }
            return ret
        end
        leftScore = _listTreasure[i].StarNum
    end
    if leftScore ~= 0 and ret == nil then
        ret = {
            LeftScore = leftScore,
            Score = _listTreasure[#_listTreasure].StarNum,
            Index = #_listTreasure
        }
    end
    return ret
end

-- Get the treasure chest reward data corresponding to index
function GrowthWaySystem:GetTreasureDataByIndex(index)
    local _listTreasure = self:GetListTreasure()
    if index <= #_listTreasure then
        return _listTreasure[index]
    end
    return nil
end

-- Obtain ordinary reward chest data
function GrowthWaySystem:GetTreasureNormalData()
    local list = List:New()
    local _listTreasure = self:GetListTreasure()
    for i = 1, #_listTreasure do
        local data = _listTreasure[i]
        if not data.IsModel then
            list:Add(data)
        end
    end
    return list
end

-- Get special reward chest data
function GrowthWaySystem:GetTreasureSpecialData()
    local ret = nil
    local _listTreasure = self:GetListTreasure()
    for i = 1, #_listTreasure do
        local data = _listTreasure[i]
        if data.IsModel then
            ret = data
        end
    end
    return ret
end

function GrowthWaySystem:IsRewardFinal()
    -- If the server opening time is greater than the time when the function exists, it will return true
    local _listTreasure = self:GetListTreasure()
    if Time.GetOpenSeverDay() > 7 then
        return true
    end
    if _listTreasure[2].IsReward and _listTreasure[#_listTreasure].IsReward then
        return true
    else
        return false
    end
end

function GrowthWaySystem:GetGrowthWayModellID()
    local _listTreasure = self:GetListTreasure()
    if not _listTreasure[2].IsReward then
        local item = _listTreasure[2].ListItem[1]
        local cfg = DataConfig.DataItem[item.Id]
        if cfg ~= nil then
            local list = Utils.SplitStr(cfg.ShowId, '_')
            return tonumber(list[1])
        end
    end

    if not _listTreasure[#_listTreasure].IsReward then
        local item = _listTreasure[#_listTreasure].ListItem[1]
        local cfg = DataConfig.DataItem[item.Id]
        if cfg ~= nil then
            local list = Utils.SplitStr(cfg.ShowId, '_')
            return tonumber(list[1])
        end
    end
end

-- Get the default parameters
function GrowthWaySystem:GetDefaultParam()
    local ret = nil
    local tempRet = nil
    local tempTask = nil
    local length = self.CurDay
    if length > self.DicDailyTask:Count() then
        length = self.DicDailyTask:Count()
    end
    for i = 1, length do
        if tempTask == nil then
            local listTask = self.DicDailyTask[i]
            if listTask ~= nil then
                for m = 1, #listTask do
                    local task = listTask[m]
                    if i == 1 and m == 1 then
                        tempRet = {
                            Day = task.Cfg.Day,
                            SubId = task.Cfg.SubId
                        }
                    end
                    if task.CurCount >= task.TotalCount and not task.IsRward then
                        ret = {
                            Day = task.Cfg.Day,
                            SubId = task.Cfg.SubId
                        }
                        return ret
                    elseif task.CurCount < task.TotalCount and tempTask == nil then
                        tempTask = task
                    end
                end
            end
        else
            ret = {
                Day = tempTask.Cfg.Day,
                SubId = tempTask.Cfg.SubId
            }
            return ret
        end
    end
    ret = tempRet
    return ret
end

-- Get the parameters corresponding to the specified number of days
function GrowthWaySystem:GetParamByDay(day)
    local ret = nil
    local tempRet = nil
    local tempTask = nil
    local listTask = self.DicDailyTask[day]
    if listTask == nil then
        return
    end

    if listTask ~= nil then
        for i = 1, #listTask do
            local task = listTask[i]
            if i == 1 then
                tempRet = {
                    Day = task.Cfg.Day,
                    SubId = task.Cfg.SubId
                }
            end
            if task.CurCount >= task.TotalCount and not task.IsRward then
                ret = {
                    Day = task.Cfg.Day,
                    SubId = task.Cfg.SubId
                }
                return ret
            elseif task.CurCount < task.TotalCount and tempTask == nil then
                tempTask = task
                ret = {
                    Day = tempTask.Cfg.Day,
                    SubId = tempTask.Cfg.SubId
                }
            end
        end
    end
    if tempTask ~= nil then
        return ret
    else
        ret = tempRet
        return ret
    end
end

-- Set magic weapon information
function GrowthWaySystem:SetFaBaoInfo()
    local str = DataConfig.DataGlobal[1552].Params
    local list = Utils.SplitStr(str, '_')
    if list ~= nil then
        self.FbItemId = tonumber(list[1])
    end
end

-- Get the magic weapon name
function GrowthWaySystem:GetFbName()
    local cfg = DataConfig.DataItem[self.FbItemId]
    if cfg ~= nil then
        return cfg.Name
    end
end

-- Get the remaining time
function GrowthWaySystem:GetLeftTime()
    return self.LeftTime - (Time.GetRealtimeSinceStartup() - self.SyncTime)
end

-- Settings menu red dot Dic
function GrowthWaySystem:UpdateMenuRedPointDic()
    -- Judge the red dot
    self.DicDailyTask:Foreach(function(k, v)
        local taskList = v
        if taskList == nil then
            return
        end
        local canReward = false
        for i = 1, #taskList do
            canReward = taskList[i]:CanRewardItem()
            if canReward then
                if self.DicMenuRedPoint:ContainsKey(k) then
                    self.DicMenuRedPoint[k] = true
                    break
                end
            end
        end
        if not canReward then
            self.DicMenuRedPoint[k] = false
        end
    end)
end

function GrowthWaySystem:GetTreasureParam()
    local retData = nil
    local preData = nil
    local list = List:New()
    local _listTreasure = self:GetListTreasure()
    for i = 1, #_listTreasure do
        if i == 1 then
            preData = _listTreasure[i]
            if not preData.IsReward then
                retData = _listTreasure[i]
            end
        else
            if preData.IsReward and not _listTreasure[i].IsReward then
                retData = _listTreasure[i]
                preData = _listTreasure[i]
            end
        end
    end
    if retData == nil then
        return nil
    else
        if #retData.ListItem > 0 then
            return retData.ListItem[1].Id
        end
    end
end

function GrowthWaySystem:Update(dt)
    local lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if lp == nil then
        return
    end
    local isShow = false
    local _listTreasure = self:GetListTreasure()
    self.DicDailyTask:Foreach(function(k, v)
        local taskList = v
        if taskList == nil then
            return
        end
        local canReward = false
        for i = 1, #taskList do
            canReward = taskList[i]:CanRewardItem()
            if canReward and self.CurDay >= k then
                isShow = true
                break
            end
        end
    end)
    if not isShow then
        -- Determine whether there is a treasure chest to collect
        for i = 1, #_listTreasure do
            local data = _listTreasure[i]
            local canReward = false
            if data.StarNum <= self.CurStarNum then
                canReward = true
            end
            if not data.IsReward then
                if canReward then
                    isShow = true
                    break
                end
            end
        end
    end
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.GrowthWay, isShow)
    if self.IsShowModel then
        if self:IsRewardFinal() then
            if lp ~= nil then
                lp.PropMoudle.GrowthWayModelId = 0
                self.ShowModelId = 0
            end
            self.IsShowModel = false
        else
            local modelId = self:GetGrowthWayModellID()
            if self.ShowModelId ~= modelId then
                if lp ~= nil then
                    lp.PropMoudle.GrowthWayModelId = self:GetGrowthWayModellID()
                    self.ShowModelId = modelId
                end
            end
        end
    else
        -- If the model is not displayed and the function is not ended and the function is not enabled
        if not self:IsRewardFinal() and
            not GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.GrowthWay) then
            -- Set the default model
            if lp ~= nil then
                local cfg = DataConfig.DataGlobal[GlobalName.New_Sever_Growup_Show_Model_Value]
                if cfg ~= nil then
                    local list = Utils.SplitStr(cfg.Params, ';')
                    local values = Utils.SplitStr(list[1], '_')
                    local modelId = tonumber(values[1])
                    lp.PropMoudle.GrowthWayModelId = modelId
                end
            end
        end
    end

end

function GrowthWaySystem:IsRewardOver()
    local _ret = true
    local _listTreasure = self:GetListTreasure()
    for i = 1, #_listTreasure do
        if not _listTreasure[i].IsReward then
            _ret = false
            break
        end
    end
    return _ret
end

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Receive points for growth
function GrowthWaySystem:ReqGrowUpPoint(index)
    GameCenter.Network.Send("MSG_OpenServerAc.ReqGrowUpPoint", {
        id = index
    })
end
-- Receive points rewards
function GrowthWaySystem:ReqGrowUpPointReward(index)
    GameCenter.Network.Send("MSG_OpenServerAc.ReqGrowUpPointReward", {
        id = index
    })
end
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- The Growth Road server actively pushes messages (send once when it is online)
function GrowthWaySystem:ResGrowUpInfo(result)
    if result == nil then
        return
    end
    local _listTreasure = self:GetListTreasure()
    -- Calculate the remaining time
    -- What day has the computing server been turned on?
    self.CurDay = Time.GetOpenSeverDay() -- GameCenter.ServeCrazySystem:GetCurOpenTime()
    local totalDay = tonumber(DataConfig.DataGlobal[1567].Params) - 1
    local liveSeconds = totalDay * (24 * 60 * 60)

    local seconds = 24 * 3600
    local hour, min, sec = TimeUtils.GetStampTimeHHMMSS(math.floor(GameCenter.HeartSystem.ServerTime))
    local curSeconds = hour * 3600 + min * 60 + sec
    self.LeftTime = liveSeconds - ((self.CurDay - 1) * (24 * 60 * 60) + curSeconds)
    self.SyncTime = Time.GetRealtimeSinceStartup()

    self.CurStarNum = result.point
    for i = 1, #result.growups do
        local key = DataConfig.DataNewSeverGrowup[result.growups[i].id].Day
        local taskList = nil
        if self.DicDailyTask:ContainsKey(key) then
            taskList = self.DicDailyTask[key]
            for m = 1, #taskList do
                if taskList[m].CfgId == result.growups[i].id then
                    taskList[m]:ParaseMsg(result.growups[i])
                end
            end
        end
    end
    -- Determine the state of treasure chest collection
    local index = 0
    local mark = 1
    local isRewardOver = true
    for i = 1, #_listTreasure do
        mark = 1 << index
        _listTreasure[i]:SetReward(result.hasGet, mark)
        index = index + 1
        --IsReward
        if not _listTreasure[i].IsReward then
            isRewardOver = false
        end
    end
    if isRewardOver then
        GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.GrowthWay, false)
    end
    self:UpdateMenuRedPointDic()
    -- GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GROWTHWAYFORM_UPDATE)
    if not self:IsRewardFinal() then
        local lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if lp ~= nil then
            lp.PropMoudle.GrowthWayModelId = self:GetGrowthWayModellID()
            self.ShowModelId = lp.PropMoudle.GrowthWayModelId
        end
        self.IsShowModel = true
    end
end
-- Update the growth path list
function GrowthWaySystem:ResGrowUpList(result)
    if result == nil then
        return
    end
    if result.growups ~= nil then
        for i = 1, #result.growups do
            local key = DataConfig.DataNewSeverGrowup[result.growups[i].id].Day
            local taskList = nil
            if self.DicDailyTask:ContainsKey(key) then
                taskList = self.DicDailyTask[key]
                for m = 1, #taskList do
                    if taskList[m].CfgId == result.growups[i].id then
                        taskList[m]:ParaseMsg(result.growups[i])
                    end
                end
            end
        end
    end
    self:UpdateMenuRedPointDic()
    -- Send message to update UI
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GROWTHWAYFORM_UPDATE, false)
end
-- Return to the road of growth after completing the task
function GrowthWaySystem:ResGrowUpPoint(result)
    if result == nil then
        return
    end
    self.CurStarNum = result.point

    local tab = nil
    local taskList = nil
    local day = DataConfig.DataNewSeverGrowup[result.id].Day
    if self.DicDailyTask:ContainsKey(day) then
        taskList = self.DicDailyTask[day]
        for m = 1, #taskList do
            if taskList[m].CfgId == result.id then
                taskList[m].IsRward = true
                taskList[m].State = 3
                tab = {
                    Day = day,
                    SubId = taskList[m].Cfg.SubId
                }
            end
        end
    end
    self:UpdateMenuRedPointDic()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GROWTHUP_TASKUPDATE, tab)
end
-- The road to growth preview rewards return
function GrowthWaySystem:ResGrowUpPointReward(result)
    if result == nil then
        return
    end
    local _listTreasure = self:GetListTreasure()
    for i = 1, #_listTreasure do
        if _listTreasure[i].CfgId == result.id then
            _listTreasure[i].IsReward = true
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GROWTHWAYFORM_UPDATE, false)
end
return GrowthWaySystem
