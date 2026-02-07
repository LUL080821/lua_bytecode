------------------------------------------------
-- Author: 
-- Date: 2021-02-24
-- File: MainCustomBtnSystem.lua
-- Module: MainCustomBtnSystem
-- Description: Custom button system
------------------------------------------------

local L_MainCustomBtn = require "Logic.MainCustomBtnSystem.MainCustomBtn"

local MainCustomBtnSystem = {
    BtnList = List:New(),
}

function MainCustomBtnSystem:Initialize()
    self.BtnList:Clear()
end

function MainCustomBtnSystem:UnInitialize()
    self.BtnList:Clear()
end

local function L_BtnShort(left, right)
    local _lTime = left:GetRemainTime()
    local _rTime = right:GetRemainTime()
    if not left.UseRemainTime then
        _lTime = -999999999
    end
    if not right.UseRemainTime then
        _rTime = -999999999
    end

    if _lTime == _rTime then
        return left.ID < right.ID
    end
    return _lTime < _rTime
end

-- Add a limited time button
function MainCustomBtnSystem:AddLimitBtn( iconID, showText, remainTime, customData, clickBack, showEffect, showRedPoint, remainTimeSuf, useServerTime, tweenRot, vfxId, isRemainTimeStart)
    local _newBtn = L_MainCustomBtn:New()
    _newBtn.IconID = iconID
    _newBtn.ShowText = showText
    _newBtn.UseServerTime = useServerTime
    _newBtn:SetRemainTime(remainTime)
    _newBtn.RemainTimeSuf = remainTimeSuf
    _newBtn.CustomData = customData
    _newBtn.ClickCallBack = clickBack
    _newBtn.UseRemainTime = true
    _newBtn.ShowEffect = showEffect
    _newBtn.ShowRedPoint = showRedPoint
    _newBtn.TweenRot = tweenRot
    _newBtn.VfxId = vfxId
    _newBtn.IsRemainTimeStart = isRemainTimeStart or false
    self.BtnList:Add(_newBtn)
    self.BtnList:Sort(L_BtnShort)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATECUSTONBTNS)
    return _newBtn.ID
end

-- Add unlimited buttons
function MainCustomBtnSystem:AddBtn(iconID, showText, customData, clickBack, showEffect, showRedPoint, tweenRot, vfxId)
    local _newBtn = L_MainCustomBtn:New()
    _newBtn.IconID = iconID
    _newBtn.ShowText = showText
    _newBtn.RemainTime = 0
    _newBtn.CustomData = customData
    _newBtn.ClickCallBack = clickBack
    _newBtn.UseRemainTime = false
    _newBtn.ShowEffect = showEffect
    _newBtn.ShowRedPoint = showRedPoint
    _newBtn.TweenRot = tweenRot
    _newBtn.VfxId = vfxId
    self.BtnList:Add(_newBtn)
    self.BtnList:Sort(L_BtnShort)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATECUSTONBTNS)
    return _newBtn.ID
end

-- Setting display red dots
function MainCustomBtnSystem:SetShowRedPoint(id, show)
    local _succ = false
    for i = 1, #self.BtnList do
        local _btn = self.BtnList[i]
        if _btn.ID == id then
            if _btn.ShowRedPoint ~= show then
                _btn.ShowRedPoint = show
                _succ = true
            end
            break
        end
    end
    if _succ then
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATECUSTONBTNS)
    end
    return _succ
end
    
-- Set display effects
function MainCustomBtnSystem:SetShowEffect(id, show)
    local _succ = false
    for i = 1, #self.BtnList do
        local _btn = self.BtnList[i]
        if _btn.ID == id then
            if _btn.ShowEffect ~= show then
                _btn.ShowEffect = show
                _succ = true
            end
            break
        end
    end
 
    if _succ then
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATECUSTONBTNS)
    end
    return _succ
end
-- Delete button
function MainCustomBtnSystem:RemoveBtn(id)
    local _succ = false
    for i = 1, #self.BtnList do
        if self.BtnList[i].ID == id then
            self.BtnList:RemoveAt(i)
            _succ = true
            break
        end
    end
    if _succ then
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATECUSTONBTNS)
    end
end
-- renew
function MainCustomBtnSystem:Update()
    local _remove = false
    for i = #self.BtnList, 1, -1 do
        local _btn = self.BtnList[i]
        if _btn.UseRemainTime and _btn:GetRemainTime() <= 0 then
            self.BtnList:RemoveAt(i)
            _remove = true
        end
    end

    if _remove then
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATECUSTONBTNS)
    end
end

return MainCustomBtnSystem