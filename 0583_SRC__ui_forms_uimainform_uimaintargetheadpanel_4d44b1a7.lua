------------------------------------------------
-- author:
-- Date: 2021-02-27
-- File: UIMainTargetHeadPanel.lua
-- Module: UIMainTargetHeadPanel
-- Description: The main interface time display paging
------------------------------------------------

local L_UIMainSubBasePanel = require "UI.Forms.UIMainForm.UIMainSubBasePanel"
local L_ShakeIntensity = 10
local L_BlinkTime = 0.15
local L_BlinkHalfTime = L_BlinkTime / 2
local MainFunctionSystem = CS.Thousandto.Code.Logic.MainFunctionSystem
local MonsterType = CS.Thousandto.Code.Logic.MonsterType

local UIMainTargetHeadPanel = {
    RootTrans = nil,
    BossHpProgress = nil,
    BossHpSpr1 = nil,
    BossHpSpr2 = nil,
    BossHeadIcon = nil,
    BossName = nil,
    BossHPValue = nil,
    ShakeRoot = nil,
    ShakeRootGo = nil,
    ShakeCurve = nil,
    BossBuffList = nil,
    BossHpVfx = nil,
    NuqiGo1 = nil,
    NuqiValue1 = nil,
    NuqiIcon = nil,
    DropOwnerGO = nil,
    DropOwnerDesc = nil,
    DropOwner = nil,
    FrontUpdateHPCount = -1,
    CurHpBarIndex = 0,
    BoosHpColors = {},
    CurBossHpColor = {1, 1, 1},
    SelectTargetID = 0,
    BarBlinkTimer = 0,
    BarBlinkStartColor = {1, 1, 1},
    BarBlinkEndColor = {0.8, 0.8, 0.8},
    FrontPlayVfxTime = 0,
    -- Total number of target blood bars
    TargetHPNum = 0,
    -- Current display percentage of blood
    ShowHPPercent = 0,
    -- Blood-loss animation speed
    HpAnimSpeed = 0.01,
}

function UIMainTargetHeadPanel:OnFirstShow(trans, parent, rootForm)
    setmetatable(self, {__index = L_UIMainSubBasePanel.New()})
    self:BaseFirstShow(trans, parent, rootForm)

    self.BossHpProgress = UIUtils.FindProgressBar(trans, "Root/ShakeRoot/HPBar1")
    self.BossHpSpr1 = UIUtils.FindSpr(trans, "Root/ShakeRoot/HPBar1")
    self.BossHpSpr2 = UIUtils.FindSpr(trans, "Root/ShakeRoot/HPBar2")
    self.BossHPValue = UIUtils.FindLabel(trans, "Root/ShakeRoot/HPCount")
    self.BossHeadIcon = UIUtils.RequireUIIcon(UIUtils.FindTrans(trans, "Root/ShakeRoot"))
    self.BossName = UIUtils.FindLabel(trans, "Root/ShakeRoot/Name")
    self.ShakeRoot = UIUtils.FindTrans(trans, "Root/ShakeRoot")
    self.ShakeRootGo = self.ShakeRoot.gameObject
    local _tweenAlaha = UIUtils.FindTweenAlpha(trans, "Root/ShakeRoot")
    self.ShakeCurve = _tweenAlaha.animationCurve
    self.BoosHpColors[0] = {255 / 255, 74 / 255, 52 / 255}
    self.BoosHpColors[1] = {255 / 255, 138 / 255, 76 / 255}
    self.BoosHpColors[2] = {158 / 255, 52 / 255, 255 / 255}
    self.BoosHpColors[3] = {72 / 255, 146 / 255, 250 / 255}
    self.BoosHpColors[4] = {54 / 255, 255 / 255, 168 / 255}
    self.BossBuffList = require "UI.Forms.UIMainForm.UIMainBuffListPanel"
    self.BossBuffList:OnFirstShow(UIUtils.FindTrans(trans, "Root/ShakeRoot/BuffPanel"), self, rootForm)
    self.BossHpVfx = UIUtils.RequireUIVfxSkinCompoent(UIUtils.FindTrans(trans, "Root/ShakeRoot/UIVfxSkinCompoent"))
    self.NuqiGo1 = UIUtils.FindGo(trans, "Root/ShakeRoot/NuQi")
    self.NuqiValue1 = UIUtils.FindLabel(trans, "Root/ShakeRoot/NuQi/NuQiValue")
    self.NuqiIcon = UIUtils.RequireUIIcon(UIUtils.FindTrans(trans, "Root/ShakeRoot/NuQi/Icon"))
    self.DropOwnerGO = UIUtils.FindGo(trans, "Root/ShakeRoot/DropOwner")
    self.DropOwnerDesc = UIUtils.FindLabel(trans, "Root/ShakeRoot/DropOwner/Name")
    self.DropOwner = UIUtils.FindLabel(trans, "Root/ShakeRoot/DropOwner")

    self.RootTrans = UIUtils.FindTrans(trans, "Root")
