------------------------------------------------
-- Author:
-- Date: 2021-04-09
-- File: BlockingUpPromptSystem.lua
-- Module: BlockingUpPromptSystem
-- Description: Blocking prompt system
------------------------------------------------
local L_BlockingUpPromptFlyTeleport = require "Logic.BlockingUpPrompt.BlockingUpPromptFlyTeleport"
local L_BlockingUpPromptForceGuide = require "Logic.BlockingUpPrompt.BlockingUpPromptForceGuide"
local L_BlockingUpPromptNewFunction = require "Logic.BlockingUpPrompt.BlockingUpPromptNewFunction"
local L_BlockingUpPromptTimelineTeleport = require "Logic.BlockingUpPrompt.BlockingUpPromptTimelineTeleport"


local BlockingUpPromptSystem = {
    PromptList = List:New(),
    CurRunningPrompt = nil,
    -- Record whether the hang-up is running
    MandateIsRunning = false,
    FrontIsRunning = false,
}

function BlockingUpPromptSystem:IsRunning()
    return self.CurRunningPrompt ~= nil and not self.CurRunningPrompt:IsFinish() or #self.PromptList > 0
end

function BlockingUpPromptSystem:Initialize()
    -- Add mandatory guidance
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_BLOCK_ADD_FORCEGUIDE, self.OnEventAddForceGuide, self)
    -- Add model display
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_BLOCK_ADD_SHOWMODEL, self.OnEventAddShowModel, self)
    -- Add new features to enable
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_BLOCK_ADD_NEWFUNCTION, self.OnEventAddNewFunction, self)
    -- Add conversation
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_BLOCK_ADD_DIALOG, self.OnEventAddDialog, self)
    -- Add plot display
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_BLOCK_ADD_CINEMATIC, self.OnEventAddCinematic, self)
    -- Increase flight delivery
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_BLOCK_ADD_FLYTELEPORT, self.OnEventAddFlyTeleport, self)
    -- Add chapter display
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_BLOCK_ADD_TASKCHAPTER, self.OnEventAddTaskChapter, self)
end

-- De-initialization
function BlockingUpPromptSystem:UnInitialize()
    self:Clear()
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_BLOCK_ADD_FORCEGUIDE, self.OnEventAddForceGuide, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_BLOCK_ADD_SHOWMODEL, self.OnEventAddShowModel, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_BLOCK_ADD_NEWFUNCTION, self.OnEventAddNewFunction, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_BLOCK_ADD_DIALOG, self.OnEventAddDialog, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_BLOCK_ADD_CINEMATIC, self.OnEventAddCinematic, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_BLOCK_ADD_FLYTELEPORT, self.OnEventAddFlyTeleport, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_BLOCK_ADD_TASKCHAPTER, self.OnEventAddTaskChapter, self)
end

function BlockingUpPromptSystem:Update(dt)
    if self.CurRunningPrompt == nil and #self.PromptList > 0 then
        self.CurRunningPrompt = self.PromptList[1]
        self.CurRunningPrompt:Start()
        self.PromptList:RemoveAt(1)
        if not self.FrontIsRunning then
            self:OnStart()
        end
    end

    if self.CurRunningPrompt ~= nil then
        self.CurRunningPrompt:Update(dt)
        if self.CurRunningPrompt ~= nil and self.CurRunningPrompt:IsFinish() then
            if #self.PromptList <= 0 then
                self:OnEnd(self.CurRunningPrompt)
            end
            if self.CurRunningPrompt ~= nil then
                self.CurRunningPrompt:End()
                self.CurRunningPrompt = nil
            end
        end
    end
    self.FrontIsRunning = self:IsRunning()
    return true
end

-- Add mandatory guidance
function BlockingUpPromptSystem:AddForceGuide(guideCfg, endCallBack, openSkip)
    if guideCfg ~= nil then
        if openSkip == nil then
            openSkip = true
        end
        self:RemoveNotForceGuide()
        self.PromptList:Add(L_BlockingUpPromptForceGuide:New(guideCfg.Id, endCallBack, openSkip))
        self:Update(0)
    end
end

-- Add mandatory guidance
function BlockingUpPromptSystem:AddForceGuideByID(cfgID, endCallBack, openSkip)
    local guideCfg = DataConfig.DataGuide[cfgID]
    if guideCfg ~= nil then
        if openSkip == nil then
            openSkip = true
        end
        self:RemoveNotForceGuide()
        self.PromptList:Add(L_BlockingUpPromptForceGuide:New(cfgID, endCallBack, openSkip))
        self:Update(0)
    end
end

