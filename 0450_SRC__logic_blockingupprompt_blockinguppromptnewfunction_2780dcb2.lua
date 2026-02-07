------------------------------------------------
-- Author:
-- Date: 2021-04-09
-- File: BlockingUpPromptNewFunction.lua
-- Module: BlockingUpPromptNewFunction
-- Description: Function is enabled
------------------------------------------------

local L_BlockingUpPromptBase = require "Logic.BlockingUpPrompt.BlockingUpPromptBase"

local BlockingUpPromptNewFunction = {
    CfgId = 0,
    LifeTime = 0,
}

function BlockingUpPromptNewFunction:New(cfgId, endCallBack)
    local _n = Utils.DeepCopy(self)
    local _m = setmetatable(_n, {
        __index = L_BlockingUpPromptBase:New(BlockingUpPromptType.ForceGuide, endCallBack)
    })
    _m.CfgId = cfgId
    _m.PromptState = BlockingUpPromptState.Initialize
    _m.LifeTime = 0
    return _m
end

function BlockingUpPromptNewFunction:Start()
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_NEWFUNCTION_CLOSE, self.OnNewFunctionFormClose, self)
    GameCenter.PushFixEvent(UIEventDefine.UINewFunctionForm_OPEN, self.CfgId)
    self.PromptState = BlockingUpPromptState.Running
    self.LifeTime = 7
end

function BlockingUpPromptNewFunction:OnNewFunctionFormClose(cfgId, sender)
    if cfgId == self.CfgId then
        self.PromptState = BlockingUpPromptState.Finish
    end
end

function BlockingUpPromptNewFunction:End()
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_NEWFUNCTION_CLOSE, self.OnNewFunctionFormClose, self)
    self:DoBaseEnd()
end

function BlockingUpPromptNewFunction:Update(dt)
    if self.LifeTime > 0 then
        self.LifeTime = self.LifeTime - dt
        if self.LifeTime <= 0 then
            self.PromptState = BlockingUpPromptState.Finish
        end
    end
end

return BlockingUpPromptNewFunction