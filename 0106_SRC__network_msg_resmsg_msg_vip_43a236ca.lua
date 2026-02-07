local MSG_Vip = {}
local Network = GameCenter.Network

function MSG_Vip.RegisterMsg()
    Network.CreatRespond("MSG_Vip.ResVipReward",function (msg)
        --TODO
        GameCenter.VipSystem:ResVipReward(msg)
    end)

    Network.CreatRespond("MSG_Vip.ResVipRechageMoney",function (msg)
        --TODO
        GameCenter.VipSystem:ResVipRechageMoney(msg)
    end)


    Network.CreatRespond("MSG_Vip.ResVipRechageRewardList",function (msg)
        --TODO
        GameCenter.VipSystem:ResVipRechageRewardList(msg)
    end)


    Network.CreatRespond("MSG_Vip.ResVipRechargeReward",function (msg)
        --TODO
        GameCenter.VipSystem:ResVipRechargeReward(msg)
    end)


    Network.CreatRespond("MSG_Vip.ResVipRed",function (msg)
        --TODO
        GameCenter.VipSystem:ResVipRed(msg)
    end)


    Network.CreatRespond("MSG_Vip.ResVipPurGift",function (msg)
        --TODO
        GameCenter.VipSystem:ResVipPurGift(msg)
    end)


    Network.CreatRespond("MSG_Vip.ResVip",function (msg)
        --TODO
        GameCenter.VipSystem:ResVip(msg)
    end)


    Network.CreatRespond("MSG_Vip.ResVipExpChange",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Vip.ResSpecialVipStateInfo",function (msg)
        --TODO
        GameCenter.VipSystem:ResSpecialVipStateInfo(msg)
    end)


    Network.CreatRespond("MSG_Vip.ResVipPearlInfo",function (msg)
        --TODO
        GameCenter.VipSystem:ResVipPearlInfo(msg)
    end)

end
return MSG_Vip