end

-- After display
function UIMainTargetHeadPanel:OnShowAfter()
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end
    self.SelectTargetID = 0
    self.ShakeRootGo:SetActive(false)
end

-- After closing
function UIMainTargetHeadPanel:OnHideAfter()
    self.SelectTargetID = 0
    self.BossHpVfx:OnDestory()
end
function UIMainTargetHeadPanel:StopVFX()
    self.BossHpVfx:OnDestory()
end
function UIMainTargetHeadPanel:OnDropInfoUpdate()
    local _monster = GameCenter.GameSceneSystem:FindMonster(self.SelectTargetID)
    if _monster == nil then
        return
    end
    local _dropShowState = 0
    local _mCfg = DataConfig.DataMonster[_monster.PropMoudle.CfgID]
    if _mCfg ~= nil then
        _dropShowState = _mCfg.ShowDropType
    end
    if _dropShowState == 1 then-- 1. The boss's blood bar shows participation in the attack
        self.DropOwnerGO:SetActive(true)
        UIUtils.SetTextByEnum(self.DropOwnerDesc, "C_DIAOLUO_DESC_CANYUGONGJI")
        UIUtils.SetTextByEnum(self.DropOwner, "C_DIAOLUO_DESC_DIAOLUOGUISHU")
    elseif _dropShowState == 2 then-- 2 first place display extra drop
        self.DropOwnerGO:SetActive(true)
        local _topPlayerID = GameCenter.DropAscriptionSystem:GetRankTopPlayerID(self.SelectTargetID)
        local _player = GameCenter.GameSceneSystem:FindPlayer(_topPlayerID)
        if _player ~= nil then
            UIUtils.SetTextByString(self.DropOwnerDesc, _player.Name)
        else
            UIUtils.SetTextByEnum(self.DropOwnerDesc, "C_DIAOLUO_DESC_SHANGHAIDIYI")
        end
        UIUtils.SetTextByEnum(self.DropOwner, "C_DIAOLUO_DESC_EWAIDIAOLUO")
    elseif _dropShowState == 3 then-- 3 first three display drop belonging
        self.DropOwnerGO:SetActive(true)
        UIUtils.SetTextByEnum(self.DropOwnerDesc, "C_DIAOLUO_DESC_SHANGHAIQIANSAN")
        UIUtils.SetTextByEnum(self.DropOwner, "C_DIAOLUO_DESC_DIAOLUOGUISHU")
    elseif _dropShowState == 4 then-- 4 First place display Drop belonging
        self.DropOwnerGO:SetActive(true)
        UIUtils.SetTextByEnum(self.DropOwner, "C_DIAOLUO_DESC_DIAOLUOGUISHU")
        local _topPlayerID = GameCenter.DropAscriptionSystem:GetRankTopPlayerID(self.SelectTargetID)
        local _player = GameCenter.GameSceneSystem:FindPlayer(_topPlayerID)
        if _player ~= nil then
            UIUtils.SetTextByString(self.DropOwnerDesc, _player.Name)
        else
            UIUtils.SetTextByEnum(self.DropOwnerDesc, "C_DIAOLUO_DESC_SHANGHAIDIYI")
        end
    else
        self.DropOwnerGO:SetActive(false)
    end
