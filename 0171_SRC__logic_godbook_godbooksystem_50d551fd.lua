
------------------------------------------------
-- Author:
-- Date: 2019-04-29
-- File: GodBookSystem.lua
-- Module: GodBookSystem
-- Description: Heavenly Book System
------------------------------------------------
local AmuletData = require "Logic.GodBook.AmuletData"
local GodBookData = require "Logic.GodBook.GodBookData"

local GodBookSystem = {
    ActiveAmuletID = 0,                                         -- Save the activated spell id
    OpenAmuletInfoList = List:New(),                            -- The talisman in activation
    OpenAmuletIdList = List:New(),                              -- List of talisman ids in activation
}

function GodBookSystem:Initialize()
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_FIRSTENTERMAP, self.OnFirstEnterMap, self)
end

function GodBookSystem:UnInitialize()
    self.OpenAmuletIdList:Clear()
    self.OpenAmuletInfoList:Clear()
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_FIRSTENTERMAP, self.OnFirstEnterMap, self)
end

-- Is the talisman activateable?
function GodBookSystem:GetAmuletActiveStatus(id)
    local _active = true
    local _message = nil
    if not self.OpenAmuletIdList:Contains(id) then
        return false
    end
    local _amuletData = {}
    for i = 1, self.OpenAmuletInfoList:Count() do
        if self.OpenAmuletInfoList[i].ID == id then
            _amuletData = self.OpenAmuletInfoList[i].TaskList
            if self.OpenAmuletInfoList[i].Status then
                return false
            end
            break
        end
    end
    for i=1,_amuletData:Count() do
        if not (_amuletData[i].Status == AmuletTaskStatusEnum.RECEIVED) then
            return false
        end
    end

    local _cfg = DataConfig.DataAmulet[id]
    if _cfg.Condition and _cfg.Condition ~= "" then
        
        local _params = Utils.SplitStr(_cfg.Condition, "_")
        if tonumber(_params[1]) ==  AmuletActiveConditionEnum.LevelComplete then
            local _p = GameCenter.GameSceneSystem:GetLocalPlayer()
            if tonumber(_params[2]) <= _p.Level then
                _active = true
            else
                _active = false
                _message = UIUtils.CSFormat(DataConfig.DataMessageString.Get("GodBookOpenTips"), _params[2])
            end
        elseif tonumber(_params[1]) == AmuletActiveConditionEnum.TaskComplete then
            if GameCenter.LuaTaskManager:IsMainTaskOver(tonumber(_params[2])) then
                _active = true
            else
                _active = false
                local _taskCfg = DataConfig.DataTask[tonumber(_params[2])]
                _message = UIUtils.CSFormat( DataConfig.DataMessageString.Get("GodBookTaskOpenTips"), _taskCfg.TaskName)
            end
        elseif tonumber(_params[1]) == AmuletActiveConditionEnum.AchievementComplete then
            if GameCenter.AchievementSystem:IsFinish(tonumber(_params[2])) then
                _active = true
            else
                _active = false
                local _achievementCfg = DataConfig.DataAchievement[tonumber(_params[2])]
                _message = UIUtils.CSFormat(DataConfig.DataMessageString.Get("GodBookAchieveOpenTips"), _achievementCfg.Name)
            end
        end
    end
    return _active, _message
end

-- Get the corresponding task list of talismans
function GodBookSystem:GetTaskList(id)
    if not self.OpenAmuletIdList:Contains(id) then
        return nil
    end
    for i = 1, self.OpenAmuletInfoList:Count() do
        if self.OpenAmuletInfoList[i].ID ==id then
            return self.OpenAmuletInfoList[i].TaskList
        end
    end
end

-- Obtain spell information based on ID
function GodBookSystem:GetAmuletInfo(id)
    for i = 1, self.OpenAmuletInfoList:Count() do
        if self.OpenAmuletInfoList[i].ID == id then
            return self.OpenAmuletInfoList[i]
        end
    end
end

-- Refresh the task
function GodBookSystem:RefreshTask(index, info)
    local _list = self.OpenAmuletInfoList[index].TaskList
    for j = 1, #_list do
        if _list[j].ID == info.id then
            self.OpenAmuletInfoList[index].TaskList[j]:RefreshData(info)
            break
        end
    end
    if info.status == AmuletTaskStatusEnum.RECEIVED then
        self.OpenAmuletInfoList[index]:SortData()
    end
end

