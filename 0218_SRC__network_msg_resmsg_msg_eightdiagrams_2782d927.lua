local MSG_EightDiagrams = {}
local Network = GameCenter.Network

function MSG_EightDiagrams.RegisterMsg()
    Network.CreatRespond("MSG_EightDiagrams.ResEightDiagramsPanel",function (msg)
        --TODO
        GameCenter.BaJiZhenSystem:ResEightDiagramsPanel(msg)
    end)

    Network.CreatRespond("MSG_EightDiagrams.ResRankPanel",function (msg)
        --TODO
        GameCenter.BaJiZhenSystem:ResRankPanel(msg)
    end)

    Network.CreatRespond("MSG_EightDiagrams.ResTickMapInfo",function (msg)
        --TODO
        GameCenter.BaJiZhenSystem:ResTickMapInfo(msg)
    end)


    Network.CreatRespond("MSG_EightDiagrams.P2FRepChangeCityMap",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_EightDiagrams.F2PResEnterMapSucc",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_EightDiagrams.F2PPlayerOutCity",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_EightDiagrams.F2PPlayerToBossHurt",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_EightDiagrams.F2PKillBoss",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_EightDiagrams.ResLastTime",function (msg)
        --TODO
        GameCenter.BaJiZhenSystem:ResLastTime(msg)
    end)


    Network.CreatRespond("MSG_EightDiagrams.P2GSendEightCityRward",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_EightDiagrams.F2PKillPlayer",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_EightDiagrams.P2FSendEightCityInfo",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_EightDiagrams.F2PSendOverCityInfo",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_EightDiagrams.G2PReqEightDiagramsPanel",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_EightDiagrams.G2PReqRankPanel",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_EightDiagrams.G2PReqEnterEightCityMap",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_EightDiagrams.G2PReqTickMapInfo",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_EightDiagrams.P2FReqRankPanel",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_EightDiagrams.G2FReqRankPanel",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_EightDiagrams.P2FReqTickRankPanel",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_EightDiagrams.P2FReqEightDiagramsPanel",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_EightDiagrams.G2FReqEightDiagramsPanel",function (msg)
        --TODO
    end)

end
return MSG_EightDiagrams

