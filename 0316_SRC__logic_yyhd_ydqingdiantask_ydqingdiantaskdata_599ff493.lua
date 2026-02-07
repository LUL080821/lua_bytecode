------------------------------------------------
-- Author:
-- Date: 2020-10-16
-- File: YDQingDianTaskData.lua
-- Module: YDQingDianTaskData
-- Description: Celebration mission data
------------------------------------------------
local BaseData = require("Logic.YYHD.YYHDBaseData")
local ItemData = require("Logic.YYHD.YYHDItemData")
local YDQingDianTaskData = {
    -- Celebration Coin ID
    CoinId = 0,
    TaskList = List:New(),
}

function YDQingDianTaskData:New(typeId)
    local _n = Utils.DeepCopy(self)
    local _mn = setmetatable(_n, {__index = BaseData:New(typeId)})
    return _mn
end

-- Parse activity configuration data
function YDQingDianTaskData:ParseSelfCfgData(jsonTable)
    self.TaskList:Clear()
    self.CoinId = jsonTable.coinId
    if jsonTable.tasks ~= nil then
        for i = 1, #jsonTable.tasks do
            local _task = jsonTable.tasks[i]
            local _id = _task.id
            local _type = _task.taskType
            local _tCount = _task.reach
            local _itemList = List:New()
            for m = 1, #_task.item do
                local _itemData = ItemData:New(_task.item[m])
                local _item = {Id = _itemData.ItemID, Num = _itemData.ItemCount, IsBind = _itemData.IsBind}
                _itemList:Add(_item)
            end
            local _rewardItem = nil
            if #_itemList > 0 then
                _rewardItem = _itemList[1]
            end
            local _data = {Id = _id, Type = _type, Count = 0, TCount = _tCount, Des = nil, RewardItem = _rewardItem, State = 0, FuncId = 0}
            self.TaskList:Add(_data)
        end
    end
end

-- Analyze the data of active players
function YDQingDianTaskData:ParsePlayerData(jsonTable)
    for i = 1,#jsonTable do
        local _data = jsonTable[i]
        local _task = self:GetTaskById(_data.id)
        if _data.prc > _task.TCount then
            _task.Count = _task.TCount
        else
            _task.Count = _data.prc
        end
        _task.State = _data.isGet
        if _data.isGet == 1 then
            if _task.Count >= _task.TCount then
                -- Can be collected
                _task.State = 0
            end
        end
        local _cfg = DataConfig.DataActivityTaskType[_task.Type]
        if _cfg ~= nil then
            _task.Des = UIUtils.CSFormat(_cfg.Name, _task.TCount, _task.Count, _task.TCount)
            _task.FuncId = _cfg.FunctionID
        end
    end
    self:SortTask()
end

-- Get task data
function YDQingDianTaskData:GetTaskById(id)
    local _ret = nil
    for i = 1, #self.TaskList do
        local _task = self.TaskList[i]
        if _task.Id == id then
            _ret = _task
            break
        end
    end
    return _ret
end

-- Sort
function YDQingDianTaskData:SortTask()
    self.TaskList:Sort(function(a,b)
        return a.State * 100 + a.Id < b.State * 100 + b.Id
     end )
end

-- Refresh data
function YDQingDianTaskData:RefreshData()
    self:CheckRedPoint()
end

-- Check the red dots
function YDQingDianTaskData:CheckRedPoint()
    self:RemoveRedPoint(nil)
    if self.TaskList ~= nil then
        for i = 1, #self.TaskList do
            local _task = self.TaskList[i]
            if _task.State == 0 then
                self:AddRedPoint(_task.Id, nil, nil, nil, true, nil)
            end
        end
    end
end

-- Send a reward request
function YDQingDianTaskData:ReqChouJiang(id)
    local _json = string.format("{\"id\":%d}", id)
    GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {type = self.TypeId, data = _json})
end

-- Processing operational activities return
function YDQingDianTaskData:ResActivityDeal(jsonTable)
    local _task = self:GetTaskById(jsonTable.id)
    _task.State = jsonTable.isGet
    if jsonTable.isGet == 1 then
        if _task.Count >= _task.TCount then
            -- Can be collected
            _task.State = 0
        end
    end
    self:SortTask()
    self:CheckRedPoint()
    -- Refresh activity list
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_HDLIST)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_QINGDIAN_TASK_RESULT)
end

return YDQingDianTaskData
