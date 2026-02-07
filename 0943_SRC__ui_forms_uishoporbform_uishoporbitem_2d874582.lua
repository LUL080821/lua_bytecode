------------------------------------------------
--author:
--Date: 2025-11-05
--File: UIShopOrbItem.lua
--Module: UIShopOrbForm > UIShopOrbPanel > UIShopOrbItem
--Description: Orb Mall
------------------------------------------------
local L_Itembase = CS.Thousandto.Code.Logic.ItemBase
local L_AddReduce = require "UI.Components.UIAddReduce"

local UIShopOrbItem = {
    Trans            = nil,
    Go               = nil,
    ParentForm       = nil,

    ItemUI           = nil, -- Item <UILuaItem.lua>
    ItemNameLabel    = nil, -- 
    ExchangeLabel    = nil, -- format: "Can be exchanged for 1/2"
    PriceLabel       = nil, -- 
    CurrencyIcon     = nil, -- CostIcon type <RequireUIIconBase>

    CostData         = nil, -- { Id, Num }
    ItemData         = nil, -- { Id, Num, IsBind }
    --Product data
    ShopItemData     = nil, --  <ShopOrbItemData.lua>

    --Click to callback
    ClickCallBack    = nil,

    --The maximum purchase volume of current products
    MaxPurchaseCount = 1,
    --The current number of inputs
    SelectedCount    = 1,
    NumInput         = nil,

    --Texture
    BgTex            = nil,
    BgTexName        = "n_tex_shop_orb_normal",
}

------------------------------------------------------------------------------------------------------------------------
--region [Init & Config]
-- Initialization, setup, and preloading data
-- ---------------------------------------------------------------------------------------------------------------------

function UIShopOrbItem:New(trans, owner)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m.ParentForm = owner
    _m:FindAllComponents()

    -- Default set 1
    _m.SelectedCount = 1
    return _m
end

function UIShopOrbItem:Clone()
    return self:New(UnityUtils.Clone(self.Go).transform, self.ParentForm)
end

function UIShopOrbItem:OnOwnClick()
    if self.ClickCallBack ~= nil then
        self.ClickCallBack(self)
    end
end

--endregion [Init & Config]

------------------------------------------------------------------------------------------------------------------------
--region [Data Binding / UI Update]
-- Update UI elements based on data and state
-- ---------------------------------------------------------------------------------------------------------------------

function UIShopOrbItem:FindAllComponents()
    self.ItemUI = UILuaItem:New(UIUtils.FindTrans(self.Trans, "UIItem"))
    self.ItemNameLabel = UIUtils.FindLabel(self.Trans, "Name")
    self.PriceLabel = UIUtils.FindLabel(self.Trans, "ChangeBtn/Cost/NumLabel")
    self.CurrencyIcon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(self.Trans, "ChangeBtn/Cost"))

    self.NumInput = L_AddReduce:OnFirstShow(UIUtils.FindTrans(self.Trans, "UIAddReduce"))
    self.NumInput:SetCallBack(Utils.Handler(self.OnClickAddReduce, self), Utils.Handler(self.OnClickAddReduceInput, self))

    self.ExchangeLabel = UIUtils.FindLabel(self.Trans, "Num_1")
    
    self.BtnTrans = UIUtils.FindTrans(self.Trans, "ChangeBtn")
    self.BtnDisableGO = UIUtils.FindGo(self.Trans, "ChangeBtn/DisableSpr")
    self.Btn = UIUtils.FindBtn(self.Trans, "ChangeBtn")
    UIUtils.AddBtnEvent(self.Btn, self.OnOwnClick, self)

    self.BgTex = UIUtils.FindTex(self.Trans, "BgTex")
end

-- Add or subtract quantity
function UIShopOrbItem:OnClickAddReduce(add)
    if add then
        self.SelectedCount = self.SelectedCount + 1
    else
        self.SelectedCount = self.SelectedCount - 1
    end
    self:FixNum()
    self.NumInput:SetValueLabel(tostring(self.SelectedCount))

    self:RefreshButtonState()
