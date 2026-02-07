-- Author: 
-- Date: 2020-02-18
-- File: XmRateInfo.lua
-- Module: XmRateInfo
-- Description: Evaluation information of the Immortal Alliance in the Immortal Alliance Battle
-----------------------------------------------
local XmRateInfo =
{
    -- name
    Name = "",
    -- Rating rating
    Type = 0,
    -- Tags: 0: Promotion 1: Normal 2: Demotion
	Flag = 0
}

function XmRateInfo:New(pb_msg)
    if pb_msg then 
        local _m = Utils.DeepCopy(self);
        _m.Name = pb_msg.guildName;
        _m.Type = pb_msg.type;
        _m.Flag = pb_msg.flag;
        return _m;
    else
        return nil;
    end
end

-- Sort xmRateInfoList
function XmRateInfo:SortList(rateList)
    if rateList ~= nil then
        rateList:Sort(
            function(a,b)
               return a.Flag < b.Flag;     
            end
        );
    end
end

return XmRateInfo;