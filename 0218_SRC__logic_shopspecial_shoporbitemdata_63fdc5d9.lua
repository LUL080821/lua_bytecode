------------------------------------------------
-- Author:
-- Date: 2025-11-05
-- File: ShopOrbItem.lua
-- Module: ShopOrbItem
-- Description: Data model for Orb Shop items
--[[==============================================================
#region [IShopItemData] — Interface Convention
    Interface quy ước cho tất cả loại Shop Item Data.
    Required Methods:
        GetID()→ number -- Trả về ID cấu hình (CfgId)
        GetItemData(occ)        ->  Trả về thông tin vật phẩm hiển thị            
        GetCostData()           ->  Trả về thông tin vật phẩm tiêu hao
        GetCount()              ->  Số lần đã đổi / đã mua / đã nhận
        GetAllCount()           ->  Giới hạn tổng số lần đổi / mua
        SetCount(count: number) ->  Thiết lập lại số lượt đã dùng (client update)
#endregion
==============================================================]]
------------------------------------------------

local ShopOrbItemData = {
    CfgId     = 0,
    Cfg       = nil,

    CurCount  = 0, -- Redeemed several times
    AllCount  = 0, -- Total redemption times
    ItemData  = nil,
    CostData  = nil,
    IsWarning = false, -- Is it a reminder
}

------------------------------------------------------------------------------------------------------------------------
--region [Init & Config]
-- Initialization, setup, and preloading data
-- ---------------------------------------------------------------------------------------------------------------------
function ShopOrbItemData:New(k, v)
    local _m = Utils.DeepCopy(self)
    _m.CfgId = k
    _m.Cfg = v
    return _m
end

--endregion [Init & Config]

------------------------------------------------------------------------------------------------------------------------
--region [Public API / Getters & Setters]
-- Methods callable from outside (other systems or UI)
-- ---------------------------------------------------------------------------------------------------------------------

-- Get ItemID
function ShopOrbItemData:GetID()
    return self.CfgId
end

-- Get display prop data
function ShopOrbItemData:GetItemData(occ)
    if self.ItemData ~= nil then
        return self.ItemData
    end

    if self.Cfg and self.Cfg.Reward then
        local _rewards = Utils.SplitStr(self.Cfg.Reward, ';')
        for i = 1, #_rewards do
            local parts = Utils.SplitNumber(_rewards[i], '_')
            if (parts and #parts >= 4) and (parts[4] == occ or parts[4] == 9) then
                self.ItemData = { Id = parts[1], Num = parts[2], IsBind = parts[3] == 1 }
                break
            end
        end
    end
    return self.ItemData
end

-- Get consumed item data
function ShopOrbItemData:GetCostData()
    if self.CostData ~= nil then
        return self.CostData
    end

    if self.Cfg and self.Cfg.Need then
        local parts = Utils.SplitNumber(self.Cfg.Need, '_')
        if (parts and #parts >= 2) then
            self.CostData = { Id = parts[1], Num = parts[2] }
        end
    end
    return self.CostData
end

-- Get the total redemption times
function ShopOrbItemData:GetAllCount()
    if not self.AllCount or self.AllCount == 0 then
        if self.Cfg and self.Cfg.ExchangeLimit then
            self.AllCount = self.Cfg.ExchangeLimit
        else
            self.AllCount = 0  -- fallback nếu field không tồn tại
        end
    end
    return self.AllCount
end

-- Set the number of redemptions
function ShopOrbItemData:SetCount(count)
    self.CurCount = count
end

-- How many times have I received it?
function ShopOrbItemData:GetCount()
    return self.CurCount
end

--endregion [Public API / Getters & Setters]

return ShopOrbItemData