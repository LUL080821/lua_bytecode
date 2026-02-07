------------------------------------------------
-- Author: 
-- Date: 2025-04-15
-- File: NewTrainMap.lua
-- Module: NewTrainMap
-- Description: Default map logic
------------------------------------------------
local CSGameCenter = CS.Thousandto.Code.Center.GameCenter
local L_Vector3 = CS.UnityEngine.Vector3
local L_Quaternion = CS.UnityEngine.Quaternion
local NewTrainMap = {
    Parent = nil,
    WaterObj = nil,
    -- DelayFrame = 0,
}

local PlayerRotateConfig = {
    [1602] = -90,
    [1603] = 90,
    -- thêm map khác tại đây
}


function NewTrainMap:OnEnterScene(parent)
    self.Parent = parent

    -- Set the switch
    GameCenter.MapLogicSwitch.CanRide = true
    GameCenter.MapLogicSwitch.CanFly = true
    GameCenter.MapLogicSwitch.CanRollDoge = true
    GameCenter.MapLogicSwitch.CanMandate = true
    GameCenter.MapLogicSwitch.CanOpenTeam = true
    GameCenter.MapLogicSwitch.ShowNewFunction = true
    GameCenter.MapLogicSwitch.UseAutoStrikeBack = true
    GameCenter.MapLogicSwitch.CanTeleport = true
    GameCenter.MapLogicSwitch.IsCopyMap = false
    GameCenter.MapLogicSwitch.IsPlaneCopyMap = false
    GameCenter.MapLogicSwitch.HoldFighting = false
    

    local _mapId = GameCenter.GameSceneSystem.ActivedScene.MapId
    local _cfg = DataConfig.DataMapsetting[_mapId]

  
    self.LP = GameCenter.GameSceneSystem:GetLocalPlayer()
    local _scene = GameCenter.GameSceneSystem.ActivedScene
    self.CameraControl = _scene.SceneCameraControl
    self.CameraManager = _scene.CameraManager
    

    local rotateYaw = PlayerRotateConfig[_mapId] or 0

    -- ⭐ Xoay player đúng theo map
    if self.LP then
        local vec3 = L_Vector3(0, rotateYaw, 0)
        self.LP.Skin.RootGameObject.transform.rotation = L_Quaternion.Euler(vec3)
        -- Debug.Log(">>> Apply player rotation for map:", _mapId, "yaw:", rotateYaw)
    end

    -- Off -> On Water Object -> Fixed Water.cs
    -- local _sceneRoot = GameObject.Find("SceneRoot").transform
    -- if (_sceneRoot == nil) then return end
    -- self.WaterObj = UIUtils.FindGo(_sceneRoot, "[far]/1/Water")
    -- if self.WaterObj ~= nil then
    --     self.WaterObj:SetActive(false)
    --     self.WaterObj:SetActive(true)
    -- end
end

-- function NewTrainMap:Update(dt)
    -- if self.DelayFrame >= 0 and self.DelayFrame < 30 then
    --     self.DelayFrame = self.DelayFrame + 1
    -- else
    --     -- Ensure the water object is active
    --     if self.WaterObj ~= nil and not self.WaterObj.activeSelf then
    --         self.DelayFrame = -1
    --         self.WaterObj:SetActive(false)
    --         self.WaterObj:SetActive(true)
    --     end
    -- end

    -- if self.LP == nil then
    --     return
    -- end
    -- if not self.LP.IsOnMount then
    --     return
    -- end
    -- local _nav = self.LP.Scene.navigator
    -- local cell_type = _nav:GetCellType(self.LP.Position2d)
    -- if tostring(cell_type) == "Water: 3" then
    --     self.LP:MountDown()
    -- end
-- end

function NewTrainMap:OnLeaveScene()
    self.LP = nil
end

function NewTrainMap:OnMsgHandle(msg)
end

function NewTrainMap:GetMainUIState()
    return {
        [MainFormSubPanel.PlayerHead] = true,         -- Protagonist avatar
        [MainFormSubPanel.TargetHead] = true,         -- Target avatar
        [MainFormSubPanel.TopMenu] = true,            -- Top Menu
        [MainFormSubPanel.MiniMap] = true,            -- Mini map
        [MainFormSubPanel.FlySwordGrave] = true,              -- realm
        [MainFormSubPanel.TaskAndTeam] = true,        -- Mission and teaming
        [MainFormSubPanel.Joystick] = true,           -- Rocker
        [MainFormSubPanel.Exp] = true,                -- experience
        [MainFormSubPanel.MiniChat] = true,           -- Small chat box
        [MainFormSubPanel.Skill] = true,              -- Skill
        [MainFormSubPanel.SelectPkMode] = true,       -- Select PK mode
        [MainFormSubPanel.FunctionFly] = true,        -- New function enables flight interface
        [MainFormSubPanel.FastPrompt] = true,         -- Quick reminder interface
        [MainFormSubPanel.FastBts] = true,            -- Quick operation button interface
        [MainFormSubPanel.Ping] = true,               --ping
        [MainFormSubPanel.SkillWarning] = false,      -- Skill release warning
        [MainFormSubPanel.CustomBtn] = true,          -- Customize buttons
        [MainFormSubPanel.SitDown] = true,            -- Meditation
        [MainFormSubPanel.RemotePlayerHead] = true,   -- Remote player
        [MainFormSubPanel.ChangeSkill] = true,     -- Transformation skills
        [MainFormSubPanel.RightMenuBox] = true,       -- Main RightMenuBox
    }
end

function NewTrainMap:GetMainLeftUIState()
    return {
        [MainLeftSubPanel.Task] = true,        -- Task pagination
        [MainLeftSubPanel.Team] = true,        -- Team pagination
        [MainLeftSubPanel.Other] = false,      -- Other pagination
    }
end

return NewTrainMap