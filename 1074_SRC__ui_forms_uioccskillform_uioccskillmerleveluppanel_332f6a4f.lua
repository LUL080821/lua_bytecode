--==============================--
--author:
--Date: 2020-08-06
--File: UIOccskillMerLevelUpPanel.lua
--Module: UIOccskillMerLevelUpPanel
--Description: Skill meridian interface
--==============================--

local UIOccskillMerLevelUpPanel = {
    --transform
    Trans = nil,
    Go = nil,
    --Parent node
    Parent = nil,
    --Affiliated form
    RootForm = nil,
    --Animation module
    AnimModule = nil,

    CloseBtn = nil,
    CloseBtn2 = nil,

    Name = nil,
    Level = nil,
    Icon = nil,
    NeedParent = nil,
    CurGo = nil,
    CurDesc = nil,
    NextGo = nil,
    NextDesc = nil,
    LevelGo = nil,
    LevelUpBtn = nil,
    CostValue = nil,
    CostIcon = nil,
    HaveValue = nil,
    HaveIcon = nil,
    MaxLevelGo = nil,
}

function UIOccskillMerLevelUpPanel:OnFirstShow(trans, parent, rootForm)
    self.Trans = trans
    self.Go = trans.gameObject
    self.Parent = parent
    self.RootForm = rootForm
    --Create an animation module
    self.AnimModule = UIAnimationModule(self.Trans)
    --Add an animation
	self.AnimModule:AddNormalAnimation(0.3)
    self.Go:SetActive(false)
    self.IsVisible = false
    self.Name = UIUtils.FindLabel(trans, "Back/Name")
    self.Level = UIUtils.FindLabel(trans, "Back/Level")
    self.Icon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(trans, "Back/Icon"))
    self.NeedParent = UIUtils.FindLabel(trans, "Back/NeedParent")
    self.CurGo = UIUtils.FindGo(trans, "Back/Cur")
    self.CurDesc = UIUtils.FindLabel(trans, "Back/Cur/Desc")
    self.NextGo = UIUtils.FindGo(trans, "Back/Next")
    self.NextDesc = UIUtils.FindLabel(trans, "Back/Next/Desc")
    self.LevelGo = UIUtils.FindGo(trans, "Back/LevelGo")
    self.LevelUpBtn = UIUtils.FindBtn(trans, "Back/LevelGo/LevelUP")
    UIUtils.AddBtnEvent(self.LevelUpBtn, self.OnLevelUPBtnClick, self)
    self.CostValue = UIUtils.FindLabel(trans, "Back/LevelGo/Cost/Value")
    self.CostIcon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(trans, "Back/LevelGo/Cost/Icon"))
    self.HaveValue = UIUtils.FindLabel(trans, "Back/LevelGo/Have/Value")
    self.HaveIcon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(trans, "Back/LevelGo/Have/Icon"))
    self.MaxLevelGo = UIUtils.FindGo(trans, "Back/MaxLevel")
    self.Title1PosY = self.CurGo.transform.localPosition.y
    self.Title2PosY = self.NextGo.transform.localPosition.y
    self.CloseBtn = UIUtils.FindBtn(trans, "Close")
    UIUtils.AddBtnEvent(self.CloseBtn, self.OnCloseBtnClick, self)
    self.CloseBtn2 = UIUtils.FindBtn(trans, "Back/Close")
    UIUtils.AddBtnEvent(self.CloseBtn2, self.OnCloseBtnClick, self)
    return self
end

