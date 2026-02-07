------------------------------------------------
-- Author:
-- Date: 2021-03-09
-- File: CharacterBase.lua
-- Module: CharacterBase
-- Description: lua role base class
------------------------------------------------
local L_Vector3 = CS.UnityEngine.Vector3
local L_Vector2 = CS.UnityEngine.Vector2

local CharacterBase = {
    CSChar = nil,
    CharType = 0,
    IsDeleted = false,
}

function CharacterBase:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

function CharacterBase:BindCSCharacter(character, charType)
    self.CSChar = character
    self.CharType = charType
    if self.OnSetupFSMBefore then
        character.SetupFSMBeforeHandle = Utils.Handler(self.OnSetupFSMBefore, self)
    end
    if self.OnSetupFSM then
        character.SetupFSMHandle = Utils.Handler(self.OnSetupFSM, self)
    end
    if self.OnInitializeAfter then
        character.InitializeAfterHandle = Utils.Handler(self.OnInitializeAfter, self)
    end
    if self.OnSyncInfo then
        character.SyncInfoHandle = Utils.Handler(self.OnSyncInfo, self)
    end
    self._OnUninitializeBefore_ = function(obj)
        if obj.OnUninitializeBefore then
            obj:OnUninitializeBefore()
        end
        obj.IsDeleted = true
    end
    character.UninitializeBeforeHandle = Utils.Handler(self._OnUninitializeBefore_, self)
end

function CharacterBase:GetPos()
    return self.CSChar.Position
end

function CharacterBase:GetPos2d()
    return self.CSChar.Position2d
end

function CharacterBase:GetHeight(x, z)
    local _, _h = self.CSChar:GetHeightOnTerrain(x, z)
    return _h
end

function CharacterBase:SetPos(x, y, z)
    if z == nil then
        self.CSChar:RayCastToGroundXOZ(L_Vector2(x, y))
    else
        self.CSChar:SetPosition(L_Vector3(x, y, z))
    end
end

function CharacterBase:SetEquip(partType, modelId)
    self.CSChar.Skin:SetSkinPartFromCfgID(partType, modelId)
end

function CharacterBase:PlayAnim(anim, partType, wrapMode, isCrossFade, crossFadeTime, speed, normalizedTime)
    if anim == nil then
        return
    end
    if partType == nil then
        partType = 0
    end
    if wrapMode == nil then
        wrapMode = 0
    end
    if isCrossFade == nil then
        isCrossFade = true
    end
    if crossFadeTime == nil then
        crossFadeTime = 0.2
    end
    if speed == nil then
        speed = 1
    end
    if normalizedTime == nil then
        normalizedTime = 0
    end
    self.CSChar:PlayAnim(anim, partType, wrapMode, isCrossFade, crossFadeTime, speed, normalizedTime)
end

return CharacterBase