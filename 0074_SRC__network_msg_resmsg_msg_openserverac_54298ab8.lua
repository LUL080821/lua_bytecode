local MSG_OpenServerAc = {}
local Network = GameCenter.Network

function MSG_OpenServerAc.RegisterMsg()
    Network.CreatRespond("MSG_OpenServerAc.ResOpenSeverRevelList",function (msg)
        --TODO
        GameCenter.ServeCrazySystem:GS2U_ResOpenSeverRevelList(msg)
    end)

    Network.CreatRespond("MSG_OpenServerAc.ResOpenSeverRevelInfo",function (msg)
        --TODO
        GameCenter.ServeCrazySystem:ResOpenSeverRevelInfo(msg)
    end)

    Network.CreatRespond("MSG_OpenServerAc.ResOpenSeverRevelReward",function (msg)
        --TODO
        GameCenter.ServeCrazySystem:ResOpenSeverRevelReward(msg)
    end)


    Network.CreatRespond("MSG_OpenServerAc.ResGrowUpInfo",function (msg)
        --TODO
        GameCenter.GrowthWaySystem:ResGrowUpInfo(msg)
    end)


    Network.CreatRespond("MSG_OpenServerAc.ResGrowUpList",function (msg)
        --TODO
        GameCenter.GrowthWaySystem:ResGrowUpList(msg)
    end)


    Network.CreatRespond("MSG_OpenServerAc.ResGrowUpPoint",function (msg)
        --TODO
        GameCenter.GrowthWaySystem:ResGrowUpPoint(msg)
    end)


    Network.CreatRespond("MSG_OpenServerAc.ResGrowUpPointReward",function (msg)
        --TODO
        GameCenter.GrowthWaySystem:ResGrowUpPointReward(msg)
    end)

    Network.CreatRespond("MSG_OpenServerAc.ResOpenServerSpecRedDot",function (msg)
        --TODO
        GameCenter.ServerActiveSystem:ResOpenServerSpecRedDot(msg)
    end)


    Network.CreatRespond("MSG_OpenServerAc.ResOpenServerSpecAc",function (msg)
        --TODO
        GameCenter.ServerActiveSystem:ResOpenServerSpecAc(msg)
    end)


    Network.CreatRespond("MSG_OpenServerAc.ResOpenServerSpecReward",function (msg)
        --TODO
        GameCenter.ServerActiveSystem:ResOpenServerSpecReward(msg)
    end)


    Network.CreatRespond("MSG_OpenServerAc.ResOpenServerSpecExchange",function (msg)
        --TODO
        GameCenter.ServerActiveSystem:ResOpenServerSpecExchange(msg)
    end)


    Network.CreatRespond("MSG_OpenServerAc.ResOpenSeverRevelPersonReward",function (msg)
        --TODO
        GameCenter.ServeCrazySystem:GS2U_ResOpenSeverRevelPersonReward(msg)
    end)


    Network.CreatRespond("MSG_OpenServerAc.ResFreeDailyReward",function (msg)
        -- Set whether to receive red dots
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.FunctionNotice, not msg.hasGet)
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATEFUNCNOTICE_INFO)
    end)


    Network.CreatRespond("MSG_OpenServerAc.ResGrowUpPur",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_OpenServerAc.ResOpenServerSpecRed",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_OpenServerAc.ResOpenFirstKillPanel",function (msg)
        --TODO
        GameCenter.ServeCrazySystem:ResOpenFirstKillPanel(msg)
    end)


    Network.CreatRespond("MSG_OpenServerAc.ResGetKillReward",function (msg)
        --TODO
        GameCenter.ServeCrazySystem:ResGetKillReward(msg)
    end)


    Network.CreatRespond("MSG_OpenServerAc.ResHongBaoReward",function (msg)
        --TODO
        GameCenter.ServeCrazySystem:ResHongBaoReward(msg)
    end)


    Network.CreatRespond("MSG_OpenServerAc.ResFirstKillBossInfo",function (msg)
        --TODO
        GameCenter.ServeCrazySystem:ResFirstKillBossInfo(msg)
    end)


    Network.CreatRespond("MSG_OpenServerAc.ResFirstKillAdvice",function (msg)
        --TODO
        GameCenter.ServeCrazySystem:ResFirstKillAdvice(msg)
    end)


    Network.CreatRespond("MSG_OpenServerAc.ResFirstKillRedPoint",function (msg)
        --TODO
        GameCenter.ServeCrazySystem:ResFirstKillRedPoint(msg)
    end)


    Network.CreatRespond("MSG_OpenServerAc.ResNewServerActPanel",function (msg)
        GameCenter.NewServerActivitySystem:ResNewServerActPanel(msg)
    end)


    Network.CreatRespond("MSG_OpenServerAc.ResGetActReward",function (msg)
        GameCenter.NewServerActivitySystem:ResGetActReward(msg)
    end)


    Network.CreatRespond("MSG_OpenServerAc.ResLuckyCardInfo",function (msg)
        --TODO
        GameCenter.LuckyCardSystem:ResLuckyCardInfo(msg)
    end)


    Network.CreatRespond("MSG_OpenServerAc.ResLuckyOnce",function (msg)
        --TODO
        GameCenter.LuckyCardSystem:ResLuckyOnce(msg)
    end)


    Network.CreatRespond("MSG_OpenServerAc.ResGetLuckyTaskReawrd",function (msg)
        --TODO
        GameCenter.LuckyCardSystem:ResGetLuckyTaskReawrd(msg)
    end)


    Network.CreatRespond("MSG_OpenServerAc.ResGetLuckyLog",function (msg)
        --TODO
        GameCenter.LuckyCardSystem:ResGetLuckyLog(msg)
    end)


    Network.CreatRespond("MSG_OpenServerAc.ResV4HelpInfos",function (msg)
        --TODO
        GameCenter.NewServerActivitySystem:ResV4HelpInfos(msg)
    end)


    Network.CreatRespond("MSG_OpenServerAc.ResV4RebateInfo",function (msg)
        GameCenter.NewServerActivitySystem:ResV4RebateInfo(msg)
    end)


    Network.CreatRespond("MSG_OpenServerAc.ResV4RebateUpDate",function (msg)
        GameCenter.NewServerActivitySystem:ResV4RebateUpDate(msg)
    end)


    Network.CreatRespond("MSG_OpenServerAc.ResV4RebateRewardResult",function (msg)
        GameCenter.NewServerActivitySystem:ResV4RebateRewardResult(msg)
    end)


    Network.CreatRespond("MSG_OpenServerAc.ResRebateBoxList",function (msg)
        GameCenter.NewServerActivitySystem:ResRebateBoxList(msg)
    end)


    Network.CreatRespond("MSG_OpenServerAc.ResXMZhengBaInfo",function (msg)
        GameCenter.XMZhengBaSystem:ResXMZhengBaInfo(msg)
    end)


    Network.CreatRespond("MSG_OpenServerAc.ResGetXMZBReward",function (msg)
        GameCenter.XMZhengBaSystem:ResGetXMZBReward(msg)
    end)

end
return MSG_OpenServerAc

