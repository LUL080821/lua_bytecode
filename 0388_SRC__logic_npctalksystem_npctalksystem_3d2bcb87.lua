------------------------------------------------
-- Author:
-- Date: 2021-03-05
-- File: NpcTalkSystem.lua
-- Module: NpcTalkSystem
-- Description: NPC dialogue system
------------------------------------------------

local L_DefaultClipName = "idle"

local NpcTalkSystem = {
   -- Current task dialogue ID (default dialogue _talkId = -1)
   TalkId = -1, -- TalkTalk ID
   -- Conversation with NPC
   ModelId = -1,
   PreModelId = -1,
   -- Is it possible to submit a task
   CanSubmit = false,
   -- Is it possible to receive tasks
   CanAccess = false,
   Npc = nil,
   NpcCfgID = 0,
   Task = nil,
   ClipName = "",
   NextClipName = "",
   -- Current playback status
   CurPlayState = NpcTalkAnimPlayState.Default,
   -- Current npc talk dialogue ID
   NpcTalkId = -1, -- NpcTalk ID

   AutoTalkNpcId = -1,
}

-- Is there any subsequent conversation
function NpcTalkSystem:IsEnd()
    if self:IsUseNpcTalk() then
        return self:IsEndDialogue(self.NpcTalkId)
    end
    
    if self.TalkId == -1 then
        return true
    end
    return GameCenter.LuaTaskManager:IsEndDialogue(self.TalkId)
end

-- Open NPC conversation
function NpcTalkSystem:OpenNpcTalk(npc, taskID, isTaskOpenUI, openUIParam)
    if taskID == nil then
        taskID = 0
    end
    if isTaskOpenUI == nil then
        isTaskOpenUI = false
    end
    if npc == nil then
        return
    end
    local _npcCfgId = npc.PropMoudle.CfgID
    local _npcCfg = DataConfig.DataNpc[_npcCfgId]
    if _npcCfg == nil then
        return
    end
    self.Npc = npc
    self.NpcCfgID = _npcCfgId
    self.ClipName = L_DefaultClipName
    self.NextClipName = L_DefaultClipName
    self.ModelId = -1
    if isTaskOpenUI then
        if _npcCfg.BindFunctionID > 0 then
            -- Check the boot
            if not GameCenter.GuideSystem:Check(GuideTriggerType.ChickOpenUITask, taskID) then
                -- If the current NPC has a function bound, open a function
                if openUIParam ~= nil then
                    GameCenter.MainFunctionSystem:DoFunctionCallBack(_npcCfg.BindFunctionID, openUIParam)
                else
                    GameCenter.MainFunctionSystem:DoFunctionCallBack(_npcCfg.BindFunctionID, _npcCfg.BindFunctionParams)
                end
            end
        end
    else
        if _npcCfg.IsReqNPC == 1 then
            GameCenter.Netword.Send("MSG_Npc.ReqClickNpc", {id = npc.ID})
            return
        end
        local _talkText = nil
        self.TalkId = -1
        self.NpcTalkId = -1
        self.CanSubmit = false
        self.CanAccess = false
        GameCenter.LuaTaskManager.CurSelectTaskID = taskID
        self.Task = GameCenter.LuaTaskManager:GetNpcTask(_npcCfgId)
        if self.Task == nil then
            if _npcCfg.NpcTalk > 0 then
                local _npcTalkCfg = DataConfig.DataNpcTalk[_npcCfg.NpcTalk]
                if _npcTalkCfg ~= nil then
                    self.NpcTalkId = _npcCfg.NpcTalk
                    self.ModelId = _npcTalkCfg.Model
                    self.CanSubmit = true
                    _talkText = _npcTalkCfg.Content
                    if _npcTalkCfg.ShowName == 1 then
                        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
                        if _lp ~= nil then
                            _talkText = UIUtils.CSFormat(_talkText, _lp.Name)
                        end
                    end
                end
                if _npcTalkCfg ~= nil then
                    GameCenter.PushFixEvent(UIEventDefine.UINpcTalkForm_OPEN, _talkText)
                    self.ClipName = _npcTalkCfg.Animation
                end
            elseif _npcCfg.BindFunctionID > 0 then
                -- If the current NPC has a function bound, open a function
                GameCenter.MainFunctionSystem:DoFunctionCallBack(_npcCfg.BindFunctionID, _npcCfg.BindFunctionParams)
            elseif _npcCfg.FuncType > 0 then
                -- If the function type of NPC is greater than 0, a form will be opened
                GameCenter.PushFixEvent(UIEventDefine.UINpcFunctionForm_OPEN, _npcCfgId)
            else
                -- The task is not received (or the task is not reached) default conversation
                local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
                if _lp ~= nil then
                    local _occ = _lp.IntOcc
                    if _occ == _npcCfg.Professional then
                        _talkText = _npcCfg.ProfessionalDialog
                    else
                        _talkText = _npcCfg.Dialog
                    end
                end
                self.ModelId = _npcCfgId
                GameCenter.PushFixEvent(UIEventDefine.UINpcTalkForm_OPEN, _talkText)
            end
        else
            -- Own a mission
            GameCenter.LuaTaskManager.CurSelectTaskID = self.Task.Data.Id
            --Talk = _talk, TalkId = _talkId, ModelId = _modelId
            local _talkData = GameCenter.LuaTaskManager:GetTaskTalk(self.Task, self.TalkId, self.ModelId)
            if _talkData ~= nil then
                _talkText = _talkData.Talk
                self.TalkId = _talkData.TalkId
                self.ModelId = _talkData.ModelId
            end
            local _talkCfg = DataConfig.DataTaskTalk[self.TalkId]
            if _talkCfg ~= nil then
                if _talkCfg.ShowName == 1 then
                    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
                    if _lp ~= nil then
                        _talkText = UIUtils.CSFormat(_talkText, _lp.Name)
                    end
                end
            end
            if self.Task.Data.IsAccess then
                self.CanSubmit = GameCenter.LuaTaskManager:CanSubmitTaskEx(self.Task)
            else
                self.CanAccess = true
            end
            if _talkCfg ~= nil then
                GameCenter.PushFixEvent(UIEventDefine.UINpcTalkForm_OPEN, _talkText)
                self.ClipName = _talkCfg.Animation
            end
            self.NextClipName = self.ClipName
        end
    end

    -- NPC steering
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp ~= nil then
        npc:LookAtPosition(_lp.Position2d)
    end
