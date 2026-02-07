local MSG_BravePeak = {}
local Network = GameCenter.Network

function MSG_BravePeak.RegisterMsg()
    Network.CreatRespond("MSG_BravePeak.F2GSendBravePeakReward",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_BravePeak.G2PGetPlayerBravePeakInfo",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_BravePeak.P2GPlayerBravePeakInfoResult",function (msg)
        --TODO
    end)

end
return MSG_BravePeak

