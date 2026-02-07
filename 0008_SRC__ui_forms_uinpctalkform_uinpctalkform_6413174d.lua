------------------------------------------------
-- author:
-- Date: 2021-03-05
-- File: UINpcTalkForm.lua
-- Module: UINpcTalkForm
-- Description: NPC dialogue interface
------------------------------------------------
local L_NetHandler = CS.Thousandto.Code.Logic.NetHandler
local L_Vector3 = CS.UnityEngine.Vector3
local L_ItemBase = CS.Thousandto.Code.Logic.ItemBase
local L_AudioPlayer = CS.Thousandto.Core.Asset.AudioPlayer

local L_TalkType = {
    SubMit = 1, -- submit
    NextTalk = 2, --The next conversation
    Access = 3, -- Retrieve
    EnterMap = 4, -- Enter the copy
    CutTimeBtn = 5,
    Other = 6, -- other
    NpcTalk = 7 -- npc talk button
}

local UINpcTalkForm = {
    Close = nil,
    Talk = nil,
    SubMit = nil,
    NextTalk = nil,
    Access = nil,
    -- Dialogue model name
    NpcName = nil,
    UIItemBtn = nil,
    Grid = nil,
    FuncClick = nil,
    -- Enter copy button
    EnterCopyBtn = nil,
    -- Immortal Alliance Help Button
    XmHelpBtn = nil,
    FuncLabel = nil,
    Texture = nil,
    BgTexture = nil,
    Continue = nil,
    CloseClick = nil,
    SubMitItem = nil,
    OffTime = nil,
    Time = nil,
    RewardTitle = nil,
    FuncType = 0,
    TalkText = nil,
    -- Dialogue Model
    Skin = nil,
    ItemList = List:New(),
    StoryUICamera = nil,
    -- ui animation node
    Left = nil,
    Right = nil,
    Bottom = nil,
    NormalPos = nil,
    -- Click CD on the task submission button
    SubMitCD = 2,
    -- Whether it was clicked to submit to enter the submission status
    IsSubmitState = false,
    CutTime = 0,
    PrevCutTime = 0,
    CTime = 6,
    TalkType = L_TalkType.Other,
    TalkSystem = nil
}

function UINpcTalkForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UINpcTalkForm_OPEN, self.OnOpen, self)
    self:RegisterEvent(UIEventDefine.UINpcTalkForm_CLOSE, self.OnClose, self)
end

