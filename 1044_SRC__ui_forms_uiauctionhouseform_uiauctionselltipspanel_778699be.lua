------------------------------------------------
-- author:
-- Date: 2019-10-10
-- File: UIAuctionSellTipsPanel.lua
-- Module: UIAuctionSellTipsPanel
-- Description: Tips interface
------------------------------------------------
local L_ItemBase = CS.Thousandto.Code.Logic.ItemBase
local L_Equipment = CS.Thousandto.Code.Logic.Equipment
local L_BattlePropTools = CS.Thousandto.Code.Logic.BattlePropTools
local L_HolyEquip = CS.Thousandto.Code.Logic.HolyEquip
local L_AuctionMiMaKey = "AuctionSellMiMa"

-- //Module definition
local UIAuctionSellTipsPanel = {
    -- Current transform
    Trans = nil,
    -- father
    Parent = nil,
    -- Animation module
    AnimModule = nil,

    CloseBtn = nil,

    UIItem = nil,
    Name = nil,
    QuaBack = nil,

    ItemRoot = nil,
    ItemType = nil,
    ItemLevel = nil,
    ItemScroll = nil,
    ItemDesc = nil,

    EquipRoot = nil,
    EquipOcc = nil,
    EquipPart = nil,
    EquipLevel = nil,
    EquipPower = nil,
    EquipScroll = nil,
    EquipProName = nil,
    EquipProValue = nil,

    BtnGrid = nil,
    WorldSell = nil,
    GuildSell = nil,
    PutOutBtn = nil,

    CountLabel = nil,
    CountDecBtn = nil,
    CountAddBtn = nil,
    CoutInputBtn = nil,

    CurPriceGo = nil,
    CurPriceValue = nil,
    CurPriceIcon = nil,
    MaxPriceGo = nil,
    MaxPriceValue = nil,
    MaxPriceIcon = nil,

    InstID = 0,
    MaxCount = 0,
    CurCount = 0,
    IsSell = false,
    SingleAddPrice = 0,
    SingleMinPrice = 0,
    SingleMaxPrice = 0,
    -- Item Type
    ItemInstType = nil,

    -- Quantity limit
    MaxUPCount = 0,

    -- password
    MiMaBtn = nil,
    MiMaSelect = nil,
    MiMaPriceBtn = nil,
    MiMaPriceValue = nil,
    MiMaPriceIcon = nil,
    MiMaInptuBtn = nil,
    MiMaInputValue = nil,
    IsUseMiMa = false,
    -- Is it possible to use a password
    CanUseMiMa = false,
    SaveMiMaValue = nil,
    -- Password input box
    MiMaInptuPanel = nil,
    -- Price entered
    MiMaInputPrice = 0,

    MiMaZongJiaGo = nil,
    MiMaZongJiaPrice = nil,
    MiMaZongJiaPriceIcon = nil,

    -- Custom price input box
    CutomGo = nil,
    CutomInput = nil,
    CutomPrice = nil,
    CutomIcon = nil,
    -- Whether to customize the price
    IsCutomPrice = false,
    -- Custom price entered
    CutonInputPrice = 0,
}

