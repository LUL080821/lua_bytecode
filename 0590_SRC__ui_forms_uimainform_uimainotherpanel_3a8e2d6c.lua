------------------------------------------------
-- author:
-- Date: 2021-03-01
-- File: UIMainOtherPanel.lua
-- Module: UIMainOtherPanel
-- Description: Other pages on the left side of the main interface
------------------------------------------------

local L_UIMainSubBasePanel = require "UI.Forms.UIMainForm.UIMainSubBasePanel"

local UIMainOtherPanel = {
    SelfWighet = nil,
    ChildGo = nil,
    ChildPanel = nil,
    ChildTrans = nil,
    AnchorTrans = nil,
    WaitFrame = 0,
}

function UIMainOtherPanel:OnFirstShow(trans, parent, rootForm)
    setmetatable(self, {__index = L_UIMainSubBasePanel.New()})
    self:BaseFirstShow(trans, parent, rootForm)
    self.SelfWighet = UIUtils.FindWid(trans)
    self.AnchorTrans = UIUtils.FindTrans(trans, "Container")
end
function UIMainOtherPanel:OnShowAfter()
    self.ChildGo = nil
    self.ChildPanel = nil
    self.ChildTrans = nil
    GameCenter.PushFixEvent(GameCenter.MapLogicSwitch.EventOpen)
end

-- Before closing
function UIMainOtherPanel:OnHideBefore()
    self.ChildGo = nil
    self.ChildPanel = nil
    self.ChildTrans = nil
    GameCenter.PushFixEvent(GameCenter.MapLogicSwitch.EventClose)
end
function UIMainOtherPanel:Update(dt)
    if not self.IsVisible then
        return
    end
    if self.SelfWighet == nil then
        return
    end
    local _go = GameCenter.FormStateSystem:GetOpenedFormByEventID(GameCenter.MapLogicSwitch.EventOpen)
    if self.ChildGo ~= _go then
        self.ChildGo = _go
        if _go ~= nil then
            local _trans = _go.transform
            self.ChildPanel = UIUtils.FindPanel(_trans)
            self.ChildTrans = _trans
            self.WaitFrame = 1
        end
    end
    if _go == nil then
        return
    end
    if self.WaitFrame > 0 then
        self.WaitFrame = self.WaitFrame - 1
        return
    end

    if self.SelfWighet.finalAlpha <= 0 then
        -- Hide state
        if self.ChildTrans ~= nil and self.ChildPanel ~= nil then
            local _pos = self.Trans.position
            _pos.z = 0
            self.ChildTrans.position = _pos
            self.ChildPanel.alpha = self.SelfWighet.finalAlpha
        end
    elseif self.SelfWighet.finalAlpha >= 1 then
        local _pos = nil
        -- Display status
        if self.ChildTrans ~= nil and self.ChildPanel ~= nil then
            _pos = self.RootForm.Trans.position
            _pos.z = 0
            self.ChildTrans.position = _pos
            self.ChildPanel.alpha = 1
        end
        -- Always set the position in the display state
        _pos = self.RootForm.Trans.position
        _pos.z = 0
        self.SelfWighet.transform.position = _pos
    else
        -- During animation
        if self.ChildTrans ~= nil and self.ChildPanel ~= nil then
            local _pos = self.Trans.position
            _pos.z = 0
            self.ChildTrans.position = _pos
            self.ChildPanel.alpha = self.SelfWighet.finalAlpha
        end
    end
end

return UIMainOtherPanel