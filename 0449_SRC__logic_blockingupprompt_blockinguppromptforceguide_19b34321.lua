------------------------------------------------
-- Author:
-- Date: 2021-04-09
-- File: BlockingUpPromptForceGuide.lua
-- Module: BlockingUpPromptForceGuide
-- Description: Forced Boot
------------------------------------------------

local L_BlockingUpPromptBase = require "Logic.BlockingUpPrompt.BlockingUpPromptBase"
local L_PostEffectManager = CS.Thousandto.Core.PostEffect.PostEffectManager
local L_TimelinePlayer = CS.Thousandto.Core.Asset.TimelinePlayer
local L_TimelinePlayState = CS.Thousandto.Core.Asset.TimelinePlayState

local L_NotCloseUI = {
    "UIHUDForm", "UIMainForm", "UIMainFormPC", "UIGuideForm", "UIReliveForm", "UIMsgPromptForm", "UIMsgMarqueeForm",
    "UILoadingForm", "UICinematicForm", "UIGetEquipTIps", "UIPowerSaveForm", "UIPropertyChangeForm",
    "UIRealmExpMapMainForm", "UIBossHomeCopyMainForm","UIDNYFCopyMainForm","UIExpCopyMainForm","UIGuildFightMainForm",
    "UIHunShouShenLinCopyMainForm", "UIJiuTianCopyMainForm", "UIManyCopyMainForm","UINewWorldBossCopyMainForm",
    "UIPlaneCopyMainForm", "UISkyDoorCopyMainForm", "UISZZQCopyMainForm", "UIWYTCopyMainForm", "UIYZZDCopyMainForm",
    "UITaskFinishNoticeForm","UILevelUPNoticeForm", "UIStatureBossCopyForm", "UIJjcCopyForm", "UIWuxianBossCopyMainForm",
    "UIWuxianBossCopyForm","UINewWorldBossCopyForm","UINewWorldBossCopyMainForm",
}

local BlockingUpPromptForceGuide = {
    CfgId = 0,
    AnimTimer = 0,
    WaitFrame = 0,
    IsLoadingTimeLine = false,
    IsHideCamera = false,
    SceneRestoreState = false,
    ShadowIsEnable = false,
    OldIsPauseTips = false,
    OpenSkipForm = false,
}

function BlockingUpPromptForceGuide:New(cfgId, endCallBack, openSkip)
    local _n = Utils.DeepCopy(self)
    local _m = setmetatable(_n, {
        __index = L_BlockingUpPromptBase:New(BlockingUpPromptType.NewFunction, endCallBack)
    })
    _m.CfgId = cfgId
    _m.PromptState = BlockingUpPromptState.Initialize
    _m.AnimTimer = 0
    _m.WaitFrame = 0
    _m.IsLoadingTimeLine = false
    _m.IsHideCamera = false
    _m.SceneRestoreState = false
    _m.ShadowIsEnable = false
    _m.OldIsPauseTips = false
    _m.OpenSkipForm = openSkip
    return _m
end

function BlockingUpPromptForceGuide:Start()
    local _cfg = DataConfig.DataGuide[self.CfgId]
    if _cfg == nil then
        self.PromptState = BlockingUpPromptState.Finish
        return
    end
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        self.PromptState = BlockingUpPromptState.Finish
        return
    end
    _lp:DoStartGuide()
    -- Turn off all full screen interfaces
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_HIDE_CURFULLSCREEN_FORM)
    -- Turn off other interfaces
    if _cfg.TargetUi ~= nil and string.len(_cfg.TargetUi) > 0 then
        local _uiArray = Utils.SplitStr(_cfg.TargetUi, ';')
        for i = 1, #_uiArray do
            L_NotCloseUI[#L_NotCloseUI + 1] = _uiArray[i]
        end
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_CLOSE_ALL_FORM, L_NotCloseUI)
        L_NotCloseUI[#L_NotCloseUI + 1] = nil
    else
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_CLOSE_ALL_FORM, L_NotCloseUI)
    end
    if GameCenter.MainFunctionSystem:GetFunctionInfo(_cfg.OpenFunction) ~= nil then
        -- Open the function interface
        GameCenter.MainFunctionSystem:DoFunctionCallBack(_cfg.OpenFunction, _cfg.OpenFunctionParam)
    end
    if _cfg.OpenFunction ~= FunctionStartIdCode.MainFuncRoot then
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_CLOSE_MAINMENU)
    end
    GameCenter.PushFixEvent(UIEventDefine.UIChatMainForm_CLOSE)
    if _cfg.Type == GuideForcedType.SceneAnim or _cfg.Type == GuideForcedType.TimelineAnim then
        self.WaitFrame = 2
        self.SceneRestoreState = GameCenter.SceneRestoreSystem.StoryEnable
        GameCenter.SceneRestoreSystem.StoryEnable = false
        if self.OpenSkipForm and GameCenter.SkipSystem ~= nil then
            GameCenter.SkipSystem:OpenSkip(function()
                self.WaitFrame = 0
                self.AnimTimer = 0
            end)
        end
    elseif _cfg.Type == GuideForcedType.Forced then
        -- Close the item usage interface
        GameCenter.PushFixEvent(UIEventDefine.UIITEMGET_TIPS_CLOSE)
        self.OldIsPauseTips = GameCenter.MapLogicSwitch.PauseGetNewItemTips
        GameCenter.MapLogicSwitch.PauseGetNewItemTips = true
        -- Open the boot interface
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_START_FORCEGUIDE, self.CfgId)
    else
        -- Open the boot interface
        GameCenter.PushFixEvent(UIEventDefine.UINotForceGuideForm_OPEN, self.CfgId)
    end
    -- Perform a delivery
    if _cfg.FinishTeleport ~= nil and string.len(_cfg.FinishTeleport) > 0 then
        local _teleParams = Utils.SplitNumber(_cfg.FinishTeleport, '_')
        if _teleParams ~= nil and #_teleParams >= 3 then
            GameCenter.Network.Send("MSG_Map.ReqTransportControl", {type = 2, mapID = _teleParams[1], x = _teleParams[2], y = _teleParams[3], param = -1})
        end
    end
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_ONGUIDEFORM_OPEN, self.OnForceGuideUIOpen, self)
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_ONGUIDEFORM_CLOSE, self.OnForceGuideUIClose, self)
end

