------------------------------------------------
-- author:
-- Date: 2021-04-02
-- File: UIChatInsertExpPanel.lua
-- Module: UIChatInsertExpPanel
-- Description: Chat insert emoji panel
------------------------------------------------

local L_UIMainSubBasePanel = require "UI.Forms.UIMainForm.UIMainSubBasePanel"
local L_Expression1 = "#%02d"         -- Static expression
local L_Expression2 = "@%02d_%d"     -- Dynamic expressions, always loop
local L_Expression3 = "^%02d_%d"     -- Dynamic expressions, only play once
local L_Expression1Big = "##%02d"     -- Static expression
local L_Expression2Big = "@@%02d_%d" -- Dynamic expressions, always loop
local L_Expression3Big = "^^%02d_%d" -- Dynamic expressions, only play once

local UIChatInsertExpPanel = {
    ScrollView = nil,
    Grid = nil,
    ExpList = nil,
    Res = nil,
}

local L_ExpItem = nil

function UIChatInsertExpPanel:OnFirstShow(trans, parent, rootForm)
    setmetatable(self, {__index = L_UIMainSubBasePanel.New()})
    self:BaseFirstShow(trans, parent, rootForm)

    self.Res = nil
    self.ScrollView = UIUtils.FindScrollView(trans, "ScrollView")
    self.Grid = UIUtils.FindGrid(trans, "ScrollView/Grid")
    local _parentTrans = self.Grid.transform
    local _childCount = _parentTrans.childCount
    self.ExpList = List:New()
    local _atlas = nil
    for i = 1, _childCount do
        local _childTrans = _parentTrans:GetChild(i - 1)
        if self.Res == nil then
            self.Res = _childTrans.gameObject
        end 
        if _spriteList == nil then
            local _spr = UIUtils.FindSpr(_childTrans)
            if _spr ~= nil then
                _atlas = _spr.atlas
            end
        end
        self.ExpList:Add(L_ExpItem:New(_childTrans, self))
    end
    if _atlas ~= nil then
        local _curIndex = 1
        _curIndex = self:FillExp(L_Expression1, _atlas, false, false, _curIndex)
        _curIndex = self:FillExp(L_Expression2, _atlas, true,  false, _curIndex)
        _curIndex = self:FillExp(L_Expression3, _atlas, true, false, _curIndex)
        _curIndex = self:FillExp(L_Expression1Big, _atlas, false, true, _curIndex)
        _curIndex = self:FillExp(L_Expression2Big, _atlas, true, true, _curIndex)
        _curIndex = self:FillExp(L_Expression3Big, _atlas, true, true, _curIndex)
        for i = _curIndex, #self.ExpList do 
            self.ExpList[i]:SetInfo(nil)
        end
    end
    return self
end

function UIChatInsertExpPanel:OnShowAfter()
    self.Grid:Reposition()
    self.ScrollView:ResetPosition()
end

function UIChatInsertExpPanel:FillExp(expFormat, atlas, haveAnim, clickClose, curIndex)
    for i = 1, 100 do
        if haveAnim then
            local _frameIndex = 1
            local _frameList = nil
            while true do
                local _sprName = string.format(expFormat, i, _frameIndex)
                if atlas:GetSprite(_sprName) ~= nil then
                    if _frameList == nil then
                        _frameList = List:New()
                    end
                    _frameList:Add(_sprName)
                else
                    break
                end
                _frameIndex = _frameIndex + 1
            end

            if _frameList ~= nil then
                local _expUI = nil
                if curIndex <= #self.ExpList then
                    _expUI = self.ExpList[curIndex]
                else
                    _expUI = L_ExpItem:New(UnityUtils.Clone(self.Res).transform, self)
                    self.ExpList:Add(_expUI)
                end
                curIndex = curIndex + 1
                _expUI:SetInfo(true, _frameList, clickClose)
            end
        else
            local _sprName = string.format(expFormat, i)
            if atlas:GetSprite(_sprName) ~= nil then
                local _expUI = nil
                if curIndex <= #self.ExpList then
                    _expUI = self.ExpList[curIndex]
                else
                    _expUI = L_ExpItem:New(UnityUtils.Clone(self.Res).transform, self)
                    self.ExpList:Add(_expUI)
                end
                curIndex = curIndex + 1
                _expUI:SetInfo(false, _sprName, clickClose)
            end
        end
    end

    return curIndex
end

function UIChatInsertExpPanel:Update(dt)
    for i = 1, #self.ExpList do
        self.ExpList[i]:Update(dt)
    end
end

L_ExpItem = {
    Go = nil,
    Trans = nil,
    Spr = nil,
    Btn = nil,
    HaveAnim = nil,
    Params = nil,
    FrameTimer = 0.0,
    CurFrameIndex = 0,
    FrameCount = 0,
    ClickClose = nil,
}

function L_ExpItem:New(trans, parent)
    local _m = Utils.DeepCopy(self)
    _m.Go = trans.gameObject
    _m.Trans = trans
    _m.Parent = parent
    _m.Spr = UIUtils.FindSpr(trans)
    _m.Btn = UIUtils.FindBtn(trans)
    UIUtils.AddBtnEvent(_m.Btn, _m.OnClick, _m)
    return _m
end

function L_ExpItem:SetInfo(haveAnim, params, clickClose)
    self.HaveAnim = haveAnim
    self.Params = params
    self.FrameTimer = 0
    self.ClickClose = clickClose
    if haveAnim == nil then
        self.Go:SetActive(false)
    else
        if haveAnim then
            self.CurFrameIndex = 1
            self.FrameCount = #params
            self.Spr.spriteName = params[self.CurFrameIndex]
        else
            self.Spr.spriteName = params
        end
        self.Go:SetActive(true)
    end
end

function L_ExpItem:OnClick()
    if self.HaveAnim then
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_CHAT_INSERT_EXPRESSION, self.Params[1])
    else
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_CHAT_INSERT_EXPRESSION, self.Params)
    end
    if self.ClickClose then
        self.Parent.Parent:OnClose(nil)
    end
end

function L_ExpItem:Update(dt)
    if self.HaveAnim then
        self.FrameTimer = self.FrameTimer + dt
        if self.FrameTimer >= 0.3 then
            self.CurFrameIndex = self.CurFrameIndex + 1
            if self.CurFrameIndex > self.FrameCount then
                self.CurFrameIndex = 1
            end
            self.Spr.spriteName = self.Params[self.CurFrameIndex]
            self.FrameTimer = self.FrameTimer - 0.3
        end
    end
end

return UIChatInsertExpPanel