------------------------------------------------
-- Author:
-- Date: 2021-03-10
-- File: TaskTransEquipPlayer.lua
-- Module: FaBao
-- Description: Magic weapon character
------------------------------------------------
local L_CharBase = require "Logic.LuaCharacter.Base.CharacterBase"
local SlotNameDefine = CS.Thousandto.Core.Asset.SlotNameDefine
local L_Vector3 = CS.UnityEngine.Vector3
local L_Vector2 = CS.UnityEngine.Vector2
local L_Quaternion = CS.UnityEngine.Quaternion

local TaskTransEquipPlayer = {
    MasterID = 0,
    Cfg = nil,
    IsLocal = false,
    DeleteWaitFrame = 0,
    TimeShowPrompt = 0,
    IsLongDistanceMaster = false,

    FollowHeight = 0,
    IsAdded = false,
}

function TaskTransEquipPlayer:New(csChar, initInfo)
    local _m = Utils.DeepCopy(self)
    setmetatable(_m, {__index = L_CharBase:New()})
    _m:BindCSCharacter(csChar, initInfo.UserData.CharType)
    return _m
end

function TaskTransEquipPlayer:OnSetupFSMBefore()
end

function TaskTransEquipPlayer:OnSetupFSM()
end

function TaskTransEquipPlayer:OnInitializeAfter(initInfo)
    self:OnSyncInfo(initInfo)
end

function TaskTransEquipPlayer:OnSyncInfo(initInfo)
    self.IsMasterCreated = false
    self.MasterID = initInfo.UserData.MasterId
    self.Cfg = initInfo.UserData.Cfg
    self.IsLocal = initInfo.UserData.IsLocal
    self.FollowHeight = initInfo.UserData.FollowHeight
    self.SlotNum = initInfo.UserData.SlotNum

    -- Temp: get from task behavior, remove later
    -- if self.IsLocal then
    --     local _task = GameCenter.LuaTaskManager:GetMainTask()
    --     local _behavior = GameCenter.LuaTaskManager:GetBehavior(_task.Data.Id)
    --     if _behavior ~= nil then 
    --         self.SlotNum = _behavior.ActionSlotNum    
    --     end
    -- end
    -- Temp

    if self.SlotNum == 1 then
        -- self.SlotName = SlotNameDefine.Wing
        self.SlotName = SlotNameDefine.SlotD
    else
        self.SlotName = SlotNameDefine.RightShoulder
    end

    self:SetEquip(FSkinPartCode.Body, self.Cfg.Id)
    local _master = GameCenter.GameSceneSystem:FindPlayer(self.MasterID)
    if _master ~= nil then
        self.CSChar:RayCastToGroundXOZ(_master.Position2d)
        self.CSChar.IsShowModel = _master.IsShowModel
    end
    self.DeleteWaitFrame = 5
    -- self:PlayAnim("idle", 0, 2)
    -- local _targetPos = self.CSChar.Position
    -- _targetPos.x = _targetPos.x + 1
    -- local _height = self:GetHeight(_targetPos.x, _targetPos.z)
    -- _targetPos.y = _height + self.FollowHeight
    -- self.CSChar:SetPosition(_targetPos)
end

function TaskTransEquipPlayer:OnUninitializeBefore()
end

function TaskTransEquipPlayer:Update(dt)
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
            local slot = _master.Skin:FindTransform(self.SlotName)
            if slot ~= nil then
                self.CSChar.ModelTransform.parent = slot
                self.CSChar.ModelTransform.localPosition = L_Vector3.zero
                self.CSChar.ModelTransform.localRotation = L_Quaternion.identity
            end
        end
    end
end

return TaskTransEquipPlayer
