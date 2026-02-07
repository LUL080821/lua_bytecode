------------------------------------------------
--author:
--Date: 2019-7-5
--File: UIShopMallPanel.lua
--Module: UIShopMallPanel
--Description: Yuanbao Mall, redemption Mall Panel
------------------------------------------------
local L_UIListMenu = require "UI.Components.UIListMenu.UIListMenu"
local L_ItemList = require("UI.Forms.UIShopMallForm.UIShopMallItem")
local L_TypeItem = require("UI.Forms.UIShopMallForm.UIShopMallTypeItem")
local L_AddReduce = require("UI.Components.UIAddReduce")
local L_BuyComfirmPanel = require("UI.Forms.UIShopMallForm.UIShopMallBuyComfirmPanel")
local L_ItemBase = CS.Thousandto.Code.Logic.ItemBase
local L_BattlePropTools = CS.Thousandto.Code.Logic.BattlePropTools
local L_UIAnimDelayPlayer = require "UI.Components.UIAnimDelayPlayer"

local UIShopMallPanel = {
    Trans = nil,
    Go = nil,
    CSForm = nil,
    --Product List
    ListScrollView = nil,
    ListGrid = nil,
    ListGridTrans = nil,
    ListItem = nil,
    ShopList = List:New(),
    --Category List
    TypeGrid = nil,
    TypeGridTrans = nil,
    TypeItem = nil,
    TypeList = List:New(),

    --Quantity input
    NumInput = nil,

    --The current number of inputs
    CurSetNum = 1,

    --The currently selected product
    CurSelectGoods = nil,

    --The maximum purchase volume of current products
    CurGoodsMaxCount = 1,

    --The name and description of the currently selected item
    CurGoodsNameLabel = nil,
    CurGoodsDescLabel = nil,

    --Total value and current currency
    CostCoinIcon = nil,
    CostCoinNumLabel = nil,
    HaveCoinIcon = nil,
    HaveCoinNumLabel = nil,

    --Buy Button
    BuyBtn = nil,

    --The currently selected page
    CurPanel = ShopPanelEnum.GoldShop,
    CurSubPanel = ShopSubPanelEnum.BindGoldShop,
    OpenSelectItemId = nil,

    IsVisible = false,
}

function UIShopMallPanel:OnFirstShow(parent, trans)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.CSForm = parent
    _m.Go = trans.gameObject
    _m:FindAllComponents()
    _m:RegUICallback()
	_m.AnimPlayer = L_UIAnimDelayPlayer:New(_m.CSForm.AnimModule)
    return _m
end

function UIShopMallPanel:OnOpen()
    self.Go:SetActive(true)
    self.IsVisible = true
    self.BuyPanel.Go:SetActive(false)
end

function UIShopMallPanel:OnClose()
    self.Go:SetActive(false)
    self.IsVisible = false
end

function UIShopMallPanel:OnTryHide()
    if self.BuyPanel.IsVisible then
        self.BuyPanel:OnClose()
        return false
    end
    return true
end

function UIShopMallPanel:Update(dt)
    if not self.IsVisible then
        return
    end
    self.AnimPlayer:Update(dt)
end

