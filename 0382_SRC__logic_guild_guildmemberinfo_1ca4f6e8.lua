------------------------------------------------
-- Author:
-- Date: 2021-03-01
-- File: GuildMemberInfo.lua
-- Module: GuildMemberInfo
-- Description: Basic data of gang members
------------------------------------------------
local GuildMemberInfo ={
    roleId           = 0,      -- Role id
    career           = 0,      -- Profession
    name             = nil,    -- name
    lv               = 0,      -- grade
    contribute       = 0,      -- Zhou Banggong
    vip              = 0,      -- VIP level
    lastOffTime      = 0,      -- Last time offline, 0 means online
    rank             = 0,      -- Position
    RankNum          = 1,      -- Ranking
    fighting         = 0,      -- Player combat power
    activity         = 0,
    monCard          = 0,      -- Monthly Card January Card 2 Lifetime Card March Card and Lifetime Card
    StateVip         = 0,      -- Realm level
    isProxy          = false,  -- Whether to apply for an acting leader
    OnLine           = 0,
    Head            = nil,
}

function GuildMemberInfo:New()
    local _m = Utils.DeepCopy(self)
    _m.roleId           = 0
    _m.career           = 0
    _m.name             = nil
    _m.lv               = 0
    _m.contribute       = 0
    _m.vip              = 0
    _m.lastOffTime      = 0
    _m.rank             = 0
    _m.RankNum          = 1
    _m.fighting         = 0
    _m.activity         = 0
    _m.monCard          = 0
    _m.StateVip         = 0
    _m.isProxy          = false
    _m.OnLine           = 0
    _m.Head             = nil
    return _m
end

function GuildMemberInfo:NewByMsg(info)
    local _m = self:New()
    if info then
        _m.name = info.name;
        _m.roleId = info.roleId;
        _m.lastOffTime = info.lastOffTime;
        if (_m.lastOffTime > 0) then
            _m.lastOffTime = GameCenter.HeartSystem.ServerTime - _m.lastOffTime;
            OnLine = 1;
        else
            OnLine = _m.lastOffTime;
        end
        _m.lv = info.lv;
        _m.contribute = info.allcontribute;
        _m.vip = info.vip;
        _m.fighting = info.fighting;
        _m.career = info.career;
        _m.rank = info.position;
        _m.isProxy = info.isProxy;
        _m.Head = info.head
    end
    return _m
end
return GuildMemberInfo