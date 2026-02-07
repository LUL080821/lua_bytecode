------------------------------------------------
-- author:
-- Date: 2019-10-8
-- File: UIAuctionItemListPanel.lua
-- Module: UIAuctionItemListPanel
-- Description: Auction house item list interface
------------------------------------------------
local L_PopupListMenu = require "UI.Components.UIPopoupListMenu.PopupListMenu"
local L_UIPopSelectList = require "UI.Components.UIPopSelectList.UIPopSelectList"
local UIAuctionItemUI = require "UI.Forms.UIAuctionHouseForm.UIAuctionItemUI"
local L_PageItemCount = 10

-- //Module definition
local UIAuctionItemListPanel = {
    -- Current transform
    Trans = nil,
    Go = nil,
    -- father
    Parent = nil,
    -- Animation module
    AnimModule = nil,
    -- menu
    PopList = nil,
    BigMenuIds = nil,
    PopScrollView = nil,

    ItemScroll = nil,
    ItemGrid = nil,
    ItemRes = nil,
    ItemList = nil,

    -- Level filtering
    LevelScreenBtn = nil,
    -- Quality filtering
    QualityScreenBtn = nil,

    -- Page selection
    FrontBtn = nil,
    NextBtn = nil,
    CurPageLabel = nil,

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

    -- search
    SearchInput = nil,
    SearchBtn = nil,

    -- Current gold coins
    CurMoney = nil,

    -- The currently selected type, 0 world, 1 guild
    SelectType = 0,
    -- The currently selected menu ID
    CurMenuID = 0,
    -- The currently selected order
    CurGrade = 0,
    -- The current star rating
    CurStar = 0,
    -- The quality currently selected
    CurQuality = 0,
    -- In which item is currently selected, 0 combat power, 1 remaining time, 2 current price, 3 maximum price
    CurSortType = 0,
    -- Ascending or descending order currently selected
    CurUPSort = false,
    -- The number of pages currently selected
    CurPage = 0,
    -- Current maximum number of pages
    MaxPage = 0,

    -- Do I need to refresh the item list?
    IsRefreshItemList = false,
}

function UIAuctionItemListPanel:OnFirstShow(trans, parent, rootForm)
    self.Trans = trans
    self.Go = trans.gameObject
    self.Parent = parent
    self.RootForm = rootForm

    -- Create an animation module
    self.AnimModule = UIAnimationModule(self.Trans)
    -- Add an animation
	self.AnimModule:AddAlphaScaleAnimation(nil, 0, 1, 1.05, 1.05, 1, 1, 0.3, true, false)
    self.Go:SetActive(false)

    -- Add PopoupListMenu
    self.PopScrollView = UIUtils.FindScrollView(trans, "BtnScrll")
    self.PopList = L_PopupListMenu:CreateMenu(UIUtils.FindTrans(trans, "BtnScrll/PopoupList"), Utils.Handler(self.OnClickChildMenu,self), 3, false)
    local _menuDataDic = Dictionary:New()
    self.BigMenuIds = {}
    DataConfig.DataAuctionMenu:Foreach(function(key, value)
        if value.ParentId <= 0 then
            _menuDataDic[key] = {value.Name, List:New()}
        else
            local _parentData = _menuDataDic[value.ParentId]
            if _parentData then
                _parentData[2]:Add({Id = value.Id ,Name = value.Name})
            end
        end
    end)

    _menuDataDic:Foreach(function(key, value)
        self.BigMenuIds[key] = true
        self.PopList:AddMenu(key, value[1], value[2])
    end)

    self.ItemScroll = UIUtils.FindScrollView(trans, "ItemScrll")
    self.ItemGrid = UIUtils.FindGrid(trans, "ItemScrll/Grid")

    self.LevelScreenBtn = L_UIPopSelectList:OnFirstShow(UIUtils.FindTrans(trans, "Bottom/LevelSelect"))
    self.QualityScreenBtn = L_UIPopSelectList:OnFirstShow(UIUtils.FindTrans(trans, "Bottom/QualitySelect"))
    self:InitScreenBtn()

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

    self.FrontBtn = UIUtils.FindBtn(trans, "Bottom/Forword")
    UIUtils.AddBtnEvent(self.FrontBtn, self.OnFrontPageBtnClick, self)
    self.NextBtn = UIUtils.FindBtn(trans, "Bottom/Next")
    UIUtils.AddBtnEvent(self.NextBtn, self.OnNextPageBtnClick, self)
    self.CurPageLabel = UIUtils.FindLabel(trans, "Bottom/Page/Label")

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

    self.SearchInput = UIUtils.FindInput(trans, "Bottom/SerchInput")
    self.SearchBtn = UIUtils.FindBtn(trans, "Bottom/SerchInput/Find")
    UIUtils.AddBtnEvent(self.SearchBtn, self.OnSearchBtnClick, self)

    self.CurMoney = UIUtils.FindLabel(trans, "Bottom/MyMoneyLabel")

    return self
end

