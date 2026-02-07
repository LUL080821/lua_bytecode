------------------------------------------------
-- Author:
-- Date: 2020-10-16
-- File: MainLimitIcon.lua
-- Module: MainLimitIcon
-- Description: Main interface limited time icon
------------------------------------------------

-- id counter
local L_IdCounter = 1

local MainLimitIcon = {
    ID = 0,
    Name = nil,
    IconName = nil,
    EndTimeStamp = 0,
    ClickCallBack = nil,
    Params = nil,
    SortValue = 0,
}

function MainLimitIcon:New(name, iconName, endTime, callBack, params, sortValue)
    local _m = Utils.DeepCopy(self)
    _m.ID = L_IdCounter
    L_IdCounter = L_IdCounter + 1
    _m.Name = name
    _m.IconName = iconName
    _m.EndTimeStamp = endTime
    _m.ClickCallBack = callBack
    _m.Params = params
    _m.SortValue = sortValue
    return _m
end

return MainLimitIcon