function UINpcTalkForm:OnFirstShow()
    local _trans = self.Trans
    self.Close = UIUtils.FindBtn(_trans, "StoryLayer/Center/Close")
    self.Talk = UIUtils.FindLabel(_trans, "StoryLayer/Bottom/Front/Talk")
    self.SubMit = UIUtils.FindBtn(_trans, "StoryLayer/Right/SubMit")
    self.NextTalk = UIUtils.FindBtn(_trans, "StoryLayer/Right/NextTalk")
    self.Access = UIUtils.FindBtn(_trans, "StoryLayer/Right/Access")
    self.Skin = UIUtils.RequireUIRoleSkinCompoent(UIUtils.FindTrans(_trans, "RoleSkin/UIRoleSkinCompoent"))
    self.Skin:OnFirstShow(self.CSForm, FSkinTypeCode.Custom, "idle", 1)
    self.Skin:SetOnSkinPartChangedHandler(Utils.Handler(self.OnSkinLoadCallBack, self))
    self.NpcName = UIUtils.FindLabel(_trans, "StoryLayer/Bottom/Front/npcname")
    self.UIItemBtn = UIUtils.FindBtn(_trans, "StoryLayer/Bottom/Grid/UIItem")
    self.Grid = UIUtils.FindGrid(_trans, "StoryLayer/Bottom/Grid")
    self.FuncClick = UIUtils.FindBtn(_trans, "StoryLayer/Bottom/FuncBtn")
    self.FuncLabel = UIUtils.FindLabel(_trans, "StoryLayer/Bottom/FuncBtn/Label")
    self.Left = UIUtils.FindTrans(_trans, "StoryLayer/Left")
    self.Right = UIUtils.FindTrans(_trans, "StoryLayer/Right")
    self.Bottom = UIUtils.FindTrans(_trans, "StoryLayer/Bottom")
    self.Continue = UIUtils.FindBtn(_trans, "StoryLayer/Top/Continue")
    self.CloseClick = UIUtils.FindBtn(_trans, "StoryLayer/Right/CloseClick")
    self.SubMitItem = UIUtils.FindBtn(_trans, "StoryLayer/Right/SubMitItem")
    self.OffTime = UIUtils.FindLabel(_trans, "StoryLayer/Bottom/OffTime")
    self.Time = UIUtils.FindLabel(_trans, "StoryLayer/Bottom/OffTime/Time")
    self.EnterCopyBtn = UIUtils.FindBtn(_trans, "StoryLayer/Bottom/EnterCopyBtn")
    self.XmHelpBtn = UIUtils.FindBtn(_trans, "StoryLayer/Bottom/HelpBtn")
    self.NpcTalkConfirmBtn = UIUtils.FindBtn(_trans, "StoryLayer/Bottom/NpcTalkConfirmBtn")
    self.NpcTalkConfirmBtn.gameObject:SetActive(false)
    self.NpcTalkConfirmBtnLabel = UIUtils.FindLabel(_trans, "StoryLayer/Bottom/NpcTalkConfirmBtn/Label")
    self.NpcTalkCancelBtn = UIUtils.FindBtn(_trans, "StoryLayer/Bottom/NpcTalkCancelBtn")
    self.NpcTalkCancelBtn.gameObject:SetActive(false)
    self.NpcTalkCancelBtnLabel = UIUtils.FindLabel(_trans, "StoryLayer/Bottom/NpcTalkCancelBtn/Label")
    self.RewardTitle = UIUtils.FindLabel(_trans, "StoryLayer/Bottom/RewardTitle")
    self.StoryUICamera = UIUtils.FindCamera(_trans, "StoryCamera")
    -- Synchronize camera data to prevent misalignment
    if self.StoryUICamera ~= nil then
        self.StoryUICamera.orthographicSize = self.CSForm.Manager.UI2DCamera.orthographicSize
        self.StoryUICamera.rect = self.CSForm.Manager.UI2DCamera.rect
    end
    self.NormalPos = UIUtils.FindTrans(_trans, "Pos")
    UIUtils.AddBtnEvent(self.Close, self.OnClickCloseBtn, self)
    UIUtils.AddBtnEvent(self.SubMit, self.OnClickSubMit, self)
    UIUtils.AddBtnEvent(self.NextTalk, self.OnClickNextTalk, self)
    UIUtils.AddBtnEvent(self.Access, self.OnClickAccess, self)
    UIUtils.AddBtnEvent(self.FuncClick, self.OnClickFuncClick, self)
    UIUtils.AddBtnEvent(self.Continue, self.OnClickContinue, self)
    UIUtils.AddBtnEvent(self.CloseClick, self.OnClickCloseClick, self)
    UIUtils.AddBtnEvent(self.SubMitItem, self.OnClickSubMitItem, self)
    UIUtils.AddBtnEvent(self.EnterCopyBtn, self.OnClickXmEnterCopy, self)
    UIUtils.AddBtnEvent(self.XmHelpBtn, self.OnClickXmHelp, self)
    UIUtils.AddBtnEvent(self.NpcTalkConfirmBtn, self.OnClickNpcTalkConfirmBtn, self)
    UIUtils.AddBtnEvent(self.NpcTalkCancelBtn, self.OnClickCloseBtn, self)
    self.ItemList:Clear()
    local _itemRes = self.UIItemBtn.gameObject
    _itemRes:SetActive(false)
    -- self.ItemList:Add(UILuaItem:New(_itemRes.transform))
    for i = 2, 5 do
        local _go = UnityUtils.Clone(_itemRes)
        _go:SetActive(false)
        self.ItemList:Add(UILuaItem:New(_go.transform))
    end
    self.CSForm:AddAlphaAnimation()
    self.CSForm:AddPositionAnimation(0, -100, self.Right)
    self.CSForm:AddPositionAnimation(0, -100, self.Bottom)
    self.CSForm.IsMustShowMainCamera = true
end

function UINpcTalkForm:OnShowBefore()
    self.TalkSystem = GameCenter.NpcTalkSystem
    GameCenter.PushFixEvent(UIEventDefine.UI_NUMBER_INPUT_FORM_CLOSE)
end

function UINpcTalkForm:OnShowAfter()
    -- Debug.Log("UINpcTalkForm:OnShowAfter")
    for i = 1, #self.ItemList do
        self.ItemList[i].RootGO:SetActive(false)
    end
    UIUtils.SetTextByString(self.Talk, self:DealWitchTalkStr(self.TalkText))
    local _speech = self.TalkSystem:GetCurSpeechName()
    if _speech ~= nil and string.len(_speech) > 0 and (not L_AudioPlayer.IsPlayingClip(AudioTypeCode.Speech, _speech)) then
        -- Stop before playing new voice so other voices
        L_AudioPlayer.Stop(AudioTypeCode.Speech)
        L_AudioPlayer.PlaySpeech(nil, _speech)
    end
    self.CTime = 6
    local _talkCfg = DataConfig.DataTaskTalk[self.TalkSystem.TalkId]
    if _talkCfg ~= nil then
        if _talkCfg.Showtime <= 0 then
            self.CTime = 6
        else
            self.CTime = _talkCfg.Showtime
        end
    end
    self.RewardTitle.gameObject:SetActive(false)
    -- Set whether to display the countdown to complete the task
    self:SetAutoOffTimeShow()
    self:SetSubmitBtnState()
    self:SetNextTalkBtnState()
    self:SetFuncClickBtnState()
    self:SetAccessBtnState()
    self:SetNpcTalkBtnState()
    self:SetCloseBtnState()
    self:SetCloseClickState()
    self:SetSubMitItemClickState()
    self:SetModel()
    self.IsSubmitState = false
    self.SubMitCD = 2
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_SUSPEND_ALL_FORM)
end

