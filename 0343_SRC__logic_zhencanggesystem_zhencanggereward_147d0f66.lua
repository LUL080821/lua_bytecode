
------------------------------------------------
-- Author:
-- Date: 2020-09-02
-- File: ZhenCangGeReward.lua
-- Module: ZhenCangGeReward
-- Description: Treasure Pavilion Award Receive Data
------------------------------------------------
-- Quote
local ZhenCangGeReward = {
    CfgId = 0,
    Cfg = nil,
    ItemData = nil,
    -- Number of times the previous item was required
    PreValue = -1,
    -- Number of draws required
    Value = -1,
    -- Whether to receive it
    IsRd = false,
}
function ZhenCangGeReward:New( k, v )
    local _m = Utils.DeepCopy(self)
    _m.CfgId = k
    _m.Cfg = v
    return _m
end

function ZhenCangGeReward:GetCfgId()
    return self.CfgId
end

-- Get display prop data
function ZhenCangGeReward:GetItemData(occ)
    if self.ItemData == nil then
        if self.Cfg ~= nil then
            local list = Utils.SplitStr(self.Cfg.Reward, ';')
            for i = 1,#list do
                local subList = Utils.SplitNumber(list[i], '_')
                if occ == subList[4] or subList[4] == 9 then
                    self.ItemData = {Id = subList[1], Num = subList[2], IsBind = subList[3] == 1}
                    break
                end
            end
        end
    end
    return self.ItemData
end

-- Get the required draw times
function ZhenCangGeReward:GetNeedCount()
    if self.Value == -1 then
        self.Value = self.Cfg.Need
    end
    return self.Value
end

-- Whether to receive props
function ZhenCangGeReward:IsReward()
    return self.IsRd
end

-- Set whether to collect it
function ZhenCangGeReward:SetReward(b)
    self.IsRd = b
end

return ZhenCangGeReward