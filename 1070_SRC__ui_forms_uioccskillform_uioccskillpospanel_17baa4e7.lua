--==============================--
-- author:
-- Date: 2020-11-26
-- File: UIOccSkillPosPanel.lua
-- Module: UIOccSkillPosPanel
-- Description: Skill Assembly Interface
--==============================--
local L_UIOccSkillUseSetPanel = require "UI.Forms.UIOccSkillForm.UIOccSkillUseSetPanel"

local UIOccSkillPosPanel = {
    --transform
    Trans = nil,
    Go = nil,
    -- Parent node
    Parent = nil,
    -- The form belongs to
    RootForm = nil,
    -- Animation module
    AnimModule = nil,

    ScrollView = nil,
    TypeRes = nil,
    TypeList = nil,
    SkillName = nil,
    SkillEquip = nil,
    SkillDesc = nil,
    SetBtn = nil,
    BackTex = nil,
    NormalSpr = nil,
    PosIcons = nil,
    FirstIcon = nil,

    CurSelectIcon = nil,
    SetPanel = nil,
    BackTexEquip = nil,
}

local L_TypeItem = nil
local L_PosItem = nil

function UIOccSkillPosPanel:OnFirstShow(trans, parent, rootForm)
    self.Trans = trans
    self.Go = trans.gameObject
    self.Parent = parent
    self.RootForm = rootForm
    -- Create an animation module
    self.AnimModule = UIAnimationModule(self.Trans)
    -- Add an animation
	self.AnimModule:AddAlphaScaleAnimation(nil, 0, 1, 1.05, 1.05, 1, 1, 0.3, true, false)
    self.Go:SetActive(false)
    self.IsVisible = false

    self.ScrollView = UIUtils.FindScrollView(trans, "ScrollView")
    self.TypeRes = nil
    self.TypeList = List:New()
    local _parentTrans = self.ScrollView.transform
    for i = 1, _parentTrans.childCount do
        local _trans = _parentTrans:GetChild(i - 1)
        local _typeItem = L_TypeItem:New(_trans, self)
        self.TypeList:Add(_typeItem)
        if self.TypeRes == nil then
            self.TypeRes = _typeItem.Go
        end
    end
    self.BackTexEquip = UIUtils.FindTex(trans, "BackTexEquip")
    self.RootForm.CSForm:LoadTexture(self.BackTexEquip,AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_b_jineng_t"))
    self.SkillName = UIUtils.FindLabel(trans, "Name")
    self.SkillEquip = UIUtils.FindGo(trans, "Name/Label")
    self.SkillDesc = UIUtils.FindLabel(trans, "Desc")
    self.SetBtn = UIUtils.FindBtn(trans, "SetBtn")
    UIUtils.AddBtnEvent(self.SetBtn, self.OnSetBtnClick, self)
    self.BackTex = UIUtils.FindTex(trans, "BackTex")
    self.NormalSpr = UIUtils.FindSpr(trans, "BackTex/NormalIcon")
    self.PosIcons = {}
    for i = 1, 8 do
        self.PosIcons[i] = L_PosItem:New(UIUtils.FindTrans(trans, string.format("BackTex/%d", i)), self, i)
    end

    local _skillInst = GameCenter.PlayerSkillSystem:GetSkillCell(0)
    if _skillInst ~= nil then
        -- Activated
        local _cellCfg = DataConfig.DataSkillStarLevelup[_skillInst.CfgID]
        if _cellCfg ~= nil then
            local _skillCfg = DataConfig.DataSkill[Utils.SplitNumber(_cellCfg.SkillId, '_')[1]]
            if _skillCfg ~= nil then
                self.NormalSpr.spriteName = string.format("skill_%d", _skillCfg.Icon)
            end
        end
    end
    self.SetPanel = L_UIOccSkillUseSetPanel:OnFirstShow(UIUtils.FindTrans(trans, "SetPanel"), self, rootForm)
    return self
end

function UIOccSkillPosPanel:Show()
    -- Play the start-up picture
    self.AnimModule:PlayEnableAnimation()

    local _curSelectMerId = GameCenter.PlayerSkillSystem.CurSelectMerId
    self.FirstIcon = nil
    local _index = 1
    local _posY = 77
    local _func = function(key, value)
        if value.XinfaId ~= 0 and value.XinfaId ~= _curSelectMerId then
            return
        end
        local _typeItem = nil
        if _index <= #self.TypeList then
            _typeItem = self.TypeList[_index]
        else
            _typeItem = L_TypeItem:New(UnityUtils.Clone(self.TypeRes).transform, self)
            self.TypeList:Add(_typeItem)
        end
        local _resultIcon = _typeItem:SetInfo(value, _posY)
        _posY = _posY - _typeItem.Height
        _index = _index + 1

        if _resultIcon ~= nil and self.FirstIcon == nil then
            self.FirstIcon = _resultIcon
        end
    end
    for i = _index, #self.TypeList do
        self.TypeList[i]:SetInfo(nil)
    end
    DataConfig.DataSkillOderPos:Foreach(_func)

    for i = 1, #self.TypeList do
        self.TypeList[i]:Refresh()
    end
    self:SetSelectSkill(self.FirstIcon)
    self.RootForm.CSForm:LoadTexture(self.BackTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_b_jineng_1"))
    self.ScrollView:ResetPosition()
    self.SetPanel:Hide()
    self.IsVisible = true
end

function UIOccSkillPosPanel:Hide()
    -- Play Close animation
    self.Go:SetActive(false)
    self.IsVisible = false
end

function UIOccSkillPosPanel:OnTryHide()
    if self.SetPanel.IsVisible then
        self.SetPanel:Hide()
        return false
    end
    return true
end

function UIOccSkillPosPanel:OnSetBtnClick()
    self.SetPanel:Show()
end

-- Refresh the page
function UIOccSkillPosPanel:RefreshPanel()
    for i = 1, #self.TypeList do
        self.TypeList[i]:Refresh()
    end
    if self.CurSelectIcon == nil then
        self:SetSelectSkill(self.FirstIcon)
    else
        self:SetSelectSkill(self.CurSelectIcon)
    end
end

function UIOccSkillPosPanel:SetSelectSkill(icon)
    for i = 1, #self.TypeList do
        self.TypeList[i]:SetSelect(icon)
    end
    self.CurSelectIcon = icon
    for i = 1, #self.PosIcons do
        self.PosIcons[i]:Refresh(icon.OderValue)
    end
    if icon ~= nil then
        UIUtils.SetTextByStringDefinesID(self.SkillName, icon.SkillCfg._Name)
        UIUtils.SetTextByStringDefinesID(self.SkillDesc, icon.SkillCfg._Desc)
        self.SkillEquip:SetActive(icon.IsEquip)
        self.SkillName.gameObject:SetActive(false)
        self.SkillName.gameObject:SetActive(true)
        self.SkillDesc.gameObject:SetActive(true)
    else
        self.SkillName.gameObject:SetActive(false)
        self.SkillDesc.gameObject:SetActive(false)
    end
end

-- type
L_TypeItem = {
    Parent = nil,
    Go = nil,
    Trans = nil,
    Title = nil,
    Grid = nil,
    IconRes = nil,
    IconList = nil,
    Height = 0
}
local L_SkillIcon = nil
function L_TypeItem:New(trans, parent)
    local _m = Utils.DeepCopy(self)
    _m.Parent = parent
    _m.Go = trans.gameObject
    _m.Trans = trans
    _m.Title = UIUtils.FindLabel(trans, "Title")
    _m.Grid = UIUtils.FindGrid(trans, "Grid")
    _m.IconRes = nil
    _m.IconList = List:New()
    local _parentTrans = _m.Grid.transform
    for i = 1, _parentTrans.childCount do
        local _trans = _parentTrans:GetChild(i - 1)
        local _icon = L_SkillIcon:New(_trans, parent)
        _m.IconList:Add(_icon)
        if _m.IconRes == nil then
            _m.IconRes = _icon.Go
        end
    end
    return _m
end

function L_TypeItem:SetInfo(cfg, posY)
    local _firstIcon = nil
    if cfg == nil then
        self.Height = 0
        self.Go:SetActive(false)
    else
        self.Go:SetActive(true)
        UIUtils.SetTextByStringDefinesID(self.Title, cfg._Name)
        local _orers = Utils.SplitNumber(cfg.OderList, '_')
        local _skillCount = 0
        for i = 1, #_orers do
            local _useIcon = nil
            if i <= #self.IconList then
                _useIcon = self.IconList[i]
            else
                _useIcon = L_SkillIcon:New(UnityUtils.Clone(self.IconRes).transform, self.Parent)
                self.IconList:Add(_useIcon)
            end
            if _useIcon:SetOder(_orers[i]) then
                _skillCount = _skillCount + 1
                if _firstIcon == nil then
                    _firstIcon = _useIcon
                end
            end
        end
        for i = #_orers + 1, #self.IconList do
            self.IconList[i]:SetOder(nil)
        end
        self.Grid:Reposition()
        local _lineCount = (_skillCount / 4)
        if _skillCount % 4 ~= 0 then
            _lineCount = _lineCount + 1
        end
        -- đổi vị trí hiện skill
        --self.Height = 70 + _lineCount * 145
        self.Height = _skillCount * 90
        UnityUtils.SetLocalPositionY(self.Trans, posY)
    end
    return _firstIcon
end
function L_TypeItem:SetSelect(icon)
    for i = 1, #self.IconList do
        self.IconList[i]:SetSelect(self.IconList[i] == icon)
    end
end
function L_TypeItem:Refresh()
    for i = 1, #self.IconList do
        self.IconList[i]:Refresh()
    end
end

L_SkillIcon = {
    Parent = nil,
    Go = nil,
    Trans = nil,
    Btn = nil,
    Icon = nil,
    Name = nil,
    Select = nil,
    StartRoots = nil,
    Starts = nil,
    Equip = nil,
    Lock = nil,
    SkillCfg = nil,
    IsActive = false,
    IsEquip = false,
    RedPoint = nil,
}
function L_SkillIcon:New(trans, parent)
    local _m = Utils.DeepCopy(self)
    _m.Parent = parent
    _m.Go = trans.gameObject
    _m.Trans = trans
    _m.Btn = UIUtils.FindBtn(trans)
    UIUtils.AddBtnEvent(_m.Btn, _m.OnBtnClick, _m)
    _m.Icon = UIUtils.FindSpr(trans, "Icon")
    _m.Name = UIUtils.FindLabel(trans, "Name")
    _m.Select = UIUtils.FindGo(trans, "Select")
    _m.StartRoots = {}
    _m.Starts = {}
    for i = 1, 5 do
        _m.StartRoots[i] = UIUtils.FindGo(trans, string.format("Star%d", i))
        _m.Starts[i] = UIUtils.FindGo(trans, string.format("Star%d/Value", i))
    end
    _m.Equip = UIUtils.FindGo(trans, "Equip")
    _m.Lock = UIUtils.FindGo(trans, "Lock")
    _m.RedPoint = UIUtils.FindGo(trans, "RedPoint")
    return _m
end
function L_SkillIcon:SetOder(oder)
    self.OderValue = oder
    if oder == nil then
        self.Go:SetActive(false)
        return false
    else
        local _cellCfg = nil
        local _skillInst = GameCenter.PlayerSkillSystem:GetSkillCell(oder)
        if _skillInst ~= nil then
            -- Activated
            _cellCfg = DataConfig.DataSkillStarLevelup[_skillInst.CfgID]
        else
            -- Not activated
            local _occ = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
            _cellCfg = DataConfig.DataSkillStarLevelup[(_occ + 1) * 1000000 + oder * 1000]
        end

        if _cellCfg ~= nil then
            local _skillCfg = DataConfig.DataSkill[Utils.SplitNumber(_cellCfg.SkillId, '_')[1]]
            if _skillCfg ~= nil then
                self.SkillCfg = _skillCfg
                self.Go:SetActive(true)
                self.Icon.spriteName = string.format("skill_%d", _skillCfg.Icon)
                UIUtils.SetTextByStringDefinesID(self.Name, _skillCfg._Name)
                return true
            else
                self.Go:SetActive(false)
                return false
            end
        else
            self.Go:SetActive(false)
            return false
        end
    end
end
function L_SkillIcon:OnBtnClick()
    self.Parent:SetSelectSkill(self)
end
function L_SkillIcon:SetSelect(b)
    self.Select:SetActive(b)
end
function L_SkillIcon:Refresh()
    self.RedPoint:SetActive(GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.PlayerSkillPos, self.OderValue))
    if self.SkillCfg == nil then
        self.IsActive = false
        return
    end
    self.IsEquip = GameCenter.PlayerSkillSystem:SkillIsEquip(self.OderValue)
    self.Equip:SetActive(self.IsEquip)
    local _skillInst = GameCenter.PlayerSkillSystem:GetSkillCell(self.OderValue)
    if _skillInst ~= nil then
        -- Activated
        UIUtils.SetColor(self.Icon, 1, 1, 1, 1)
        self.Lock:SetActive(false)
        local _cellCfg = DataConfig.DataSkillStarLevelup[_skillInst.CfgID]
        if _cellCfg ~= nil then
            local _starCount = _cellCfg.Id % 10
            for i = 1, 5 do
                self.StartRoots[i]:SetActive(true)
                self.Starts[i]:SetActive(i <= _starCount)
            end
            self.SkillCfg = DataConfig.DataSkill[Utils.SplitNumber(_cellCfg.SkillId, '_')[1]]
        end
        self.IsActive = true
    else
        -- Not activated
        for i = 1, 5 do
            self.StartRoots[i]:SetActive(false)
        end
        self.Lock:SetActive(true)
        UIUtils.SetColor(self.Icon, 0.6, 0.6, 0.6, 1)
        self.IsActive = false
    end
end

-- Slot position
L_PosItem = {
    Parent = nil,
    Go = nil,
    Trans = nil,
    Btn = nil,
    Icon = nil,
    Light = nil,
    Add = nil,
    RedPoint = nil,

    PosValue = 0,
    CurOrder = 0,
}

function L_PosItem:New(trans, parent, posValue)
    local _m = Utils.DeepCopy(self)
    _m.Parent = parent
    _m.Go = trans.gameObject
    _m.Trans = trans
    _m.Btn = UIUtils.FindBtn(trans)
    UIUtils.AddBtnEvent(_m.Btn, _m.OnBtnClick, _m)
    _m.Icon = UIUtils.FindSpr(trans, "Icon")
    _m.Light = UIUtils.FindGo(trans, "Light")
    _m.Add = UIUtils.FindGo(trans, "Add")
    _m.RedPoint = UIUtils.FindGo(trans, "RedPoint")
    _m.PosValue = posValue
    return _m
end

function L_PosItem:OnBtnClick()
    if self.Parent.CurSelectIcon == nil then
        -- Skill not selected
        Utils.ShowPromptByEnum("C_SKILLPOS_XUANZHE")
        return
    end

    if not self.Parent.CurSelectIcon.IsActive then
        -- Activate skills first
        Utils.ShowPromptByEnum("C_SKILLPOS_WEIJIHUO")
        return
    end
        
    if self.Parent.CurSelectIcon.OderValue == self.CurOrder then
        -- No replacement is required
        Utils.ShowPromptByEnum("C_SKILLPOS_CHONGFU")
        return
    end
    -- Set skill position
    GameCenter.PlayerSkillSystem:SetSkillPos(self.PosValue, self.Parent.CurSelectIcon.OderValue)
    -- Refresh the interface
    self.Parent:RefreshPanel()
end

function L_PosItem:Refresh(selectOrder)
    self.CurOrder = -1
    self.RedPoint:SetActive(GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.PlayerSkillPos, self.PosValue * 10000))
    local _orderValue = GameCenter.PlayerSkillSystem:GetSkillPosCellValue(self.PosValue)
    if _orderValue > 0 then
        self.Add:SetActive(false)
        self.Icon.gameObject:SetActive(true)
        local _skillInst = GameCenter.PlayerSkillSystem:GetSkillCell(_orderValue)
        local _cellCfg = nil
        if _skillInst ~= nil then
            -- Activated
            _cellCfg = DataConfig.DataSkillStarLevelup[_skillInst.CfgID]
        else
            local _occ = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
            _cellCfg = DataConfig.DataSkillStarLevelup[(_occ + 1) * 1000000 + _orderValue * 1000]
        end
        if _cellCfg ~= nil then
            local _skillCfg = DataConfig.DataSkill[Utils.SplitNumber(_cellCfg.SkillId, '_')[1]]
            if _skillCfg ~= nil then
                self.Icon.spriteName = string.format("skill_%d", _skillCfg.Icon)
            end
            local _curOder = _cellCfg.Id % 1000000 / 1000
            self.Light:SetActive(_curOder ~= selectOrder)
            self.CurOrder = _curOder
        end
    else
        self.Add:SetActive(true)
        self.Icon.gameObject:SetActive(false)
    end
end

return UIOccSkillPosPanel
