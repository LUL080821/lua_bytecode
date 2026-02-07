------------------------------------------------
-- Author:
-- Date: 2019-07-08
-- File: ShopManager.lua
-- Module: ShopManager
-- Description: Store logic and data management
------------------------------------------------
local L_ShopData = require("Logic.Shop.ShopData")
local L_HouseShopData = require("Logic.Shop.HouseShopData")
local L_ShopContainer = require("Logic.Shop.ShopItemContainer")
local ShopManager = {
    ShopContainer = Dictionary:New(),
    LabelIDDic = Dictionary:New(),
    ShopCfgDic = Dictionary:New(),
    -- Product list of community mall indexed with product ID
    HouseShopDic = Dictionary:New(),
    -- Community mall product ID list Indexed by mall ID
    HouseTypeDic = Dictionary:New(),
    IsBuyComfirm = true,
    IsBuyComfirmForHouse = true,
}
-- load
function ShopManager:Initialize()
    self.IsBuyComfirm = true
    self.IsBuyComfirmForHouse = true
    self.HouseShopDic = Dictionary:New()
    self.HouseTypeDic = Dictionary:New()
end

-- uninstall
function ShopManager:UnInitialize()
    self.ShopContainer:Clear()
    self.HouseShopDic:Clear()
    self.HouseTypeDic:Clear()
end

-- Initialize the data dictionary
function ShopManager:InitShopLabelDic()
    if #self.ShopCfgDic > 0 then
        return
    end
    DataConfig.DataShopMaket:Foreach(function(k, v)
        if not self.LabelIDDic:ContainsKey(v.LabelID) then
            self.LabelIDDic:Add(v.LabelID, v.Type)
        end
        if self.ShopCfgDic:ContainsKey(v.LabelID) then
            self.ShopCfgDic[v.LabelID]:Add(v)
        else
            local _list = List:New()
            _list:Add(v)
            self.ShopCfgDic:Add(v.LabelID, _list)
        end
    end)
end

-- Get current VIP privilege discount
function ShopManager:GetCurDisCount()
    local _disCount = 10
    local _cfg = DataConfig.DataVIPTrueRecharge[GameCenter.VipSystem:GetCurTrueVipCfgId()]
    if _cfg then
        if _cfg.TrueRewardPowerPra and string.len(_cfg.TrueRewardPowerPra) > 0 then
            local _ar = Utils.SplitStr(_cfg.TrueRewardPowerPra, ';')
            for i = 1, #_ar do
                local _single = Utils.SplitNumber(_ar[i], '_')
                if #_single >= 3 and _single[1] == 28 then
                    _disCount = _single[3]
                end
            end
        end
    end
    return _disCount
end

-- Check if the store is a local store
function ShopManager:GetLabelIsLocal(page)
    self:InitShopLabelDic()
    if self.LabelIDDic:ContainsKey(page) then
        return self.LabelIDDic[page] == 0
    end
    return false
end

-- Get the corresponding store container
function ShopManager:GetShopItemContainer(type)
    local _spContainer = self.ShopContainer[type]
    if not _spContainer then
        _spContainer = L_ShopContainer:New(type)
        self.ShopContainer:Add(type, _spContainer)
    end
    return _spContainer
end

-- Update corresponding store containers
function ShopManager:UpdateShopItemInContainer(itemInfo, page, type, sort, occ)
    local _spContainer = self:GetShopItemContainer(type)
    if _spContainer ~= nil and itemInfo ~= nil then
        if itemInfo.sellId ~= nil then
            _spContainer:UpdateItem(L_ShopData:NewWithData(itemInfo), page)
        elseif itemInfo.GuildShopLvlStart then
            _spContainer:UpdateItem(L_ShopData:NewWithCfg(itemInfo), page, occ)
        else
            _spContainer:UpdateItem(L_ShopData:New(itemInfo), page)
        end
        if sort then
            _spContainer:Sort(page)
        end
    end
end

