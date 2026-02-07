------------------------------------------------
-- author:
-- Date: 2021-03-01
-- File: UIMainTaskAndTeamPanel.lua
-- Module: UIMainTaskAndTeamPanel
-- Description: Main interface team and task pagination
------------------------------------------------

local L_UIMainSubBasePanel = require "UI.Forms.UIMainForm.UIMainSubBasePanel"

local UIMainTaskAndTeamPanel = {
    BackTrans = nil,
    BackWidget = nil,
    BtnGrid = nil,
    TopBtnList = nil,
    SubPanels = nil,
    ShowBtn = nil,
    HideBtn = nil,
    TeamCount1 = nil,
    TeamCount2 = nil,
    FrontHaveTeam = false,
    IsState = false,
    GrowthWayModelRoot = nil,
    Skin = nil,
    ModelBtn = nil,
    ModelTex = nil,
    GrowthWayDes = nil,
    ShowGrowthModel = false,
    CurShowModel = 0,
}
-- Register Events
function UIMainTaskAndTeamPanel:OnRegisterEvents()
    -- Update the page display status
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_MAINLEFTSUBPABNELOPENSTATE, self.OnUpdateSubpanelShowState, self)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_FUNCTION_UPDATE, self.OnFuncUpdated, self)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_UITEAMFORM_UPDATE, self.OnUpdateTeam, self)
end
local L_TopMenuButton = nil
function UIMainTaskAndTeamPanel:OnFirstShow(trans, parent, rootForm)
    setmetatable(self, {__index = L_UIMainSubBasePanel.New()})
    self:BaseFirstShow(trans, parent, rootForm)
    self.BackTrans = UIUtils.FindTrans(trans, "Back")
    self.BackWidget = UIUtils.FindWid(self.BackTrans)
    self.BtnGrid = UIUtils.FindGrid(trans, "Back/Grid")
    self.TopBtnList = {}
    self.TopBtnList[MainLeftSubPanel.Task] = L_TopMenuButton:New(UIUtils.FindGo(trans, "Back/Grid/Task"), FunctionStartIdCode.TargetTask, self)
    self.TopBtnList[MainLeftSubPanel.Team] = L_TopMenuButton:New(UIUtils.FindGo(trans, "Back/Grid/Team"), FunctionStartIdCode.Team, self)
    self.TopBtnList[MainLeftSubPanel.Other] = L_TopMenuButton:New(UIUtils.FindGo(trans, "Back/Grid/Other"), -998, self)
    self.SubPanels = {}
    self.SubPanels[MainLeftSubPanel.Task] = require("UI.Forms.UIMainForm.UIMainTaskPanel")
    self.SubPanels[MainLeftSubPanel.Task]:OnFirstShow(UIUtils.FindTrans(trans, "Back/TaskBack"), self, rootForm)
    self.SubPanels[MainLeftSubPanel.Team] = require("UI.Forms.UIMainForm.UIMainTeamPanel")
    self.SubPanels[MainLeftSubPanel.Team]:OnFirstShow(UIUtils.FindTrans(trans, "Back/TeamBack"), self, rootForm)
    self.SubPanels[MainLeftSubPanel.Other] = require("UI.Forms.UIMainForm.UIMainOtherPanel")
    self.SubPanels[MainLeftSubPanel.Other]:OnFirstShow(UIUtils.FindTrans(trans, "Back/Other"), self, rootForm)
    self.ShowBtn = UIUtils.FindBtn(trans, "WidgetBtn/ShowBtn")
    UIUtils.AddBtnEvent(self.ShowBtn, self.OnShowBtnClick, self)
    self.HideBtn = UIUtils.FindBtn(trans, "WidgetBtn/HideBtn")
    UIUtils.AddBtnEvent(self.HideBtn, self.OnHideBtnClick, self)
    self.TeamCount1 = UIUtils.FindLabel(trans, "Back/Grid/Team/Normal/Label")
    self.TeamCount2 = UIUtils.FindLabel(trans, "Back/Grid/Team/Select/Label")
    self.AnimModule:AddAlphaPosAnimation(self.BackTrans, 0, 1, -376, 0, 0.3, false, false)
    self.GrowthWayModelRoot = UIUtils.FindGo(trans, "Back/ModelRoot")
    self.GrowthWayModelRoot:SetActive(false)
    self.Skin = UIUtils.RequireUIRoleSkinCompoent(UIUtils.FindTrans(trans, "Back/ModelRoot/UIRoleSkinCompoent"))
    self.Skin:OnFirstShow(parent.CSForm, FSkinTypeCode.Custom)
    self.Skin.EnableDrag = false
    self.ModelBtn = UIUtils.FindBtn(trans, "Back/ModelRoot/ModelBtn")
    UIUtils.AddBtnEvent(self.ModelBtn, self.OnClickModel, self)
    self.ModelTex = UIUtils.FindTex(trans, "Back/ModelRoot/Sprite/Texture")
    self.GrowthWayDes = UIUtils.FindLabel(trans, "Back/ModelRoot/Sprite/Label")