function UIAuctionItemListPanel:InitScreenBtn()
    -- Career screening data
    local _list = List:New()
    -- Level
    _list:Clear()
    _list:Add({ID = 15, Text = DataConfig.DataMessageString.Get("FifthOrHigher")})
    _list:Add({ID = 14, Text = DataConfig.DataMessageString.Get("FourteenOrHigher")})
    _list:Add({ID = 13, Text = DataConfig.DataMessageString.Get("ThirteenOrHigher")})
    _list:Add({ID = 12, Text = DataConfig.DataMessageString.Get("TwelveOrHigher")})
    _list:Add({ID = 11, Text = DataConfig.DataMessageString.Get("ElevenOrHigher")})
    _list:Add({ID = 10, Text = DataConfig.DataMessageString.Get("TenOrHigher")})
    _list:Add({ID = 9, Text = DataConfig.DataMessageString.Get("NineOrHigher")})
    _list:Add({ID = 8, Text = DataConfig.DataMessageString.Get("EightOrHigher")})
    _list:Add({ID = 7, Text = DataConfig.DataMessageString.Get("SevenOrHigher")})
    _list:Add({ID = 6, Text = DataConfig.DataMessageString.Get("SixOrHigher")})
    _list:Add({ID = 5, Text = DataConfig.DataMessageString.Get("FiveOrHigher")})
    _list:Add({ID = 4, Text = DataConfig.DataMessageString.Get("FourOrHigher")})
    _list:Add({ID = 3, Text = DataConfig.DataMessageString.Get("ThreeOrHigher")})
    _list:Add({ID = -1, Text = DataConfig.DataMessageString.Get("AllEqualStage")})
    self.LevelScreenBtn:SetData(_list)

    -- quality
    _list:Clear()
    _list:Add({ID = 10, Text = DataConfig.DataMessageString.Get("ColorfulOrHigher")})
    _list:Add({ID = 9, Text = DataConfig.DataMessageString.Get("DullGoldOrHigher")})
    _list:Add({ID = 8, Text = DataConfig.DataMessageString.Get("PinkOrHigher")})
    _list:Add({ID = 7, Text = DataConfig.DataMessageString.Get("RedOrHigher")})
    _list:Add({ID = 6, Text = DataConfig.DataMessageString.Get("GoldOrHigher")})
    _list:Add({ID = 4, Text = DataConfig.DataMessageString.Get("PurpleOrHigher")})
    _list:Add({ID = -1, Text = DataConfig.DataMessageString.Get("AllQuality")})
    self.QualityScreenBtn:SetData(_list)

    self.LevelScreenBtn:SetOnSelectCallback(Utils.Handler(self.OnLevelScreenSelectCallBack, self))
    self.QualityScreenBtn:SetOnSelectCallback(Utils.Handler(self.OnQualityScreenSelectCallBack, self))
end

-- Level filter selection callback
function UIAuctionItemListPanel:OnLevelScreenSelectCallBack(index, data)
    if self.CurGrade ~= data.ID then
        self.CurGrade = data.ID
        self:SetSearchText(nil)
        self.IsRefreshItemList = true
    end
end

-- Quality filter selection callback
function UIAuctionItemListPanel:OnQualityScreenSelectCallBack(index, data)
    if self.CurQuality ~= data.ID then
        self.CurQuality = data.ID
        self:SetSearchText(nil)
        self.IsRefreshItemList = true
    end
end

-- Click on the previous page button
function UIAuctionItemListPanel:OnFrontPageBtnClick()
    if self.CurPage > 0 then
        self.CurPage = self.CurPage - 1
        self.IsRefreshItemList = true
    end
end

-- Click on the next page button
function UIAuctionItemListPanel:OnNextPageBtnClick()
    if self.CurPage < (self.MaxPage - 1) then
        self.CurPage = self.CurPage + 1
        self.IsRefreshItemList = true
    end
end

-- Click on the combat power sort button
function UIAuctionItemListPanel:OnPowerSortBtnClick()
    self:SetCurSortType(0)
end

-- Click on the time sort button
function UIAuctionItemListPanel:OnTimeSortBtnClick()
    self:SetCurSortType(1)
end

-- Click the current price button
function UIAuctionItemListPanel:OnCurPriceSortBtnClick()
    self:SetCurSortType(2)
end

-- Maximum price button click
function UIAuctionItemListPanel:OnMaxPriceSortBtnClick()
    self:SetCurSortType(3)
end

-- Click on the name search button
function UIAuctionItemListPanel:OnSearchBtnClick()
    if string.len(self.SearchInput.value) > 0 then
        -- Selection reset
        self.CurMenuID = 1
        self.CurGrade = -1
        self.CurStar = -1
        self.CurQuality = -1
        self.CurPage = 0
        self.CurSortType = -1
        -- Open all by default
        self.PopList:OpenMenuList(self.CurMenuID)
        -- All are selected by default
        self.LevelScreenBtn:SetSelectById(self.CurGrade)
        -- All are selected by default
        self.QualityScreenBtn:SetSelectById(self.CurQuality)
        -- Default combat power descending order
        self:SetCurSortType(0, false)
        self.IsRefreshItemList = true
    end 
