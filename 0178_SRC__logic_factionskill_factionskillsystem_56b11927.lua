
------------------------------------------------
-- Author:
-- Date: 2019-05-08
-- File: FactionSkillSystem.lua
-- Module: FactionSkillSystem
-- Description: Sectarian Skill System
------------------------------------------------

local FactionSkillSystem = {
    -- Whether to open the interface
    OpenForm = false,
    -- Whether to refresh the sect skill information
    Refresh = false,
    -- Skill List
    SkillList = List:New(),
    -- The maximum level of skill
    SkillMaxLvDic = Dictionary:New(),                   -- The maximum level of skill
}

function FactionSkillSystem:Initialize()
    DataConfig.DataGuildCollege:Foreach(function(k, v)
        if v.NextLevelID == 0 then
            self.SkillMaxLvDic[v.Type] = v.Level
        end
    end)
end

function FactionSkillSystem:UnInitialize()
    self.SkillList:Clear()
    self.SkillMaxLvDic:Clear()
end

-- Get the maximum level of skill
function FactionSkillSystem:GetSkillMaxLv(id)
    return self.SkillMaxLvDic[id]
end

-- Obtain the id of the skill
function FactionSkillSystem:GetSkillIdByType(t)
    for i = 1, #self.SkillList do
        local _cfg = DataConfig.DataGuildCollege[self.SkillList[i]]
        if _cfg.Type == t then
            return _cfg.Id
        end
    end
end

-- Get a skill list
function FactionSkillSystem:GetSkillList()
    return self.SkillList
end

-- Check whether there are upgradeable skills
function FactionSkillSystem:CheckUpgreadSkill()
    local _guildMoney = GameCenter.ItemContianerSystem:GetEconomyWithType(ItemTypeCode.UnionContribution)
    for i = 1, #self.SkillList do
        local _cfg = DataConfig.DataGuildCollege[self.SkillList[i]]
        local _value = tonumber(Utils.SplitStr(_cfg.LearningConsumption,"_")[2])
        if _value <= _guildMoney then
            return true
        end
    end
    return false
end

-- Sectarian skills list return
function FactionSkillSystem:GS2U_ResFactionSkills(msg)
    if msg.skills then
        self.SkillList:Clear()
        for i = 1, #msg.skills do
            self.SkillList:Add(msg.skills[i])
        end
        table.sort( self.SkillList, function(a, b)
            return a < b
        end)
    end
    if self.OpenForm then
        GameCenter.PushFixEvent(UIEventDefine.UIFactionSkillForm_OPEN)
        self.OpenForm = false
    end
    if self.Refresh then
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_FACTIONSKILLS)
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_FACTIONSKILLINFO)
        self.Refresh = false
    end
    -- GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.GuildSkill, self:CheckUpgreadSkill())
end

-- Research skills (id=0 one-click research)
function FactionSkillSystem:ReqStudyFactionSkill(id)
    self.Refresh = true
    local _req = {}
    _req.id = id
    GameCenter.Network.Send("MSG_Guild.ReqLearnSkill", _req)
end

-- Request Skill List
function FactionSkillSystem:ReqFactionSkilList()
    self.OpenForm = true
    GameCenter.Network.Send("MSG_Guild.ReqPlayerLearnSkills",{})
end

return FactionSkillSystem