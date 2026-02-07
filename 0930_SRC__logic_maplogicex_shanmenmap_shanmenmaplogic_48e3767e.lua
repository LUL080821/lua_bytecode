------------------------------------------------
-- Author: 
-- Date: 2019-09-06
-- File: ShanMenMapLogic.lua
-- Module: ShanMenMapLogic
-- Description: Shanmen copy logic
------------------------------------------------
local L_Vector3 = CS.UnityEngine.Vector3
local AnimationPlayer = CS.Thousandto.Core.Asset.AnimationPlayer
local L_PostEffectManager = CS.Thousandto.Core.PostEffect.PostEffectManager
local ShanMenMapLogic = {
    Parent = nil,
    DTStartX = 0,
    DTStartY = 0,
    DTNpc = nil,
    CameraControl = nil,
    CameraManager = nil,
    CameraAnimGo = nil,
    HideOtherPartTimer = 0,

    LongBornGo = nil,
    LongTimer = 5,
    HuLiNPC = nil,
    HuLiTimer = 0,
    BossShow1Go = nil,
    BossShow2Go = nil,

    EnterAnimgGos = nil,
    EnterAnimTimer = nil,
    CurEnterAnimGo = nil,
    ShadowIsEnable = false,

    IsInPrison = false,
    CurPrisonState = nil,
    FirstPrisonTask = 0,
    StateTimer = 0,
    TargetPosX = 139.05,
    TargetPosY = 45.43,
}

local L_LogicPrisonState = {
    MoveToPos = 1,
    Stop = 2,
    RunPrisonTask = 3,
}

function ShanMenMapLogic:OnChangeSetting(obj, sender)
    -- Handle game setting changes if needed
    if (obj == nil) then
        obj = GameCenter.GameSetting:GetSetting(GameSettingKeyCode.QualityLevel)
    end
    local _sceneRoot = GameObject.Find("SceneRoot").transform
    if (_sceneRoot == nil) then return end
    -- local qLevel = ameCenter.GameSetting:GetSetting(GameSettingKeyCode.QualityLevel)
    self.grass_03 = UIUtils.FindGo(_sceneRoot, "[near]/grass_03")
    if self.grass_03 ~= nil then
        if (obj ==0) then 
            self.grass_03:SetActive(false)
        else 
            self.grass_03:SetActive(true)
        end
    end
    self.luas = UIUtils.FindGo(_sceneRoot, "[near]/lua")
    if self.luas ~= nil then
        if (obj ==0) then 
            self.luas:SetActive(false)
        else 
            self.luas:SetActive(true)
        end
    end
    self.ruongW = UIUtils.FindGo(_sceneRoot, "[midle]/ruongW")
    if self.ruongW ~= nil then
        if (obj ==0) then 
            self.ruongW:SetActive(false)
        else 
            self.ruongW:SetActive(true)
        end
    end
end

