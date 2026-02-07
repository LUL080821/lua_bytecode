------------------------------------------------
-- Author:
-- Date: 2021-04-09
-- File: BlockingUpPromptBase.lua
-- Module: BlockingUpPromptBase
-- Description: Blocking base class
------------------------------------------------

local BlockingUpPromptBase = {
    -- Blocking type
    PromptType = BlockingUpPromptType.Count,
    -- Current status
    PromptState = BlockingUpPromptState.None,
    -- End callback
    EndCallBack = nil,
}

function BlockingUpPromptBase:New(type, endCallBack)
    local _m = Utils.DeepCopy(self)
    _m.PromptType = type
    _m.EndCallBack = endCallBack
    return _m
end

-- Whether it's over
function BlockingUpPromptBase:IsFinish()
    return self.PromptState == BlockingUpPromptState.Finish
end

-- End of execution
function BlockingUpPromptBase:DoBaseEnd()
    if self.EndCallBack ~= nil then
        self.EndCallBack(self)
    end
end

return BlockingUpPromptBase