
------------------------------------------------
-- Author:
-- Date: 2019-07-11
-- File: ServeCrazyItemData.lua
-- Module: ServeCrazyItemData
-- Description: Server Carnival Reward Data
------------------------------------------------
-- Quote
local ServeCrazyItemData = {
    -- Props Id
    Id = 0,
    -- quantity
    Num = 0,
    -- Whether to bind 0: Non-binding 1: bind
    Bind = 1,
    --occ
    Occ = -1,
}
function ServeCrazyItemData:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

function ServeCrazyItemData:Parase(str)
    local list1 = Utils.SplitStr(str,'_')
    self.Id = tonumber(list1[1])
    self.Num = tonumber(list1[2])
    self.Occ = tonumber(list1[3])
    self.Bind = 1
end
return ServeCrazyItemData