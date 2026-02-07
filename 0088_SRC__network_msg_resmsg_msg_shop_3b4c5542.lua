local MSG_Shop = {}
local Network = GameCenter.Network

function MSG_Shop.RegisterMsg()
    Network.CreatRespond("MSG_Shop.ResShopItemList",function (msg)
        GameCenter.ShopSystem:GS2U_ResShopItemList(msg)
    end)

    Network.CreatRespond("MSG_Shop.ResBuySuccess",function (msg)
        GameCenter.ShopSystem:GS2U_ResBuySuccess(msg)
    end)

    Network.CreatRespond("MSG_Shop.ResBuyFailure",function (msg)
        GameCenter.ShopSystem:ResBuyFailure(msg)
    end)

    Network.CreatRespond("MSG_Shop.ResShopSubList",function (msg)
        GameCenter.ShopSystem:GS2U_ResShopSubList(msg)
    end)

    Network.CreatRespond("MSG_Shop.ResFreshItemInfo",function (msg)
        GameCenter.ShopSystem:ResFreshItemInfo(msg)
    end)

    Network.CreatRespond("MSG_Shop.SyncLimitShop",function (msg)
        GameCenter.LimitShopSystem:SyncLimitShop(msg);
    end)


    Network.CreatRespond("MSG_Shop.SyncShopData",function (msg)
        GameCenter.ShopSystem:SyncShopData(msg)
    end)


    Network.CreatRespond("MSG_Shop.SyncMysteryShop",function (msg)
        --TODO
        GameCenter.MysteryShopSystem:SyncMysteryShop(msg)
    end)


    Network.CreatRespond("MSG_Shop.SyncFreeShopResult",function (msg)
        --TODO
        GameCenter.WelfareSystem:SyncFreeShopResult(msg)
    end)


    Network.CreatRespond("MSG_Shop.SyncOnlineInitFreeShop",function (msg)
        --TODO
        GameCenter.WelfareSystem:SyncOnlineInitFreeShop(msg)
    end)


    Network.CreatRespond("MSG_Shop.SyncBuyNewFreeShopResult",function (msg)
        --TODO
        GameCenter.ZeroBuySystem:SyncBuyNewFreeShopResult(msg)
    end)


    Network.CreatRespond("MSG_Shop.SyncOnlineInitNewFreeShop",function (msg)
        --TODO
        GameCenter.ZeroBuySystem:SyncOnlineInitNewFreeShop(msg)
    end)


    Network.CreatRespond("MSG_Shop.ResOpenNewFreeShopResult",function (msg)
        --TODO
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_ZEROBUY_RECORD_FORM, msg)
    end)

end
return MSG_Shop