function ShanMenMapLogic:OnEnterScene(parent)
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

    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_TASKINIT, self.OnTaskChange, self)
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_TASKCHANG, self.OnTaskChange, self)
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_TASKFINISH, self.OnTaskFinish, self)
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_FLYTELEPORT_START, self.OnFlyTeleportStart, self)

    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_UPDATEGAMESETTING_FORM, self.OnChangeSetting, self)

    -- Create a door animation player
    self.EnterAnimgGos = {}
    local _sceneRoot = GameObject.Find("SceneRoot").transform
    if _sceneRoot ~= nil then
        self.CameraAnimGo = UIUtils.FindGo(_sceneRoot, "zhuchengshexiangjidonghua")
        if self.CameraAnimGo ~= nil then
            self.CameraAnimGo:SetActive(false)
        end
        self.WYJJieFengGo = UIUtils.FindGo(_sceneRoot, "wanyaojuanfeizou")
        self.WYJFengYinVfx1 = UIUtils.FindGo(_sceneRoot, "Cuberongyan/fengying")
        self.WYJFengYinVfx2 = UIUtils.FindGo(_sceneRoot, "Cuberongyan/zhuchenfazhenjiefeng")
        self.WYJFengYinVfx3 = UIUtils.FindGo(_sceneRoot, "Cuberongyan/fengyingjiasu")

        self:OnChangeSetting()

        Debug.Log("Disable effect LongBorn go when create player");
        -- self.LongBornGo = UIUtils.FindGo(_sceneRoot, "[vfx]/[LongBorn]")
        -- if self.LongBornGo ~= nil then
        --     self.LongBornGo:SetActive(false)
        -- end

        -- [Gosu] Fix: hide effect go when create player
        Debug.Log("hide effect go when create player");
        -- for i = 1, 4 do
        --     self.EnterAnimgGos[i] = UIUtils.FindGo(_sceneRoot, string.format("[timeline]/[PlayerEnter%d]", i - 1))
        --     if self.EnterAnimgGos[i] ~= nil then
        --         self.EnterAnimgGos[i]:SetActive(false)
        --     end
        -- end
    end

    local _scene = GameCenter.GameSceneSystem.ActivedScene
    self.CameraControl = _scene.SceneCameraControl
    self.CameraManager = _scene.CameraManager

    self.EnterAnimTimer = nil
    self.CurEnterAnimGo = nil
    local _closeLoading = true
    self.ShadowIsEnable = L_PostEffectManager.Instance.IsEnableShadow
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
   
    -- if not GameCenter.LuaTaskManager:IsMainTaskOver(99001) and _lp.Level == 1 then
    --     -- The door opening task was not completed
    --     local _animGo = self.EnterAnimgGos[_lp.Occ + 1]
    --     if _animGo ~= nil then
    --         _closeLoading = true
    --         _animGo:SetActive(true)
    --         GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_ADD_MAINCAMERA_HIDECOUNTER)
    --         self.EnterAnimTimer = 7.75
    --         self.CurEnterAnimGo = _animGo
    --         GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_HIDEANIMATION)
    --         -- Preload welcome interface resources
    --         GameCenter.MapLogicSwitch:PreLoadPrefab(ModelTypeCode.Monster, 5002)
    --         --L_PostEffectManager.Instance:EnableShadow(false)
    --         -- The combat status is set to true, in order to take out the weapon and keep it consistent with the animation
    --         _lp.FightState = true
    --         _lp.RootGameObject:SetActive(false)
    --         GameCenter.MapLogicSwitch.HideOtherPlayer = true
    --     else
    --         GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_OPEN_WELECOME_PANEL)
    --         _closeLoading = false
    --     end
    -- else
    --     -- The door opening task has been completed
    --     GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UNLOAD_WELECOME_RES)
    -- end
  
    -- if not GameCenter.LuaTaskManager:IsMainTaskOver(99011) and not GameCenter.LuaTaskManager:CanSubmitTask(99011) then
    --     -- Show the task without completion
    --     if self.WYJJieFengGo ~= nil then
    --         self.WYJJieFengGo:SetActive(true)
    --         local _animList = UIUtils.RequireAnimListBaseScript(self.WYJJieFengGo.transform)
    --         if _animList ~= nil then
    --             self.AnimPlayer = AnimationPlayer(_animList, 1)
    --             self.AnimPlayer.CullingType = 0
    --             self.AnimPlayer:Play("idle", 0, 2)
    --         end
    --     end
    --     if self.WYJFengYinVfx1 ~= nil then
    --         self.WYJFengYinVfx1:SetActive(true)
    --     end
    --     if self.WYJFengYinVfx2 ~= nil then
    --         self.WYJFengYinVfx2:SetActive(false)
    --     end
    --     if self.WYJFengYinVfx3 ~= nil then
    --         self.WYJFengYinVfx3:SetActive(false)
    --     end

    --     -- Preload the boss animation of Wan Yaoshu
    --     GameCenter.MapLogicSwitch:PreLoadPrefab(ModelTypeCode.Timeline, 4)
    --     GameCenter.MapLogicSwitch:PreLoadPrefab(ModelTypeCode.Timeline, 5)
    -- else
    --     -- Complete the task and hide it
    --     if self.WYJJieFengGo ~= nil then
    --         self.WYJJieFengGo:SetActive(false)
    --     end
    --     if self.WYJFengYinVfx1 ~= nil then
    --         self.WYJFengYinVfx1:SetActive(false)
    --     end
    --     if self.WYJFengYinVfx2 ~= nil then
    --         self.WYJFengYinVfx2:SetActive(false)
    --     end

    --     if self.WYJFengYinVfx3 ~= nil then
    --         self.WYJFengYinVfx3:SetActive(false)
    --     end
    -- end

    -- if not GameCenter.LuaTaskManager:IsMainTaskOver(99014) and not GameCenter.LuaTaskManager:CanSubmitTask(99014) then
    --     -- Preload the boss animation of Wan Yaoshu
    --     GameCenter.MapLogicSwitch:PreLoadPrefab(ModelTypeCode.Timeline, 6)
    -- end

    self.HideOtherPartTimer = 2
    self.LongTimer = -1
    if _lp.Level < 30 then
        -- Preload mounts to get animation
        local _occ = _lp.Occ
        local _guideCfg = DataConfig.DataGuide[4]
        if _guideCfg ~= nil then
            local _animIds = Utils.SplitNumber(_guideCfg.Steps, ';')
            local _mountAnimId = _animIds[_occ]
            if _mountAnimId ~= nil then
                GameCenter.MapLogicSwitch:PreLoadPrefab(ModelTypeCode.Timeline, _mountAnimId)
            end
        end
        -- Preload sword tomb model
        GameCenter.MapLogicSwitch:PreLoadPrefab(ModelTypeCode.UISceneModel, 3)
    end

    self:OnPrisonEnterScene()
    return _closeLoading