function UIAuctionSellTipsPanel:OnFirstShow(trans, parent, rootForm)
    self.Trans = trans
    self.Parent = parent
    self.RootForm = rootForm

    -- Create an animation module
    self.AnimModule = UIAnimationModule(self.Trans)
    -- Add an animation
    self.AnimModule:AddNormalAnimation(0.3)
    self.Trans.gameObject:SetActive(false)
    self.IsVisible = false

    self.CloseBtn = UIUtils.FindBtn(trans, "BG")
    UIUtils.AddBtnEvent(self.CloseBtn, self.OnCloseBtnClick, self)
    local _close2 = UIUtils.FindBtn(trans, "Close")
    UIUtils.AddBtnEvent(_close2, self.OnCloseBtnClick, self)
    self.UIItem = UILuaItem:New(UIUtils.FindTrans(trans, "UIItem"))
    self.Name = UIUtils.FindLabel(trans, "Name")
    self.QuaBack = UIUtils.FindSpr(trans, "QualityBack")
    self.ItemRoot = UIUtils.FindGo(trans, "Item")
    self.ItemType = UIUtils.FindLabel(trans, "Item/ItemType/ItemType")
    self.ItemLevel = UIUtils.FindLabel(trans, "Item/ItemLevel/ItemLevel")
    self.ItemScroll = UIUtils.FindScrollView(trans, "Item/ScrollView")
    self.ItemDesc = UIUtils.FindLabel(trans, "Item/ScrollView/Desc")
    
    self.EquipRoot = UIUtils.FindGo(trans, "Equip")
    self.EquipOcc = UIUtils.FindLabel(trans, "Equip/Occ/Value")
    self.EquipPart = UIUtils.FindLabel(trans, "Equip/Part/Value")
    self.EquipLevel = UIUtils.FindLabel(trans, "Equip/Level")
    self.EquipPower = UIUtils.FindLabel(trans, "Equip/Power/Value")
    self.EquipScroll = UIUtils.FindScrollView(trans, "Equip/ScrollView")
    self.EquipProName = UIUtils.FindLabel(trans, "Equip/ScrollView/Names")
    self.EquipProValue = UIUtils.FindLabel(trans, "Equip/ScrollView/Values")
    self.BtnGrid = UIUtils.FindGrid(trans, "BtnGrid")
    self.WorldSell = UIUtils.FindBtn(trans, "BtnGrid/WorldSell")
    UIUtils.AddBtnEvent(self.WorldSell, self.OnWorldSellBtnClick, self)
    self.GuildSell = UIUtils.FindBtn(trans, "BtnGrid/GuildSell")
    UIUtils.AddBtnEvent(self.GuildSell, self.OnGuildSellBtnClick, self)
    self.PutOutBtn = UIUtils.FindBtn(trans, "PutOut")
    UIUtils.AddBtnEvent(self.PutOutBtn, self.OnPutOutBtnClick, self)
    self.CountLabel = UIUtils.FindLabel(trans, "Count/Value")
    self.CountDecBtn = UIUtils.FindBtn(trans, "Count/DecBtn")
    UIUtils.AddBtnEvent(self.CountDecBtn, self.OnCountDecBtnClick, self)
    self.CountAddBtn = UIUtils.FindBtn(trans, "Count/AddBtn")
    UIUtils.AddBtnEvent(self.CountAddBtn, self.OnCountAddBtnClick, self)
    self.CoutInputBtn = UIUtils.FindBtn(trans, "Count/Value")
    UIUtils.AddBtnEvent(self.CoutInputBtn, self.OnCoutInputBtnClick, self)
    self.CurPriceGo = UIUtils.FindGo(trans, "CurPrice")
    self.CurPriceValue = UIUtils.FindLabel(trans, "CurPrice/Value")
    self.MaxPriceGo = UIUtils.FindGo(trans, "MaxPrice")
    self.MaxPriceValue = UIUtils.FindLabel(trans, "MaxPrice/Value")
    local _gCfg = DataConfig.DataGlobal[GlobalName.Trade_maxrecord]
    self.MaxUPCount = tonumber(_gCfg.Params)
    self.QualityVfx = UIUtils.RequireUIVfxSkinCompoent(UIUtils.FindTrans(trans, "UIVfxSkinCompoent"))

    self.MiMaBtn = UIUtils.FindBtn(trans, "MiMaBtn")
    UIUtils.AddBtnEvent(self.MiMaBtn, self.OnMiMaBtnClick, self)
    self.MiMaSelect = UIUtils.FindGo(trans, "MiMaBtn/Select")
    self.MiMaPriceBtn = UIUtils.FindBtn(trans, "MiMaPrice")
    UIUtils.AddBtnEvent(self.MiMaPriceBtn, self.OnMiMaPriceBtnClick, self)
    self.MiMaPriceValue = UIUtils.FindLabel(trans, "MiMaPrice/Value")
    self.MiMaInptuBtn = UIUtils.FindBtn(trans, "MimaInput")
    UIUtils.AddBtnEvent(self.MiMaInptuBtn, self.OnMiMaInptuBtnClick, self)
    self.MiMaInputValue = UIUtils.FindLabel(trans, "MimaInput/Value")
    self.MiMaInptuPanel = require "UI.Forms.UIAuctionHouseForm.UIAuctionNumberInputPanel"
    self.MiMaInptuPanel:OnFirstShow(UIUtils.FindTrans(trans, "MiMaPanel"), self, rootForm)
    self.MiMaZongJiaGo = UIUtils.FindGo(trans, "MiMaZongJia")
    self.MiMaZongJiaPrice = UIUtils.FindLabel(trans, "MiMaZongJia/Value")

    self.CurPriceIcon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(trans, "CurPrice/Icon"))
    self.MaxPriceIcon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(trans, "MaxPrice/Icon"))
    self.MiMaPriceIcon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(trans, "MiMaPrice/Icon"))
    self.MiMaZongJiaPriceIcon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(trans, "MiMaZongJia/Icon"))

    self.CutomGo = UIUtils.FindGo(trans, "CutomInput")
    self.CutomInput = UIUtils.FindBtn(trans, "CutomInput")
    UIUtils.AddBtnEvent(self.CutomInput, self.OnCutomInputClick, self)
    self.CutomPrice = UIUtils.FindLabel(trans, "CutomInput/Value")
    self.CutomIcon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(trans, "CutomInput/Icon"))
    return self
