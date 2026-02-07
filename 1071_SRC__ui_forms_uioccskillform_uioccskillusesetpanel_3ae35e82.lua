--==============================--
-- author:
-- Date: 2020-11-30
-- File: UIOccSkillUseSetPanel.lua
-- Module: UIOccSkillUseSetPanel
-- Description: Skill Release Setting Interface
--==============================--

local UIOccSkillUseSetPanel = {
    --transform
    Trans = nil,
    -- Parent node
    Parent = nil,
    -- The form belongs to
    RootForm = nil,
    -- Animation module
    AnimModule = nil,

    CloseBtn = nil,
    CloseBtn2 = nil,
    SaveBtn = nil,
    ScrollView = nil,
    Table = nil,
    NormalTitle = nil,
    GridNormal = nil,
    ItemNormalRes = nil,
    ItemNormalResList = nil,
    SpecTitle = nil,
    GridSpec = nil,
    ItemSpecRes = nil,
    ItemSpecResList = nil,
    BackTex = nil,
}

local L_SkillItem = nil

function UIOccSkillUseSetPanel:OnFirstShow(trans, parent, rootForm)
    self.Trans = trans
    self.Parent = parent
    self.RootForm = rootForm
    -- Create an animation module
    self.AnimModule = UIAnimationModule(self.Trans)
    -- Add an animation
    self.AnimModule:AddNormalAnimation(0.3)
    self.Trans.gameObject:SetActive(false)
    self.IsVisible = false

    self.CloseBtn = UIUtils.FindBtn(trans, "CloseBtn")
    self.CloseBtn2 = UIUtils.FindBtn(trans, "CloseBtn2")
    UIUtils.AddBtnEvent(self.CloseBtn, self.OnCloseBtnClick, self)
    --UIUtils.AddBtnEvent(self.CloseBtn2, self.OnCloseBtnClick, self)
    self.SaveBtn = UIUtils.FindBtn(trans, "SaveBtn")
    UIUtils.AddBtnEvent(self.SaveBtn, self.OnSaveBtnClick, self)
    self.ScrollView = UIUtils.FindScrollView(trans, "ScrollView")
    self.Table = UIUtils.FindTable(trans, "ScrollView/Table")
    self.GridNormal = UIUtils.FindGrid(trans, "ScrollView/Table/Grid1")
    self.ItemNormalRes = nil
    self.ItemNormalResList = List:New()
    local _normalTrans = self.GridNormal.transform
    for i = 1, _normalTrans.childCount do
        local _trans = _normalTrans:GetChild(i - 1)
        local _skillItem = L_SkillItem:New(_trans)
        self.ItemNormalResList:Add(_skillItem, i)
        if self.ItemNormalRes == nil then
            self.ItemNormalRes = _skillItem.Go
        end
    end
    self.GridSpec = UIUtils.FindGrid(trans, "ScrollView/Table/Grid2")
    self.ItemSpecRes = nil
    self.ItemSpecResList = List:New()
    local _specTrans = self.GridSpec.transform
    for i = 1, _specTrans.childCount do
        local _trans = _specTrans:GetChild(i - 1)
        local _skillItem = L_SkillItem:New(_trans)
        self.ItemSpecResList:Add(_skillItem)
        if self.ItemSpecRes == nil then
            self.ItemSpecRes = _skillItem.Go
        end
    end
    self.NormalTitle = UIUtils.FindGo(trans, "ScrollView/Table/Title1")
    self.SpecTitle = UIUtils.FindGo(trans, "ScrollView/Table/Title2")
    self.BackTex = UIUtils.FindTex(trans, "BackTex")
    return self
end

