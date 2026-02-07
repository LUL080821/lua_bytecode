local MSG_Commercialize = {}
local Network = GameCenter.Network

function MSG_Commercialize.RegisterMsg()
    Network.CreatRespond("MSG_Commercialize.ResDailyRechargeCfg", function(msg)
        -- GameCenter.DailyRechargeSystem:ResDailyRechargeCfg(msg)
    end)

    Network.CreatRespond("MSG_Commercialize.SyncDailyRechargeInfo", function(msg)
        -- GameCenter.DailyRechargeSystem:SyncDailyRechargeInfo(msg)
    end)

    Network.CreatRespond("MSG_Commercialize.ResFCChargeData", function(msg)
        GameCenter.FristChargeSystem:ResFCChargeData(msg)
    end)

    Network.CreatRespond("MSG_Commercialize.ResDailyRechargeInfo", function(msg)
        GameCenter.DailyRechargeSystem:ResDailyRechargeInfo(msg)
    end)


    Network.CreatRespond("MSG_Commercialize.ResGetBoxRewardResult",function (msg)
        GameCenter.DailyRechargeSystem:ResGetBoxRewardResult(msg)
    end)

end
return MSG_Commercialize

