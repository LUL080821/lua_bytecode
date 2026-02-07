------------------------------------------------
-- Author:
-- Date: 2021-04-09
-- File: BlockingUpPromptFlyTeleport.lua
-- Module: BlockingUpPromptFlyTeleport
-- Description: Flight Transmission
------------------------------------------------

local L_BlockingUpPromptBase = require "Logic.BlockingUpPrompt.BlockingUpPromptBase"
local L_EntityStateID = CS.Thousandto.Core.Asset.EntityStateID

local BlockingUpPromptFlyTeleport = {
    DataId = 0,
}

function BlockingUpPromptFlyTeleport:New(dataId, endCallBack)
    local _n = Utils.DeepCopy(self)
    local _m = setmetatable(_n, {
        __index = L_BlockingUpPromptBase:New(BlockingUpPromptType.FlyTeleport, endCallBack)
    })
    _m.DataId = dataId
    _m.PromptState = BlockingUpPromptState.Initialize
    return _m
end

function BlockingUpPromptFlyTeleport:Start()
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    local _succ = false
    if _lp ~= nil then
        _succ = _lp:Action_FlyTeleport(self.DataId)
    end

    if _succ then
        self.PromptState = BlockingUpPromptState.Running
    else
        self.PromptState = BlockingUpPromptState.Finish
    end
end

function BlockingUpPromptFlyTeleport:Update(dt)
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp ~= nil then
        if not _lp:IsXState(L_EntityStateID.FlyTeleport) then
            self.PromptState = BlockingUpPromptState.Finish
        end
    else
        self.PromptState = BlockingUpPromptState.Finish
    end
end

function BlockingUpPromptFlyTeleport:End()
    self:DoBaseEnd()
end

return BlockingUpPromptFlyTeleport