end

-- Enter a click to open the numeric input keyboard
function UIShopOrbItem:OnClickAddReduceInput()
    --[[GameCenter.NumberInputSystem:OpenInput(
            self.MaxPurchaseCount,
            Vector3(-200, 0, 0),
            function(num)
                if num < 1 then
                    num = 1
                end
                self.CurrentQuantity = num
                self.NumInput:SetValueLabel(tostring(num))
                self:OnUpdateHaveCoin(self.CurrencyId)
            end,
            0,
            function()
                self:FixNum()
                self.NumInput:SetValueLabel(tostring(self.CurrentQuantity))
            end
    )]]
end

--Quantity judgment: whether the upper and lower limits exceed
function UIShopOrbItem:FixNum()
    if not self.MaxPurchaseCount or self.MaxPurchaseCount == 0 then
        self.SelectedCount = 1
    else
        local _selectCount = math.max(self.SelectedCount or 1, 1)
        self.SelectedCount = math.min(_selectCount, self.MaxPurchaseCount)
    end
end

---@param data: <ShopOrbItemData.lua>
function UIShopOrbItem:UpdateShopItemData(data)
    self.ShopItemData = data
    if self.ShopItemData then
        -- Set object name
        self.Trans.name = string.format("%03d", data:GetID())

        -- Set ItemUI
        local playerOcc = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
        local itemData = data:GetItemData(playerOcc) -- { Id, Num, IsBind }
        self.ItemUI:InItWithCfgid(itemData.Id, itemData.Num, itemData.IsBind)
        self.ItemData = itemData

        --Set item name
        local itemCfg = DataConfig.DataItem[itemData.Id]
        UIUtils.SetTextByString(self.ItemNameLabel, itemCfg.Name)

        -- Exchange info
        local _maxExchange = data:GetAllCount() -- tổng lượt được phép đổi
        local _exchangedCount = data:GetCount() -- số lươt đã đổi
        self.MaxPurchaseCount = _maxExchange - _exchangedCount -- Số lượt tối đa có thể chọn

        -- text hiển thị "Có thể đổi {đã đổi}/{tổng}"
        local _exchangeText = UIUtils.CSFormat(DataConfig.DataMessageString.Get("C_ZCG_KEDUIHUAN"), _exchangedCount, _maxExchange)
        UIUtils.SetTextByString(self.ExchangeLabel, _exchangeText)

        if data:GetCount() >= _maxExchange then
            data:SetCount(_maxExchange)
            UIUtils.SetColorByString(self.ExchangeLabel, "#F11F1F") -- Red
        else
            UIUtils.SetColorByString(self.ExchangeLabel, "#217FCE") -- Blue
        end

        -- Set currency info
        local _costData = data:GetCostData() -- { Id, Num }
        self.CurrencyIcon:UpdateIcon(LuaItemBase.GetItemIcon(_costData.Id))
        self.CostData = _costData
        -- Update coin display (button)
        self:RefreshButtonState()
    end
end

--[[function UIShopOrbItem:OnUpdateUIByHaveCoin(costId)
    local _costId = self.CostData and self.CostData.Id
    local _costNum = self.CostData and self.CostData.Num or 0
    local _selectNum = self.SelectedCount

    if (costId and _costId and _costNum) and costId == _costId then
        local _needCurrency = (_costNum) * _selectNum
        local _haveCurrency = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(_costId)

        local _priceText = UIUtils.CSFormat("{0}/{1}", _haveCurrency, _needCurrency)
        UIUtils.SetTextByString(self.PriceLabel, _priceText)

        if (self.SelectedCount > 0 and self.MaxPurchaseCount > 0) and (_haveCurrency >= _needCurrency) then
            self.Btn.isEnabled = true
            UIUtils.SetColorByString(self.PriceLabel, "#252520") -- Black
        else
            self.Btn.isEnabled = false
            UIUtils.SetColorByString(self.PriceLabel, "#FFFEF5") -- Trắng
        end
    end
end]]

