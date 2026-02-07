------------------------------------------------
--author:
--Date: 2021-02-25
--File: UIMainTopMenuPanel.lua
--Module: UIMainTopMenuPanel
--Description: Top menu pagination of main interface
------------------------------------------------
local L_UIMainSubBasePanel = require "UI.Forms.UIMainForm.UIMainSubBasePanel"
local L_ShowSCTime = 30 * 60

local UIMainTopMenuPanel = {
    CurState = MainTopMenuState.Hide,
    FuncBtnList = List:New(),
    MenuBtn = nil,
    MenuSprTrans = nil,
    MenuRes = nil,
    RedPoint = nil,
    FuncMenu = nil,
    BtnCount = 0,

    SCTips = nil,
    SCTrans = nil,
    SCRemainTime = nil,
    FrontSCUpdateTime = -1,
    BYSCTips = nil,
    BYSCTrans = nil,
}

function UIMainTopMenuPanel:OnRegisterEvents()
    self:RegisterEvent(LogicEventDefine.EID_EVENT_FUNCTION_UPDATE, self.OnFuncUpdated, self)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_ON_MAINMENU_OPEN, self.OnMainMenuOpen, self)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_ON_MAINMENU_CLOSE, self.OnMainMenuClose, self)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_FIRST_RECHAGE_TIPS, self.OnShowFirstRechargeTips, self)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_VIPRECHARGE_UPDATE, self.OnRechargeValueChanged, self)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_MONTH_CARD_TIPS, self.OnShowMonthCardTips, self)
end

local L_UIMainMenuButton = nil
local function L_SortFunc(left, right)
    return left.Cfg.FunctionSortNum < right.Cfg.FunctionSortNum
end

function UIMainTopMenuPanel:OnTryHide()
    if self.FuncMenu.IsVisible then
        self.FuncMenu:Close()
        return false
    end
    return true
end

function UIMainTopMenuPanel:OnFirstShow(trans, parent, rootForm)
    setmetatable(self, {__index = L_UIMainSubBasePanel.New()})
    self:BaseFirstShow(trans, parent, rootForm)

    local _rootTrans = UIUtils.FindTrans(trans, "Panel/Root")
    self.MenuRes = _rootTrans:GetChild(0).gameObject
    local _childCount = _rootTrans.childCount

    self.FuncBtnList:Clear()
    local _topList = GameCenter.MainFunctionSystem:GetFunctionList(1)
    local _count = _topList.Count
    for i = 1, _count do
        local _go = nil
        if i <= _childCount then
            _go = _rootTrans:GetChild(i - 1).gameObject
        else
            _go = UnityUtils.Clone(self.MenuRes)
        end
        self.FuncBtnList:Add(L_UIMainMenuButton:New(_go, _topList[i - 1], self))
    end
    self.FuncBtnList:Sort(L_SortFunc)
    self.BtnCount = #self.FuncBtnList
    self.MenuBtn = UIUtils.FindBtn(trans, "Panel/MenuBtn")
    self.MenuBtn.gameObject:SetActive(false)
    self.MenuSprTrans = UIUtils.FindTrans(trans, "Panel/MenuBtn/Sprite")
    self.RedPoint = UIUtils.FindGo(trans, "Panel/RedPoint")
    UIUtils.AddBtnEvent(self.MenuBtn, self.OnMenuBtnClick, self)

    self.FuncMenu = require "UI.Forms.UIMainForm.UIMainFunctionMenu"
    self.FuncMenu:OnFirstShow(UIUtils.FindTrans(trans, "Panel/Menu"), self, rootForm)

    self.SCTips = UIUtils.FindGo(trans, "Panel/SCTips")
    self.SCTrans = self.SCTips.transform
    self.SCRemainTime = UIUtils.FindLabel(trans, "Panel/SCTips/Desc")
    self.BYSCTips = UIUtils.FindGo(trans, "Panel/BYSCTips")
    self.BYSCTrans = self.BYSCTips.transform
    -- self.ShowBYSC = true
    self.ShowBYSC = false; --fix yy temporarily hides it, the first version of the 3-day battle force surge prompts that the upper right corner blocks the map
    self.SCTips:SetActive(false)
end

