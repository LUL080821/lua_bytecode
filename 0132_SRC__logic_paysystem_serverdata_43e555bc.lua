------------------------------------------------
-- Author: 
-- Date: 2019-05-13
-- File: ServerData.lua
-- Module: ServerData
-- Description: The data in the recharge system data table is distributed by the server, and this data is the data distributed by the server
------------------------------------------------
local RuntimePlatform = CS.UnityEngine.RuntimePlatform

local ServerData =
{
    -- Product ID
    Id = 0,
    -- Configuration table ID
    CfgId = 0,
    -- Product name description (mainly used for BI background data)
    Desc = "",
    -- The payment type required by the SDK
    GoodsDealType = 0,
    -- Recharge type: 1 Normal recharge, 2 Daily gift package recharge... etc. See the configuration table for details
    RechargeType = 0,
    -- Only use for Type=1 (normal recharge).
    RechargeSubType = 0,
    -- Number of recharges
    RechargeTime = 0,
    -- The icon displayed
    Icon = 0,
    -- The real currency consumed corresponding to the recharge gear (unit: points)
    Money = 0,
    -- The amount of recharge passed to the SDK
    SDKPrice = 0,
    -- Corresponding rewards Item type_quantity_binding_profession
    Reward = 0,
    -- Recharge multiple multiples_number of times (3_2 means that the first two recharges are 3 times rewards)-1 means unlimited times
    MultipleTime = 0,
    -- Additional bonus
    ExtraReward = 0,
    -- The number of extra rewards available - 1 means unlimited times
    ExtraRewardTime = 0,
    -- Product Extension Field
    GoodsExt = "",
    CurPlatform = nil,
}

function ServerData:New(sData)
    local _m = Utils.DeepCopy(self)
    _m.CurPlatform = LogicAdaptor.GetRuntimePlatform()
    _m:RefeshData(sData)
    return _m
end

function ServerData:RefeshData(sData)
    -- ID passed to the SDK
    self.Id              = sData.goods_id
    -- Configuration table ID
    self.CfgId = sData.goods_system_cfg_id
    -- Product name description (mainly used for BI background data)
    self.Desc = sData.goods_name
    -- Transaction Type
    self.GoodsDealType = sData.goods_pay_channel
    -- * Recharge type
    -- * 1: Normal recharge
    -- * 2: Daily gift pack recharge
    -- * 3: Travel the moon card
    -- * 4: Exclusive monthly card
    -- * 5: Lifetime Card
    -- * 6: Growth Fund
    -- * 7: Mysterious Store
    -- * 8:0 yuan purchase
    -- * 9: Direct purchase gift package (excellent discount)
    -- * 10: Carnival Week
    -- * 11: Operation activity category (backend configuration)
    self.RechargeType = tonumber(sData.goods_type)
    -- * Only used for Type=1 (normal recharge) situation, other types cannot be used
    -- * 1=Normal recharge
    -- * 2=Newbie Gift Pack (Once in a Lifetime)
    -- * 3=Weekly gift pack (refreshed every week)
    -- * 4=Daily gift pack (refreshed every day)
    self.RechargeSubType = sData.goods_subtype
    -- * Number of recharges (the number of recharges corresponding to each gear in the current wheel)
    -- * -1=No limit on the number of times
    self.RechargeTime = sData.goods_limit
    -- * The ID of the displayed icon (hide)
    self.Icon = sData.goods_icon
    -- * The real currency consumed corresponding to the recharge gear (unit: minutes)
    -- * 1：android
    -- * 2：ios
    -- * (No case sensitivity is required)
    local _price = sData.goods_price

    if CS.UnityEngine.Application.platform == RuntimePlatform.Android then
        local _priceDict = Dictionary:New(_price.android)
        if _priceDict:ContainsKey(GameCenter.PaySystem.SdkPlatCfg.MoneyCode) then
            local _priceByMoneyCode = tonumber(_priceDict[GameCenter.PaySystem.SdkPlatCfg.MoneyCode])
            self.Money    = tonumber(_priceByMoneyCode / 100)
            self.SDKPrice = tonumber(_priceByMoneyCode)
        end
    else
        local _priceDict = Dictionary:New(_price.ios)
        if _priceDict:ContainsKey(GameCenter.PaySystem.SdkPlatCfg.MoneyCode) then
            local _priceByMoneyCode = tonumber(_priceDict[GameCenter.PaySystem.SdkPlatCfg.MoneyCode])
            self.Money    = tonumber(_priceByMoneyCode / 100)
            self.SDKPrice = tonumber(_priceByMoneyCode)
        end
    end
    -- * Corresponding rewards
    -- * Item type_quantity_binding_profession
    -- * Bind 0 Not bound 1 Bind
    -- * Also only 0 male sword 1 female gun 9 universal
    self.Reward = sData.goods_reward
    -- * Recharge multiple
    -- * Multiple_Number of times (3_2 means that the first 2 recharges are all 3 times the reward)
    -- * -1 represents infinite times
    self.MultipleTime = sData.goods_multiple
    -- * Additional gift
    -- * Item type_quantity_binding_profession
    -- * Bind 0 Not bound 1 Bind
    -- * Also only 0 male sword 1 female gun 9 universal
    self.ExtraReward = sData.goods_extra_reward
    -- * Number of additional rewards available -1 means unlimited
    self.ExtraRewardTime = sData.goods_extra_reward_limit
    -- Product extension fields
    self.GoodsExt = sData.goods_ext
end

return ServerData
