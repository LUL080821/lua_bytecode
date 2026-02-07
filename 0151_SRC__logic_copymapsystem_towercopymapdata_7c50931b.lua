------------------------------------------------
-- Author: 
-- Date: 2019-04-19
-- File: TowerCopyMapData.lua
-- Module: TowerCopyMapData
-- Description: Tower Climbing Copy Data
------------------------------------------------

local CopyMapBaseData = require("Logic.CopyMapSystem.CopyMapBaseData")

-- Constructor
local TowerCopyMapData = {
    -- Current level number (the level being challenged, default value 1)
    CurLevel = 1,
}

function TowerCopyMapData:New(cfgData)
    local _n = Utils.DeepCopy(self);
    local _mn = setmetatable(_n, {__index = CopyMapBaseData:New(cfgData)});
    return _mn;
end

-- Analyze basic data
function TowerCopyMapData:ParseBaseMsg(msg)
end

-- Parse copy data
function TowerCopyMapData:ParseMsg(msg)
    self.CurLevel = msg.overLevel;
    if self.CurLevel == nil or self.CurLevel < 1 then
        self.CurLevel = 1;
    end
    GameCenter.PlayerShiHaiSystem:RefreshRedPointData()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SHOW_XIANPOINLAYINFOS)
end

-- Copy clearance
function TowerCopyMapData:OnFinishLevel(level)
    self.CurLevel = level;
    GameCenter.PlayerShiHaiSystem:RefreshRedPointData()
end

return TowerCopyMapData