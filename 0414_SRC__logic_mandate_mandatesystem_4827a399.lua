------------------------------------------------
-- Author:
-- Date: 2021-03-26
-- File: MandateSystem.lua
-- Module: MandateSystem
-- Description: Hang-up system
------------------------------------------------

-- The fixed distance of the hang-up will move back to the starting point after exceeding this distance.
local L_MaxSqrDistance = 18 * 18
-- Time for each heartbeat
local L_HeartTickTime = 0.1
local L_Vector2 = CS.UnityEngine.Vector2
local L_CombatUtil = CS.Thousandto.Code.Logic.CombatUtil
local L_EntityStateID = CS.Thousandto.Core.Asset.EntityStateID

local MandateSystem = {
    -- Whether to enable
    IsMandating = false,
    -- Heartbeat timer
    HeartTimer = 0.0,
    -- Owner
    Owner = nil,
    -- Hang-up type
    MandateType = MandateType.Map,
    -- Attacked monster ID, used for hang-up of tasks
    MonsterID = 0,
    -- List of skills to be selected
    SkillList = nil,
    CurChooseSkill = 0,
    -- The location where the hangup starts
    StartPos2d = L_Vector2.zero,
    -- Wandering
    IsWandering = false,
    -- pause
    IsMovePause = false,
    -- Map configuration of the current map
    MapCfg = nil,
    -- Find the time to send the target message in the copy
    CopyMapFindTargetTimer = 0,
    -- Delay time
    DelayTimer = 0,
    -- Is the hang-up interface turned on?
    IsOpenMandateUI = false,

    -- delay auto sau khi bị khống chế
    ControlRecoverTimer = 0
}

function MandateSystem:IsRunning()
    return self.IsMandating
end

-- initialization
function MandateSystem:Initialize()
end

function MandateSystem:UnInitialize()
end


-- Start hanging up
function MandateSystem:Start(monsterID)
    if monsterID == nil then
        monsterID = 0
    end
    self.DelayTimer = 0
    if not GameCenter.MapLogicSwitch.CanMandate then
        return
    end

    self.Owner = GameCenter.GameSceneSystem:GetLocalPlayer()
    if self.Owner == nil then
        return
    end
    -- Following mode of the command system, if there is no target, no hang up
    if self:GetCommandFollow() and not self:GetCommandHasMonster() then
        return
    end
    self.MapCfg = GameCenter.MapLogicSystem.MapCfg
    if self.MapCfg == nil then
        return
    end
    if self.MapCfg.AutoFightSet == 0 then
        self.MandateType = MandateType.Map
    else
        self.MandateType = MandateType.Screen
    end

    if not self:InitSkillList() then
        return
    end
    self.MonsterID = monsterID
    self.StartPos2d = self.Owner.Position2d
    self.HeartTimer = 0.0
    self.IsMandating = true
    self.Owner:Stop_Action()
    self.IsWandering = false
    self.IsMovePause = false
    self.Owner:SetCurSelectedTargetId(0)
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MANDATE_STATE_CHANGED)
    if self:IsShowMandateTips() then
        GameCenter.PushFixEvent(UIEventDefine.UIMandateForm_OPEN)
    end
end

-- Whether to display a hang-up prompt
function MandateSystem:IsShowMandateTips()
    if self:GetCommandFollow() then
        return false
    end
    local _activeLogic = GameCenter.MapLogicSystem.ActiveLogic
    if _activeLogic == nil then
        return false
    end
    if _activeLogic.ShowMandateTips == false then
        return false
    end
    return true
end

-- Command system
function MandateSystem:GetCommandFollow()
    if GameCenter.MapLogicSystem.MapCfg and GameCenter.MapLogicSystem.MapCfg.MapLogicType == MapLogicTypeDefine.TerritorialWar then
        return GameCenter.MapLogicSystem.ActiveLogic.IsFollow
    end
    return false
end
-- Command system
function MandateSystem:GetCommandHasMonster()
    if GameCenter.MapLogicSystem.MapCfg and GameCenter.MapLogicSystem.MapCfg.MapLogicType == MapLogicTypeDefine.TerritorialWar then
        return GameCenter.MapLogicSystem.ActiveLogic.CurTargetMonsterId == 0
    end
    return false