--Find various controls on the UI
function UIShopMallPanel:FindAllComponents()
    self.ListScrollView = UIUtils.FindScrollView(self.Trans, "BuyGo/ItemScroll")
    self.ScrollTrans = UIUtils.FindTrans(self.Trans, "BuyGo/ItemScroll")
    self.ListGridTrans = UIUtils.FindTrans(self.Trans, "BuyGo/ItemScroll/Grid")
    self.ListGrid = UIUtils.FindGrid(self.Trans, "BuyGo/ItemScroll/Grid")
    for i = 0, self.ListGridTrans.childCount - 1 do
        self.ListItem = L_ItemList:New(self.ListGridTrans:GetChild(i))
        self.ShopList:Add(self.ListItem)
        self.ListItem.ClickCallBack = Utils.Handler(self.OnClickItem, self)
    end
    self.TypeScroll = UIUtils.FindScrollView(self.Trans, "BuyGo/BtnScrll")
    self.TypeGridTrans = UIUtils.FindTrans(self.Trans, "BuyGo/BtnScrll/Grid")
    self.TypeGrid = UIUtils.FindGrid(self.Trans, "BuyGo/BtnScrll/Grid")
    for i = 0, self.TypeGridTrans.childCount - 1 do
        self.TypeItem = L_TypeItem:New(self.TypeGridTrans:GetChild(i))
        self.TypeItem.CallBack = Utils.Handler(self.OnClickType, self)
        self.TypeList:Add(self.TypeItem)
    end
    self.AddCoinBtn = UIUtils.FindBtn(self.Trans, "BuyGo/BgRight/HaveCoin/AddBtn")
    self.NumInput = L_AddReduce:OnFirstShow(UIUtils.FindTrans(self.Trans, "BuyGo/BgRight/UIAddReduce"))
    self.CurGoodsNameLabel = UIUtils.FindLabel(self.Trans, "BuyGo/BgRight/NameLabel")
    self.CurGoodsDescLabel = UIUtils.FindLabel(self.Trans, "BuyGo/BgRight/DescScroll/DesLabel")
    self.GoodsDescScroll = UIUtils.FindScrollView(self.Trans, "BuyGo/BgRight/DescScroll")
    self.CostCoinIcon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(self.Trans, "BuyGo/BgRight/TotalPrice"))
    self.CostCoinNumLabel = UIUtils.FindLabel(self.Trans, "BuyGo/BgRight/TotalPrice/PriceLabel")
    self.HaveCoinIcon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(self.Trans, "BuyGo/BgRight/HaveCoin"))
    self.HaveCoinNumLabel = UIUtils.FindLabel(self.Trans, "BuyGo/BgRight/HaveCoin/PriceLabel")
    self.BuyBtn = UIUtils.FindBtn(self.Trans, "BuyGo/BgRight/BuyBtn")
    self.NumInput:SetCallBack(Utils.Handler(self.OnClickAddReduce, self), Utils.Handler(self.OnClickAddReduceInput, self))
    -- self.ListMenu = L_UIListMenu:OnFirstShow(self.CSForm, UIUtils.FindTrans(self.Trans, "TopMenu"))
    -- self.ListMenu:ClearSelectEvent();
    -- self.ListMenu:AddSelectEvent(Utils.Handler(self.OnClickCallBack, self))
    -- self.ListMenu.IsHideIconByFunc = true
    self.BuyPanel = L_BuyComfirmPanel:OnFirstShow(self.CSForm, UIUtils.FindTrans(self.Trans, "BuyComfirmGo"))
    self.BuyPanel:OnClose()

    self.NewShopItemList = List:New()
    local _str = PlayerPrefs.GetString("ShopMarketList")
    if _str and _str ~= "" then
        local _arr = Utils.SplitNumber(_str, '_')
        for i = 1, #_arr do
            if _arr[i] then
                self.NewShopItemList:Add(_arr[i])
            end
        end
    end
    self.RightTrans = UIUtils.FindTrans(self.Trans, "BuyGo/BgRight")
    self.CSForm:AddAlphaPosAnimation(self.RightTrans, 0, 1, 50, 0, 0.3, false, false)
end

function UIShopMallPanel:RegUICallback()
    UIUtils.AddBtnEvent(self.BuyBtn, self.OnBuyBtnClick, self)
    UIUtils.AddBtnEvent(self.AddCoinBtn, self.OnClickAddCoinBtn, self)
end

--Add currency
function UIShopMallPanel:OnClickAddCoinBtn()
    GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(self.CoinType)
end

--Click to callback on the list of small tags at the top of the mall
function UIShopMallPanel:OnClickCallBack(id, mainPanel)

        self.CurSelectGoods = nil
        self.CurSelectType = nil
        self:HideItemList()
        GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN, DataConfig.DataMessageString.Get("Load_GoodsList"));
        GameCenter.Network.Send("MSG_Shop.ReqShopList", {shopId = mainPanel, labelId = id, gradeLimit = 0})
end

