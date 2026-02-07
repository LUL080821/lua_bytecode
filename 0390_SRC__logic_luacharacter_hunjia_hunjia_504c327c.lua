------------------------------------------------
-- Author:
-- Date: 2021-03-09
-- File: HunJia.lua
-- Module: HunJia
-- Description: Soul Armor Character
------------------------------------------------
local L_CharBase = require "Logic.LuaCharacter.Base.CharacterBase"

local HunJia = {
    MasterID = 0,
    Cfg = nil,
    IsLocal = false,
    DeleteWaitFrame = 0,
    IsMoving = nil,
    AllFollowHeight = 0,
    FollowHeightList = List:New(),
}

function HunJia:New(csChar, initInfo)
    local _m = Utils.DeepCopy(self)
    setmetatable(_m, {__index = L_CharBase:New()})
    _m:BindCSCharacter(csChar, initInfo.UserData.CharType)
    return _m
end

function HunJia:OnSetupFSMBefore()
end

function HunJia:OnSetupFSM()
end

function HunJia:OnInitializeAfter(initInfo)
    self:OnSyncInfo(initInfo)
end

function HunJia:OnSyncInfo(initInfo)
    self.MasterID = initInfo.UserData.MasterId
    self.Cfg = initInfo.UserData.Cfg
    self.IsLocal = initInfo.UserData.IsLocal
    self.DeleteWaitFrame = 5
    self:SetEquip(FSkinPartCode.Body, self.Cfg.Model)
    self.IsMoving = nil
    self.AllFollowHeight = 0
    self.FollowHeightList:Clear()
end

function HunJia:OnUninitializeBefore()
end

function HunJia:Update(dt)
    local _master = GameCenter.GameSceneSystem:FindPlayer(self.MasterID)
    if _master == nil then
        self.DeleteWaitFrame = self.DeleteWaitFrame - 1
        if self.DeleteWaitFrame <= 0 then
            -- Delete yourself
            self.IsDeleted = true
        end
    else
        local _isShowModel = _master.IsShowModel
        self.CSChar.IsShowModel = _isShowModel
        if _isShowModel then
            -- Follow the position
            local _masterPos = _master.Position2d
            local _masterDir = _master:GetFacingDirection2d().normalized
            local _newPos = _masterPos - (_masterDir * 0.3)
            self.CSChar:SetDirection2d(_masterDir, false, true)
            local _height = self:GetHeight(_newPos.x, _newPos.y) + 1.3
            local _rideTrans = _master:GetSlotTransform("slot_wing")
            if _rideTrans ~= nil then
                _height = _rideTrans.position.y
            end
            self.AllFollowHeight = self.AllFollowHeight + _height
            self.FollowHeightList:Add(_height)
            local _heightCount = #self.FollowHeightList
            if _heightCount > 4 then
                local _decHeight = self.FollowHeightList[1]
                self.AllFollowHeight = self.AllFollowHeight - _decHeight
                _heightCount = _heightCount - 1
                self.FollowHeightList:RemoveAt(1)
            end
            _height = self.AllFollowHeight / _heightCount

            self:SetPos(_newPos.x, _height, _newPos.y)
            local _isMoving = _master:IsMoving()
            if self.IsMoving ~= _isMoving then
                self.IsMoving = _isMoving
                if _isMoving then
                    self:PlayAnim("run", 0, 2)
                else
                    self:PlayAnim("idle", 0, 2)
                end
            end
        end
    end
end

return HunJia