--After display
function UIMainTopMenuPanel:OnShowAfter()
    self:OnFuncUpdated(GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.TopFuncRoot))
    self:OnFuncUpdated(GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.RealmStifle))
    self:ShowAfterUpdate(true)
    self:OnRechargeValueChanged()
    self.MenuBtn.gameObject:SetActive(false)
    self.RedPoint.gameObject:SetActive(false)
end

--Play on effect
function UIMainTopMenuPanel:PlayNewFunctionEffect(funcID, hideIcon)
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_OPEN_MAINMENU)
    for i = 1, self.BtnCount do
        local _btn = self.FuncBtnList[i]
        if _btn.Cfg.FunctionId == funcID then
            _btn:PlayOpenEffect(hideIcon)
            return _btn.RootTrans
        end
    end
    return nil
end
function UIMainTopMenuPanel:OpenMenu()
    if self.CurState == MainTopMenuState.Show or self.CurState == MainTopMenuState.Showing then
        return
    end
    if GameCenter.GameSetting:IsEnabled(GameSettingKeyCode.EnableUIAnimation) then
        self:ChangeState(MainTopMenuState.Showing)
    else
        self:ChangeState(MainTopMenuState.Show)
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_ON_TOPMENU_OPEN)
end
function UIMainTopMenuPanel:CloseMenu()
    if self.CurState == MainTopMenuState.Hide or self.CurState == MainTopMenuState.Hide then
        return
    end

    if GameCenter.GameSetting:IsEnabled(GameSettingKeyCode.EnableUIAnimation) then
        self:ChangeState(MainTopMenuState.Hiding)
    else
        self:ChangeState(MainTopMenuState.Hide)
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_ON_TOPMENU_CLOSE)
    if self.FuncMenu.IsVisible then
        self.FuncMenu:Close()
    end
end
function UIMainTopMenuPanel:ShowAfterUpdate(isShow)
    for i = 1, self.BtnCount do
        self.FuncBtnList[i]:RefreshData()
    end
    self:UpdatePos()
    if isShow then
        self:ChangeState(MainTopMenuState.Show)
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_ON_TOPMENU_OPEN)
    else
        self:ChangeState(MainTopMenuState.Hide)
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_ON_TOPMENU_CLOSE)
    end
end
function UIMainTopMenuPanel:UpdatePos()
    local _indexHide = 0
    local _indexShow = 0
    local _index2Hide = 0
    local _index2Show = 0
    local _startX = 219
    local _startX2 = 289
    local _startY = 46
    local _startY2 = -21
    for i = 1, self.BtnCount do
        local _funcBtn = self.FuncBtnList[i]
        if _funcBtn.FuncVisible then
            local _sortNum = _funcBtn.Cfg.FunctionSortNum
            if _sortNum < 100 then
                _funcBtn.ShowPos = {_startX - _indexShow * 65, _startY}
                _indexShow = _indexShow + 1
                if _sortNum < 49 then
                    _funcBtn.HidePos = {_startX - _indexHide * 65, _startY}
                    _funcBtn.IsNeedHide = false
                    _indexHide = _indexHide + 1
                else
                    _funcBtn.HidePos = {_funcBtn.ShowPos[1] + 65, _funcBtn.ShowPos[2]}
                    _funcBtn.IsNeedHide = true
                end
            else
                _funcBtn.ShowPos = {_startX2 - _index2Show * 65, _startY2}
                _index2Show = _index2Show + 1

                if _sortNum < 149 then
                    _funcBtn.HidePos = {_startX2 - _index2Hide * 65, _startY2}
                    _funcBtn.IsNeedHide = false
                    _index2Hide = _index2Hide + 1
                else
                    _funcBtn.HidePos = {_funcBtn.ShowPos[1] + 65, _funcBtn.ShowPos[2]}
                    _funcBtn.IsNeedHide = true
                end
            end
        end
    end
end
function UIMainTopMenuPanel:OnMainMenuOpen(obj, sender)
    self:OpenMenu()
end
function UIMainTopMenuPanel:OnMainMenuClose(obj, sender)
    self:CloseMenu()
end
function UIMainTopMenuPanel:UpdateRedpoint()
    --self.RedPoint:SetActive((self.CurState == MainTopMenuState.Hide or self.CurState == MainTopMenuState.Hiding) and GameCenter.MainFunctionSystem:GetAlertFlag(FunctionStartIdCode.TopFuncRoot))
    self.RedPoint:SetActive(false)