-- Set basic data for store item list
function ShopManager:SetShopItemByContainer(page, type, sort)
    self:InitShopLabelDic()
    local _spContainer = self:GetShopItemContainer(type)
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    local _shopLv = GameCenter.GuildSystem:OnGetGuildLevel(GuildBuildEnum.GuildShop)
    if _spContainer ~= nil and _lp then
        if self.ShopCfgDic:ContainsKey(page) then
            local _list = self.ShopCfgDic[page]
            for i = 1, #_list do
                if _lp.Level >= _list[i].Level and _shopLv >= _list[i].GuildShopLvlStart and _shopLv <= _list[i].GuildShopLvlEND then
                    self:UpdateShopItemInContainer(_list[i], page, type, false, _lp.IntOcc)
                end
            end
        end
    end
end

-- Delete items in the product container
function ShopManager:DeleteShopItemInContainer(sellId, page, type)
    local _spContainer = self:GetShopItemContainer(type)
    if _spContainer ~= nil  then
        _spContainer:DeleteItem(sellId, page)
    end
end

-- Change the number of purchases in the product container
function ShopManager:ChangeShopItemInContainer(sellId, page, type, overBuyNo, sort)
    local _spContainer = self:GetShopItemContainer(type)
    if _spContainer ~= nil  then
        local _itemDic = _spContainer:GetShopItemDic(page)
        if _itemDic:ContainsKey(sellId) then
            _itemDic[sellId].AlreadyBuyNum = overBuyNo
            _itemDic[sellId]:SetAddPrice()
        end
        if sort then
            _spContainer:Sort(page)
        end
    end
end

-- Requested Product List
-- shopid store big tag
-- labelid sub-store tags
function ShopManager:ReqShopItemList(shopId, labelId)
    GameCenter.Network.Send("MSG_Shop.ReqShopList", {shopId = shopId, labelId = labelId, gradeLimit = 0})
end

-- Product list issuance
function ShopManager:GS2U_ResShopItemList(result)
    if result then
        local _spContainer = nil
        local _type = result.shopId
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        _spContainer = self:GetShopItemContainer(_type)
        if _spContainer and _lp then
            _spContainer:ClearShopByPage(result.labelId)
            if result.itemList then
                for idx = 1, #result.itemList do
                    local shopItem = result.itemList[idx]
                    self:UpdateShopItemInContainer(shopItem, result.labelId, _type, false, _lp.IntOcc)
                end
            end
            if result.dataList then
                for idx = 1, #result.dataList do
                    local shopItem = result.dataList[idx]
                    if self:GetLabelIsLocal(result.labelId) then
                        local _cfg = DataConfig.DataShopMaket[shopItem.sellId]
                        if _cfg then
                            self:UpdateShopItemInContainer(_cfg, result.labelId, _type, false, _lp.IntOcc)
                        end
                    end
                    self:ChangeShopItemInContainer(shopItem.sellId, result.labelId, _type, shopItem.buyNum)
                end
            end
            _spContainer:Sort(result.labelId)
        end
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SHOPFORM_UPDATEPAGE, result.labelId, true)
    end
end

-- Updated product purchases
function ShopManager:SyncShopData(result)
    self:ChangeShopItemInContainer(result.data.sellId, result.labelId, result.shopId, result.data.buyNum, true)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SHOPFORM_UPDATEPAGE, result.labelId)
end

-- Successful purchase
function ShopManager:GS2U_ResBuySuccess(result)
    Utils.ShowPromptByEnum("C_SHOP_TIPS_BUYSUXESSSSSS")
    CS.Thousandto.Core.Asset.AudioPlayer.PlayUI("snd_ui_wupingoumai")
end

