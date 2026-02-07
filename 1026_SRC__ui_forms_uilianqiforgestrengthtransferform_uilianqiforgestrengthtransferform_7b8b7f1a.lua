-- author: TL
-- Date: 2025-11-07
-- File: UILianQiForgeStrengthTransferForm.lua
-- Module: UILianQiForgeStrengthTransferForm
-- Description: Handles transferring enhancement levels between equipment of the same group.
------------------------------------------------
local L_LeftItem = require("UI.Forms.UILianQiForgeStrengthTransferForm.UILeftItem")
local L_UIAnimDelayPlayer = require "UI.Components.UIAnimDelayPlayer"

local StonePointKeyInEffectNum = 22
local UILianQiForgeStrengthTransferForm = {
    EquipContainerGo            = nil,
    EquipScrollView             = nil,
    EquipGrid                   = nil, -- Left equipment sliding GRID
    EquipItem                   = nil, -- Left equipment control
    EquipDic                    = Dictionary:New(), -- Left equipment list
    SourceEquipItemUI           = nil, -- UILuaItem(Equipment.cs): để show lên đại diện (Left)
    SourceEquipItemData         = nil, -- UILeftItem: Data item được chọn để chuyển

    BagContainerGo              = nil,
    BagScrollView               = nil,
    BagGrid                     = nil, -- Left equipment sliding GRID
    BagItem                     = nil, -- Left equipment control
    BagDic                      = Dictionary:New(),

    -- Handle select equip target
    Popup_TransferEquipSelectGo = nil,
    TransferEquipScroll         = nil,
    TransferEquipGrid           = nil, -- Grid Popup Select Equip target
    TransferEquipItem           = nil, -- Item Popup Select Equip target
    TargetEquipItemUI           = nil, -- UILuaItem(Equipment.cs): để show lên đại diện (Right)
    TransferEquipList           = List:New(), -- List<UILuaItem(Equipment.cs)>: Equipment có thể chọn (trong túi)
    TargetEquipItemData         = nil, -- UILuaItem(Equipment.cs): Data Equipment được chọn để nhận 

    -- Handle select stone additional
    Popup_TransferStoneSelectGo = nil,
    TransferStoneScroll         = nil,
    TransferStoneGrid           = nil, -- Grid Popup Select Stone target
    TransferStoneItem           = nil, -- Item Popup Select Stone target
    TransferStoneList           = List:New(), -- List<UILuaItem(ItemModel.cs)>: Stone Item có thể chọn (trong túi)
    SelectedStoneDataList       = List:New(), -- List<UILuaItem(ItemModel.cs)> : Data Item Stone được chọn để bổ sung
    SelectedStoneDataDic        = Dictionary:New(), -- Data custom để show lên UI

    ValidStoneIDs               = List:New(), -- List ID đá cường hóa hợp lệ
    RequiredPoint               = 0, -- Số điểm cần đạt cho cấp độ hiện tại
    BaseRetainRate              = 0.9, -- 90% điểm giữ lại mặc định
    CurPercent                  = 0,
    -- 
    CostItem                    = nil,
    CostItemList                = List:New(), -- List Chứa Item Đá (show lên UI)

    CurrencyCostType            = ItemTypeCode.BindMoney, -- ID tiền tệ cần dùng
    CurrencyCostAmount          = 0, -- Số tiền cần phải dùng

    VfxID                       = 612, -- Special effect id (Eff thông báo thành công)
    VfxSkinCompo                = nil, -- Special effects components
    Help                        = nil,
}
------------------------------------------------------------------------------------------------------------------------
--region Setup Form
function UILianQiForgeStrengthTransferForm:OnRegisterEvents()
    self:RegisterEvent(UILuaEventDefine.UILianQiForgeStrengthTransferForm_OPEN, self.OnOpen)
    self:RegisterEvent(UILuaEventDefine.UILianQiForgeStrengthTransferForm_CLOSE, self.OnClose)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_WEAREQUIPSUC, self.RefreshLeftEquipInfos)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_MOVE_EQUIP_STRENGTH_LV, self.MoveEquipStrengthLv)
end

function UILianQiForgeStrengthTransferForm:RegUICallback()
    UIUtils.AddBtnEvent(self.ChangeEquipBtn, self.OnOpenTransferEquipPopup, self)
    UIUtils.AddBtnEvent(self.Popup_TransferEquipBackBg, self.OnCloseTransferEquipPopup, self)
    UIUtils.AddBtnEvent(self.TransferEquipConfirmBtn, self.OnCloseTransferEquipPopup, self)

    UIUtils.AddBtnEvent(self.Popup_TransferStoneBackBg, self.OnCloseSrcTransferStonePopup, self)
    UIUtils.AddBtnEvent(self.TransferStoneConfirmBtn, self.OnCloseSrcTransferStonePopup, self)
    --UIUtils.AddBtnEvent(self.TransferStoneQuickSelectBtn, self.OnCloseSrcTransferEquip, self)
    -- Button Transfer
    UIUtils.AddBtnEvent(self.TransferBtn, self.OnTransferBtn, self)
end

function UILianQiForgeStrengthTransferForm:OnOpen(obj, sender)
    self.CSForm:Show(sender)
end

function UILianQiForgeStrengthTransferForm:OnClose(obj, sender)
    self.CSForm:Hide()
end

function UILianQiForgeStrengthTransferForm:OnFirstShow()
    self:FindAllComponents()
    self:RegUICallback()

    self.EquipRightTrans = UIUtils.FindTrans(self.Trans, "Right/Right")
    self.CSForm:AddAlphaPosAnimation(self.EquipRightTrans, 0, 1, 0, 50, 0.3, false, false)
    self.EquipButtomTrans = UIUtils.FindTrans(self.Trans, "Right/Buttom")
    self.CSForm:AddAlphaPosAnimation(self.EquipButtomTrans, 0, 1, 0, -50, 0.3, false, false)
    self.AnimPlayer = L_UIAnimDelayPlayer:New(self.CSForm.AnimModule)
end

function UILianQiForgeStrengthTransferForm:OnShowBefore()
end

