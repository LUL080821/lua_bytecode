------------------------------------------------
-- Author: 
-- Date: 2021-02-24
-- File: MainCustomBtn.lua
-- Module: MainCustomBtn
-- Description: Custom button data
------------------------------------------------

local L_IdCounter = 0

local MainCustomBtn = {
    RemainTime = 0,
    SyncTime = 0,
    IsRemainTimeStart = false,

    --id
    ID = 0,
    -- IconID used
    IconID = 0,
    -- The name displayed
    ShowText  = nil,
    -- Remaining time suffix
    RemainTimeSuf = nil,
    -- Is there a countdown
    UseRemainTime = false,
    -- Custom data
    CustomData = nil,
    -- Click to callback
    ClickCallBack = nil,
    -- /Whether dots are displayed
    ShowRedPoint = false,
    -- Whether to display special effects
    ShowEffect = false,
    -- Whether to use server time to count
    UseServerTime = false,
    -- Temporary transform of click
    ClickTrans = nil,
}

function MainCustomBtn:New()
    local _m = Utils.DeepCopy(self)
    L_IdCounter = L_IdCounter + 1
    _m.ID = L_IdCounter
    return _m
end

function MainCustomBtn:SetRemainTime(time)
    self.RemainTime = time
    if self.UseServerTime then
        self.SyncTime = GameCenter.HeartSystem.ServerZoneTime
    else
        self.SyncTime = Time.GetRealtimeSinceStartup()
    end
end

function MainCustomBtn:GetRemainTime()
    if self.UseServerTime then
        return self.RemainTime - (GameCenter.HeartSystem.ServerZoneTime - self.SyncTime)
    else
        return self.RemainTime - (Time.GetRealtimeSinceStartup() - self.SyncTime)
    end
end

return MainCustomBtn