end
function UIMainTopMenuPanel:OnFuncUpdated(funcInfo, sender)
    if funcInfo == nil then
        return
    end
    local _funcId = funcInfo.ID
    local _cfg = DataConfig.DataFunctionStart[_funcId]
    if _funcId == FunctionStartIdCode.TopFuncRoot then
        self:UpdateRedpoint()
    end
    if _cfg.FunctionPosType ~= 1 then
        return
    end
    local _btn = nil
    for i = 1, self.BtnCount do
        local _icon = self.FuncBtnList[i]
        if _icon.Cfg.FunctionId == _funcId then
            _btn = _icon
            break
        end
    end

    if _btn ~= nil then
        _btn:RefreshData()
        if UnityUtils.GetObjct2Int(funcInfo.CurUpdateType) == 1 then
            self:UpdatePos()
            self:ChangeState(self.CurState)
        end
    end
end
function UIMainTopMenuPanel:OnMenuBtnClick()
    if self.CurState == MainTopMenuState.Hide then
        self:OpenMenu()
    elseif self.CurState == MainTopMenuState.Show then
        self:CloseMenu()
    end
end
function UIMainTopMenuPanel:ChangeState(state)
    self.CurState = state
    self:UpdateRedpoint()
    if self.CurState == MainTopMenuState.Show then
        UnityUtils.SetLocalEulerAngles(self.MenuSprTrans, 0, 0, 180)
        for i = 1, self.BtnCount do
            local _btn = self.FuncBtnList[i]
            if _btn.FuncVisible then
                _btn:ChangeState(MainTopMenuState.Show)
            end
        end
    elseif self.CurState == MainTopMenuState.Showing then
        local _waitTime0 = 0
        local _waitTime1 = 0
        for i = 1, self.BtnCount do
            local _btn = self.FuncBtnList[i]
            if _btn.FuncVisible then
                if _btn.Cfg.FunctionSortNum < 100 then
                    _btn:ChangeState(MainTopMenuState.Showing, _waitTime0)
                    _waitTime0 = _waitTime0 + 0.05
                else
                    _btn:ChangeState(MainTopMenuState.Showing, _waitTime1)
                    _waitTime1 = _waitTime1 + 0.05
                end
            end
        end
    elseif self.CurState == MainTopMenuState.Hide then
        UnityUtils.SetLocalEulerAngles(self.MenuSprTrans, 0, 0, 0)
        for i = 1, self.BtnCount do
            local _btn = self.FuncBtnList[i]
            if _btn.FuncVisible then
                _btn:ChangeState(MainTopMenuState.Hide)
            end
        end
    elseif self.CurState == MainTopMenuState.Hiding then
        local _waitTime0 = 0
        local _waitTime1 = 0
        for i = 1, self.BtnCount do
            local _btn = self.FuncBtnList[i]
            if _btn.FuncVisible then
                if _btn.Cfg.FunctionSortNum < 100 then
                    _btn:ChangeState(MainTopMenuState.Hiding, _waitTime0)
                    _waitTime0 = _waitTime0 + 0.05
                else
                    _btn:ChangeState(MainTopMenuState.Hiding, _waitTime1)
                    _waitTime1 = _waitTime1 + 0.05
                end
            end
        end
    end
end
function UIMainTopMenuPanel:Update(dt)
    local _allShow = true
    local _allHide = true
    for i = 1, self.BtnCount do
        local _btn = self.FuncBtnList[i]
        if _btn.FuncVisible then
            _btn:Update(dt)
            if _btn.CurState ~= MainTopMenuState.Show then
                _allShow = false
            end
            if _btn.CurState ~= MainTopMenuState.Hide then
                _allHide = false
            end
        end
    end
    if self.CurState == MainTopMenuState.Show then
    elseif self.CurState == MainTopMenuState.Showing then
        if _allShow then
            self:ChangeState(MainTopMenuState.Show)
        end
    elseif self.CurState == MainTopMenuState.Hide then
    elseif self.CurState == MainTopMenuState.Hiding then
        if _allHide then
            self:ChangeState(MainTopMenuState.Hide)
        end
    end
    self.FuncMenu:Update(dt)

    if self.UpdateSCTime then
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if _lp ~= nil then
            local _onLineTime = _lp.PropMoudle.AllOnLineTime
            if _onLineTime < L_ShowSCTime then
                local _iTime = math.floor(L_ShowSCTime - _onLineTime)
                if self.FrontSCUpdateTime ~= _iTime then
                    self.FrontSCUpdateTime = _iTime
                    local _min = _iTime // 60
                    local _sec = _iTime % 60
                    UIUtils.SetTextByEnum(self.SCRemainTime, "C_SC_MAIN_TIPS", _min, _sec)
                end
            else
                self:OnRechargeValueChanged()
            end
        end
    end