end
function UIMainTargetHeadPanel:UpdateHead(m)
    self.SelectTargetID = m.ID
    self.BossBuffList:Close()
    local _mCfgID = m.PropMoudle.CfgID
    local _mCfg = DataConfig.DataMonster[_mCfgID]
    
    if _mCfg.MonsterType >= MonsterType.MonsterFunctionBegin and _mCfg.MonsterType < MonsterType.MonsterFunctionEnd then
        if _mCfg.MonsterType == MonsterType.MonsterFunctionEscort then
            local player_name = m:GetNameAttributeValueByType(MonsterType.MonsterFunctionEscort)
            UIUtils.SetTextByEnum(self.BossName, "C_MONSTER_ESCORT_NAME_FORMAT", _mCfg.Name, player_name)
        else
            UIUtils.SetTextByString(self.BossName, m.Name)
        end
    elseif _mCfg.Level < 0 then
        -- Show player level
        UIUtils.SetTextByEnum(self.BossName, "C_MONSTER_NAME_FORMAT", GameCenter.GameSceneSystem:GetLocalPlayerLevel(), _mCfg.Name)
    elseif _mCfg.Level == 0 then
        -- Show world level
        UIUtils.SetTextByEnum(self.BossName, "C_MONSTER_NAME_FORMAT", GameCenter.OfflineOnHookSystem:GetCurWorldLevel(), _mCfg.Name)
    else
        UIUtils.SetTextByString(self.BossName, m.Name)
    end
    self.FrontUpdateHPCount = -1
    self.CurHpBarIndex = 4
    self.BossHeadIcon:UpdateIcon(_mCfg.Icon)
    self.TargetHPNum = _mCfg.HPNum
    self.ShowHPPercent = -1
    self.BossBuffList:OpenList(self.SelectTargetID)
    self:UpdateHP(m.HpPercent, true)
    self:OnDropInfoUpdate()
    -- If it is a Tianxu battlefield, the BOSS rage will be displayed according to the configuration.
    local _addNuQi = -1
    local _mapCfg = GameCenter.MapLogicSystem.MapCfg
    if _mapCfg ~= nil and _mapCfg.MapLogicType == MapLogicTypeDefine.TerritorialWar then
        local _func = function(k, v)
            if v.MonsterID == _mCfgID then
                if v.Score > 0 then
                    _addNuQi = v.Score
                end
                return true
            end
            return false
        end
        DataConfig.DataUniverseBoss:ForeachCanBreak(_func)
    end
    if _addNuQi > 0 then
        self.NuqiGo1:SetActive(true)
        self.NuqiIcon:UpdateIcon(275)
        UIUtils.SetTextByNumber(self.NuqiValue1, _addNuQi)
    else
        self.NuqiGo1:SetActive(false)
    end
end
local function L_SetColor(ui, color)
    UIUtils.SetColor(ui, color[1], color[2], color[3], 1)
end
function UIMainTargetHeadPanel:UpdateHPSpr(curHpCount)
    if self.FrontUpdateHPCount == curHpCount then
        return
    end
    self.FrontUpdateHPCount = curHpCount
    if curHpCount <= 1 then
        self.BossHpSpr2.gameObject:SetActive(false)
        L_SetColor(self.BossHpSpr1, self.BoosHpColors[0])
        self.CurBossHpColor = self.BoosHpColors[0]
    elseif curHpCount <= 2 then
        self.BossHpSpr2.gameObject:SetActive(true)
        L_SetColor(self.BossHpSpr2, self.BoosHpColors[0])
        L_SetColor(self.BossHpSpr1, self.BoosHpColors[self.CurHpBarIndex])
        self.CurBossHpColor = self.BoosHpColors[self.CurHpBarIndex]
    else
        self.BossHpSpr2.gameObject:SetActive(true)
        if self.CurHpBarIndex < 1 then
            self.CurHpBarIndex = 4
        end
        if self.CurHpBarIndex > 4 then
            self.CurHpBarIndex = 4
        end
        L_SetColor(self.BossHpSpr1, self.BoosHpColors[self.CurHpBarIndex])
        self.CurBossHpColor = self.BoosHpColors[self.CurHpBarIndex]
        self.CurHpBarIndex = self.CurHpBarIndex - 1
        if self.CurHpBarIndex < 1 then
            self.CurHpBarIndex = 4
        end
        L_SetColor(self.BossHpSpr2, self.BoosHpColors[self.CurHpBarIndex])
    end
    UIUtils.SetTextFormat(self.BossHPValue, "x{0}", curHpCount)
end
function UIMainTargetHeadPanel:UpdateHP(percent, first)
    if self.ShowHPPercent == percent and not first then
        return
    end
    self.ShowHPPercent = percent
    local _fHpCount = percent * self.TargetHPNum
    local _iHPCount = math.floor(_fHpCount)
    local _curPerect = _fHpCount % 1
    if _curPerect ~= 0 then
        _iHPCount = _iHPCount + 1
    end
    self:UpdateHPSpr(_iHPCount)
    self.BossHpProgress.value = _curPerect

    if not first and not MainFunctionSystem.MainMenuIsShowed  then
        local _startTime = Time.GetRealtimeSinceStartup()
        if (_startTime - self.FrontPlayVfxTime) >= 0.1 then
            self.BossHpVfx:OnCreateAndPlay(ModelTypeCode.UIVFX, 37, LayerUtils.AresUI)
            self.FrontPlayVfxTime = _startTime
        end
        if self.BossHpVfx.IsPlaying then
            local _vfxLocalPos = Vector3(self.BossHpProgress.value * self.BossHpSpr1.width, 0, 0)
            self.BossHpVfx:OnSetPosition(self.BossHpSpr1.transform:TransformPoint(_vfxLocalPos))
        end
    end
end

