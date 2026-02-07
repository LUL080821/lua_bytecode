------------------------------------------------
-- Author: 
-- Date: 2019-04-16
-- File: NatureSkillSetData.lua
-- Module: NatureSkillSetData
-- Description: Creation Panel Skill Data
------------------------------------------------
-- Quote

------------------------------------------------
local NatureSkillSetData = {
    SkillInfo = nil, -- Configure table skill data
    IsActive = false, -- Whether the skill is activated
    NeedLevel = 0, -- Skill activation level
    SkillType = 0, -- Skill Type
    SkillLevel = 0, -- Current skill level
}

NatureSkillSetData.__index = NatureSkillSetData

function NatureSkillSetData:New(natureatt,type)
    local _M = Utils.DeepCopy(self)
    local _cs = {'_'}
    local _skill = Utils.SplitStrByTable(natureatt.Skill,_cs)
    local _skilltype = tonumber(_skill[1])
    local _skilllevel = tonumber(_skill[2])
    _M.SkillInfo = DataConfig.DataSkill[_skilltype * 100 + _skilllevel]
    if not _M.SkillInfo then
        Debug.LogError("NatureSkill  is is nil!!!!!!!!!!!!!!!!",natureatt.Skill)
    end
    _M.SkillType = _skilltype
    _M.SkillLevel = _skilllevel
    _M.IsActive = false
    _M.NeedLevel = natureatt.Id
    return _M
end

return NatureSkillSetData