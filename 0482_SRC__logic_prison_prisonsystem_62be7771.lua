------------------------------------------------
-- Author:
-- Date: 2025-11-14
-- File: PrisonSystem.lua
-- Module: PrisonSystem
-- Description: Vận lúa
------------------------------------------------
local L_PrisonData = require("Logic.Prison.PrisonData")
local PrisonSystem = {
    _IsPrisonLoaded = false,
    PrisonDataDic   = Dictionary:New(), -- Dic<{Id , L_PrisonData}>
}

------------------------------------------------------------------------------------------------------------------------
--region [Init & Config]
-- Initialization, setup, and preloading data
-- ---------------------------------------------------------------------------------------------------------------------

---Load / Init
function PrisonSystem:Initialize()
    self.PrisonDataDic = Dictionary:New()
    self:EnsurePrisonDataLoaded()
end

---Unload / Clear
function PrisonSystem:UnInitialize()
    self.PrisonDataDic:Clear()
end

--endregion [Init & Config]

------------------------------------------------------------------------------------------------------------------------
--region [Access & Data Handling]
-- Internal data management, used only inside the module
-- ---------------------------------------------------------------------------------------------------------------------

---Ensure Prison data is loaded
function PrisonSystem:EnsurePrisonDataLoaded()
    
end

--endregion [Access & Data Handling]  

------------------------------------------------------------------------------------------------------------------------
--region [Public API / Getters & Setters]
-- Methods callable from outside (other systems or UI)
-- ---------------------------------------------------------------------------------------------------------------------
-- TODO
--endregion [Public API / Getters & Setters]

------------------------------------------------------------------------------------------------------------------------
--region [Network Requests & Responses]
-- Handle server requests and responses
-- ---------------------------------------------------------------------------------------------------------------------
---Handles server response: PrisonOver data from server
---@param result {rewards: {id:number, num:number}[]}
function PrisonSystem:ResPrisonOverReward(result)
   
end
--endregion [Network Requests & Responses]

function PrisonSystem:OnEnterScene()
    -- Set the switch
    GameCenter.MapLogicSwitch.CanRide = true
    GameCenter.MapLogicSwitch.CanFly = false
    GameCenter.MapLogicSwitch.CanRollDoge = false
    GameCenter.MapLogicSwitch.CanMandate = false
    GameCenter.MapLogicSwitch.CanOpenTeam = false
    GameCenter.MapLogicSwitch.ShowNewFunction = true
    GameCenter.MapLogicSwitch.UseAutoStrikeBack = true
    GameCenter.MapLogicSwitch.CanTeleport = false
    GameCenter.MapLogicSwitch.IsCopyMap = false
    GameCenter.MapLogicSwitch.IsPlaneCopyMap = false
    GameCenter.MapLogicSwitch.HoldFighting = false

    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_ENTER_PRISON_MAP)
    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.Bag, false)
    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.Sociality, false)
end

function PrisonSystem:OnLeaveScene()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LEAVE_PRISON_MAP)
    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.Bag, true)
    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.Sociality, true)
end

function PrisonSystem:GetMainUIState()
    return {
        [MainFormSubPanel.PlayerHead] = true,         -- Protagonist avatar
        [MainFormSubPanel.TargetHead] = true,         -- Target avatar
        [MainFormSubPanel.TopMenu] = false,           -- Top Menu
        [MainFormSubPanel.MiniMap] = true,            -- Mini map
        [MainFormSubPanel.FlySwordGrave] = false,     -- realm
        [MainFormSubPanel.TaskAndTeam] = true,        -- Mission and teaming
        [MainFormSubPanel.Joystick] = true,           -- Rocker
        [MainFormSubPanel.Exp] = true,                -- experience
        [MainFormSubPanel.MiniChat] = true,           -- Small chat box
        [MainFormSubPanel.Skill] = false,             -- Skill
        [MainFormSubPanel.SelectPkMode] = false,      -- Select PK mode
        [MainFormSubPanel.FunctionFly] = false,       -- New function enables flight interface
        [MainFormSubPanel.FastPrompt] = false,        -- Quick reminder interface
        [MainFormSubPanel.FastBts] = false,           -- Quick operation button interface
        [MainFormSubPanel.Ping] = true,               --ping
        [MainFormSubPanel.SkillWarning] = false,      -- Skill release warning
        [MainFormSubPanel.CustomBtn] = false,         -- Customize buttons
        [MainFormSubPanel.SitDown] = false,           -- Meditation
        [MainFormSubPanel.RemotePlayerHead] = true,   -- Remote player
        [MainFormSubPanel.ChangeSkill] = false,       -- Transformation skills
        [MainFormSubPanel.RightMenuBox] = false,      -- Main RightMenuBox
    }
end

function PrisonSystem:GetMainLeftUIState()
    return {
        [MainLeftSubPanel.Task] = true,        -- Task pagination
        [MainLeftSubPanel.Team] = false,        -- Team pagination
        [MainLeftSubPanel.Other] = false,      -- Other pagination
    }
end

return PrisonSystem

