------------------------------------------------
-- Author: 
-- Date: 2020-08-14
-- File: FBFenXiangData.lua
-- Module: FBFenXiangData
-- Description: Share (New Year's Day)
------------------------------------------------
local BaseData = require("Logic.YYHD.YYHDBaseData")

local FBFenXiangData = {
    -- Configuration data
    CfgData = nil,
    PlayerData = nil,
    IsShare = false,
}

function FBFenXiangData:New(typeId)
    local _n = Utils.DeepCopy(self)
    local _mn = setmetatable(_n, {
        __index = BaseData:New(typeId)
    })
    return _mn
end

-- Parse activity configuration data
-- awardList
function FBFenXiangData:ParseSelfCfgData(jsonTable)
    self.CfgData = jsonTable;
    self.PlayerData = nil;
end

-- Resolve custom data and update it
--> isGet
function FBFenXiangData:ParsePlayerData(jsonTable)
    self.PlayerData = jsonTable;
end

-- Is there a small red dot in this function
function FBFenXiangData:IsRedpoint()

end

-- Refresh data
function FBFenXiangData:RefreshData()

end

-- Operation activity return
function FBFenXiangData:ResActivityDeal(jsonTable)

end

return FBFenXiangData

