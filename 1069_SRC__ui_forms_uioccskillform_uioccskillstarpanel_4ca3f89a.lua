--==============================--
--author:
--Date: 2020-10-12
--File: UIOccSkillStarPanel.lua
--Module: UIOccSkillStarPanel
--Description: Skill Upgrade Interface
--==============================--

local UIOccSkillStarPanel = {
    --transform
    Trans = nil,
    Go = nil,
    --Parent node
    Parent = nil,
    --Affiliated form
    RootForm = nil,
    --Animation module
    AnimModule = nil,

    ScrollView = nil,
    Grid = nil,
    ItemRes = nil,
    ItemList = nil,

    SkillIcon = nil,
    SkillName = nil,
    SkillStars = nil,
    SkillDesc = nil,

    ProNames = nil,
    ProValues = nil,
    ProNextValues = nil,
    CurDamage = nil,
    NextDamage = nil,
    FullDesc = nil,

    MaxLevelGo = nil,
    
    LevelGo = nil,
    CostItem = nil,
    LevelUPBtn = nil,
    LevelUPRedPoint = nil,

    SelectSkill = nil,
}

local L_SkillIcon = nil

function UIOccSkillStarPanel:OnFirstShow(trans, parent, rootForm)
    self.Trans = trans
    self.Go = trans.gameObject
    self.Parent = parent
    self.RootForm = rootForm
    --Create an animation module
    self.AnimModule = UIAnimationModule(self.Trans)
    --Add an animation
	self.AnimModule:AddAlphaScaleAnimation(nil, 0, 1, 1.05, 1.05, 1, 1, 0.3, true, false)
    self.Go:SetActive(false)

    self.ScrollView = UIUtils.FindScrollView(trans, "ScrollView")
    self.Grid = UIUtils.FindGrid(trans, "ScrollView/Grid")
    self.ItemRes = nil
    self.ItemList = List:New()
    local _parentTrans = self.Grid.transform
    for i = 1, _parentTrans.childCount do
        local _childTrans = _parentTrans:GetChild(i - 1)
        if self.ItemRes == nil then
            self.ItemRes = _childTrans.gameObject
        end
        self.ItemList:Add(L_SkillIcon:New(_childTrans, self, i))
    end
    self.SkillIcon = UIUtils.FindSpr(trans, "Icon")
    self.SkillName = UIUtils.FindLabel(trans, "Name")
    self.SkillStars = {}
    for i = 1, 5 do
        self.SkillStars[i] = UIUtils.FindGo(trans, string.format("Star%d/Value", i))
    end
    self.SkillDesc = UIUtils.FindLabel(trans, "Desc")

    self.ProNames = {}
    self.ProValues = {}
    self.ProNextValues = {}
    for i = 1, 2 do
        self.ProNames[i] = UIUtils.FindLabel(trans, string.format("Pro%d/Name", i))
        self.ProValues[i] = UIUtils.FindLabel(trans, string.format("Pro%d/Value", i))
        self.ProNextValues[i] = UIUtils.FindLabel(trans, string.format("Pro%d/NextValue", i))
    end
    self.CurDamage = UIUtils.FindLabel(trans, "Damage/Value")
    self.NextDamage = UIUtils.FindLabel(trans, "Damage/NextValue")
    self.FullDesc = UIUtils.FindLabel(trans, "FullEffect/Value")
    self.MaxLevelGo = UIUtils.FindGo(trans, "MaxLevel")

    self.LevelGo = UIUtils.FindGo(trans, "Level")
    self.LevelUPBtn = UIUtils.FindBtn(trans, "Level/LevelUP")
    UIUtils.AddBtnEvent(self.LevelUPBtn, self.OnLevelUPBtnClick, self)
    self.LevelUPRedPoint = UIUtils.FindGo(trans, "Level/LevelUP/RedPoint")
    self.CostItem = UILuaItem:New(UIUtils.FindTrans(trans, "Level/UIItem"))
    return self
end

function UIOccSkillStarPanel:Show()
    --Play the start-up picture
    self.AnimModule:PlayEnableAnimation()
    self.SelectSkill = nil
    self:RefreshPanel()
end

function UIOccSkillStarPanel:Hide()
    --Play Close animation
    self.Go:SetActive(false)
end

--Click the upgrade button
function UIOccSkillStarPanel:OnLevelUPBtnClick()
    if not self.CostItem.IsEnough then
        GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(self.CostItem.ShowItemData.CfgID)
        return
    end
    GameCenter.Network.Send("MSG_Skill.ReqUpSkillStar", {skillID = self.SelectSkill.StarCfg.Id})
end

--Refresh the page
function UIOccSkillStarPanel:RefreshPanel()
    for i = 1, 20 do
        local _usedUI = nil
        if i <= #self.ItemList then
            _usedUI = self.ItemList[i]
        else
            _usedUI = L_SkillIcon:New(UnityUtils.Clone(self.ItemRes).transform, self, i)
            self.ItemList:Add(_usedUI)
        end
        _usedUI:Refresh()
    end

    if self.SelectSkill == nil then
        self:SetSelect(self.ItemList[1])
    else
        self:RefreshDetPanel()
    end
    self.Grid:Reposition()
end

function UIOccSkillStarPanel:SetSelect(skill)
    self.SelectSkill = skill
    for i = 1, #self.ItemList do
        self.ItemList[i]:SetSelect(self.ItemList[i] == skill)
    end
    self:RefreshDetPanel()