end

-- Start hanging up again
function MandateSystem:ReStart()
    if not self.IsMandating then
        return
    end
    local _monserID = self.MonsterID
    self:End()
    self:Start(_monserID)
end

-- End the hangup
function MandateSystem:End()
    if not self.IsMandating then
        return
    end
    if self.Owner ~= nil then
        if PlayerBT.IsInitPlayerBD then
            if not PlayerBT.IsState(PlayerBDState.CrossMap) then
                PlayerBT.ChangeState(PlayerBDState.Default)
            end
        end
        self.Owner:Stop_Action()
        if self.Owner.skillManager ~= nil then
            self.Owner.skillManager:ClearCacheSkill()
        end
    end
    self.Owner = nil
    self.IsMandating = false
    self.MonsterID = 0
    self.SkillList = nil
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MANDATE_STATE_CHANGED)
    GameCenter.PushFixEvent(UIEventDefine.UIMandateForm_CLOSE)
end

-- Delay hang-up
function MandateSystem:SetPauseTime(time)
    self.DelayTimer = time
end

-- Refresh the hang-up start point
function MandateSystem:RefreshStartPos()
    if self.IsMandating and self.MandateType == MandateType.Screen then
        self.StartPos2d = self.Owner.Position2d
        self.MonsterID = 0
    end
end

-- The process of character movement, determine whether to stop the hangup according to the settings
function MandateSystem:OnMove()
    if self.IsMandating then
        self.IsMovePause = true
    end
end

-- Server returns to monster location
function MandateSystem:OnGetMonsterResult(posX, posY)
    if not self.IsMandating or self.Owner == nil or not PlayerBT.IsInitPlayerBD then
        return
    end
    local _pos = L_Vector2(posX, posY)
    if self.Owner:GetSqrDistance2d(_pos) >= 9 then
        PlayerBT.MapMove:Write2D(-1, _pos, 3)
    end
end

-- Initialize the skill list and sort it. When selecting a skill, it will be selected from the front to the back.
function MandateSystem:InitSkillList()
    self.SkillList = GameCenter.PlayerSkillSystem:GetMandateSkillList()
    self.CurChooseSkill = 1
    return true
end

-- Check the target, select the target when there is no target
function MandateSystem:CheckAndSelectTarget()

    --[Gosu] giật khung hình
    if self.ControlRecoverTimer > 0 then
        return
    end
    --[Gosu] End giật khung hình

    if self.IsMovePause then
        if not self.Owner:IsMoving() and not PlayerBT.IsMoving() then
            self.IsMovePause = false
        else
            return
        end
    end

    local _target = self:FindTarget()
    if _target == nil then
        -- No target, clear all cached skills
        self.Owner:SetCurSelectedTargetId(0)
        self.Owner.skillManager:ClearCacheSkill()
        if self.MandateType == MandateType.Screen then
            -- Check whether to return to the starting point on the screen
            if not self.Owner:IsMoving() and self.Owner:CanMove() and not self.Owner.skillManager:IsSkillUseing()  and self.Owner:GetSqrDistance2d(self.StartPos2d) > 25 then
                -- Find the way back to the starting point
                PlayerBT.MapMove:Write2D(-1, self.StartPos2d, 1)
            end
        else
            -- Determine whether to start patrol
            if not self.IsWandering then
                self:BeginWander()
            end
        end
    else
        if self.MandateType == MandateType.Screen and not self.Owner.skillManager:IsSkillUseing() and
            not self.Owner:IsMoving() and self.Owner:CanMove() and self.Owner:GetSqrDistance2d(self.StartPos2d) > L_MaxSqrDistance then
            local _targetType = UnityUtils.GetType(_target)
            if string.find(_targetType, "RemotePlayer") == nil then
                -- Find the way back to the starting point
                self.Owner:SetCurSelectedTargetId(0)
                PlayerBT.MapMove:Write2D(-1, self.StartPos2d, 1)
                return
            end
        end
        self.Owner:SetCurSelectedTargetId(_target.ID)
    end
end

function MandateSystem:GetCurrentTarget()
    local _curTarget = self.Owner:GetCurSelectedTarget()
    if L_CombatUtil.CanAttackTarget(self.Owner, _curTarget, false) then
        return _curTarget
    end
    return nil