end

function UIAuctionSellTipsPanel:Show(itemInst, isSell)
    -- Play the start-up picture
    self.AnimModule:PlayEnableAnimation()
    self.IsVisible = true

    self.IsSell = isSell
    local _itemBase = nil
    if isSell then
        -- Listed itemInst is ItemBase
        _itemBase = itemInst
        self.InstID = _itemBase.DBID
        self.ItemInstType = itemInst.Type
        self.WorldSell.gameObject:SetActive(GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.AuchtionWorld))
        self.GuildSell.gameObject:SetActive(GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.AuchtionGuild))
        self.PutOutBtn.gameObject:SetActive(false)
        self.BtnGrid:Reposition()
    else
        -- Removed itemInst as AuctionItem
        _itemBase = itemInst.ItemInst
        self.InstID = itemInst.ID
        self.ItemInstType = nil
        self.WorldSell.gameObject:SetActive(false)
        self.GuildSell.gameObject:SetActive(false)
        self.PutOutBtn.gameObject:SetActive(true)
        self.HasMiMa = itemInst.HasMiMa
        self.CutomGo:SetActive(false)
        UIUtils.SetTextByNumber(self.MiMaZongJiaPrice, itemInst.CurPrice)
    end
    
    self.MaxCount = _itemBase.Count
    self.CurCount = self.MaxCount
    self.UIItem:InitWithItemData(_itemBase, nil, nil, false, nil, nil)
    UIUtils.SetTextFormat(self.Name, "[{0}]{1}",  Utils.GetQualityStrColor(_itemBase.Quality),  _itemBase.Name)

    self.CanUseMiMa = false
    self.UseCoinName = nil
    local _equipCfg = DataConfig.DataEquip[_itemBase.CfgID]
    local _itemCfg = DataConfig.DataItem[_itemBase.CfgID]
    local _coinIcon = 0



    if _equipCfg ~= nil then
        self.EquipRoot:SetActive(true)
        self.ItemRoot:SetActive(false)
        local _coinCfg = DataConfig.DataItem[_equipCfg.AuctionUseCoin]
        _coinIcon = _coinCfg.Icon
        self.UseCoinName = _coinCfg.Name
        if _equipCfg.Quality >= 6 then
            self.QualityVfx:OnCreateAndPlay(ModelTypeCode.UIVFX, 126 + _equipCfg.Quality, LayerUtils.GetAresUILayer());
        end

        local lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if lp ~= nil then
            if string.find(_equipCfg.Gender, tostring(lp.IntOcc)) ~= nil then
                UIUtils.SetTextByString(self.EquipOcc, L_Equipment.GetOccNameWithOcc(_equipCfg.Gender))
            else
                UIUtils.SetTextFormat(self.EquipOcc, "[FF0000]{0}[-]",  L_Equipment.GetOccNameWithOcc(_equipCfg.Gender))
            end
        end

        if _itemBase.Type == ItemType.Equip then
            UIUtils.SetTextByString(self.EquipPart, LuaItemBase.GetEquipNameWithType(_equipCfg.Part))
        else
            UIUtils.SetTextByString(self.EquipPart, L_HolyEquip.GetEquipNameWithType(_equipCfg.Part))
        end
        UIUtils.SetTextByEnum(self.EquipLevel, "WearLevel", CommonUtils.GetLevelDesc(_equipCfg.Level))
        UIUtils.SetTextByNumber(self.EquipPower, _itemBase.Power)
        local _curPros = Utils.SplitStrByTableS(_equipCfg.Attribute1)
        local _proNames = ""
        local _proValues = ""
        -- for i = 1, #_curPros do
        --     local _name = L_BattlePropTools.GetBattlePropName(tonumber(_curPros[i][1]))
        --     local _value = L_BattlePropTools.GetBattleValueText(tonumber(_curPros[i][1]), tonumber(_curPros[i][2]))
        --     if string.len(_proNames) <= 0 then
        --         _proNames = _proNames .. _name
        --     else
        --         _proNames = _proNames .. '\n' .. _name
        --     end

        --     if string.len(_proValues) <= 0 then
        --         _proValues = _proValues .. _value
        --     else
        --         _proValues = _proValues .. '\n' .. _value
        --     end
        -- end
        -- UIUtils.SetTextByString(self.EquipProName, _proNames)
        -- UIUtils.SetTextByString(self.EquipProValue, _proValues)

        ------------------------------- custom ------------------------------------

        local attDic = _itemBase:GetBaseAttribute()
        if not attDic then return end

        local _proNames = ""
        local _proValues = ""

        local e = attDic:GetEnumerator()
        while e:MoveNext() do
            local attrID = e.Current.Key
            local baseValue = e.Current.Value

            if baseValue and baseValue > 0 then
                local _name = L_BattlePropTools.GetBattlePropName(attrID)
                local _value = L_BattlePropTools.GetBattleValueText(attrID, baseValue)

                if string.len(_proNames) <= 0 then
                    _proNames = _name
                    _proValues = _value
                else
                    _proNames = _proNames .. "\n" .. _name
                    _proValues = _proValues .. "\n" .. _value
                end
            end
        end

        UIUtils.SetTextByString(self.EquipProName, _proNames)
        UIUtils.SetTextByString(self.EquipProValue, _proValues)

        ------------------------------- custom ------------------------------------

      
        self.EquipScroll.repositionWaitFrameCount = 1

        self.SingleAddPrice = _equipCfg.AuctionSinglePrice
        self.SingleMinPrice = _equipCfg.AuctionMinPrice
        self.SingleMaxPrice = _equipCfg.AuctionMaxPrice
        if self.SingleAddPrice <= 0 then
            UIUtils.SetTextByEnum(self.CurPriceValue, "NULL")
        else
            UIUtils.SetTextByNumber(self.CurPriceValue, self.CurCount * self.SingleMinPrice)
        end
        self.IsCutomPrice = _equipCfg.AuctionPriceType == 1
        if _equipCfg.AuctionPriceType == 1 then
            if not isSell then
                UIUtils.SetTextByNumber(self.MaxPriceValue, itemInst.CurPrice)
            end
            self.CanUseMiMa = isSell
        else
            if self.SingleMaxPrice <= 0 then
                UIUtils.SetTextByEnum(self.MaxPriceValue, "NULL")
            else
                UIUtils.SetTextByNumber(self.MaxPriceValue, self.CurCount * self.SingleMaxPrice)
                self.CanUseMiMa = isSell
            end
        end
        self.QuaBack.spriteName = Utils.GetQualityBackName(_equipCfg.Quality)
    elseif _itemCfg ~= nil then
        self.EquipRoot:SetActive(false)
        self.ItemRoot:SetActive(true)
        local _coinCfg = DataConfig.DataItem[_itemCfg.AuctionUseCoin]
        _coinIcon = _coinCfg.Icon
        self.UseCoinName = _coinCfg.Name

        if _itemCfg.Color >= 6 then
            self.QualityVfx:OnCreateAndPlay(ModelTypeCode.UIVFX, 126 + _itemCfg.Color, LayerUtils.GetAresUILayer());
        end

        local typeString = LuaItemBase.GetTypeNameWitType(_itemBase.Type)
        if typeString ~= nil then
            UIUtils.SetTextByString(self.ItemType, typeString)
        end

        local levelValue = CommonUtils.GetLevelDesc(_itemCfg.Level)
        local sText = UIUtils.CSFormat(DataConfig.DataMessageString.Get("C_MAIN_NON_PLAYER_SHOW_LEVEL"), levelValue)
        if (_itemBase:CheckLevel(GameCenter.GameSceneSystem:GetLocalPlayerLevel())) then
            UIUtils.SetTextFormat(self.ItemLevel, "[00EE00]{0}[-]", sText)
        else
            UIUtils.SetTextFormat(self.ItemLevel, "[CD0000]{0}[-]", sText)
        end

        UIUtils.SetTextByStringDefinesID(self.ItemDesc, _itemCfg._Description)
        self.SingleAddPrice = _itemCfg.AuctionSinglePrice
        self.SingleMinPrice = _itemCfg.AuctionMinPrice
        self.SingleMaxPrice = _itemCfg.AuctionMaxPrice
        if self.SingleAddPrice <= 0 then
            UIUtils.SetTextByEnum(self.CurPriceValue, "NULL")
        else
            UIUtils.SetTextByNumber(self.CurPriceValue, self.CurCount * self.SingleMinPrice)
        end
        self.IsCutomPrice = _itemCfg.AuctionPriceType == 1
        if _itemCfg.AuctionPriceType == 1 then
            if not isSell then
                UIUtils.SetTextByNumber(self.MaxPriceValue, itemInst.CurPrice)
            end
            self.CanUseMiMa = isSell
        else
            if self.SingleMaxPrice <= 0 then
                UIUtils.SetTextByEnum(self.MaxPriceValue, "NULL")
            else
                UIUtils.SetTextByNumber(self.MaxPriceValue, self.CurCount * self.SingleMaxPrice)
                self.CanUseMiMa = isSell
            end
        end
        self.QuaBack.spriteName = Utils.GetQualityBackName(_itemCfg.Color)
        self.ItemScroll.repositionWaitFrameCount = 1
    end
    self.MiMaInputPrice =  0
    self.CutonInputPrice = 0
    UIUtils.SetTextByNumber(self.CountLabel, self.CurCount)
    self:SetUseMiMa(false)

    self.CurPriceIcon:UpdateIcon(_coinIcon)
    self.MaxPriceIcon:UpdateIcon(_coinIcon)
    self.MiMaPriceIcon:UpdateIcon(_coinIcon)
    self.MiMaZongJiaPriceIcon:UpdateIcon(_coinIcon)
    self.CutomIcon:UpdateIcon(_coinIcon)
