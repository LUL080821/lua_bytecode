--==============================--
-- author:
-- Date: 2019-07-03
-- File: UICommonBarForm.lua
-- Module: UICommonBarForm
-- Description: Public reading interface
--==============================--

local UICommonBarForm = {
    -- Progress bar
    Progress = nil,
    -- describe
    DescLabel = nil,
    -- time
    TimeLabel = nil,
    --
    RunTime= 0,
};

-- Register event functions and provide them to the CS side to call.
function UICommonBarForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UICommonBarForm_OPEN, self.OnOpen)
    self:RegisterEvent(UIEventDefine.UICommonBarForm_CLOSE, self.OnClose)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_UPDATECOMMON_PROGRESS, self.OnUpdateProgress);
end

-- The first display function is provided to the CS side to call.
function UICommonBarForm:OnFirstShow()
    self.CSForm:AddAlphaAnimation();
    self.Progress = UIUtils.FindProgressBar(self.Trans, "Buttom/Progress");
    self.DescLabel = UIUtils.FindLabel(self.Trans, "Buttom/Des");
    self.TimeLabel = UIUtils.FindLabel(self.Trans, "Buttom/Des/Time");
    self.CSForm.UIRegion = UIFormRegion.BottomRegion;
end

-- Turn on the event
function UICommonBarForm:OnOpen(obj, sender)
    self.CSForm:Show(nil);
    self.RunTime = obj;
    UIUtils.SetTextByString(self.DescLabel, sender)
    UIUtils.SetTextByEnum(self.TimeLabel, "COMMONBAR_DES", self.RunTime);
end

-- Close Event
function UICommonBarForm:OnClose(obj, sender)
    self.CSForm:Hide()
end

-- Progress refresh time
function UICommonBarForm:OnUpdateProgress(obj, sender)
    self.Progress.value = obj;
    UIUtils.SetTextByEnum(self.TimeLabel, "COMMONBAR_DES", obj * self.RunTime)
end

return UICommonBarForm;
