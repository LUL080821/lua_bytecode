------------------------------------------------
-- Author:
-- Date: 2021-04-27
-- File: FengMoTaiData.lua
-- Module: FengMoTaiData
-- Description: Demon-Shoulder Reward Information Category
------------------------------------------------

local FengMoTaiData = {
    Id = nil,
    HotLimit = nil,
    RewardId = nil,
    RewardCount = nil,
    IsBind = nil,
    IsUseForBoth = nil,

}

function FengMoTaiData:New(cfg)
    local _m = Utils.DeepCopy(self)
    _m.Id = cfg.Id
    _m.HotLimit = cfg.HotLimit
    local strs = Utils.SplitStr(cfg.Reward,"_")
    _m.RewardId = strs[1]
    _m.RewardCount = strs[2]
    _m.IsBind = strs[3]
    _m.IsUseForBoth = strs[4]
    return _m
end

return FengMoTaiData