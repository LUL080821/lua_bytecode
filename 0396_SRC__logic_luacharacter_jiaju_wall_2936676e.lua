------------------------------------------------
-- Author:
-- Date: 2021-06-24
-- File: Wall.lua
-- Module: Wall
-- Description: Wall and floor roles
------------------------------------------------
local L_CharBase = require "Logic.LuaCharacter.Base.CharacterBase"

local Wall = {
    MasterID = 0,
    Cfg = nil,
    DeleteWaitFrame = 0,
    IsMoving = nil,
}

function Wall:New(csChar, initInfo)
    local _m = Utils.DeepCopy(self)
    setmetatable(_m, {__index = L_CharBase:New()})
    _m:BindCSCharacter(csChar, initInfo.UserData.CharType)
    return _m
end

function Wall:OnSetupFSMBefore()
end

function Wall:OnSetupFSM()
end

function Wall:OnInitializeAfter(initInfo)
    self:OnSyncInfo(initInfo)
end

function Wall:OnSyncInfo(initInfo)
    self.MasterID = initInfo.UserData.MasterId
    self.Cfg = initInfo.UserData.Cfg
    self.HouseLv = initInfo.UserData.HouseLv
    self.DeleteWaitFrame = 5
    local _ar = Utils.SplitNumber(self.Cfg.Res, '_')
    self:SetEquip(FSkinPartCode.Body, _ar[initInfo.UserData.HouseLv])
    self.CSChar.Skin:SetLayer(LayerUtils.GetTerrainLayer())
    self.IsMoving = nil
    self.AllFollowHeight = 0
end

function Wall:OnUninitializeBefore()
end

function Wall:Update(dt)
end

function Wall:PositionAligan()
end

return Wall