end
function UIMainTopMenuPanel:OnShowFirstRechargeTips(obj, sender)
    if self.CurState == MainTopMenuState.Hide then
        self:OpenMenu()
    end
    for i = 1, self.BtnCount do
        local _btn = self.FuncBtnList[i]
        if _btn.Cfg.FunctionId == FunctionStartIdCode.FirstCharge then
            GameCenter.PushFixEvent(UIEventDefine.UIFirstChargeTipsForm_OPEN, _btn.RootTrans)
            break
        end
    end
end

function UIMainTopMenuPanel:OnShowMonthCardTips(obj, sender)
    for i = 1, self.BtnCount do
        local _btn = self.FuncBtnList[i]
        if _btn.Cfg.FunctionId == FunctionStartIdCode.Welfare then
            GameCenter.PushFixEvent(UILuaEventDefine.UIMonthCardTipsForm_OPEN, _btn.RootTrans)
            break
        end
    end
end

function UIMainTopMenuPanel:OnRechargeValueChanged(obj, sender)
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end
    self.UpdateSCTime = false
    local _scFuncVisible = GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.FirstCharge)
    if _scFuncVisible then
        local _onLineTime = _lp.PropMoudle.AllOnLineTime
        local _curRecharge = GameCenter.VipSystem.CurRecharge
        if _onLineTime < L_ShowSCTime then
            if _curRecharge <= 0 then
                --Display first charge
                --fix yy is temporarily hidden, the first charge is displayed in the first 30 minutes, blocking the map
                -- self.SCTips:SetActive(true)
                self.BYSCTips:SetActive(false)
                self.UpdateSCTime = true
                self.FrontSCUpdateTime = -1
            else
                --No display
                self.SCTips:SetActive(false)
                self.BYSCTips:SetActive(false)
            end
        else
            local _byId = GameCenter.FristChargeSystem.HundredIds[1]
            local _byCfg = DataConfig.DataRechargeAward[_byId]
            if _curRecharge < (_byCfg.NeedRecharge) then
                --Showing the top 100
                self.SCTips:SetActive(false)
                self.BYSCTips:SetActive(self.ShowBYSC)
            else
                --No display
                self.SCTips:SetActive(false)
                self.BYSCTips:SetActive(false)
            end
        end
    else
        --No display
        self.SCTips:SetActive(false)
        self.BYSCTips:SetActive(false)
    end
end

function UIMainTopMenuPanel:OnBYSCCloseBtnClick()
    self.BYSCTips:SetActive(false)
    self.ShowBYSC = false
end

local L_ANIM_TIME = 0.3
L_UIMainMenuButton = {
    --The object of the current button
    RootGo = nil,
    RootTrans = nil,
    RootWidget = nil,
    --Button Component
    Btn = nil,
    --Sprite component
    Icon = nil,
    --Text component
    Name = nil,
    --subtitle
    LittleName = nil,
    --Red dot
    RedPointGo = nil,
    --Effect object
    EffectGo = nil,
    --Button function information
    Data = nil,
    --The location displayed
    ShowPos = {0, 0},
    --Hidden location
    HidePos = nil,
    --Does it need to be hidden?
    IsNeedHide = false,
    --father
    Parent = nil,
    --Configuration
    Cfg = nil,
    --Current display status
    CurState = MainTopMenuState.Show,
    StartAlpha = 0,
    EndAlpha = 0,
    AnimTimer = 0,
    WaitTimer = 0,
    GetEffectTimer = -1,
    FuncVisible = false,
}
function L_UIMainMenuButton:New(go, data, parent)
    local _m = Utils.DeepCopy(self)
    _m.Parent = parent
    _m.RootGo = go
    _m.RootTrans = go.transform
    _m.Data = data
    local _trans = _m.RootTrans
    _m.RootWidget = UIUtils.FindWid(_trans)
    local _funcId = UnityUtils.GetObjct2Int(data.ID)
    _m.Cfg = DataConfig.DataFunctionStart[_funcId]
    _m.RootGo.name = tostring(_funcId)
    _m.Btn = UIUtils.FindBtn(_trans, "Btn")
    _m.Icon = UIUtils.FindSpr(_trans, "Btn/Icon")
    _m.Name = UIUtils.FindLabel(_trans, "Btn/Icon/Name")
    _m.RedPointGo = UIUtils.FindGo(_trans, "Btn/Icon/RedPoint")
    _m.EffectGo = UIUtils.FindGo(_trans, "Btn/Icon/Effect")
    _m.LittleName = UIUtils.FindLabel(_trans, "Btn/Icon/LittleName")
    UIUtils.AddBtnEvent(_m.Btn, _m.OnBtnClick, _m)
    _m:RefreshData()
    return _m
