------------------------------------------------
-- author:
-- Date: 2021-04-06
-- File: UIChatInsertItemPanel.lua
-- Module: UIChatInsertItemPanel
-- Description: Chat Insert Item Panel
------------------------------------------------

local L_UIMainSubBasePanel = require "UI.Forms.UIMainForm.UIMainSubBasePanel"

local UIChatInsertItemPanel = {
    ScrollView = nil,
    Grid = nil,
    ItemRes = nil,
    UILoopGrid = nil,
    ShowItemInsts = nil,
    ShowItemTable = nil,
}

function UIChatInsertItemPanel:OnFirstShow(trans, parent, rootForm)
    setmetatable(self, {__index = L_UIMainSubBasePanel.New()})
    self:BaseFirstShow(trans, parent, rootForm)
    self.ScrollView = UIUtils.FindScrollView(trans, "ScrollView")
    self.Grid = UIUtils.FindGrid(trans, "ScrollView/Grid")
    local _parentTrans = self.Grid.transform
    local _childCount = _parentTrans.childCount
    self.ShowItemTable = {}
    self.ItemRes = nil
    for i = 1, _childCount do
        local _childTrans = _parentTrans:GetChild(i - 1)
        local _uiItem = UILuaItem:New(_childTrans)
        _uiItem.IsShowTips = false
        _uiItem.SingleClick = Utils.Handler(self.OnItemClick, self)
        self.ShowItemTable[_childTrans] = _uiItem
        if self.ItemRes == nil then
            self.ItemRes = _childTrans.gameObject
        end
    end
    self.UILoopGrid = UIUtils.RequireUILoopScrollViewBase(self.Grid.transform)
    self.UILoopGrid:SetDelegate(Utils.Handler(self.LoopGridCallBack, self))
    self.ShowItemInsts = List:New()
    return self
end

function UIChatInsertItemPanel:OpenByTypeId(id)
    self.CurSelectPanel = id
    self:Open()
end

function UIChatInsertItemPanel:OnShowAfter()
    self.ShowItemInsts:Clear()
    if self.CurSelectPanel == ChatInsertType.HolyEquip then
        local _equiTable = GameCenter.HolyEquipSystem.EquipDic
        local _bagList = GameCenter.HolyEquipSystem.BagList
        for k, v in pairs(_equiTable) do
            if v.Equip ~= nil then
                self.ShowItemInsts:Add(v.Equip)
            end
        end
        for i = 1, #_bagList do
            self.ShowItemInsts:Add(_bagList[i])
        end
    elseif self.CurSelectPanel == ChatInsertType.UnrealEquip then
        local _equiTable = GameCenter.UnrealEquipSystem.EquipDic
        local _bagList = GameCenter.UnrealEquipSystem.BagList
        for k, v in pairs(_equiTable) do
            if v.Equip ~= nil then
                self.ShowItemInsts:Add(v.Equip)
            end
        end
        for i = 1, #_bagList do
            self.ShowItemInsts:Add(_bagList[i])
        end
    else
        local _bagList = GameCenter.ItemContianerSystem:GetBackpackModelByType(ContainerType.ITEM_LOCATION_BAG)
        local _dressList = GameCenter.ItemContianerSystem:GetBackpackModelByType(ContainerType.ITEM_LOCATION_EQUIP)
        local _iter = _dressList.ItemsOfUID:GetEnumerator()
        while(_iter:MoveNext()) do
            self.ShowItemInsts:Add(_iter.Current.Value)
        end
        _iter:Dispose()
        _iter = _bagList.ItemsOfUID:GetEnumerator()
        while(_iter:MoveNext()) do
            self.ShowItemInsts:Add(_iter.Current.Value)
        end
        _iter:Dispose()
    end
    for k, v in pairs(self.ShowItemTable) do
        v:InitWithItemData(nil)
    end
    local _cellCount = #self.ShowItemInsts
    if _cellCount < 28 then
        _cellCount = 28
    elseif _cellCount % 7 ~= 0 then
        _cellCount = (_cellCount // 7 + 1) * 7
    end
    self.UILoopGrid:Init(_cellCount, self.ItemRes)
    self.Grid.repositionNow = true
    self.ScrollView.repositionWaitFrameCount = 2
end

function UIChatInsertItemPanel:LoopGridCallBack(trans, name, isClear)
    local index = tonumber(name)
    local _uiItem = self.ShowItemTable[trans]
    if _uiItem == nil then
        _uiItem = UILuaItem:New(trans)
        _uiItem.IsShowTips = false
        _uiItem.SingleClick = Utils.Handler(self.OnItemClick, self)
        self.ShowItemTable[trans] = _uiItem
    end
    if index <= #self.ShowItemInsts then
        _uiItem:InitWithItemData(self.ShowItemInsts[index])
    else
        _uiItem:InitWithItemData(nil)
    end
end

function UIChatInsertItemPanel:OnItemClick(uiItem)
    if uiItem.ShowItemData ~= nil then
        local item = uiItem.ShowItemData
        local _itemType = item.Type
        local _nodeText = nil
        if _itemType == ItemType.Equip or _itemType == ItemType.ImmortalEquip then
            -- <t=Equipment type><Enhancement level_Star upgrade level_Role level, Configuration id_Is there any special attributes, name>
            _nodeText = string.format("<t=%d>%s,%d,%s</t>", 5, item:ToProtoBufferBytes(), item.CfgID, item.Name)
        else
            _nodeText = string.format("<t=%d>%d,%d,%s</t>", 2, item.DBID, item.CfgID, item.Name)
        end
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_CHAT_INSERT_ITEM, _nodeText)
    end
end

return UIChatInsertItemPanel