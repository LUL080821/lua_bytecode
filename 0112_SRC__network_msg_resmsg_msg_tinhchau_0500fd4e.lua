local MSG_Tinhchau = {}
local Network = GameCenter.Network

function MSG_Tinhchau.RegisterMsg()
    Network.CreatRespond("MSG_Tinhchau.ResOpenTinhChauExchange",function (msg)
        GameCenter.ShopSpecialSystem:ResOpenOrbShop(msg)
    end)

    Network.CreatRespond("MSG_Tinhchau.ResBuyTinhChauExchange",function (msg)
        GameCenter.ShopSpecialSystem:ResExchangeOrb(msg)
    end)

end
return MSG_Tinhchau