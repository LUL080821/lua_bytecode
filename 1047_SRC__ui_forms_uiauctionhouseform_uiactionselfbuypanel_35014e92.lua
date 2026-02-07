------------------------------------------------
-- author:
-- Date: 2019-10-11
-- File: UIActionSelfBuyPanel.lua
-- Module: UIActionSelfBuyPanel
-- Description: Props interface that you bid for
------------------------------------------------
local UIAuctionItemUI = require "UI.Forms.UIAuctionHouseForm.UIAuctionItemUI"

-- //Module definition
local UIActionSelfBuyPanel = {
    -- Current transform
    Trans = nil,
    Go = nil,
    -- father
    Parent = nil,
    -- Animation module
    AnimModule = nil,
    -- menu
    PopList = nil,

    ItemScroll = nil,
    ItemGrid = nil,
    ItemRes = nil,
    ItemList = nil,

    -- Sort button
    SortPowerBtn = nil,
    SortPowerUP = nil,
    SortPowerDown = nil,

    SortTimeBtn = nil,
    SortTimeUP = nil,
    SortTimeDown = nil,

    SortCurPriceBtn = nil,
    SortCurPriceUP = nil,
    SortCurPriceDown = nil,

    SortMaxPriceBtn = nil,
    SortMaxPriceUP = nil,
    SortMaxPriceDown = nil,

    -- Do I need to refresh the item list?
    IsRefreshItemList = false,
}

function UIActionSelfBuyPanel:OnFirstShow(trans, parent, rootForm)
    self.Trans = trans
    self.Go = trans.gameObject
    self.Parent = parent
    self.RootForm = rootForm

    -- Create an animation module
    self.AnimModule = UIAnimationModule(self.Trans)
    -- Add an animation
	self.AnimModule:AddAlphaScaleAnimation(nil, 0, 1, 1.05, 1.05, 1, 1, 0.3, true, false)
    self.Go:SetActive(false)

    self.ItemScroll = UIUtils.FindScrollView(trans, "ItemScrll")
    self.ItemGrid = UIUtils.FindGrid(trans, "ItemScrll/Grid")

    self.ItemList = List:New()
    self.ItemRes = nil
    local _itemParent = self.ItemGrid.transform
    for i = 0, _itemParent.childCount - 1 do
        local _childTrans = _itemParent:GetChild(i)
        if self.ItemRes == nil then
            self.ItemRes = _childTrans.gameObject
            self.ItemRes:SetActive(false)
        else
            local _auItem = UIAuctionItemUI:New(_childTrans, self.RootForm)
            self.ItemList:Add(_auItem);
        end
    end

    self.SortPowerBtn = UIUtils.FindBtn(trans, "Title/Name")
    UIUtils.AddBtnEvent(self.SortPowerBtn, self.OnPowerSortBtnClick, self)
    self.SortPowerUP = UIUtils.FindGo(trans, "Title/Name/UP")
    self.SortPowerDown = UIUtils.FindGo(trans, "Title/Name/Down")

    self.SortTimeBtn = UIUtils.FindBtn(trans, "Title/RemainTime")
    UIUtils.AddBtnEvent(self.SortTimeBtn, self.OnTimeSortBtnClick, self)
    self.SortTimeUP = UIUtils.FindGo(trans, "Title/RemainTime/UP")
    self.SortTimeDown = UIUtils.FindGo(trans, "Title/RemainTime/Down")

    self.SortCurPriceBtn = UIUtils.FindBtn(trans, "Title/CurPrice")
    UIUtils.AddBtnEvent(self.SortCurPriceBtn, self.OnCurPriceSortBtnClick, self)
    self.SortCurPriceUP = UIUtils.FindGo(trans, "Title/CurPrice/UP")
    self.SortCurPriceDown = UIUtils.FindGo(trans, "Title/CurPrice/Down")

    self.SortMaxPriceBtn = UIUtils.FindBtn(trans, "Title/MaxPrice")
    UIUtils.AddBtnEvent(self.SortMaxPriceBtn, self.OnMaxPriceSortBtnClick, self)
    self.SortMaxPriceUP = UIUtils.FindGo(trans, "Title/MaxPrice/UP")
    self.SortMaxPriceDown = UIUtils.FindGo(trans, "Title/MaxPrice/Down")

    return self
end

-- Click on the combat power sort button
function UIActionSelfBuyPanel:OnPowerSortBtnClick()
    self:SetCurSortType(0)
