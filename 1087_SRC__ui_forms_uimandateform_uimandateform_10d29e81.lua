------------------------------------------------
--author:
--Date: 2021-02-19
--File: UIMandateForm.lua
--Module: UIMandateForm
--Description: Hang-up prompt interface
------------------------------------------------

--//Module definition
local UIMandateForm = {
    AutoTitle =nil,
    DianTimer = 0,
    CurDianCount = 0,
    OriTitle = nil,
    StopTips = nil,
}

--Inherit the Form function
function UIMandateForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UIMandateForm_OPEN, self.OnOpen)
    self:RegisterEvent(UIEventDefine.UIMandateForm_CLOSE, self.OnClose)
end

function UIMandateForm:OnFirstShow()
    local _trans = self.Trans
    self.AutoTitle = UIUtils.FindLabel(_trans, "Center/ShowLabel")
    self.CSForm.UIRegion = UIFormRegion.MainRegion
    self.CSForm.FormType = CS.Thousandto.Plugins.Common.UIFormType.Hint
    self.OriTitle = UIUtils.GetText(self.AutoTitle)
    self.StopTips = UIUtils.FindGo(_trans, "Center/StopTips")
    self.StopTips:SetActive(false)
end

function UIMandateForm:OnShowAfter()
    self.CurDianCount = 0
    self.DianTimer = 0.5
    UIUtils.SetTextByString(self.AutoTitle, self.OriTitle)
    self.StopTips:SetActive(UnityUtils.IsUseUsePCMOdel())
end

function UIMandateForm:OnHideBefore()
    GameCenter.MandateSystem.IsOpenMandateUI = false
end

--Open event
function UIMandateForm:OnOpen(obj, sender)
    self.CSForm:Show(sender)
    GameCenter.MandateSystem.IsOpenMandateUI = true
end

--Close event
function UIMandateForm:OnClose(obj, sender)
    self.CSForm:Hide()
end
function UIMandateForm:Update()
    self.DianTimer = self.DianTimer - Time.GetDeltaTime()
    if self.DianTimer <= 0 then
        self.DianTimer = 0.5
        self.CurDianCount = self.CurDianCount + 1
        if self.CurDianCount > 3 then
            self.CurDianCount = 0
        end
        if self.CurDianCount == 3 then
            UIUtils.SetTextByString(self.AutoTitle, self.OriTitle .. "...")
        elseif self.CurDianCount == 2 then
            UIUtils.SetTextByString(self.AutoTitle, self.OriTitle .. "..")
        elseif self.CurDianCount == 1 then
            UIUtils.SetTextByString(self.AutoTitle, self.OriTitle .. ".")
        else
            UIUtils.SetTextByString(self.AutoTitle, self.OriTitle)
        end
    end
end

return UIMandateForm