function UINpcTalkForm:OnTryHide()
    self:OnClickContinue()
    return true
end

function UINpcTalkForm:OnHideBefore()
    self.TalkSystem.Task = nil
    self.TalkSystem.PreModelId = -1
    self.Skin:ResetSkin()
    L_AudioPlayer.Stop(AudioTypeCode.Speech)
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_RESUME_ALL_FORM)
end
-- Open the interface
function UINpcTalkForm:OnOpen(talkText, sender)
    if talkText ~= nil and type(talkText) == "string" then
        self.TalkText = talkText
    end
    self.CSForm:Show(sender)
end
-- Close the interface
function UINpcTalkForm:OnClose(obj, sender)
    self.CSForm:Hide()
end

function UINpcTalkForm:OnClickCloseBtn()
    self:OnClose(nil)
end
function UINpcTalkForm:OnClickSubMitItem()
    GameCenter.PushFixEvent(UIEventDefine.UISubMitItemForm_OPEN, self.TalkSystem.Task)
    self:OnClose(nil)
end
function UINpcTalkForm:OnClickCloseClick()
    local _behavior = GameCenter.LuaTaskManager:GetBehavior(GameCenter.LuaTaskManager.CurSelectTaskID)
    if _behavior ~= nil and _behavior.Type == TaskBeHaviorType.FindCharactor then
        _behavior.TaskTarget.Count = _behavior.TaskTarget.TCount
        if self.TalkSystem.Task ~= nil then
            GameCenter.LuaTaskManager:SubMitTask()
        end
    end
    self:OnClose(nil)
end

-- jump over
function UINpcTalkForm:OnClickContinue()
    Debug.Log("UINpcTalkForm:OnClickContinue")
    -- When skip, close it directly
    L_AudioPlayer.Stop(AudioTypeCode.Speech)
    if self.TalkSystem.CanSubmit then
        if self.TalkSystem.Task ~= nil then
            GameCenter.LuaTaskManager:SubMitTask(self.TalkSystem.Task.Data.Id)
        end
    end

    if self.SubMitItem.gameObject.activeSelf then
        if self.TalkSystem.Task ~= nil then
            GameCenter.LuaTaskManagerMsg:ReqChangeTaskState(self.TalkSystem.Task.Data.Type, self.TalkSystem.Task.Data.Id)
        end
    end
    self:OnClose(nil)
end

function UINpcTalkForm:OnClickFuncClick()
    local _cfg = DataConfig.DataNpc[self.TalkSystem.ModelId]
    if _cfg ~= nil then
        if _cfg.NpcTalkBtn == 1 or _cfg.NpcTalkBtn == 3 then
            GameCenter.MainFunctionSystem:DoFunctionCallBack(self.FuncType, nil)
        end
    end
    self:OnClose(nil)
end
-- Click to enter the Immortal Alliance copy
function UINpcTalkForm:OnClickXmEnterCopy()
    local _task = GameCenter.LuaTaskManager:GetXmCopyTaskByNpc(self.TalkSystem.NpcCfgID)
    if _task ~= nil and _task.Data.Type == TaskType.Guild then
        local _behavior = GameCenter.LuaTaskManager:GetBehavior(_task.Data.Id)
        if _behavior ~= nil and _behavior.Type == TaskBeHaviorType.PassCopy then
            L_NetHandler.SendMessage_EnterCopyMap(_behavior.TaskTarget.TagId)
        end
    end
end
-- 
function UINpcTalkForm:OnClickNpcTalkConfirmBtn()
    local _npcCfg = DataConfig.DataNpc[self.TalkSystem.NpcCfgID]
    if _npcCfg ~= nil then
        GameCenter.MainFunctionSystem:DoFunctionCallBack(_npcCfg.BindFunctionID, nil)
    end
    self:OnClose(nil)
end
-- Click on the Immortal Alliance for help
function UINpcTalkForm:OnClickXmHelp()
    GameCenter.Network.Send("MSG_WorldHelp.ReqGuildTaskHelp", {})
