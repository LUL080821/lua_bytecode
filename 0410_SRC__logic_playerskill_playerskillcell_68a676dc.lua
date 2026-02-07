------------------------------------------------
-- Author:
-- Date: 2021-03-26
-- File: PlayerSkillCell.lua
-- Module: PlayerSkillCell
-- Description: Player Skill Grid
------------------------------------------------
local L_PlayerSkill = require "Logic.PlayerSkill.PlayerSkill"

local PlayerSkillCell = {
    -- Configuration ID
    CfgID = 0,
    -- Current configuration
    Cfg = nil,
    -- Current skill index
    CurIndex = 0,
    -- Index countdown, index is 0 after countdown
    IndexTimer = 0,
    -- Skill List
    SkillList = nil,
    -- Number of skills
    SkillCount = 0,
    -- Refresh callback
    RereshCallBack = nil,
}

function PlayerSkillCell:New(cfg, useSkills)
    local _m = Utils.DeepCopy(self)
    _m.CfgID = cfg.Id
    _m.Cfg = cfg
    _m.CurIndex = 1
    if cfg.Id == 1007000 then
        local dad = 0
    end
    _m.SkillList = List:New()
    if useSkills ~= nil then
        for i = 1, #useSkills do
            local _skillCfg = DataConfig.DataSkill[useSkills[i]]
            if _skillCfg ~= nil then
                _m.SkillList:Add(L_PlayerSkill:New(_skillCfg, true))
            end
        end
    else
        local _skillIds = Utils.SplitNumber(cfg.SkillId, '_')
        for i = 1, #_skillIds do
            local _skillCfg = DataConfig.DataSkill[_skillIds[i]]
            if _skillCfg ~= nil then
                _m.SkillList:Add(L_PlayerSkill:New(_skillCfg, true))
            end
        end
    end
    _m.SkillCount = #_m.SkillList
    return _m
end

-- Current skills
function PlayerSkillCell:GetCurSkill()
    if self.CurIndex < 1 or self.CurIndex > self.SkillCount then
        CurIndex = 1
    end
    if self.CurIndex <= self.SkillCount then
        return self.SkillList[self.CurIndex]
    end
    return nil
end

-- Update CD
function PlayerSkillCell:Update(dt)
    if self.SkillCount > 0 then
        if self.IndexTimer > 0 then
            self.IndexTimer = self.IndexTimer - dt
            if self.IndexTimer <= 0 then
                self.CurIndex = 1
                self.IndexTimer = 0
                if self.RereshCallBack ~= nil then
                    self.RereshCallBack()
                end
            end
        end
    end
    for i = 1, self.SkillCount do
        self.SkillList[i]:Update(dt)
    end
end


-- Fill in the skill list
function PlayerSkillCell:FillSkillList(skillList)
    for i = 1, self.SkillCount do
        skillList:Add(self.SkillList[i])
    end
end

-- Use skill callback
function PlayerSkillCell:OnUseSkill(skillId)
    local _selfSkill = false
    for i = 1, self.SkillCount do
        if self.SkillList[i].CfgID == skillId then
            _selfSkill = true
            break
        end
    end

    if _selfSkill then
        self.CurIndex = self.CurIndex + 1
        if self.CurIndex > self.SkillCount then
            self.CurIndex = 1
            self.IndexTimer = 0
        else
            self.IndexTimer = 2
        end
        if self.RereshCallBack ~= nil then
            self.RereshCallBack()
        end
    end
end

return PlayerSkillCell