end

-- Obtain the target
function MandateSystem:FindTarget()
    local _curTarget = self:GetCurrentTarget()
    if _curTarget ~= nil and _curTarget.CanBeSelect and L_CombatUtil.CanAttackTarget(self.Owner, _curTarget, false) and not self.Owner.CurSelectTargetIsAuto then
        return _curTarget
    end
    -- If automatic counterattack is enabled and there are players in the hatred list, select the player
    if GameCenter.MapLogicSwitch.UseAutoStrikeBack then
        local _strikeBack = GameCenter.GameSetting:GetSetting(GameSettingKeyCode.MandateAutoStrikeBack)
        if _strikeBack ~= 0 and self.Owner.StrikeBackTable.Count > 0 then
            local _enumer = self.Owner.StrikeBackTable:GetEnumerator()
            while _enumer:MoveNext() do
                local _target = GameCenter.GameSceneSystem:FindPlayer(_enumer.Current.Key)
                if _target ~= nil and not _target:IsDead() and _target.CanBeSelect then
                    _curTarget = _target
                    break
                end
            end
        end
    end
    -- No priority attack target was found, get the current target
    if _curTarget == nil then
        _curTarget = self:GetCurrentTarget()
        if not L_CombatUtil.CanAttackTarget(self.Owner, _curTarget, false) or not _curTarget.CanBeSelect then
            _curTarget = nil
            self.Owner:SetCurSelectedTargetId(0)
        end
    end
    -- No current target, find target
    if _curTarget == nil then
        _curTarget = L_CombatUtil.FindMandateTarget(self.Owner, self.MonsterID)
    end
    -- Check the screen hanger
    if _curTarget ~= nil and self.MandateType == MandateType.Screen then
        -- Determine whether the screen hang-up distance is exceeded
        local _dis = self.Owner:GetSqrDistance2d(_curTarget.Position2d)
        if _dis > L_MaxSqrDistance then
            _curTarget = nil
        end
    end
    return _curTarget
end

-- Check skills and use skills
function MandateSystem:CheckAndUseSkill()

    --[Gosu] giật khung hình
    if self.ControlRecoverTimer > 0 then
        return
    end
    --[Gosu] End giật khung hình

    if self.IsMovePause then
        return
    end
    if not self.Owner.skillManager:IsSkillUseing() and not PlayerBT.IsState(PlayerBDState.UseSkillState) then
        if self.Owner:IsDead() then
            -- Clear the skills
            self.Owner.skillManager:ClearCacheSkill()
            return
        end
        local _curTarget = self.Owner:GetCurSelectedTarget()
        if _curTarget ~= nil and L_CombatUtil.CanAttackTarget(self.Owner, _curTarget, false) then
            if not _curTarget.IsBorning then
                local _isChoose = false
                for i = self.CurChooseSkill, #self.SkillList do
                    if not GameCenter.PlayerSkillSystem:SkillIsCD(self.SkillList[i]) then
                        PlayerBT.UseSkill:Write(self.SkillList[i], _curTarget.Position2d - self.Owner.Position2d)
                        _isChoose = true
                        self.CurChooseSkill = i + 1
                        break
                    end
                end
                if not _isChoose then
                    for i = 1, #self.SkillList do
                        if not GameCenter.PlayerSkillSystem:SkillIsCD(self.SkillList[i]) then
                            PlayerBT.UseSkill:Write(self.SkillList[i], _curTarget.Position2d - self.Owner.Position2d)
                            _isChoose = true
                            self.CurChooseSkill = i + 1
                            break
                        end
                    end
                end
            end
        end
    end
end
-- Begin to wander
function MandateSystem:BeginWander()
    if self.MapCfg.Type ~= UnityUtils.GetObjct2Int(MapTypeDef.Map) and self.MapCfg.Type ~= 5 then
        self.CopyMapFindTargetTimer = 2
        self.IsWandering = true
    end
end