end
--Refresh the interface
function L_UIMainMenuButton:RefreshData()
    self.FuncVisible = self.Data.IsVisible
    if self.FuncVisible then
        self.Icon.spriteName = self.Data.Icon
        UIUtils.SetTextByStringDefinesID(self.Name, self.Cfg._FunctionName)
        local _littleText = self.Data.LittleName
        if _littleText ~= nil and string.len(_littleText) > 0 then
            UIUtils.SetTextByString(self.LittleName, _littleText)
            self.LittleName.gameObject:SetActive(true)
        else
            self.LittleName.gameObject:SetActive(false)
        end
        self.RedPointGo:SetActive(self.Data.IsShowRedPoint)
        self.EffectGo:SetActive(self.Data.IsEffectShow or (self.Data.IsEffectByAlert and self.Data.IsShowRedPoint))
    else
        self.RootGo:SetActive(false)
    end
    -- Whether to enable it is determined by btn
    if self.Btn.gameObject.activeSelf ~= self.FuncVisible then
        self.Btn.gameObject:SetActive(self.FuncVisible)
    end
end

function L_UIMainMenuButton:ChangeState(state, waitTime)
    self.CurState = state
    self.WaitTimer = waitTime
    if self.CurState ~= MainTopMenuState.Show and self.Parent.FuncMenu.CurRootFunc == self.Data then
        self.Parent.FuncMenu:Close()
    end
    if self.CurState == MainTopMenuState.Show then
        self.RootGo:SetActive(true)
        UnityUtils.SetLocalPosition(self.RootTrans, self.ShowPos[1], self.ShowPos[2], 0)
        self.RootWidget.alpha = 1
        self.AnimTimer = 0
    elseif self.CurState == MainTopMenuState.Showing then
        self.RootGo:SetActive(true)
        UnityUtils.SetLocalPosition(self.RootTrans, self.HidePos[1], self.HidePos[2], 0)
        if self.IsNeedHide then
            self.StartAlpha = 0
        else
            self.StartAlpha = 1
        end
        self.EndAlpha = 1
        self.RootWidget.alpha = self.StartAlpha
        self.AnimTimer = 0
    elseif self.CurState == MainTopMenuState.Hide then
        self.RootGo:SetActive(not self.IsNeedHide)
        UnityUtils.SetLocalPosition(self.RootTrans, self.HidePos[1], self.HidePos[2], 0)
        self.RootWidget.alpha = 1
        self.AnimTimer = 0
    elseif self.CurState == MainTopMenuState.Hiding then
        self.RootGo:SetActive(true)
        UnityUtils.SetLocalPosition(self.RootTrans, self.ShowPos[1], self.ShowPos[2], 0)
        self.StartAlpha = 1
        if self.IsNeedHide then
            self.EndAlpha = 0
        else
            self.EndAlpha = 1
        end
        self.RootWidget.alpha = self.StartAlpha
        self.AnimTimer = 0
    end
