------------------------------------------------
-- author:
-- Date: 2021-02-26
-- File: UIMainLPBuffPanel.lua
-- Module: UIMainLPBuffPanel
-- Description: Main interface player buff list pagination
------------------------------------------------

local L_UIMainSubBasePanel = require "UI.Forms.UIMainForm.UIMainSubBasePanel"

local UIMainLPBuffPanel = {
    CloseBtn = nil,
    ScrollView = nil,
    Grid = nil,
    Res = nil,
    ResList = List:New(),
    OldBuffCount = -1,
    NotBuff = nil,
}

local L_UIBuffIcon = nil
function UIMainLPBuffPanel:OnFirstShow(trans, parent, rootForm)
    setmetatable(self, {__index = L_UIMainSubBasePanel.New()})
    self:BaseFirstShow(trans, parent, rootForm)
    self.CloseBtn = UIUtils.FindBtn(trans, "CloseBtn")
    UIUtils.AddBtnEvent(self.CloseBtn, self.OnCloseBtnClick, self)
    self.ScrollView = UIUtils.FindScrollView(trans, "ScrollView")
    self.Grid = UIUtils.FindGrid(trans, "ScrollView/Grid")
    local _rootTrans = self.Grid.transform
    local _childCount = _rootTrans.childCount
    self.Res = nil
    self.ResList:Clear()
    for i = 1, _childCount do
        local _childTrans = _rootTrans:GetChild(i - 1)
        if self.Res == nil then
            self.Res = _childTrans.gameObject
        end
        local _item = L_UIBuffIcon:New(_childTrans.gameObject)
        self.ResList:Add(_item)
    end
    self.NotBuff = UIUtils.FindGo(trans, "NotBuff")
    self.AnimModule:AddAlphaScaleAnimation(nil, 0, 1, 0, 0, 1, 1, 0.3)
end
function UIMainLPBuffPanel:OnShowAfter()
    self.OldBuffCount = -1
    self.ScrollView:ResetPosition()
    self:UpdateBuff()
    UnityUtils.SetLayer(self.Trans, LayerUtils.UITop, true)
end

function UIMainLPBuffPanel:GetBuffList()
    local _result = List:New()
    local _buffList = GameCenter.BuffSystem.LpBuffList
    local _buffCount = _buffList.Count
    for i = 1, _buffCount do
        local _buff = _buffList[i - 1]
        local _cfg = DataConfig.DataBuff[_buff.DataID]
        if _cfg ~= nil and _cfg.IfShow == 0 then
            _result:Add(_buff)
        end
    end
    return _result
end

function UIMainLPBuffPanel:UpdateBuff()
    local _newCount = 0
    local _buffList = self:GetBuffList()
    local _count = #_buffList
    if _count <= 0 then
        for i = 1, #self.ResList do
            self.ResList[i]:SetInfo(nil)
        end
        _newCount = 0
    else
        for i = 1, _count do
            local _icon = nil
            if i <= #self.ResList then
                _icon = self.ResList[i]
            else
                _icon = L_UIBuffIcon:New(UnityUtils.Clone(self.Res))
                self.ResList:Add(_icon)
            end
            _icon:SetInfo(_buffList[i])
        end
        for i = _count + 1, #self.ResList do
            self.ResList[i]:SetInfo(nil)
        end
        _newCount = _count
    end
    if self.OldBuffCount ~= _newCount then
        self.OldBuffCount = _newCount
        self.Grid:Reposition()
    end
    if self.NotBuff.activeSelf ~= (_newCount <= 0) then
        self.NotBuff:SetActive(_newCount <= 0)
    end
end
function UIMainLPBuffPanel:Update(dt)
    if not self.IsVisible then
        return
    end
    for i = 1, #self.ResList do
        self.ResList[i]:Update()
    end
    -- Updated once in 10 frames
    if Time.GetFrameCount() % 10 ~= 0 then
        return
    end
    self:UpdateBuff()
end
function UIMainLPBuffPanel:OnCloseBtnClick()
    self:Close()
end

L_UIBuffIcon = {
    Go = nil,
    Trans = nil,
    Icon = nil,
    Time = nil,
    Desc = nil,
    Level = nil,
    Buff = nil,
    Cfg = nil,
    FrontUpdateTime = -1,
    FrontUpdateLevel = -1,
}

function L_UIBuffIcon:New(go)
    local _m = Utils.DeepCopy(self)
    _m.Go = go
    _m.Trans = go.transform
    _m.Icon = UIUtils.RequireUIIcon(UIUtils.FindTrans(_m.Trans, "Back"))
    _m.Time = UIUtils.FindLabel(_m.Trans, "Back/Time")
    _m.Desc = UIUtils.FindLabel(_m.Trans, "Back/Desc")
    _m.Level = UIUtils.FindLabel(_m.Trans, "Back/Level")
    return _m
end

function L_UIBuffIcon:SetInfo(buff)
    self.Buff = buff
    if buff ~= nil then
        self.Cfg = DataConfig.DataBuff[buff.DataID]
        self.Icon:UpdateIcon(self.Cfg.Icon)
        UIUtils.SetTextByStringDefinesID(self.Desc, self.Cfg._Desc)
        self.FrontUpdateTime = -1
        self.FrontUpdateLevel = -1
        self:Update()
        self.Go:SetActive(true)
    else
        self.Go:SetActive(false)
    end
end
function L_UIBuffIcon:Update()
    if self.Buff == nil then
        return
    end
    local _curTime = math.floor(self.Buff.CurRemainTime)
    if _curTime ~= self.FrontUpdateTime then
        self.FrontUpdateTime = _curTime
        -- Unlimited time
        if _curTime < 0 then
            UIUtils.ClearText(self.Time)
        elseif _curTime >= 3600 then
            UIUtils.SetTextFormat(self.Time, "{0}h", _curTime // 3600)
        elseif _curTime >= 60 then
            UIUtils.SetTextFormat(self.Time, "{0}m", _curTime // 60)
        else
            UIUtils.SetTextFormat(self.Time, "{0}s", _curTime)
        end
    end
    if self.FrontUpdateLevel ~= self.Buff.CurLevel then
        self.FrontUpdateLevel = self.Buff.CurLevel
        if self.FrontUpdateLevel > 1 then
            UIUtils.SetTextFormat(self.Level, "{0}s", self.FrontUpdateLevel)
        else
            UIUtils.ClearText(self.Level)
        end
    end
end

return UIMainLPBuffPanel