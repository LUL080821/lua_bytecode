------------------------------------------------
-- author:
-- Date: 2021-02-27
-- File: UIMainJoystickPanel.lua
-- Module: UIMainJoystickPanel
-- Description: Main interface rocker interface
------------------------------------------------

local L_UIMainSubBasePanel = require "UI.Forms.UIMainForm.UIMainSubBasePanel"
local L_MaxDis = 0.25

local UIMainJoystickPanel = {
    BackGo = nil,
    BackTrans = nil,
    ThumbTrans = nil,
    UiCamera = nil,
}
-- Register Events
function UIMainJoystickPanel:OnRegisterEvents()
    -- Drag to start
    self:RegisterEvent(LogicEventDefine.EID_EVENT_JOYSTICK_DRAGBEGIN, self.OnDragBegin, self)
    -- Dragging
    self:RegisterEvent(LogicEventDefine.EID_EVENT_JOYSTICK_DRAGING, self.OnDraging, self)
    -- Drag ends
    self:RegisterEvent(LogicEventDefine.EID_EVENT_JOYSTICK_DRAGEND, self.OnDragEnd, self)
end

function UIMainJoystickPanel:OnFirstShow(trans, parent, rootForm)
    setmetatable(self, {__index = L_UIMainSubBasePanel.New()})
    self:BaseFirstShow(trans, parent, rootForm)
    self.BackTrans = UIUtils.FindTrans(trans, "Back")
    self.BackGo = self.BackTrans.gameObject
    self.ThumbTrans = UIUtils.FindTrans(trans, "Back/Thumb")
end

-- After display
function UIMainJoystickPanel:OnShowAfter()
    self.BackGo:SetActive(false)
    self.UiCamera = self.RootForm.CSForm.Manager.UI2DCamera
end

-- Drag to start
function UIMainJoystickPanel:OnDragBegin(screenPos, sender)
    self.BackGo:SetActive(true)
    local _screenPos3D = Vector3(screenPos.x, screenPos.y, 0)
    self.BackTrans.position = self.UiCamera:ScreenToWorldPoint(_screenPos3D)
    self.ThumbTrans.localPosition = self.BackTrans.position
end
-- Dragging
function UIMainJoystickPanel:OnDraging(screenPos, sender)
    GameCenter.PushFixEvent(UILuaEventDefine.UIAutoSearchPathForm_CLOSE)
    local _screenPos3D = Vector3(screenPos.x, screenPos.y, 0)
    _screenPos3D = self.UiCamera:ScreenToWorldPoint(_screenPos3D)
    local _disVec = _screenPos3D - self.BackTrans.position
    local _sqrDis = _disVec.x * _disVec.x + _disVec.y * _disVec.y + _disVec.z * _disVec.z
    if _sqrDis > L_MaxDis * L_MaxDis then
        local _dir = _disVec.normalized
        _screenPos3D = self.BackTrans.position + _dir * L_MaxDis
    end
    self.ThumbTrans.position = _screenPos3D
end
-- Drag ends
function UIMainJoystickPanel:OnDragEnd(screenPos, sender)
    self.BackGo:SetActive(false)
end

return UIMainJoystickPanel