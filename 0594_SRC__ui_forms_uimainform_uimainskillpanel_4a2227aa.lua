------------------------------------------------
-- author:
-- Date: 2021-02-26
-- File: UIMainSkillPanel.lua
-- Module: UIMainSkillPanel
-- Description: Main interface skill pagination
------------------------------------------------
local L_UIMainSubBasePanel = require "UI.Forms.UIMainForm.UIMainSubBasePanel"
local L_MaxSelectUIDis = 90
local L_CombatUtil = CS.Thousandto.Code.Logic.CombatUtil
local L_Color = CS.UnityEngine.Color
local L_NGUIMath = CS.NGUIMath
local L_UICamera = CS.UICamera
local L_SkillSelectFiledType = CS.Thousandto.Code.Logic.SkillSelectFiledType
local L_Vector2 = CS.UnityEngine.Vector2
local L_Vector3 = CS.UnityEngine.Vector3
local L_Mathf = CS.UnityEngine.Mathf
local L_MathLib = CS.Thousandto.Core.Base.MathLib

local UIMainSkillPanel = {
    RollDogeBtn = nil,
    RollCDValue = nil,
    RollCDSpr = nil,
    FrontUpdateCd = -1,
    ChangeTargetBtn = nil,
    SelectHisTable = Dictionary:New(),
    FirstGo = nil,
    SecondGo = nil,
    SkillIcons = nil,
    UseSelectGo = nil,
    UseSelectRoot = nil,
    UseSelectBar = nil,
    UseSelectPos = nil,
    CanelWidget = nil,
    CanelRect = nil,
    UseSelectTouchID = 0,
    FlySwordSkillGo = nil,
    FlySwordSkilIcon = nil,
    FlySwordSkilCdSpr = nil,
    FlySwordLightTrans = nil,
    FlySwordVfx = nil,
    FlySwordSkillBtn = nil,
    SwitchBtn = nil,
    CurIndex = -1,
}
-- Register Events
function UIMainSkillPanel:OnRegisterEvents()
    -- Skill list changes
    self:RegisterEvent(LogicEventDefine.EID_EVENT_SKILL_LIST_CHANGED, self.UpdateSkillList, self)
    -- Change of skill stiffness state
    self:RegisterEvent(LogicEventDefine.EID_EVENT_SKILLSTIFFSTATE_CHANGED, self.UpdateSkillStiffState, self)
    -- Other UIs open
    self:RegisterEvent(LogicEventDefine.EID_EVENT_FORM_SHOW_AFTER, self.OnFormOpen, self)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_CANEL_MAINHANDLE, self.OnCanelHandle, self)
    -- Flying Sword Skill Refresh
    self:RegisterEvent(LogicEventDefine.EID_EVENT_FLYSWORD_SKILL_UPDATE, self.OnUpdateFlySwordSkill, self)
end
local L_UIMainSkillIcon = nil

