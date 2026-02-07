local MSG_StateVip = {}
local Network = GameCenter.Network

function MSG_StateVip.RegisterMsg()
    Network.CreatRespond("MSG_StateVip.ResGetReward",function (msg)
    end)

    Network.CreatRespond("MSG_StateVip.ResStateVip",function (msg)
    end)

    Network.CreatRespond("MSG_StateVip.ResStateVipBroadcast",function (msg)
    end)

    Network.CreatRespond("MSG_StateVip.ResStateVipGiftList",function (msg)
    end)

    Network.CreatRespond("MSG_StateVip.ResDelStateVipGift",function (msg)
    end)


    Network.CreatRespond("MSG_StateVip.ResCurrStateVipGift",function (msg)
    end)


    Network.CreatRespond("MSG_StateVip.ResPurStateVipGift",function (msg)
    end)


    Network.CreatRespond("MSG_StateVip.ResExpData",function (msg)
    end)


    Network.CreatRespond("MSG_StateVip.ResStateVipProgress",function (msg)
        --TODO
    end)

end
return MSG_StateVip