-- Update Wandering
function MandateSystem:UpdateWander(dt)
    if not self.IsWandering then
        return
    end
    local _target = self:FindTarget()
    -- Found the target that can be attacked and is not in the safe area, ending wandering
    if _target ~= nil then
        self.Owner:SetCurSelectedTargetId(_target.ID)
        self.IsWandering = false
        PlayerBT.ChangeState(PlayerBDState.Default)
        self.Owner:Stop_Action()
    -- The target cannot be found, but I have stopped moving and re-entered the wandering state
    elseif self.Owner:IsXState(L_EntityStateID.Idle) and not PlayerBT.IsMoving() then
        if self.MapCfg.Type ~= UnityUtils.GetObjct2Int(MapTypeDef.Map) and self.MapCfg.Type ~= 5 then
            if self.MapCfg.Xunlu ~= nil and string.len(self.MapCfg.Xunlu) > 0 then
                local _paramArray = Utils.SplitStrByTableS(self.MapCfg.Xunlu, {';', '_'})
                for i = 1, #_paramArray do
                    local _camp = _paramArray[i][1]
                    local _x = _paramArray[i][2]
                    local _y = _paramArray[i][3]
                    self:OnGetMonsterResult(_x, _y)
                end
            else
                self.CopyMapFindTargetTimer = self.CopyMapFindTargetTimer + dt
                if self.CopyMapFindTargetTimer >= 2 then
                    self.CopyMapFindTargetTimer = 0
                    self:SendFindTargetMsg()
                end
            end
        end
    end
end
--
function MandateSystem:SendFindTargetMsg()
    GameCenter.Network.Send("MSG_Map.ReqGetMonsterPos")
end


-- [Gosu] - các code liên quan đến chỉnh sửa skill bị đẩy, giật khung hình

function MandateSystem:IsInControlState()
    if not self.Owner then return false end

    return self.Owner:IsXState(L_EntityStateID.BeHitBack)
        or self.Owner:IsXState(L_EntityStateID.BeHitFly)
        or self.Owner:IsXState(L_EntityStateID.BeHitGrab)
        or self.Owner:IsXState(L_EntityStateID.BeHit)
        or self.Owner:IsXState(L_EntityStateID.Fly)
        or self.Owner:IsXState(L_EntityStateID.FlyTeleport)
        or self.Owner:IsXState(L_EntityStateID.RollDodge)
        or self.Owner:IsXState(L_EntityStateID.Jump)
        or self.Owner:IsXState(L_EntityStateID.MountFlyUp)
        or self.Owner:IsXState(L_EntityStateID.MountFlyDown)
        or self.Owner:IsXState(L_EntityStateID.CrossMapTran)
        or self.Owner:IsXState(L_EntityStateID.EnterMap)
end


-- [Gosu] - End



function MandateSystem:Update(dt)

    --[Gosu] -- giật khung hình
    -- chết thì khỏi auto

    -- đang bị khống chế → reset timer
    if self:IsInControlState() then
        self.ControlRecoverTimer = 0.35 -- 350ms sau khi thoát state mới auto lại
        return
    end

    -- vừa thoát khống chế → chờ thêm chút cho animation mượt
    if self.ControlRecoverTimer > 0 then
        self.ControlRecoverTimer = self.ControlRecoverTimer - dt
        return
    end

    -- [Gosu] -- End giật khung hình



    if not self.IsMandating then
        return
    end
    local _activeLogic = GameCenter.MapLogicSystem.ActiveLogic
    if _activeLogic == nil then
        return
    end
    if self.Owner == nil or self.Owner:IsDead() or self.Owner.skillManager == nil then
        return
    end
    if self.SkillList == nil then
        return
    end
    if self.DelayTimer > 0 then
        self.DelayTimer = self.DelayTimer - dt
        return false
    end
    -- Heartbeat Limit
    if self.HeartTimer > 0 then
        self.HeartTimer = self.HeartTimer - dt
        return false
    end
    self.HeartTimer = L_HeartTickTime

    if _activeLogic.CustomMandate == true then
        return
    end
    -- Select a target
    self:CheckAndSelectTarget()
    -- Usage skills
    self:CheckAndUseSkill()
    -- Wandering
    self:UpdateWander(L_HeartTickTime)
    if self.IsOpenMandateUI and not self:IsShowMandateTips() then
        GameCenter.PushFixEvent(UIEventDefine.UIMandateForm_OPEN)
    end
end

return MandateSystem