function UIMainSkillPanel:OnFirstShow(trans, parent, rootForm)
    setmetatable(self, {__index = L_UIMainSubBasePanel.New()})
    self:BaseFirstShow(trans, parent, rootForm)
    self.RollDogeBtn = UIUtils.FindBtn(trans, "FanGun")
    UIUtils.AddBtnEvent(self.RollDogeBtn, self.OnRollDogeBtnClick, self)
    self.RollCDValue = UIUtils.FindLabel(trans, "FanGun/CdValue")
    self.RollCDSpr = UIUtils.FindSpr(trans, "FanGun/CDSpr")
    self.ChangeTargetBtn = UIUtils.FindBtn(trans, "ChangeTarget")
    UIUtils.AddBtnEvent(self.ChangeTargetBtn, self.OnChangeTargetBtnClick, self)
    self.FirstGo = UIUtils.FindGo(trans, "First")
    self.SecondGo = UIUtils.FindGo(trans, "Second")
    self.SkillIcons = {}
    self.SkillIcons[1] = L_UIMainSkillIcon:New(self, UIUtils.FindGo(trans, "Skill0"), 0)
    local _1Pos = self.SkillIcons[1].Root.localPosition
    for i = 2, 5 do
        local _go = UIUtils.FindGo(trans, string.format("First/Skill%d", i - 1))
        self.SkillIcons[i] = L_UIMainSkillIcon:New(self, _go, i - 1)
        local _offsetPos = _1Pos - _go.transform.localPosition
        self.AnimModule:AddAlphaPosAnimation(self.SkillIcons[i].Root, 0, 1, _offsetPos.x, _offsetPos.y, 0.4, false, false)
    end
    for i = 6, 9 do
        local _go = UIUtils.FindGo(trans, string.format("Second/Skill%d", i - 1))
        self.SkillIcons[i] = L_UIMainSkillIcon:New(self, _go, i - 1)
        local _offsetPos = _1Pos - _go.transform.localPosition
        self.AnimModule:AddAlphaPosAnimation(self.SkillIcons[i].Root, 0, 1, _offsetPos.x, _offsetPos.y, 0.4, false, false)
    end
    self.UseSelectGo = UIUtils.FindGo(trans, "SelectPanel")
    self.UseSelectRoot = UIUtils.FindTrans(trans, "SelectPanel/Root")
    self.UseSelectBar = UIUtils.FindTrans(trans, "SelectPanel/Root/Bar")
    self.UseSelectPos = {}
    for i = 1, 9 do
        local _trans = UIUtils.FindTrans(trans, string.format("SelectPanel/%d", i - 1))
        self.UseSelectPos[i] = _trans.localPosition
    end
    self.UseSelectGo:SetActive(false)
    self.CanelWidget = UIUtils.FindWid(trans, "SelectPanel/Canel")
    self.CanelRect = Rect(-self.CanelWidget.width / 2, -self.CanelWidget.height / 2, self.CanelWidget.localSize.x, self.CanelWidget.localSize.y)
    self.AnimModule:AddAlphaPosAnimation(nil, 0, 1, 370, 0, 0.5, true, true)
    self.FlySwordSkillGo = UIUtils.FindGo(trans, "FlySwordSkill/Root")
    self.FlySwordSkilIcon = UIUtils.FindSpr(trans, "FlySwordSkill/Root/Icon")
    self.FlySwordSkilCdSpr = UIUtils.FindSpr(trans, "FlySwordSkill/Root/CDSpr")
    self.FlySwordVfx = UIUtils.RequireUIVfxSkinCompoent(UIUtils.FindTrans(trans, "FlySwordSkill/Root/UIVfxSkinCompoent"))
    self.FlySwordSkillBtn = UIUtils.FindBtn(trans, "FlySwordSkill")
    UIUtils.AddBtnEvent(self.FlySwordSkillBtn, self.OnlySwordSkillBtnClick, self)
    self.FlySwordLightTrans = UIUtils.FindTrans(trans, "FlySwordSkill/Root/CDSpr/CDLight")
    self.SwitchBtn = UIUtils.FindBtn(trans, "SwitchBtn")
    UIUtils.AddBtnEvent(self.SwitchBtn, self.OnSwitchBtnClick, self)
end

-- After display
function UIMainSkillPanel:OnShowAfter()
    self:UpdateSkillList(nil)
    self:UpdateSkillStiffState(0)
    self.SelectHisTable:Clear()
    self.UseSelectGo:SetActive(false)
    self:OnUpdateFlySwordSkill(nil, nil)
    self.CurIndex = -1
    self:SwitchSkillIndex(0, false)
end
-- After closing
function UIMainSkillPanel:OnHideAfter()
    self.UseSelectGo:SetActive(false)
end
function UIMainSkillPanel:PlayNewSkillEffect(panelIndex, hideIcon)
    local _result = self.Trans
    if panelIndex > 0 and panelIndex <= #self.SkillIcons then
        self.SkillIcons[panelIndex]:PlayGetEffect()
        _result = self.SkillIcons[panelIndex].Root
    end
    return _result
end
function UIMainSkillPanel:StopVFX()
    for i = 1, #self.SkillIcons do
        self.SkillIcons[i]:StopVFX()
    end
