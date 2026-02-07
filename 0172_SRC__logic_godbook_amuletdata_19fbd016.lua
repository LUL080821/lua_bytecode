
------------------------------------------------
-- Author:
-- Date: 2019-04-29
-- File: AmuletData.lua
-- Module: AmuletData
-- Description: Talisman data
------------------------------------------------
local AmuletData = {
    ID = 0,                         -- The ID corresponding to the DataAmuletCondition table
    Progress = 0,                   -- Task completion progress
    Status = 0,                     -- Status 1 Can be collected 2 Cannot be collected 3 Received
    TargetValue = 0,                -- Task Target Value
}

function AmuletData:New(info)
    local _m = Utils.DeepCopy(self)
    _m.ID = info.id
    _m:RefreshData(info)
    _m:SetTargetValue()
    return _m
end

-- Refresh data
function AmuletData:RefreshData(info)
    if info.Status == AmuletTaskStatusEnum.RECEIVED then
        self.Status = AmuletTaskStatusEnum.RECEIVED
        self.Progress = self.TargetValue
    else
        self.Status = info.status
        self.Progress = info.progress
    end
end

-- Set the task target value
function AmuletData:SetTargetValue()
    local _cfg = DataConfig.DataAmuletCondition[self.ID]
    if not _cfg then
        return
    end

    self.TargetValue = _cfg.StatisticsNumber
end

return AmuletData