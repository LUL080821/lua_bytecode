local MSG_DevilSeries = {}
local Network = GameCenter.Network

function MSG_DevilSeries.RegisterMsg()
    Network.CreatRespond("MSG_DevilSeries.ResFollowDeviBoss",function (msg)
        GameCenter.SlayerBossSystem:ResFollowDeviBoss(msg)
    end)

    Network.CreatRespond("MSG_DevilSeries.ResOpenDeviBossPanel",function (msg)
        GameCenter.SlayerBossSystem:ResOpenDeviBossPanel(msg)
    end)

    Network.CreatRespond("MSG_DevilSeries.ResCreateDeviBossMapResult",function (msg)
        GameCenter.SlayerBossSystem:ResCreateDeviBossMapResult(msg)
    end)

    Network.CreatRespond("MSG_DevilSeries.ResSynDeviBossIntegral",function (msg)
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SLAYER_SCORE_UPDATE, msg)
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SLAYERRANK_UPDATE, msg)
    end)


    Network.CreatRespond("MSG_DevilSeries.ResDevilCardList",function (msg)
        GameCenter.DevilSoulSystem:ResDevilCardList(msg)
    end)


    Network.CreatRespond("MSG_DevilSeries.ResDevilEquipWear",function (msg)
        GameCenter.DevilSoulSystem:ResDevilEquipWear(msg)
    end)


    Network.CreatRespond("MSG_DevilSeries.ResDevilCardBreak",function (msg)
        GameCenter.DevilSoulSystem:ResDevilCardBreak(msg)
    end)


    Network.CreatRespond("MSG_DevilSeries.ResDevilCardUp",function (msg)
        GameCenter.DevilSoulSystem:ResDevilCardUp(msg)
    end)


    Network.CreatRespond("MSG_DevilSeries.ResDevilEquipAdd",function (msg)
        GameCenter.NewItemContianerSystem:ResDevilEquipAdd(msg)
    end)


    Network.CreatRespond("MSG_DevilSeries.ResDevilEquipDelete",function (msg)
        GameCenter.NewItemContianerSystem:ResDevilEquipDelete(msg)
    end)


    Network.CreatRespond("MSG_DevilSeries.ResDevilEquipBagInfos",function (msg)
        GameCenter.NewItemContianerSystem:ResDevilEquipBagInfos(msg)
    end)


    Network.CreatRespond("MSG_DevilSeries.ResDevilEquipSynthesis",function (msg)
        GameCenter.DevilSoulSystem:ResDevilEquipSynthesis(msg)
    end)


    Network.CreatRespond("MSG_DevilSeries.ResDevilHunt",function (msg)
        GameCenter.FengMoTaiSystem:ResDevilHunt(msg)
    end)


    Network.CreatRespond("MSG_DevilSeries.ResDevilHuntPanel",function (msg)
        GameCenter.FengMoTaiSystem:ResDevilHuntPanel(msg)
    end)


    Network.CreatRespond("MSG_DevilSeries.ResEnterDeviBossMap",function (msg)
        GameCenter.MapLogicSystem:OnMsgHandle(msg)
    end)


    Network.CreatRespond("MSG_DevilSeries.ResDevilCardFightPoint",function (msg)
        GameCenter.DevilSoulSystem:ResDevilCardFightPoint(msg)
    end)

end
return MSG_DevilSeries