end
-- Accept the task
function UINpcTalkForm:OnClickAccess()
    GameCenter.LuaTaskManager:AccessTask(GameCenter.LuaTaskManager.CurSelectTaskID)
end
-- Click to continue the conversation
function UINpcTalkForm:OnClickNextTalk()
    -- local _taskText = self.TalkSystem:GetNextTalk()
    -- local _talkCfg = DataConfig.DataTaskTalk[self.TalkSystem.TalkId]

    local _taskText = nil
    local _talkCfg = nil
    if (self.TalkSystem:IsUseNpcTalk()) then
        _taskText = self.TalkSystem:GetNextNpcTalk()
        _talkCfg = DataConfig.DataNpcTalk[self.TalkSystem.NpcTalkId]
    else
        _taskText = self.TalkSystem:GetNextTalk()
        _talkCfg = DataConfig.DataTaskTalk[self.TalkSystem.TalkId]
    end

    if _talkCfg ~= nil then
        if _talkCfg.Showtime == 0 then
            self.CTime = 6
        else
            self.CTime = _talkCfg.Showtime
        end
    end
    UIUtils.SetTextByString(self.Talk, self:DealWitchTalkStr(_taskText))
    local _speech = self.TalkSystem:GetCurSpeechName()
    if _speech ~= nil and string.len(_speech) > 0 and (not L_AudioPlayer.IsPlayingClip(AudioTypeCode.Speech, _speech)) then
        -- Stop before playing new voice so other voices
        L_AudioPlayer.Stop(AudioTypeCode.Speech)
        L_AudioPlayer.PlaySpeech(nil, _speech)
    end
    self:SetSubmitBtnState()
    self:SetFuncClickBtnState()
    self:SetNextTalkBtnState()
    self:SetAccessBtnState()
    self:SetNpcTalkBtnState()
    self:SetCloseBtnState()
    self:SetCloseClickState()
    self:SetSubMitItemClickState()
    self:SetModel()
end
-- Click to submit the task
function UINpcTalkForm:OnClickSubMit()
    if not self.IsSubmitState then
        if self.TalkSystem.Task ~= nil then
            if self.TalkSystem.Task.Data.Type == TaskType.Daily or self.TalkSystem.Task.Data.Type == TaskType.DailyPrison then
                local _openId = self.TalkSystem.Task:SubMitTaskOpenPanel()
                if _openId ~= 0 then
                    GameCenter.MainFunctionSystem:DoFunctionCallBack(_openId)
                end
            else
                GameCenter.LuaTaskManager:SubMitTask(self.TalkSystem.Task.Data.Id)
            end
        end
        self.IsSubmitState = true
        self:OnClose(nil)
    end
end
function UINpcTalkForm:OnSkinLoadCallBack(skin, part)
end
-- Set whether to display automatic task countdown
function UINpcTalkForm:SetAutoOffTimeShow()
    self.OffTime.gameObject:SetActive(false)
    if self.TalkSystem.Task ~= nil and self.TalkSystem.Task.Data.Type == TaskType.Main then
        local _mainTask = self.TalkSystem.Task
        local _taskCfg = DataConfig.DataTask[_mainTask.Data.Id]
        if _taskCfg ~= nil and _taskCfg.IsAuto == 0 then
            self.CutTime = self.CTime
            self.PrevCutTime = 0
            self.OffTime.gameObject:SetActive(true)
        else
            self.OffTime.gameObject:SetActive(false)
        end
    elseif self.TalkSystem.Task ~= nil and self.TalkSystem.Task.Data.Type == TaskType.Prison then
        local _prisonTask = self.TalkSystem.Task
        local _taskCfg = DataConfig.DataTaskPrison[_prisonTask.Data.Id]
        if _taskCfg ~= nil and _taskCfg.IsAuto == 0 then
            self.CutTime = self.CTime
            self.PrevCutTime = 0
            self.OffTime.gameObject:SetActive(true)
        else
            self.OffTime.gameObject:SetActive(false)
        end
    elseif self.TalkSystem.Task ~= nil then
        local _taskType = self.TalkSystem.Task.Data.Type
        if _taskType == TaskType.Daily or _taskType == TaskType.Guild or _taskType == TaskType.ZhuanZhi or _taskType == TaskType.DailyPrison then
            self.OffTime.gameObject:SetActive(true)
        end
    elseif  self.TalkSystem.Task == nil then
        local _npcCfg = DataConfig.DataNpc[self.TalkSystem.ModelId]
        if _npcCfg ~= nil then
            if _npcCfg.NpcTalkBtn == 3 then
                self.CutTime = 8
                self.PrevCutTime = 0
                self.OffTime.gameObject:SetActive(true)
            end
        end
    end
end