end

function UIAuctionSellTipsPanel:SetUseMiMa(b)
    if self.CanUseMiMa then
        self.MiMaBtn.gameObject:SetActive(true)
        self.MiMaZongJiaGo:SetActive(false)
        self.IsUseMiMa = b
        if b then
            self.MiMaInptuBtn.gameObject:SetActive(true)
            self.MiMaPriceBtn.gameObject:SetActive(true)
            self.MiMaSelect:SetActive(true)
            self.CurPriceGo:SetActive(false)
            self.MaxPriceGo:SetActive(false)
            self.CutomGo:SetActive(false)
            self.SaveMiMaValue = PlayerPrefs.GetString(L_AuctionMiMaKey)
            self:RefreshMiMa()
            self:RefreshMiMaPrice()
        else
            self.MiMaInptuBtn.gameObject:SetActive(false)
            self.MiMaPriceBtn.gameObject:SetActive(false)
            self.MiMaSelect:SetActive(false)
            self.CurPriceGo:SetActive(not self.IsCutomPrice)
            self.MaxPriceGo:SetActive(not self.IsCutomPrice)
            self.CutomGo:SetActive(self.IsCutomPrice)
            self:RefreshCutomPrice()
        end
    else
        if self.HasMiMa then
            self.MiMaBtn.gameObject:SetActive(false)
            self.MiMaInptuBtn.gameObject:SetActive(false)
            self.MiMaPriceBtn.gameObject:SetActive(false)
            self.MiMaSelect:SetActive(false)
            self.CurPriceGo:SetActive(false)
            self.MaxPriceGo:SetActive(false)
            self.MiMaZongJiaGo:SetActive(true)
            self.CutomGo:SetActive(false)
        else
            self.IsUseMiMa = false
            self.MiMaBtn.gameObject:SetActive(false)
            self.MiMaInptuBtn.gameObject:SetActive(false)
            self.MiMaPriceBtn.gameObject:SetActive(false)
            self.MiMaSelect:SetActive(false)
            self.CurPriceGo:SetActive(not self.IsCutomPrice)
            self.MaxPriceGo:SetActive(self.IsCutomPrice or (not self.IsSell))
            self.MiMaZongJiaGo:SetActive(false)
            self.CutomGo:SetActive(false)
        end
    end