end

-- Click on the time sort button
function UIActionSelfBuyPanel:OnTimeSortBtnClick()
    self:SetCurSortType(1)
end

-- Click the current price button
function UIActionSelfBuyPanel:OnCurPriceSortBtnClick()
    self:SetCurSortType(2)
end

-- Maximum price button click
function UIActionSelfBuyPanel:OnMaxPriceSortBtnClick()
    self:SetCurSortType(3)
end

-- Set the current sorting method
function UIActionSelfBuyPanel:SetCurSortType(sortType)
    if self.CurSortType == sortType then
        self.CurUPSort = not self.CurUPSort
    else
        self.CurUPSort = true
    end
    self.CurSortType = sortType
    self.SortPowerUP:SetActive(self.CurSortType == 0 and self.CurUPSort)
    self.SortPowerDown:SetActive(self.CurSortType == 0 and not self.CurUPSort)

    self.SortTimeUP:SetActive(self.CurSortType == 1 and self.CurUPSort)
    self.SortTimeDown:SetActive(self.CurSortType == 1 and not self.CurUPSort)

    self.SortCurPriceUP:SetActive(self.CurSortType == 2 and self.CurUPSort)
    self.SortCurPriceDown:SetActive(self.CurSortType == 2 and not self.CurUPSort)

    self.SortMaxPriceUP:SetActive(self.CurSortType == 3 and self.CurUPSort)
    self.SortMaxPriceDown:SetActive(self.CurSortType == 3 and not self.CurUPSort)
    self.IsRefreshItemList = true
end


function UIActionSelfBuyPanel:Show()
    -- Play the start-up picture
    self.AnimModule:PlayEnableAnimation()
    self.SelectType = type
    -- Default combat power ascending order
    self:SetCurSortType(0)
    self.IsRefreshItemList = true
end

function UIActionSelfBuyPanel:Hide()
    -- Play Close animation
    self.Go:SetActive(false)
end

function UIActionSelfBuyPanel:Update(dt)
    if self.IsRefreshItemList then
        self.IsRefreshItemList = false
        self:RefreshItemList()
    end
    for i = 1, #self.ItemList do
        self.ItemList[i]:Update(dt)
    end
end

function UIActionSelfBuyPanel:RefreshItemList()
    local _luaList = GameCenter.AuctionHouseSystem:GetSelBuyItemList(self.CurSortType, self.CurUPSort)
    local _count = #_luaList

    for i = 1, #self.ItemList do
        self.ItemList[i]:SetData(nil)
    end

    for i = 1, _count do
        local _uiItem = nil
        if i <= #self.ItemList then
            _uiItem = self.ItemList[i]
        else
            _uiItem = UIAuctionItemUI:New(UnityUtils.Clone(self.ItemRes).transform, self.RootForm)
            self.ItemList:Add(_uiItem)
        end
        _uiItem:SetData(_luaList[i])
    end

    self.ItemGrid:Reposition()
    self.ItemScroll.repositionWaitFrameCount = 2
end

-- Return to purchase successfully
function UIActionSelfBuyPanel:OnBuySucc(id)
    for i = 1, #self.ItemList do
        if self.ItemList[i].RootGO.activeSelf then
            if self.ItemList[i].ItemInst == nil or (self.ItemList[i].ItemInst ~= nil and self.ItemList[i].ItemInst.ID <= 0) then
                self.ItemList[i]:SetData(nil)
            end
        end
    end
    self.ItemGrid:Reposition()
    --self.ItemScroll.repositionWaitFrameCount = 2
end

-- Bidding Return
function UIActionSelfBuyPanel:OnJingJiaResult(id)
    -- Reset the data
    for i = 1, #self.ItemList do
        if self.ItemList[i].RootGO.activeSelf then
            if self.ItemList[i].ItemInst == nil or (self.ItemList[i].ItemInst ~= nil and self.ItemList[i].ItemInst.ID <= 0) then
                self.ItemList[i]:SetData(nil)
            elseif self.ItemList[i].ItemInst.ID == id then
                self.ItemList[i]:SetData(self.ItemList[i].ItemInst)
            end
        end
    end
    self.ItemGrid:Reposition()
    --self.ItemScroll.repositionWaitFrameCount = 2
end

function UIActionSelfBuyPanel:ReSortList()
    self.ItemGrid:Reposition()
end

return UIActionSelfBuyPanel