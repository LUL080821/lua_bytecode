------------------------------------------------
-- author:
-- Date: 2021-02-27
-- File: UIMainMiniMapPanel.lua
-- Module: UIMainMiniMapPanel
-- Description: Home interface minimap pagination
------------------------------------------------

local L_UIMainSubBasePanel = require "UI.Forms.UIMainForm.UIMainSubBasePanel"

local UIMainMiniMapPanel = {
    MapBtn = nil,
    MapName = nil,
    MapLine = nil,
}
-- Register Events
function UIMainMiniMapPanel:OnRegisterEvents()
    -- Update the line
    self:RegisterEvent(LogicEventDefine.EID_EVENT_PLYAER_ENTER_SCENE, self.OnUpdateLineAndName, self)
end
function UIMainMiniMapPanel:OnFirstShow(trans, parent, rootForm)
    setmetatable(self, {__index = L_UIMainSubBasePanel.New()})
    self:BaseFirstShow(trans, parent, rootForm)
    self.MapBtn = UIUtils.FindBtn(trans, "MapBtn")
    UIUtils.AddBtnEvent(self.MapBtn, self.OnOpenMapBtnClick, self)
    self.MapName = UIUtils.FindLabel(trans, "MapBtn/Name")
    self.MapLine = UIUtils.FindLabel(trans, "SwitchLineBtn/Name")
end
-- After display
function UIMainMiniMapPanel:OnShowAfter()
    self:OnUpdateLineAndName(nil)
end

function UIMainMiniMapPanel:OnHideAfter()
    Debug.Log("-----------> UIMainMiniMapPanel:OnHideAfter")
end
-- Open the map
function UIMainMiniMapPanel:OnOpenMapBtnClick()
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.AreaMap)
end

function UIMainMiniMapPanel:OnUpdateLineAndName()
    local _mapCfg = GameCenter.MapLogicSystem.MapCfg
    local _activeScene = GameCenter.GameSceneSystem.ActivedScene
    if _mapCfg ~= nil and _activeScene ~= nil then
        UIUtils.SetTextByStringDefinesID(self.MapName, _mapCfg._Name)
        if GameCenter.MapLogicSwitch.IsCopyMap then
            self.MapLine.gameObject:SetActive(false)
        else
            self.MapLine.gameObject:SetActive(true)
            UIUtils.SetTextByEnum(self.MapLine, "C_MIAN_MINIMAPLINE", _activeScene.LineID)
        end
    end
end

return UIMainMiniMapPanel