end

function UIMainTaskAndTeamPanel:OnTryHide()
    if self.SubPanels[MainLeftSubPanel.Task].IsVisible then
        return self.SubPanels[MainLeftSubPanel.Task]:OnTryHide()
    end
    return true
end

-- After display
function UIMainTaskAndTeamPanel:OnShowAfter()
    self:SwitchShowState(true)
    for i = 1, MainLeftSubPanel.Count do
        local _funcInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(self.TopBtnList[i].ID)
        self.TopBtnList[i]:OnUpdateFunc(_funcInfo)
    end
    self:OnUpdateTeam(nil)
    self:OnUpdateSubpanelShowState(nil, nil)
    self:UpdateShowModel()
end
function UIMainTaskAndTeamPanel:OnHideBefore()
    if self.Skin ~= nil then
        self.Skin:ResetSkin()
    end
    if self.SubPanels[MainLeftSubPanel.Other].IsVisible then
        self.SubPanels[MainLeftSubPanel.Other]:Close()
    end
end
-- Update the team interface
function UIMainTaskAndTeamPanel:OnUpdateTeam(obj, sender)
    -- Determine whether the team exists
    if GameCenter.TeamSystem:IsTeamExist() then
        local _count = #GameCenter.TeamSystem.MyTeamInfo.MemberList
        UIUtils.SetTextByEnum(self.TeamCount1, "C_MIAN_TEAM_MENCOUNT", _count)
        UIUtils.SetTextByEnum(self.TeamCount2, "C_MIAN_TEAM_MENCOUNT", _count)
        self.FrontHaveTeam = true
        if not self.FrontHaveTeam then
            self:SetSelect(FunctionStartIdCode.Team)
        end
    else
        -- No team
        UIUtils.SetTextByEnum(self.TeamCount1, "C_MIAN_TEAM")
        UIUtils.SetTextByEnum(self.TeamCount2, "C_MIAN_TEAM")
        self.FrontHaveTeam = false
    end
end

-- Switch interface display status
function UIMainTaskAndTeamPanel:SwitchShowState(b)
    self.IsState = b
    self.ShowBtn.gameObject:SetActive(false)
    self.HideBtn.gameObject:SetActive(false)
    if b then
        self.AnimModule:PlayShowAnimation(self.BackTrans, Utils.Handler(self.OnBackShowAnimFinifh, self))
    else
        self.AnimModule:PlayHideAnimation(self.BackTrans, Utils.Handler(self.OnBackHideAnimFinifh, self), false)
    end
end
function UIMainTaskAndTeamPanel:OnBackShowAnimFinifh()
    self.HideBtn.gameObject:SetActive(true)
end
function UIMainTaskAndTeamPanel:OnBackHideAnimFinifh()
    self.ShowBtn.gameObject:SetActive(true)
end
function UIMainTaskAndTeamPanel:OnFuncUpdated(data, sender)
    if data == nil then
        return
    end
    for i = 1, MainLeftSubPanel.Count do
        self.TopBtnList[i]:OnUpdateFunc(data)
    end
