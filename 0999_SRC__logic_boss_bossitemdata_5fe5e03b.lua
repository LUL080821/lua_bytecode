
------------------------------------------------
-- Author: 
-- Date: 2019-05-5
-- File: BossItemData.lua
-- Module: BossItemData
-- Description: Spouse's data
------------------------------------------------
local BossItemData =
{
    BossID = 0,
    IsFollow = false,
    CurCloneMapId = 0,
    IsInfinite = false,
    Stage = 0,
    BossLv = 0,
    BossName = "",
    BossHeadIcon = 0,
}

function BossItemData:New(bossId)
    local _m = Utils.DeepCopy(self)
    _m:RefeshData(bossId)
    return _m
end

function BossItemData:RefeshData(bossId)
    if bossId ~= nil then
        self.BossID = bossId
        local _bossCfg = DataConfig.DataBossnewWorld[bossId]
        local _monsterCfg = DataConfig.DataMonster[bossId]
        local _bossInfo = GameCenter.BossSystem.WorldBossInfoDic[bossId]
        -- Are you following
        self.IsFollow = _bossInfo.IsFollow
        self.CurCloneMapId = _bossCfg.CloneMap
        -- Is it an infinite layer?
        self.IsInfinite = _bossCfg.Infinite == 1
        -- Order
        self.Stage = _bossCfg.DropEquipShow
        -- grade
        self.BossLv = _monsterCfg.Level
        -- name
        self.BossName = _monsterCfg.Name
        --Icon
        self.BossHeadIcon = tonumber(_monsterCfg.Icon)
        -- Debug.Log("Name_2",Inspect(_monsterCfg.Name))
        -- Debug.Log("icon2",Inspect(_monsterCfg.Icon))
    end
end

return BossItemData