function UINpcTalkForm:SetSubmitBtnState()
    self.SubMit.gameObject:SetActive(false)
    if self.TalkSystem:IsEnd() and self.TalkSystem.CanSubmit then
        if self.TalkSystem.Task then
            if self.TalkSystem.Task.Data.Type == TaskType.Guild then
                local _guildTask = self.TalkSystem.Task
                local _taskId = _guildTask.GuildData.Id
                local _taskCfg = DataConfig.DataTaskConquer[_taskId]
                if _taskCfg ~= nil and _taskCfg.ConquerSubtype == 2 then
                    local _behavior = GameCenter.LuaTaskManager:GetBehavior(_taskId)
                    if _behavior.Type == TaskBeHaviorType.Talk then
                        _behavior.TaskTarget.Count = _behavior.TaskTarget.TCount
                        self.Close.gameObject:SetActive(true)
                        return
                    end
                end
            end
            self.TalkType = L_TalkType.SubMit
            self.CutTime = self.CTime
            self.PrevCutTime = 0
            self.SubMit.gameObject:SetActive(true)

        end
    end
    if self.TalkSystem.Task ~= nil then
        self:SetReward(self.TalkSystem.Task)
    end

end

function UINpcTalkForm:SetNextTalkBtnState()
    self.NextTalk.gameObject:SetActive(false)
    if not self.TalkSystem:IsEnd() and self.TalkSystem.CanSubmit then
        self.TalkType = L_TalkType.NextTalk
        self.CutTime = self.CTime
        self.PrevCutTime = 0
        self.NextTalk.gameObject:SetActive(true)
    end
end
function UINpcTalkForm:SetFuncClickBtnState()
    self.FuncClick.gameObject:SetActive(false)
    self.EnterCopyBtn.gameObject:SetActive(false)
    self.XmHelpBtn.gameObject:SetActive(false)

    if self.TalkSystem:IsEnd() and not self.TalkSystem.CanSubmit and not self.TalkSystem.CanAccess then
        self.TalkType = L_TalkType.Other
        local _npcCfg = DataConfig.DataNpc[self.TalkSystem.ModelId]
        if _npcCfg ~= nil then
            local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
            if _lp ~= nil and not self.TalkSystem.CanAccess then
                if _npcCfg.NpcTalkBtn == 1 then
                    if _npcCfg.GuildWarCamp == GameCenter.XmFightSystem.Camp then
                        UIUtils.SetTextByStringDefinesID(self.FuncLabel, _npcCfg._TalkBtnName)
                        self.FuncType = _npcCfg.BtnFunction
                        self.FuncClick.gameObject:SetActive(true)
                        self.CloseClick.gameObject:SetActive(true)
                    end
                elseif _npcCfg.NpcTalkBtn == 2 then
                    local _xmTask = GameCenter.LuaTaskManager:GetXmCopyTaskByNpc(self.TalkSystem.NpcCfgID)
                    if _xmTask ~= nil then
                        self.EnterCopyBtn.gameObject:SetActive(true)
                        --self.XmHelpBtn.gameObject:SetActive(true)
                        self.OffTime.gameObject:SetActive(false)
                    end
                elseif _npcCfg.NpcTalkBtn == 3 then
                    if _npcCfg.GuildWarCamp == GameCenter.XmFightSystem.Camp then
                        UIUtils.SetTextByStringDefinesID(self.FuncLabel, _npcCfg._TalkBtnName)
                        self.FuncType = _npcCfg.BtnFunction
                        self.FuncClick.gameObject:SetActive(true)
                        self.CloseClick.gameObject:SetActive(true)
                        self.TalkType = L_TalkType.CutTimeBtn
                        --Check the guidance of the gods
                        local _activeLogic = GameCenter.MapLogicSystem.ActiveLogic
                        if _activeLogic ~= nil then
                            local _param = _activeLogic:GetChangeGuidKey()
                            if _param == 0 then
                                GameCenter.BlockingUpPromptSystem:AddForceGuideByID(311, nil, false)
                            end
                        end
                    end
                end
            end
        end
    end
end

function UINpcTalkForm:SetCloseBtnState()
    if not self.SubMit.gameObject.activeSelf and not self.Access.gameObject.activeSelf and
        not self.NextTalk.gameObject.activeSelf and not self.FuncClick.gameObject.activeSelf then
        self.TalkType = L_TalkType.Other
        self.Close.gameObject:SetActive(true)
    else
        self.Close.gameObject:SetActive(false)
    end
end

function UINpcTalkForm:SetAccessBtnState()
    self.Access.gameObject:SetActive(false)
    if self.TalkSystem:IsEnd() and self.TalkSystem.CanAccess then
        self.TalkType = L_TalkType.Access
        self.CutTime = self.CTime
        self.PrevCutTime = 0
        self.Access.gameObject:SetActive(true)
    end
end

