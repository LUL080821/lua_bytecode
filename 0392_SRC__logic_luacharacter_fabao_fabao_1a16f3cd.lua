------------------------------------------------
-- Author:
-- Date: 2021-03-10
-- File: FaBao.lua
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

local FaBao = {
    MasterID = 0,
    Cfg = nil,
    IsLocal = false,
    DeleteWaitFrame = 0,

    SprVfx1 = nil,
    SprVfx2 = nil,
    SprVfx3 = nil,
    Spr1Angle = 0,
    Spr2Angle = 120,
    Spr3Angle = 240,
    FollowHeight = 0,
    MoveSpeedScale = 1,
    IsMoving = false,
}

function FaBao:New(csChar, initInfo)
    local _m = Utils.DeepCopy(self)
    setmetatable(_m, {__index = L_CharBase:New()})
    _m:BindCSCharacter(csChar, initInfo.UserData.CharType)
    return _m
end

function FaBao:OnSetupFSMBefore()
end

function FaBao:OnSetupFSM()
end

function FaBao:OnInitializeAfter(initInfo)
    self:OnSyncInfo(initInfo)
end

function FaBao:OnSyncInfo(initInfo)
    self.IsMoving = false
    self.MasterID = initInfo.UserData.MasterId
    self.Cfg = initInfo.UserData.Cfg
    self.IsLocal = initInfo.UserData.IsLocal
    self.FollowHeight = initInfo.UserData.FollowHeight

    self:SetEquip(FSkinPartCode.Body, self.Cfg.Id)
    local _master = GameCenter.GameSceneSystem:FindPlayer(self.MasterID)
    if _master ~= nil then
        self.CSChar:RayCastToGroundXOZ(_master.Position2d)
        self.CSChar.IsShowModel = _master.IsShowModel
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

    if self.Cfg.Type == 3 then
        local _targetPos = self.CSChar.Position
        _targetPos.x = _targetPos.x + 1
        local _height = self:GetHeight(_targetPos.x, _targetPos.z)
        _targetPos.y = _height + self.FollowHeight
        self.CSChar:SetPosition(_targetPos)
    end
end

function FaBao:OnUninitializeBefore()
end

function FaBao:Update(dt)
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
            -- Direct teleportation greater than 10 meters
            local _dir = L_RotQua * _master:GetFacingDirection().normalized
            local _targetPos = _master.Position + _dir.normalized * 1
            local _sqrDis = self.CSChar:GetSqrDistance2d(L_Vector2(_targetPos.x, _targetPos.z))

            -- Type 3: Task Hộ tống
            if self.Cfg.Type == 3 then

                if _fightState == true then
                    _sqrDis = 0
                end
                
                if _sqrDis >= 100 then
                    -- Debug.LogWarning("FaBao teleport too far, master id:" .. tostring(self.MasterID))
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

            else
                
                if _sqrDis >= 100 then
                    self.MoveSpeedScale = 1
                    local _height = self:GetHeight(_targetPos.x, _targetPos.z)
                    _targetPos.y = _height + self.FollowHeight
                    self.CSChar:SetPosition(_targetPos)
                elseif _sqrDis >= 0.2 then
                    _dir = (_targetPos - self.CSChar.Position).normalized
                    if _sqrDis > 9 then
                        -- accelerate
                        self.MoveSpeedScale = 1.5
                    end
                    if _sqrDis < 1 then
                        self.MoveSpeedScale = 1
                    end
                    _targetPos = self.CSChar.Position + _dir * dt * _master.MoveSpeed * self.MoveSpeedScale
                    local _height = self:GetHeight(_targetPos.x, _targetPos.z)
                    _targetPos.y = _height + self.FollowHeight
                    self.CSChar:SetPosition(_targetPos)
                    if self.Cfg.SyncDir ~= 0 then
                        self.CSChar:SetDirection(_dir)
                    end
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

return FaBao