end

-- Set the current sorting method
function UIAuctionItemListPanel:SetCurSortType(sortType, upSort)
    if upSort ~= nil then
        self.CurUPSort = upSort
    else
        if self.CurSortType == sortType then
            self.CurUPSort = not self.CurUPSort
        else
            self.CurUPSort = true
        end
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


-- Set the search box content
function UIAuctionItemListPanel:SetSearchText(searchText)
    if searchText == nil then
        self.SearchInput.value = ""
    else
        self.SearchInput.value = searchText
    end
end

function UIAuctionItemListPanel:Show(type, searchName)
    -- Play the start-up picture
    self.AnimModule:PlayEnableAnimation()
    self.SelectType = type

    -- All are selected by default
    self.CurMenuID = 1
    self.CurGrade = -1
    self.CurStar = -1
    self.CurQuality = -1
    self.CurPage = 0
    self.CurSortType = -1
    -- Set the search name
    self:SetSearchText(searchName)
    -- Open all by default
    self.PopList:OpenMenuList(self.CurMenuID)
    -- All are selected by default
    self.LevelScreenBtn:SetSelectById(self.CurGrade)
    -- All are selected by default
    self.QualityScreenBtn:SetSelectById(self.CurQuality)

    if searchName ~= nil and string.len(searchName) > 0 then
        -- When searching for names, the default combat power descending order
        self:SetCurSortType(0, false)
    else
        -- Default combat power ascending order
        self:SetCurSortType(0, true)
    end

    self.IsRefreshItemList = true
end

function UIAuctionItemListPanel:Hide()
    -- Play Close animation
    self.Go:SetActive(false)
end

function UIAuctionItemListPanel:Update(dt)
    self.PopList:Update(dt)

    if self.IsRefreshItemList then
        self.IsRefreshItemList = false
        self:RefreshItemList()
    end

    local _rePos = false
    for i = 1, #self.ItemList do
        if self.ItemList[i]:Update(dt) then
            _rePos = true
        end
    end
    if _rePos then
        self.ItemGrid:Reposition()
    end
end

function UIAuctionItemListPanel:OnClickChildMenu(id)
    if id <= 0 then
        return
    end
    if self.CurMenuID ~= id then
        self.CurMenuID = id
        self:SetSearchText(nil)
        self.IsRefreshItemList = true
        if self.BigMenuIds[id] == true then
            -- When clicking on the large menu
            self.PopScrollView.repositionWaitFrameCount = 2
        end
    end
end

function UIAuctionItemListPanel:RefreshItemList()
    UIUtils.SetTextByNumber(self.CurMoney, GameCenter.ItemContianerSystem:GetEconomyWithType(ItemTypeCode.Lingshi))
    local _luaList = GameCenter.AuctionHouseSystem:GetItemList(self.SelectType, self.CurMenuID, self.CurGrade, self.CurStar, self.CurQuality, self.CurSortType, self.CurUPSort, self.SearchInput.value)
    local _count = #_luaList
    if math.floor(_count % L_PageItemCount)  ~= 0 then
        self.MaxPage = math.floor(_count / L_PageItemCount) + 1
    else
        self.MaxPage = math.floor(_count / L_PageItemCount)
    end
    if self.MaxPage <= 0 then
        self.MaxPage = 1
    end

    if self.CurPage >= self.MaxPage then
        self.CurPage = self.MaxPage - 1
    end

    local _index = 1
    for i = self.CurPage * L_PageItemCount + 1, (self.CurPage + 1) * L_PageItemCount do
        if i <= _count then
            local _uiItem = nil
            if _index <= #self.ItemList then
                _uiItem = self.ItemList[_index]
            else
                _uiItem = UIAuctionItemUI:New(UnityUtils.Clone(self.ItemRes).transform, self.RootForm)
                self.ItemList:Add(_uiItem)
            end
            _uiItem:SetData(_luaList[i])
            _index = _index + 1
        end
    end

    for i = _index, #self.ItemList do
        self.ItemList[i]:SetData(nil)
    end

    UIUtils.SetTextByEnum(self.CurPageLabel, "Progress", self.CurPage + 1, self.MaxPage)
    self.ItemGrid:Reposition()
    self.ItemScroll.repositionWaitFrameCount = 2
end

-- Return to purchase successfully
function UIAuctionItemListPanel:OnBuySucc(id)
    UIUtils.SetTextByNumber(self.CurMoney, GameCenter.ItemContianerSystem:GetEconomyWithType(ItemTypeCode.Lingshi))
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
function UIAuctionItemListPanel:OnJingJiaResult(id)
    UIUtils.SetTextByNumber(self.CurMoney, GameCenter.ItemContianerSystem:GetEconomyWithType(ItemTypeCode.Lingshi))
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

function UIAuctionItemListPanel:ReSortList()
    self.ItemGrid:Reposition()
end

return UIAuctionItemListPanel
