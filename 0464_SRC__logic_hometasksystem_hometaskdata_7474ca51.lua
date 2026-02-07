
------------------------------------------------
-- Author:
-- Date: 2021-06-17
-- File: HomeTaskData.lua
-- Module: HomeTaskData
-- Description: Daily task data
------------------------------------------------
-- Quote
local HomeTaskData = {
    Id = 0,
    Count = 0,
    Type = 0,
    Des = "",
    -- 0=Not completed 1=Not received 2=Finished
    State = 0,
    Sort = 0,
    OpenId = 0,
    RewardList = List:New(),
}

function HomeTaskData:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

function HomeTaskData:ParaseMsg(msg, cfg)
    self.Id = msg.id
    self.Count = msg.process
    self.State = msg.state
    if cfg ~= nil then
        self.Sort = cfg.BranchSort
        self.Type = cfg.Type
        self.OpenId = cfg.OpenPanel
        self.Des = UIUtils.CSFormat(cfg.ConditionsDescribe, msg.process)
        self.RewardList:Clear()
        local _reward = Utils.SplitStr(cfg.TaskReward, ';')
        if _reward ~= nil then
            for i = 1, #_reward do
                local _list = Utils.SplitNumber(_reward[i], '_')
                self.RewardList:Add({ID = _list[1], Num = _list[2], IsBind = false})
            end
        end
    end
end

function HomeTaskData:Updata(msg, cfg)
    self.Count = msg.process
    self.State = msg.state
    if cfg ~= nil then
        self.Des = UIUtils.CSFormat(cfg.ConditionsDescribe, msg.process)
    end
end

return HomeTaskData
