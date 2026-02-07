local MSG_TreasureHuntWuyou = {}
local Network = GameCenter.Network

function MSG_TreasureHuntWuyou.RegisterMsg()
    Network.CreatRespond("MSG_TreasureHuntWuyou.ResAllInfo",function (msg)
        GameCenter.TreasureHuntSystem:ResWuyouAllInfo(msg)
    end)

    Network.CreatRespond("MSG_TreasureHuntWuyou.ResOpenPanel",function (msg)
        GameCenter.TreasureHuntSystem:ResOpenWuyouPanel(msg)
    end)

    Network.CreatRespond("MSG_TreasureHuntWuyou.ResGetItem",function (msg)
        GameCenter.TreasureHuntSystem:ResGetItem(msg)
    end)

    Network.CreatRespond("MSG_TreasureHuntWuyou.ResHuntResult",function (msg)
        GameCenter.TreasureHuntSystem:ResWuyouHuntResult(msg)
    end)

    Network.CreatRespond("MSG_TreasureHuntWuyou.ResExtractResult",function (msg)
        --TODO
    end)

end
return MSG_TreasureHuntWuyou