end

function UIAuctionSellTipsPanel:RefreshMiMa()
    if self.SaveMiMaValue == nil or string.len(self.SaveMiMaValue) <= 0 then
        UIUtils.SetTextByEnum(self.MiMaInputValue, "C_AUCTION_INPUT_MIMA")
    else
        UIUtils.SetTextByString(self.MiMaInputValue, self.SaveMiMaValue)
    end
end

function UIAuctionSellTipsPanel:OnMiMaBtnClick()
    self:SetUseMiMa(not self.IsUseMiMa)
end
    
function UIAuctionSellTipsPanel:OnMiMaInptuBtnClick()
    self.MiMaInptuPanel:OpenInput(function(num)
        if self.SaveMiMaValue == nil then
            self.SaveMiMaValue = ""
        end
        if string.len(self.SaveMiMaValue) >=6 then
            Utils.ShowPromptByEnum("C_AUCTION_MIMA_FAILED")
            return
        end
        self.SaveMiMaValue = self.SaveMiMaValue .. num
        self:RefreshMiMa()
    end,
    function()
        if self.SaveMiMaValue == nil then
            self.SaveMiMaValue = ""
        end
        local _len = string.len(self.SaveMiMaValue)
        if _len <= 0 then
            return
        end
        self.SaveMiMaValue = string.sub(self.SaveMiMaValue, 1, _len - 1)
        self:RefreshMiMa()
    end)
