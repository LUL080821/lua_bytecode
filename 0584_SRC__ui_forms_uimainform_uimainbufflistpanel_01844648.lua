------------------------------------------------
-- author:
-- Date: 2021-02-27
-- File: UIMainBuffListPanel.lua
-- Module: UIMainBuffListPanel
-- Description: Main interface experience bar
------------------------------------------------

local L_UIMainSubBasePanel = require "UI.Forms.UIMainForm.UIMainSubBasePanel"

local UIMainBuffListPanel = {
    Grid = nil,
    BuffList = List:New(),
    OwnerID = 0,
    OldBuffCount = -1,
}
local L_UIBuffIcon = nil
function UIMainBuffListPanel:OnFirstShow(trans, parent, rootForm)
    setmetatable(self, {__index = L_UIMainSubBasePanel.New()})
    self:BaseFirstShow(trans, parent, rootForm)

    self.Grid = UIUtils.FindGrid(trans, "Grid")
    local _rootTrans = self.Grid.transform
    local _childCount = _rootTrans.childCount
    self.BuffList:Clear()
    for i = 1, _childCount do
        self.BuffList:Add(L_UIBuffIcon:New(self, _rootTrans:GetChild(i - 1).gameObject))
    end
end
function UIMainBuffListPanel:OpenList(owner)
    self.OwnerID = owner
    self:Open()
end

function UIMainBuffListPanel:Update(dt)
    if not self.IsVisible then
        return
    end
    -- Updated once in 10 frames
    if Time.GetFrameCount() % 10 ~= 0 then
        return
    end

    local _buffList = GameCenter.BuffSystem:FindBuffList(self.OwnerID)
    local _count = 0
    if _buffList ~= nil then
        _count = _buffList.Count
    end
    for i = 1, #self.BuffList do
        if i < (_count + 1) then
            self.BuffList[i]:SetInfo(_buffList[i - 1])
            self.BuffList[i]:Update()
        else
            self.BuffList[i]:SetInfo(nil)
        end
    end
    if self.OldBuffCount ~= _count then
        self.OldBuffCount = _count
        self.Grid:Reposition()
    end
end

L_UIBuffIcon = {
    Parent = nil,
    RootGo = nil,
    Icon = nil,
    Time = nil,
    Level = nil,
    Btn = nil,
    BuffInst = nil,
    FrontUpdateTime = -1,
    FrontUpdateLevel = -1,
}

function L_UIBuffIcon:New(parent, rootGo)
    local _m = Utils.DeepCopy(self)
    _m.Parent = parent
    _m.RootGo = rootGo
    local _trans = rootGo.transform
    _m.Icon = UIUtils.RequireUIIcon(_trans)
    _m.Time = UIUtils.FindLabel(_trans, "Time")
    _m.Level = UIUtils.FindLabel(_trans, "Level")
    _m.Btn = UIUtils.FindBtn(_trans)
    UIUtils.AddBtnEvent(_m.Btn, _m.OnClick, _m)
    rootGo:SetActive(false)
    return _m
end
function L_UIBuffIcon:SetInfo(buff)
    if self.BuffInst == buff then
        return
    end
    self.FrontUpdateTime = -1
    self.FrontUpdateLevel = -1
    self.BuffInst = buff
    if buff == nil then
        self.RootGo:SetActive(false)
    else
        self.RootGo:SetActive(true)
        self.Icon:UpdateIcon(buff.Cfg.Icon)
    end
end
function L_UIBuffIcon:Update()
    if self.BuffInst == nil then
        return
    end

    local _curTime = math.floor(self.BuffInst.CurRemainTime)
    if _curTime ~= self.FrontUpdateTime then
        self.FrontUpdateTime = _curTime
        
        if _curTime < 0 then-- Unlimited time
            UIUtils.ClearText(self.Time)
        elseif _curTime >= 3600 then-- More than one hour, displayed as hour
            UIUtils.SetTextFormat(self.Time, "{0}h", _curTime // 3600)
        elseif _curTime >= 60 then-- More than 1 minute, displayed as minutes
            UIUtils.SetTextFormat(self.Time, "{0}m", _curTime // 60)
        else
            UIUtils.SetTextFormat(self.Time, "{0}s", _curTime)
        end
    end

    local _level = self.BuffInst.CurLevel
    if self.FrontUpdateLevel ~= _level then
        self.FrontUpdateLevel = _level
        if _level > 1 then
            UIUtils.SetTextByNumber(self.Level, _level)
        else
            UIUtils.ClearText(self.Level)
        end
    end
end
function L_UIBuffIcon:OnClick()
    if self.BuffInst ~= nil then
        GameCenter.PushFixEvent(UIEventDefine.UIBuffTipsForm_OPEN, self.BuffInst.DataID)
    end
end

return UIMainBuffListPanel