-- Author: 
-- Date: 2020-02-18
-- File: XmRewardBoxInfo.lua
-- Module: XmRewardBoxInfo
-- Description: Information about the reward treasure chest in the Immortal Alliance
-----------------------------------------------
local XmRewardBoxInfo =
{
    -- Configuration file ID
    CfgID = 0,
    -- Arrange the sequence number
    Count = 0,
    -- Description Information
    Desc = "",
    -- List of Xianlian Rewards
    ItemList = "",
    -- Current status of the reward chest 0: Not received, 1: Received
    State = 0,
    -- Is it a winning streak reward or a final reward in the current package?
    Type = 0,
}

-- Constructor
function XmRewardBoxInfo:New(cfgid,lsCount,itemList,desc,state,type)
    local _m = Utils.DeepCopy(self);
    _m.CfgID = cfgid;
    _m.ItemList = itemList;
    _m.Count = lsCount;
    _m.Desc = desc;     
    _m.State = state;
    _m.Type = type;
    if itemList == nil or #itemList == 0 then
        Debug.LogError("The item list of the current treasure chest is empty!" .. tostring(cfgid));
    end
    return _m;
end

-- Get display items
function XmRewardBoxInfo:GetShowItem()
    if self.ItemList then
        return self.ItemList[1];
    else
        return nil;
    end
end

-- Get the description
function XmRewardBoxInfo:GetFlagDesc()
    if self:EnableGet() then
        return DataConfig.DataMessageString.Get("XMREWARDBOXINFO_TISHI_1");
    else
        return self.Desc;
    end
end

-- Is it available?
function XmRewardBoxInfo:EnableGet()
    
    if self.State == 0 and GameCenter.XmFightSystem:CanGetLSReward(self.Type) then
        
        if self.Type == 0 then           
            return GameCenter.XmFightSystem.LSXmCount >= self.Count;
        elseif self.Type == 1 then            
            return GameCenter.XmFightSystem.ZJXmCount >= self.Count;
        end
    end
    return false;
end

return XmRewardBoxInfo;