end

-- Set up the next conversation
function NpcTalkSystem:GetNextTalk()
    self.ClipName = self.NextClipName
    local _cfg = DataConfig.DataTaskTalk[self.TalkId]
    if _cfg ~= nil then
        if _cfg.Nextid ~= 0 then
            self.TalkId = _cfg.Nextid
            _cfg = DataConfig.DataTaskTalk[self.TalkId]
            if _cfg ~= nil then
                local _talkText = _cfg.Content
                self.PreModelId = self.ModelId
                self.ModelId = _cfg.Model
                if _cfg.ShowName == 1 then
                    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
                    if _lp ~= nil then
                        _talkText = UIUtils.CSFormat(_talkText, _lp.Name)
                    end
                end
                self.NextClipName = _cfg.Animation
                return _talkText
            end
        end
    end
    return nil
end

function NpcTalkSystem:GetCurSpeechName()
    local _ret = ""
    local _cfg = DataConfig.DataTaskTalk[self.TalkId]
    if _cfg ~= nil then
        -- Debug.Log("[NpcTalkSystem] GetCurSpeechName TalkId:", self.TalkId, " Speech:", _cfg.Speech)
        return _cfg.Speech
    end

    -- Get from npc talk configuration
    if self.NpcTalkId ~= -1 then
        -- Debug.Log("[NpcTalkSystem] GetCurSpeechName NpcTalkId:", self.NpcTalkId)
        local _npcTalkCfg = DataConfig.DataNpcTalk[self.NpcTalkId]
        if _npcTalkCfg ~= nil then
            return _npcTalkCfg.Speech
        end
    end

    -- Get from npc configuration
    if self.Npc ~= nil then
        local _npcCfgId = self.Npc.PropMoudle.CfgID
        local _npcCfg = DataConfig.DataNpc[_npcCfgId]
        if _npcCfg ~= nil then
            -- Debug.Log("[NpcTalkSystem] GetCurSpeechName NpcCfgId:", _npcCfgId, " Name:", _npcCfg.Name)
            return _npcCfg.Speech
        end
    end

    return _ret
