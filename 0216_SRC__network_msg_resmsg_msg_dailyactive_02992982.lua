local MSG_Dailyactive = {}
local Network = GameCenter.Network

function MSG_Dailyactive.RegisterMsg()

    Network.CreatRespond("MSG_Dailyactive.ResGetActiveReward",function (msg)
        GameCenter.DailyActivitySystem:GS2U_ResGetActiveReward(msg)
    end)

    Network.CreatRespond("MSG_Dailyactive.ResDailyActivePenel",function (msg)
        GameCenter.DailyActivitySystem:GS2U_ResDailyActivePenel(msg)
    end)


    Network.CreatRespond("MSG_Dailyactive.ResDailyPushResult",function (msg)
        GameCenter.DailyActivitySystem:GS2U_ResDailyPushResult(msg)
    end)


    Network.CreatRespond("MSG_Dailyactive.ResDailyActiveOpen",function (msg)
        GameCenter.DailyActivitySystem:GS2U_ResDailyActivityOpenStatus(msg)
    end)


    Network.CreatRespond("MSG_Dailyactive.ResCrossServerMatch",function (msg)
        GameCenter.CrossServerMapSystem:GS2U_ResCrossServerMatch(msg)
        GameCenter.BaJiZhenSystem:SetJinDuData(msg)
    end)

    Network.CreatRespond("MSG_Dailyactive.P2FSendDailyState",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Dailyactive.ResUpdateDailyActiveInfo",function (msg)
        GameCenter.DailyActivitySystem:GS2U_ResUpdateDailyActiveInfo(msg)
    end)


    Network.CreatRespond("MSG_Dailyactive.SyncLeaderPowerStage",function (msg)
        --TODO
        GameCenter.PushFixEvent(UIEventDefine.UIChuanDaoCopyForm_Open)
    end)


    Network.CreatRespond("MSG_Dailyactive.ResLeaderReward",function (msg)
        --TODO
        GameCenter.ChuanDaoSystem:ResLeaderReward(msg)
    end)


    Network.CreatRespond("MSG_Dailyactive.G2PReqCrossServerMatch",function (msg)
        --TODO
    end)

end
return MSG_Dailyactive