-- Purchase failed
function ShopManager:ResBuyFailure(result)
    if result then
        if result.reason == 1 then
            Utils.ShowPromptByEnum("NonexistentGoods")
        elseif result.reason == 2 then
            Utils.ShowPromptByEnum("NonexistentItems")
        elseif result.reason == 3 then
            Utils.ShowPromptByEnum("GoodsSoldOut")
        elseif result.reason == 4 then
            Utils.ShowPromptByEnum("BuyFailByLevelLower")
        elseif result.reason == 5 then
            Utils.ShowPromptByEnum("BuyFailBySectLower")
        elseif result.reason == 6 then
            Utils.ShowPromptByEnum("BuyFailByMilitaryLower")
        elseif result.reason == 7 then
            Utils.ShowPromptByEnum("BuyFailVipLevelLower")
        elseif result.reason == 8 then
            Utils.ShowPromptByEnum("BuyFailByNoMoney")
        elseif result.reason == 10 then
            Utils.ShowPromptByEnum("BuyFailByBagNoSpace")
        end
    end
end

-- Store Tag List
function ShopManager:GS2U_ResShopSubList(result)
    if result and result.sublist then
        for idx = 1, #result.sublist do
            local subMess = result.sublist[idx]
            local _type = subMess.shopId
            local _spContainer = nil
            _spContainer = self:GetShopItemContainer(_type)

            if _spContainer then
                _spContainer:ClearShopPage()
                for jdx = 1, #subMess.labelList do
                    _spContainer:AddShopPage(subMess.labelList[jdx])
                end
            end
        end
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SHOPFORM_UPDATEPAGEBTN)
    end
end

-- Update individual products
function ShopManager:ResFreshItemInfo(result)
    if result then
        self:UpdateShopItemInContainer(result.itemInfo, result.itemInfo.labelId, result.itemInfo.shopId, true)
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SHOPFORM_UPDATEPAGE, result.itemInfo.labelId)
    end
end

-- Open the mall interface according to Functionstarid
function ShopManager:OpenShopMallPanel(functionID, param)
    local _funcInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(functionID)
    if _funcInfo then
        if _funcInfo.Parent.ID == FunctionStartIdCode.GoldShop then
            GameCenter.PushFixEvent(UIEventDefine.UIShopMallForm_OPEN, {ShopPanelEnum.GoldShop, functionID, param})
        end
        if _funcInfo.Parent.ID == FunctionStartIdCode.ExchangeShop then
            GameCenter.PushFixEvent(UIEventDefine.UIShopMallForm_OPEN, {ShopPanelEnum.ExchangeShop, functionID, param})
        end
    end
end

-- Community mall list issuance
function ShopManager:ResHomeShopGoods(msg)
    if msg.goods then
        self.HouseShopDic:Clear()
        self.HouseTypeDic:Clear()
        for i = 1, #msg.goods do
            local _item = L_HouseShopData:New(msg.goods[i].goodsId, msg.goods[i].remain)
            if _item then
                self.HouseShopDic:Add(_item.SellId, _item)
                if self.HouseTypeDic:ContainsKey(_item.ShopID) then
                    self.HouseTypeDic[_item.ShopID]:Add(_item.SellId)
                else
                    local _list = List:New()
                    _list:Add(_item.SellId)
                    self.HouseTypeDic:Add(_item.ShopID, _list)
                end
            end
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_HOUSESHOP_UPDATE)
end

-- Community mall product update
function ShopManager:ResUpdateHomeShopGoods(msg)
    if msg.goods then
        local _item = L_HouseShopData:New(msg.goods.goodsId, msg.goods.remain)
        if _item then
            if self.HouseShopDic:ContainsKey(_item.SellId) then
                self.HouseShopDic[_item.SellId] = _item
            else
                self.HouseShopDic:Add(_item.SellId, _item)
                if self.HouseTypeDic:ContainsKey(_item.ShopID) then
                    self.HouseTypeDic[_item.ShopID]:Add(_item.SellId)
                else
                    local _list = List:New()
                    _list:Add(_item.SellId)
                    self.HouseTypeDic:Add(_item.ShopID, _list)
                end
            end
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_HOUSESHOPDATA_UPDATE)
end
return ShopManager
