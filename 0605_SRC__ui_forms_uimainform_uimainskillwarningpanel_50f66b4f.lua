------------------------------------------------
-- author:
-- Date: 2021-02-26
-- File: UIMainSkillWarningPanel.lua
-- Module: UIMainSkillWarningPanel
-- Description: Main interface skill warning interface
------------------------------------------------

local L_UIMainSubBasePanel = require "UI.Forms.UIMainForm.UIMainSubBasePanel"

local UIMainSkillWarningPanel = {
    DescLabel = nil,
    Timer = 0,
    DelayTimer = 0,
}

function UIMainSkillWarningPanel:OnFirstShow(trans, parent, rootForm)
    setmetatable(self, {__index = L_UIMainSubBasePanel.New()})
    self:BaseFirstShow(trans, parent, rootForm)
    self.DescLabel = UIUtils.FindLabel(trans, "Desc")
end
function UIMainSkillWarningPanel:OpenWarning(showText, delayTime, lifeTime)
    self.DelayTimer = delayTime
    self.Timer = lifeTime
    UIUtils.SetTextByString(self.DescLabel, showText)
    self.DescLabel.gameObject:SetActive(delayTime <= 0)
    self:Open()
end

function UIMainSkillWarningPanel:Update(dt)
    if not self.IsVisible then
        return
    end
    if self.DelayTimer > 0 then
        self.DelayTimer = self.DelayTimer - dt
        if self.DelayTimer <= 0 then
            self.DescLabel.gameObject:SetActive(true)
        else
            return
        end
    end
    if self.Timer > 0 then
        self.Timer = self.Timer - dt
        if self.Timer <= 0 then
            self:Close()
        end
    end
end

return UIMainSkillWarningPanel