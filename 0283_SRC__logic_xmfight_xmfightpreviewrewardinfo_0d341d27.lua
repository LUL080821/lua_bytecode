-- Author: 
-- Date: 2020-02-18
-- File: XmRateInfo.lua
-- Module: XmRateInfo
-- Description: Evaluation information of the Immortal Alliance in the Immortal Alliance Battle
-----------------------------------------------
local XmFightPreviewRewardInfo =
{
    -- Start level
    StartLevel = 0,
    -- End level
    EndLevel = 0,
    -- Gang Rewards
    GuildRewards = nil,
    -- Personal Rewards
	PersonRewards = nil
}

function XmFightPreviewRewardInfo:New(s,e,g,p)
    local _m = Utils.DeepCopy(self);
    _m.StartLevel = s;
    _m.EndLevel = e;
    _m.GuildRewards = g;
    _m.PersonRewards = p;
    return _m;
end

-- Sort xmRateInfoList
function XmFightPreviewRewardInfo:SortList(list)
    if list ~= nil then
        list:Sort(
            function(a,b)
               return a.StartLevel < b.StartLevel;     
            end
        );
    end
end

return XmFightPreviewRewardInfo;