--Click on the product list
function UIShopMallPanel:OnClickItem(item)
    if self.CurSelectGoods ~= nil then
        self.CurSelectGoods:Select(false)
    end
    self.CurSelectGoods = item
    self.CurSelectGoods:Select(true)
    self:OnUpdateSelectItemInfo()
    self.CurSelectGoods:SetIsNew(false)
    if not self.NewShopItemList:Contains(self.CurSelectGoods.ShopItemInfo.SellId) and self.CurSelectGoods.ShopItemInfo.BuyLv > 0 then
        self.NewShopItemList:Add(self.CurSelectGoods.ShopItemInfo.SellId)
        self:SaveShopList()
    end
    if self.TypeDataDic and self.TypeDataDic:ContainsKey(self.CurSelectType.Type) then
        local _itemDic = self.TypeDataDic[self.CurSelectType.Type]
        local _isNew = false
        _itemDic:ForeachCanBreak(function(k, v)
            if not self.NewShopItemList:Contains(v.SellId) and v.BuyLv > 0 then
                _isNew = true
                return true
            end
        end)
        self.CurSelectType:SetIsShow(_isNew)
    end
end

function UIShopMallPanel:OnClickType(item, playAnim)
    if self.CurSelectType then
        self.CurSelectType:Select(false)
        if self.CurSelectType ~= item then
            self.CurSelectGoods = nil
        end
    end
    local _lastSelectid = nil
    self.CurSelectType = item
    self.CurSelectType:Select(true)
    local _index = 1
    if self.CurSelectGoods then
        _lastSelectid = self.CurSelectGoods.ShopItemInfo.SellId
    end
    local _isMsgNotFund = false
    local _moveIndex = 1
    if self.OpenSelectItemId and self.OpenSelectItemId > 0 then
        _isMsgNotFund = true
    end
    local _animList = nil
    if playAnim then
        _animList = List:New()
		self.AnimPlayer:Stop()
    end
    if self.TypeDataDic and self.TypeDataDic:ContainsKey(item.Type) then
        local _itemDic = self.TypeDataDic[item.Type]
        _itemDic:Foreach(function(k, v)
            local _shopItemUI = nil
            if #self.ShopList >= _index then
                _shopItemUI = self.ShopList[_index]
            end
            if _shopItemUI == nil then
                _shopItemUI = self.ListItem:Clone()
                _shopItemUI.ClickCallBack = Utils.Handler(self.OnClickItem, self)
                self.ShopList:Add(_shopItemUI)
            end
            _shopItemUI.Go:SetActive(true)
            if playAnim then
                _animList:Add(_shopItemUI.Trans)
            end
            _shopItemUI:UpdateItem(v, not self.NewShopItemList:Contains(v.SellId) and v.BuyLv > 0)
            _shopItemUI:Select(false)
            --Select the last selected product
            if self.CurSelectGoods == _shopItemUI and not self.OpenSelectItemId then
                self.CurSelectGoods = _shopItemUI
                _moveIndex = _index
            end
            --Select the first one
            if _index == 1 and self.CurSelectGoods == nil then
                self.CurSelectGoods = _shopItemUI
            end
            --Open the product selected by default on the interface
            if self.OpenSelectItemId and v.ItemId == self.OpenSelectItemId then
                self.CurSelectGoods = _shopItemUI
                _moveIndex = _index
                self.OpenSelectItemId = nil
                _isMsgNotFund = false
            end
            _index = _index + 1
        end)
        if _isMsgNotFund then
            Utils.ShowPromptByEnum("C_SHOP_OPENIDISNOTFUND")
        end
        for i = _index, #self.ShopList do
            self.ShopList[i].Go:SetActive(false)
        end
        self.ListGrid:Reposition()
        self.ListScrollView:ResetPosition()
        if playAnim then
            for i = 1, #_animList do
                self.CSForm:RemoveTransAnimation(_animList[i])
                self.CSForm:AddAlphaPosAnimation(_animList[i], 0, 1, -50, 0, 0.3, false, false)
                self.AnimPlayer:AddTrans(_animList[i], (i - 1) * 0.03)
            end
            self.AnimPlayer:AddTrans(self.RightTrans, 0)
            self.AnimPlayer:Play()
        end

        if self.CurSelectGoods then
            self:OnClickItem(self.CurSelectGoods)
            if _moveIndex > 8 then
                local _clip = self.ListScrollView.panel.finalClipRegion
                local _max = math.ceil((_index - 1) / 2) * 100 - _clip.w
                local _moveDeltaY = (math.ceil(_moveIndex / 2) - 1) * 100
                if _moveDeltaY > _max then
                    _moveDeltaY = _max
                end
                local _targetPos = Vector3(self.ScrollTrans.localPosition.x, self.ScrollTrans.localPosition.y + _moveDeltaY, self.ScrollTrans.localPosition.z);
                local _spring = UIUtils.RequireSpringPanel(self.ScrollTrans)
                if _spring then
                    _spring.target = _targetPos
                    _spring.enabled = true
                end
            end
            self.OpenSelectItemId = nil
        end
    end
