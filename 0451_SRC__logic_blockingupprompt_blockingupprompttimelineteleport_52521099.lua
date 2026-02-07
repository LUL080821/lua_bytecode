------------------------------------------------
-- Author:
-- Date: 2021-04-10
-- File: BlockingUpPromptTimelineTeleport.lua
-- Module: BlockingUpPromptTimelineTeleport
-- Description: Animation delivery
------------------------------------------------

local L_BlockingUpPromptBase = require "Logic.BlockingUpPrompt.BlockingUpPromptBase"
local L_PostEffectManager = CS.Thousandto.Core.PostEffect.PostEffectManager
local L_TimelinePlayer = CS.Thousandto.Core.Asset.TimelinePlayer
local L_TimelinePlayState = CS.Thousandto.Core.Asset.TimelinePlayState
local L_Vector3 = CS.UnityEngine.Vector3
local L_State = {
    MoveTo = 1, -- Player moves
    PlayAnim = 2, -- Play animation
    Finish = 3, -- Finish
}

local BlockingUpPromptTimelineTeleport = {
    -- Transmission point id
    TransId = 0,
    -- Animation id
    TimelineId = 0,
    -- Player start position
    StartPos = nil,
    -- Current status
    CurState = L_State.Finish,
    -- Shadow Status
    ShadowIsEnable = false,
    -- Release hidden camera
    IsHideCamera = false,
    -- Is it loading?
    IsLoadingTimeline = false,
    -- Timer
    Timer = -1,
}

function BlockingUpPromptTimelineTeleport:New(transId, timelineId, startX, startY, endCallBack)
    local _n = Utils.DeepCopy(self)
    local _m = setmetatable(_n, {
        __index = L_BlockingUpPromptBase:New(BlockingUpPromptType.TimelineTeleport, endCallBack)
    })
    _m.TransId = transId
    _m.TimelineId = timelineId
    _m.StartPos = L_Vector3(startX, 0, startY)
    _m.ShadowIsEnable = false
    _m.IsHideCamera = false
    _m.IsLoadingTimeline = false
    _m.PromptState = BlockingUpPromptState.Initialize
    return _m
end

function BlockingUpPromptTimelineTeleport:Start()
    GameCenter.InputSystem.JoystickHandler:DoJoystickDragEnd()
    GameCenter.InputSystem.JoystickHandler.EnableHoldDrag = false
    
    self.ShadowIsEnable = L_PostEffectManager.Instance.IsEnableShadow
    self.IsHideCamera = false
    self.Timer = -1
    self:ChangeState(L_State.MoveTo)
end

function BlockingUpPromptTimelineTeleport:ChangeState(state)
    self.CurState = state
    if state == L_State.MoveTo then
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if _lp ~= nil then
            _lp:Action_MoveTo(self.StartPos)
        else
            self:ChangeState(L_State.Finish)
        end
    elseif state == L_State.PlayAnim then
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if _lp ~= nil then
            -- Force the player to the target position
            _lp:RayCastToGround(self.StartPos)
        end
        -- Loading resources
        self.IsLoadingTimeline = true
        L_TimelinePlayer.Play(self.TimelineId, function(info)
            self.IsLoadingTimeline = false
            if info == nil then
                self:ChangeState(L_State.Finish)
                return
            end
            if info.TimelinePlayState == L_TimelinePlayState.None then
                local _actorNames = info.ActorNames
                if _actorNames ~= nil then
                    local _instGo = nil
                    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
                    if _lp ~= nil and _lp.Skin ~= nil then
                        local _part = _lp.Skin:GetSkinPart(FSkinPartCode.Body)
                        if _part ~= nil then
                            _instGo = _part.RealGameObject
                        end
                    end
                    if _instGo ~= nil then
                        local _length = _actorNames.Length
                        -- If there is a protagonist
                        for i = 1, _length do
                            if _actorNames[i - 1] == "LocalPlayer" then
                                local _tempLp = GameObject.Instantiate(_instGo)
                                UnityUtils.SetLayer(_tempLp.transform, LayerUtils.RemotePlayer, true)
                                info:SetActor("LocalPlayer", _tempLp)
                                local _floowTrans = _tempLp.transform:Find("p_m_0")
                                if _floowTrans ~= nil then
                                    _floowTrans = _tempLp.transform:Find("p_m_1")
                                end
                                if _floowTrans ~= nil then
                                    PostEffectManager.Instance:SetShadowTargetTransform(_floowTrans)
                                end
                            end
                        end
                    end
                end
                -- Save shadow status
                self.ShadowIsEnable = L_PostEffectManager.Instance.IsEnableShadow
                -- Hide shadows
                --L_PostEffectManager.Instance:EnableShadow(false)
                -- Hide the main camera
                GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_ADD_MAINCAMERA_HIDECOUNTER)
                self.IsHideCamera = true
                self.Timer = info.Duration
                self.PromptState = BlockingUpPromptState.Running
                -- Send a delivery message
                GameCenter.Network.Send("MSG_Map.ReqTransport", {transportId = self.TransId})
            else
                self:ChangeState(L_State.Finish)
            end
        end)
    elseif state == L_State.Finish then
        self.PromptState = BlockingUpPromptState.Finish
    end
end

function BlockingUpPromptTimelineTeleport:Update(dt)
    if self.CurState == L_State.MoveTo then
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if _lp ~= nil then
            if not _lp:IsMoving() then
                self:ChangeState(L_State.PlayAnim)
            end
        else
            self:ChangeState(L_State.Finish)
        end
    elseif self.CurState == L_State.PlayAnim then
        if not self.IsLoadingTimeline then
            self.Timer = self.Timer - dt
            if self.Timer <= 0 then
                -- Playback is complete
                self:ChangeState(L_State.Finish)
            end
        end
    elseif self.CurState == L_State.Finish then
    end
end

function BlockingUpPromptTimelineTeleport:End()
    GameCenter.InputSystem.JoystickHandler.EnableHoldDrag = true
    self:DoBaseEnd()
    if self.IsHideCamera then
        -- Recover the camera
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_DEC_MAINCAMERA_HIDECOUNTER)
        -- Stop animation
        L_TimelinePlayer.Stop()
        -- Recover the shadow
        --L_PostEffectManager.Instance:EnableShadow(self.ShadowIsEnable)
        local _scene = GameCenter.GameSceneSystem.ActivedScene
        if _scene ~= nil then
            local _cameraCon = _scene.SceneCameraControl
            if _cameraCon ~= nil then
                -- Update the camera position once
                _cameraCon:Update()
            end
        end
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if _lp ~= nil then
            PostEffectManager.Instance:SetShadowTargetTransform(_lp.ModelTransform)
        end
    end
end

return BlockingUpPromptTimelineTeleport