------------------------------------------------
-- Author: 
-- Date: 2021-06-07
-- File: WaiGuanZhanShiData.lua
-- Module: WaiGuanZhanShiData
-- Description: Appearance display data
------------------------------------------------
local BaseData = require("Logic.YYHD.YYHDBaseData")
local ItemData = require("Logic.YYHD.YYHDItemData")

local WaiGuanZhanShiData = {
    ShowItemList = List:New(),
}

function WaiGuanZhanShiData:New(typeId)
    local _n = Utils.DeepCopy(self)
    local _mn = setmetatable(_n, {__index = BaseData:New(typeId)})
    return _mn
end

-- Parse activity configuration data
function WaiGuanZhanShiData:ParseSelfCfgData(jsonTable)
    self.ShowItemList:Clear()
    for i = 1, #jsonTable do
        local _occData = {}
        for j = 1, #jsonTable[i].showList do
            local _item = ItemData:New(jsonTable[i].showList[j])
            _occData[_item.Occ] = _item
        end
        self.ShowItemList:Add({
            FuncId = jsonTable[i].toFunction,
            OccData = _occData,
        })
    end
end

-- Analyze the data of active players
function WaiGuanZhanShiData:ParsePlayerData(jsonTable)
end

-- Refresh data
function WaiGuanZhanShiData:RefreshData()
end

return WaiGuanZhanShiData
