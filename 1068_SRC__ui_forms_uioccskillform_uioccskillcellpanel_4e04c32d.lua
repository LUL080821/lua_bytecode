--==============================--
-- author:
-- Date: 2020-10-10
-- File: UIOccSkillCellPanel.lua
-- Module: UIOccSkillCellPanel
-- Description: Skill Slot Upgrade Interface
--==============================--

local UIOccSkillCellPanel = {
    --transform
    Trans = nil,
    Go = nil,
    -- Parent node
    Parent = nil,
    -- The form belongs to
    RootForm = nil,
    -- Animation module
    AnimModule = nil,

    CurLevel = nil,
    NextLevel = nil,

    ProGos = nil,
    ProNames = nil,
    ProValues = nil,
    ProNextValues = nil,

    LevelGo = nil,
    HaveMoney = nil,
    NeedMoney = nil,
    AddMoneyBtn = nil,
    LevelUPBtn = nil,
    LevelUPRedPoint = nil,
    OneKeyLevelBtn = nil,
    OneKeyLevelRedPoint = nil,

    MaxLevelGo = nil,

    Tex1 = nil,
    Tex2 = nil,
    Tex3 = nil,

    VipAddBtn = nil,
    VipAddNActive = nil,
    VipAddValue = nil,

    IsAuto = false,
    AutoTimer = 0,
    IsVisible = false,
    StopAutoBtn = nil,
}

function UIOccSkillCellPanel:OnFirstShow(trans, parent, rootForm)
    self.Trans = trans
    self.Go = trans.gameObject
    self.Parent = parent
    self.RootForm = rootForm
    -- Create an animation module
    self.AnimModule = UIAnimationModule(self.Trans)
    -- Add an animation
	self.AnimModule:AddAlphaScaleAnimation(nil, 0, 1, 1.05, 1.05, 1, 1, 0.3, true, false)
    self.Go:SetActive(false)

    self.CurLevel = UIUtils.FindLabel(trans, "CurLevel")
    self.NextLevel = UIUtils.FindLabel(trans, "NextLevel")
    self.ProGos = {}
    self.ProNames = {}
    self.ProValues = {}
    self.ProNextValues = {}
    for i = 1, 4 do
        self.ProGos[i] = UIUtils.FindGo(trans, string.format("Pro/%d", i))
        self.ProNames[i] = UIUtils.FindLabel(trans, string.format("Pro/%d/Name", i))
        self.ProValues[i] = UIUtils.FindLabel(trans, string.format("Pro/%d/Value", i))
        self.ProNextValues[i] = UIUtils.FindLabel(trans, string.format("Pro/%d/NextValue", i))
    end
    self.LevelGo = UIUtils.FindGo(trans, "Level")
    self.HaveMoney = UIUtils.FindLabel(trans, "Level/Have/Value")
    self.NeedMoney = UIUtils.FindLabel(trans, "Level/Cost/Value")
    self.AddMoneyBtn = UIUtils.FindBtn(trans, "Level/Have/AddBtn")
    self.LevelUPBtn = UIUtils.FindBtn(trans, "Level/LevelUP")
    self.LevelUPRedPoint = UIUtils.FindGo(trans, "Level/LevelUP/RedPoint")
    self.OneKeyLevelBtn = UIUtils.FindBtn(trans, "Level/OnKeyUP")
    self.OneKeyLevelRedPoint = UIUtils.FindGo(trans, "Level/OnKeyUP/RedPoint")
    self.MaxLevelGo = UIUtils.FindGo(trans, "MaxLevel")

    UIUtils.AddBtnEvent(self.AddMoneyBtn, self.OnAddMoneyBtnClick, self)
    UIUtils.AddBtnEvent(self.LevelUPBtn, self.OnLevelUPBtnClick, self)
    UIUtils.AddBtnEvent(self.OneKeyLevelBtn, self.OnOnKeyLevelBtnClick, self)

    self.Tex2 = UIUtils.FindTex(trans, "Tex2")
    self.Tex3 = UIUtils.FindTex(trans, "Tex3")

    self.VipAddBtn = UIUtils.FindBtn(trans, "JiaCheng")
    UIUtils.AddBtnEvent(self.VipAddBtn, self.OnVipAddBtnClick, self)
    self.VipAddNActive = UIUtils.FindGo(trans, "JiaCheng/NotActive")
    self.VipAddValue = UIUtils.FindLabel(trans, "JiaCheng/Value")
    self.IsVisible = false
    self.StopAutoBtn = UIUtils.FindBtn(trans, "Level/Stop")
    UIUtils.AddBtnEvent(self.StopAutoBtn, self.OnStopAutoBtnClick, self)
    self.StopBtnGo = self.StopAutoBtn.gameObject
    self.AutoBtnGo = self.OneKeyLevelBtn.gameObject
    return self
end

