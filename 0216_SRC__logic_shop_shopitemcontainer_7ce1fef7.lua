------------------------------------------------
-- Author:
-- Date: 2019-07-05
-- File: ShopItemContainer.lua
-- Module: ShopItemContainer
-- Description: Containers of various stores, including all basic store operations and data
------------------------------------------------

local ShopItemContainer = {
    -- Store Type
    ShopType = nil,
    -- Item container
    ItemContainer = nil,
    -- Store Page Container
    ShopPageList = nil,
    -- Next refresh time
    NextTimes = nil,
    -- Current number of refreshes
    CurUpdateTimes = nil,
}

-- Create a container object
function ShopItemContainer:New(type)
    local _m = Utils.DeepCopy(self)
    _m.ShopType = type
    _m.ItemContainer = Dictionary:New()
    _m.ShopPageList = List:New()
    return _m
end

-- Update product containers
function ShopItemContainer:UpdateItem(item, page, occ)
    if item ~= nil then
        local _shopItems = nil
        _shopItems = self.ItemContainer[page]
        if _shopItems == nil then
            _shopItems = Dictionary:New()
            self.ItemContainer:Add(page, _shopItems)
        end
        if _shopItems ~= nil and item:CheckOcc(occ) and item:CheckOpenTime() then
            local _tmpItem = nil;
            _tmpItem = _shopItems[item.SellId]
            if _tmpItem ~= nil then
                _shopItems[item.SellId] = item
            else
                _shopItems:Add(item.SellId, item)
            end
            self.ItemContainer[page] = _shopItems
        end
    end
end

function ShopItemContainer:Sort(page)
    local _shopItems = nil
    _shopItems = self.ItemContainer[page]
    if _shopItems ~= nil then
        for k, v in pairs(_shopItems) do
            if v.LimitType > 0 then
                if v.AlreadyBuyNum >= v.BuyLimit and v.BuyLimit > 0 and v.Index <= 99999 then
                    v.Index = v.Index + 99999
                end
            end
        end
        _shopItems:SortValue(function(a, b)
            return a.Index < b.Index
        end)
        self.ItemContainer[page] = _shopItems
    end
end

-- Delete the product
function ShopItemContainer:DeleteItem(key, page)
    if self.ItemContainer[page] ~= nil then
        self.ItemContainer[page]:Remove(key)
    end
end

function ShopItemContainer:AddShopPage(page)
    if page > 0 and not self.ShopPageList:Contains(page) then
        self.ShopPageList:Add(page)
    end
end

function ShopItemContainer:ClearShopPage()
    self.ShopPageList:Clear()
end

function ShopItemContainer:ClearShopByPage(page)
    if self.ItemContainer:ContainsKey(page) then
        self.ItemContainer[page]:Clear()
    end
end

function ShopItemContainer:GetShopItemDic(page)
    local _shopItems = Dictionary:New()
    if self.ItemContainer:ContainsKey(page) then
        _shopItems = self.ItemContainer[page]
    end
    return _shopItems
end
return ShopItemContainer