function BlockingUpPromptForceGuide:End()
    local _cfg = DataConfig.DataGuide[self.CfgId]
    if _cfg.Type == GuideForcedType.SceneAnim or _cfg.Type == GuideForcedType.TimelineAnim then
        if self.IsHideCamera then
            GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_DEC_MAINCAMERA_HIDECOUNTER)
        end
        local _nodeNames = Utils.SplitStr(_cfg.Steps, ';')
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        local _occ = _lp.IntOcc + 1
        if _cfg.Type == GuideForcedType.SceneAnim then
            local _sceneRoot = GameObject.Find("SceneRoot")
            local _animTrans = _sceneRoot.transform:Find(_nodeNames[_occ])
            if _animTrans ~= nil then
                _animTrans.gameObject:SetActive(false)
                L_PostEffectManager.Instance:EnableShadow(self.ShadowIsEnable)
            end
        else
            local _timelineId = tonumber(_nodeNames[_occ])
            if _timelineId ~= nil then
                L_TimelinePlayer.Stop()
                L_PostEffectManager.Instance:EnableShadow(self.ShadowIsEnable)
            end
        end
        GameCenter.SceneRestoreSystem.StoryEnable = self.SceneRestoreState
        if GameCenter.SkipSystem ~= nil then
            GameCenter.SkipSystem:ForceCloseSkip()
        end
    end
    if _cfg.Type == GuideForcedType.Forced then
        GameCenter.MapLogicSwitch.PauseGetNewItemTips = self.OldIsPauseTips
    end
    self:DoBaseEnd()
end

function BlockingUpPromptForceGuide:OnForceGuideUIOpen(obj, sender)
    self.PromptState = BlockingUpPromptState.Running
end

function BlockingUpPromptForceGuide:OnForceGuideUIClose(isError, sender)
    if not isError then
        -- Save without errors
        GameCenter.GuideSystem:SaveGuide(self.CfgId)
    end
    self.PromptState = BlockingUpPromptState.Finish
end

function BlockingUpPromptForceGuide:PlayAnim()
    if self.IsHideCamera then
        return
    end
    local _cfg = DataConfig.DataGuide[self.CfgId]
    self.AnimTimer = _cfg.OpenFunctionParam / 1000
    self.PromptState = BlockingUpPromptState.Running
    self.ShadowIsEnable = L_PostEffectManager.Instance.IsEnableShadow
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_ADD_MAINCAMERA_HIDECOUNTER)
    L_PostEffectManager.Instance:EnableShadow(false)
    self.IsHideCamera = true
end

function BlockingUpPromptForceGuide:Update(dt)
    local _cfg = DataConfig.DataGuide[self.CfgId]
    if _cfg.Type == GuideForcedType.SceneAnim or _cfg.Type == GuideForcedType.TimelineAnim then
        if self.WaitFrame > 0 then
            self.WaitFrame = self.WaitFrame - 1
            if self.WaitFrame <= 0 then
                local _nodeNames = Utils.SplitStr(_cfg.Steps, ';')
                local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
                local _occ = _lp.IntOcc + 1
                if _cfg.Type == GuideForcedType.SceneAnim then
                    local _sceneRoot = GameObject.Find("SceneRoot")
                    local _animTrans = _sceneRoot.transform:Find(_nodeNames[_occ])
                    if _animTrans ~= nil then
                        _animTrans.gameObject:SetActive(true)
                        self:PlayAnim()
                    else
                        self.PromptState = BlockingUpPromptState.Finish
                    end
                else
                    local _timelineId = tonumber(_nodeNames[_occ])
                    if _timelineId ~= nil then
                        self.IsLoadingTimeLine = true
                        L_TimelinePlayer.Play(_timelineId, function(info)
                            self.IsLoadingTimeLine = false
                            if info == nil then
                                self.ShadowIsEnable = L_PostEffectManager.Instance.IsEnableShadow
                                self.PromptState = BlockingUpPromptState.Finish
                                return
                            end
                            if info.TimelinePlayState == L_TimelinePlayState.None then
                                local _actorNames = info.ActorNames
                                if _actorNames ~= nil then
                                    local _length = _actorNames.Length
                                    -- If there is a protagonist
                                    for i = 1, _length do
                                        if _actorNames[i - 1] == "LocalPlayer" then
                                            local _tempLp = GameObject.Instantiate(_lp.Skin:GetSkinPart(FSkinPartCode.Body).RealGameObject)
                                            UnityUtils.SetLayer(_tempLp.transform, LayerUtils.Default, true)
                                            info:SetActor("LocalPlayer", _tempLp)
                                        end
                                    end
                                end
                                self:PlayAnim()
                            end
                        end)
                    else
                        self.PromptState = BlockingUpPromptState.Finish
                    end
                end
                GameCenter.GuideSystem:SaveGuide(self.CfgId)
            end
        else
            if not self.IsLoadingTimeLine then
                self.AnimTimer = self.AnimTimer - dt
                if self.AnimTimer <= 0 then
                    self.PromptState = BlockingUpPromptState.Finish
                end
            end
        end
    end
end

return BlockingUpPromptForceGuide