end
function UIAuctionSellTipsPanel:RefreshMiMaPrice()
    if self.MiMaInputPrice <= 0 then
        UIUtils.SetTextByEnum(self.MiMaPriceValue, "C_AUCTION_INPUT_JIAGE")
    else
        UIUtils.SetTextByNumber(self.MiMaPriceValue, self.MiMaInputPrice)
    end
end

function UIAuctionSellTipsPanel:OnMiMaPriceBtnClick()
    self.MiMaInptuPanel:OpenInput(function(num)
        if self.MiMaInputPrice < 0 then
            self.MiMaInputPrice = 0
        end
        self.MiMaInputPrice = self.MiMaInputPrice * 10 + num
        if self.CurCount * self.SingleMaxPrice < self.MiMaInputPrice then
            self.MiMaInputPrice = self.CurCount * self.SingleMaxPrice
        end
        self:RefreshMiMaPrice()
    end,
    function()
        self.MiMaInputPrice = self.MiMaInputPrice // 10
        self:RefreshMiMaPrice()
    end,
    function()
        if self.MiMaInputPrice < 2 then
            self.MiMaInputPrice = 2
            self:RefreshMiMaPrice()
        end
    end)
end
function UIAuctionSellTipsPanel:RefreshCutomPrice()
    if self.CutonInputPrice <= 0 then
        UIUtils.SetTextByEnum(self.CutomPrice, "C_AUCTION_INPUT_JIAGE")
    else
        UIUtils.SetTextByNumber(self.CutomPrice, self.CutonInputPrice)
    end
end
function UIAuctionSellTipsPanel:OnCutomInputClick()
    self.MiMaInptuPanel:OpenInput(function(num)
        if num < 0 then
            num = 0
        end
        self.CutonInputPrice = self.CutonInputPrice * 10 + num
        if self.CurCount * self.SingleMaxPrice < self.CutonInputPrice then
            self.CutonInputPrice = self.CurCount * self.SingleMaxPrice
        end
        self:RefreshCutomPrice()
    end,
    function()
        self.CutonInputPrice = self.CutonInputPrice // 10
        self:RefreshCutomPrice()
    end,
    function()
        if self.CutonInputPrice < 2 then
            self.CutonInputPrice = 2
            self:RefreshCutomPrice()
        end
    end)
end

function UIAuctionSellTipsPanel:Hide()
    -- Play Close animation
    self.AnimModule:PlayDisableAnimation()
    self.IsVisible = false
end

function UIAuctionSellTipsPanel:OnCloseBtnClick()
    self:Hide()
end

