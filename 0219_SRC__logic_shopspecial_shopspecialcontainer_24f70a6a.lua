------------------------------------------------
-- Author:
-- Date: 2025-11-05
-- File: ShopSpecialContainer.lua
-- Module: ShopSpecialContainer
-- Description: Containers of various stores, including all basic store operations and data
------------------------------------------------

local ShopSpecialContainer = {
    -- Store Type
    ShopType      = nil,
    -- Item container (Dictionary<page, Dictionary<key, item>>)
    ItemContainer = nil,
    -- Store Page Container
    ShopPageList  = nil,
    -- Whether this shop uses sub pages
    HasSubPage    = true,
    -- Function to determine item key (customizable)
    KeyFunc       = nil,
    -- Function to sort items (customizable)
    SortFunc      = nil,
}

------------------------------------------------------------------------------------------------------------------------
--region [Init & Config]
-- Initialization, setup, and preloading data
-- ---------------------------------------------------------------------------------------------------------------------

---Create a container object
---@param type: store type (enum or id)
---@param hasSubPage : whether this shop has sub pages
---@param keyFunc    : (optional) function(item) -> key
---@param sortFunc   : (optional) function(item) -> condition
function ShopSpecialContainer:New(type, hasSubPage, keyFunc, sortFunc)
    local _m = Utils.DeepCopy(self)
    _m.ShopType = type
    _m.HasSubPage = (hasSubPage ~= false)-- default = true
    _m.ItemContainer = Dictionary:New()
    _m.ShopPageList = List:New()

    -- Custom key generator (default: item:GetID())
    _m.KeyFunc = keyFunc or function(item)
        return item:GetID()
    end

    -- Custom sort function (default: by Index ascending)
    _m.SortFunc = sortFunc or nil
    --function(a, b)
    --    return (a.Index or 0) < (b.Index or 0)
    --end

    return _m
end

---Normalizes page safely:
--- * If no subpage: always return 1
--- * If has subpage but page is nil/invalid: return nil
local function NormalizePage(self, page)
    if not self.HasSubPage then return 1 end
    if page == nil then return nil end
    return page
end

--endregion [Init & Config]

------------------------------------------------------------------------------------------------------------------------
--region [Access & Data Handling]
-- Internal data management and access (get/set, update, delete)
-- ---------------------------------------------------------------------------------------------------------------------

---Update or add an item to a specific page
function ShopSpecialContainer:UpdateItem(item, page)
    if not item then return end

    local _page = NormalizePage(self, page)
    if _page == nil then
        --Debug.LogError("[LDebug] [ShopOrbContainer]", string.format(
        --        "Invalid page access: ShopType = %s, page = %s.",
        --        tostring(self.ShopType), tostring(page)
        --))
        return
    end

    local _shopItems = self.ItemContainer[_page]
    if not _shopItems then
        _shopItems = Dictionary:New()
        self.ItemContainer:Add(_page, _shopItems)
    end
    local _key = self.KeyFunc(item)
    if _shopItems:ContainsKey(_key) then
        _shopItems[_key] = item
    else
        _shopItems:Add(_key, item)
    end
end

---Delete item in page
function ShopSpecialContainer:DeleteItem(key, page)
    local _page = NormalizePage(self, page)
    if _page == nil then return end

    if self.ItemContainer:ContainsKey(_page) then
        self.ItemContainer[_page]:Remove(key)
    end
end

---Clear all items in the given page
function ShopSpecialContainer:ClearShopByPage(page)
    local _page = NormalizePage(self, page)
    if _page == nil then return end

    if self.ItemContainer:ContainsKey(_page) then
        self.ItemContainer[_page]:Clear()
    end
end

function ShopSpecialContainer:ClearAll()
    self.ItemContainer:Clear()
    self.ShopPageList:Clear()
end

---Sort all items in the given page using Dictionary:SortValue()
---@param page      : page index
---@param sortFunc  : optional custom sort function(a,b)
function ShopSpecialContainer:Sort(page, sortFunc)
    local _page = NormalizePage(self, page)
    if _page == nil then return end

    if not self.ItemContainer:ContainsKey(_page) then return end
    local _shopItems = self.ItemContainer[_page]
    if not _shopItems then return end

    -- Use Dictionary built-in sort
    local _func = sortFunc or self.SortFunc
    if not _func then
        return
    end
    _shopItems:SortValue(_func)
end

---Get dictionary of items by page
---Always returns a valid Dictionary (empty if not exist)
function ShopSpecialContainer:GetShopItemDic(page)
    local _page = NormalizePage(self, page)
    if _page == nil then
        return Dictionary:New()
    end

    local _shopItems = Dictionary:New()
    if self.ItemContainer:ContainsKey(_page) then
        _shopItems = self.ItemContainer[_page]
    end
    return _shopItems
end

---Add a sub page
function ShopSpecialContainer:AddShopPage(page)
    if page > 0 and not self.ShopPageList:Contains(page) then
        self.ShopPageList:Add(page)
    end
end

---Remove a sub page
function ShopSpecialContainer:RemoveShopPage(page)
    if not page or page <= 0 then return end

    self:ClearShopByPage(page)
    if self.ItemContainer:ContainsKey(page) then
        self.ItemContainer:Remove(page)
    end
    -- Xóa page khỏi container và danh sách
    if self.ShopPageList:Contains(page) then
        self.ShopPageList:Remove(page)
    end
end

--endregion [Access & Data Handling]

return ShopSpecialContainer