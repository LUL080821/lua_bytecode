------------------------------------------------
-- Author: 
-- Date: 2020-02-26
-- File: LuckyDrawAwardItem.lua
-- Module: LuckyDrawAwardItem
-- Description: Reward items
------------------------------------------------
local LuckyDrawAwardItem = {
    CfgId = 0,
    -- index
    Index = 0,
    -- Reward type, 0-4 Special prize First prize Second grade Third prize
    RewardType = 0,
    -- All reward data are obtained according to the server's subscript.
    Rewards = nil,
    -- Reward data to be used on the interface item_num_bind_occ_level
    Item = nil,
}


function LuckyDrawAwardItem:New(cfg, index)
    local _m = Utils.DeepCopy(self)
    _m:RefeshData(cfg, index)
    return _m
end

function LuckyDrawAwardItem:RefeshData(cfg, index)
    if cfg ~= nil then
        self.CfgId = cfg.Id
        self.RewardType = cfg.Type
        self.Rewards = Utils.SplitStr(cfg.RewardPool, ';');
        self.Item = Utils.SplitNumber(self.Rewards[index + 1], '_')
        self.Index = index
    end
end

return LuckyDrawAwardItem;