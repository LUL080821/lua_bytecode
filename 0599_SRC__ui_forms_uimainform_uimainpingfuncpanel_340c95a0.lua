------------------------------------------------
-- author:
-- Date: 2021-02-26
-- File: UIMainPingFuncPanel.lua
-- Module: UIMainPingFuncPanel
-- Description: Main interface delay paging
------------------------------------------------

local L_UIMainSubBasePanel = require "UI.Forms.UIMainForm.UIMainSubBasePanel"
local L_UnityUtils = require("Common.CustomLib.Utility.UnityUtils")
local L_FrameMonitor = CS.Thousandto.Core.Support.FrameMonitor

local UIMainPingFuncPanel = {
    PingIcon = nil,
    PingText = nil,
    GreenLabel = nil,
    OrangeLabel = nil,
    RedLabel = nil,
    -- Refresh ping every 5 seconds
    Timer = 0,
    FpsLabel = nil,
    FpsGo = nil,
    FpsTimer = 0,
}
-- Register Events
function UIMainPingFuncPanel:OnRegisterEvents()
    self:RegisterEvent(LogicEventDefine.EID_EVENT_SHOW_MAINFPS, self.ShowFPS, self)
end

function UIMainPingFuncPanel:OnFirstShow(trans, parent, rootForm)
    setmetatable(self, {__index = L_UIMainSubBasePanel.New()})
    self:BaseFirstShow(trans, parent, rootForm)
    self.PingIcon = UIUtils.FindSpr(trans, "Tag")
    self.PingText = UIUtils.FindLabel(trans, "Label")
    self.GreenLabel = UIUtils.FindLabel(trans, "ColorGreen")
    self.OrangeLabel = UIUtils.FindLabel(trans, "ColorOrange")
    self.RedLabel = UIUtils.FindLabel(trans, "ColorRed")
    self.FpsGo = UIUtils.FindGo(trans, "FPS")
    self.FpsLabel = UIUtils.FindLabel(trans, "FPS/FPSValue")
    if L_UnityUtils.UNITY_EDITOR() then
        self.FpsGo:SetActive(true)
    else
        self.FpsGo:SetActive(false)
    end
end

-- After display
function UIMainPingFuncPanel:OnShowAfter()
    self.Timer = 5
end
function UIMainPingFuncPanel:ShowFPS(obj, sender)
    if self.FpsGo.activeSelf then
        return
    end
    self.FpsGo:SetActive(true)
    UIUtils.SetTextByNumber(self.FpsLabel, math.floor(L_FrameMonitor.RealFPS))
end


function UIMainPingFuncPanel:Update(dt)
    if not self.IsVisible then
        return
    end
    if self.FpsGo.activeSelf then
        self.FpsTimer = self.FpsTimer + dt
        if self.FpsTimer >= 1 then
            self.FpsTimer = 0
            local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
            if _lp ~= nil then
                UIUtils.SetTextFormat(self.FpsLabel, "{0}   {1},{2}", math.floor(L_FrameMonitor.RealFPS), math.floor(_lp.Position2d.x), math.floor(_lp.Position2d.y))
            end
        end
    end
    if self.Timer >= 5 then
        self.Timer = 0
        local _pingValue = GameCenter.HeartSystem.NetPingValue
        if _pingValue > 199 then -- Red delay
            if _pingValue >= 9999 then
                _pingValue = 9999
            end
            self.PingIcon.color = self.RedLabel.color
            self.PingText.color = self.RedLabel.color
        elseif _pingValue > 100 then -- Orange delay
            self.PingIcon.color = self.OrangeLabel.color
            self.PingText.color = self.OrangeLabel.color
        else -- Green delay
            self.PingIcon.color = self.GreenLabel.color
            self.PingText.color = self.GreenLabel.color
        end
        UIUtils.SetTextFormat(self.PingText, "{0}{1}", _pingValue, DataConfig.DataMessageString.Get("C_PING_TIME_MM"))
    else
        self.Timer = self.Timer + dt
    end
end

return UIMainPingFuncPanel