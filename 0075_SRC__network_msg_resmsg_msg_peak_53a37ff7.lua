local MSG_Peak = {}
local Network = GameCenter.Network

function MSG_Peak.RegisterMsg()
    Network.CreatRespond("MSG_Peak.ResPeakRankList",function (msg)
        GameCenter.TopJjcSystem:ResPeakRankList(msg)
    end)

    Network.CreatRespond("MSG_Peak.ResPeakInfo",function (msg)
        GameCenter.TopJjcSystem:ResPeakInfo(msg)
    end)

    Network.CreatRespond("MSG_Peak.ResPeakStageInfo",function (msg)
        GameCenter.TopJjcSystem:ResPeakStageInfo(msg)
    end)

    Network.CreatRespond("MSG_Peak.ResPeakTimesResult",function (msg)
        GameCenter.TopJjcSystem:ResPeakTimesResult(msg)
    end)

    Network.CreatRespond("MSG_Peak.ResPeakStageResult",function (msg)
        GameCenter.TopJjcSystem:ResPeakStageResult(msg)
    end)

    Network.CreatRespond("MSG_Peak.ResPeakPkTimeInfo",function (msg)
        GameCenter.MapLogicSystem:OnMsgHandle(msg)
    end)

    Network.CreatRespond("MSG_Peak.ResPeakPkGameOverInfo",function (msg)
        GameCenter.MapLogicSystem:OnMsgHandle(msg)
    end)


    Network.CreatRespond("MSG_Peak.ResCancelPeakMatch",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Peak.ResPeakMatchRes",function (msg)
        GameCenter.TopJjcSystem:ResPeakMatchRes(msg)
    end)


    Network.CreatRespond("MSG_Peak.G2PEnterPeakMatch",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Peak.G2PCancelPeakMatch",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Peak.G2PPeakRankInfo",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Peak.G2PPeakStageInfo",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Peak.G2PPeakStageReward",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Peak.F2PPeakCloneResult",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Peak.P2GPeakCloneResult",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Peak.P2GPeakStageReward",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Peak.G2PPeakTimesReward",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Peak.P2GPeakTimesReward",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Peak.G2PPeakInfo",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Peak.ResUpdatePeakExp",function (msg)
        GameCenter.MapLogicSystem:OnMsgHandle(msg)
    end)

end
return MSG_Peak