-- Shelves in the world
function UIAuctionSellTipsPanel:OnWorldSellBtnClick()
    -- Holy clothing, determine whether the player's VIP level is sufficient
    if self.ItemInstType == ItemType.HolyEquip and self.RootForm.HolyEquipSellNeedVipLevel > 0  then
        local _vipLevel = GameCenter.VipSystem:GetVipLevel()
        if _vipLevel < self.RootForm.HolyEquipSellNeedVipLevel then
            Utils.ShowPromptByEnum("Trade_VIP_Limit_Push_Title", self.RootForm.HolyEquipSellNeedVipLevel)
            return
        end
        if not GameCenter.VipSystem:BaoZhuIsOpen() then
            Utils.ShowPromptByEnum("C_AUCTION_SZSELL_BAOZHU")
            return
        end
    end
    -- Demon soul equipment, determine whether the player's VIP level is sufficient
    if self.ItemInstType == ItemType.DevilSoulChip and self.RootForm.DevilEquipSellNeedVipLevel > 0 then
        local _vipLevel = GameCenter.VipSystem:GetVipLevel()
        if _vipLevel < self.RootForm.DevilEquipSellNeedVipLevel then
            Utils.ShowPromptByEnum("Devil_Trade_VIP_Limit_Push_Title", self.RootForm.DevilEquipSellNeedVipLevel)
            return
        end
        if not GameCenter.VipSystem:BaoZhuIsOpen() then
            Utils.ShowPromptByEnum("C_AUCTION_MHSELL_BAOZHU")
            return
        end
    end

    if (self.Parent.CurUPCount + 1) > self.MaxUPCount then
        Utils.ShowPromptByEnum("PutawayFullTips")
    else
        if self.IsUseMiMa then
            -- Determine password length
            if string.len(self.SaveMiMaValue) ~= 6 then
                Utils.ShowPromptByEnum("C_AUCTION_MIMA_FAILED")
                return
            end
            -- Judgment of the maximum price
            if self.CurCount * self.SingleMaxPrice < self.MiMaInputPrice then
                Utils.ShowPromptByEnum("C_AUCTION_JIAGE_FAILED")
                return
            end
            if self.MiMaInputPrice < 2 then
                Utils.ShowPromptByEnum("C_AUCTION_MIN_PRICE", 2, self.UseCoinName)
                return
            end
            PlayerPrefs.SetString(L_AuctionMiMaKey, self.SaveMiMaValue)
            GameCenter.Network.Send("MSG_Auction.ReqAuctionInfoPut", {itemUid = self.InstID, num = self.CurCount, type = 0, password = self.SaveMiMaValue, price = self.MiMaInputPrice})
        else
            if self.IsCutomPrice then
                if self.CutonInputPrice < 2 then
                    Utils.ShowPromptByEnum("C_AUCTION_MIN_PRICE", 2, self.UseCoinName)
                    return
                end
                GameCenter.Network.Send("MSG_Auction.ReqAuctionInfoPut", {itemUid = self.InstID, num = self.CurCount, type = 0, price = self.CutonInputPrice})
            else
                GameCenter.Network.Send("MSG_Auction.ReqAuctionInfoPut", {itemUid = self.InstID, num = self.CurCount, type = 0})
            end
        end
    end
end