end
-- Flying Sword Skill Refresh
function UIMainSkillPanel:OnUpdateFlySwordSkill(obj, sender)
    local _skill = GameCenter.PlayerSkillSystem.FlySwordSkill
    if _skill ~= nil then
        self.FlySwordSkillGo:SetActive(true)
        self.FlySwordSkilIcon.spriteName = string.format("skill_%d", _skill.Icon)
    else
        self.FlySwordSkillGo:SetActive(false)
    end
end
-- Skill list refresh
function UIMainSkillPanel:UpdateSkillList(obj, sender)
    for i = 1, #self.SkillIcons do
        self.SkillIcons[i]:UpdateSkill()
    end
end
-- Update the skill stiffness state
function UIMainSkillPanel:UpdateSkillStiffState(obj, sender)
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp ~= nil then
        local _freeze = _lp.StateManager:InState(1)
        for i = 1, #self.SkillIcons do
            self.SkillIcons[i]:SetIconGray(_freeze)
        end
    end
end
function UIMainSkillPanel:OnFormOpen(uiname, sender)
    if uiname == nil or string.len(uiname) <= 0 then
        return
    end
    if not self.UseSelectGo.activeSelf then
        return
    end
    local _checker = self.RootForm.CSForm.Manager
    if _checker == nil then
        return
    end
    if _checker:IsHitUI(self.UseSelectTouchID, uiname) then
        self.UseSelectGo:SetActive(false)
        GameCenter.SkillSelectFiledManager:DestoryFiled()
        for i = 1, #self.SkillIcons do
            self.SkillIcons[i]:CanelUseSkill()
        end
    end
end
function UIMainSkillPanel:OnCanelHandle(obj, sender)
    if self.UseSelectGo.activeSelf then
        self.UseSelectGo:SetActive(false)
        GameCenter.SkillSelectFiledManager:DestoryFiled()
        for i = 1, #self.SkillIcons do
            self.SkillIcons[i].CanelUseSkill()
        end
    end
end
function UIMainSkillPanel:Update(dt)
    for i = 1, #self.SkillIcons do
        self.SkillIcons[i]:UpdateCD(dt)
    end
    local _cd = GameCenter.InputSystem.RollDadgeHandler.CurRollCD
    if _cd > 0 then
        local _iCD = math.floor(_cd)
        if _iCD ~= self.FrontUpdateCd then
            self.FrontUpdateCd = _iCD
            if _iCD <= 0 then
                UIUtils.ClearText(self.RollCDValue)
            else
                UIUtils.SetTextByNumber(self.RollCDValue, _iCD)
            end
        end
        self.RollCDSpr.fillAmount = _cd / GameCenter.InputSystem.RollDadgeHandler.RollCDTime
    else
        self.FrontUpdateCd = -1
        UIUtils.ClearText(self.RollCDValue)
        self.RollCDSpr.fillAmount = 0
    end
    local _lfSkill = GameCenter.PlayerSkillSystem.FlySwordSkill
    if _lfSkill ~= nil then
        if not self.FlySwordSkillGo.activeSelf then
            self.FlySwordSkillGo:SetActive(true)
        end
        local _fillAmount = 1 - _lfSkill:GetCDPercent()
        self.FlySwordSkilCdSpr.fillAmount = _fillAmount
        UnityUtils.SetLocalEulerAngles(self.FlySwordLightTrans, 0, 0, math.Lerp(0, -360, _fillAmount))
        local _curCd = _lfSkill.CurCD
        if _curCd <= 0 and self.FlySwordSkilIcon.finalAlpha > 0.01 then
            if not self.FlySwordVfx.IsPlaying then
                self.FlySwordVfx:OnCreateAndPlay(ModelTypeCode.UIVFX, 220, LayerUtils.AresUI)
            end
        else
            if self.FlySwordVfx.IsPlaying then
                self.FlySwordVfx:OnDestory()
            end
        end
    else
        if self.FlySwordSkillGo.activeSelf then
            self.FlySwordSkillGo:SetActive(false)
        end
    end