function UIOccSkillUseSetPanel:Show()
    -- Play the start-up picture
    self.AnimModule:PlayEnableAnimation()
    self:RefreshPanel()
    self.ScrollView:ResetPosition()
    self.RootForm.CSForm:LoadTexture(self.BackTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_3_1"))
    self.IsVisible = true
end

function UIOccSkillUseSetPanel:Hide()
    -- Play Close animation
    self.AnimModule:PlayDisableAnimation()
    self.IsVisible = false
end

-- Click Close button
function UIOccSkillUseSetPanel:OnCloseBtnClick()
    self:Hide()
end

-- Click on the Save button
function UIOccSkillUseSetPanel:OnSaveBtnClick()
    local _swordUI = self.ItemSpecResList[1]
    if _swordUI.PosId ~= nil then
        GameCenter.PlayerSkillSystem.SkillSwordUseState = _swordUI.IsAutoUse
    end
    for i = 1, #self.ItemNormalResList do
        local _ui = self.ItemNormalResList[i]
        if _ui.PosId ~= nil then
            GameCenter.PlayerSkillSystem:SetAutoUse(_ui.PosId, _ui.IsAutoUse)
        end
    end
    GameCenter.PlayerSkillSystem:SavePosData()
    -- Start hanging up again
    GameCenter.MandateSystem:ReStart()
    self:Hide()
    Utils.ShowPromptByEnum("C_SKILL_USE_SAVESUCC")
end

-- Refresh the page
function UIOccSkillUseSetPanel:RefreshPanel()
    -- Normal skills
    local _index = 1
    for i = 1, 8 do
        local _skillInst = GameCenter.PlayerSkillSystem:GetSkillPosCell(i)
        if _skillInst ~= nil then
            local _useItem = nil
            if _index <= #self.ItemNormalResList then
                _useItem = self.ItemNormalResList[_index]
            else
                _useItem = L_SkillItem:New(UnityUtils.Clone(self.ItemNormalRes).transform)
                self.ItemNormalResList:Add(_useItem)
            end
            _useItem:RefreshNormal(_skillInst, i)
            _index = _index + 1
        end
    end
    for i = _index, #self.ItemNormalResList do
        self.ItemNormalResList[i]:RefreshNormal(nil)
    end
    if _index <= 1 then
        self.NormalTitle:SetActive(false)
    else
        self.NormalTitle:SetActive(true)
    end
    self.GridNormal:Reposition()

    -- Sword Spirit Awakens
    local _swordUI = self.ItemSpecResList[1]
    local _swordSkill = GameCenter.PlayerSkillSystem.FlySwordSkill
    if _swordSkill ~= nil then
        self.SpecTitle:SetActive(true)
        _swordUI:RefreshSpec(_swordSkill)
    else
        _swordUI:RefreshSpec(nil)
        self.SpecTitle:SetActive(false)
    end

    self.Table:Reposition()
end

L_SkillItem = {
    Go = nil,
    Trans = nil,
    Icon = nil,
    Name = nil,
    Btn = nil,
    SelectGo = nil,

    IsAutoUse = false,
    PosId = nil,
}

function L_SkillItem:New(trans)
    local _m = Utils.DeepCopy(self)
    _m.Go = trans.gameObject
    _m.Trans = trans
    _m.Icon = UIUtils.FindSpr(trans, "Icon")
    _m.Name = UIUtils.FindLabel(trans, "Name")
    _m.Btn = UIUtils.FindBtn(trans)
    UIUtils.AddBtnEvent(_m.Btn, _m.OnBtnClick, _m)
    _m.SelectGo = UIUtils.FindGo(trans, "Select/Spr")
    return _m
end

function L_SkillItem:RefreshNormal(skillInst, posId)
    if skillInst == nil then
        self.Go:SetActive(false)
        self.PosId = nil
    else
        self.Go:SetActive(true)
        local _cellCfg = DataConfig.DataSkillStarLevelup[skillInst.CfgID]
        if _cellCfg ~= nil then
            local _skillCfg = DataConfig.DataSkill[Utils.SplitNumber(_cellCfg.SkillId, '_')[1]]
            if _skillCfg ~= nil then
                self.Icon.spriteName = string.format("skill_%d", _skillCfg.Icon)
                UIUtils.SetTextByStringDefinesID(self.Name, _skillCfg._Name)
            end
        end
        self.IsAutoUse = GameCenter.PlayerSkillSystem:IsAutoUse(posId)
        self.SelectGo:SetActive(self.IsAutoUse)
        self.PosId = posId
    end
end

function L_SkillItem:RefreshSpec(skill)
    if skill == nil then
        self.PosId = nil
        self.Go:SetActive(false)
    else
        self.Go:SetActive(true)
        local _skillCfg = DataConfig.DataSkill[skill.CfgID]
        if _skillCfg ~= nil then
            self.Icon.spriteName = string.format("skill_%d", _skillCfg.Icon)
            UIUtils.SetTextByStringDefinesID(self.Name, _skillCfg._Name)
        end
        self.IsAutoUse = GameCenter.PlayerSkillSystem.SkillSwordUseState
        self.SelectGo:SetActive(self.IsAutoUse)
        self.PosId = 65535
    end
end

function L_SkillItem:OnBtnClick()
    if self.IsAutoUse then
        self.IsAutoUse = false
    else
        self.IsAutoUse = true
    end
    self.SelectGo:SetActive(self.IsAutoUse)
end

return UIOccSkillUseSetPanel