end
-- Update pagination display
function UIMainTaskAndTeamPanel:OnUpdateSubpanelShowState(obj, sender)
    local _uiState = GameCenter.MapLogicSystem.LeftUIState
    if _uiState == nil then
        _uiState = GameCenter.MapLogicSystem:GetMainLeftUIState()
    end
    for i = 1, MainLeftSubPanel.Count do
        self.TopBtnList[i].RootGo:SetActive(_uiState[i])
    end
    self.BtnGrid:Reposition()
    if _uiState[MainLeftSubPanel.Other] then
        local _otherName = GameCenter.MapLogicSwitch.OtherName
        local _otherSprName = GameCenter.MapLogicSwitch.OtherSprName
        if _otherName ~= nil and string.len(_otherName) > 0 then
            self.TopBtnList[MainLeftSubPanel.Other]:SetNameAndSpr(_otherName, _otherSprName)
        end
    end
    if _uiState[MainLeftSubPanel.Task] then
        self:SetSelect(FunctionStartIdCode.TargetTask)
    elseif _uiState[MainLeftSubPanel.Other] then
        self:SetSelect(-998)
    else
        self:SetSelect(FunctionStartIdCode.Team)
    end
end
-- Show button
function UIMainTaskAndTeamPanel:OnShowBtnClick()
    self:SwitchShowState(true)
end
-- Hide button click
function UIMainTaskAndTeamPanel:OnHideBtnClick()
    self:SwitchShowState(false)
end
function UIMainTaskAndTeamPanel:SetSelect(id)
    if id == FunctionStartIdCode.Team then
        -- --Click the team paging button to determine whether the team can be opened on the current map
        --if (GameCenter.MapLogicSystem.ActiveLogic == nil)
        --    return

        --if (!GameCenter.MapLogicSystem.ActiveLogic.CanOpenTeam)
        --{
        --    GameCenter.MsgPromptSystem.ShowPrompt(Thousandto.Cfg.Data.DeclareMessageString.Get(Thousandto.Cfg.Data.DeclareMessageString.C_CUR_MAPCANNOT_TEAM))
        --    return
        --}
    end
    for i = 1, MainLeftSubPanel.Count do
        self.TopBtnList[i]:SetSetect(self.TopBtnList[i].ID == id)
        if self.TopBtnList[i].IsSelect then
            self.SubPanels[i]:Open()
        else
            self.SubPanels[i]:Close()
        end
    end
end
-- Click the model button
function UIMainTaskAndTeamPanel:OnClickModel()
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.GrowthWay)
end
function UIMainTaskAndTeamPanel:UpdateShowModel()
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil or self.Skin == nil then
        return
    end
    local _cfg1 = DataConfig.DataGlobal[GlobalName.New_Sever_Growup_Show_Model_Open]
    if _cfg1 ~= nil then
        local _condition = Utils.SplitNumber(_cfg1.Params, '_')
        if #_condition < 2 then
            return
        end
        local _taskId = _condition[2]
        if not GameCenter.LuaTaskManager:IsMainTaskOver(_taskId) then
            return
        end
    end
    self.Skin:ResetSkin()
    self.ShowGrowthModel = false
    local _curModelId = _lp.PropMoudle.GrowthWayModelId
    if _curModelId ~= 0 then
        local _cfg = DataConfig.DataGlobal[GlobalName.New_Sever_Growup_Show_Model_Value]
        if _cfg ~= nil then
            local _modelParams = Utils.SplitStrByTableS(_cfg.Params, {';', '_'})
            for i = 1, #_modelParams do
                local _monsterId = _modelParams[i][1]
                local _scale = _modelParams[i][2]
                local _pos = _modelParams[i][3]
                local _rot = _modelParams[i][4]
                if _curModelId == _monsterId then
                    self.Skin.NormalRot = _rot
                    self.Skin:SetPos(0, _pos)
                    self.Skin:SetCameraSize(320 / _scale)
                    self.Skin:SetEquip(FSkinPartCode.Body, _curModelId)
                    self.Skin:ResetRot()
                    self.RootForm.CSForm:LoadTexture(self.ModelTex, ImageTypeCode.UI, "tex_fl-qiridizuoguang")
                    if i == 1 then
                        UIUtils.SetTextByEnum(self.GrowthWayDes, "C_CISHUDENGLU")
                    elseif i == 2 then
                        UIUtils.SetTextByEnum(self.GrowthWayDes, "C_JUEBANFABAO")
                    end
                    self.ShowGrowthModel = true
                    break
                end
            end
        end
    end
    self.CurShowModel = _curModelId
    self.GrowthWayModelRoot:SetActive(self.ShowGrowthModel)
