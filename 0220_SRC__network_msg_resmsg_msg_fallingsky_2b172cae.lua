local MSG_FallingSky = {}
local Network = GameCenter.Network

function MSG_FallingSky.RegisterMsg()
    Network.CreatRespond("MSG_FallingSky.ResOnlineFallSkyInfo",function (msg)
        --TODO
        GameCenter.TianJinLingSystem:ResOnlineFallSkyInfo(msg)
    end)

    Network.CreatRespond("MSG_FallingSky.ResRefreshFallSkyTask",function (msg)
        --TODO
        GameCenter.TianJinLingSystem:ResRefreshFallSkyTask(msg)
    end)

    Network.CreatRespond("MSG_FallingSky.ResRefreshFallSkyLevel",function (msg)
        --TODO
        GameCenter.TianJinLingSystem:ResRefreshFallSkyLevel(msg)
    end)

    Network.CreatRespond("MSG_FallingSky.ResRefreshRechargeState",function (msg)
        --TODO
        GameCenter.TianJinLingSystem:ResRefreshRechargeState(msg)
    end)

end
return MSG_FallingSky

