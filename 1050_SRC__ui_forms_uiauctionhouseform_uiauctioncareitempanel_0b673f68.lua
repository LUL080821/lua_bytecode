------------------------------------------------
-- author:
-- Date: 2020-01-17
-- File: UIAuctionCareItemPanel.lua
-- Module: UIAuctionCareItemPanel
-- Description: Material attention interface
------------------------------------------------
local NGUITools = CS.NGUITools

-- //Module definition
local UIAuctionCareItemPanel = {
    -- Current transform
    Trans = nil,
    -- father
    Parent = nil,
    -- menu
    PopList = nil,

    ItemScroll = nil,
    ItemGrid = nil,
    ItemRes = nil,
    UILoopGrid = nil,

    ItemUIList = Dictionary:New(),

    ShowItemList = List:New(),
}

local L_ItemUI = nil

function UIAuctionCareItemPanel:OnFirstShow(trans, parent, rootForm)
    self.Trans = trans
    self.Parent = parent
    self.RootForm = rootForm
    self.Trans.gameObject:SetActive(true)
    self.ItemScroll = UIUtils.FindScrollView(trans, "ItemScrll")
    self.ItemGrid = UIUtils.FindGrid(trans, "ItemScrll/Grid")
    self.ItemRes = nil
    self.ItemUIList:Clear()
    local _parentTrans = self.ItemGrid.transform
    local _childCount = _parentTrans.childCount
    for i = 1, _childCount do
        local _trans = _parentTrans:GetChild(i - 1)
        self.ItemUIList:Add(_trans, L_ItemUI:New(_trans))
        if self.ItemRes == nil then
            self.ItemRes = _trans.gameObject
        end
    end
    self.UILoopGrid = UIUtils.RequireUILoopScrollViewBase(self.ItemGrid.transform)
    self.UILoopGrid:SetDelegate(Utils.Handler(self.LoopGridCallBack, self))
    return self
end

function UIAuctionCareItemPanel:LoopGridCallBack(trans, name, isClear)
    local index = tonumber(name)
    local _uiItem = self.ItemUIList[trans]
    if _uiItem == nil then
        _uiItem = L_ItemUI:New(trans)
        self.ItemUIList[trans] = _uiItem
    end
    if index <= #self.ShowItemList then
        _uiItem:SetItem(self.ShowItemList[index])
    else
        _uiItem:SetItem(nil)
    end
end

function UIAuctionCareItemPanel:Refresh(menuID)
    self.ShowItemList:Clear()
    local _menuCfg = DataConfig.DataAuctionCareMenu[menuID]
    if _menuCfg ~= nil then
        local _itemList = Utils.SplitNumber(_menuCfg.ItemList, '_')
        if _itemList ~= nil and #_itemList > 0 then
            for i = 1, #_itemList do
                self.ShowItemList:Add(_itemList[i])
            end
        end
        local function  _forFunc(key, value)
            local _cfg = value
            if _cfg.ParentId == menuID then
                _itemList = Utils.SplitNumber(_cfg.ItemList, '_')
                if _itemList ~= nil and #_itemList > 0 then
                    for i = 1, #_itemList do
                        self.ShowItemList:Add(_itemList[i])
                    end
                end
            end
        end
        DataConfig.DataAuctionCareMenu:Foreach(_forFunc)
        self.UILoopGrid:Init(#self.ShowItemList, self.ItemRes)
        self.ItemGrid.repositionNow = true
        self.ItemScroll.repositionWaitFrameCount = 2
    end
end

L_ItemUI = {
    GO = nil,
    UIItem = nil,
    Name = nil,
    Desc = nil,
    CareToggle = nil,
    ItemID = -1,
}
function L_ItemUI:New(trans)
    local _m = Utils.DeepCopy(self)
    _m.GO = trans.gameObject
    _m.UIItem = UILuaItem:New(UIUtils.FindTrans(trans, "Item"))
    _m.Name = UIUtils.FindLabel(trans, "Name")
    _m.Desc = UIUtils.FindLabel(trans, "Desc")
    _m.CareToggle = UIUtils.FindToggle(trans, "Care")
    UIUtils.AddOnChangeEvent(_m.CareToggle, _m.OnCareChangeCallBack, _m)
    return _m
end

function L_ItemUI:SetItem(itemID)
    self.ItemID = itemID
    local _itemCfg = DataConfig.DataItem[itemID]
    local _equipCfg = DataConfig.DataEquip[itemID]
    if _itemCfg ~= nil then
        self.GO:SetActive(true)
        self.UIItem:InItWithCfgid(itemID, 1)
        UIUtils.SetTextFormat(self.Name, "[{0}]{1}",  Utils.GetQualityStrColor(_itemCfg.Color),  _itemCfg.Name)
        self.CareToggle.value = GameCenter.AuctionHouseSystem.CareItemList[itemID] ~= nil
        UIUtils.SetTextByStringDefinesID(self.Desc, _itemCfg._AuctionText)
    elseif _equipCfg ~= nil then
        self.GO:SetActive(true)
        self.UIItem:InItWithCfgid(itemID, 1)
        UIUtils.SetTextFormat(self.Name, "[{0}]{1}",  Utils.GetQualityStrColor(_equipCfg.Quality),  _equipCfg.Name)
        self.CareToggle.value = GameCenter.AuctionHouseSystem.CareItemList[itemID] ~= nil
        UIUtils.SetTextByStringDefinesID(self.Desc, _equipCfg._AuctionText)
    else
        self.GO:SetActive(false)
    end
end

function L_ItemUI:OnCareChangeCallBack()
    if self.CareToggle.value then
        GameCenter.AuctionHouseSystem:AddCareItem(self.ItemID)
    else
        GameCenter.AuctionHouseSystem:RemoveCareItem(self.ItemID)
    end
end

return UIAuctionCareItemPanel