function UINpcTalkForm:SetNpcTalkBtnState()
    self.NpcTalkConfirmBtn.gameObject:SetActive(false)
    self.NpcTalkCancelBtn.gameObject:SetActive(false)
    
    if self.TalkSystem:IsUseNpcTalk() and not self.TalkSystem:IsEnd() then
        self.TalkType = L_TalkType.NpcTalk
    end
    
    if self.TalkSystem:IsUseNpcTalk() and self.TalkSystem:IsEnd() and self.TalkSystem.CanSubmit then
        local _cfgNpc = DataConfig.DataNpc[self.TalkSystem.NpcCfgID]
        if _cfgNpc ~= nil then
            if _cfgNpc.NpcTalkBtn == 4 and string.len(_cfgNpc.NpcTalkBtnText) > 0 then
                -- NpcTalkBtn: confirm_text;cancel_text
                local _btnNames = Utils.SplitStr(_cfgNpc.NpcTalkBtnText, ";")
                if #_btnNames >= 2 then
                    UIUtils.SetTextByString(self.NpcTalkConfirmBtnLabel, _btnNames[1])
                    UIUtils.SetTextByString(self.NpcTalkCancelBtnLabel, _btnNames[2])
                end
            end
        end
        self.NpcTalkConfirmBtn.gameObject:SetActive(true)
        self.NpcTalkCancelBtn.gameObject:SetActive(true)
    end
end

function UINpcTalkForm:SetCloseClickState()
    self.CloseClick.gameObject:SetActive(false)
    if self.TalkSystem:IsEnd() and not self.TalkSystem.CanSubmit then
        local _behaviorType = GameCenter.LuaTaskManager:GetBehaviorType(GameCenter.LuaTaskManager.CurSelectTaskID)
        if _behaviorType == TaskBeHaviorType.FindCharactor then
            self.TalkType = L_TalkType.Other
            self.CloseClick.gameObject:SetActive(true)
        end
    end
    if self.FuncClick.gameObject.activeSelf then
        self.CloseClick.gameObject:SetActive(true)
    end
end

function UINpcTalkForm:SetSubMitItemClickState()
    self.SubMitItem.gameObject:SetActive(false)
    if self.TalkSystem:IsEnd() and not self.TalkSystem.CanSubmit and
        GameCenter.LuaTaskManager:GetBehaviorType(GameCenter.LuaTaskManager.CurSelectTaskID) == TaskBeHaviorType.SubMit then
        self.TalkType = L_TalkType.Other
        self.SubMitItem.gameObject:SetActive(true)
    end
    if self.TalkSystem.Task ~= nil then
        self:SetReward(self.TalkSystem.Task)
    end
end