end
function UIMainSkillPanel:SwitchSkillIndex(index, playAnim)
    if self.CurIndex == index then
        return
    end
    self.CurIndex = index
    if index == 0 then
        self.FirstGo:SetActive(true)
        for i = 6, 9 do
            if i == 6 then
                self.AnimModule:PlayHideAnimation(self.SkillIcons[i].Root, function()
                    self.SecondGo:SetActive(false)
                end)
            else
                self.AnimModule:PlayHideAnimation(self.SkillIcons[i].Root)
            end
            self.SkillIcons[i].Collider.enabled = false
        end
        for i = 2, 5 do
            self.AnimModule:PlayShowAnimation(self.SkillIcons[i].Root)
            self.SkillIcons[i].Collider.enabled = true
        end
    else
        self.SecondGo:SetActive(true)
        for i = 2, 5 do
            if i == 2 then
                self.AnimModule:PlayHideAnimation(self.SkillIcons[i].Root, function()
                    self.FirstGo:SetActive(false)
                end)
            else
                self.AnimModule:PlayHideAnimation(self.SkillIcons[i].Root)
            end
            self.SkillIcons[i].Collider.enabled = false
        end
        for i = 6, 9 do
            self.AnimModule:PlayShowAnimation(self.SkillIcons[i].Root)
            self.SkillIcons[i].Collider.enabled = true
        end
    end
end
function UIMainSkillPanel:OnSwitchBtnClick()
    if self.CurIndex == 0 then
        self:SwitchSkillIndex(1, true)
    else
        self:SwitchSkillIndex(0, true)
    end
end
function UIMainSkillPanel:OnlySwordSkillBtnClick()
    local _skill = GameCenter.PlayerSkillSystem.FlySwordSkill
    if _skill == nil then
        return
    end
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end
    if not _lp:CanUseSkill(_skill.CfgID) then
        return
    end
    if _lp.InSafeTile then
        -- Can't use skills in safe areas
        Utils.ShowPromptByEnum("C_CANNOT_USE_SKILL_IN_SAFE_TILES")
        return
    end
    _lp.skillManager:UseSkill(_skill.CfgID, false)
end
function UIMainSkillPanel:OnRollDogeBtnClick()
    
    -- [GOSU] Check task block transport
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp ~= nil then
        local _ret = GameCenter.LuaTaskManager:IsCurrentTaskBlockTransport()
        if _ret then
            Utils.ShowPromptByEnum("CANNOT_TRANS_BY_TASK_BLOCK")
            return
        end
    end
    
    GameCenter.InputSystem.RollDadgeHandler:DoRollDadge()
end
function UIMainSkillPanel:OnChangeTargetBtnClick()
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end
    if self.SelectHisTable:Count() >= 5 then
        self.SelectHisTable:Clear()
    end
    local _selectPRI = GameCenter.GameSetting:GetSetting(GameSettingKeyCode.SelectPRI)
    local _playerList = GameCenter.GameSceneSystem:FindRemotePlayers()
    local _monsterList = GameCenter.GameSceneSystem:FindMonsters()

    local _targetPlayer = nil
    local _playerMinDis = 9999999999
    local _targetMonster = nil
    local _monsterMinDis = 9999999999
    if _playerList ~= nil then
        local _playerCount = _playerList.Count
        for i = 1, _playerCount do
            local _player = _playerList[i - 1]
            if L_CombatUtil.CanAttackTarget(_lp, _player) and not self.SelectHisTable:ContainsKey(_player.ID) then
                local _dis = _lp:GetSqrDistance2d(_player.Position2d)
                if _dis < _playerMinDis then
                    _targetPlayer = _player
                    _playerMinDis = _dis
                end
            end
        end
    end
    if _monsterList ~= nil then
        local _monsterCount = _monsterList.Count
        for i = 1, _monsterCount do
            local _monster = _monsterList[i - 1]
            if L_CombatUtil.CanAttackTarget(_lp, _monster) and not self.SelectHisTable:ContainsKey(_monster.ID) then
                local _dis = _lp:GetSqrDistance2d(_monster.Position2d)
                if _dis < _monsterMinDis then
                    _targetMonster = _monster
                    _monsterMinDis = _dis
                end
            end
        end
    end
    local _target = nil
    if _selectPRI == 0 then -- No priority
        if _targetMonster ~= nil and _targetPlayer ~= nil then
            if _playerMinDis < _monsterMinDis then
                _target = _targetPlayer
            else
                _target = _targetMonster
            end
        elseif _targetMonster ~= nil then
            _target = _targetMonster
        elseif _targetPlayer ~= nil then
            _target = _targetPlayer
        end
    elseif _selectPRI == 1 then -- Priority Players
        if _targetPlayer ~= nil then
            _target = _targetPlayer
        elseif _targetMonster ~= nil then
            _target = _targetMonster
        end
    else    -- Priority monsters
        if _targetMonster ~= nil then
            _target = _targetMonster
        elseif _targetPlayer ~= nil then
            _target = _targetPlayer
        end
    end

    if _target ~= nil then
        _lp:SetCurSelectedTargetId(_target.ID)
        self.SelectHisTable:Add(_target.ID, 0)
    end