function UILianQiForgeStrengthTransferForm:OnShowAfter()
    --- Init Data
    if not self.SourceEquipItemUI then
        self.SourceEquipItemUI = UILuaItem:New(self.EquipItemTrans)
        self.SourceEquipItemUI.IsShowAddSpr = true
        self.SourceEquipItemUI.IsShowTips = false -- handle Show Tip in SourceEquipItemUIOnClick()
        self.SourceEquipItemUI.SingleClick = Utils.Handler(self.OnSourceEquipItemUIClick, self)
        self.SourceEquipItemUI:InitWithItemData(nil, 0)
    end
    if not self.TargetEquipItemUI then
        self.TargetEquipItemUI = UILuaItem:New(self.EquipItemTargetTrans)
        self.TargetEquipItemUI.IsShowAddSpr = true
        self.TargetEquipItemUI.IsShowTips = false -- handle Show Tip in TargetEquipItemUIOnClick()
        self.TargetEquipItemUI.SingleClick = Utils.Handler(self.OnTargetEquipItemUIClick, self)
        self.TargetEquipItemUI:InitWithItemData(nil, 0)
    end

    self.SourceEquipItemData = nil
    self.TargetEquipItemData = nil
    self.SelectedStoneDataList = List:New()
    self.SelectedStoneDataDic = Dictionary:New()
    self.ValidStoneIDs = List:New()
    -------------------------------------------
    self:OnInitLeftEquipList(true)
    self.Popup_TransferEquipSelectGo:SetActive(false)
    self.Popup_TransferStoneSelectGo:SetActive(false)

    self.CSForm:LoadTexture(self.BgTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_z_53"))
    self.CSForm:LoadTexture(self.BgTextureNext, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_z_53"))
    self.CSForm:LoadTexture(self.AttrBgTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_30_2"))
    self.CSForm:LoadTexture(self.Popup_TransferEquipTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_3"))
    self.CSForm:LoadTexture(self.Popup_TransferStoneTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_3"))
end

function UILianQiForgeStrengthTransferForm:OnHideBefore()
    --- Clear Data
    self.SourceEquipItemUI = nil
    self.TargetEquipItemUI = nil

    self.SourceEquipItemData = nil
    self.TargetEquipItemData = nil
    self.SelectedStoneDataList = nil
    self.SelectedStoneDataDic = nil
    self.ValidStoneIDs = nil
    -------------------------------------------
    self:DestroyAllVfx()
end

function UILianQiForgeStrengthTransferForm:Update(dt)
    self.AnimPlayer:Update(dt)
end

function UILianQiForgeStrengthTransferForm:DestroyAllVfx()
    self.VfxSkinCompo:OnDestory()
end

function UILianQiForgeStrengthTransferForm:FindAllComponents()
    local _myTrans = self.Trans
    -----------------------------------
    self.TabEquippedBtn = UIUtils.FindBtn(_myTrans, "UIListMenu/Table/DressBag")
    self.Tab_BackpackBtn = UIUtils.FindBtn(_myTrans, "UIListMenu/Table/Bag")
    self.Tab_BackpackBtn.gameObject:SetActive(false)

    ---------------------------------- Phần trang bị trên người
    self.EquipContainerGo = UIUtils.FindGo(_myTrans, "Left/EquipRoot")
    self.EquipScrollView = UIUtils.FindScrollView(_myTrans, "Left/EquipRoot")
    self.EquipGrid = UIUtils.FindGrid(_myTrans, "Left/EquipRoot/Grid")
    local _gridEquipTrans = UIUtils.FindTrans(_myTrans, "Left/EquipRoot/Grid")
    for i = 0, _gridEquipTrans.childCount - 1 do
        self.EquipItem = L_LeftItem:OnFirstShow(_gridEquipTrans:GetChild(i))
        self.EquipItem.CallBack = Utils.Handler(self.LeftEquipItemOnClick, self)
        self.EquipDic:Add(i, self.EquipItem)
    end

    ---------------------------------- Phần trang bị trong túi
    self.BagContainerGo = UIUtils.FindGo(_myTrans, "Left/BagContainer")
    self.BagScrollView = UIUtils.FindScrollView(_myTrans, "Left/BagContainer")
    self.BagGrid = UIUtils.FindGrid(_myTrans, "Left/BagContainer/Grid")
    local _gridBagTrans = UIUtils.FindTrans(_myTrans, "Left/BagContainer/Grid")
    --for i = 0, _gridBagTrans.childCount - 1 do
    --      UILuaItem:New(UIUtils.FindTrans(_myTrans, path))
    --    self.BagItem = L_LeftItem:OnFirstShow(_gridBagTrans:GetChild(i))
    --    self.BagItem.CallBack = Utils.Handler(self.LeftBagItemOnClick, self)
    --    self.BagDic:Add(i, self.BagItem)
    --end
    self.BagContainerGo:SetActive(false)

    ---------------------------------- Phần thông tin chính
    local _topTrans = UIUtils.FindTrans(_myTrans, "Right/Right")
    self.EmptyAttrGo = UIUtils.FindGo(_topTrans, "NoAttr")
    self.AttributeGo = UIUtils.FindGo(_topTrans, "Attribute")
    self.AttrBgTexture = UIUtils.FindTex(_topTrans, "AttrBg")

    self.OldLevel = UIUtils.FindLabel(_topTrans, "Attribute/Old/Level")
    self.OldAttrGo_1 = UIUtils.FindGo(_topTrans, "Attribute/Old/Attr1")
    self.OldAttrValue_1 = UIUtils.FindLabel(_topTrans, "Attribute/Old/Attr1")
    self.OldAttrName_1 = UIUtils.FindLabel(_topTrans, "Attribute/Old/Attr1/Txt")
    self.OldAttrGo_2 = UIUtils.FindGo(_topTrans, "Attribute/Old/Attr2")
    self.OldAttrValue_2 = UIUtils.FindLabel(_topTrans, "Attribute/Old/Attr2")
    self.OldAttrName_2 = UIUtils.FindLabel(_topTrans, "Attribute/Old/Attr2/Txt")
    self.OldAttrGo_3 = UIUtils.FindGo(_topTrans, "Attribute/Old/Attr3")
    self.OldAttrValue_3 = UIUtils.FindLabel(_topTrans, "Attribute/Old/Attr3")
    self.OldAttrName_3 = UIUtils.FindLabel(_topTrans, "Attribute/Old/Attr3/Txt")

    self.NewLevel = UIUtils.FindLabel(_topTrans, "Attribute/New/Level")
    self.NewAttrGo_1 = UIUtils.FindGo(_topTrans, "Attribute/New/Attr1")
    self.NewAttrValue_1 = UIUtils.FindLabel(_topTrans, "Attribute/New/Attr1")
    self.NewAttrName_1 = UIUtils.FindLabel(_topTrans, "Attribute/New/Attr1/Txt")
    self.NewAttrGo_2 = UIUtils.FindGo(_topTrans, "Attribute/New/Attr2")
    self.NewAttrValue_2 = UIUtils.FindLabel(_topTrans, "Attribute/New/Attr2")
    self.NewAttrName_2 = UIUtils.FindLabel(_topTrans, "Attribute/New/Attr2/Txt")
    self.NewAttrGo_3 = UIUtils.FindGo(_topTrans, "Attribute/New/Attr3")
    self.NewAttrValue_3 = UIUtils.FindLabel(_topTrans, "Attribute/New/Attr3")
    self.NewAttrName_3 = UIUtils.FindLabel(_topTrans, "Attribute/New/Attr3/Txt")

    -- Trang bị gốc
    self.EquipItemTrans = UIUtils.FindTrans(_topTrans, "UIEquipmentItem")
    self.BgTexture = UIUtils.FindTex(_topTrans, "UIEquipmentItem/BgTexture")

    -- Trang bị đích
    self.EquipItemTargetTrans = UIUtils.FindTrans(_topTrans, "UIEquipmentItemNext")
    self.BgTextureNext = UIUtils.FindTex(_topTrans, "UIEquipmentItemNext/BgTexture")
    self.ChangeEquipBtn = UIUtils.FindBtn(_topTrans, "ChangeEquipBtn")

    local _botTrans = UIUtils.FindTrans(_myTrans, "Right/Buttom")
    self.ItemCostTrs = UIUtils.FindTrans(_botTrans, "ItemGrid")
    self.ItemCostGrid = UIUtils.FindGrid(_botTrans, "ItemGrid")
    for i = 0, self.ItemCostTrs.childCount - 1 do
        self.CostItem = UILuaItem:New(self.ItemCostTrs:GetChild(i))
        self.CostItem.IsShowTips = false
        self.CostItem.IsShowAddSpr = true
        self.CostItem.SingleClick = Utils.Handler(self.OnItemCostSelect, self)
        self.CostItem:SelectItem(false)
        self.CostItem:OnLock(false)
        self.CostItem:InitWithItemData(nil, 0)
        self.CostItemList:Add(self.CostItem)
    end
    self.CheckBoxTrans = UIUtils.FindTrans(_botTrans, "CheckBoxTrans")
    self.CheckBoxTrans.gameObject:SetActive(false)

    self.PerLabel = UIUtils.FindLabel(_botTrans, "NeckEquip/Per")
    self.CoinLabel = UIUtils.FindLabel(_botTrans, "NeckEquip/Coin/Num")
    local _iconCoin = UIUtils.FindTrans(_botTrans, "NeckEquip/Coin/CoinIcon")
    self.CoinIcon = UIUtils.RequireUIIconBase(_iconCoin)
    --self.CoinIcon:UpdateIcon(LuaItemBase.GetItemIcon(ItemTypeCode.Lingshi))

    self.TransferBtn = UIUtils.FindBtn(_botTrans, "TransferBtn")
    self.FastTransferBtn = UIUtils.FindBtn(_botTrans, "FastBtn")
    self.FastTransferBtn.gameObject:SetActive(false) -- TODO(TL): need handle onBtnClick

    ---------------------------------- Popup chọn trang bị đích (trang bị được chuyển)
    local _transferEquipSelectTrans = UIUtils.FindTrans(_myTrans, "Popup_TransferEquipSelect")
    self.Popup_TransferEquipSelectGo = _transferEquipSelectTrans.gameObject
    self.CSForm:AddTransNormalAnimation(_transferEquipSelectTrans, 50, 0.3)

    self.Popup_TransferEquipTex = UIUtils.FindTex(_transferEquipSelectTrans, "BgBagPanel")
    self.Popup_TransferEquipBackBg = UIUtils.FindBtn(_transferEquipSelectTrans, "BgCollider")
    self.TransferEquipScroll = UIUtils.FindScrollView(_transferEquipSelectTrans, "BagContainer")
    self.TransferEquipGrid = UIUtils.FindGrid(_transferEquipSelectTrans, "BagContainer/Grid")
    self.TransferEquipGridGo = UIUtils.FindGo(_transferEquipSelectTrans, "BagContainer/Grid")
    local _selectEquipmentGrid = UIUtils.FindTrans(_transferEquipSelectTrans, "BagContainer/Grid")
    for i = 0, _selectEquipmentGrid.childCount - 1 do
        self.TransferEquipItem = UILuaItem:New(_selectEquipmentGrid:GetChild(i))
        self.TransferEquipItem.IsShowTips = false
        self.TransferEquipItem.SingleClick = Utils.Handler(self.OnEquipTargetSelect, self)
        self.TransferEquipList:Add(self.TransferEquipItem)
    end
    self.TransferEquipTipsLabel = UIUtils.FindLabel(_transferEquipSelectTrans, "TipsLabel")
    self.TransferEquipConfirmBtn = UIUtils.FindBtn(_transferEquipSelectTrans, "Putin")

    ---------------------------------- Popup chọn đá cường hóa
    local _transferStoneSelectTrans = UIUtils.FindTrans(_myTrans, "Popup_TransferStoneSelect")
    self.Popup_TransferStoneSelectGo = _transferStoneSelectTrans.gameObject
    self.CSForm:AddTransNormalAnimation(_transferStoneSelectTrans, 50, 0.3)

    self.Popup_TransferStoneTex = UIUtils.FindTex(_transferStoneSelectTrans, "BgBagPanel")
    self.Popup_TransferStoneBackBg = UIUtils.FindBtn(_transferStoneSelectTrans, "BgCollider")
    self.TransferStoneScroll = UIUtils.FindScrollView(_transferStoneSelectTrans, "BagContainer")
    self.TransferStoneGrid = UIUtils.FindGrid(_transferStoneSelectTrans, "BagContainer/Grid")
    self.TransferStoneGridGo = UIUtils.FindGo(_transferStoneSelectTrans, "BagContainer/Grid")
    local _selectStoneGrid = UIUtils.FindTrans(_transferStoneSelectTrans, "BagContainer/Grid")
    for i = 0, _selectStoneGrid.childCount - 1 do
        self.TransferStoneItem = UILuaItem:New(_selectStoneGrid:GetChild(i))
        self.TransferStoneItem.IsShowTips = false
        self.TransferStoneItem.SingleClick = Utils.Handler(self.OnStoneTargetSelect, self)
        self.TransferStoneList:Add(self.TransferStoneItem)
    end

    self.TransferStoneTipsLabel = UIUtils.FindLabel(_transferStoneSelectTrans, "TipsLabel")
    self.TransferStoneRateLabel = UIUtils.FindLabel(_transferStoneSelectTrans, "Label")
    self.TransferStonePerLabel = UIUtils.FindLabel(_transferStoneSelectTrans, "PerLabel")
    self.TransferStoneOverLabel = UIUtils.FindLabel(_transferStoneSelectTrans, "OverLabel")

    self.TransferStoneConfirmBtn = UIUtils.FindBtn(_transferStoneSelectTrans, "Putin")
    self.TransferStoneQuickSelectBtn = UIUtils.FindBtn(_transferStoneSelectTrans, "GetEquipBtn")
    self.TransferStoneQuickSelectBtn.gameObject:SetActive(false) -- TODO(TL): need handle onBtnClick

    ---------------------------------- Popup confirm
    self.Popup_ConfirmGo = UIUtils.FindGo(_myTrans, "Popup_Confirm")
    self.Popup_ConfirmGo:SetActive(false)
    ----------------------------------
    local _vfxTrs = UIUtils.FindTrans(_myTrans, "UIVfxSkinCompoent")
    self.VfxSkinCompo = UIUtils.RequireUIVfxSkinCompoent(_vfxTrs)
    self.Help = UIUtils.FindBtn(_myTrans, "Right/Help")
    UIUtils.AddBtnEvent(self.Help, self.OnClickBtnHelp, self)
end

function UILianQiForgeStrengthTransferForm:OnClickBtnHelp()
    GameCenter.PushFixEvent(UIEventDefine.UI_HELP_FORM_OPEN, UnityUtils.GetObjct2Int(FunctionStartIdCode.LianQiForgeStrengthTransfer))
end
--endregion
------------------------------------------------------------------------------------------------------------------------
--region Setup panel
function UILianQiForgeStrengthTransferForm:RefreshLeftEquipInfos(playAnim, sender)
    self:OnInitLeftEquipList(playAnim)
end

function UILianQiForgeStrengthTransferForm:OnInitLeftEquipList(playAnim)
    local _animList = nil
    local _forgeSystem = GameCenter.LianQiForgeSystem
    if playAnim then
        _animList = List:New()
        self.AnimPlayer:Stop()
    end

    local _firstSelectableItem = nil
    for i = 0, EquipmentType.Count - 1 do
        local _item = nil
        local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(i)
        local hasEquip = (_equip ~= nil)
        local isBasicSlot = (i <= EquipmentType.FingerRing)

        if isBasicSlot or hasEquip then
            if self.EquipDic:ContainsKey(i) then
                _item = self.EquipDic[i]
            else
                _item = self.EquipItem:Clone()
                _item.CallBack = Utils.Handler(self.LeftEquipItemOnClick, self)
                self.EquipDic:Add(i, _item)
            end
        end

        if _item then
            _item:SetInfo(i, _equip, { level = _forgeSystem:GetStrengthLvByPos(i) })
            _item:OnSetSelect(false)
            if playAnim then
                _animList:Add(_item.Trans)
            end

            -- LẤY ITEM CÓ THỂ SELECT ĐẦU TIÊN
            if not _firstSelectableItem and _equip then
                _firstSelectableItem = _item
            end
        end
    end

    if _firstSelectableItem then
        self.EmptyAttrGo:SetActive(false)
        self.AttributeGo:SetActive(true)
        self:LeftEquipItemOnClick(_firstSelectableItem, true)
    else
        self.EmptyAttrGo:SetActive(true)
        self.AttributeGo:SetActive(false)
    end

    if playAnim then
        self.EquipGrid:Reposition()
        self.EquipScrollView:ResetPosition()

        for i = 1, #_animList do
            self.CSForm:RemoveTransAnimation(_animList[i])
            self.CSForm:AddAlphaPosAnimation(_animList[i], 0, 1, 0, 30, 0.2, false, false)
            self.AnimPlayer:AddTrans(_animList[i], (i - 1) * 0.05)
        end
        self.AnimPlayer:AddTrans(self.EquipRightTrans, 0)
        self.AnimPlayer:AddTrans(self.EquipButtomTrans, 0.2)
        self.AnimPlayer:Play()
    end
end

function UILianQiForgeStrengthTransferForm:LeftBagItemOnClick(item, isClear)
    Debug.Log("[LDebug] LeftBagItemOnClick")
end

function UILianQiForgeStrengthTransferForm:LeftEquipItemOnClick(item, isRefresh)
    local _pos = item.Pos
    if not _pos then return end

    local _equip = item.ItemData
    if not _equip then
        Utils.ShowPromptByEnum("LIANQI_FORGE_STRENGTHNEEDEQUIP")
        return
    end

    -- Prevent redundant UI updates if clicking the same item again
    if (self.SourceEquipItemData == item) and (not isRefresh) then
        return
    end
    -----
    -- Deselect the previous selected item (if any)
    if self.SourceEquipItemData ~= item and self.SourceEquipItemData ~= nil then
        self.SourceEquipItemData:OnSetSelect(false)
    end
    Debug.Log("LeftEquipItemOnClick")
    -- Select the new item
    item:OnSetSelect(true)
    self.SourceEquipItemData = item

    -- Update UI Item details on the right panel
    self:SetRightSourceEquipInfos()
    -- Update UI details on the right panel
    self:SetRightTargetEquipInfos()

    -- Clear data
    self.TargetEquipItemData = nil
    self.ValidStoneIDs = List:New()
    self.SelectedStoneDataList = List:New()
    self.SelectedStoneDataDic = Dictionary:New()
    --UIUtils.SetTextByEnum(self.PerLabel, "Percent", 0)
    self:RefreshCostListItemUI()
    self:RefreshEnhancePercentUI()
    self:RefreshEnhanceCurrencyCostUI()
    -----
    self:HandleActiveButton()
end

function UILianQiForgeStrengthTransferForm:OnItemCostSelect()
    self:OnOpenTransferStonePopup()
end
--endregion
------------------------------------------------------------------------------------------------------------------------
--region Popup TransferEquip
function UILianQiForgeStrengthTransferForm:OnCloseTransferEquipPopup()
    self.CSForm:PlayHideAnimation(self.Popup_TransferEquipSelectGo.transform)
end

function UILianQiForgeStrengthTransferForm:OnOpenTransferEquipPopup()
    if not self.SourceEquipItemData then return end

    local _allEquip = GameCenter.EquipmentSystem:GetAllEquipByBag()
    --if not _allEquip or _allEquip.Count == 0 then
    --    Utils.ShowPromptByEnum("Canot_Arrived_Pos")
    --    return
    --end

    --Show grid and reset scroll
    self.TransferEquipGridGo:SetActive(true)
    self.CSForm:PlayShowAnimation(self.Popup_TransferEquipSelectGo.transform)
    self.TransferEquipScroll:ResetPosition()

    --Filter
    local _filteredEquip = self:FilterEquipmentByGroup(_allEquip, self.SourceEquipItemData.ItemData)

    --Calculate the maximum number of items visible based on panel height
    local maxPerLine = self.TransferEquipGrid.maxPerLine
    local maxVisible = math.ceil(self.TransferEquipScroll.panel.height / self.TransferEquipGrid.cellHeight) * maxPerLine
    local fillCount = math.max(maxVisible, _filteredEquip:Count(), self.TransferEquipList:Count())

    --Ensure grid has enough capacity (clone items per full line)
    --[[for i = 1, fillCount do
        if #self.TransferEquipList < i then
            -- Add one full row when list is not enough
            local start = i % maxPerLine
            for _ = start, maxPerLine do
                local item = self.TransferEquipItem:Clone()
                item.SingleClick = Utils.Handler(self.OnEquipTargetSelect, self)
                item.IsShowTips = false
                self.TransferEquipList:Add(item)
            end
        end
    end]]
    self:EnsureGridCapacity(
            self.TransferEquipItem,
            self.TransferEquipList,
            fillCount, maxPerLine,
            self.OnEquipTargetSelect
    )

    local _forgeBagSystem = GameCenter.LianQiForgeBagSystem
    --Fill data into each grid cell
    for i = 1, fillCount do
        local _itemInfo = _filteredEquip[i]
        local _strengthLv = _itemInfo and _forgeBagSystem:GetStrengthLvByItemId(_itemInfo.DBID) or 0

        local item = self.TransferEquipList[i]
        self:OnFillCell(item, _itemInfo, 1, self.TargetEquipItemData, _strengthLv ~= 0)
    end
    --Clear extra cells if any
    for i = fillCount + 1, #self.TransferEquipList do
        local item = self.TransferEquipList[i]
        self:OnFillCell(item, nil)
    end
    --Mark grid to reposition
    self.TransferEquipGrid.repositionNow = true
end

function UILianQiForgeStrengthTransferForm:FilterEquipmentByGroup(_allEquip, itemData)
    local itemId = itemData.DBID
    local itemPart = itemData:GetPart()
    local targetGroup = Utils.GetEquipmentGroupByPart(itemPart)

    local filtered = List:New()
    local groupParts = EquipmentGroup[targetGroup]
    if not groupParts then
        return filtered
    end

    for i = 0, _allEquip.Count - 1 do
        local equip = _allEquip[i]
        for _, part in ipairs(groupParts) do
            if itemId ~= equip.DBID and part == equip.Part then
                filtered:Add(equip)
                break
            end
        end
    end
    return filtered
end

function UILianQiForgeStrengthTransferForm:OnEquipTargetSelect(item)
    if not item.ShowItemData then return end
    if self.TargetEquipItemData == item then
        self.TargetEquipItemData = nil
        item:SelectItem(false)
    else
        if self.TargetEquipItemData then
            self.TargetEquipItemData:SelectItem(false)
        end
        self.TargetEquipItemData = item
        item:SelectItem(true)
    end

    self:SetRightTargetEquipInfos()
    self:RefreshEnhancePercentUI()

    self:HandleActiveButton()
end
--endregion
------------------------------------------------------------------------------------------------------------------------
--region Popup TransferStone
function UILianQiForgeStrengthTransferForm:OnCloseSrcTransferStonePopup()
    self.CSForm:PlayHideAnimation(self.Popup_TransferStoneSelectGo.transform)
end

function UILianQiForgeStrengthTransferForm:OnOpenTransferStonePopup()
    if not self.SourceEquipItemData then return end

    self:LoadEnhanceConsumeConfig()
    local _allStone = GameCenter.ItemContianerSystem:GetItemListByCfgidList(self.ValidStoneIDs)
    if not _allStone or _allStone.Count == 0 then
        Utils.ShowPromptByEnum("MaterialNotEnough")  -- TODO(TL) handle String Enum
        return
    end

    ----Show grid and reset scroll
    self.TransferStoneGridGo:SetActive(true)
    self.CSForm:PlayShowAnimation(self.Popup_TransferStoneSelectGo.transform)
    self.TransferStoneScroll:ResetPosition()

    local _filteredStone = self:FilterStone(_allStone)
    --Calculate the maximum number of items visible based on panel height
    local maxPerLine = self.TransferStoneGrid.maxPerLine
    local maxVisible = math.ceil(self.TransferStoneScroll.panel.height / self.TransferStoneGrid.cellHeight) * maxPerLine
    local fillCount = math.max(maxVisible, _filteredStone:Count(), self.TransferEquipList:Count())

    --Ensure grid has enough capacity (clone items per full line)
    self:EnsureGridCapacity(
            self.TransferStoneItem,
            self.TransferStoneList,
            fillCount, maxPerLine,
            self.OnStoneTargetSelect
    )
    --Fill data into each grid cell
    for i = 1, fillCount do
        local _itemInfo = _filteredStone[i]

        local item = self.TransferStoneList[i]
        self:OnFillCell(item, _itemInfo, 1, self.SelectedStoneDataList)
    end
    --Clear extra cells if any
    for i = fillCount + 1, #self.TransferStoneList do
        local item = self.TransferStoneList[i]
        self:OnFillCell(item, nil)
    end
    --Mark grid to reposition
    self.TransferStoneGrid.repositionNow = true
end

function UILianQiForgeStrengthTransferForm:FilterStone(_allStone)
    local filtered = List:New()
    for i = 0, _allStone.Count - 1 do
        local stone = _allStone[i]
        filtered:Add(stone)
    end
    return filtered
end

function UILianQiForgeStrengthTransferForm:OnStoneTargetSelect(item)
    if not item.ShowItemData then return end
    if self.SelectedStoneDataList:Contains(item) then
        self.SelectedStoneDataList:Remove(item)
        item:SelectItem(false)
    else
        self.SelectedStoneDataList:Add(item)
        item:SelectItem(true)
    end

    self:RefreshEnhancePercentUI()
    self:RefreshCostListItemUI()

    self:HandleActiveButton()
end
--endregion
------------------------------------------------------------------------------------------------------------------------

--- Ensures the equipment grid has enough item slots to display all required items.
--- This function fills incomplete rows first, then adds full new rows if needed.
---@param itemPrefab table(UILuaItem) The prefab used to clone new item UI elements.
---@param itemList table(List) The list storing all cloned item UI elements.
---@param requiredCount number The total number of items that should be visible.
---@param maxPerLine number The maximum number of items per grid line.
---@param onItemClickFunc function The click handler for each item.
function UILianQiForgeStrengthTransferForm:EnsureGridCapacity(itemPrefab, itemList, requiredCount, maxPerLine, onItemClickFunc)
    local currentCount = #itemList
    local needCount = requiredCount - currentCount
    if needCount <= 0 then return end

    -- Fill the remaining slots of the current incomplete line (if any)
    local remainder = currentCount % maxPerLine
    if remainder ~= 0 then
        local slotsToFill = maxPerLine - remainder -- math.min(maxPerLine - remainder, needCount)
        for _ = 1, slotsToFill do
            local _newItem = itemPrefab:Clone()
            _newItem.IsShowTips = false
            _newItem.SingleClick = Utils.Handler(onItemClickFunc, self)
            itemList:Add(_newItem)
        end
        needCount = needCount - slotsToFill
    end

    -- Add complete new lines until reaching the required count
    if needCount > 0 then
        local linesToAdd = math.ceil(needCount / maxPerLine)
        for _ = 1, linesToAdd * maxPerLine do
            local _newItem = itemPrefab:Clone()
            _newItem.IsShowTips = false
            _newItem.SingleClick = Utils.Handler(onItemClickFunc, self)
            itemList:Add(_newItem)
        end
    end
end

--- Common FillCell function
---@param itemCell table(UILuaItem)
---@param itemInfo userdata(Equipment.cs)
---@param num number
---@param selectionSource userdata(Equipment.cs)
function UILianQiForgeStrengthTransferForm:OnFillCell(itemCell, itemInfo, num, selectionSource, isLock)
    --OnFillCellSingle(...)
    --OnFillCellMulti(...)
    itemCell:OnLock(isLock == true)
    itemCell:SetIsGray(isLock == true)
    itemCell:InitWithItemData(itemInfo, num)

    local isSelected = false
    if itemInfo and selectionSource then
        if type(selectionSource) == "table" and selectionSource.Contains then
            -- Case: selectionSource is a list (e.g., SelectedStoneDataList)
            isSelected = selectionSource:Contains(itemCell)
        elseif type(selectionSource) == "table" and selectionSource.ContainsKey then
            -- Case: selectionSource is a Dic (e.g., SelectedStoneDataDic)
            isSelected = selectionSource:ContainsKey(itemCell)
        else
            -- Case: selectionSource is a single item (e.g., TargetEquipItemData)
            isSelected = selectionSource == itemCell
        end
    end
    itemCell:SelectItem(isSelected)
end

--- Calculate total enhancement point and percent based on the selected item list
--- @param itemList table The current selected item list
--- @return table { BasePoint, AddedPoint, TotalPoint, OverPoint, MissingPoint, Percent, OverPer }
function UILianQiForgeStrengthTransferForm:CalcEnhancePercentByList(itemList)
    -- Build a temporary dictionary from the item list
    local itemDic = self:BuildItemEffectDic(itemList)
    self.SelectedStoneDataDic = itemDic

    -- Sum up total points from all items
    local totalPoint = 0
    for _, data in pairs(itemDic) do
        totalPoint = totalPoint + (data.TotalPoint or 0)
    end
    -- Calculate overall points and percent
    local basePoint = self.RequiredPoint * self.BaseRetainRate
    local combinedPoint = basePoint + totalPoint

    -- Calculate enhancement progress
    local overPoint = math.max(combinedPoint - self.RequiredPoint, 0)
    local missingPoint = math.max(self.RequiredPoint - combinedPoint, 0)
    -- Calculate percent
    local percent = 0
    if (self.RequiredPoint and self.RequiredPoint > 0) then
        percent = math.min(combinedPoint / self.RequiredPoint, 1) -- Check lỗi chia cho 0 
    end
    -- Calculate over percent (portion beyond 100%)
    local overPer = 0
    if (self.RequiredPoint and self.RequiredPoint > 0) and (combinedPoint > self.RequiredPoint) then
        overPer = overPoint / self.RequiredPoint -- Check lỗi chia cho 0 
    end

    -- Return a structured result
    return {
        BasePoint    = basePoint,
        AddedPoint   = totalPoint,
        TotalPoint   = combinedPoint,
        OverPoint    = overPoint,
        MissingPoint = missingPoint,
        Percent      = percent,
        OverPer      = overPer,
    }
end

--- Build a dictionary from item list with count and total point
--- @param itemList table List of items { ShowItemData = { ItemData = { Id, EffectNum } } }
--- @return table Dictionary { [id] = { Count = number, TotalPoint = number, ItemData = item } }
function UILianQiForgeStrengthTransferForm:BuildItemEffectDic(itemList)
    local resultDic = Dictionary:New()
    if not itemList then return resultDic end

    for _, entry in ipairs(itemList) do
        local showItem = entry.ShowItemData
        local info = showItem and showItem.ItemInfo

        if info and info.Id and info.EffectNum then
            local itemId = info.Id
            local itemPoint = 0

            -- Parse EffectNum safely
            local _arrNumber = Utils.SplitNumber(info.EffectNum, '_')
            if _arrNumber[1] == StonePointKeyInEffectNum and _arrNumber[2] then
                itemPoint = _arrNumber[2] or 0
            end

            -- Update dictionary
            if resultDic:ContainsKey(itemId) then
                local data = resultDic[itemId]
                data.Count = data.Count + 1
                data.TotalPoint = data.TotalPoint + itemPoint
            else
                resultDic:Add(itemId, { Count = 1, TotalPoint = itemPoint, ItemData = showItem })
            end
        end
    end
    return resultDic
end

------------------------------------------------------------------------------------------------------------------------
-- Note: cần calc SelectedStoneDataList trước 
function UILianQiForgeStrengthTransferForm:RefreshEnhancePercentUI()
    local info = self:CalcEnhancePercentByList(self.SelectedStoneDataList)

    -- làm tròn 2 chữ số
    local percent = math.floor(info.Percent * 10000 + 0.5) / 100
    local overPer = math.floor(info.OverPer * 10000 + 0.5) / 100

    self.CurPercent = percent or 0
    UIUtils.SetTextByEnum(self.PerLabel, "Percent", percent)
    UIUtils.SetTextByEnum(self.TransferStonePerLabel, "Percent", percent)
    UIUtils.SetTextByEnum(self.TransferStoneOverLabel, "C_EQUIPSYN_PEROVER_TIPS", overPer)
end

function UILianQiForgeStrengthTransferForm:RefreshEnhanceCurrencyCostUI()
    if not self.SourceEquipItemData then return end

    local _forgeSystem = GameCenter.LianQiForgeSystem
    local part = self.SourceEquipItemData.ItemData.Part
    local strengthLevel = _forgeSystem:GetStrengthLvByPos(part)

    local _refundLevel = strengthLevel > 0 and (strengthLevel - 1) or 0
    local cfgID = _forgeSystem:GetCfgID(part, _refundLevel)
    local cfg = DataConfig.DataEquipIntenMain[cfgID]
    if cfg and cfg.ConsumeCoin then
        local coinCfgParts = Utils.SplitNumber(cfg.ConsumeCoin, '_')
        local coinType = coinCfgParts[1]
        local baseCoinCost = coinCfgParts[2]

        -- Calculate refund-adjusted coin cost
        local refundCoinCost = baseCoinCost * (1 - self.BaseRetainRate)
        
        self.CurrencyCostType = coinType
        self.CurrencyCostAmount = refundCoinCost
        -- ownedCoin
        local haveCoin = GameCenter.ItemContianerSystem:GetEconomyWithType(self.CurrencyCostType)

        self.CoinIcon:UpdateIcon(self.CurrencyCostType)
        UIUtils.SetTextByNumber(self.CoinLabel, self.CurrencyCostAmount)
        if haveCoin >= self.CurrencyCostAmount then
            UIUtils.SetColorByString(self.CoinLabel, "#FFFEF5") -- Trắng
        else
            UIUtils.SetColorByString(self.CoinLabel, "#F11F1F") -- Đỏ
        end
    end
end

function UILianQiForgeStrengthTransferForm:RefreshCostListItemUI()
    local _index = 1
    local totalCount = self.SelectedStoneDataDic and self.SelectedStoneDataDic:Count() or 0
    if totalCount > 0 then
        self.SelectedStoneDataDic:Foreach(function(itemId, data)
            if self.CostItemList[_index] then
                self.CostItemList[_index]:InItWithCfgid(itemId, data.Count)
            end
            _index = _index + 1
        end)
    end

    for i = _index, #self.CostItemList do
        self.CostItemList[i]:InItWithCfgid(0, 0)
    end
end

function UILianQiForgeStrengthTransferForm:LoadEnhanceConsumeConfig()
    if not self.SourceEquipItemData then return end

    local _forgeSystem = GameCenter.LianQiForgeSystem
    local part = self.SourceEquipItemData.ItemData.Part
    local strengthLevel = _forgeSystem:GetStrengthLvByPos(part)

    local _refundLevel = strengthLevel > 0 and (strengthLevel - 1) or 0
    local cfgID = _forgeSystem:GetCfgID(part, _refundLevel)
    local cfg = DataConfig.DataEquipIntenMain[cfgID]
    if not (cfg and cfg.Consume) then
        return
    end

    self.ValidStoneIDs:Clear()
    self.RequiredPoint = 0

    local consumeGroups = Utils.SplitStr(cfg.Consume, ';') -- 60002_60020_60021_180000
    for _, consumeStr in ipairs(consumeGroups) do
        local parts = Utils.SplitNumber(consumeStr, '_')

        local lastIndex = #parts
        self.RequiredPoint = parts[lastIndex] or 0
        for i = 1, lastIndex - 1 do
            self.ValidStoneIDs:Add(parts[i])
        end
    end
end

function UILianQiForgeStrengthTransferForm:OnSourceEquipItemUIClick(go)
    local _equipItem = go
    if _equipItem.ShowItemData ~= nil then
        GameCenter.ItemTipsMgr:ShowTips(_equipItem.ShowItemData, go.RootGO, ItemTipsLocation.EquipDisplay)
    end
end

function UILianQiForgeStrengthTransferForm:OnTargetEquipItemUIClick(go)
    local _equipItem = go
    if _equipItem.ShowItemData ~= nil then
        GameCenter.ItemTipsMgr:ShowTips(_equipItem.ShowItemData, go.RootGO, ItemTipsLocation.EquipDisplay)
    else
        self:OnOpenTransferEquipPopup()
    end
end

function UILianQiForgeStrengthTransferForm:SetRightSourceEquipInfos()
    -- Note: self.SourceEquipItemData <UILeftItem.lua>
    local _pos = self.SourceEquipItemData and self.SourceEquipItemData.Pos
    local _sourceItemData = nil
    if self.SourceEquipItemData and self.SourceEquipItemData.ItemData then
        _sourceItemData = self.SourceEquipItemData.ItemData
    elseif _pos then
        _sourceItemData = GameCenter.EquipmentSystem:GetPlayerDressEquip(_pos) or nil
    end
    if not _sourceItemData then
        if self.SourceEquipItemUI.ShowItemData ~= nil then
            self.TargetEquipItemUI.IsShowAddSpr = true
            self.SourceEquipItemUI:InitWithItemData(nil, 0)
        end
        --UIUtils.SetTextByEnum(self.PerLabel, "Percent", 0)
        UIUtils.SetTextFormat(self.OldLevel, "{0}", 0)
        GameCenter.LianQiForgeSystem:SetLabelColorByStrengthLevel(self.OldLevel, 0)
        self.OldAttrGo_1:SetActive(false)
        self.OldAttrGo_2:SetActive(false)
        self.OldAttrGo_3:SetActive(false)
        return
    end
    local _forgeSystem = GameCenter.LianQiForgeSystem
    --- Set ItemUI data (icon,...)
    self.SourceEquipItemUI:InitWithItemData(_sourceItemData)

    --- Set Level Num
    local _strengthLevel = _forgeSystem:GetStrengthLvByPos(_pos)
    UIUtils.SetTextFormat(self.OldLevel, "+{0}", _strengthLevel)
    _forgeSystem:SetLabelColorByStrengthLevel(self.OldLevel, _strengthLevel)

    --- Set Attr Name and Attr Value
    self.OldAttrGo_1:SetActive(false)
    self.OldAttrGo_2:SetActive(false)
    self.OldAttrGo_3:SetActive(false)
    local attDic = _sourceItemData:GetBaseAttribute()
    local strengthAttrDic = _forgeSystem:GetAllStrengthAttrDicByPart(_pos)
    for index, attrID in pairs(attDic.Keys) do
        local _attrID, _attrValue = attrID, attDic[attrID]
        local _strengthValue = (strengthAttrDic[_attrID] and strengthAttrDic[_attrID].Value) or 0
        local formatValue = Utils.FormatAttributeValue(attrID, _strengthValue)
        
        if index == 0 then
            self.OldAttrGo_1:SetActive(_attrValue > 0 or _strengthValue > 0)
            UIUtils.SetTextByPropName(self.OldAttrName_1, _attrID)
            UIUtils.SetTextByString(self.OldAttrValue_1, formatValue)
        elseif index == 1 then
            self.OldAttrGo_2:SetActive(_attrValue > 0 or _strengthValue > 0)
            UIUtils.SetTextByPropName(self.OldAttrName_2, _attrID)
            UIUtils.SetTextByString(self.OldAttrValue_2, formatValue)
        elseif index == 2 then
            self.OldAttrGo_3:SetActive(_attrValue > 0 or _strengthValue > 0)
            UIUtils.SetTextByPropName(self.OldAttrName_3, _attrID)
            UIUtils.SetTextByString(self.OldAttrValue_3, formatValue)
        end
    end
end

function UILianQiForgeStrengthTransferForm:SetRightTargetEquipInfos()
    local _targetItemData = self.TargetEquipItemData and self.TargetEquipItemData.ShowItemData -- Equipment.cs

    if not _targetItemData then
        if not self.TargetEquipItemUI.IsShowAddSpr then
            self.TargetEquipItemUI.IsShowAddSpr = true
        end
        if self.TargetEquipItemUI.ShowItemData ~= nil then
            self.TargetEquipItemUI:InitWithItemData(nil, 0)
        end
        --UIUtils.SetTextByEnum(self.PerLabel, "Percent", 0)
        UIUtils.SetTextFormat(self.NewLevel, "+{0}", 0)
        GameCenter.LianQiForgeSystem:SetLabelColorByStrengthLevel(self.NewLevel, 0)
        self.NewAttrGo_1:SetActive(false)
        self.NewAttrGo_2:SetActive(false)
        self.NewAttrGo_3:SetActive(false)
        return
    end

    local _forgeBagSystem = GameCenter.LianQiForgeBagSystem
    --- Set ItemUI data (icon,...)
    self.TargetEquipItemUI:InitWithItemData(_targetItemData)

    --- Set Level Num
    local _strengthLevel = _forgeBagSystem:GetStrengthLvByItemId(_targetItemData.DBID)
    UIUtils.SetTextFormat(self.NewLevel, "+{0}", _strengthLevel)
    GameCenter.LianQiForgeSystem:SetLabelColorByStrengthLevel(self.NewLevel, _strengthLevel)

    --- Set Attr Name and Attr Value
    self.NewAttrGo_1:SetActive(false)
    self.NewAttrGo_2:SetActive(false)
    self.NewAttrGo_3:SetActive(false)
    local attDic = _targetItemData:GetBaseAttribute()
    local strengthAttrDic = _forgeBagSystem:GetAllStrengthAttrDicByItemId(_targetItemData.DBID)
    for index, attrID in pairs(attDic.Keys) do
        local _attrID, _attrValue = attrID, attDic[attrID]
        local _strengthValue = (strengthAttrDic[_attrID] and strengthAttrDic[_attrID].Value) or 0
        local formatValue = Utils.FormatAttributeValue(attrID, _strengthValue)
        
        if index == 0 then
            self.NewAttrGo_1:SetActive(_attrValue > 0 or _strengthValue > 0)
            UIUtils.SetTextByPropName(self.NewAttrName_1, _attrID)
            UIUtils.SetTextByString(self.NewAttrValue_1, formatValue)
        elseif index == 1 then
            self.NewAttrGo_2:SetActive(_attrValue > 0 or _strengthValue > 0)
            UIUtils.SetTextByPropName(self.NewAttrName_2, _attrID)
            UIUtils.SetTextByString(self.NewAttrValue_2, formatValue)
        elseif index == 2 then
            self.NewAttrGo_3:SetActive(true)
            self.NewAttrGo_3:SetActive(_attrValue > 0 or _strengthValue > 0)
            UIUtils.SetTextByPropName(self.NewAttrName_3, _attrID)
            UIUtils.SetTextByString(self.NewAttrValue_3, formatValue)
        end
    end
end

function UILianQiForgeStrengthTransferForm:HandleActiveButton()
    if not (self.SourceEquipItemData and self.SourceEquipItemData.Pos) then
        self.TransferBtn.isEnabled = false
        return
    end
    local _forgeSystem = GameCenter.LianQiForgeSystem
    local part = self.SourceEquipItemData.ItemData.Part
    local _strengthLevel = _forgeSystem:GetStrengthLvByPos(part)

    local haveCoin = GameCenter.ItemContianerSystem:GetEconomyWithType(self.CurrencyCostType)
    local needCoin = self.CurrencyCostAmount

    local hasStrengthLevel = _strengthLevel > 0
    local hasTargetItem = self.TargetEquipItemData ~= nil
    local isPercentFull = self.CurPercent >= 100
    local isCoinEnough = haveCoin >= needCoin

    local newState = hasStrengthLevel and hasTargetItem and isPercentFull and isCoinEnough
    if self.TransferBtn.isEnabled ~= newState then
        self.TransferBtn.isEnabled = newState
    end
end
------------------------------------------------------------------------------------------------------------------------
function UILianQiForgeStrengthTransferForm:OnTransferBtn()
    if not (self.SourceEquipItemData and self.SourceEquipItemData.Pos) then
        return
    end

    local _forgeSystem = GameCenter.LianQiForgeSystem
    local _part = self.SourceEquipItemData.Pos
    local _equipId = self.TargetEquipItemData.ShowItemData.DBID

    local _index = 1
    local _infos = List:New() -- List<{index, itemId, value}>
    self.SelectedStoneDataDic:Foreach(function(itemId, data)
        _infos:Add({ index = _index, itemId = itemId, value = data.Count })
        _index = _index + 1
    end)

    _forgeSystem:ReqEquipMoveLevel(_part, _infos, _equipId)
end

function UILianQiForgeStrengthTransferForm:MoveEquipStrengthLv(obj, sender)
    if not (obj and obj[1] and obj[2]) then
        return
    end

    local part, level = obj[1], obj[2]
    if not self.EquipDic:ContainsKey(part) then
        return
    end
    local item = self.EquipDic[part]
    item:SetStrengthLv(level)
    --- Refresh All UI
    self.TargetEquipItemData = nil
    self:LeftEquipItemOnClick(item, true)
    --- Show success effect
    self.VfxSkinCompo:OnDestory()
    self.VfxSkinCompo:OnCreateAndPlay(ModelTypeCode.UIVFX, self.VfxID, LayerUtils.GetAresUILayer())
end

return UILianQiForgeStrengthTransferForm