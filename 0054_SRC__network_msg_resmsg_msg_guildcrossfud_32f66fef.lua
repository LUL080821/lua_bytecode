local MSG_GuildCrossFud = {}
local Network = GameCenter.Network

function MSG_GuildCrossFud.RegisterMsg()
    Network.CreatRespond("MSG_GuildCrossFud.ResAllCrossFudInfo",function (msg)
        --TODO
        GameCenter.CrossFuDiSystem:ResAllCrossFudInfo(msg)
    end)

    Network.CreatRespond("MSG_GuildCrossFud.ResUpdateCrossFudScoreBox",function (msg)
        --TODO
        GameCenter.CrossFuDiSystem:ResUpdateCrossFudScoreBox(msg)
    end)

    Network.CreatRespond("MSG_GuildCrossFud.ResUpdateCrossFudBox",function (msg)
        --TODO
        GameCenter.CrossFuDiSystem:ResUpdateCrossFudBox(msg)
    end)

    Network.CreatRespond("MSG_GuildCrossFud.ResCrossFudCityInfo",function (msg)
        --TODO
        GameCenter.CrossFuDiSystem:ResCrossFudCityInfo(msg)
    end)

    Network.CreatRespond("MSG_GuildCrossFud.ResCrossFudRankInfo",function (msg)
        --TODO
        GameCenter.CrossFuDiSystem:ResCrossFudRankInfo(msg)
    end)

    Network.CreatRespond("MSG_GuildCrossFud.ResCrossFudReport",function (msg)
        --TODO
        GameCenter.CrossFuDiSystem:ResCrossFudReport(msg)
    end)

    Network.CreatRespond("MSG_GuildCrossFud.ResCrossFudBossReport",function (msg)
        --TODO
        GameCenter.CrossFuDiSystem:ResCrossFudBossReport(msg)
    end)

    Network.CreatRespond("MSG_GuildCrossFud.ResCrossFudOwnerNotice",function (msg)
        --TODO
        GameCenter.CrossFuDiSystem:ResCrossFudOwnerNotice(msg)
    end)


    Network.CreatRespond("MSG_GuildCrossFud.ResCrossFudCareBoss",function (msg)
        --TODO
        GameCenter.CrossFuDiSystem:ResCrossFudCareBoss(msg)
    end)


    Network.CreatRespond("MSG_GuildCrossFud.G2PAllCrossFudInfo",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_GuildCrossFud.G2PCrossFudUnLockScoreBox",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_GuildCrossFud.G2PCrossFudScoreBoxOpen",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_GuildCrossFud.G2PCrossFudBoxOpen",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_GuildCrossFud.G2PCrossFudCityInfo",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_GuildCrossFud.G2PCrossFudRank",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_GuildCrossFud.G2PCrossFudCareBoss",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_GuildCrossFud.F2PCrossFudInfo",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_GuildCrossFud.G2PCrossFudEnter",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_GuildCrossFud.P2GCrossFudBoxUnLock",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_GuildCrossFud.P2GCrossFudScoreBoxOpen",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_GuildCrossFud.P2GCrossFudReward",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_GuildCrossFud.P2GCrossFudProcess",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_GuildCrossFud.F2PCrossFudGain",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_GuildCrossFud.P2GCrossFudOwnerNotice",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_GuildCrossFud.ResCrossFudCareBossRefresh",function (msg)
        --TODO
        GameCenter.CrossFuDiSystem:ResCrossFudCareBossRefresh(msg)
    end)


    Network.CreatRespond("MSG_GuildCrossFud.ResDevilBossList",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_GuildCrossFud.G2PDevilBossList",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_GuildCrossFud.G2PSyncRoomInfo",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_GuildCrossFud.ResUpdateTJValue",function (msg)
        --TODO
        GameCenter.CrossFuDiSystem:ResUpdateTJValue(msg)
    end)


    Network.CreatRespond("MSG_GuildCrossFud.F2PKillFudBoss",function (msg)
        --TODO
    end)

end
return MSG_GuildCrossFud

