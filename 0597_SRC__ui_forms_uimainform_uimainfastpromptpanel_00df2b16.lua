------------------------------------------------
--Author: yangqf
--Date: 2021-02-26
--File: UIMainFastPromptPanel.lua
--Module: UIMainFastPromptPanel
--Description: Main interface function reminder interface
------------------------------------------------

local L_UIMainSubBasePanel = require "UI.Forms.UIMainForm.UIMainSubBasePanel"

local UIMainFastPromptPanel = {
    IconSpr = nil,
    NameLabel = nil,
    DescLabel = nil,
    Btn = nil,
    FuncGo = nil,
    RedPoint = nil,
    CurShowCfg = nil,
    ShowType = nil, --Display type 1: Function opening; 2: Function preview
    
}

function UIMainFastPromptPanel:OnRegisterEvents()
    self:RegisterEvent(LogicEventDefine.EID_EVENT_SYNC_FUNCTION_INFO, self.UpdatePage, self)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_UPDATEFUNCNOTICE_INFO, self.UpdatePage, self)
end

function UIMainFastPromptPanel:OnFirstShow(trans, parent, rootForm)
    setmetatable(self, {__index = L_UIMainSubBasePanel.New()})
    self:BaseFirstShow(trans, parent, rootForm)
    self.IconSpr = UIUtils.FindSpr(trans, "Tips/Icon")
    self.NameLabel = UIUtils.FindLabel(trans, "Tips/Name")
    self.DescLabel = UIUtils.FindLabel(trans, "Tips/Desc")
    self.Btn = UIUtils.FindBtn(trans, "Tips")
    UIUtils.AddBtnEvent(self.Btn, self.OnFuncBtnClick, self)
    self.FuncGo = UIUtils.FindGo(trans, "Tips")
    self.RedPoint = UIUtils.FindGo(trans, "Tips/Panel/Redpoint")
end

function UIMainFastPromptPanel:OnShowAfter()
    self.CurShowCfg = nil
    self:UpdatePage(nil, nil)
    --self.FuncGo.gameObject:SetActive(false)
end

function UIMainFastPromptPanel:OnFuncBtnClick()
    local _openId = nil
    if GameCenter.MainFunctionSystem:GetAlertFlag(FunctionStartIdCode.FunctionNotice) then
        _openId = FunctionStartIdCode.FunctionNotice
    elseif GameCenter.MainFunctionSystem:GetAlertFlag(FunctionStartIdCode.FuncFuncPanel) then
        _openId = FunctionStartIdCode.FuncFuncPanel
    else
        if self.ShowType == 1 then
            _openId = FunctionStartIdCode.FuncFuncPanel
        else
            _openId = FunctionStartIdCode.FunctionNotice
        end
    end
    GameCenter.MainFunctionSystem:DoFunctionCallBack(_openId)
end

function UIMainFastPromptPanel:UpdatePage(obj, sender)
    local _canGet = false
    local _showCfg = nil
    local _lastCfg = nil
    local _func = function(k, v)
        if v.IsShow == 0 then
            return
        end
        local _funcInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(v.FunctionId)
        if _funcInfo == nil then
            return
        end
        if v.ActiveDay > 0 then
            --The function of opening a server for the number of days, judge your own Visible
            if _funcInfo.SelfIsVisible and _funcInfo.IsEnable and not _funcInfo.IsGetAward then
                _canGet = true
            end
            if _showCfg == nil and not _funcInfo.IsEnable and _funcInfo.SelfIsVisible then
                _showCfg = v
            end
        else
            if _funcInfo.IsEnable and not _funcInfo.IsGetAward then
                _canGet = true
            end
            if _showCfg == nil and not _funcInfo.IsEnable then
                _showCfg = v
            end
        end
        _lastCfg = v
    end
    DataConfig.DataFunctionOpenTips:Foreach(_func)
    self.RedPoint:SetActive(_canGet or GameCenter.MainFunctionSystem:GetAlertFlag(FunctionStartIdCode.FunctionNotice))
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.FuncFuncPanel, _canGet)

    if GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.FunctionNotice) then
        self.ShowType = 2
        --Display function trailer related
        local _showCfg = GameCenter.FunctionNoticeSystem.CurNoticeCfg
        self.IconSpr.spriteName = _showCfg.Icon
        UIUtils.SetTextByStringDefinesID(self.NameLabel, _showCfg._Name)
        UIUtils.SetTextByStringDefinesID(self.DescLabel, _showCfg._MainDesc)
        self.FuncGo:SetActive(true)
       -- self.FuncGo:SetActive(false)
    else
        self.ShowType = 1
        --Content display function is enabled
        if _showCfg == nil and not _canGet then
            self.CurShowCfg = nil
            self.FuncGo:SetActive(false)
        else
            if _showCfg == nil then
                _showCfg = _lastCfg
            end
            self.CurShowCfg = _showCfg
            self.IconSpr.spriteName = self.CurShowCfg.Icon
            UIUtils.SetTextByStringDefinesID(self.NameLabel, _showCfg._Name)
            UIUtils.SetTextByStringDefinesID(self.DescLabel, _showCfg._OpenDesc)
            self.FuncGo:SetActive(true)
            --self.FuncGo:SetActive(false)
        end
    end
end

return UIMainFastPromptPanel