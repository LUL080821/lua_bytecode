------------------------------------------------
-- author:
-- Date: 2019-11-25
-- File: WorldSupportInfo.lua
-- Module: WorldSupportInfo
-- Description: World Data Model
------------------------------------------------
local WorldSupportInfo = {
    -- Support id
    SupportId = 0,
    -- Player ID
    RoleId = 0,
    -- name
    RoleName = nil,
    -- Profession
    Career = 0,
    -- grade
    Level = 0,
    -- BossId requested support
    BossId = 0,
    -- Number of supporters
    SupportNum = 0,
    -- Avatar data
    Head = nil,
}
-- Create a new object and use the protocol MSG_Shop.shopItemInfo as the data source
function WorldSupportInfo:NewWithData(info)
    local _m = Utils.DeepCopy(self)
    if info then
        _m.SupportId = info.id
        _m.RoleId = info.player.roleID
        _m.RoleName = info.player.name
        _m.Career = info.player.career
        _m.Level = info.player.level
        _m.SupportNum = info.helpNum
        _m.Head = info.player.head
        if info.bossID then
            _m.BossId = info.bossID
            local _bossCfg = DataConfig.DataBossnewWorld[info.bossID]
            if _bossCfg then
                _m.BossCfg = _bossCfg
                _m.CloneMapCfg = DataConfig.DataCloneMap[_bossCfg.CloneMap]
                _m.MonsterCfg = DataConfig.DataMonster[info.bossID]
            end
        end
        if info.taskId then
            _m.TaskId = info.taskId
            _m.TeamId = info.teamId
        end
        _m:SetSupportCfg()
    end
    return _m
end

-- Create a WorldSupportInfo object
function WorldSupportInfo:New(data)
    local _m = Utils.DeepCopy(self)
    _m = data
    return _m
end

function WorldSupportInfo:SetSupportCfg()
    local _lv = self.Level
    DataConfig.DataWorldSupport:ForeachCanBreak(function(k, v)
        local _ar = Utils.SplitNumber(v.LevelRank, '_')
        if #_ar >= 2 then
            if _lv >= _ar[1] and _lv <= _ar[2] then
                self.SupportCfg = v
                return true
            end
        end
    end)
end
return WorldSupportInfo