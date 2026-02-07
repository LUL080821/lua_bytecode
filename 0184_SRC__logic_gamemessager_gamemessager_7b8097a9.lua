------------------------------------------------
-- Author: 
-- Date: 2021-04-10
-- GameMessager.lua
-- GameMessager
-- Description: Game message definition
------------------------------------------------
local GameMessager = {}
local L_MessageDef = CS.Thousandto.Core.RootSystem.MessageDef
local L_MessageId = CS.Thousandto.Core.RootSystem.MessageId
local L_NetHandler = CS.Thousandto.Code.Logic.NetHandler

function GameMessager.Init()
    L_MessageDef.LuaAddDef(L_MessageId.UnDefine, "UnDefine", "")
    L_MessageDef.LuaAddDef(L_MessageId.LaunchScript, "LaunchScript", "s,...")
    L_MessageDef.LuaAddDef(L_MessageId.DeleteObject, "DeleteObject", "i")
    L_MessageDef.LuaAddDef(L_MessageId.RefleshObject, "RefleshObject", "")
    L_MessageDef.LuaAddDef(L_MessageId.EnterScene, "EnterScene", "")
    L_MessageDef.LuaAddDef(L_MessageId.ExitScene, "ExitScene", "")
    L_MessageDef.LuaAddDef(L_MessageId.Teleport, "Teleport", "i,f,f,s")
    L_MessageDef.LuaAddDef(L_MessageId.PickNPC, "PickNPC",  "i")
    L_MessageDef.LuaAddDef(L_MessageId.PickPlayer, "PickPlayer", "i")
    L_MessageDef.LuaAddDef(L_MessageId.MissionStatusChanged, "MissionStatusChanged", "")
    L_MessageDef.LuaAddDef(L_MessageId.PlayAnimation, "PlayAnimation", "s,s")
    L_MessageDef.LuaAddDef(L_MessageId.RequestRevive, "RequestRevive", "s")
    L_MessageDef.LuaAddDef(L_MessageId.ShowObject, "ShowObject", "s")
    L_MessageDef.LuaAddDef(L_MessageId.HideObject, "HideObject", "s")
    L_MessageDef.LuaAddDef(L_MessageId.SwitchLine, "SwitchLine", "i")
    L_MessageDef.LuaAddDef(L_MessageId.FlyTeleport, "FlyTeleport", "i")
    L_MessageDef.LuaAddDef(L_MessageId.ChangeCamera, "ChangeCamera", "s,...")
end

function GameMessager.OnGameMessage(msg)
    -- Debug.Log(msg,"GameMessager.OnGameMessage:" .. tostring(msg.MsgId))
    local _msgId = msg.MsgId
    if _msgId == L_MessageId.DeleteObject then
        local _code = msg:ReadUInt64()
        GameCenter.GameSceneSystem:RemoveRemoteEntity(_code)
        return true
    elseif _msgId == L_MessageId.Teleport then
        if GameCenter.MapLogicSwitch.CustomTriggerTeleport then
            GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_CUSTOM_TRIGGER_TELEPORT, msg.FromId)
        else
            local _targetMapId = msg:ReadInt32()
            local _targetPosX = msg:ReadSingle()
            local _targetPosY = msg:ReadSingle()
            local _targetCfg = DataConfig.DataMapsetting[_targetMapId]
            local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
            if _targetCfg ~= nil and _lp ~= nil then
                if _lp.StrikeBackTable.Count > 0 then
                    Utils.ShowPromptByEnum("C_TELEPORTERROR_FIGHTING")
                end
                if _lp:CanTeleport() then
                    _lp:Stop_Action()
                    if (_targetCfg.LevelMax < 0 or _targetCfg.LevelMax >= _lp.PropMoudle.Level) and _targetCfg.LevelMin <= _lp.PropMoudle.Level then
                        local _doTeleport = true
                        if _targetCfg.MapId ~= GameCenter.MapLogicSystem.MapId then
                            if _targetCfg.Type == MapTypeDefine.PlaneCopy then
                                -- GameCenter.Network.Send("MSG_zone.ReqEnterZone", {modelId = _targetMapId})
                                L_NetHandler.SendMessage_EnterCopyMap(_targetMapId)
                                return
                            else
                                GameCenter.PushFixEvent(Plugins.Common.UIEventDefine.UI_WAITING_OPEN)
                            end
                        else
                            -- Determine whether animations need to be played
                            local _timelineParams = msg:ReadString()
                            if _timelineParams ~= nil and string.len(_timelineParams) > 0 then
                                local _timelineIds = Utils.SplitNumber(_timelineParams, '_')
                                if _timelineIds ~= nil and #_timelineIds > (_lp.IntOcc * 3) then
                                    _doTeleport = false
                                    local _startIndex = _lp.IntOcc * 3 + 1
                                    local _timelineId = _timelineIds[_startIndex]
                                    local _startX = _timelineIds[_startIndex + 1]
                                    local _startY = _timelineIds[_startIndex + 2]
                                    GameCenter.BlockingUpPromptSystem:AddTimelineTeleport(msg.FromId, _timelineId, _startX, _startY)
                                end
                            end
                        end
                        if _doTeleport then
                            GameCenter.Network.Send("MSG_Map.ReqTransport", {transportId = msg.FromId})
                        end
                    else
                        if _targetCfg.LevelMin > _lp.PropMoudle.Level then
                            -- Too low level
                            Utils.ShowPromptByEnum("C_ENTER_MAPFAILED_MINLEVEL")
                        elseif _targetCfg.LevelMax < _lp.PropMoudle.Level then
                            -- Too high level
                            Utils.ShowPromptByEnum("C_ENTER_MAPFAILED_MAXLEVEL")
                        end
                    end
                end
            end
        end
        return true
    elseif _msgId == L_MessageId.SwitchLine then
        local _activeScene = GameCenter.GameSceneSystem.ActivedScene
        if _activeScene ~= nil then
            _activeScene.Entities:RemoveAllRemoteObjects()
        end
        GameCenter.Network.Send("MSG_Register.ReqLoadFinish", {type = 0, width = 960, height = 640})
        return true
    elseif _msgId == L_MessageId.FlyTeleport then
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if _lp ~= nil and _lp:CanTeleport() then
            GameCenter.Network.Send("MSG_Map.ReqTransport", {transportId = msg.FromId})
        end
        return true
    end
    return false
end

return GameMessager