------------------------------------------------
-- Author:
-- Date: 2025-11-04
-- File: ShopSpecialSystem.lua
-- Module: ShopSpecialSystem
-- Description: Store logic and data management
------------------------------------------------
local L_ShopOrbData = require("Logic.ShopSpecial.ShopOrbItemData")
local L_ShopContainer = require("Logic.ShopSpecial.ShopSpecialContainer")

local ShopSpecialSystem = {
    ShopContainer = Dictionary:New(), -- Dic<{pageId , L_ShopContainer}>
}

------------------------------------------------------------------------------------------------------------------------
--region [Init & Config]
-- Initialization, setup, and preloading data
-- ---------------------------------------------------------------------------------------------------------------------

---Load / Init
function ShopSpecialSystem:Initialize()
    self.ShopContainer = Dictionary:New()
end

---Unload / Clear
function ShopSpecialSystem:UnInitialize()
    self.ShopContainer:Clear()
end

--endregion [Init & Config]

------------------------------------------------------------------------------------------------------------------------
--region [Access & Data Handling]
-- Internal data management, used only inside the module
-- ---------------------------------------------------------------------------------------------------------------------

---Ensure OrbShop data exists in ShopContainer
function ShopSpecialSystem:EnsureShopOrbInAllShops()
    if not (self.ShopContainer and self.ShopContainer:ContainsKey(SpecialShopPanelEnum.OrbShop)) then
        local orbShop = self:GetShopItemContainer(SpecialShopPanelEnum.OrbShop)
        DataConfig.DataRechargeDailyTinhchau:Foreach(function(cfgId, cfg)
            local data = L_ShopOrbData:New(cfgId, cfg)  -- Note: cfgId is actually cfg.ID
            orbShop:UpdateItem(data)
        end)
    end

    return self.ShopContainer
end

---Get the corresponding store container (create if missing)
---@param type: shop type
---@return table: ShopSpecialContainer instance
function ShopSpecialSystem:GetShopItemContainer(type)
    -- 1. If container already exists, return it directly
    local _spContainer = self.ShopContainer[type]
    if _spContainer then
        return _spContainer
    end

    -- 2. Define special configuration for specific shops (only override defaults if needed)
    local typeConfig = {
        -- Item type <L_ShopOrbData>
        [SpecialShopPanelEnum.OrbShop] = {
            hasSubPage = false,
            --keyFunc    = function(item) return item:GetID() end,
            --sortFunc   = nil,
        },
        -- Add other shop types here if they need custom configuration
    }

    -- 3. Get configuration for the shop type or use defaults
    local config = typeConfig[type] or {}
    local _hasSubPage = (config.hasSubPage ~= false)                                -- default true
    local keyFunc = config.keyFunc or function(item) return item:GetID() end    -- default item:GetID()
    local sortFunc = config.sortFunc or nil                                         -- default: no sorting

    -- 4. Create a new ShopSpecialContainer with the specified configuration
    _spContainer = L_ShopContainer:New(type, _hasSubPage, keyFunc, sortFunc)
    -- 5. Add it to ShopContainer dictionary
    self.ShopContainer:Add(type, _spContainer)

    return _spContainer
end

---Update item in store container
function ShopSpecialSystem:UpdateShopItemInContainer(itemInfo, page, type, sort)
    if not itemInfo then return end

    local _spContainer = self:GetShopItemContainer(type)
    if not _spContainer then return end

    if itemInfo.ID ~= nil then
        _spContainer:UpdateItem(L_ShopOrbData:New(itemInfo), page)
    end

    -- Sort nếu cần
    if sort then
        _spContainer:Sort(page)
    end
end

---Delete item in store container
function ShopSpecialSystem:DeleteShopItemInContainer(itemKey, page, type)
    local _spContainer = self:GetShopItemContainer(type)
    if _spContainer then
        _spContainer:DeleteItem(itemKey, page)
    end
end

--endregion [Access & Data Handling]    

------------------------------------------------------------------------------------------------------------------------
--region [Network Requests & Responses]
-- Handle server requests and responses
-- ---------------------------------------------------------------------------------------------------------------------

---Request: Open the Orb Shop
function ShopSpecialSystem:ReqOpenOrbShop(pageId, shopId)
    local _req = ReqMsg.MSG_Tinhchau.ReqOpenTinhChauExchange:New();
    _req:Send()
end

---Response: Receive Orb Shop data from server
---@result: exchangeMaps: List{exchangeID, exchangeNum}
function ShopSpecialSystem:ResOpenOrbShop(result)
    self:EnsureShopOrbInAllShops()
    local _spContainer = self:GetShopItemContainer(SpecialShopPanelEnum.OrbShop)
    if _spContainer == nil then
        return
    end

    if result.exchangeMaps and #result.exchangeMaps > 0 then
        local _itemDic = _spContainer:GetShopItemDic()
        for _, exchange in ipairs(result.exchangeMaps) do
            local id = exchange.exchangeID
            local num = exchange.exchangeNum
            if _itemDic[id] then
                _itemDic[id]:SetCount(num)
            end
        end
    end

    local _pageId = 1
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SHOP_ORB_RESULT, _pageId, true)
end

---Request: Exchange Orb for a specific item
function ShopSpecialSystem:ReqExchangeOrb(itemId, itemNum)
    local _req = ReqMsg.MSG_Tinhchau.ReqBuyTinhChauExchange:New();
    _req.exchangeId = itemId
    _req.exchangeNum = itemNum
    _req:Send()
end

---Response: Receive result of Orb exchange from server
---@result: exchangeData: {exchangeID, exchangeNum}
function ShopSpecialSystem:ResExchangeOrb(result)
    local _spContainer = self:GetShopItemContainer(SpecialShopPanelEnum.OrbShop)
    if not _spContainer or not result or not result.exchangeData then
        return
    end

    local _itemDic = _spContainer:GetShopItemDic()

    local itemId = result.exchangeData.exchangeID
    local itemCount = result.exchangeData.exchangeNum
    if _itemDic[itemId] then
        _itemDic[itemId]:SetCount(itemCount)
    end

    local _pageId = 1
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SHOP_ORB_RESULT, _pageId, false)
end

--endregion [Network Requests & Responses]

return ShopSpecialSystem