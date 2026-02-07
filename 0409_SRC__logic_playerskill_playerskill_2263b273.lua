------------------------------------------------
-- Author:
-- Date: 2021-03-26
-- File: PlayerSkill.lua
-- Module: PlayerSkill
-- Description: Player skill data
------------------------------------------------

local PlayerSkill = {
    -- Skill ID
    CfgID = 0,
    --
    VisualInfo = nil,
    -- Skill ICON
    Icon = 0,
    -- Current CD
    CurCD = 0,
    -- Maximum CD
    MaxCD = 0,
    -- Whether to use public CDs
    UsePublicCD = false,
    -- Public CD time
    PubilcCD = 0,
    -- Is it synchronized
    IsSync = true,
}

function PlayerSkill:New(cfg, isSync)
    local _m = Utils.DeepCopy(self)
    _m.IsSync = isSync
    _m:RefreshSkill(cfg)
    return _m
end

function PlayerSkill:RefreshSkill(cfg)
    self.MaxCD = cfg.Cd / 1000
    self.UsePublicCD = (cfg.UsePublicCd ~= 0)
    self.PubilcCD = cfg.PublicCd / 1000
    self.CfgID = cfg.Id
    self.Icon = cfg.Icon
    self.VisualInfo = GameCenter.SkillVisualManager:Find(cfg.VisualDef)
end

function PlayerSkill:NewSwordSkill(flySwordSkill, playerSkill, curCD)
    local _m = Utils.DeepCopy(self)
    -- CDs and Icons using Flying Sword
    _m.MaxCD = flySwordSkill.Cd / 1000
    _m.UsePublicCD = (flySwordSkill.UsePublicCd ~= 0)
    _m.PubilcCD = flySwordSkill.PublicCd / 1000
    _m.Icon = flySwordSkill.Icon
    -- Show using player skills
    _m.CfgID = playerSkill.Id
    _m.IsSync = false
    _m.CurCD = curCD
    _m.VisualInfo = GameCenter.SkillVisualManager:Find(playerSkill.VisualDef)
    return _m
end


function PlayerSkill:IsCDing()
    return self.CurCD > 0
end

function PlayerSkill:GetCDPercent()
    local _result = 0
    if self.MaxCD ~= 0 then
        _result = self.CurCD / self.MaxCD
    end
    if _result < 0 then
        _result = 0
    end
    if _result > 1 then
        _result = 1
    end
    return _result
end

function PlayerSkill:BeginCD()
    self.CurCD = self.MaxCD
end

function PlayerSkill:EndCD()
    self.CurCD = 0
end

function PlayerSkill:Update(dt)
    if self.CurCD > 0 then
        self.CurCD = self.CurCD - dt
        if self.CurCD <= 0 then
            self.CurCD = 0
        end
    end
end

return PlayerSkill