end

--Inactive, get V4 data
function UIShopMallPanel:OnClickAddReduce(add)
    if self.CurSelectGoods and self.CurSelectGoods.ShopItemInfo then
        if self.CurSelectGoods.ShopItemInfo.CountdisCount and self.CurSelectGoods.ShopItemInfo.CountdisCount ~= "" then
            Utils.ShowPromptByEnum("C_SHOP_DISCOUNTDIS_TIPS")
            return
        end
    end
    if add then
        self.CurSetNum = self.CurSetNum + 1
    else
        self.CurSetNum = self.CurSetNum - 1
    end

    self:FixNum()
    self.NumInput:SetValueLabel(tostring(self.CurSetNum))
    self:OnUpdateHaveCoin(self.CoinType)
end
--Enter click to open the numeric input keyboard
function UIShopMallPanel:OnClickAddReduceInput()
    if self.CurSelectGoods and self.CurSelectGoods.ShopItemInfo then
        if self.CurSelectGoods.ShopItemInfo.CountdisCount and self.CurSelectGoods.ShopItemInfo.CountdisCount ~= "" then
            Utils.ShowPromptByEnum("C_SHOP_DISCOUNTDIS_TIPS")
            return
        end
    end
    if self.CurSelectGoods then
        GameCenter.NumberInputSystem:OpenInput(self.CurSelectGoods:OnGetMaxNum(), Vector3(-200, 0, 0), function(num)
            if num < 1 then
                num = 1
            end
            self.CurSetNum = num
            self:FixNum()
            self.NumInput:SetValueLabel(tostring(num))
            self:OnUpdateHaveCoin(self.CoinType)
        end, 0, function()
            -- self:FixNum()
            -- self.NumInput:SetValueLabel(tostring(self.CurSetNum))
        end)
    end
end

--Quantity judgment: whether the upper and lower limits exceed
function UIShopMallPanel:FixNum()
    if self.CurSelectGoods then
        if self.CurSetNum < 1 then
            self.CurSetNum = 1
        end
        self.CurGoodsMaxCount = self.CurSelectGoods:OnGetMaxNum()
        if self.CurSetNum > self.CurGoodsMaxCount then
            self.CurSetNum = self.CurGoodsMaxCount
        end
    end
end

--Purchase button click
function UIShopMallPanel:OnBuyBtnClick()
    if not self.CurSelectGoods then
        return
    end
    local _vipLv = self.CurSelectGoods.ShopItemInfo.VipLv
    if _vipLv > 0 then
        if GameCenter.VipSystem:GetVipLevel() < _vipLv then
            Utils.ShowPromptByEnum("C_SHOP_BUY_VIPLV", _vipLv)
            return
        end
        if GameCenter.VipSystem.BaoZhuState == 0 then
            Utils.ShowPromptByEnum("C_SHOP_BUY_BAOZHU")
            return
        end
    end
    if not self.CoinEough and self.CoinType == ItemTypeCode.Gold then
        Utils.ShowMsgBox(function(code)
            if code == MsgBoxResultCode.Button2 then
                GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(ItemTypeCode.Gold)
            end
        end, "C_SHOPMALL_RECHARGE")
    else
        if GameCenter.ShopSystem.IsBuyComfirm then
            self.BuyPanel:OnOpen(self.CurSelectGoods.ShopItemInfo, self.CurSetNum)
        else
            if self.CoinEough then
                local _req = {}
                _req.sellId = self.CurSelectGoods.ShopItemInfo.SellId
                _req.num = self.CurSetNum
                GameCenter.Network.Send("MSG_Shop.ReqBuyItem", _req)
            else
                Utils.ShowPromptByEnum("C_SHOP_BUYCOINLESS_TIPS", L_ItemBase.GetItemName(self.CoinType))
            end
        end
    end
end

