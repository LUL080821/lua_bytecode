------------------------------------------------
-- author:
-- Date: 2021-04-06
-- File: UIChatInsertHisPanel.lua
-- Module: UIChatInsertHisPanel
-- Description: Chat insert history panel
------------------------------------------------

local L_UIMainSubBasePanel = require "UI.Forms.UIMainForm.UIMainSubBasePanel"
local L_WordFilter = CS.Thousandto.Code.Logic.WordFilter

local UIChatInsertHisPanel = {
    ScrollView = nil,
    Table = nil,
    ItemList = nil,
    Res = nil,
}

local L_HisItem = nil

function UIChatInsertHisPanel:OnFirstShow(trans, parent, rootForm)
    setmetatable(self, {__index = L_UIMainSubBasePanel.New()})
    self:BaseFirstShow(trans, parent, rootForm)

    self.Res = nil
    self.ScrollView = UIUtils.FindScrollView(trans, "ScrollView")
    self.Table = UIUtils.FindTable(trans, "ScrollView/Table")
    local _parentTrans = self.Table.transform
    local _childCount = _parentTrans.childCount
    self.ItemList = List:New()
    for i = 1, _childCount do
        local _childTrans = _parentTrans:GetChild(i - 1)
        if self.Res == nil then
            self.Res = _childTrans.gameObject
        end
        self.ItemList:Add(L_HisItem:New(_childTrans, self))
    end
    return self
end

function UIChatInsertHisPanel:OnShowAfter()
    local _index = 1
    local _hisList =  GameCenter.ChatSystem.HistoryData
    local _hisCount = _hisList.Count
    for i = 1, _hisCount do
        local _hisData = _hisList[i - 1]
        local _hisUI = nil
        if _index <= #self.ItemList then
            _hisUI = self.ItemList[_index]
        else
            _hisUI = L_HisItem:New(UnityUtils.Clone(self.Res).transform, self)
            self.ItemList:Add(_hisUI)
        end
        _hisUI:SetInfo(_hisData, i - 1)
        _index = _index + 1
    end
    for i = _index, #self.ItemList do
        self.ItemList[i]:SetInfo(nil)
    end
    self.Table:Reposition()
    self.ScrollView:ResetPosition()
end

L_HisItem = {
    Go = nil,
    Trans = nil,
    Label = nil,
    Btn = nil,
    Parent = nil,
    Params = nil,
}

function L_HisItem:New(trans, parent)
    local _m = Utils.DeepCopy(self)
    _m.Go = trans.gameObject
    _m.Trans = trans
    _m.Label = UIUtils.FindLabel(trans)
    _m.Btn = UIUtils.FindBtn(trans)
    UIUtils.AddBtnEvent(_m.Btn, _m.OnItemClick, _m)
    _m.Parent = parent
    return _m
end

function L_HisItem:SetInfo(info, index)
    if info == nil then
        self.Go:SetActive(false)
    else
        self.Go:SetActive(true)
        self.Params = tostring(index)
        local _showText = ""
        local _length = info.Length
        for i = 1, _length do
            local _text = info[i - 1]:GetDisplayText()
            _showText = _showText .. L_WordFilter.ReplaceKeyWords(_text)
        end
        UIUtils.SetTextByString(self.Label, _showText)
    end
end

function L_HisItem:OnItemClick()
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_CHAT_INSERT_HISTORY, self.Params)
    self.Parent.Parent:OnClose(nil)
end

return UIChatInsertHisPanel