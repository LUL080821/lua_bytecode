local MSG_SoulAnimalForest = {}
local Network = GameCenter.Network

function MSG_SoulAnimalForest.RegisterMsg()
    Network.CreatRespond("MSG_SoulAnimalForest.ResSoulAnimalForestLocalPanel",function (msg)
        GameCenter.SoulMonsterSystem:ResSoulAnimalForestLocalPanel(msg)
    end)

    Network.CreatRespond("MSG_SoulAnimalForest.ResSoulAnimalForestLocalRefreshInfo",function (msg)
        GameCenter.SoulMonsterSystem:ResSoulAnimalForestLocalRefreshInfo(msg)
        GameCenter.SoulMonsterSystem:ReqSoulAnimalForestLocalPanel()
    end)

    Network.CreatRespond("MSG_SoulAnimalForest.ResSoulAnimalForestLocalBossRefreshTip",function (msg)
        GameCenter.SoulMonsterSystem:ResSoulAnimalForestLocalBossRefreshTip(msg)
    end)

    Network.CreatRespond("MSG_SoulAnimalForest.ResSoulAnimalForestCrossPanel",function (msg)
        GameCenter.SoulMonsterSystem:ResSoulAnimalForestLocalPanel(msg)
    end)

    Network.CreatRespond("MSG_SoulAnimalForest.ResSoulAnimalForestCrossRefreshInfo",function (msg)
        GameCenter.SoulMonsterSystem:ResSoulAnimalForestLocalRefreshInfo(msg)
        GameCenter.SoulMonsterSystem:ReqSoulAnimalForestCrossPanel()
    end)

    Network.CreatRespond("MSG_SoulAnimalForest.ResFollowSoulAnimalForestCrossBoss",function (msg)
        GameCenter.SoulMonsterSystem:ResFollowBoss(msg)
    end)

    Network.CreatRespond("MSG_SoulAnimalForest.P2GResSoulAnimalForestCrossBossRefreshTip",function (msg)
    end)

    Network.CreatRespond("MSG_SoulAnimalForest.ResSoulAnimalForestCrossBossRefreshTip",function (msg)
        GameCenter.SoulMonsterSystem:ResSoulAnimalForestLocalBossRefreshTip(msg)
    end)

    Network.CreatRespond("MSG_SoulAnimalForest.P2FResSoulAnimalForestBossInfo",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_SoulAnimalForest.P2FResCloneMonsterDie",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_SoulAnimalForest.P2FUpdateOneSoulAnimalForestBossInfo",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_SoulAnimalForest.F2PUpdateOneSoulAnimalForestBossInfo",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_SoulAnimalForest.F2PSoulAnimalCloneOpen",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_SoulAnimalForest.ResCrossSoulAnimalForestBossKiller",function (msg)
        GameCenter.SoulMonsterSystem:ResBossKilledInfo(msg)
    end)


    Network.CreatRespond("MSG_SoulAnimalForest.G2PReqSoulAnimalForestCrossPanel",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_SoulAnimalForest.G2PReqFollowSoulAnimalForestCrossBoss",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_SoulAnimalForest.F2PReqSoulAnimalForestBossInfo",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_SoulAnimalForest.F2PReqCloneMonsterDie",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_SoulAnimalForest.G2PReqCrossSoulAnimalForestBossKiller",function (msg)
        --TODO
    end)

end
return MSG_SoulAnimalForest