function UIOccskillMerLevelUpPanel:Show(icon)
    --Play the start-up picture
    if not self.IsVisible then
        self.AnimModule:PlayEnableAnimation()
    end
    self.IsVisible = true
    self.SelectIcon = icon
    local _costValue = 0
    local _costItem = nil
    UIUtils.SetTextByStringDefinesID(self.Name, icon.Cfg._Name)
    if icon.IsActive then
        UIUtils.SetTextByEnum(self.Level, "C_SKILLTF_LEVEL", icon.Cfg.Level, icon.Cfg.MaxLevel)
        UnityUtils.SetLocalPositionY(self.CurGo.transform, self.Title1PosY)
        UnityUtils.SetLocalPositionY(self.NextGo.transform, self.Title2PosY)
        local _nextCfg = DataConfig.DataSkillMeridianNew[icon.Cfg.Id + 1]
        if _nextCfg == nil then
            --Full level
            UIUtils.SetTextByStringDefinesID(self.CurDesc, icon.Cfg._Desc)
            self.CurGo:SetActive(true)
            self.NextGo:SetActive(false)
            self.LevelGo:SetActive(false)
            self.MaxLevelGo:SetActive(true)
        else
            -- Not full
            UIUtils.SetTextByStringDefinesID(self.CurDesc, icon.Cfg._Desc)
            UIUtils.SetTextByStringDefinesID(self.NextDesc, _nextCfg._Desc)
            self.CurGo:SetActive(true)
            self.NextGo:SetActive(true)
            self.LevelGo:SetActive(true)
            self.MaxLevelGo:SetActive(false)
            local _itemParams = Utils.SplitNumber(_nextCfg.NeedValue, "_")
            _costValue = _itemParams[2]
            _costItem = DataConfig.DataItem[_itemParams[1]]
        end
    else
        UIUtils.SetTextByEnum(self.Level, "C_SKILLTF_LEVEL", 0, icon.Cfg.MaxLevel)
        UIUtils.SetTextByStringDefinesID(self.NextDesc, icon.Cfg._Desc)
        UnityUtils.SetLocalPositionY(self.NextGo.transform, self.Title1PosY)
        self.CurGo:SetActive(false)
        self.NextGo:SetActive(true)
        self.LevelGo:SetActive(true)
        self.MaxLevelGo:SetActive(false)
        local _itemParams = Utils.SplitNumber(icon.Cfg.NeedValue, "_")
        _costValue = _itemParams[2]
        _costItem = DataConfig.DataItem[_itemParams[1]]
    end
    self.Icon:UpdateIcon(icon.Cfg.Icon)
    local _parentCfg = DataConfig.DataSkillMeridianNew[icon.Cfg.NeedParentId]
    if _parentCfg ~= nil then
        local _activeId = GameCenter.PlayerSkillSystem:GetMeridianActvieID(_parentCfg.MeridianId)
        if _activeId >= icon.Cfg.NeedParentId then
            UIUtils.SetTextByEnum(self.NeedParent, "C_SKILLTF_NEEDPARENT", _parentCfg.Name, _parentCfg.Level)
        else
            UIUtils.SetTextByEnum(self.NeedParent, "C_SKILLTF_NEEDPARENT2", _parentCfg.Name, _parentCfg.Level)
        end
    else
        UIUtils.ClearText(self.NeedParent)
    end
    if _costItem ~= nil then
        UIUtils.SetTextByNumber(self.CostValue, _costValue)
        local _haveValue = GameCenter.ItemContianerSystem:GetEconomyWithType(_costItem.Id)
        UIUtils.SetTextByNumber(self.HaveValue, _haveValue)
        UIUtils.SetColorByString(self.HaveValue, _haveValue >= _costValue and "#00e2a5" or "#f37b11")
        self.CostIcon:UpdateIcon(_costItem.Icon)
        self.HaveIcon:UpdateIcon(_costItem.Icon)
    end
end

function UIOccskillMerLevelUpPanel:Hide()
    --Play Close animation
    self.AnimModule:PlayDisableAnimation()
    self.IsVisible = false
end

function UIOccskillMerLevelUpPanel:OnCloseBtnClick()
    self:Hide()
end

function UIOccskillMerLevelUpPanel:OnLevelUPBtnClick()
    local icon = self.SelectIcon
    local _activeCfg = nil
    if icon.IsActive then
        local _nextCfg = DataConfig.DataSkillMeridianNew[icon.Cfg.Id + 1]
        if _nextCfg ~= nil then
            _activeCfg = _nextCfg
        end
    else
        _activeCfg = icon.Cfg
    end
    if _activeCfg == nil then
        return
    end
    local _parentCfg = DataConfig.DataSkillMeridianNew[_activeCfg.NeedParentId]
    if _parentCfg ~= nil then
        local _activeId = GameCenter.PlayerSkillSystem:GetMeridianActvieID(_parentCfg.MeridianId)
        if _activeId < _activeCfg.NeedParentId then
            --The parent node is not activated
            Utils.ShowPromptByEnum("C_SKILLTF_PARENT_BUZHU", _parentCfg.Name, _parentCfg.Level)
            return
        end
    end
    local _itemParams = Utils.SplitNumber(_activeCfg.NeedValue, "_")
    local _costValue = _itemParams[2]
    local _costItem = DataConfig.DataItem[_itemParams[1]]
    local _haveValue = GameCenter.ItemContianerSystem:GetEconomyWithType(_costItem.Id)
    if _costValue > _haveValue then
        --Insufficient currency
        Utils.ShowPromptByEnum("ConsumeNotEnough", _costItem.Name)
        return
    end
    GameCenter.Network.Send("MSG_Skill.ReqActivateMeridian", {meridianID = _activeCfg.Id})
end

return UIOccskillMerLevelUpPanel
