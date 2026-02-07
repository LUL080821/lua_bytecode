-------------------------------------------------------------
-- Author:
-- Date: 2019-08-01
-- File: AHSortInfo.lua
-- Module: AHSortInfo
-- Description: Trading store sales information model, mainly keeping data such as sorting information of the sales list
-------------------------------------------------------------
local AHSortInfo = {
    -- Sort Type 1 Item Shelf Time, 5 Unit Price, 6 Purchase Type
    SortType = 1,
    -- Sort direction 0 No direction, 1 Ascending order 2 descending order
    Desc = 0,
    -- Index starts
    IdxBegin = 0,
    -- End of index
    IdxEnd = 0,
    -- 1 means the list of goods requested to trade, 2 means the list of purchases
    PanelType = 1,
    -- Catalog Type 100 All , 200 Equipment, 2XX Equipment Subtype, where XX represents the code of the subtype of the equipment in the table, 300 Materials, 400 Gems
    DirType = 100,
    Dia = -1,
    Quailty = -1,
    Level = -1,
    Sex = -1,
    -- Search for a name
    SerachName = "",
    -- Total number of sales
    AllNum = 0,
}
function AHSortInfo:New()
    local _m = Utils.DeepCopy(self)
    _m.SortType = 1
    _m.Desc = 0
    _m.IdxBegin = 0
    _m.IdxEnd = 0
    _m.PanelType = 1
    _m.DirType = 100
    _m.Dia = -1
    _m.Quailty = -1
    _m.Level = -1
    _m.Sex = -1
    _m.SerachName = ""
    return _m
end
return AHSortInfo