
--==============================--
-- Author: [name]
-- Date: 2019-10-29 09:38:40
-- File: LingTiOpenTab.lua
-- Module: LingTiOpenTab
-- Description: {Spirit Unblock Tab Component!}
--==============================--

local LingTiOpenTab = {
    Index = 0,
    Form = nil,
    Trans = nil,
    -- Select
    SelectGO = nil,
    -- Red dot
    RedPoint = nil,
    -- name
    Name = nil,
    -- Click the button
    Btn = nil,
}

function LingTiOpenTab:New(trans, form)
    if trans == nil then
        return
    end
    local _m = Utils.DeepCopy(self)
    _m.Form = form
    _m.Trans = trans
    _m.SelectGO = UIUtils.FindGo(trans, "Select")
    _m.RedPoint = UIUtils.FindGo(trans, "RedPoint")
    _m.BackSpr = UIUtils.FindSpr(trans)
    _m.Name = UIUtils.FindLabel(trans, "NormalName")
    _m.Btn = UIUtils.FindBtn(trans)
    UIUtils.AddBtnEvent(_m.Btn,_m.OnClickBtn, _m)
    return _m
end

-- Set up components
function LingTiOpenTab:SetCmp(data, index)
    self.SelectGO:SetActive(false)
    self.RedPoint:SetActive(false)

    self.Index = data
    self.OpenLv = index[1].Cfg.Level
    UIUtils.SetTextByStringDefinesID(self.Name, index[1].Cfg._Name)
    self.State = GameCenter.LingTiSystem:GetUnlockStateByGrade(data)
    if self.State then
        self.IsActive = false
        if self.State == LingtiUnlockState.WaitForFinish or self.State == LingtiUnlockState.Finish then
            self.IsActive = true
        end
        self.BackSpr.IsGray = not self.IsActive
        if GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.LingtiFanTai, data) and self.State == LingtiUnlockState.WaitForFinish then
            self.RedPoint:SetActive(true)
        end
    end
    self.Trans.gameObject:SetActive(true)
end

-- Set red dots
function LingTiOpenTab:SetRedPoint()
end

function LingTiOpenTab:SetDisActive()
end

function LingTiOpenTab:SetSelect(b)
    self.SelectGO:SetActive(b)
end

-- Click the button
function LingTiOpenTab:OnClickBtn()
    if self.IsActive then
        if self.Form ~= nil and self.Form.CurTabId ~= self.Index then
            self.Form.CurTabId = self.Index
            self.Form:OnClickTab()
        end
    else
        if self.State == LingtiUnlockState.LastLock then
		    Utils.ShowPromptByEnum("C_UI_LINGTI_EXTEM_CON3")
        else
		    Utils.ShowPromptByEnum("C_UI_LINGTI_EXTEM_CON4", self.OpenLv)
        end
    end
end

return LingTiOpenTab;
