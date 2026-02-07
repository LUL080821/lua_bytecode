local MSG_NewFashion = {}
local Network = GameCenter.Network

function MSG_NewFashion.RegisterMsg()
    Network.CreatRespond("MSG_NewFashion.ResOnlineInitFashionInfo",function (msg)
        --TODO
        GameCenter.NewFashionSystem:ResOnlineInitFashionInfo(msg)
    end)

    Network.CreatRespond("MSG_NewFashion.ResSaveFashionResult",function (msg)
        --TODO
        GameCenter.NewFashionSystem:ResSaveFashionResult(msg)
    end)

    Network.CreatRespond("MSG_NewFashion.ResNewFashionBodyBroadcast",function (msg)
        --TODO
        GameCenter.NewFashionSystem:ResNewFashionBodyBroadcast(msg)
    end)


    Network.CreatRespond("MSG_NewFashion.ResFashionStarResult",function (msg)
        --TODO
        GameCenter.NewFashionSystem:ResFashionStarResult(msg)
    end)


    Network.CreatRespond("MSG_NewFashion.ResActiveTjResult",function (msg)
        --TODO
        GameCenter.NewFashionSystem:ResActiveTjResult(msg)
    end)


    Network.CreatRespond("MSG_NewFashion.ResTjStarResult",function (msg)
        --TODO
        GameCenter.NewFashionSystem:ResTjStarResult(msg)
    end)


    Network.CreatRespond("MSG_NewFashion.ResSaveFashionDoGiamResult",function (msg)
        --TODO
        GameCenter.NewFashionSystem:ResSaveFashionDoGiamResult(msg)
    end)


    Network.CreatRespond("MSG_NewFashion.ResFashionStarDoGiamResult",function (msg)
        --TODO
        GameCenter.NewFashionSystem:ResFashionStarDoGiamResult(msg)
    end)


    Network.CreatRespond("MSG_NewFashion.ResOnlineInitFashionDoGiamInfo",function (msg)
        --TODO
        GameCenter.NewFashionSystem:ResOnlineInitFashionDoGiamInfo(msg)
    end)

end
return MSG_NewFashion

