local MSG_Shop = {
    shopItemInfo = {
       sellId = 0,
       itemId = 0,
       shopId = 0,
       labelId = 0,
       level = 0,
       guildLevel = 0,
       militaryRankLevel = 0,
       vipLevel = 0,
       limitType = 0,
       buyLimit = 0,
       coinType = 0,
       coinNum = 0,
       originalCoinNum = 0,
       discount = 0,
       hot = 0,
       sort = 0,
       lostTime = "",
       duration = 0,
       bind = 0,
       refreshCurrency = 0,
       refreshNum = 0,
       shopType = "",
       guildShopLvlStart = 0,
       guildShopLvlEnd = 0,
       worldlvlstart = 0,
       worldlvlend = 0,
       isdiscount = 0,
       countdiscount = "",
    },
    ShopData = {
       sellId = 0,
       buyNum = 0,
    },
    shopSubMess = {
       shopId = 0,
       labelList = List:New(),
    },
    ReqShopSubList = {
    },
    ReqShopList = {
       shopId = 0,
       labelId = 0,
       gradeLimit = 0,
    },
    ReqBuyItem = {
       sellId = 0,
       num = 0,
    },
    ReqRefreshShop = {
       shopId = 0,
       labelId = 0,
    },
    LimitShop = {
       id = 0,
       endTime = 0,
       isOverTime = false,
    },
    ReqLimitBuy = {
       id = 0,
    },
    ReqMysteryShopBuy = {
       id = 0,
    },
    FreeShopData = {
       id = 0,
       isGet = false,
       buyTime = 0,
    },
    ReqFreeShop = {
       id = 0,
       type = 0,
    },
    BuyInfo = {
       name = "",
       type = 0,
       id = 0,
    },
    ReqBuyNewFreeShop = {
       id = 0,
       type = 0,
    },
    ReqOpenNewFreeShop = {
    },
}
local L_StrDic = {
    [MSG_Shop.ReqShopSubList] = "MSG_Shop.ReqShopSubList",
    [MSG_Shop.ReqShopList] = "MSG_Shop.ReqShopList",
    [MSG_Shop.ReqBuyItem] = "MSG_Shop.ReqBuyItem",
    [MSG_Shop.ReqRefreshShop] = "MSG_Shop.ReqRefreshShop",
    [MSG_Shop.ReqLimitBuy] = "MSG_Shop.ReqLimitBuy",
    [MSG_Shop.ReqMysteryShopBuy] = "MSG_Shop.ReqMysteryShopBuy",
    [MSG_Shop.ReqFreeShop] = "MSG_Shop.ReqFreeShop",
    [MSG_Shop.ReqBuyNewFreeShop] = "MSG_Shop.ReqBuyNewFreeShop",
    [MSG_Shop.ReqOpenNewFreeShop] = "MSG_Shop.ReqOpenNewFreeShop",
}
local L_SendDic = setmetatable({},{__mode = "k"});

local mt = {}
mt.__index = mt
function mt:New()
    local _str = L_StrDic[self]
    local _clone = Utils.DeepCopy(self)
    L_SendDic[_clone] = _str
    return _clone
end
function mt:Send()
    GameCenter.Network.Send(L_SendDic[self], self)
end

for k,v in pairs(L_StrDic) do
    setmetatable(k, mt)
end

return MSG_Shop