function UIMainTargetHeadPanel:Update(dt)
    if not self.IsVisible then
        return
    end
    self.BossBuffList:Update(dt)
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end
    local _curTarget = _lp:GetCurSelectBoss()
    if _curTarget ~= nil then
        -- Refresh the target
        self.ShakeRootGo:SetActive(true)
        if _curTarget.ID ~= self.SelectTargetID then
            -- Refresh the interface
            self:UpdateHead(_curTarget)
        end

        local _curTargetHP = _curTarget.HpPercent
        if self.ShowHPPercent > _curTargetHP then
            local _oneHpPerent = 1.0 / self.TargetHPNum
            local _decPercent = self.ShowHPPercent - _curTargetHP
            local _fDecCount = _decPercent / _oneHpPerent
            local _iDecCount = math.floor(_fDecCount)
            if _fDecCount % 1 ~= 0 then
                _iDecCount = _iDecCount + 1
            end
            if _iDecCount > 10 then
                _iDecCount = 10
            end
            self.HpAnimSpeed = _iDecCount * 5 / self.TargetHPNum
            local _hpPerect = self.ShowHPPercent - dt * self.HpAnimSpeed
            if _hpPerect < _curTargetHP then
                _hpPerect = _curTargetHP
            end
            self:UpdateHP(_hpPerect, false)
            -- Play vibration
            self.BarBlinkTimer = self.BarBlinkTimer + dt
            if self.BarBlinkTimer <= L_BlinkTime then
                local _lerpValue = self.ShakeCurve:Evaluate(self.BarBlinkTimer / L_BlinkTime)
                UnityUtils.SetLocalPosition(self.ShakeRoot, - _lerpValue * L_ShakeIntensity, -_lerpValue * L_ShakeIntensity, 0)
            else
                self.BarBlinkTimer = 0
            end

            if self.BarBlinkTimer <= L_BlinkHalfTime then
                local _lerp = self.BarBlinkTimer / L_BlinkHalfTime
                local _r = math.Lerp(self.BarBlinkStartColor[1], self.BarBlinkEndColor[1], _lerp) * self.CurBossHpColor[1]
                local _g = math.Lerp(self.BarBlinkStartColor[2], self.BarBlinkEndColor[2], _lerp) * self.CurBossHpColor[2]
                local _b = math.Lerp(self.BarBlinkStartColor[3], self.BarBlinkEndColor[3], _lerp) * self.CurBossHpColor[3]
                L_SetColor(self.BossHpSpr1, {_r, _g, _b})
            elseif self.BarBlinkTimer <= L_BlinkTime then
                local _lerp = (self.BarBlinkTimer - L_BlinkHalfTime) / L_BlinkHalfTime
                local _r = math.Lerp(self.BarBlinkEndColor[1], self.BarBlinkStartColor[1], _lerp) * self.CurBossHpColor[1]
                local _g = math.Lerp(self.BarBlinkEndColor[2], self.BarBlinkStartColor[2], _lerp) * self.CurBossHpColor[2]
                local _b = math.Lerp(self.BarBlinkEndColor[3], self.BarBlinkStartColor[3], _lerp) * self.CurBossHpColor[3]
                L_SetColor(self.BossHpSpr1, {_r, _g, _b})
            else
                L_SetColor(self.BossHpSpr1, self.CurBossHpColor)
                UnityUtils.SetLocalPosition(self.ShakeRoot, 0, 0, 0)
            end
        elseif self.ShowHPPercent < _curTargetHP then
            self:UpdateHP(_curTargetHP, false)
            self.BarBlinkTimer = 0
        end
        if Time.GetFrameCount() % 10 == 0 then
            local _dropShowState = 0
            local _mCfg = DataConfig.DataMonster[_curTarget.PropMoudle.CfgID]
            if _mCfg ~= nil then
                _dropShowState = _mCfg.ShowDropType
            end
            if _dropShowState == 4 or _dropShowState == 2 then
                local _topPlayerID = GameCenter.DropAscriptionSystem:GetRankTopPlayerID(self.SelectTargetID)
                local _player = GameCenter.GameSceneSystem:FindPlayer(_topPlayerID)
                if _player ~= nil then
                    UIUtils.SetTextByString(self.DropOwnerDesc, _player.Name)
                else
                    UIUtils.SetTextByEnum(self.DropOwnerDesc, "C_DIAOLUO_DESC_SHANGHAIDIYI")
                end
            end
        end
        if self.ShowHPPercent <= 0 then
            _lp:SetCurSelectBoss(nil)
        end
    else
        self.ShakeRootGo:SetActive(false)
        self.SelectTargetID = 0
        self.BarBlinkTimer = 0
    end
end

return UIMainTargetHeadPanel