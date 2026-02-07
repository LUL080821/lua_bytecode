
------------------------------------------------
-- Author:
-- Date: 2019-05-15
-- File: FuDiBossData.lua
-- Module: FuDiBossData
-- Description: Fudi boss data
------------------------------------------------
-- Quote
local FuDiBossData = {
    Id = 0,
    -- 1 is the leader 2-4 is the elite monster 5-8 is the guard
    Type = 0,
    Sort = 0,    
    Score = 0,
    IconId = 0,
    Lv = 0,
    MonterId = 0,
    -- integral
    Integral = 0,
    Name = nil,
    HeadName = nil,
    -- Pay attention or not
    IsAttention = false,
    -- 0 means still alive, greater than 0 means countdown to resurrection
    BornTime = 0,
    ItemIdList = List:New()
}

function FuDiBossData:New(cfg)
    if cfg == nil then
        return nil
    end 
    local _m = Utils.DeepCopy(self)
    _m.Id = cfg.Id
    _m.Type = cfg.Group
    _m.Sort = cfg.Sort
    _m.Score = cfg.Score
    _m.Name = cfg.Name
    _m.IconId = cfg.Icon
    -- local monsterCfg = DataConfig.DataMonster[cfg.MonsterID]
    -- if monsterCfg ~= nil then
    --     _m.Name = Utils.GetMonsterName(monsterCfg)
    --     _m.IconId = monsterCfg.Icon
    -- end
    _m.HeadName = cfg.Name
    return _m
end

function FuDiBossData:SetData(msg)
    self.Id = msg.monsterModelId
    self.BornTime = msg.resurgenceTime
    local cfg = DataConfig.DataGuildBattleBoss[self.Id]
    if cfg == nil then
        return
    end 

    local _openDay = Time.GetOpenSeverDay()
    self.ItemIdList:Clear()
    -- Get the player career
    local _occ = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
    -- Parse configuration data
    local _rewradStrList = Utils.SplitStr(cfg.Reward,';')
    if _rewradStrList ~= nil then
        for i = 1, #_rewradStrList do
            local _strList = Utils.SplitNumber(_rewradStrList[i], '_')
            if _strList ~= nil then
                if #_strList >= 2 then
                    if _strList[1] == _openDay then
                        if _occ == _strList[2] or _strList[2] == 9 then
                            for m = 3, #_strList do
                                self.ItemIdList:Add(_strList[m])
                            end
                        end
                    end
                end
            end
        end
    end
    -- Set monster id
    local _monsterStrList = Utils.SplitStr(cfg.MonsterID,';')
    if _monsterStrList ~= nil then
        for i = 1, #_monsterStrList do
            local _strList = Utils.SplitNumber(_monsterStrList[i], '_')
            if _strList ~= nil then
                if #_strList >= 2 then
                    if _strList[1] == _openDay then
                        self.MonterId = _strList[2]
                        break
                    end
                end
            end
        end
    end

    self.HeadName = cfg.Name
    local monsterCfg = DataConfig.DataMonster[self.MonterId]
    if monsterCfg ~= nil then
        self.Name = Utils.GetMonsterName(monsterCfg)
        self.IconId = monsterCfg.Icon
        self.Lv = monsterCfg.Level
    end
end
return FuDiBossData