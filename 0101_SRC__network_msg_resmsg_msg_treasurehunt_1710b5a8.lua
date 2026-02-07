local MSG_TreasureHunt = {}
local Network = GameCenter.Network

function MSG_TreasureHunt.RegisterMsg()
    Network.CreatRespond("MSG_TreasureHunt.ResTreasureResult",function (msg)
        GameCenter.TreasureHuntSystem:ResTreasureResult(msg)
    end)

    Network.CreatRespond("MSG_TreasureHunt.ResBuyResult",function (msg)
        GameCenter.TreasureHuntSystem:ResBuyResult(msg)
    end)

    Network.CreatRespond("MSG_TreasureHunt.ResOnekeyExtractResult",function (msg)
        GameCenter.TreasureHuntSystem:ResOnekeyExtractResult(msg)
    end)

    Network.CreatRespond("MSG_TreasureHunt.ResUpdateRecord",function (msg)
        GameCenter.TreasureHuntSystem:ResUpdateRecord(msg)
    end)

    Network.CreatRespond("MSG_TreasureHunt.ResAllWarehouseInfo",function (msg)
        GameCenter.TreasureHuntSystem:ResAllWarehouseInfo(msg)
    end)

    Network.CreatRespond("MSG_TreasureHunt.ResNoticeReward",function (msg)
        GameCenter.TreasureHuntSystem:ResNoticeReward(msg)
    end)

    Network.CreatRespond("MSG_TreasureHunt.ResRewardResultPanle",function (msg)
        GameCenter.TreasureHuntSystem:ResRewardResultPanle(msg)
    end)


    Network.CreatRespond("MSG_TreasureHunt.ResRecoveryResult",function (msg)
        GameCenter.TreasureHuntSystem:ResRecoveryResult(msg)
    end)


    Network.CreatRespond("MSG_TreasureHunt.ResFreeTreasureTime",function (msg)
        --TODO
        GameCenter.TreasureHuntSystem:ResFreeTreasureTime(msg)
    end)

end
return MSG_TreasureHunt