-- Red dot conditions
function GodBookSystem:IsShowRedPoint(id)
    local _showRedPoint = false
    local _tastList = self:GetTaskList(id)
    if not _tastList then
        return false
    end
    for i = 1, _tastList:Count() do
        if _tastList[i].Status == AmuletTaskStatusEnum.Available then
            _showRedPoint = true
        end
    end
    return _showRedPoint
end

-- Set red dots
function GodBookSystem:SetRedPoint()
    local _conditions = List:New();
    local _showRedPoint = false
    for i = 1, self.OpenAmuletInfoList:Count() do
        local _active = self:GetAmuletActiveStatus(self.OpenAmuletInfoList[i].ID)
        if _active or self:IsShowRedPoint(self.OpenAmuletInfoList[i].ID) then
            _showRedPoint = true
            break
        end
    end
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.GodBook, _showRedPoint)
end

-- Is the talisman activated
function GodBookSystem:IsActive(id)
    for i = 1, #self.OpenAmuletInfoList do
        if id == self.OpenAmuletInfoList[i].ID then
            return self.OpenAmuletInfoList[i].Status
        end
    end
    return false
end


-- MSG
-- Request for information about the book of heaven
function GodBookSystem:ReqGodBookInfo()
    GameCenter.Network.Send("MSG_GodBook.ReqGodBookInfo",{})
end

-- Request to activate the talisman
function GodBookSystem:ReqActiveAmulet(id)
    local _req = {}
    _req.amuletId = id
    self.ActiveAmuletID = id
    GameCenter.Network.Send("MSG_GodBook.ReqActiveAmulet", _req)
end

-- Request a reward
function GodBookSystem:ReqGetReward(id)
    local _req = {}
    _req.conditonId = id
    GameCenter.Network.Send("MSG_GodBook.ReqGetReward", _req)
end

function GodBookSystem:AmuletTaskIsGet(taskList, active)
    local _num = 0
    for i = 1, #taskList do
        if taskList[i].Status == 1 then
            return true
        end
        if taskList[i].Status == 3 then
            _num = _num + 1
        end
    end
    return _num == #taskList and (not active)
end

-- Return to the Book of Heaven
function GodBookSystem:GS2U_ResBookInfo(msg)
    if msg.amulets ~= nil then
        self.OpenAmuletIdList:Clear()
        self.OpenAmuletInfoList:Clear()
        for i = 1, #msg.amulets do
            self.OpenAmuletIdList:Add(msg.amulets[i].id)
            self.OpenAmuletInfoList:Add(GodBookData:New(msg.amulets[i]))
        end
    end
    table.sort( self.OpenAmuletInfoList, function(a, b) 
        return a.ID < b.ID
    end)
    if self.ActiveAmuletID ~= 0 then
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_AMULETINFO, self.ActiveAmuletID)
        self.ActiveAmuletID = 0
    else
        local _param = AmuletEnum.LuoFan
        for i = 1, #self.OpenAmuletInfoList do
            if self:AmuletTaskIsGet(self.OpenAmuletInfoList[i].TaskList, self.OpenAmuletInfoList[i].Status) then
                _param = self.OpenAmuletInfoList[i].ID
                break
            end
        end
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_AMULETINFO, _param)
    end
    self:SetRedPoint()
end

-- Receive rewards and return
function GodBookSystem:GS2U_ResGetReward(msg)
    local _cfg = DataConfig.DataAmuletCondition[msg.id]
    if not _cfg then
        return
    end
    for i = 1, self.OpenAmuletInfoList:Count() do
        if self.OpenAmuletInfoList[i].ID == _cfg.AmuletId then
            self:RefreshTask(i, {id = msg.id, progress = 0, status = AmuletTaskStatusEnum.RECEIVED})
            break
        end
    end

    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_AMULETPANEL, _cfg.AmuletId)
    self:SetRedPoint()
end

-- Talisman condition status update
function GodBookSystem:GS2U_ResUpdateCondition(msg)
    -- Debug.LogError("GS2U_ResUpdateCondition")
    for i = 1, #self.OpenAmuletInfoList do
        local _taskList = self.OpenAmuletInfoList[i].TaskList;
        for j = 1, #_taskList do
            if msg.id == _taskList[j].ID then
                _taskList[j].Status = AmuletTaskStatusEnum.Available;
            end
        end
    end
    self:SetRedPoint()
end

-- The first time I entered the game scene
function GodBookSystem:OnFirstEnterMap()
    self.ReqGodBookInfo();
end

return GodBookSystem
