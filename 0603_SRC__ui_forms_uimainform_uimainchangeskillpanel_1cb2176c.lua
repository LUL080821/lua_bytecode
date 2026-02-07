------------------------------------------------
-- author:
-- Date: 2021-02-26
-- File: UIMainChangeSkillPanel.lua
-- Module: UIMainChangeSkillPanel
-- Description: Transformation skill interface
------------------------------------------------
local L_UIMainSubBasePanel = require "UI.Forms.UIMainForm.UIMainSubBasePanel"
local L_CombatUtil = CS.Thousandto.Code.Logic.CombatUtil

local UIMainChangeSkillPanel = {
    ChangeTargetBtn = nil,
    CanelBtn = nil,
    SkillIcons = {},
    SelectHisTable = Dictionary:New(),
}

-- Register Events
function UIMainChangeSkillPanel:OnRegisterEvents()
end
local L_UISkillIcon = nil
function UIMainChangeSkillPanel:OnFirstShow(trans, parent, rootForm)
    setmetatable(self, {__index = L_UIMainSubBasePanel.New()})
    self:BaseFirstShow(trans, parent, rootForm)
    self.ChangeTargetBtn = UIUtils.FindBtn(trans, "ChangeTarget")
    UIUtils.AddBtnEvent(self.ChangeTargetBtn, self.OnChangeTargetBtnClick, self)
    self.CanelBtn = UIUtils.FindBtn(trans, "CanelBtn")
    UIUtils.AddBtnEvent(self.CanelBtn, self.OnCanelBtnClick, self)
    self.SkillIcons = {}
    for i = 1, 4 do
        local _go = UIUtils.FindGo(trans, string.format("Skill%d", i - 1))
        self.SkillIcons[i] = L_UISkillIcon:New(self, _go, i - 1)
    end
    self.AnimModule:AddAlphaPosAnimation(nil, 0, 1, 370, 0, 0.5, true, true)
end
-- After display
function UIMainChangeSkillPanel:OnShowAfter()
    self.SelectHisTable:Clear()
    self:UpdateSkillList(nil)
end
-- Skill list refresh
function UIMainChangeSkillPanel:UpdateSkillList(obj, sender)
    for i = 1, #self.SkillIcons do
        self.SkillIcons[i]:UpdateSkill()
    end
end
function UIMainChangeSkillPanel:Update(dt)
    for i = 1, #self.SkillIcons do
        self.SkillIcons[i]:UpdateCD()
    end
end
function UIMainChangeSkillPanel:OnCanelBtnClick()
    Utils.ShowMsgBox(function (code)
        if code == MsgBoxResultCode.Button2 then
            local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
            if _lp ~= nil then
                GameCenter.Network.Send("MSG_Buff.ReqRemovebuff", {id = _lp.ChangeCfgID})
            end
        end
    end, "C_BIANSHEN_RETUEN_ASK")
end
function UIMainChangeSkillPanel:OnChangeTargetBtnClick()
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

L_UISkillIcon = {
    RootGo = nil,
    RootTrans = nil,
    Btn = nil,
    Icon = nil,
    CdSpr = nil,
    CdValue = nil,
    SkillInfo = nil,
    CellPos = 0,
    Parent = nil,
}
function L_UISkillIcon:New(parent, rootGo, cellPos)
    local _m = Utils.DeepCopy(self)
    _m.RootGo = rootGo
    _m.RootTrans = rootGo.transform
    local _trans = _m.RootTrans
    _m.Parent = parent
    _m.CellPos = cellPos
    _m.Btn = UIUtils.FindBtn(_trans)
    UIUtils.AddBtnEvent(_m.Btn, _m.UseSkill, _m)
    local _tmpTrans = UIUtils.FindTrans(_trans, "Icon")
    if _tmpTrans ~= nil then
        _m.Icon = UIUtils.FindSpr(_tmpTrans)
    end
    _tmpTrans = UIUtils.FindTrans(_trans, "CDSpr")
    if _tmpTrans ~= nil then
        _m.CdSpr = UIUtils.FindSpr(_tmpTrans)
    end
    _tmpTrans = UIUtils.FindTrans(_trans, "CdValue")
    if _tmpTrans ~= nil then
        _m.CdValue = UIUtils.FindLabel(_tmpTrans)
    end
    return _m
end
function L_UISkillIcon:UpdateSkill()
    local _skillList = GameCenter.PlayerSkillSystem.ChangeSkillList
    local _skillCount = #_skillList
    if self.CellPos <= _skillCount then
        self.RootGo:SetActive(true)
        self.SkillInfo = _skillList[self.CellPos + 1]
        self:OnRefreshIcon()
        if self.CdSpr ~= nil then
            self.CdSpr.gameObject:SetActive(true)
        end
        if self.CdValue ~= nil then
            self.CdValue.gameObject:SetActive(true)
        end
    else
        self.SkillInfo = nil
        self.RootGo:SetActive(false)
    end
end
function L_UISkillIcon:OnRefreshIcon()
    if self.Icon ~= nil and self.SkillInfo ~= nil then
        self.Icon.spriteName = string.format("skill_%d", self.SkillInfo.Icon)
    end
end
function L_UISkillIcon:UseSkill()
    if self.SkillInfo == nil then
        return
    end
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp ~= nil and _lp:CanUseSkill(self.SkillInfo.CfgID) then
        if _lp.InSafeTile then
            -- Can't use skills in safe areas
            Utils.ShowPromptByEnum("C_CANNOT_USE_SKILL_IN_SAFE_TILES")
        else
            _lp.skillManager:UseSkill(self.SkillInfo.CfgID, false)
        end
    end
end
function L_UISkillIcon:UpdateCD()
    if self.SkillInfo == nil then
        return
    end
    if self.CdSpr ~= nil and self.CdValue ~= nil then
        if self.SkillInfo.CurCD > 0 then
            self.CdSpr.fillAmount = self.SkillInfo:GetCDPercent()
            if Time.GetFrameCount() % 30 == 0 then
                UIUtils.SetTextByNumber(self.CdValue, math.floor(self.SkillInfo.CurCD))
            end
        else
            self.CdSpr.fillAmount = 0
            UIUtils.ClearText(self.CdValue)
        end
    end
end

return UIMainChangeSkillPanel