end
function ShanMenMapLogic:OnPrisonEnterScene()
    self:CheckPrisonStart()
    if self.IsInPrison then
        GameCenter.PrisonSystem:OnEnterScene()
    end
end

function ShanMenMapLogic:CheckPrisonStart()
    self.IsInPrison = false

    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end
    
    local _prisonTaskFristCfg = DataConfig.DataGlobal[GlobalName.Prison_Task_First]
    if _prisonTaskFristCfg ~= nil then
        self.FirstPrisonTask = tonumber(_prisonTaskFristCfg.Params)
    else
        self.FirstPrisonTask = 0
    end
    
    if self.FirstPrisonTask == 0 then
        return
    end
    
    if _lp.IsInPrison then
        self.IsInPrison = true
        self:ChangePrisonState(L_LogicPrisonState.MoveToPos)

        -- Recall the prison task target description first behavior
        local cur_prison_task_id = GameCenter.LuaTaskManager:GetPrisonTaskId()
        if cur_prison_task_id == self.FirstPrisonTask then
            local _behavior = GameCenter.LuaTaskManager:GetBehavior(self.FirstPrisonTask)
            if _behavior then
                _behavior:SetTargetDes()
            end
        end
    end
end

function ShanMenMapLogic:ChangePrisonState(state)
    self.CurPrisonState = state
    if state == L_LogicPrisonState.MoveToPos then
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if _lp ~= nil then
            _lp:Action_MoveTo(L_Vector3(self.TargetPosX, 0, self.TargetPosY), 0.2)
        end
    elseif state == L_LogicPrisonState.Stop then
        self.StateTimer = 0.5
    elseif state == L_LogicPrisonState.RunPrisonTask then
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if _lp ~= nil then
            GameCenter.TaskController:Run(GameCenter.LuaTaskManager:GetPrisonTaskId())
        end
    end
end

