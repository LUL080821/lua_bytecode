------------------------------------------------
-- author:
-- Date: 2021-02-26
-- File: UIFunctionFlyPanel.lua
-- Module: UIFunctionFlyPanel
-- Description: Functional icon flight interface
------------------------------------------------
local L_UIMainSubBasePanel = require "UI.Forms.UIMainForm.UIMainSubBasePanel"
local L_MaxMoveTime = 1.2
local L_AnimationCurve = CS.UnityEngine.AnimationCurve

local UIFunctionFlyPanel = {
    SkillIconRes = nil,
    SkillIconResList = List:New(),
    FuncIconRes = nil,
    FuncIconResList = List:New(),
    FlyIconList = List:New(),
    BackGo = nil,
}
-- Register Events
function UIFunctionFlyPanel:OnRegisterEvents()
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_ADDNEWFUNCTION_FLYICON, self.OnAddFlyIcon, self)
end

local L_UIFunctionFlyIcon = nil
function UIFunctionFlyPanel:OnFirstShow(trans, parent, rootForm)
    setmetatable(self, {__index = L_UIMainSubBasePanel.New()})
    self:BaseFirstShow(trans, parent, rootForm)
    self.SkillIconRes = UIUtils.FindGo(trans, "SkillIcon")
    self.SkillIconRes:SetActive(false)
    self.SkillIconResList:Clear()
    self.SkillIconResList:Add(self.SkillIconRes)
    self.FuncIconRes = UIUtils.FindGo(trans, "FuncIcon")
    self.FuncIconRes:SetActive(false)
    self.FuncIconResList:Clear()
    self.FuncIconResList:Add(self.FuncIconRes)
    self.BackGo = UIUtils.FindGo(trans, "Back")
end
-- After display
function UIFunctionFlyPanel:OnShowAfter()
    self.BackGo:SetActive(false)
end
function UIFunctionFlyPanel:OnAddFlyIcon(table, sender)
    local _iconType = table[1]
    local _dataID = table[2]
    local _iconName = table[3]
    local _iconParam = table[4]
    if not self:AddIcon(_iconType, _dataID, _iconName, _iconParam) then
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_NEWFUNCTION_CLOSE, _iconParam)
    end
end
function UIFunctionFlyPanel:AddIcon(type, dataID, iconName, iconParam)
    local _res = self:GetRes(type)
    if _res == nil then
       return false
    end
    _res:SetActive(false)
    if type == 0 then -- Skill Icon
        local _cfg = DataConfig.DataSkill[dataID]
        if _cfg == nil then
            return false
        end
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if _lp ~= nil and _lp.IsChangeModel then
            return false
        end
        local _skillForm = self.Parent.SubPanels[MainFormSubPanel.Skill]
        local _spr = UIUtils.FindSpr(_res.transform)
        _spr.spriteName = iconName
        local _flyIcon = L_UIFunctionFlyIcon:New(_res, self.Trans.position, _skillForm:PlayNewSkillEffect(_cfg.CellId % 100, true), iconParam)
        _res:SetActive(true)
        self.FlyIconList:Add(_flyIcon)
        if self.Parent.MainMenuIsOpen then
            self.Parent:OnCloseMainMenu(nil)
        end
        return true
    elseif type == 1 then -- Functional Icon
        local _cfg = DataConfig.DataFunctionStart[dataID]
        if _cfg == nil then
            return false
        end
        local _hideIcon = true
        local _custForm = self.Parent.SubPanels[MainFormSubPanel.CustomBtn]
        local _widget = _custForm:GetFlyFuncTrans(dataID)
        local _spr = UIUtils.FindSpr(_res.transform)
        if _widget ~= nil then
            _spr.spriteName = _cfg.MainIcon
            local _flyIcon = L_UIFunctionFlyIcon:New(_res, self.Trans.position, _widget.transform, iconParam)
            _flyIcon.TargetWidget = _widget
            _res:SetActive(true)
            self.FlyIconList:Add(_flyIcon)
            return true
        end

        if _cfg.FunctionPosType == 2 then
            -- Internal function to find parent node location
            local _parentCfg = self:FindParent(_cfg)
            if _parentCfg ~= nil then
                _cfg = _parentCfg
                _hideIcon = false
            end
        end
        if _cfg.FunctionPosType == 0 then
            local _menuPanel = self.Parent.MainMenuPanel
            local _targetTrans = _menuPanel:PlayNewFunctionEffect(_cfg.FunctionId, _hideIcon)
            _spr.spriteName = _cfg.MainIcon
            local _flyIcon = L_UIFunctionFlyIcon:New(_res, self.Trans.position, _targetTrans, iconParam)
            _res:SetActive(true)
            self.FlyIconList:Add(_flyIcon)
            return true
        elseif _cfg.FunctionPosType == 1 then
            local _topMenuForm = self.Parent.SubPanels[MainFormSubPanel.TopMenu]
            local _targetTrans = _topMenuForm:PlayNewFunctionEffect(_cfg.FunctionId, _hideIcon)
            _spr.spriteName = _cfg.MainIcon
            local _flyIcon = L_UIFunctionFlyIcon:New(_res, self.Trans.position, _targetTrans, iconParam)
            _res:SetActive(true)
            self.FlyIconList:Add(_flyIcon)
            return true
        end
        return false
    end
    return false
