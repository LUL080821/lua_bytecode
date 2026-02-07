------------------------------------------------
-- author:
-- Date: 2021-02-27
-- File: UIMainWifiAndTimePanel.lua
-- Module: UIMainWifiAndTimePanel
-- Description: The main interface time display paging
------------------------------------------------

local L_UIMainSubBasePanel = require "UI.Forms.UIMainForm.UIMainSubBasePanel"
local HardwareManager = CS.Thousandto.Core.Base.HardwareManager;

local UIMainWifiAndTimePanel = {
    TimeLabel = nil,
    WifiGo = nil,
    FourGGo = nil,
    BatteryIcon = nil,
    CheckTimer = 0,
    BatteryCheckTimer = 0,
}
-- Register Events
function UIMainWifiAndTimePanel:OnRegisterEvents()
end

function UIMainWifiAndTimePanel:OnFirstShow(trans, parent, rootForm)
    setmetatable(self, {__index = L_UIMainSubBasePanel.New()})
    self:BaseFirstShow(trans, parent, rootForm)

    self.TimeLabel = UIUtils.FindLabel(trans, "Label")
    self.WifiGo = UIUtils.FindGo(trans, "Wifi")
    self.FourGGo = UIUtils.FindGo(trans, "4G")
    self.BatteryIcon = UIUtils.FindSpr(trans, "Battery/Front")
    self.BatteryCheckTimer = 57
end

-- After display
function UIMainWifiAndTimePanel:OnShowAfter()
    self:UpdateNetState(6)
end
function UIMainWifiAndTimePanel:ShowFPS(obj, sender)
end
function UIMainWifiAndTimePanel:Update(dt)
    if not self.IsVisible then
        return
    end
    -- Refresh the power
    self:UpdateBatteryValue(dt)
    -- Refresh network status
    self:UpdateNetState(dt)
    -- Refresh local time
    self:UpdateTime()
end

function UIMainWifiAndTimePanel:UpdateTime()
    if Time.GetFrameCount() % 30 ~= 0 then
        return
    end
    UIUtils.SetTextByString(self.TimeLabel, Time.StampToDateTimeNotZone(math.floor(GameCenter.HeartSystem.ServerZoneTime), "HH:mm"))
end
function UIMainWifiAndTimePanel:UpdateBatteryValue(dt)
    self.BatteryCheckTimer = self.BatteryCheckTimer + dt
    if self.BatteryCheckTimer >= 60 then
        self.BatteryCheckTimer = 0
        local _curPower = HardwareManager.DeviceInfo:GetBatteryPower()
        if _curPower < 0.1 then
            _curPower = 0.1
        end
        self.BatteryIcon.fillAmount = _curPower
    end
end
function UIMainWifiAndTimePanel:UpdateNetState(dt)
    self.CheckTimer = self.CheckTimer + dt
    if self.CheckTimer < 5 then
        return
    end
    self.CheckTimer = 0
    local _netState = LogicAdaptor.GetCurInternetReachability()
    if _netState == 1 then
        -- 4G status
        self.FourGGo:SetActive(true)
        self.WifiGo:SetActive(false)
    elseif _netState == 2 then
        -- Wifi status
        self.FourGGo:SetActive(false)
        self.WifiGo:SetActive(true)
    else
        -- No network
        self.FourGGo:SetActive(false)
        self.WifiGo:SetActive(false)
    end
end

return UIMainWifiAndTimePanel