function UIShopMallPanel:OnUpdateTopMenu(panel)
    self.ListMenu:RemoveAll()
    if panel then
        self.CurPanel = panel
    end
    -- self:HideItemList()
    local _spContainer = GameCenter.ShopSystem:GetShopItemContainer(self.CurPanel)
    if _spContainer ~= nil then
        local _pageList = _spContainer.ShopPageList
        local _pageFuncDic = Dictionary:New()
        if _pageList then
            for idx = 1, _pageList:Count() do
                local _info = GameCenter.MainFunctionSystem:GetFunctionInfo(_pageList[idx]);
                if _info ~= nil and _info.IsVisible then
                    _pageFuncDic:Add(_pageList[idx], _info)
                end
            end
        end
        _pageFuncDic:SortValue(function(a, b)
            return a.Cfg.FunctionSortNum < b.Cfg.FunctionSortNum
        end)
        local _initPanel = nil
        _pageFuncDic:Foreach(function(k, v)
            if not _initPanel then
                _initPanel = k
            end
            self.ListMenu:AddIcon(k, v.Cfg.FunctionName, k);
        end)
        if _pageList:Contains(self.CurSubPanel) then
            self.ListMenu:SetSelectById(self.CurSubPanel)
        else
            self.ListMenu:SetSelectById(_initPanel)
        end
    end
end

--Update product list
function UIShopMallPanel:OnUpdateItemList(page, playAnim)
    local _spContainer = GameCenter.ShopSystem:GetShopItemContainer(self.CurPanel)
    if _spContainer == nil then
        return
    end
    local _itemDic = _spContainer:GetShopItemDic(page)
    local _index = 1;
    if not self.TypeDataDic then
        self.TypeDataDic = Dictionary:New()
    else
        self.TypeDataDic:Clear()
    end
    local _openSelectType = nil
    --Classify all products and store them
    _itemDic:Foreach(function(k, v)
        if v.ItemTypeList:Count() > 0 then
            for i = 1, #v.ItemTypeList do
                if self.TypeDataDic:ContainsKey(v.ItemTypeList[i]) then
                    self.TypeDataDic[v.ItemTypeList[i]]:Add(k, v)
                else
                    local _tempItemDic = Dictionary:New()
                    _tempItemDic:Add(k, v)
                    self.TypeDataDic:Add(v.ItemTypeList[i], _tempItemDic)
                end
                if self.OpenSelectItemId and self.OpenSelectItemId == v.ItemId and not _openSelectType then
                    _openSelectType= v.ItemTypeList[i]
                end
            end
        end
    end)
    self.TypeDataDic:SortKey(function(a, b)
        return a < b
    end)
    --Load the category list
    self.TypeDataDic:Foreach(function(k, v)
        v:SortValue(function(a,b)
            return a.Index < b.Index
        end)
        local _typeItem = nil
        if #self.TypeList >= _index then
            _typeItem = self.TypeList[_index]
        else
            _typeItem = self.TypeItem:Clone()
            _typeItem.CallBack = Utils.Handler(self.OnClickType, self)
            self.TypeList:Add(_typeItem)
        end
        _typeItem.Go:SetActive(true)
        _typeItem:UpdateItem(k)
        _typeItem:Select(false)
        local _isNew = false
        v:ForeachCanBreak(function(k, v2)
            if not self.NewShopItemList:Contains(v2.SellId) and v2.BuyLv > 0 then
                _isNew = true
                return true
            end
        end)
        _typeItem:SetIsShow(_isNew)
        if _index == 1 and not self.CurSelectType and not _openSelectType then
            self.CurSelectType = _typeItem
        end
        if _openSelectType and _openSelectType == k then
            self.CurSelectType = _typeItem
        end
        _index = _index + 1
    end)
    for j = _index, #self.TypeList do
        self.TypeList[j].Go:SetActive(false)
    end
    if self.CurSelectType then
        self:OnClickType(self.CurSelectType, playAnim)
    end
    self.TypeGrid.repositionNow = true
    self.TypeScroll.repositionWaitFrameCount = 10
end