end

function UIFunctionFlyPanel:GetRes(type)
    if type == 0 then
        for i = 1, #self.SkillIconResList do
            if not self.SkillIconResList[i].activeSelf then
                return self.SkillIconResList[i]
            end
        end

        local _res = UnityUtils.Clone(self.SkillIconRes)
        self.SkillIconResList:Add(_res)
        return _res
    elseif type == 1 then
        for i = 1, #self.FuncIconResList do
            if not self.FuncIconResList[i].activeSelf then
                return self.FuncIconResList[i]
            end
        end

        local _res = UnityUtils.Clone(self.FuncIconRes)
        self.FuncIconResList:Add(_res)
        return _res
    end
    return nil
end
-- renew
function UIFunctionFlyPanel:Update(dt)
    if not self.IsVisible then
        return
    end
    local _activeCount = #self.FlyIconList
    if self.BackGo.activeSelf ~= (_activeCount > 0) then
        self.BackGo:SetActive(_activeCount > 0)
    end
    local _iconCount = #self.FlyIconList
    for i = _iconCount, 1, -1 do
        self.FlyIconList[i]:Update(dt)
        if self.FlyIconList[i]:IsFinish() then
            self.FlyIconList:RemoveAt(i)
        end
    end
end
function UIFunctionFlyPanel:FindParent(cfg)
    local _result = DataConfig.DataFunctionStart[cfg.ParentId]
    if _result == nil then
        return cfg
    end
    if _result.ParentId == 1 or _result.ParentId == 2 then
        return _result
    end
    return self:FindParent(_result)
end

local L_MoveCurve = nil
local L_StartScale = 1.5
local L_EndScale = 1

L_UIFunctionFlyIcon = {
    RootGo = nil,
    TargetWidget = nil,
    RootTans = nil,
    StartPosX = 0,
    StartPosY = 0,
    EndTrans = nil,
    MoveTimer = 0,
    IconParam = nil,
}

function L_UIFunctionFlyIcon:IsFinish()
    return not self.RootGo.activeSelf
end
function L_UIFunctionFlyIcon:New(rootGo, startPos, endTrans, iconParam)
    local _m = Utils.DeepCopy(self)
    _m.RootGo = rootGo
    _m.RootGo:SetActive(true)
    _m.RootTans = rootGo.transform
    _m.StartPosX = startPos.x
    _m.StartPosY = startPos.y
    _m.EndTrans = endTrans
    _m.MoveTimer = 0
    _m.IconParam = iconParam

    if L_MoveCurve == nil then
        L_MoveCurve = L_AnimationCurve()
        L_MoveCurve:AddKey(0, 0)
        L_MoveCurve:AddKey(0.537, 0.214)
        L_MoveCurve:AddKey(1, 1)
    end
    return _m
end

function L_UIFunctionFlyIcon:Update(dt)
    if not self.RootGo.activeSelf then
        return
    end
    self.MoveTimer = self.MoveTimer + dt
    if self.MoveTimer <= L_MaxMoveTime then
        local _lerpValue = L_MoveCurve:Evaluate(self.MoveTimer  / L_MaxMoveTime)
        local _endPos = self.EndTrans.position
        local _x = math.Lerp(self.StartPosX, _endPos.x, _lerpValue)
        local _y = math.Lerp(self.StartPosY, _endPos.y, _lerpValue)
        UnityUtils.SetPosition(self.RootTans, _x, _y, 0)

        local _scale = math.Lerp(L_StartScale, L_EndScale, _lerpValue)
        UnityUtils.SetLocalScale(self.RootTans, _scale, _scale, _scale)
        if self.TargetWidget ~= nil then
            self.TargetWidget.alpha = 0
        end
    else
        local _endPos = self.EndTrans.position
        UnityUtils.SetPosition(self.RootTans, _endPos.x, _endPos.y, 0)
        self.RootGo:SetActive(false)
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_NEWFUNCTION_CLOSE, self.IconParam)
        if self.TargetWidget ~= nil then
            self.TargetWidget.alpha = 1
        end
    end
end

return UIFunctionFlyPanel