end

local L_ContUseColor = L_Color(1, 0.2, 0.2)
local L_CanUseColor = L_Color(1, 1, 1)
-- Skill Button
L_UIMainSkillIcon = {
    RootGo = nil,
    Root = nil,
    RootWidget = nil,
    Btn = nil,
    Collider = nil,
    Icon = nil,
    CdSpr = nil,
    CdValue = nil,
    SkillEfect = nil,
    Parent = nil,
    VfxCompoent = nil,
    LockGo = nil,
    LockLevel = nil,
    SkillMaxDis = 0,
    TouchStartPos = nil,
    UseDir2d = L_Vector2.zero,
    UseDis = 0,
    CanUseSkill = false,
    SkillInfo = nil,
    PosIndex = 0,
    GetEffectTimer = -1,
}

function L_UIMainSkillIcon:New(parent, rootGo, posIndex)
    local _m = Utils.DeepCopy(self)
    _m.RootGo = rootGo
    local _trans = rootGo.transform
    _m.Root = _trans
    _m.Parent = parent
    _m.PosIndex = posIndex
    _m.Btn = UIUtils.FindBtn(_trans)
    _m.Collider = UIUtils.FindBoxCollider(_trans)
    _m.RootWidget = UIUtils.FindWid(_trans)
    local eventListener = UIEventListener.Get(_m.Btn.gameObject)
    eventListener.onPress = Utils.Handler(_m.OnPress, _m)
    eventListener.onDrag = Utils.Handler(_m.OnDrag, _m)
    local _tmpTrans = UIUtils.FindTrans(_trans, "Root/Icon")
    if _tmpTrans ~= nil then
        _m.Icon = UIUtils.FindSpr(_tmpTrans)
    end
    _tmpTrans = UIUtils.FindTrans(_trans, "Root/CDSpr")
    if _tmpTrans ~= nil then
        _m.CdSpr = UIUtils.FindSpr(_tmpTrans)
    end
    _tmpTrans = UIUtils.FindTrans(_trans, "Root/CdValue")
    if _tmpTrans ~= nil then
        _m.CdValue = UIUtils.FindLabel(_tmpTrans)
    end
    _tmpTrans = UIUtils.FindTrans(_trans, "Root/Effect")
    if _tmpTrans ~= nil then
        _m.SkillEfect = _tmpTrans.gameObject
        _m.SkillEfect:SetActive(false)
    end
    _tmpTrans = UIUtils.FindTrans(_trans, "Root/UIVfxSkinCompoent")
    if _tmpTrans ~= nil then
        _m.VfxCompoent = UIUtils.RequireUIVfxSkinCompoent(_tmpTrans)
    end
    _tmpTrans = UIUtils.FindTrans(_trans, "Root/Lock")
    if _tmpTrans ~= nil then
        _m.LockGo = _tmpTrans.gameObject
    end
    _tmpTrans = UIUtils.FindTrans(_trans, "Root/Lock/OpenLevel")
    if _tmpTrans ~= nil then
        _m.LockLevel = UIUtils.FindLabel(_tmpTrans)
    end
    return _m
end

