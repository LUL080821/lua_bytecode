local MSG_Welfare = {}
local Network = GameCenter.Network

function MSG_Welfare.RegisterMsg()

    Network.CreatRespond("MSG_Welfare.ResLoginGiftData",function (msg)
        GameCenter.WelfareSystem.LoginGift:GS2U_ResLoginGiftData(msg)
    end)


    Network.CreatRespond("MSG_Welfare.ResDayCheckInData",function (msg)
        GameCenter.WelfareSystem.DailyCheck:GS2U_ResDayCheckInData(msg)
    end)


    Network.CreatRespond("MSG_Welfare.ResExclusiveCardData",function (msg)
        GameCenter.WelfareSystem.WelfareCard:GS2U_ResWelfareCards(msg)
    end)


    Network.CreatRespond("MSG_Welfare.ResFeelingExpData",function (msg)
        GameCenter.WelfareSystem:ResFeelingExpData(msg)
    end)


    Network.CreatRespond("MSG_Welfare.ResGrowthFundData",function (msg)
        GameCenter.WelfareSystem.GrowthFund:GS2U_ResGrowthFundData(msg)
    end)


    Network.CreatRespond("MSG_Welfare.ResDayGiftData",function (msg)
        GameCenter.WelfareSystem.DailyGift:GS2U_ResDailyGiftData(msg)
    end)


    Network.CreatRespond("MSG_Welfare.ResWelfareReward",function (msg)
        GameCenter.WelfareSystem:ResWelfareReward(msg)
    end)


    Network.CreatRespond("MSG_Welfare.ResExchangeGift",function (msg)
        GameCenter.WelfareSystem:ResExchangeGift(msg)
    end)

    Network.CreatRespond("MSG_Welfare.ResWelfareLevelGiftData",function (msg)
        --TODO
        GameCenter.WelfareSystem.LevelGift:GS2U_ResLevelGiftData(msg)
    end)


    Network.CreatRespond("MSG_Welfare.SyncRetrieveResList",function (msg)
        --TODO
        GameCenter.ResBackSystem:SyncRetrieveResList(msg)
    end)


    Network.CreatRespond("MSG_Welfare.SyncRetrieveResOne",function (msg)
        --TODO
        GameCenter.ResBackSystem:SyncRetrieveResOne(msg)
    end)


    Network.CreatRespond("MSG_Welfare.ResUpdateNoticData",function (msg)
        GameCenter.WelfareSystem:ResUpdateNoticData(msg)
    end)


    Network.CreatRespond("MSG_Welfare.ResGetUpdateNoticeAwardRet",function (msg)
        GameCenter.WelfareSystem:ResGetUpdateNoticeAwardRet(msg)
    end)


    Network.CreatRespond("MSG_Welfare.ResInvestPeakData",function (msg)
        GameCenter.WelfareSystem.PeakFund:GS2U_ResPeakFundData(msg)
    end)


    Network.CreatRespond("MSG_Welfare.ResWelfareFreeGiftInfo",function (msg)
        --TODO
        GameCenter.WelfareSystem:ResWelfareFreeGiftInfo(msg)
    end)

end
return MSG_Welfare

