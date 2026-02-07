local MSG_Universe = {}
local Network = GameCenter.Network

function MSG_Universe.RegisterMsg()
    Network.CreatRespond("MSG_Universe.ResUniverseWarPanel",function (msg)
        GameCenter.TerritorialWarSystem:ResUniverseWarPanel(msg)
    end)

    Network.CreatRespond("MSG_Universe.ResCareMonster",function (msg)
        GameCenter.TerritorialWarSystem:ResCareMonster(msg)
    end)

    Network.CreatRespond("MSG_Universe.ResSynAnger",function (msg)
        GameCenter.TerritorialWarSystem:ResSynAnger(msg)
    end)

    Network.CreatRespond("MSG_Universe.ResUpdateMonsterRefresh",function (msg)
        GameCenter.TerritorialWarSystem:ResUpdateMonsterRefresh(msg)
    end)

    Network.CreatRespond("MSG_Universe.G2PEnterDaily",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Universe.P2FOpenBlock",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Universe.ResDamageRank",function (msg)
        GameCenter.TerritorialWarSystem:ResDamageRank(msg)
    end)

    Network.CreatRespond("MSG_Universe.F2GResUniverseWarPanel",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Universe.G2PReqUniverseWarPanel",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Universe.P2FReqUniverseWarPanel",function (msg)
        --TODO
    end)

end
return MSG_Universe

