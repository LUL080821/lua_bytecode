------------------------------------------------
-- Author:
-- Date: 2020-08-19
-- File: SoulMonsterInfo.lua
-- Module: SoulMonsterInfo
-- Description: Boss data of the Immortal Island
------------------------------------------------

local SoulMonsterInfo = {
    -- Configuration
    BossCfg = nil,
    -- Refresh time
    RefreshTime = 0,
    SyncTime = 0,
    -- Pay attention or not
    IsFollowed = false,
    -- type
    Type = 0,
    -- quantity
    Num = 0,
    -- Whether to display
    IsShow = false,
}

function SoulMonsterInfo:New(cfg)
    local _m = Utils.DeepCopy(self)
    _m.BossCfg = cfg
    _m.RefreshTime = 0
    _m.SyncTime = 0
    _m.IsFollowed = false
    _m.Type = 0
    _m.Num = 0
    _m.IsShow = true
    return _m
end

function SoulMonsterInfo:Refresh(msg)
    self.RefreshTime = msg.refreshTime
    self.SyncTime = Time.GetRealtimeSinceStartup()
    self.IsFollow = msg.isFollowed
    self.Type = msg.type
    self.Num = msg.num
    self.IsShow = true
end

function SoulMonsterInfo:GetRefreshTime()
    local _result = self.RefreshTime - (Time.GetRealtimeSinceStartup() - self.SyncTime)
    if _result < 0 then
        _result = 0
    end
    return _result
end

return SoulMonsterInfo