function L_UIMainSkillIcon:PlayGetEffect()
    self.GetEffectTimer = 1.2
    self:UpdateSkill()
end


function L_UIMainSkillIcon:UpdateSkill()
    local _system = GameCenter.PlayerSkillSystem
    if _system == nil then
        return
    end
    if self.SkillInfo ~= nil then
        self.SkillInfo.RereshCallBack = nil
    end
    local _oderValue = GameCenter.PlayerSkillSystem:GetSkillPosCellValue(self.PosIndex)
    self.SkillInfo = GameCenter.PlayerSkillSystem:GetSkillCell(_oderValue)
    if self.SkillInfo ~= nil then
        self.SkillInfo.RereshCallBack = Utils.Handler(self.OnRefreshIcon, self)
        self:OnRefreshIcon()
        if self.CdSpr ~= nil then
            self.CdSpr.gameObject:SetActive(true)
        end
        if self.CdValue ~= nil then
            self.CdValue.gameObject:SetActive(true)
        end
        if self.LockGo ~= nil then
            self.LockGo:SetActive(false)
        end
    else
        if self.CdSpr ~= nil then
            self.CdSpr.gameObject:SetActive(false)
        end
        if self.CdValue ~= nil then
            self.CdValue.gameObject:SetActive(false)
        end
        if _oderValue >= 0 then
            if self.LockGo ~= nil then
                self.LockGo:SetActive(true)
            end
            if self.LockLevel ~= nil then
                local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
                local _occ = _lp.IntOcc
                local _skillCfg = DataConfig.DataSkillStarLevelup[(_occ + 1) * 1000000 + _oderValue * 1000]
                if _skillCfg ~= nil then
                    UIUtils.SetTextByEnum(self.LockLevel, "C_MAIN_NON_PLAYER_SHOW_LEVEL", _skillCfg.ActiveLevel)
                    local _skillIds = Utils.SplitNumber(_skillCfg.SkillId)
                    local _cfg = DataConfig.DataSkill[_skillIds[1]]
                    self.Icon.gameObject:SetActive(true)
                    if _cfg ~= nil then
                        self.Icon.spriteName = string.format("skill_%d", _cfg.Icon)
                    end
                end
            end
        else
            if self.LockGo ~= nil then
                self.LockGo:SetActive(false)
            end
            self.Icon.gameObject:SetActive(false)
        end
    end
end
function L_UIMainSkillIcon:StopVFX()
    if self.VfxCompoent ~= nil then
        self.VfxCompoent:OnDestory()
    end
end
function L_UIMainSkillIcon:SetIconGray(b)
    if self.Icon ~= nil then
        self.Icon.IsGray = b
    end
end
function L_UIMainSkillIcon:CanelUseSkill()
    self.CanUseSkill = false
end
function L_UIMainSkillIcon:OnRefreshIcon()
    if self.Icon ~= nil and self.SkillInfo ~= nil then
        local _skill = self.SkillInfo:GetCurSkill()
        if _skill ~= nil then
            self.Icon.gameObject:SetActive(true)
            self.Icon.spriteName = string.format("skill_%d", _skill.Icon)
        end
    end
