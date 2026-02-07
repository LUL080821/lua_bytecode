
------------------------------------------------
-- author:
-- Date: 2019-12-16
-- File: ZcTaskData.lua
-- Module: ZcTaskData
-- Description: VIP weekly data
------------------------------------------------
-- Quote
local ZcTaskData = {
    Id = 0,
    -- Task Icon ID
    IconId = 0,
    -- Total available currency
    TolCoin = 0,
    -- Total number of tasks
    TolTaskNum = 0,
    -- key:tabId ---Task List {Id:Task Id Des:Task Target CurNum:Current number of accomplished TotalNum:Num required to achieve CoinNum:Reward currency number IsFinish:Is it completed OpenUI:Open interface Id }
    DicTask = Dictionary:New(),

}
function ZcTaskData:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

-- Analyze data
function ZcTaskData:ParseCfg(cfg)
    if cfg ~= nil then
        local types = Utils.SplitStr(cfg.TaskNum, '_')
        self.Id = tonumber(types[1])
        local key = tonumber(types[2])
        -- Add a task
        local taskId = cfg.Id
        local curNum = 0
        local condition = Utils.SplitStr(cfg.Condition,'_')
        local totalNum = tonumber(condition[#condition])
        local coinNum = cfg.Reward
        local des = cfg.Desc
        local openId = cfg.FunctionId
        local isFinish = false
        local task = {Id = taskId ,CurNum = curNum,TotalNum = totalNum, CoinNum = coinNum, IsFinish = isFinish, Des = des, OpenUI = openId}
        local taskList = nil
        if self.DicTask:ContainsKey(key) then
            taskList = self.DicTask[key]
            taskList:Add(task)
        else
            taskList = List:New()
            taskList:Add(task)
            self.DicTask:Add(key,taskList)
        end
        -- local gCfg = DataConfig.DataGlobal[GlobalName.VIPWeekMoneyIcon]
        -- if gCfg ~= nil then
        --     self.IconId = tonumber(gCfg.Params)
        -- end
        self.IconId = cfg.Icon
    end
end

function ZcTaskData:ParaseMsg(msg)
    if msg ~= nil then
        for i = 1,#msg do
            self:UpdateTask(msg[i].id,msg[i].prog)
        end
    end
end

-- Get total currency
function ZcTaskData:GetTotalCoin()
    if self.TolCoin == 0 then
        self.DicTask:Foreach(function(k, v)
            local list = v
            for i = 1,#list do
                self.TolCoin = self.TolCoin + list[i].CoinNum
            end
        end)
    else
        return self.TolCoin
    end
    return self.TolCoin
end

-- Get the remaining currency you can claim
function ZcTaskData:GetLeftCoin()
    local coin = 0
    local haveCoin = 0
    self.DicTask:Foreach(function(k, v)
        local list = v
        for i = 1,#list do
            if list[i].IsFinish then
                haveCoin =  haveCoin + list[i].CoinNum
            end
            coin = coin + list[i].CoinNum
        end
    end)
    if self.TolCoin == 0 then
        self.TolCoin = coin
        return coin - haveCoin
    else
        return self.TolCoin - haveCoin
    end
end

-- Get the currency you have obtained
function ZcTaskData:GetRewardCoin()
    local coin = 0
    local haveCoin = 0
    self.DicTask:Foreach(function(k, v)
        local list = v
        for i = 1,#list do
            if list[i].IsFinish then
                haveCoin =  haveCoin + list[i].CoinNum
            end 
        end
    end)
    return haveCoin
end

-- Get the total number of tasks
function ZcTaskData:GetTotalTaskNum()
    if self.TolTaskNum == 0 then
        self.DicTask:Foreach(function(k, v)
            local list = v
            for i = 1,#list do
                self.TolTaskNum = self.TolTaskNum + 1
            end
        end)
    else
        return self.TolTaskNum
    end
    return self.TolTaskNum
end

-- Get the current number of tasks completed
function ZcTaskData:GetFinishTaskNum()
    local num = 0
    self.DicTask:Foreach(function(k, v)
        local list = v
        for i = 1,#list do
            if list[i].IsFinish then
                num = num + 1
            end
        end
    end)
    return num
end

-- Get the first task
function ZcTaskData:GetFirstTask()
    local keys = self.DicTask:GetKeys()
    if keys ~= nil and #keys >=1 then
        return self.DicTask[keys[1]]
    end
    return nil
end

-- Get task data
function ZcTaskData:GetTaskData(taskId)
    self.DicTask:Foreach(function(k, v)
        local list = v
        for i = 1,#list do
            if list[i].Id == taskId then
                return list[i]
            end
        end
    end)
    return nil
end

-- Have all the tasks corresponding to the current key been completed?
function ZcTaskData:IsFinishAllTask(key)
    if self.DicTask:ContainsKey(key) then
        local list = self.DicTask[key]
        if list ~= nil then
            for i = 1,#list do
                if not list[i].IsFinish then
                    return false
                end
            end
        end
    end
    return true
end

function ZcTaskData:ResetTasks()
    self.DicTask:Foreach(function(k, v)
        local list = v
        for i = 1,#list do
            list[i].IsFinish = false
            list[i].CurNum = 0
        end
    end)
end

-- Update tasks
function ZcTaskData:UpdateTask(taskId, process)
    local listKey = self.DicTask:GetKeys()
    if listKey ~= nil then
        for i = 1,#listKey do
            local list = self.DicTask[listKey[i]]
            for m = 1,#list do
                if list[m].Id == taskId then
                    if list[m].CurNum ~= process and list[m].TotalNum <= process then
                        --GameCenter.ZhouChangSystem.CurCoinNum = GameCenter.ZhouChangSystem.CurCoinNum + list[m].CoinNum
                    end
                    list[m].CurNum = process
                    if process >= list[m].TotalNum then
                        list[m].IsFinish = true
                        return true
                    end
                end
            end
        end
    end
end
return ZcTaskData