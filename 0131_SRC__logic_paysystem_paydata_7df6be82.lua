------------------------------------------------
-- Author: 
-- Date: 2019-05-13
-- File: PayData.lua
-- Module: PayData
-- Description: Data class of the recharge system
------------------------------------------------

local PayData =
{
    -- Configuration table ID
    Id = 0,
    -- Number of recharges
    Num = 0,
    -- Data from previous RechargeItem configuration table issued by the server
    ServerCfgData = nil,
}

function PayData:New(sCfgData)
    local _m = Utils.DeepCopy(self)
    _m:RefeshData(sCfgData)
    return _m
end

function PayData:RefeshData(sCfgData)
    self.Id = sCfgData.CfgId
    self.ServerCfgData = sCfgData
end

function PayData:UpdateNum(num)
    self.Num = num
end

return PayData