function UINpcTalkForm:SetModel()
    local _camerX = 1136.0
    local _camerY = 640.0
    local _offsetX = 0
    local _offsetY = 0
    self.CSForm.AnimModule:UpdateAnchor(self.NormalPos)
    local _normalX = self.NormalPos.localPosition.x
    if self.Skin ~= nil then
        self.Skin.Layer = LayerUtils.UIStory
    end
    self.Skin.EnableDrag = false
    if self.TalkSystem.ModelId == 0 then
        -- Pig's feet speak by themselves
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if _lp ~= nil then
            self.Skin.Skin.SkinTypeCode = FSkinTypeCode.Player
            self.Skin:ResetSkin()
            self.Skin:ResetRot()
            self.Skin:SetEquip(FSkinPartCode.Body, RoleVEquipTool.GetLPBodyModel())
            -- Set the conversation name
            UIUtils.SetTextByString(self.NpcName, _lp.Name)
            local _size = 1.1
            local _posY = -365
            local _posX = 0
            local _occ = _lp.IntOcc
            if _occ == 0 then
                _size = 0.9
                _posX = (-217 + 180) + _normalX
                _posY = -565
            elseif _occ == 1 or _occ == 3 then
                _size = 0.9
                _posX = (-217 + 180) + _normalX
                _posY = -565
            elseif _occ == 2 then
                _size = 0.9
                _posX = (-217 + 180) + _normalX
                _posY = -565
            end
            self.Skin:SetCameraSize(_size)
            self.Skin.NormalRot = 144
            self.Skin:ResetRot()
            _offsetX = (_camerX * (1 - _size) / 2)
            _offsetY = (_camerY * (1 - _size) / 2)
            if self.TalkSystem.PreModelId == 0 then
                UnityUtils.SetLocalPositionX(self.Skin.Widget.transform, _posX)
                UnityUtils.SetLocalPositionY(self.Skin.Widget.transform, _posY)
            else
                local _posZ = self.Skin.Widget.transform.localPosition.z
                local _startPos = L_Vector3(_posX - 180 - _offsetX, _posY, _posZ)
                local _endPos = L_Vector3(_posX, _posY, _posZ)
                self:SetModelPositionAndAlpha(_startPos, _endPos, self.Skin.Widget.transform, 0.3)
            end
        end
    else
        if self.TalkSystem.ModelId ~= -1 then
            -- npc speaking
            local _cfg = DataConfig.DataNpc[self.TalkSystem.ModelId]
            if _cfg ~= nil then
                if self.TalkSystem.PreModelId ~= self.TalkSystem.ModelId then
                    self.Skin:ResetSkin()
                    self.Skin:ResetRot()
                    self.Skin.Skin.SkinTypeCode = FSkinTypeCode.Monster
                    if _cfg.ShowCfgName == 0 then
                        if self.TalkSystem.Npc ~= nil then
                            self.Skin:SetEquip(FSkinPartCode.Body,
                                self.TalkSystem.Npc.Skin:GetSkinPartCfgID(FSkinPartCode.Body))
                            self.Skin:SetEquip(FSkinPartCode.XianjiaHuan,
                                self.TalkSystem.Npc.Skin:GetSkinPartCfgID(FSkinPartCode.XianjiaHuan))
                        end
                    else
                        self.Skin:SetEquip(FSkinPartCode.Body, _cfg.Res)
                    end
                    if self.TalkSystem.Npc ~= nil then
                        UIUtils.SetTextByStringDefinesID(self.NpcName, _cfg._Name)
                    end
                    self.Skin:SetEquip(FSkinPartCode.GodWeaponHead, 0)
                    self.Skin:SetEquip(FSkinPartCode.GodWeaponBody, 0)
                    self.Skin:SetEquip(FSkinPartCode.GodWeaponVfx, 0)
                    if self.TalkSystem.NpcCfgID == _cfg.Id then
                        self.Skin:SetEquip(FSkinPartCode.Wing,
                            self.TalkSystem.Npc.Skin:GetSkinPartCfgID(FSkinPartCode.Wing))
                    else
                        self.Skin:SetEquip(FSkinPartCode.Wing, 0)
                    end
                    self.Skin.NormalRot = _cfg.Notation
                    self.Skin:ResetRot()
                end
                -- Set the zoom and position
                local _size = _cfg.Zoom / 100
                self.Skin:SetCameraSize(_size)
                _offsetX = (_camerX * (1 - _size) / 2)
                _offsetY = (_camerY * (1 - _size) / 2)
                local _x = _cfg.PosX + _normalX
                if self.TalkSystem.PreModelId == self.TalkSystem.ModelId then
                    UnityUtils.SetLocalPositionX(self.Skin.Widget.transform, _x)
                    UnityUtils.SetLocalPositionY(self.Skin.Widget.transform, _cfg.PosY)
                else
                    local _posZ = self.Skin.Widget.transform.localPosition.z
                    local _startPos = L_Vector3(_x - 180 + _offsetX, _cfg.PosY, _posZ)
                    local _endPos = L_Vector3(_cfg.PosX + _normalX, _cfg.PosY, _posZ)
                    self:SetModelPositionAndAlpha(_startPos, _endPos, self.Skin.Widget.transform, 0.3)
                end
            end
        end
    end
    if self.TalkSystem:IsPlayDefaultAnim() then
        self.TalkSystem:ChangePlayState(NpcTalkAnimPlayState.Default)
    else
        self.TalkSystem:ChangePlayState(NpcTalkAnimPlayState.Other)
    end
end

-- Set UI model animation
function UINpcTalkForm:SetModelPositionAndAlpha(startPos, endPos, trans, duration)
    duration = duration or 0.3
    if trans ~= nil then
        local _tween = UIUtils.RequireTweenPosition(trans)
        if _tween ~= nil then
            _tween:ResetToBeginning()
            _tween.duration = duration
            _tween.from = startPos
            _tween.to = endPos
            _tween:PlayForward()
        end
        local _alpha = UIUtils.FindTweenAlpha(trans)
        if _alpha ~= nil then
            _alpha:ResetToBeginning()
            _alpha.from = 0
            _alpha.to = 1
            _alpha.duration = duration
            _alpha:PlayForward()
        end
    end
end

