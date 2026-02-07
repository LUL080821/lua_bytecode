------------------------------------------------
-- Author:
-- Date: 2021-03-10
-- File: TaskTransNPC.lua
-- Module: FaBao
-- Description: Magic weapon character
------------------------------------------------
local L_CharBase = require "Logic.LuaCharacter.Base.CharacterBase"
local L_Vector3 = CS.UnityEngine.Vector3
local L_Vector2 = CS.UnityEngine.Vector2
local L_Quaternion = CS.UnityEngine.Quaternion
local L_RotQua = L_Quaternion.AngleAxis(-135, L_Vector3.up)
local L_SprVfx1Center = L_Vector3(0, 1, 0).normalized
local L_SprVfx2Center = L_Vector3(0.5, 0.5, 0).normalized
local L_SprVfx3Center = L_Vector3(-0.5, 0.5, 0).normalized
local L_VfxDis = 0.5

local TaskTransNPC = {
    MasterID = 0,
    Cfg = nil,
    IsLocal = false,
    DeleteWaitFrame = 0,
    TimeShowPrompt = 0,
    IsLongDistanceMaster = false,

    SprVfx1 = nil,
    SprVfx2 = nil,
    SprVfx3 = nil,
    Spr1Angle = 0,
    Spr2Angle = 120,
    Spr3Angle = 240,
    FollowHeight = 0,
    MoveSpeedScale = 1,
    IsMoving = false,

    WaitMasterCreated = false,
}

function TaskTransNPC:New(csChar, initInfo)
    local _m = Utils.DeepCopy(self)
    setmetatable(_m, {__index = L_CharBase:New()})
    _m:BindCSCharacter(csChar, initInfo.UserData.CharType)
    return _m
end

function TaskTransNPC:OnSetupFSMBefore()
end

function TaskTransNPC:OnSetupFSM()
end

function TaskTransNPC:OnInitializeAfter(initInfo)
    self:OnSyncInfo(initInfo)
end

function TaskTransNPC:OnSyncInfo(initInfo)
    self.IsMasterCreated = false
    self.IsMoving = false
    self.MasterID = initInfo.UserData.MasterId
    self.Cfg = initInfo.UserData.Cfg
    self.IsLocal = initInfo.UserData.IsLocal
    self.FollowHeight = initInfo.UserData.FollowHeight

    self:SetEquip(FSkinPartCode.Body, self.Cfg.Res)
    local _master = GameCenter.GameSceneSystem:FindPlayer(self.MasterID)
    if _master ~= nil then
        self.CSChar:RayCastToGroundXOZ(_master.Position2d)
        self.CSChar.IsShowModel = _master.IsShowModel
    else
        self.IsMasterCreated = true
    end
    if self.SprVfx1 ~= nil then
        self.SprVfx1:Destroy()
    end
    if self.SprVfx2 ~= nil then
        self.SprVfx2:Destroy()
    end
    if self.SprVfx3 ~= nil then
        self.SprVfx3:Destroy()
    end
    self.SprVfx1 = nil
    self.SprVfx2 = nil
    self.SprVfx3 = nil
    local _sprCfg1 = initInfo.UserData.Spr1Cfg
    local _sprCfg2 = initInfo.UserData.Spr2Cfg
    local _sprCfg3 = initInfo.UserData.Spr3Cfg
    if _sprCfg1 ~= nil then
        self.SprVfx1 = self.CSChar:PlayVFX(ModelTypeCode.OtherVFX, _sprCfg1.Vfx)
    end
    if _sprCfg2 ~= nil then
        self.SprVfx2 = self.CSChar:PlayVFX(ModelTypeCode.OtherVFX, _sprCfg2.Vfx)
    end
    if _sprCfg3 ~= nil then
        self.SprVfx3 = self.CSChar:PlayVFX(ModelTypeCode.OtherVFX, _sprCfg3.Vfx)
    end
    self.DeleteWaitFrame = 5
    self:PlayAnim("idle", 0, 2)

    if self.Cfg.MonsterType == 4 then
        local _targetPos = self.CSChar.Position
        _targetPos.x = _targetPos.x + 1
        local _height = self:GetHeight(_targetPos.x, _targetPos.z)
        _targetPos.y = _height + self.FollowHeight
        self.CSChar:SetPosition(_targetPos)
    end
end

function TaskTransNPC:OnUninitializeBefore()
end

