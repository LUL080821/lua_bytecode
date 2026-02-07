
------------------------------------------------
-- Author:
-- Date: 2020-08-14
-- File: SkipSystem.lua
-- Module: SkipSystem
-- Description: Skip
------------------------------------------------
-- Quote

local SkipSystem = {
    SkipCallBack = nil,
}

function SkipSystem:OpenSkip(skipFuc)
    self.SkipCallBack = skipFuc
    -- Open the skip interface
    GameCenter.PushFixEvent(UILuaEventDefine.UISkipForm_OPEN)
end

function SkipSystem:ForceCloseSkip()
    GameCenter.PushFixEvent(UILuaEventDefine.UISkipForm_CLOSE)
    self:CloseSkip()
end

function SkipSystem:CloseSkip()
    if self.SkipCallBack ~= nil then
        self.SkipCallBack()
        self.SkipCallBack = nil
    end
end

return SkipSystem