--Update the selected product display information
function UIShopMallPanel:OnUpdateSelectItemInfo()
    if self.CurSelectGoods == nil then
        return
    end
    local _item = L_ItemBase.CreateItemBase(self.CurSelectGoods.ShopItemInfo.ItemId)
    if _item then
        self.ItemNameStr = _item.Name
        UIUtils.SetTextByString(self.CurGoodsNameLabel, self.ItemNameStr)
        if _item.Type ~= ItemType.Equip and _item.ItemInfo and _item.ItemInfo.Description then
            UIUtils.SetTextByString(self.CurGoodsDescLabel, _item.ItemInfo.Description)
        elseif _item.Type == ItemType.Equip then
            self:SetEquipDes(_item)
        else
            UIUtils.ClearText(self.CurGoodsDescLabel)
        end
        self.GoodsDescScroll:ResetPosition()
    end
    self.CoinType = self.CurSelectGoods.ShopItemInfo.CoinType
    self.CurSetNum = 1
    self.NumInput:SetValueLabel(tostring(self.CurSetNum))
    local _iconID = LuaItemBase.GetItemIcon(self.CoinType)
    self.CostCoinIcon:UpdateIcon(_iconID)
    self.HaveCoinIcon:UpdateIcon(_iconID)
    self:OnUpdateHaveCoin(self.CoinType)
end

function UIShopMallPanel:OnUpdateHaveCoin(obj)
    if obj and self.CoinType and obj == self.CoinType and self.CurSelectGoods then
        local _haveCoinNum = GameCenter.ItemContianerSystem:GetEconomyWithType(self.CoinType)
        local info = self.CurSelectGoods.ShopItemInfo
        local _needNum = (info.Price + info.AddPrice) * self.CurSetNum
        UIUtils.SetTextByNumber(self.HaveCoinNumLabel, _haveCoinNum)
        UIUtils.SetTextByNumber(self.CostCoinNumLabel, _needNum)
        if _haveCoinNum < _needNum then
            UIUtils.SetRed(self.HaveCoinNumLabel)
            self.CoinEough = false
        else
            UIUtils.SetColorByString(self.HaveCoinNumLabel, "#fffef5")
            self.CoinEough = true
        end
    end
end

--Hide all product lists, initialize display
function UIShopMallPanel:HideItemList()
    for i = 1, #self.ShopList do
        self.ShopList[i].Go:SetActive(false)
    end
end

function UIShopMallPanel:SaveShopList()
    local _str = nil
    for i = 1, #self.NewShopItemList do
        if i == 1 then
            _str = tostring(self.NewShopItemList[i])
        else
            _str = _str .. UIUtils.CSFormat("_{0}", self.NewShopItemList[i])
        end
    end
    PlayerPrefs.SetString("ShopMarketList", _str)
end

---Setting equipment description
function UIShopMallPanel:SetEquipDes(equip)
    local _descList = List:New();
    local attDic = equip:GetGodAttribute()
    if attDic.Count > 0 then
        _descList:Add(DataConfig.DataMessageString.Get("C_UI_SHOP_TIPSTITLE_God"))
        local e = attDic:GetEnumerator()
        while e:MoveNext() do
            if #_descList > 0 then
                _descList:Add('\n');
            end
            _descList:Add(UIUtils.CSFormat("{0}  +{1}", L_BattlePropTools.GetBattlePropName(e.Current.Key), L_BattlePropTools.GetBattleValueText(e.Current.Key, e.Current.Value)))
        end
    end
    attDic = equip:GetBaseAttribute()
    if attDic.Count > 0 then
        if #_descList > 0 then
            _descList:Add('\n');
            _descList:Add('\n');
        end
        _descList:Add(DataConfig.DataMessageString.Get("C_UI_SHOP_TIPSTITLE1"))
        local e = attDic:GetEnumerator()
        while e:MoveNext() do
            if #_descList > 0 then
                _descList:Add('\n');
            end
            _descList:Add(UIUtils.CSFormat("{0}  +{1}", L_BattlePropTools.GetBattlePropName(e.Current.Key), L_BattlePropTools.GetBattleValueText(e.Current.Key, e.Current.Value)))
        end
    end
    attDic = equip:GetSpecialAttribute()
    if attDic.Count > 0 then
        _descList:Add('\n');
        _descList:Add('\n');
        _descList:Add(DataConfig.DataMessageString.Get("C_UI_SHOP_TIPSTITLE2"))
        local e = attDic:GetEnumerator()
        while e:MoveNext() do
            if #_descList > 0 then
                _descList:Add('\n');
            end
            _descList:Add(UIUtils.CSFormat("{0}  +{1}", L_BattlePropTools.GetBattlePropName(e.Current.Key), L_BattlePropTools.GetBattleValueText(e.Current.Key, e.Current.Value)))
        end
    end
    UIUtils.SetTextByString(self.CurGoodsDescLabel, table.concat(_descList))
end
return UIShopMallPanel
