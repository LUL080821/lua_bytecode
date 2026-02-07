-- Author: 
-- Date: 2020-02-26
-- File: LuckyDrawVolume.lua
-- Module: LuckyDrawVolume
-- Description: Prize Receipt Information
------------------------------------------------
local LuckyDrawVolume = {
    -- ID of the conditions for collection
    ID = nil,
    -- Description of conditions
    Desc = 0,    
    -- Maximum number of conditions
    MaxCount = 0,
    -- Conditions to proceed
    Progress = 0,
    -- Have you received it
    IsGet = 0,
    -- Configuration table data
    Cfg = nil,
    -- Function Id
    FuncId = nil,
}

function LuckyDrawVolume:New(sinfo)
    local _m = Utils.DeepCopy(self)
    _m:Init(sinfo);
    return _m;
end

function LuckyDrawVolume:Init(sinfo)
    self.ID = sinfo.id;
    self.MaxCount = sinfo.maxCount;
    self.Progress = sinfo.progress;
    self.IsGet = sinfo.isGet;
    self.Desc = DataConfig.DataWeekWelfare[self.ID].Desc;
    self.Cfg = DataConfig.DataWeekWelfare[self.ID];
    self.FuncId = tonumber(DataConfig.DataWeekWelfare[self.ID].FunctionId)
end

function LuckyDrawVolume:UpdateSdata(sinfo)
    self.ID = sinfo.id;
    self.MaxCount = sinfo.maxCount;
    self.Progress = sinfo.progress;
    self.IsGet = sinfo.isGet;
end

return LuckyDrawVolume;