-- Guild on shelves
function UIAuctionSellTipsPanel:OnGuildSellBtnClick()
    -- Holy clothing, determine whether the player's VIP level is sufficient
    if self.ItemInstType == ItemType.HolyEquip and self.RootForm.HolyEquipSellNeedVipLevel > 0 then
        local _vipLevel = GameCenter.VipSystem:GetVipLevel()
        if _vipLevel < self.RootForm.HolyEquipSellNeedVipLevel then
            Utils.ShowPromptByEnum("Trade_VIP_Limit_Push_Title", self.RootForm.HolyEquipSellNeedVipLevel)
            return
        end
        if not GameCenter.VipSystem:BaoZhuIsOpen() then
            Utils.ShowPromptByEnum("C_AUCTION_SZSELL_BAOZHU")
            return
        end
    end
    -- Demon soul equipment, determine whether the player's VIP level is sufficient
    if self.ItemInstType == ItemType.DevilSoulChip and self.RootForm.DevilEquipSellNeedVipLevel > 0 then
        local _vipLevel = GameCenter.VipSystem:GetVipLevel()
        if _vipLevel < self.RootForm.DevilEquipSellNeedVipLevel then
            Utils.ShowPromptByEnum("Devil_Trade_VIP_Limit_Push_Title", self.RootForm.DevilEquipSellNeedVipLevel)
            return
        end
        if not GameCenter.VipSystem:BaoZhuIsOpen() then
            Utils.ShowPromptByEnum("C_AUCTION_MHSELL_BAOZHU")
            return
        end
    end

    if GameCenter.GuildSystem:HasJoinedGuild() then
        if (self.Parent.CurUPCount + 1) > self.MaxUPCount then
            Utils.ShowPromptByEnum("PutawayFullTips")
        else
            if self.IsUseMiMa then
                -- Determine password length
                if string.len(self.SaveMiMaValue) ~= 6 then
                    Utils.ShowPromptByEnum("C_AUCTION_MIMA_FAILED")
                    return
                end
                -- Judgment of the maximum price
                if self.CurCount * self.SingleMaxPrice < self.MiMaInputPrice then
                    Utils.ShowPromptByEnum("C_AUCTION_JIAGE_FAILED")
                    return
                end
                if self.MiMaInputPrice < 2 then
                    Utils.ShowPromptByEnum("C_AUCTION_MIN_PRICE", 2, self.UseCoinName)
                    return
                end
                PlayerPrefs.SetString(L_AuctionMiMaKey, self.SaveMiMaValue)
                GameCenter.Network.Send("MSG_Auction.ReqAuctionInfoPut", {itemUid = self.InstID, num = self.CurCount, type = 1, password = self.SaveMiMaValue, price = self.MiMaInputPrice})
            else
                if self.IsCutomPrice then
                    if self.CutonInputPrice < 2 then
                        Utils.ShowPromptByEnum("C_AUCTION_MIN_PRICE", 2, self.UseCoinName)
                        return
                    end
                    GameCenter.Network.Send("MSG_Auction.ReqAuctionInfoPut", {itemUid = self.InstID, num = self.CurCount, type = 1, price = self.CutonInputPrice})
                else
                    GameCenter.Network.Send("MSG_Auction.ReqAuctionInfoPut", {itemUid = self.InstID, num = self.CurCount, type = 1})
                end
            end
        end
    else
        Utils.ShowPromptByEnum("PutawayGuildTips")
    end
end

-- Removed
function UIAuctionSellTipsPanel:OnPutOutBtnClick()
    GameCenter.Network.Send("MSG_Auction.ReqAuctionInfoOut", {auctionId = self.InstID})
end

function UIAuctionSellTipsPanel:OnCountDecBtnClick()
    if not self.IsSell then
        return
    end
    self.CurCount = self.CurCount - 1
    if self.CurCount < 1 then
        self.CurCount = 1
    end
    self:UpdateCurCount()
end

function UIAuctionSellTipsPanel:OnCountAddBtnClick()
    if not self.IsSell then
        return
    end
    self.CurCount = self.CurCount + 1
    self:UpdateCurCount()
end

function UIAuctionSellTipsPanel:OnCoutInputBtnClick()
    if not self.IsSell then
        return
    end
    if self.MaxCount <= 1 then
        return
    end
    self.MiMaInptuPanel:OpenInput(function(num)
        self.CurCount = self.CurCount * 10 + num
        self:UpdateCurCount()
    end,
    function()
        self.CurCount = self.CurCount // 10
        self:UpdateCurCount()
    end,
    function()
        if self.CurCount < 1 then
            self.CurCount = 1
            self:UpdateCurCount()
        end
        if self.CurCount > self.MaxCount then
            self.CurCount = self.MaxCount
            self:UpdateCurCount()
        end
    end)
end

function UIAuctionSellTipsPanel:UpdateCurCount()
    if self.CurCount < 0 then
        self.CurCount = 0
    end
    if self.CurCount > self.MaxCount then
        self.CurCount = self.MaxCount
    end
    UIUtils.SetTextByNumber(self.CountLabel, self.CurCount)
    if self.SingleAddPrice <= 0 then
        UIUtils.SetTextByEnum(self.CurPriceValue, "NULL")
    else
        UIUtils.SetTextByNumber(self.CurPriceValue, self.CurCount * self.SingleMinPrice)
    end
    if self.SingleMaxPrice <= 0 then
        UIUtils.SetTextByEnum(self.MaxPriceValue, "NULL")
    else
        UIUtils.SetTextByNumber(self.MaxPriceValue, self.CurCount * self.SingleMaxPrice)
    end

    -- Clear password price
    self.MiMaInputPrice = 0
    self:RefreshMiMaPrice()
    -- Clear custom price
    self.CutonInputPrice = 0
    self:RefreshCutomPrice()
end

return UIAuctionSellTipsPanel