end

function NpcTalkSystem:Reset()
    self.ModelId = -1
end

-- Switch playback status
function NpcTalkSystem:ChangePlayState(state)
    self.CurPlayState = state
end

-- Can I force the next action clip be played
function NpcTalkSystem:IsCanPlayNextAnim()
    if self.ClipName ~= L_DefaultClipName then
        return false
    else
        return true
    end
end

-- Whether to play the default action clip
function NpcTalkSystem:IsPlayDefaultAnim()
    return self.NextClipName == L_DefaultClipName
end

-- Get npc talk conversation
function NpcTalkSystem:GetNpcTalk(npcTalkId)
    local _ret = nil
    local _npcTalkId = nil
    local _modelId = nil

    local _cfg = DataConfig.DataNpcTalk[npcTalkId]
    if _cfg ~= nil then
        _npcTalkId = npcTalkId
        _modelId = _cfg.Model;
    end

    _ret = {
        npcTalkId = _npcTalkId,
        ModelId = _modelId
    }
    return _ret;
end

function NpcTalkSystem:IsUseNpcTalk()
    return self.NpcTalkId ~= -1
end

function NpcTalkSystem:GetNextNpcTalk()
    local _talkText = nil
    local _npcTalkCfg = DataConfig.DataNpcTalk[self.NpcTalkId]
    if _npcTalkCfg ~= nil then
        if _npcTalkCfg.Nextid ~= 0 then
            self.NpcTalkId = _npcTalkCfg.Nextid
            if _npcTalkCfg ~= nil then
                _npcTalkCfg = DataConfig.DataNpcTalk[self.NpcTalkId]
                _talkText = _npcTalkCfg.Content
                self.PreModelId = self.ModelId
                self.ModelId = _npcTalkCfg.Model
                if _npcTalkCfg.ShowName == 1 then
                    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
                    if _lp ~= nil then
                        _talkText = UIUtils.CSFormat(_talkText, _lp.Name)
                    end
                end
                self.NextClipName = _npcTalkCfg.Animation
                return _talkText
            end
        end
    end
    return nil
end

function NpcTalkSystem:IsEndDialogue(npcTalkId)
    local _ret = false
    local _cfg = DataConfig.DataNpcTalk[npcTalkId]
    if _cfg ~= nil then
        _ret = _cfg.Nextid == 0 and true or false
    end
    return _ret
end


function NpcTalkSystem:TalkToNpc(npcId, mapId)
    local currentMapId = GameCenter.MapLogicSystem.MapCfg.MapId or 0
    if currentMapId ~= mapId then
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if _lp == nil then
            return
        end
        _lp:Action_CrossMapTran(mapId)
        self:SetAutoTalkNpc(npcId, true)
    else
        PlayerBT.Task:TaskTalkToNpc(npcId)
    end
end

function NpcTalkSystem:SetAutoTalkNpc(npcId, isAuto)
    if isAuto then
        self.AutoTalkNpcId = npcId
    else
        self.AutoTalkNpcId = -1
    end
end

function NpcTalkSystem:ResumeAutoTalkNpc()
    if GameCenter.LuaTaskManager.IsAutoTaskForTransPort == false and self.AutoTalkNpcId > 0 then
        PlayerBT.Task:TaskTalkToNpc(self.AutoTalkNpcId)
        self.AutoTalkNpcId = -1
    end
end

return NpcTalkSystem