function TaskTransNPC:Update(dt)
    
    if self.IsMasterCreated then
        local _master = GameCenter.GameSceneSystem:FindPlayer(self.MasterID)
        if _master ~= nil then
            self.CSChar:RayCastToGroundXOZ(_master.Position2d)
            self.CSChar.IsShowModel = _master.IsShowModel
            
            local _targetPos = self.CSChar.Position
            _targetPos.x = _targetPos.x + 1
            local _height = self:GetHeight(_targetPos.x, _targetPos.z)
            _targetPos.y = _height + self.FollowHeight
            self.CSChar:SetPosition(_targetPos)
            
            self.IsMasterCreated = false
        end
    end

    local _master = GameCenter.GameSceneSystem:FindPlayer(self.MasterID)
    if _master == nil then
        self.DeleteWaitFrame = self.DeleteWaitFrame - 1
        if self.DeleteWaitFrame <= 0 then
            -- Delete yourself
            self.IsDeleted = true
        end
    else
        local _isShowModel = _master.IsShowModel
        local _fightState = _master.FightState
        self.CSChar.IsShowModel = _isShowModel
        if _isShowModel then
            local _dir = L_RotQua * _master:GetFacingDirection().normalized
            local _targetPos = _master.Position + _dir.normalized * 1
            local _sqrDis = self.CSChar:GetSqrDistance2d(L_Vector2(_targetPos.x, _targetPos.z))

            if _fightState == true then
                _sqrDis = 0
            end
            
            if _sqrDis >= 100 then
                local time = Time.GetTime();
                -- Debug.LogTable({ time = time, masterId = self.MasterID, sqrDis = _sqrDis, },"Check _sqrDis>=100")
                -- Show prompt every 5 seconds
                if time - self.TimeShowPrompt > 5 then
                    self.TimeShowPrompt = time
                    if _master:IsLocalPlayer() then
                        Utils.ShowPromptByEnum("C_NPC_FOLLOW_TOO_FAR", self.Cfg.Name)
                    end
                end
                -- if _master:IsLocalPlayer() then
                --     Utils.ShowPromptByEnum("C_FABAO_FOLLOW_TOO_FAR", self.Cfg.Name)
                -- end
                if self.IsMoving then
                    self:PlayAnim(AnimClipNameDefine.NormalIdle, 0, 2)
                    self.IsMoving = false
                end
            elseif _sqrDis >= 4 then
                _dir = (_targetPos - self.CSChar.Position).normalized
                self.MoveSpeedScale = 0.8

                if _sqrDis > 9 then
                    self.MoveSpeedScale = 1
                end

                _targetPos = self.CSChar.Position + _dir * dt * _master.MoveSpeed * self.MoveSpeedScale
                local _height = self:GetHeight(_targetPos.x, _targetPos.z)
                _targetPos.y = _height + self.FollowHeight
                self.CSChar:SetPosition(_targetPos)
                if self.Cfg.SyncDir ~= 0 then
                    self.CSChar:SetDirection(_dir)
                    if not self.IsMoving then
                        self:PlayAnim(AnimClipNameDefine.NormalWalk, 0, 2)
                        self.IsMoving = true
                    end
                end
            elseif _sqrDis < 4 then
                if self.IsMoving then
                    self:PlayAnim(AnimClipNameDefine.NormalIdle, 0, 2)
                    self.IsMoving = false
                end
            end

            self.Spr1Angle = self.Spr1Angle + 360 * dt
            if self.Spr1Angle >= 360 then
                self.Spr1Angle = 0
            end
            self.Spr2Angle = self.Spr2Angle + 360 * dt
            if self.Spr2Angle >= 360 then
                self.Spr2Angle = 0
            end
            self.Spr3Angle = self.Spr3Angle + 360 * dt
            if self.Spr3Angle >= 360 then
                self.Spr3Angle = 0
            end
            if self.SprVfx1 ~= nil then
                local _pos = L_Quaternion.AngleAxis(self.Spr1Angle, L_SprVfx1Center) * (L_Vector3.forward * L_VfxDis)
                self.SprVfx1:SetLocalPosition(_pos)
            end
            if self.SprVfx2 ~= nil then
                local _pos = L_Quaternion.AngleAxis(self.Spr2Angle, L_SprVfx2Center) * (L_Vector3.forward * L_VfxDis)
                self.SprVfx2:SetLocalPosition(_pos)
            end
            if self.SprVfx3 ~= nil then
                local _pos = L_Quaternion.AngleAxis(self.Spr3Angle, L_SprVfx3Center) * (L_Vector3.forward * L_VfxDis)
                self.SprVfx3:SetLocalPosition(_pos)
            end
        end
    end
end

return TaskTransNPC