-- Add new features to enable
function BlockingUpPromptSystem:AddNewFunction(type, dataID, endCallBack)
    self:RemoveNotForceGuide()
    local _succ = false
    local _func = function(k, cfg)
        if cfg.Type == type and cfg.DataId == dataID then
            self.PromptList:Add(L_BlockingUpPromptNewFunction:New(k, endCallBack))
            self:Update(0)
            _succ = true
            return true
        end
        return false
    end
    DataConfig.DataFunctionOpen:ForeachCanBreak(_func)
    return _succ
end

-- Flying delivery
function BlockingUpPromptSystem:AddFlyTeleport(id, endCallBack)
    self:RemoveNotForceGuide()
    self.PromptList:Add(L_BlockingUpPromptFlyTeleport:New(id, endCallBack))
    self:Update(0)
end

-- Animation delivery
function BlockingUpPromptSystem:AddTimelineTeleport(transId, timelineId, startX, startY, endCallBack)
    -- If there is a transmission animation, no playback is done
    if self.CurRunningPrompt ~= nil and self.CurRunningPrompt.PromptType == BlockingUpPromptType.TimelineTeleport then
        return
    end
    for i = 1, #self.PromptList do
        if self.PromptList[i].PromptType == BlockingUpPromptType.TimelineTeleport then
            return
        end
    end
    self:RemoveNotForceGuide()
    self.PromptList:Add(L_BlockingUpPromptTimelineTeleport:New(transId, timelineId, startX, startY, endCallBack))
    self:Update(0)
end

function BlockingUpPromptSystem:Clear()
    if self.CurRunningPrompt ~= nil then
        self.CurRunningPrompt:End()
        self.CurRunningPrompt = nil
    end
    self.PromptList:Clear()
end

-- Clear non-forced boot
function BlockingUpPromptSystem:RemoveNotForceGuide()
    for i = #self.PromptList, 1, -1 do
        if self.PromptList[i].PromptType == BlockingUpPromptType.ForceGuide then
            local _guideCfg = DataConfig.DataGuide[self.PromptList[i].CfgId]
            if _guideCfg == nil or _guideCfg.Type == GuideForcedType.NotForced then
                self.PromptList:RemoveAt(i)
            end
        end
    end
    if self.CurRunningPrompt ~= nil and self.CurRunningPrompt.PromptType == BlockingUpPromptType.ForceGuide then
        local _guideCfg = DataConfig.DataGuide[self.CurRunningPrompt.CfgId]
        if _guideCfg ~= nil and _guideCfg.Type == GuideForcedType.NotForced then
            self.CurRunningPrompt:End()
            self.CurRunningPrompt = nil
        end
    end
    GameCenter.PushFixEvent(UIEventDefine.UINotForceGuideForm_CLOSE)
end

function BlockingUpPromptSystem:OnStart()
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp ~= nil then
        _lp:Stop_Action()
        PlayerBT.ChangeState(PlayerBDState.Default)
    end
    if not self.MandateIsRunning then
        self.MandateIsRunning = GameCenter.MandateSystem:IsRunning()
    end
    GameCenter.MandateSystem:End()
end

function BlockingUpPromptSystem:OnEnd(bup)
    if bup == nil then
        return
    end
    if bup.PromptType == BlockingUpPromptType.ForceGuide then
        -- Continue to boot
        local _guideCfg = DataConfig.DataGuide[bup.CfgId]
        if _guideCfg ~= nil then
            local _nextCfg = DataConfig.DataGuide[_guideCfg.ContinueGuide]
            if _nextCfg ~= nil then
                self.PromptList:Add(L_BlockingUpPromptForceGuide:New(_nextCfg.Id, nil, true))
            end
        end
    end
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end
    if not _lp.IsChuanDaoing then
        if self.MandateIsRunning then
            GameCenter.MandateSystem:Start()
            self.MandateIsRunning = false
        end
    end
end

function BlockingUpPromptSystem:OnEventAddForceGuide(obj, sender)
    if obj == nil then
        return
    end
    self:AddForceGuideByID(obj)
end

function BlockingUpPromptSystem:OnEventAddShowModel(obj, sender)
end

function BlockingUpPromptSystem:OnEventAddNewFunction(obj, sender)
end

function BlockingUpPromptSystem:OnEventAddDialog(obj, sender)
end

function BlockingUpPromptSystem:OnEventAddCinematic(obj, sender)
end

function BlockingUpPromptSystem:OnEventAddFlyTeleport(obj, sender)
end

function BlockingUpPromptSystem:OnEventAddTaskChapter(obj, sender)
end

return BlockingUpPromptSystem