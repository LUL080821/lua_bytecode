------------------------------------------------
-- author:
-- Date: 2021-02-25
-- File: UIMainMenuPanel.lua
-- Module: UIMainMenuPanel
-- Description: Main interface menu pagination
------------------------------------------------
local L_UIMainSubBasePanel = require "UI.Forms.UIMainForm.UIMainSubBasePanel"
local MainFunctionSystem = CS.Thousandto.Code.Logic.MainFunctionSystem

local UIMainMenuPanel = {
    ButtonList = List:New(),
    BtnCount = 0,
    BackTex = nil,
    Lines = nil,
}

function UIMainMenuPanel:OnRegisterEvents()
    self:RegisterEvent(LogicEventDefine.EID_EVENT_FUNCTION_UPDATE, self.OnFuncUpdated, self)
end

local L_UIMainMenuButton = nil
local function L_SortFunc(left, right)
    return left.Cfg.FunctionSortNum < right.Cfg.FunctionSortNum
end

function UIMainMenuPanel:OnFirstShow(trans, parent, rootForm)
    setmetatable(self, {__index = L_UIMainSubBasePanel.New()})
    self:BaseFirstShow(trans, parent, rootForm)

    self.AnimModule:AddAlphaAnimation()
    local _resGo = nil
    local _rootTrans = UIUtils.FindTrans(trans, "Root")
    local _childCount = _rootTrans.childCount
    _resGo = _rootTrans:GetChild(0).gameObject
    local _topList = GameCenter.MainFunctionSystem:GetFunctionList(0)
    local _count = _topList.Count
    self.ButtonList:Clear()
    for i = 1, _count do
        local _go = nil
        if i <= _childCount then
            _go = _rootTrans:GetChild(i - 1).gameObject
        else
            _go = UnityUtils.Clone(_resGo)
        end
        self.ButtonList:Add(L_UIMainMenuButton:New(_go, _topList[i - 1]))
    end
    self.ButtonList:Sort(L_SortFunc)
    self.BtnCount = #self.ButtonList
    self.Lines = {}
    for i = 1, 5 do
        self.Lines[i] = UIUtils.FindGo(trans, string.format("Sprite/%d", i - 1))
    end
end

-- After display
function UIMainMenuPanel:OnShowAfter()
    for i = 1, self.BtnCount do
        self.ButtonList[i]:RefreshData()
    end
    MainFunctionSystem.MainMenuIsShowed = true
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_CANEL_MAINHANDLE)
    self:UpdateIconPos()
    local _index = 0
    for i = 1, self.BtnCount do
        local _icon = self.ButtonList[i]
        self.AnimModule:RemoveTransAnimation(_icon.RootTrans)
        if _icon.IsVisible then
            self.AnimModule:AddAlphaPosAnimation(_icon.RootTrans, 0, 1, 60, 0, 0.2 + 0.05 * ((_index) % 6), false, true)
            self.AnimModule:PlayShowAnimation(_icon.RootTrans)
            _index = _index + 1
        end
    end
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_ON_MAINMENU_OPEN)
    -- Actively call the red dot of the check guild main button
    GameCenter.GuildSystem:CheckMainGuildBtnRedPoint()
end
function UIMainMenuPanel:OnHideBefore()
    MainFunctionSystem.MainMenuIsShowed = false
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_ON_MAINMENU_CLOSE)
end
-- Playback function to turn on animation
function UIMainMenuPanel:PlayNewFunctionEffect(funcID, hideIcon)
    if not self.IsVisible then
        -- Hidden, open the interface
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_OPEN_MAINMENU)
    end
    self:UpdateIconPos()
    for i = 1, self.BtnCount do
        if self.ButtonList[i].Cfg.FunctionId == funcID then
            self.ButtonList[i]:PlayOpenEffect(hideIcon)
            return self.ButtonList[i].RootTrans
        end
    end
    return nil
