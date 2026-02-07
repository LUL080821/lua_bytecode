------------------------------------------------
-- author:
-- Date: 2021-02-27
-- File: UIMainExpPanel.lua
-- Module: UIMainExpPanel
-- Description: Main interface experience bar
------------------------------------------------

local L_UIMainSubBasePanel = require "UI.Forms.UIMainForm.UIMainSubBasePanel"
local L_RoleBaseAttribute = CS.Thousandto.Code.Global.RoleBaseAttribute

local UIMainExpPanel = {
    ExpBar = nil,
    ExpBarSpr = nil,
    ExpBackSpr = nil,
    IsNeedUpdateExp = false,
    LimitLevelGo = nil,
    LimitLabel = nil,
    LimitToggle = nil,
    LimitClose = nil,
    LimitLevels = List:New(),
    LimitDescs = List:New(),
    ShowLimitTips = true,
    FrontCheckMapID = 0,
    LightList = List:New(),
    LightTrans = nil,
}
-- Register Events
function UIMainExpPanel:OnRegisterEvents()
    self:RegisterEvent(LogicEventDefine.EID_EVENT_PLAYER_BASE_ATTR_CHANGED, self.OnPropChanged, self)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_ENTERMAP, self.OnChangeMap, self)
end

function UIMainExpPanel:OnFirstShow(trans, parent, rootForm)
    setmetatable(self, {__index = L_UIMainSubBasePanel.New()})
    self:BaseFirstShow(trans, parent, rootForm)

    self.ExpBar = UIUtils.FindProgressBar(trans, "Exp")
    self.ExpBarSpr = UIUtils.FindSpr(trans, "Exp/ExpBar")
    self.ExpBackSpr = UIUtils.FindSpr(trans, "Exp/ExpBar/Back")
    self.LimitLevelGo = UIUtils.FindGo(trans, "FullTips")
    self.LimitLabel = UIUtils.FindLabel(trans, "FullTips/Right/Desc")
    self.LimitToggle = UIUtils.FindToggle(trans, "FullTips/Right/Select")
    UIUtils.AddOnChangeEvent(self.LimitToggle, self.OnLimitToggleChanged, self)
    self.LimitClose = UIUtils.FindBtn(trans, "FullTips/Right/Close")
    UIUtils.AddBtnEvent(self.LimitClose, self.OnLimitCloseBtnClick, self)
    self.LimitLevelGo:SetActive(false)
    local _gCfg = DataConfig.DataGlobal[GlobalName.Level_Limit_Notice]
    if _gCfg ~= nil then
        local _params = Utils.SplitStrBySeps(_gCfg.Params, {';', '_'})
        self.LimitLevels:Clear()
        self.LimitDescs:Clear()
        for i = 1, #_params do
            self.LimitLevels:Add(tonumber(_params[i][1]))
            self.LimitDescs:Add(_params[i][2])
        end
    end
    self.LightTrans = UIUtils.FindTrans(trans, "Exp/ExpBar/Light")
    self.LightList:Clear()
    for i = 1, 9 do
        self.LightList:Add(UIUtils.FindTrans(trans, string.format("Exp/ExpBar/Back/%d", i)))
    end
end

-- After display
function UIMainExpPanel:OnShowAfter()
    self.IsNeedUpdateExp = true

    local _root = GameCenter.UIFormManager:GetUIRoot()
	local _screen = CS.UnityEngine.Screen;
    local _s = _root.activeHeight / _screen.height
    local _width = math.ceil(_screen.width * _s)
    self.ExpBarSpr.width = _width
    self.ExpBackSpr.width = _width
    local _singleWidth = _width / 10
    for i = 1, #self.LightList do
        UnityUtils.SetLocalPosition(self.LightList[i], -(_width / 2) + _singleWidth * (i), 1, 0)
    end
end
function UIMainExpPanel:OnPropChanged(prop, sender)
    local _curType = prop.CurrentChangeBasePropType
    if _curType == L_RoleBaseAttribute.Exp then
        self.IsNeedUpdateExp = true
        self:CheckShowLimitTips()
    elseif _curType == L_RoleBaseAttribute.Level then
        self.IsNeedUpdateExp = true
    end
end
function UIMainExpPanel:OnChangeMap(prop, sender)
    self:CheckShowLimitTips()
end
function UIMainExpPanel:CheckShowLimitTips()
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end
    local _curExp = _lp.PropMoudle.Exp
    local _levelCfg = DataConfig.DataCharacters[_lp.Level]
    if _curExp <= _levelCfg.Exp then
        -- Has broken through the level, hide the prompt
        self.LimitLevelGo:SetActive(false)
        return
    end
    if not self.ShowLimitTips then
        return
    end
    local _curMapId = 0
    if GameCenter.MapLogicSystem.MapCfg ~= nil then
        _curMapId = GameCenter.MapLogicSystem.MapCfg.MapId
    end
    if _curMapId ~= self.FrontCheckMapID and self.LimitLevels:Contains(_lp.Level) then
        -- Exceeding experience limit, pop-up prompt
        self.FrontCheckMapID = _curMapId
        self.LimitLevelGo:SetActive(true)
        self.LimitToggle.value = not self.ShowLimitTips
        UIUtils.SetTextByString(self.LimitLabel, self.LimitDescs[self.LimitLevels:IndexOf(_lp.Level)])
    end
end

function UIMainExpPanel:Update(dt)
    if not self.IsVisible then
        return
    end
    if self.IsNeedUpdateExp then
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if _lp ~= nil then
            local _curExp = _lp.PropMoudle.Exp
            local _levelCfg = DataConfig.DataCharacters[_lp.Level]
            if _levelCfg ~= nil then
                local _progress = _curExp / _levelCfg.Exp
                self.ExpBar.value = _progress
                UnityUtils.SetLocalPosition(self.LightTrans, -(self.ExpBarSpr.width / 2) + _progress * self.ExpBarSpr.width, 0, 0)
            end
        end
        self.IsNeedUpdateExp = false
    end
end
function UIMainExpPanel:OnLimitCloseBtnClick()
    self.LimitLevelGo:SetActive(false)
end
function UIMainExpPanel:OnLimitToggleChanged()
    self.ShowLimitTips = not self.LimitToggle.value
end

return UIMainExpPanel