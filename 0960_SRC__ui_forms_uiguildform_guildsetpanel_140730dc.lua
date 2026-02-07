------------------------------------------------
-- author:
-- Date: 2019-05-24
-- File: GuildSetPanel.lua
-- Module: GuildSetPanel
-- Description: Sect setting interface
------------------------------------------------
local L_CheckBox = require "UI.Components.UICheckBox"
local L_AddReduce = require "UI.Components.UIAddReduce"
local GuildSetPanel = {
    Trans = nil,
    Go = nil,
    -- Level input control
    LevelInput = nil,
    -- Level input control
    PowerInput = nil,
    -- Add to the minimum and maximum level of the sect, configured by the configuration table
    GlobalMin = 1,
    GlobalMax = 0,
    MaxPower = 999999999,
    CurSetLevel = 0,
    CurSetPower = 0,
    -- background
    -- BackTexture = nil,
}

-- Create a new object
function GuildSetPanel:OnFirstShow(trans, parent)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m.CSForm = parent
    _m:FindAllComponents()
    _m.IsVisible = false
    _m.Go:SetActive(false)
    return _m
end

-- Find controls
function GuildSetPanel:FindAllComponents()
    self.BackTexture = UIUtils.FindTex(self.Trans, "Texture")
    self.LevelInput = L_AddReduce:OnFirstShow(UIUtils.FindTrans(self.Trans, "LevelAddReduce"))
    self.LevelInput:SetCallBack(Utils.Handler(self.OnClickAddReduce, self), Utils.Handler(self.OnClickAddReduceInput, self))
    self.PowerInput = L_AddReduce:OnFirstShow(UIUtils.FindTrans(self.Trans, "PowerAddReduce"))
    self.PowerInput:SetCallBack(Utils.Handler(self.OnClickAddReducePower, self), Utils.Handler(self.OnClickAddReduceInputPower, self))
    local _btn = UIUtils.FindBtn(self.Trans, "SaveBtn")
    UIUtils.AddBtnEvent(_btn, self.OnSaveBtnClick, self)
    local _closeBtn = UIUtils.FindBtn(self.Trans, "CloseBtn")
    UIUtils.AddBtnEvent(_closeBtn, self.Close, self)

    local _global = DataConfig.DataGlobal[1198]
    if _global ~= nil then
        self.GlobalMin = tonumber(_global.Params)
    end
    _global = DataConfig.DataGlobal[1099]
    if _global ~= nil then
        self.GlobalMax = tonumber(_global.Params)
    end
end

function GuildSetPanel:Open()
    self.Go:SetActive(true)
    self:OnUpdateForm()
    self.CSForm:LoadTexture(self.BackTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI,"tex_n_d_3"))
    self.IsVisible = true
end

function GuildSetPanel:Close()
    self.Go:SetActive(false)
    self.IsVisible = false
end
-- Save settings
function GuildSetPanel:OnSaveBtnClick()
    if self.CurSetLevel < self.GlobalMin then
        Utils.ShowPromptByEnum("UI_GUILD_LEVELISERROR", self.GlobalMin)
        return
    end
    local _info = GameCenter.GuildSystem.GuildInfo
    local _req = {
        fightPoint = self.CurSetPower,
        isAutoApply = _info.isAutoJoin,
        lv = self.CurSetLevel,
        notice = _info.notice,
        icon = _info.icon
    }
    GameCenter.Network.Send("MSG_Guild.ReqChangeGuildSetting", _req)
end

-- Increase and decrease combat power
function GuildSetPanel:OnClickAddReducePower(add)
    if add then
        self.CurSetPower = self.CurSetPower + 10000
    else
        self.CurSetPower = self.CurSetPower - 10000
    end

    self:FixPower()
    self.PowerInput:SetValueLabel(tostring(self.CurSetPower))
end
-- Enter a click to open the numeric input keyboard
function GuildSetPanel:OnClickAddReduceInputPower()
    GameCenter.NumberInputSystem:OpenInput(self.MaxPower, Vector3(180, 0, 0), function(num)
        if num < 1 then
            num = 1
        end
        self.CurSetPower = num
        self.PowerInput:SetValueLabel(tostring(num))
    end, 0, function()
        self:FixPower()
        self.PowerInput:SetValueLabel(tostring(self.CurSetPower))
    end)
end
-- Level addition and subtraction
function GuildSetPanel:OnClickAddReduce(add)
    if add then
        self.CurSetLevel = self.CurSetLevel + 5
    else
        self.CurSetLevel = self.CurSetLevel - 5
    end

    self:FixLevel()
    self.LevelInput:SetValueLabel(CommonUtils.GetLevelDesc(self.CurSetLevel))
end
-- Enter a click to open the numeric input keyboard
function GuildSetPanel:OnClickAddReduceInput()
    GameCenter.NumberInputSystem:OpenInput(self.GlobalMax, Vector3(180, -80, 0), function(num)
        if num < 1 then
            num = 1
        end
        self.CurSetLevel = num
        self.LevelInput:SetValueLabel(CommonUtils.GetLevelDesc(num))
    end, 0, function()
        self:FixLevel()
        self.LevelInput:SetValueLabel(CommonUtils.GetLevelDesc(self.CurSetLevel))
    end)
end
-- Level judgment: whether the upper and lower limits exceed
function GuildSetPanel:FixLevel()
    if self.CurSetLevel < self.GlobalMin then
        self.CurSetLevel = self.GlobalMin
    end
    if self.CurSetLevel > self.GlobalMax then
        self.CurSetLevel = self.GlobalMax
    end
end
-- Determination of combat power: whether the upper and lower limits exceed
function GuildSetPanel:FixPower()
    if self.CurSetPower < 1 then
        self.CurSetPower = 1
    end
    if self.CurSetPower > self.MaxPower then
        self.CurSetPower = self.MaxPower
    end
end

-- Load interface data
function GuildSetPanel:OnUpdateForm()
    local _info = GameCenter.GuildSystem.GuildInfo
    if _info == nil then
        return
    end
    self.CurSetLevel = _info.limitLv
    self.CurSetPower = _info.limitFight
    self.LevelInput:SetValueLabel(CommonUtils.GetLevelDesc(_info.limitLv))
    self.PowerInput:SetValueLabel(tostring(self.CurSetPower))
end
return GuildSetPanel