end
function UIMainMenuPanel:OnFuncUpdated(funcInfo, sender)
    if funcInfo == nil then
        return
    end
    local _funcId = funcInfo.ID
    local _cfg = DataConfig.DataFunctionStart[_funcId]
    if _cfg == nil or _cfg.FunctionPosType ~= 0 then
        return
    end
    local _btn = nil
    for i = 1, self.BtnCount do
        local _icon = self.ButtonList[i]
        if _icon.Cfg.FunctionId == _funcId then
            _btn = _icon
            break
        end
    end
   
    if _btn ~= nil then
        _btn:RefreshData()
        self:UpdateIconPos()
    end
end
function UIMainMenuPanel:UpdateIconPos()
    local _startX = -39
    local _startY = 64
    local _index = 0
    local _y = 0
    local _x = 0
    local _yPos = _startX
    local _xPos = _startY
    for i = 1, self.BtnCount do
        local _icon = self.ButtonList[i]
        if _icon.IsVisible then
            y = _icon.Cfg.FunctionSortNum // 10
            x = _icon.Cfg.FunctionSortNum % 10

            _yPos = _startY + y*76
            _xPos = _startX - x*71

            UnityUtils.SetLocalPosition(_icon.RootTrans, _xPos, _yPos, 0)
        end
    end

    for i = 1, #self.Lines do
        self.Lines[i]:SetActive(i < _index)
    end
end

function UIMainMenuPanel:Update(dt)
    for i = 1, self.BtnCount do
        self.ButtonList[i]:Update(dt)
    end
end

L_UIMainMenuButton = {
    RootGo = nil,      -- The object of the current button
    RootTrans = nil,    -- The object of the current button
    Btn = nil,           -- Button Component
    Icon = nil,          -- Sprite Components
    Name = nil,   -- name
    RedPointGo = nil,  -- Red dot
    EffectGo = nil,    -- Effect object
    Data = nil,   -- Function information of buttons
    Cfg = nil,
    GetEffectTimer = -1,
    IsVisible = false,
}

function L_UIMainMenuButton:New(go, data)
    local _m = Utils.DeepCopy(self)
    _m.RootGo = go
    local _trans = go.transform
    _m.RootTrans = _trans
    _m.Data = data
    _m.Btn = UIUtils.FindBtn(_trans)
    _m.Icon = UIUtils.FindSpr(_trans, "Icon")
    _m.Name = UIUtils.FindLabel(_trans, "Icon/Name")
    _m.RedPointGo = UIUtils.FindGo(_trans, "Icon/RedPoint")
    _m.EffectGo = UIUtils.FindGo(_trans, "Icon/Effect")
    UIUtils.AddBtnEvent(_m.Btn, _m.OnBtnClick, _m)
    local _funcId = UnityUtils.GetObjct2Int(data.ID)
    _m.Cfg = DataConfig.DataFunctionStart[_funcId]
    UIUtils.SetTextByStringDefinesID(_m.Name, _m.Cfg._FunctionName)
    _m.Icon.spriteName = _m.Cfg.MainIcon
    _m.RootGo.name = tostring(_funcId)
    _m:RefreshData()
    return _m
end

-- Refresh the interface
function L_UIMainMenuButton:RefreshData()
    if self.Data.IsVisible then
        self.RedPointGo:SetActive(self.Data.IsShowRedPoint)
        self.EffectGo:SetActive(self.Data.IsEffectShow or (self.Data.IsEffectByAlert and self.Data.IsShowRedPoint))
        self.RootGo:SetActive(true)
        self.IsVisible = true
    else
        self.RootGo:SetActive(false)
        self.GetEffectTimer = -1
        self.Icon.alpha = 1
        self.IsVisible = false
    end
end

-- Playback effect
function L_UIMainMenuButton:PlayOpenEffect(hideIcon)
    if hideIcon then
        self.GetEffectTimer = 1.2
        self.Icon.alpha = 0
    end
end
     
function L_UIMainMenuButton:OnBtnClick()
    self.Data:OnClickHandler(nil)
end

function L_UIMainMenuButton:Update(dt)
    if not self.IsVisible then
        return
    end
    if self.GetEffectTimer > 0 then
        self.GetEffectTimer = self.GetEffectTimer - dt
        if self.GetEffectTimer <= 0 then
            self.GetEffectTimer = -1
            self.Icon.alpha = 1
        end
    end
end

return UIMainMenuPanel