function UIShopOrbItem:RefreshButtonState()
    if not self.Btn then return end

    local canEnable = false
    local have, need = 0, 0

    -- VALIDATE COST DATA
    if self.ShopItemData and self.CostData and self.CostData.Id then
        local data = self.ShopItemData
        local _costId = self.CostData and self.CostData.Id
        local _costNum = self.CostData and self.CostData.Num or 0
        local _selectNum = self.SelectedCount
        local _maxNum = self.MaxPurchaseCount

        need = _costNum * _selectNum
        have = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(_costId) or 0

        -- VALIDATE EXCHANGE LIMIT
        local exchangeCount = data:GetCount()        -- số lần đã đổi
        local exchangeLimit = data:GetAllCount()     -- tổng số lần được đổi

        local underLimit = exchangeCount < exchangeLimit

        -- COMBINE ALL CONDITIONS
        canEnable = (_selectNum > 0) and (_maxNum > 0) and (have >= need) and underLimit

        local _priceText = UIUtils.CSFormat("{0}/{1}", have, need)
        UIUtils.SetTextByString(self.PriceLabel, _priceText)
    else
        canEnable = false
        UIUtils.SetTextByString(self.PriceLabel, "Đổi") -- TODO: change string
    end

    --[[self.Btn.isEnabled = canEnable
    if self.Btn.SetState then
        local state = canEnable and UIButton.State.Normal or UIButton.State.Disabled
        self.Btn:SetState(state, true)
    end]]
    if canEnable then
        self.BtnDisableGO:SetActive(false)
        UIUtils.SetBtnState(self.BtnTrans, true)
        UIUtils.SetColorByString(self.PriceLabel, "#252520")
    else
        self.BtnDisableGO:SetActive(true)
        UIUtils.SetBtnState(self.BtnTrans, false)
        UIUtils.SetColorByString(self.PriceLabel, "#252520")
    end
end

function UIShopOrbItem:LoadTextures(isSelected)
    local texName = isSelected and "n_tex_shop_orb_sellect" or "n_tex_shop_orb_normal"
    if not (self.ParentForm and self.BgTex and self.Go.activeSelf) then
        return
    end
    self.ParentForm:LoadTexture(self.BgTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, texName))
    self.BgTexName = texName
end

--endregion [Data Binding / UI Update]

------------------------------------------------------------------------------------------------------------------------
--region [Public API / Getters & Setters]
-- Methods callable from outside (other systems or UI)
-- ---------------------------------------------------------------------------------------------------------------------

function UIShopOrbItem:SetItemActive(isActive)
    if isActive then
        self.Go:SetActive(true)
        self:LoadTextures(false)
    else
        self.Go:SetActive(false)
    end
end

function UIShopOrbItem:SetItemSelect(isSelect)
    local targetTex = isSelect and "n_tex_shop_orb_sellect" or "n_tex_shop_orb_normal"
    if self.BgTexName ~= targetTex then
        self:LoadTextures(isSelect)
    end
end

---@return number: Shop Item Cfg ID
function UIShopOrbItem:GetShopItemID()
    return self.ShopItemData and self.ShopItemData:GetID()
end

---@return <ShopOrbItemData.lua>
function UIShopOrbItem:GetShopItemData()
    return self.ShopItemData
end

---@return number Item Cfg ID
function UIShopOrbItem:GetItemID()
    return self.ItemData and self.ItemData.Id
end

function UIShopOrbItem:GetItemData()
    return self.ItemData
end

---@return number: Lấy số lượng item được mua 
function UIShopOrbItem:GetItemQuantity()
    return self.SelectedCount or 0
end

---@return number: set số item được mua
function UIShopOrbItem:SetItemQuantity(num)
    self.SelectedCount = num
    self:FixNum()
    self.NumInput:SetValueLabel(tostring(self.SelectedCount))
end

function UIShopOrbItem:GetCostType()
    return self.CostData and self.CostData.Id
end

function UIShopOrbItem:GetCostNum()
    return self.CostData and self.CostData.Num
end

--endregion [Public API / Getters & Setters]

return UIShopOrbItem