end
function L_UIMainMenuButton:UpdateState(dt)
    if self.CurState == MainTopMenuState.Show then
    elseif self.CurState == MainTopMenuState.Showing then
        if self.WaitTimer > 0 then
            self.WaitTimer = self.WaitTimer - dt
        end
        if self.WaitTimer <= 0 then
            self.AnimTimer = self.AnimTimer + dt
            if self.AnimTimer <= L_ANIM_TIME then
                local _lerpValue = self.AnimTimer / L_ANIM_TIME
                local _x = math.Lerp(self.HidePos[1], self.ShowPos[1], _lerpValue)
                local _y = math.Lerp(self.HidePos[2], self.ShowPos[2], _lerpValue)
                UnityUtils.SetLocalPosition(self.RootTrans, _x, _y, 0)
                self.RootWidget.alpha = math.Lerp(self.StartAlpha, self.EndAlpha, _lerpValue)
            else
                self:ChangeState(MainTopMenuState.Show)
            end
        end
    elseif self.CurState == MainTopMenuState.Hide then
    elseif self.CurState == MainTopMenuState.Hiding then
        if self.WaitTimer > 0 then
            self.WaitTimer = self.WaitTimer - dt
        end
        if self.WaitTimer <= 0 then
            self.AnimTimer = self.AnimTimer + dt
            if self.AnimTimer <= L_ANIM_TIME then
                local _lerpValue = self.AnimTimer / L_ANIM_TIME
                local _x = math.Lerp(self.ShowPos[1], self.HidePos[1], _lerpValue)
                local _y = math.Lerp(self.ShowPos[2], self.HidePos[2], _lerpValue)
                UnityUtils.SetLocalPosition(self.RootTrans, _x, _y, 0)
                self.RootWidget.alpha = math.Lerp(self.StartAlpha, self.EndAlpha, _lerpValue)
            else
                self:ChangeState(MainTopMenuState.Hide)
            end
        end
    end
end
--Play on effect
function L_UIMainMenuButton:PlayOpenEffect(hideIcon)
    if hideIcon then
        self.Icon.alpha = 0
        self.GetEffectTimer = 1.2
    end
end
--renew
function L_UIMainMenuButton:Update(dt)
    self:UpdateState(dt)
    if self.GetEffectTimer > 0 then
        self.GetEffectTimer = self.GetEffectTimer - dt
        if self.GetEffectTimer <= 0 then
            self.Icon.alpha = 1
        end
    end
end

--Click the button
function L_UIMainMenuButton:OnBtnClick()
    if self.Cfg.OpenMenu ~= 0 then
        self.Parent.FuncMenu:OpenMenu(self.Data, self.RootTrans.localPosition)
    else
        self.Data:OnClickHandler(nil)
    end
    local _funcId = self.Cfg.FunctionId
    if _funcId == FunctionStartIdCode.FirstCharge then
        self.Parent:OnBYSCCloseBtnClick()
    end
    --BI burial point
    if _funcId == FunctionStartIdCode.Arena then
        GameCenter.BISystem:ReqClickEvent(BiIdCode.ArenaMainEnter)
    elseif _funcId == FunctionStartIdCode.PlayerSkill then
        GameCenter.BISystem:ReqClickEvent(BiIdCode.SkillMainEnter)
    elseif _funcId == FunctionStartIdCode.Mount then
        GameCenter.BISystem:ReqClickEvent(BiIdCode.MountMainEnter)
    elseif _funcId == FunctionStartIdCode.NatureWing then
        GameCenter.BISystem:ReqClickEvent(BiIdCode.WingMainEnter)
    elseif _funcId == FunctionStartIdCode.Pet then
        GameCenter.BISystem:ReqClickEvent(BiIdCode.PetMainEnter)
    elseif _funcId == FunctionStartIdCode.RealmStifle then
        GameCenter.BISystem:ReqClickEvent(BiIdCode.FabaoMainEnter)
    elseif _funcId == FunctionStartIdCode.SoulMonsterCopy then
        GameCenter.BISystem:ReqClickEvent(BiIdCode.NSFYMainEnter)
    elseif _funcId == FunctionStartIdCode.ChuanDao then
        GameCenter.BISystem:ReqClickEvent(BiIdCode.ZMCDMainEnter)
    elseif _funcId == FunctionStartIdCode.FuDiBoss then
        GameCenter.BISystem:ReqClickEvent(BiIdCode.FDBossMainEnter)
    elseif _funcId == FunctionStartIdCode.DailyRechargeForm then
        GameCenter.BISystem:ReqClickEvent(BiIdCode.TotalRechargeMainEnter)
    end
end

return UIMainTopMenuPanel