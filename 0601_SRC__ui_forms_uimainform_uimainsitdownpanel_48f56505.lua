-- author:
-- Date: 2021-02-24
-- File: UIMainSitDownPanel.lua
-- Module: UIMainSitDownPanel
-- Description: Main interface meditation page
------------------------------------------------
local L_UIMainSubBasePanel = require "UI.Forms.UIMainForm.UIMainSubBasePanel"

local UIMainSitDownPanel = {
    RootGo = nil,
    SitDownBtn = nil,
    SitDownInfo = nil,
    SitDownTime = nil,
    SitDownGettedExp = nil,
    ExpShowRoot = nil,
    SitDownTexture = nil,
}

function UIMainSitDownPanel:OnRegisterEvents()
    -- Meditation message update
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_SITDOWN_START, self.OnStartSitDown, self)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_SITDOWN_END, self.OnEndSitDown, self)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_SHOWEXP_UPDATE, self.OnUpdateSitDownExp, self)
    -- Feature updates
    self:RegisterEvent(LogicEventDefine.EID_EVENT_FUNCTION_UPDATE, self.OnUpdateFunc, self)
end

function UIMainSitDownPanel:OnFirstShow(trans, parent, rootForm)
    setmetatable(self, {__index = L_UIMainSubBasePanel.New()})
    self:BaseFirstShow(trans, parent, rootForm)

    self.RootGo = UIUtils.FindGo(trans, "Root")
    self.SitDownBtn = UIUtils.FindBtn(trans, "Root/SitDownBtn")
    self.SitDownInfo = UIUtils.FindTrans(trans, "Root/SitDownInfo/Root")
    self.AnimModule:AddTransNormalAnimation(self.SitDownInfo, 30, 0.3)
    self.SitDownTime = UIUtils.FindLabel(trans, "Root/SitDownInfo/Root/SitDownTime")
    self.SitDownGettedExp = UIUtils.FindLabel(trans, "Root/SitDownInfo/Root/ExpGetted")
    self.ExpShowRoot = UIUtils.FindGo(trans, "Root/ExpShow")
    self.SitDownTexture = UIUtils.FindTex(trans, "Root/SitDownInfo/Root/BgTexture")
    UIUtils.AddBtnEvent(self.SitDownBtn, self.OnSitDownBtnClick, self)
    return self
end

function UIMainSitDownPanel:OnShowAfter()
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp ~= nil and _lp.IsSitDown then
        self:OnStartSitDown(nil, nil)
    else
        self:OnEndSitDown(nil, nil)
    end
    self:OnUpdateFunc(GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.SitDown))
    self.RootForm.CSForm:LoadTexture(self.SitDownTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_hangup_bg3"))
    self:OnUpdateSitDownExp(0, nil)
end

function UIMainSitDownPanel:OnHideBefore()
end

function UIMainSitDownPanel:OnStartSitDown(obj, sender)
    self.AnimModule:PlayShowAnimation(self.SitDownInfo);
end
function UIMainSitDownPanel:OnEndSitDown(obj, sender)
    self.AnimModule:PlayHideAnimation(self.SitDownInfo);
end
function UIMainSitDownPanel:OnUpdateSitDownExp(addedExp, sender)
    if addedExp == nil then
        return
    end
    if addedExp > 0 then
        local _expCfg = DataConfig.DataItem[ItemTypeCode.Exp]
        if _expCfg ~= nil then
            local _countText = CommonUtils.CovertToBigUnit(addedExp, 0)
            local _expAddRate = GameCenter.SitDownSystem.CurExpAddRate
            local _showText = UIUtils.CSFormat("{0} {1}(+{2:F0}%)", _expCfg.Name, _countText, _expAddRate)
            GameCenter.PushFixEvent(UIEventDefine.UIMSGTIPS_SHOWINFO, _showText)
        end
    end
   
    local _allTime = GameCenter.HeartSystem.ServerTime - GameCenter.SitDownSystem.SitDownStartTime
    if _allTime < 0 then
        _allTime = 0
    end
    local _h = math.floor(_allTime / 3600)
    _allTime = _allTime % 3600
    local _m = math.floor(_allTime / 60)
    _allTime = _allTime % 60
    UIUtils.SetTextByEnum(self.SitDownTime, "HOOK_HOURMINUTE", _h, _m)
    UIUtils.SetTextByNumber(self.SitDownGettedExp, GameCenter.SitDownSystem.TotalExp, true, 0)
end

function UIMainSitDownPanel:OnUpdateFunc(funcInfo, sender)
    if funcInfo == nil then
        return
    end
    local _funcId = funcInfo.ID
    if _funcId == FunctionStartIdCode.SitDown then
        self.RootGo:SetActive(funcInfo.IsVisible)
    end
end

function UIMainSitDownPanel:OnSitDownBtnClick()
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end
    if _lp.IsSitDown then
        -- End meditation
        GameCenter.SitDownSystem:ReqEndSitDown()
    else
        if _lp:CanSitDown() then
            GameCenter.SitDownSystem:ReqStartSitDown()
        else
            Utils.ShowPromptByEnum("C_CURSTATE_CANNOT_SITDOWN")
        end
    end
end

return UIMainSitDownPanel