function ShanMenMapLogic:UpdatePrisonState(dt)
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil or not _lp.IsInPrison then 
        return
    end

    if GameCenter.LuaTaskManager:IsPrisonTaskOver(self.FirstPrisonTask) then
        return
    end

    if self.CurPrisonState == L_LogicPrisonState.MoveToPos then
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if _lp ~= nil then
            if not _lp:IsMoving() then
                _lp:Action_MoveTo(L_Vector3(self.TargetPosX, 0, self.TargetPosY), 0.2)
            end
            if self:IsLocalPlayerNearTarget(self.TargetPosX, self.TargetPosY, 0.045) then
                self:ChangePrisonState(L_LogicPrisonState.Stop)
                _lp:Stop_Action()
                _lp:RayCastToGround(L_Vector3(self.TargetPosX, 0, self.TargetPosY))
            end
        end
        if GameCenter.MandateSystem:IsRunning() then
            GameCenter.MandateSystem:End()
        end
    elseif self.CurPrisonState == L_LogicPrisonState.Stop then
        self.StateTimer = self.StateTimer - dt
        if self.StateTimer <= 0 then
            self:ChangePrisonState(L_LogicPrisonState.RunPrisonTask)
        end
    elseif self.CurPrisonState == L_LogicPrisonState.RunPrisonTask then
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if _lp ~= nil then
            if not _lp:IsMoving() and not GameCenter.MandateSystem:IsRunning() then
                if self:IsLocalPlayerNearTarget(self.TargetPosX, self.TargetPosY, 0.045) then
                    if not GameCenter.LuaTaskManager:IsPrisonTaskOver(self.FirstPrisonTask) then
                        self:ChangePrisonState(L_LogicPrisonState.MoveToPos)
                    end
                else
                    self:ChangePrisonState(L_LogicPrisonState.MoveToPos)
                end
            end
        end
    end
end

function ShanMenMapLogic:IsLocalPlayerNearTarget(targetX, targetY, threshold)
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return false
    end
    if _lp ~= nil then
        local _pos2d = _lp.Position2d
        local _xDis = math.abs(_pos2d.x - targetX)
        local _yDis = math.abs(_pos2d.y - targetY)
        if _xDis * _xDis + _yDis * _yDis <= threshold then
            return true
        end
    end
    return false
end

function ShanMenMapLogic:OnLeaveScene()
    if self.CameraAnimGo ~= nil then
        self.CameraAnimGo:SetActive(false)
    end
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_TASKINIT, self.OnTaskChange, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_TASKCHANG, self.OnTaskChange, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_TASKFINISH, self.OnTaskFinish, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_FLYTELEPORT_START, self.OnFlyTeleportStart, self)
    
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_UPDATEGAMESETTING_FORM, self.OnChangeSetting, self)
    GameCenter.MapLogicSwitch.HideOtherPlayer = false
    GameCenter.MapLogicSwitch.HideFaBao = false
    if self.AnimPlayer ~= nil then
        self.AnimPlayer:Destory()
    end
    
    self:OnPrisonLeaveScene()
end
function ShanMenMapLogic:OnPrisonLeaveScene()
    if self.IsInPrison then
        GameCenter.PrisonSystem:OnLeaveScene()
    end
    self.IsInPrison = false
end

function ShanMenMapLogic:PlayLongBorn()
    if self.LongBornGo ~= nil then
        self.LongBornGo:SetActive(true)
        self.LongTimer = 5
    else
        GameCenter.TaskController:Run(GameCenter.LuaTaskManager:GetMainTaskId())
    end
end

function ShanMenMapLogic:OnMsgHandle(msg)
end

function ShanMenMapLogic:OnTaskChange(obj, sender)
    local cur_prison_task_id = GameCenter.LuaTaskManager:GetPrisonTaskId()
    if cur_prison_task_id == self.FirstPrisonTask then
        if GameCenter.LuaTaskManager:IsPrisonTaskOver(self.FirstPrisonTask) then
            self.IsInPrison = false
        else
            self.IsInPrison = true
            self:ChangePrisonState(L_LogicPrisonState.MoveToPos)
        end
    end
end

function ShanMenMapLogic:OnTaskFinish(obj, sender)
    if 99011 == obj then
        if self.WYJJieFengGo ~= nil then
            self.WYJJieFengGo:SetActive(false)
        end

        if self.WYJFengYinVfx1 ~= nil then
            self.WYJFengYinVfx1:SetActive(false)
        end
        if self.WYJFengYinVfx2 ~= nil then
            self.WYJFengYinVfx2:SetActive(false)
        end

        if self.WYJFengYinVfx3 ~= nil then
            self.WYJFengYinVfx3:SetActive(false)
        end
    end