end
function L_UIMainSkillIcon:OnPress(go, press)
    if self.SkillInfo == nil then
        return
    end

    if press then
        -- [GOSU] Check task block transport
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if _lp ~= nil then
            local _ret = GameCenter.LuaTaskManager:IsCurrentTaskBlockTransport()
            if _ret then
                Utils.ShowPromptByEnum("CANNOT_TRANS_BY_TASK_BLOCK")
                return
            end
        end

        local _skill = self.SkillInfo:GetCurSkill()
        if _skill ~= nil and not _skill:IsCDing() then
            self.CanUseSkill = true
        else
            self.CanUseSkill = false
        end
        self.TouchStartPos = L_NGUIMath.ScreenToPixels(L_UICamera.currentTouch.pos, go.transform)
        self.Parent.UseSelectGo:SetActive(false)
        GameCenter.SkillSelectFiledManager:DestoryFiled()
    else
        if self.Parent.UseSelectGo.activeSelf then
            -- If the selection disk is displayed, calculate the skill direction or position
            self.Parent.UseSelectGo:SetActive(false)
            local _curTouchPos = L_NGUIMath.ScreenToPixels(L_UICamera.currentTouch.pos, self.Parent.CanelWidget.transform)
            if not self.Parent.CanelRect:Contains(_curTouchPos) then
                if self.SkillInfo:GetCurSkill().VisualInfo.SelectFiledType ~= L_SkillSelectFiledType.None then
                    self:UseSkillByUseSelect()
                end
            end
        else
            -- If the selection plate is not displayed, use the skills directly
            if self.TouchStartPos then
                local _curTouchPos = L_NGUIMath.ScreenToPixels(L_UICamera.currentTouch.pos, go.transform)
                local _xDis = _curTouchPos.x - self.TouchStartPos.x
                local _yDis = _curTouchPos.y - self.TouchStartPos.y
                if (_xDis * _xDis + _yDis * _yDis) <= 100 then
                    self:UseSkill()
                end
            end
        end
        GameCenter.SkillSelectFiledManager:DestoryFiled()
    end
    if GameCenter.MapLogicSystem.MapCfg and GameCenter.MapLogicSystem.MapCfg.MapLogicType == MapLogicTypeDefine.TerritorialWar then
        GameCenter.MapLogicSystem.ActiveLogic:ReqTargetPos()
    end
end
function L_UIMainSkillIcon:OnDrag(go, dt)
    if not self.CanUseSkill then
        return
    end
    if self.SkillInfo == nil then
        return
    end
    local _visInfo = self.SkillInfo:GetCurSkill().VisualInfo
    local _filedType = _visInfo.SelectFiledType
    if _filedType == L_SkillSelectFiledType.None then
        return
    end
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end
    local _curDragPos = L_NGUIMath.ScreenToPixels(L_UICamera.currentTouch.pos, self.Parent.UseSelectRoot)
    if not self.Parent.UseSelectGo.activeSelf then
        if (_curDragPos.x * _curDragPos.x + _curDragPos.y * _curDragPos.y) >= 400 then
            -- Moving more than 20 pixels means opening the skill selection position or direction interface
            self.Parent.UseSelectGo:SetActive(true)
            self.Parent.UseSelectTouchID = L_UICamera.currentTouchID
            self.Parent.UseSelectRoot.localPosition = self.Parent.UseSelectPos[self.PosIndex + 1]
            if _filedType == L_SkillSelectFiledType.SelectPos then
                self.SkillMaxDis = _visInfo.PosBigRoundSize
                GameCenter.SkillSelectFiledManager:ShowSelectPosFiled(_visInfo.PosBigRoundSize, _visInfo.PosSmallRoundSize)
            elseif _filedType == L_SkillSelectFiledType.SelectDir then
                self.SkillMaxDis = _visInfo.DirSelectParam1
                GameCenter.SkillSelectFiledManager:ShowSelectDirFiled(_visInfo.SelectDirType, _visInfo.DirSelectParam1, _visInfo.DirSelectParam2)
            end
        end
    end
    if self.Parent.UseSelectGo.activeSelf then
        local _dir = _curDragPos.normalized
        local _curDis = L_Vector2.Distance(L_Vector2.zero, _curDragPos)
        if _curDis >= L_MaxSelectUIDis then
            UnityUtils.SetLocalPosition(self.Parent.UseSelectBar.transform, _dir.x * L_MaxSelectUIDis, _dir.y * L_MaxSelectUIDis, 0)
            _curDis = L_MaxSelectUIDis
        else
            UnityUtils.SetLocalPosition(self.Parent.UseSelectBar.transform, _curDragPos.x, _curDragPos.y, 0)
        end
        local _woldDir = self:JoystickDirToWorldDir(_dir)
        local _worldDir3d = L_Vector3(_woldDir.x, 0, _woldDir.y)
        _worldDir3d = _worldDir3d.normalized
        self.UseDis = (_curDis / L_MaxSelectUIDis) * self.SkillMaxDis
        local _pos3d = _lp.Position + self.UseDis * _worldDir3d
        _pos3d = _lp.Scene:GetTerrainPosition(_pos3d.x, _pos3d.z)
        _pos3d.y = _pos3d.y + 0.2
        local _touchCanelPos = L_NGUIMath.ScreenToPixels(L_UICamera.currentTouch.pos, self.Parent.CanelWidget.transform)
        local _color = L_CanUseColor
        if self.Parent.CanelRect:Contains(_touchCanelPos) then
            _color = L_ContUseColor
        end
        if _filedType == L_SkillSelectFiledType.SelectPos and _lp.Scene.navigator:IsBlocked(_pos3d) then
            -- Select the skill of the position. If the target is in the block, it will be displayed in red.
            _color = L_ContUseColor
        end
        GameCenter.SkillSelectFiledManager:SetPosAndDir(_pos3d, _worldDir3d, _color)
        self.UseDir2d.x = _woldDir.x
        self.UseDir2d.y = _worldDir3d.z
    end