end

--Refresh attributes
function UIOccSkillStarPanel:RefreshDetPanel()
    self.SkillIcon.spriteName = string.format("skill_%d", self.SelectSkill.SkillCfg.Icon)
    UIUtils.SetTextByStringDefinesID(self.SkillName, self.SelectSkill.SkillCfg._Name)
    UIUtils.SetTextByStringDefinesID(self.SkillDesc, self.SelectSkill.SkillCfg._Desc)

    local _starCount = self.SelectSkill.StarCfg.Id % 10
    for i = 1, 5 do
        self.SkillStars[i]:SetActive(i <= _starCount)
    end

    local _curPros = Utils.SplitStrByTableS(self.SelectSkill.StarCfg.Att, {';', '_'})
    local _nextPros = nil
    local _nextCfg = DataConfig.DataSkillStarLevelup[self.SelectSkill.StarCfg.Id + 1]
    if _nextCfg ~= nil then
        _nextPros = Utils.SplitStrByTableS(_nextCfg.Att, {';', '_'})
    end
    for i = 1, 2 do
        if i <= #_curPros then
            UIUtils.SetTextByPropName(self.ProNames[i], _curPros[i][1], "{0}：")
            UIUtils.SetTextByPropValue(self.ProValues[i], _curPros[i][1], _curPros[i][2])
            if _nextPros ~= nil then
                UIUtils.SetTextByPropValue(self.ProNextValues[i], _nextPros[i][1], _nextPros[i][2])
                self.ProNextValues[i].gameObject:SetActive(true)
            else
                self.ProNextValues[i].gameObject:SetActive(false)
            end
        end
    end

    UIUtils.SetTextByNumber(self.CurDamage, self.SelectSkill.StarCfg.DamageAddShow)
    UIUtils.SetTextByStringDefinesID(self.FullDesc, self.SelectSkill.StarCfg._FiveStarShow)
    if _nextPros ~= nil then
        -- Not full
        self.MaxLevelGo:SetActive(false)
        self.LevelGo:SetActive(true)
        self.LevelUPRedPoint:SetActive(self.SelectSkill.ShowRedPoint)
        local _itemTable = Utils.SplitNumber(self.SelectSkill.StarCfg.NeedItem, '_')
        self.CostItem:InItWithCfgid(_itemTable[1], _itemTable[2], false, true)
        self.CostItem:BindBagNum()
        self.NextDamage.gameObject:SetActive(true)
        UIUtils.SetTextByNumber(self.NextDamage, _nextCfg.DamageAddShow)
    else
        -- Full level
        self.MaxLevelGo:SetActive(true)
        self.LevelGo:SetActive(false)
        self.NextDamage.gameObject:SetActive(false)
    end
end

L_SkillIcon = {
    Trans = nil,
    Go = nil,
    Icon = nil,
    Name = nil,
    RedPoint = nil,
    Select = nil,
    Parent = nil,
    StarGos = nil,

    CellIndex = 0,
    StarCfg = nil,
    SkillCfg = nil,
    ShowRedPoint = false,
}

function L_SkillIcon:New(trans, parent, cellIdex)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m.Parent = parent
    _m.CellIndex = cellIdex
    _m.Icon = UIUtils.FindSpr(trans, "Icon")
    _m.Name = UIUtils.FindLabel(trans, "Name")
    _m.RedPoint = UIUtils.FindGo(trans, "RedPoint")
    _m.Select = UIUtils.FindGo(trans, "Select")
    local _btn = UIUtils.FindBtn(trans)
    UIUtils.AddBtnEvent(_btn, _m.OnClick, _m)
    _m.StarGos = {}
    for i = 1, 5 do
        _m.StarGos[i] = UIUtils.FindGo(trans, string.format("Star%d/Value", i))
    end
    return _m
end

function L_SkillIcon:Refresh()
    local _skillCell = GameCenter.PlayerSkillSystem:GetSkillCell(self.CellIndex)
    if _skillCell ~= nil then
        self.Go:SetActive(true)
        local _cfg = DataConfig.DataSkillStarLevelup[_skillCell.CfgID]
        if _cfg ~= nil then
            local _skillIds = Utils.SplitNumber(_cfg.SkillId, '_')
            local _skillCfg = DataConfig.DataSkill[tonumber(_skillIds[1])]
            if _skillCfg ~= nil then
                self.Icon.spriteName = string.format("skill_%d", _skillCfg.Icon)
                UIUtils.SetTextByStringDefinesID(self.Name, _skillCfg._Name)
            end
            self.StarCfg = _cfg
            self.SkillCfg = _skillCfg

            local _starCount = _cfg.Id % 10
            for i = 1, 5 do
                self.StarGos[i]:SetActive(i <= _starCount)
            end
        end
        self.ShowRedPoint = GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.PlayerSkillStar, _skillCell.CfgID)
        self.RedPoint:SetActive(self.ShowRedPoint)
    else
        self.Go:SetActive(false)
        self.SkillCfg = nil
        self.StarCfg = nil
        self.ShowRedPoint = false
    end
end

function L_SkillIcon:OnClick()
    self.Parent:SetSelect(self)
end

function L_SkillIcon:SetSelect(b)
    self.Select:SetActive(b)
end

return UIOccSkillStarPanel
