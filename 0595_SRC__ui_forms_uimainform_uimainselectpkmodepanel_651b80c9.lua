------------------------------------------------
-- author:
-- Date: 2021-02-27
-- File: UIMainSelectPkModePanel.lua
-- Module: UIMainSelectPkModePanel
-- Description: Select pk mode paging in the main interface
------------------------------------------------

local L_UIMainSubBasePanel = require "UI.Forms.UIMainForm.UIMainSubBasePanel"

local PKIconMap = {

    [PKMode.PeaceMode]     = "n_a_61_green",
    [PKMode.AllMode]       = "n_a_61",
    [PKMode.SelfServer]    = "n_a_61_blue",
    [PKMode.GuildMode]     = "n_a_61_yellow",
    [PKMode.SceneCampMode] = "n_a_61",
}

local UIMainSelectPkModePanel = {
    SelectBtn = nil,
    CurSelectCamp = nil,
    PKIcon = nil,
}
-- Register Events
function UIMainSelectPkModePanel:OnRegisterEvents()
    -- PK mode
    self:RegisterEvent(LogicEventDefine.EID_EVENT_PKMODE_CHANGED, self.OnSetPkMode, self)
end

function UIMainSelectPkModePanel:OnFirstShow(trans, parent, rootForm)
    setmetatable(self, {__index = L_UIMainSubBasePanel.New()})
    self:BaseFirstShow(trans, parent, rootForm)

    self.SelectBtn = UIUtils.FindBtn(trans, "SelectBtn")
    UIUtils.AddBtnEvent(self.SelectBtn, self.OnSelectBtnClick, self)
    self.CurSelectCamp = UIUtils.FindLabel(trans, "SelectBtn/CampValue")

    self.PKIcon = UIUtils.FindTrans(trans, "SelectBtn/Icon")
end

-- After display
function UIMainSelectPkModePanel:OnShowAfter()
   self:OnSetPkMode(nil, nil)
end
function UIMainSelectPkModePanel:OnSetPkMode(obj, sender)
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end
    local _curPkState = _lp.PropMoudle.PkModel
    if _curPkState == PKMode.PeaceMode then
        UIUtils.SetTextByEnum(self.CurSelectCamp, "C_MAIN_PKMODE_HEPING")

    elseif _curPkState == PKMode.AllMode then
        UIUtils.SetTextByEnum(self.CurSelectCamp, "C_MAIN_PKMODE_QUANTI")
    elseif _curPkState == PKMode.SelfServer then
        UIUtils.SetTextByEnum(self.CurSelectCamp, "UI_SHENGTIANCHENG_LOCAL")
    elseif _curPkState == PKMode.SceneCampMode then
        UIUtils.SetTextByEnum(self.CurSelectCamp, "C_MAIN_PKMODE_FORCE")
    elseif _curPkState == PKMode.GuildMode then
        UIUtils.SetTextByEnum(self.CurSelectCamp, "C_MAIN_PKMODE_BANGHUI")
    end
    self:UpdatePkIcon(_curPkState)

end


function UIMainSelectPkModePanel:UpdatePkIcon(state)
    local icon = PKIconMap[state]
    if icon then
        UIUtils.SetUISprite(self.PKIcon, icon)
    else
        -- Debug.LogError("PKIcon not found, state =", state)
    end
end



function UIMainSelectPkModePanel:OnSelectBtnClick()
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end
    local _mapCfg = GameCenter.MapLogicSystem.MapCfg
    -- This map cannot switch camps
    if _mapCfg.FightChange == 0 then
        Utils.ShowPromptByEnum("C_CANNOT_SWITCH_PKMODE")
        return
    end
    local _curPkState = _lp.PropMoudle.PkModel
    -- Cannot switch in scene camp attack mode
    if _curPkState == PKMode.SceneCampMode then
        Utils.ShowPromptByEnum("C_CANNOT_SWITCH_PKMODE")
        return
    end
    GameCenter.PushFixEvent(UIEventDefine.UISelectPKModeForm_OPEN)
end

return UIMainSelectPkModePanel