-- Set reward props
function UINpcTalkForm:SetReward(task)
    if task ~= nil then
        local _isShowTitle = false
        local _rewCount = #task.Data.RewardList
        --fix yy The reward display moves from the top right corner to the bottom left corner
        -- if _rewCount > 0 then
        --     for i = 1, _rewCount do
        --         local reward = task.Data.RewardList[i]
        --         if L_ItemBase.GetItemTypeByModelID(reward.ID) ~= ItemType.Money then
        --             _isShowTitle = true
        --             break
        --         end
        --     end
        --     self.RewardTitle.gameObject:SetActive(_isShowTitle)
        -- else
        --     self.RewardTitle.gameObject:SetActive(false)
        -- end
        local _index = 1

        for i = 1, _rewCount do
            local reward = task.Data.RewardList[i]
            --if L_ItemBase.GetItemTypeByModelID(reward.ID) ~= ItemType.Money then
                if _index <= #self.ItemList and _index <= 3 then
                    local _itemUI = self.ItemList[_index]
                    _itemUI.RootGO:SetActive(true)
                    -- Debug.Log("yy reward id: "..tostring(reward.ID))
                    _itemUI:InItWithCfgid(reward.ID, reward.Num, reward.IsBind, false, false)
                    _index = _index + 1
                end
            --end
        end
        
        for i = _rewCount + 1, #self.ItemList do
            self.ItemList[i].RootGO:SetActive(false)
        end
    else
        -- Debug.Log("yy SetReward task 222")
        for i = 1, #self.ItemList do
            self.ItemList[i].RootGO:SetActive(false)
        end
    end
    self.Grid.repositionNow = true
end

function UINpcTalkForm:AutoControll(dt)
    if self.OffTime ~= nil and self.OffTime.gameObject.activeSelf then
        if self.CutTime > 0 then
            if self.PrevCutTime > math.ceil(self.CutTime) or self.PrevCutTime == 0 then
                UIUtils.SetTextFormat(self.Time, "({0})", math.ceil(self.CutTime) - 1)
                self.PrevCutTime = self.CutTime
            end
            self.CutTime = self.CutTime - dt
        else
            self.CutTime = self.CTime
            self.PrevCutTime = 0
            -- Automatically receive or submit tasks
            if self.TalkType == L_TalkType.SubMit then
                self:OnClickSubMit()
                self.OffTime.gameObject:SetActive(false)
            elseif self.TalkType == L_TalkType.Access then
                self:OnClickAccess()
                self.OffTime.gameObject:SetActive(false)
            elseif self.TalkType == L_TalkType.EnterMap then
                self:OnClickFuncClick()
                self.OffTime.gameObject:SetActive(false)
            elseif self.TalkType == L_TalkType.NextTalk then
                self:OnClickNextTalk()
            elseif self.TalkType == L_TalkType.CutTimeBtn then
                self:OnClickFuncClick()
                self.OffTime.gameObject:SetActive(false)
            end
        end
    end
end

function UINpcTalkForm:UpdatePlayState()
    local _playState = self.TalkSystem.CurPlayState
    if _playState == NpcTalkAnimPlayState.Default then
        if self.TalkSystem:IsCanPlayNextAnim() then
            self.Skin:Play(self.TalkSystem.Other, 0, 1, 1)
            self.TalkSystem:ChangePlayState(2)
        end
    elseif _playState == NpcTalkAnimPlayState.Default then
        -- This is a forced switching action clip
        self.Skin:Play(self.TalkSystem.NextClipName, 0, 1, 1)
        self.TalkSystem:ChangePlayState(2)
    elseif _playState == 2 then
    end
end

function UINpcTalkForm:Update(dt)
    if self.IsSubmitState then
        if self.SubMitCD > 0 then
            self.SubMitCD = self.SubMitCD - dt
        else
            self.SubMitCD = 2
            self.IsSubmitState = false
        end
    end
    self:AutoControll(dt)
    self:UpdatePlayState()
end

-- Process strings
function UINpcTalkForm:DealWitchTalkStr(str)
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return ""
    end
    local _occ = _lp.IntOcc
    local _sb = ""
    local _strs = Utils.SplitStr(str, '<')
    for i = 1, #_strs do
        if string.find(_strs[i], '>', 1) ~= nil then
            if string.find(_strs[i], "-n", 1) ~= nil then
                -- Processing character names
                local _replaceStr = string.gsub(_strs[i], "-n", "")
                local _param1 = ""
                local _param2 = ""
                local _param3 = ""
                local _param4 = ""
                local _strs1 = Utils.SplitStr(_replaceStr, '>')
                for m = 1, #_strs1 do
                    if string.find(_strs1[m], '/', 1) ~= nil then
                        local _strs2 = Utils.SplitStr(_strs1[m], '/')
                        _param1 = _strs2[1]
                        _param2 = _strs2[2]
                        _param3 = _strs2[3]
                        _param4 = _strs2[4]
                    else
                        local _param = ""
                        if _occ == 0 then
                            _param = _param1
                        elseif _occ == 1 then
                            _param = _param2
                        elseif _occ == 2 then
                            _param = _param3
                        elseif _occ == 3 then
                            _param = _param4
                        end
                        _sb = _sb .. UIUtils.CSFormat(_strs1[m], _param)
                    end
                end
            end
        else
            _sb = _sb .. _strs[i]
        end
    end
    return _sb
end

return UINpcTalkForm