end

-- Play the effect of the fox being trampled
function ShanMenMapLogic:OnFlyTeleportStart(obj, sender)
    local _huli = GameCenter.MapLogicSwitch:FindNpcByDataID(40207)
    if _huli ~= nil then
        _huli:PlayAnim("sleep", 0, 2)
        self.HuLiNPC = _huli
        self.HuLiTimer = 3.5
    end
end

function ShanMenMapLogic:Update(dt)
    if self.EnterAnimTimer ~= nil then
        self.EnterAnimTimer = self.EnterAnimTimer - dt
        if self.EnterAnimTimer <= 0 then
            self.EnterAnimTimer = nil
            if self.CurEnterAnimGo ~= nil then
                self.CurEnterAnimGo:SetActive(false)
            end
            GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_SHOWANIMATION)
            GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_DEC_MAINCAMERA_HIDECOUNTER)
            -- Open the environment interface
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_OPEN_WELECOME_PANEL)
            --L_PostEffectManager.Instance:EnableShadow(self.ShadowIsEnable)
            local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
            _lp.RootGameObject:SetActive(true)
            GameCenter.MapLogicSwitch.HideOtherPlayer = false
            -- Actively refresh the scene camera to prevent camera shaking
            self.CameraControl:Update()
        end
    end
  
    if self.AnimPlayer ~= nil then
        self.AnimPlayer:Update(dt)
    end
    if self.HuLiTimer > 0 then
        self.HuLiTimer = self.HuLiTimer - dt
        if self.HuLiTimer <= 0 and self.HuLiNPC ~= nil then
            self.HuLiNPC:PlayAnim("jingxing", 0, 1)
            self.HuLiNPC = nil
        end
    end
    if self.LongTimer > 0 then
        local _frontTimer = self.LongTimer 
        self.LongTimer = self.LongTimer - dt
        if _frontTimer > 4.5 and self.LongTimer <= 4.5 then
            GameCenter.TaskController:Run(GameCenter.LuaTaskManager:GetMainTaskId())
        end
        if self.LongTimer <= 0 and self.LongBornGo ~= nil then
            self.LongBornGo:SetActive(false)
        end
    end
    if self.HideOtherPartTimer > 0 then
        self.HideOtherPartTimer = self.HideOtherPartTimer - dt
        if self.HideOtherPartTimer <= 0 then
            local _sceneRoot = GameObject.Find("SceneRoot").transform
            if _sceneRoot ~= nil then
                -- Hidden magic treasure
                local _faBaoScene = _sceneRoot:Find("part_fabao")
                if _faBaoScene ~= nil then
                    _faBaoScene.gameObject:SetActive(false)
                end
                -- Hide the disaster
                local _duJieScene = _sceneRoot:Find("part_dujie")
                if _duJieScene ~= nil then
                    _duJieScene.gameObject:SetActive(false)
                end
                -- Hidden Demon Scroll
                local _wyjScene = _sceneRoot:Find("wanyaojuan")
                if _wyjScene ~= nil then
                    _wyjScene.gameObject:SetActive(false)
                end
            end
        end
    end

    if self.IsInPrison then
        self:UpdatePrisonState(dt)
    end
end

function ShanMenMapLogic:GetMainUIState()
    if self.IsInPrison then
        return GameCenter.PrisonSystem:GetMainUIState()
    end
    
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

function ShanMenMapLogic:GetMainLeftUIState()
    if self.IsInPrison then
        return GameCenter.PrisonSystem:GetMainLeftUIState()
    end

    return {
        [MainLeftSubPanel.Task] = true,        -- Task pagination
        [MainLeftSubPanel.Team] = true,        -- Team pagination
        [MainLeftSubPanel.Other] = false,      -- Other pagination
    }
end

return ShanMenMapLogic