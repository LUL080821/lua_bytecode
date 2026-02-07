------------------------------------------------
-- Author:
-- Date: 2019-06-18
-- File: PetInfo.lua
-- Module: PetInfo
-- Description: Pet data
------------------------------------------------

local PetInfo = {
    --id
    ID = 0,
    -- Configuration data
    Cfg = nil,
    -- Current level, born as 1st order
    CurLevel = 1,
    -- Current level configuration data
    CurLevelCfg = nil,
    -- Attributes of the current level
    CurLevelPros = nil,
    -- Next level configuration data
    NextLevelCfg = nil,
    -- Activate properties
    ActivePros = nil,
    -- Current total attributes
    CurAllPros = nil,
    -- Attributes added by the lower level
    NextAddPros = nil,
    -- Is it full level
    IsFullDegree = false,
    -- Skill activation data
    SkillActiveLevels = nil,
}


function PetInfo:New(cfg, level)
    local _m = Utils.DeepCopy(self)
    _m.ID = cfg.Id
    _m.Cfg = cfg
    _m.CurLevel = level
    _m.CurLevelCfg = DataConfig.DataPetRank[_m.Cfg.Id * 1000 + _m.CurLevel]
    _m.NextLevelCfg = DataConfig.DataPetRank[_m.Cfg.Id * 1000 + _m.CurLevel + 1]
    _m.ActivePros = Utils.SplitStrByTableS(cfg.Attribute)
    _m:CalculatePros()

    _m.IsFullDegree = level >= cfg.FullDegress
    _m.SkillActiveLevels = {}
    -- Activation level of computing skills
    for i = 1, cfg.MaxDegree do
        local _levelCfg = DataConfig.DataPetRank[cfg.Id * 1000 + i]
        if _levelCfg ~= nil then
            local _skillParam =  Utils.SplitStrByTableS(_levelCfg.PetSkill, {';', '_'})
            for j = 1, #_skillParam do
                if _m.SkillActiveLevels[_skillParam[j][1]] == nil then
                    _m.SkillActiveLevels[_skillParam[j][1]] = {_skillParam[j][2], _levelCfg, i}
                end
            end
        end
    end
    return _m
end

-- Calculate the current attribute
function PetInfo:CalculatePros()
    self.CurLevelPros = Utils.SplitStrByTableS(self.CurLevelCfg.Attribute)
    self.CurAllPros = Utils.MergePropTable(self.CurLevelPros, self.ActivePros)
    if self.NextLevelCfg  ~= nil then
        local _nextPros = Utils.SplitStrByTableS(self.NextLevelCfg.Attribute)
        self.NextAddPros = Utils.DecPropTable(_nextPros, self.CurLevelPros)
    else
        self.NextAddPros = nil
    end
end


return PetInfo