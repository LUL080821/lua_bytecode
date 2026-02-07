local MSG_AlienBoss = {}
local Network = GameCenter.Network

function MSG_AlienBoss.RegisterMsg()
    Network.CreatRespond("MSG_AlienBoss.ResCrossAlienCity",function (msg)
        --TODO
        GameCenter.CrossFuDiSystem:ResCrossAlienCity(msg)
    end)

    Network.CreatRespond("MSG_AlienBoss.ResCrossAlienBossList",function (msg)
        --TODO
        GameCenter.CrossFuDiSystem:ResCrossAlienBossList(msg)
    end)

    Network.CreatRespond("MSG_AlienBoss.ResCrossAlienBossDamageList",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_AlienBoss.G2PEnterCrossAlien",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_AlienBoss.G2PCrossAlienCity",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_AlienBoss.G2PEnterCrossAlienGem",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_AlienBoss.F2PCrossAlienBoss",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_AlienBoss.F2PCrossAlienBossDie",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_AlienBoss.P2FCrossAlienCityCapture",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_AlienBoss.P2FEnterCrossAlienGem",function (msg)
        --TODO
    end)

end
return MSG_AlienBoss