end
function L_UIMainSkillIcon:JoystickDirToWorldDir(joyDir)
    if GameCenter.GameSceneSystem.ActivedScene == nil then
        return joyDir
    end
    local _angle = L_Mathf.Atan2(joyDir.y, joyDir.x)
    local _degree = math.floor(L_Mathf.Round(L_Mathf.Rad2Deg * _angle))
    _degree = (_degree + 360) % 360
    local _cdir = L_Vector3(L_Mathf.Cos(L_Mathf.Deg2Rad * (-_degree)), 0.0, L_Mathf.Sin(L_Mathf.Deg2Rad * (-_degree)))
    local _wdir = GameCenter.GameSceneSystem.ActivedScene.SceneCamera.cameraToWorldMatrix:MultiplyVector(_cdir)
    local _yaw = L_MathLib.CalculateYaw(_wdir)
    return L_Vector2(L_Mathf.Sin(_yaw), L_Mathf.Cos(_yaw))
end
function L_UIMainSkillIcon:UseSkill()
    if self.SkillInfo == nil then
        return
    end
    local _skill = self.SkillInfo:GetCurSkill()
    if _skill == nil then
        return
    end
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end
    if not _lp:CanUseSkill(_skill.CfgID) then
        return
    end
    if _lp.InSafeTile then
        -- Can't use skills in safe areas
        Utils.ShowPromptByEnum("C_CANNOT_USE_SKILL_IN_SAFE_TILES")
        return
    end
    _lp.skillManager:UseSkill(_skill.CfgID, false)
end
function L_UIMainSkillIcon:UseSkillByUseSelect()
    if self.SkillInfo == nil then
        return
    end
    local _skill = self.SkillInfo:GetCurSkill()
    if _skill == nil then
        return
    end
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end
    if not _lp:CanUseSkill(_skill.CfgID) then
        return
    end
    if _lp.InSafeTile then
        Utils.ShowPromptByEnum("C_CANNOT_USE_SKILL_IN_SAFE_TILES")
        return
    end
    _lp.skillManager:UseSkill(_skill.CfgID, self.SkillInfo:GetCurSkill().VisualInfo.SelectFiledType, self.UseDir2d, _lp.Position2d + self.UseDir2d.normalized * self.UseDis)
end
function L_UIMainSkillIcon:UpdateCD(dt)
    if self.SkillInfo == nil then
        return
    end

    if self.GetEffectTimer > 0 then
        self.GetEffectTimer = self.GetEffectTimer - dt
        if self.GetEffectTimer <= 0 then
            self.GetEffectTimer = -1
            self:UpdateSkill()
        end
    end

    if self.CdSpr ~= nil and self.CdValue ~= nil then
        local _skill = self.SkillInfo:GetCurSkill()
        if _skill ~= nil then
            if _skill.CurCD > 0 then
                self.CdSpr.fillAmount = _skill:GetCDPercent()
                if Time.GetFrameCount() % 30 == 0 then
                    UIUtils.SetTextByNumber(self.CdValue, math.floor(_skill.CurCD))
                end
            else
                self.CdSpr.fillAmount = 0
                UIUtils.ClearText(self.CdValue)
            end
        end
    end
end

return UIMainSkillPanel