end
function UIMainTaskAndTeamPanel:Update(dt)
    if not self.IsVisible then
        return
    end
    if Time.GetFrameCount() % 10 == 0 then
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if _lp ~= nil and self.CurShowModel ~= _lp.PropMoudle.GrowthWayModelId then
            self:UpdateShowModel()
        end
    end
    if self.ShowGrowthModel and self.Skin.Skin ~= nil then
        self.Skin.Skin:SetActive(self.BackWidget.finalAlpha > 0.9)
    end
    for i = 1, MainLeftSubPanel.Count do
        self.SubPanels[i]:Update(dt)
    end
end

L_TopMenuButton = {
    RootGo = nil,
    NormalGo = nil,
    SelectGo = nil,
    RedPoint = nil,
    Name = nil,
    NameSelect = nil,
    Spr = nil,
    Sprselect = nil,
    Btn = nil,
    Parent = nil,
    ID = 0,
    IsSelect = false,
}
function L_TopMenuButton:New(rootGo, id, parent)
    local _m = Utils.DeepCopy(self)
    _m.RootGo = rootGo
    _m.ID = id
    _m.Parent = parent
    local _trans = rootGo.transform
    _m.NormalGo = UIUtils.FindGo(_trans, "Normal")
    _m.SelectGo = UIUtils.FindGo(_trans, "Select")
    _m.RedPoint = UIUtils.FindGo(_trans, "RedPoint")
    _m.Name = UIUtils.FindLabel(_trans, "Normal/Label")
    _m.NameSelect = UIUtils.FindLabel(_trans, "Select/Label")
    local _bgspr = UIUtils.FindTrans(_trans, "Normal/Sprite")
    if _bgspr ~= nil then
        _m.Spr = UIUtils.FindSpr(_bgspr)
    end
    _bgspr = UIUtils.FindTrans(_trans, "Select/Sprite")
    if _bgspr ~= nil then
        _m.Sprselect = UIUtils.FindSpr(_bgspr)
    end
    _m.Btn = UIUtils.FindBtn(_trans)
    UIUtils.AddBtnEvent(_m.Btn, _m.OnBtnClick, _m)
    return _m
end
function L_TopMenuButton:SetSetect(b)
    self.IsSelect = b
    self.NormalGo:SetActive(not b)
    self.SelectGo:SetActive(b)
end
function L_TopMenuButton:SetNameAndSpr(name, sprName)
    UIUtils.SetTextByString(self.Name, name)
    UIUtils.SetTextByString(self.NameSelect, name)
    if self.Spr ~= nil then
        if sprName == nil or string.len(sprName <= 0) then
            self.Spr.gameObject:SetActive(false)
        else
            self.Spr.gameObject:SetActive(true)
            self.Spr.spriteName = string.format("%s_1", sprName)
        end
    end
    if self.Sprselect ~= nil then
        if sprName == nil or string.len(sprName <= 0) then
            self.Sprselect.gameObject:SetActive(false)
        else
            self.Sprselect.gameObject:SetActive(true)
            self.Sprselect.spriteName = string.format("%s_2", sprName)
        end
    end
end
function L_TopMenuButton:OnUpdateFunc(info)
    if info == nil then
        self.RedPoint:SetActive(false)
    else
        local _funcId = info.ID
        if _funcId == self.ID then
            self.RedPoint:SetActive(info.IsShowRedPoint)
        end
    end
end
 
function L_TopMenuButton:OnBtnClick()
    if not self.IsSelect then
        self.Parent:SetSelect(self.ID)
    else
        GameCenter.MainFunctionSystem:DoFunctionCallBack(self.ID)
    end
end
return UIMainTaskAndTeamPanel