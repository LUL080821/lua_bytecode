------------------------------------------------
-- Author:
-- Date: 2020-10-16
-- File: MainLimitIconSystem.lua
-- Module: MainLimitIconSystem
-- Description: Main interface limited time icon
------------------------------------------------
local L_MainLimitIcon = require "Logic.MainLimitIcon.MainLimitIcon"

local MainLimitIconSystem = {
    IconList = nil,
    IsRefresh = false,
}

function MainLimitIconSystem:Initialize()
    self.IconList = List:New()
end

function MainLimitIconSystem:UnInitialize()
    self.IconList = nil
end

function MainLimitIconSystem:AddIcon(name, iconName, endTime, callBack, params, sortValue)
    local _icon = L_MainLimitIcon:New(name, iconName, endTime, callBack, params, sortValue)
    self.IconList:Add(_icon)
    self.IconList:Sort(function(x, y)
        return x.SortValue < y.SortValue
    end)
    self.IsRefresh = true
    return _icon.ID
end

function MainLimitIconSystem:RemoveIcon(id)
    for i = 1, #self.IconList do
        if self.IconList[i].ID == id then
            self.IconList:RemoveAt(i)
            self.IsRefresh = true
            break
        end
    end
end

function MainLimitIconSystem:OnMainRequest(obj, sender)
    self.IsRefresh = true
end

function MainLimitIconSystem:RefreshMainIcon()
    local _serverTime = GameCenter.HeartSystem.ServerZoneTime
    for i = #self.IconList, 1, -1 do
        local _icon = self.IconList[i]
        if _icon.EndTimeStamp < _serverTime then
            -- Expired, deleted
            self.IconList:RemoveAt(i)
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MYSTERYSHOP_UPDATE_MAIN_ICON)
end

function MainLimitIconSystem:Update()
    if self.IsRefresh then
        self.IsRefresh = false
        self:RefreshMainIcon()
    end
end

return MainLimitIconSystem