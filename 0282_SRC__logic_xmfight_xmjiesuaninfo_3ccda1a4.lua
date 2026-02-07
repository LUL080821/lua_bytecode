-- Author: 
-- Date: 2020-02-18
-- File: XmJieSuanInfo.lua
-- Module: XmJieSuanInfo
-- Description: Settlement information of the Immortal Alliance in the Immortal Alliance Battle
-----------------------------------------------
local XmRewardInfo = require("Logic.XmFight.XmRewardInfo");

local XmJieSuanInfo =
{
    -- Ranking
    Rank = 0,
    -- Total points
    Record = 0,
    -- type
    Type = 0,
    -- Win or end
    Win = 0,
    -- 0: Winning in a row 1: End
    Res = 0,
    -- Reward display
    --RewardDict = nil,
}

function XmJieSuanInfo:New(pb_msg)
    if pb_msg then 
        local _m = Utils.DeepCopy(self);
        _m.Rank = pb_msg.rank;
        _m.Record = pb_msg.record;
        _m.Type = pb_msg.type;
        _m.Win = pb_msg.win;
        _m.Res = pb_msg.res;
        --_m.RewardDict = Dictionary:New()
        --_m:GetRewardInfo()
        return _m;
    else
        return nil;
    end
end

function XmJieSuanInfo:GetRewardInfo()
    if self.RewardDict:Count() == 0 then
        self.RewardDict = Dictionary:New()
        DataConfig.DataGuildWarRank:Foreach(
            function(_id, _cfg)
                if not self.RewardDict:ContainsKey(_id) then
                    local _rewardList = List:New()
                    _rewardList:Add(_cfg.GuildReward1)
                    _rewardList:Add(_cfg.GuildReward2)
                    _rewardList:Add(_cfg.GuildReward3)
                    self.RewardDict:Add(_id, _rewardList)
                end
            end
        )
    end
end

return XmJieSuanInfo;