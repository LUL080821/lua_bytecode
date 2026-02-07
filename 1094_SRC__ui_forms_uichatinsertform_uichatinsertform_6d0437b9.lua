------------------------------------------------
-- author:
-- Date: 2021-04-02
-- File: UIChatInsertForm.lua
-- Module: UIChatInsertForm
-- Description: Chat insert interface
------------------------------------------------
local UIListMenu = require "UI.Components.UIListMenu.UIListMenu"
local L_UIChatInsertExpPanel = require("UI.Forms.UIChatInsertForm.UIChatInsertExpPanel")
local L_UIChatInsertHisPanel = require("UI.Forms.UIChatInsertForm.UIChatInsertHisPanel")
local L_UIChatInsertItemPanel = require("UI.Forms.UIChatInsertForm.UIChatInsertItemPanel")

local UIChatInsertForm = {
    CloseBtn = nil,
    ListMenu = nil,
    CurSelectPanel = nil,

    ExpPanel = nil,
    HisPanel = nil,
    ItemPanel = nil,
}

function UIChatInsertForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UIChatInsertForm_OPEN, self.OnOpen, self)
    self:RegisterEvent(UIEventDefine.UIChatInsertForm_CLOSE, self.OnClose, self)
end

function UIChatInsertForm:OnFirstShow()
    local _trans = self.Trans
    self.CloseBtn = UIUtils.FindBtn(_trans, "BGMask")
    UIUtils.AddBtnEvent(self.CloseBtn, self.OnClickCloseBtn, self)
    self.ExpPanel = L_UIChatInsertExpPanel:OnFirstShow(UIUtils.FindTrans(_trans, "LeftButtom/ExpPanel"), self, self)
    self.HisPanel = L_UIChatInsertHisPanel:OnFirstShow(UIUtils.FindTrans(_trans, "LeftButtom/HisPanel"), self, self)
    self.ItemPanel = L_UIChatInsertItemPanel:OnFirstShow(UIUtils.FindTrans(_trans, "LeftButtom/ItemPanel"), self, self)
    self.CSForm:AddNormalAnimation(0.3)
    self.CSForm.UIRegion = UIFormRegion.TopRegion

    self.ListMenu = UIListMenu:OnFirstShow(self.CSForm, UIUtils.FindTrans(_trans, "LeftButtom/UIListMenuTop"))
    self.ListMenu:AddIcon(ChatInsertType.Expression, DataConfig.DataMessageString.Get("C_CHAT_INSET_BIAOQING"))
    self.ListMenu:AddIcon(ChatInsertType.History, DataConfig.DataMessageString.Get("C_CHAT_INSET_LISGHI"))
    self.ListMenu:AddIcon(ChatInsertType.Item, DataConfig.DataMessageString.Get("C_CHAT_INSET_WUPING"))
    -- Ẩn Thánh Trang và Ảo Trang
    -- self.ListMenu:AddIcon(ChatInsertType.HolyEquip, DataConfig.DataMessageString.Get("C_CHAT_INSET_SHENGZHUANG"))
    -- self.ListMenu:AddIcon(ChatInsertType.UnrealEquip, DataConfig.DataMessageString.Get("C_CHAT_INSET_HUANZHUANG"))
    self.ListMenu:AddSelectEvent(Utils.Handler(self.OnMenuSelect, self))
end

function UIChatInsertForm:OnMenuSelect(id, b)
    if b then
        if id == ChatInsertType.Expression then
            self.ExpPanel:Open()
        elseif id == ChatInsertType.History then
            self.HisPanel:Open()
        elseif id == ChatInsertType.Item then
            self.ItemPanel:OpenByTypeId(id)
        -- elseif id == ChatInsertType.HolyEquip then
        --     self.ItemPanel:OpenByTypeId(id)
        -- elseif id == ChatInsertType.UnrealEquip then
        --     self.ItemPanel:OpenByTypeId(id)
        end
    else
        if id == ChatInsertType.Expression then
            self.ExpPanel:Close()
        elseif id == ChatInsertType.History then
            self.HisPanel:Close()
        elseif id == ChatInsertType.Item then
            self.ItemPanel:Close()
        -- elseif id == ChatInsertType.HolyEquip then
        --     self.ItemPanel:Close()
        -- elseif id == ChatInsertType.UnrealEquip then
        --     self.ItemPanel:Close()
        end
    end
end

-- Event trigger opening interface
function UIChatInsertForm:OnOpen(params, sender)
    self.CSForm:Show(sender)
    local _openPanel = ChatInsertType.Expression
    if params ~= nil  then
        local _type = type(params)
        if _type == "number" then
            _openPanel = params
        elseif _type == "userdata" then
            local _param = UnityUtils.GetObjct2Int(params[1])
            _openPanel = _param
        end
    end
    self.CurSelectPanel = nil
    self.ListMenu:SetSelectById(_openPanel)
end

-- Event triggers the close interface
function UIChatInsertForm:OnClose(obj, sender)
    self.ListMenu:SetSelectByIndex(-1)
    self.CSForm:Hide()
end

-- Click the Close button on the interface
function UIChatInsertForm:OnClickCloseBtn()
    self:OnClose(nil)
end

function UIChatInsertForm:Update(dt)
    if self.ExpPanel.Update ~= nil then
        self.ExpPanel:Update(dt)
    end
    if self.HisPanel.Update ~= nil then
        self.HisPanel:Update(dt)
    end
    if self.ItemPanel.Update ~= nil then
        self.ItemPanel:Update(dt)
    end
end

return UIChatInsertForm