-- author:
-- Date: 2019-04-26
-- File: UILianQiForgeForm.lua
-- Module: UILianQiForgeForm
-- Description: First-level pagination of refining functions: Forged panel
------------------------------------------------
local UIListMenu = require "UI.Components.UIListMenu.UIListMenu"

local UILianQiForgeForm = {
    UIListMenu = nil,-- List
    Form = LianQiForgeSubEnum.Begin, -- Pagination Type
}

function UILianQiForgeForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UILianQiForgeForm_OPEN, self.OnOpen)
    self:RegisterEvent(UIEventDefine.UILianQiForgeForm_CLOSE, self.OnClose)
end

function UILianQiForgeForm:OnOpen(obj, sender)
    self.CSForm:Show(sender)
    if obj and obj[1] <= LianQiForgeSubEnum.Count then
        self.Form = obj[1]
        self.SelectID = obj[2]
    end
    self.UIListMenu:SetSelectById(self.Form)
end

function UILianQiForgeForm:OnClose(obj,sender)
    self.CSForm:Hide()
end

function UILianQiForgeForm:RegUICallback()
    
end

function UILianQiForgeForm:OnFirstShow()
    self:FindAllComponents()
    self:RegUICallback()
end

function UILianQiForgeForm:OnHideBefore()
    GameCenter.PushFixEvent(UIEventDefine.UILianQiForgeStrengthForm_CLOSE, nil, self.CSForm)
    GameCenter.PushFixEvent(UIEventDefine.UILianQiForgeWashForm_CLOSE, nil, self.CSForm)
    -- GameCenter.PushFixEvent(UIEventDefine.UIEquipSynthForm_CLOSE)
end

function UILianQiForgeForm:OnClickCloseBtn()
    self:OnClose(nil, nil)
end

function UILianQiForgeForm:FindAllComponents()
    local _myTrans = self.Trans
    self.UIListMenu = UIListMenu:OnFirstShow(self.CSForm, UIUtils.FindTrans(_myTrans, "UIListMenu"))
    --self.UIListMenu:OnFirstShow(self.CSForm)
    -- self.UIListMenu:AddIcon(LianQiForgeSubEnum.Synth, nil, FunctionStartIdCode.EquipSynthSub)
    -- self.UIListMenu:AddIcon(LianQiForgeSubEnum.Strength, DataConfig.DataMessageString.Get("LIANQI_FORGE_STRENGTH"), FunctionStartIdCode.LianQiForgeStrength)
    self.UIListMenu:AddIcon(LianQiForgeSubEnum.Wash, DataConfig.DataMessageString.Get("LIANQI_FORGE_WASH"), FunctionStartIdCode.LianQiForgeWash)
    self.UIListMenu:AddSelectEvent(Utils.Handler(self.OnMenuSelect,self))
    self.UIListMenu.IsHideIconByFunc = true
end

function UILianQiForgeForm:OnMenuSelect(id, open)
    self.Form = id
    if open then
        self:OpenSubForm(id)
    else
        self:CloseSubForm(id)
    end
end

function UILianQiForgeForm:OpenSubForm(id)
    if id == LianQiForgeSubEnum.Strength then
        -- Equipment enhancement
        GameCenter.PushFixEvent(UIEventDefine.UILianQiForgeStrengthForm_OPEN, nil, self.CSForm)
    elseif id == LianQiForgeSubEnum.Wash then
        -- Equipment refining
        GameCenter.PushFixEvent(UIEventDefine.UILianQiForgeWashForm_OPEN, nil, self.CSForm)
    elseif id == LianQiForgeSubEnum.Synth then
        -- GameCenter.PushFixEvent(UIEventDefine.UIEquipSynthForm_OPEN, self.SelectID, self.CSForm)
        -- self.SelectID = nil
    end
end

function UILianQiForgeForm:CloseSubForm(id)
    if id == LianQiForgeSubEnum.Strength then
        -- Equipment enhancement
        GameCenter.PushFixEvent(UIEventDefine.UILianQiForgeStrengthForm_CLOSE, nil, self.CSForm)
    elseif id == LianQiForgeSubEnum.Wash then
        -- Equipment refining
        GameCenter.PushFixEvent(UIEventDefine.UILianQiForgeWashForm_CLOSE, nil, self.CSForm)
    elseif id == LianQiForgeSubEnum.Synth then
        -- GameCenter.PushFixEvent(UIEventDefine.UIEquipSynthForm_CLOSE)
    end
end

return UILianQiForgeForm