function UIOccSkillCellPanel:Show()
    -- Play the start-up picture
    self.AnimModule:PlayEnableAnimation()
    self:ChangeAutoState(false)
    self:RefreshPanel(nil, nil)
    self.RootForm.CSForm:LoadTexture(self.Tex2, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_z_53"))
    self.RootForm.CSForm:LoadTexture(self.Tex3, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_z_53"))
    self.IsVisible = true
end

function UIOccSkillCellPanel:Hide()
    -- Play Close animation
    self.Go:SetActive(false)
    self.IsVisible = false
end

function UIOccSkillCellPanel:Update(dt)
    if not self.IsVisible then
        return
    end
    if self.IsAuto and self.AutoTimer >= 0 then
        self.AutoTimer = self.AutoTimer - dt
        if self.AutoTimer < 0 then
            self:OnLevelUPBtnClick()
        end
    end
end

-- Click on the upgrade button
function UIOccSkillCellPanel:OnLevelUPBtnClick()
    local _playerLevel = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
    local _cellLevel = GameCenter.PlayerSkillSystem:GetCellLevel()
    if _cellLevel >= _playerLevel then
        Utils.ShowPromptByEnum("C_SKILL_SKILLUP_LEVEL_UNENOUGH")
        self:ChangeAutoState(false)
        return
    end
    local _haveMoney = GameCenter.ItemContianerSystem:GetEconomyWithType(ItemTypeCode.BindMoney)
    local _cfg = DataConfig.DataSkillPositionLevelup[_cellLevel]
    if _haveMoney < _cfg.Money then
        local _costCfg = DataConfig.DataItem[3]
        Utils.ShowPromptByEnum("ConsumeNotEnough", _costCfg.Name)
        GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(3)
        self:ChangeAutoState(false)
        return
    end
    GameCenter.Network.Send("MSG_Skill.ReqUpCell")
end

-- Click the upgrade button with one click
function UIOccSkillCellPanel:OnOnKeyLevelBtnClick()
    self:ChangeAutoState(true)
end

function UIOccSkillCellPanel:OnStopAutoBtnClick()
    self:ChangeAutoState(false)
end

-- Change the automatic state
function UIOccSkillCellPanel:ChangeAutoState(b)
    self.IsAuto = b
    self.AutoTimer = 0
    self.StopBtnGo:SetActive(b)
    self.AutoBtnGo:SetActive(not b)
end

-- Add copper coin button click
function UIOccSkillCellPanel:OnAddMoneyBtnClick()
    GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(3)
end

-- Additional bonus button click
function UIOccSkillCellPanel:OnVipAddBtnClick()
    GameCenter.PushFixEvent(UILuaEventDefine.UISkillVipAddForm_OPEN)
end

-- Refresh the page
function UIOccSkillCellPanel:RefreshPanel()
    local _proAddRate = GameCenter.VipSystem:GetCurVipPowerParam(37)
    if _proAddRate > 0 and GameCenter.VipSystem:BaoZhuIsOpen() then
        self.VipAddNActive:SetActive(false)
        UIUtils.SetTextByEnum(self.VipAddValue, "Percent", _proAddRate)
        self.VipAddValue.gameObject:SetActive(true)
    else
        self.VipAddNActive:SetActive(true)
        self.VipAddValue.gameObject:SetActive(false)
    end
    local _cellLevel = GameCenter.PlayerSkillSystem:GetCellLevel()
    local _cfg = DataConfig.DataSkillPositionLevelup[_cellLevel]
    local _nextCfg = DataConfig.DataSkillPositionLevelup[_cellLevel + 1]
    UIUtils.SetTextByNumber(self.CurLevel, _cellLevel)
    if _nextCfg == nil then
        -- Full level
        UIUtils.SetTextByNumber(self.NextLevel, _cellLevel)
        self.LevelGo:SetActive(false)
        self.MaxLevelGo:SetActive(true)
        local _curPros = Utils.SplitStrByTableS(_cfg.Att, {';', '_'})
        for i = 1, 4 do
            if i <= #_curPros then
                UIUtils.SetTextByPropName(self.ProNames[i], _curPros[i][1])
                UIUtils.SetTextByPropValue(self.ProValues[i], _curPros[i][1], _curPros[i][2])
                self.ProNextValues[i].gameObject:SetActive(false)
                self.ProGos[i]:SetActive(true)
            else
                self.ProGos[i]:SetActive(false)
            end
        end
    else
        UIUtils.SetTextByNumber(self.NextLevel, _cellLevel + 1)
        -- Already activated
        self.LevelGo:SetActive(true)
        self.MaxLevelGo:SetActive(false)
        local _haveMoney = GameCenter.ItemContianerSystem:GetEconomyWithType(ItemTypeCode.BindMoney)
        UIUtils.SetTextByNumber(self.HaveMoney, _haveMoney)
        UIUtils.SetTextByNumber(self.NeedMoney, _cfg.Money)
        self.LevelUPRedPoint:SetActive(GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.PlayerSkillCell, 0))
        self.OneKeyLevelRedPoint:SetActive(GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.PlayerSkillCell, 0))
        
        local _curPros = Utils.SplitStrByTableS(_cfg.Att, {';', '_'})
        local _nextPros = Utils.SplitStrByTableS(_nextCfg.Att, {';', '_'})
        for i = 1, 4 do
            if i <= #_curPros then
                UIUtils.SetTextByPropName(self.ProNames[i], _curPros[i][1])
                UIUtils.SetTextByPropValue(self.ProValues[i], _curPros[i][1], _curPros[i][2])
                UIUtils.SetTextByPropValue(self.ProNextValues[i], _nextPros[i][1], _nextPros[i][2])
                self.ProNextValues[i].gameObject:SetActive(true)
                self.ProGos[i]:SetActive(true)
            else
                self.ProGos[i]:SetActive(false)
            end
        end
    end
    if self.IsAuto then
        self.AutoTimer = 0.3
    end
end

return UIOccSkillCellPanel
