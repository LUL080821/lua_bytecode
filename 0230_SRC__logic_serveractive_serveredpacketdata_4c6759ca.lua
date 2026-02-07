
------------------------------------------------
-- Author:
-- Date: 2019-07-20
-- File: ServeRedPacketData.lua
-- Module: ServeRedPacketData
-- Description: Seven-day red envelope data for service opening activities
------------------------------------------------
-- Quote
local ServeRedPacketData = {
    -- index
    Index = 0,
    -- Deposit ratio
    Percent = 0,
    -- Gold Icon
    GoldIcon = 0,
    -- Quantity of ingots
    GoldNum = 0,
}
function ServeRedPacketData:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

function ServeRedPacketData:Parase(str, index)
    self.Index = index
    local list = Utils.SplitStr(str,'_')
    if list ~= nil then
        self.Index = tonumber(list[1])
        self.Percent = tonumber(list[2])/10000
    end
end

-- Resolve server messages
function ServeRedPacketData:ParaseMsg(num)
    self.GoldNum = num
end
return ServeRedPacketData