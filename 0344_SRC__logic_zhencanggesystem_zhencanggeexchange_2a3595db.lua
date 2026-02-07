
------------------------------------------------
-- Author:
-- Date: 2020-09-03
-- File: ZhenCangGeExchange.lua
-- Module: ZhenCangGeExchange
-- Description: Treasure Pavilion redemption data
------------------------------------------------
-- Quote
local ZhenCangGeExchange = {
    CfgId = 0,
    Cfg = nil,
    -- Redeemed several times
    CurCount = 0,
    -- Total redemption times
    AllCount = 0,
    ItemData = nil,
    CostData = nil,
    -- Is it a reminder
    IsWarning = false,
}
function ZhenCangGeExchange:New( k, v )
    local _m = Utils.DeepCopy(self)
    _m.CfgId = k
    _m.Cfg = v
    return _m
end

function ZhenCangGeExchange:GetCfgId()
    return self.CfgId
end

-- Get display prop data
function ZhenCangGeExchange:GetItemData(occ)
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

-- Get consumed item data
function ZhenCangGeExchange:GetCostData()
    if self.CostData == nil then
        if self.Cfg ~= nil then
            local list = Utils.SplitNumber(self.Cfg.Need, '_')
            for i = 1,#list do
                self.CostData = {Id = list[1], Num = list[2]}
            end
        end
    end
    return self.CostData
end

-- Set the number of redemptions
function ZhenCangGeExchange:SetCount(count)
    self.CurCount = count
end

-- How many times have I received it?
function ZhenCangGeExchange:GetCount()
    return self.CurCount
end

-- Get the total redemption times
function ZhenCangGeExchange:GetAllCount()
    if self.AllCount == 0 then
        if self.Cfg ~= nil then
            self.AllCount = self.Cfg.ExchangeLimit
        end
    end
    return self.AllCount
end

return ZhenCangGeExchange