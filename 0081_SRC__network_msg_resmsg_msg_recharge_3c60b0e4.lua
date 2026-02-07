local MSG_Recharge = {}
local Network = GameCenter.Network

function MSG_Recharge.RegisterMsg()
    -- The total value of the player's current recharge
    Network.CreatRespond("MSG_Recharge.ResRechargeTotalValue",function (msg)
        GameCenter.PaySystem:ResRechargeTotalValue(msg)
    end)

    -- Return the recharge data
    Network.CreatRespond("MSG_Recharge.ResRechargeData",function (msg)
        GameCenter.PaySystem:ResRechargeData(msg)
    end)


    Network.CreatRespond("MSG_Recharge.ResDiscountRechargeData",function (msg)
        if msg.type and msg.type == 1 then
            GameCenter.LimitDicretShopMgr2:ResDiscountRechargeData(msg)
        else
            GameCenter.LimitDicretShopMgr:ResDiscountRechargeData(msg)
        end
    end)


    Network.CreatRespond("MSG_Recharge.ResCheckGoodsResult",function (msg)
        GameCenter.PaySystem:ResCheckGoodsResult(msg)
    end)


    Network.CreatRespond("MSG_Recharge.ResRechargeItems",function (msg)
        GameCenter.PaySystem:ResRechargeItems(msg)
    end)


    Network.CreatRespond("MSG_Recharge.ResCheckDiscRechargeGoods",function (msg)
        --TODO
        GameCenter.ServeCrazySystem:ResCheckDiscRechargeGoods(msg)
    end)

end
return MSG_Recharge

