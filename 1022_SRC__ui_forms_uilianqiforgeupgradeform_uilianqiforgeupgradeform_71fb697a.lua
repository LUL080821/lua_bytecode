-- author:
-- Date: 2019-04-26
-- File: UILianQiForgeUpgradeForm.lua
-- Module: UILianQiForgeUpgradeForm
-- Description: First-level pagination of refining functions: Forged panel
------------------------------------------------
local UIListMenu = require "UI.Components.UIListMenu.UIListMenu"

local UILianQiForgeUpgradeForm = {
    UIListMenu = nil, -- List
    Form       = LianQiForgeUpgradeSubEnum.Begin, -- Pagination Type
}

function UILianQiForgeUpgradeForm:OnRegisterEvents()
    self:RegisterEvent(UILuaEventDefine.UILianQiForgeUpgradeForm_OPEN, self.OnOpen)
    self:RegisterEvent(UILuaEventDefine.UILianQiForgeUpgradeForm_CLOSE, self.OnClose)
end

function UILianQiForgeUpgradeForm:RegUICallback()

end

function UILianQiForgeUpgradeForm:OnOpen(obj, sender)
    self.CSForm:Show(sender)
    if obj and obj[1] <= LianQiForgeUpgradeSubEnum.Count then
        self.Form = obj[1]
        self.SelectID = obj[2]
    end
    self.UIListMenu:SetSelectById(self.Form)
end

function UILianQiForgeUpgradeForm:OnClose(obj, sender)
    self.CSForm:Hide()
end

function UILianQiForgeUpgradeForm:OnFirstShow()
    self:FindAllComponents()
    self:RegUICallback()
end

function UILianQiForgeUpgradeForm:OnHideBefore()
    GameCenter.PushFixEvent(UILuaEventDefine.UILianQiForgeStrengthTransferForm_CLOSE, nil, self.CSForm)
    GameCenter.PushFixEvent(UILuaEventDefine.UILianQiForgeStrengthSplitForm_CLOSE, nil, self.CSForm)
end

function UILianQiForgeUpgradeForm:FindAllComponents()
    local _myTrans = self.Trans
    self.UIListMenu = UIListMenu:OnFirstShow(self.CSForm, UIUtils.FindTrans(_myTrans, "UIListMenu"))
    self.UIListMenu:AddIcon(LianQiForgeUpgradeSubEnum.Strength, DataConfig.DataMessageString.Get("LIANQI_FORGE_STRENGTH"), FunctionStartIdCode.LianQiForgeStrength)
    self.UIListMenu:AddIcon(LianQiForgeUpgradeSubEnum.Transfer, "Chuyển Cường Hóa", FunctionStartIdCode.LianQiForgeStrengthTransfer)
    self.UIListMenu:AddIcon(LianQiForgeUpgradeSubEnum.Split, "Tách Cường Hóa", FunctionStartIdCode.LianQiForgeStrengthSplit)
    self.UIListMenu:AddSelectEvent(Utils.Handler(self.OnMenuSelect, self))
    self.UIListMenu.IsHideIconByFunc = true
end

function UILianQiForgeUpgradeForm:OnMenuSelect(id, open)
    self.Form = id
    if open then
        self:OpenSubForm(id)
    else
        self:CloseSubForm(id)
    end
end

function UILianQiForgeUpgradeForm:OpenSubForm(id)
    if id == LianQiForgeUpgradeSubEnum.Transfer then
        GameCenter.PushFixEvent(UILuaEventDefine.UILianQiForgeStrengthTransferForm_OPEN, nil, self.CSForm)
    elseif id == LianQiForgeUpgradeSubEnum.Split then
        GameCenter.PushFixEvent(UILuaEventDefine.UILianQiForgeStrengthSplitForm_OPEN, nil, self.CSForm)
    elseif id == LianQiForgeUpgradeSubEnum.Strength then
        -- Equipment enhancement
        GameCenter.PushFixEvent(UIEventDefine.UILianQiForgeStrengthForm_OPEN, nil, self.CSForm)
    end
end

function UILianQiForgeUpgradeForm:CloseSubForm(id)
    if id == LianQiForgeUpgradeSubEnum.Transfer then
        GameCenter.PushFixEvent(UILuaEventDefine.UILianQiForgeStrengthTransferForm_CLOSE, nil, self.CSForm)
    elseif id == LianQiForgeUpgradeSubEnum.Split then
        GameCenter.PushFixEvent(UILuaEventDefine.UILianQiForgeStrengthSplitForm_CLOSE, nil, self.CSForm)
    elseif id == LianQiForgeUpgradeSubEnum.Strength then
        -- Equipment enhancement
        GameCenter.PushFixEvent(UIEventDefine.UILianQiForgeStrengthForm_CLOSE, nil, self.CSForm)
    end
end

return UILianQiForgeUpgradeForm