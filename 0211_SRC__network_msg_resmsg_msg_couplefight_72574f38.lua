local MSG_Couplefight = {}
local Network = GameCenter.Network

function MSG_Couplefight.RegisterMsg()
    Network.CreatRespond("MSG_Couplefight.G2PReqCouplefightInfo",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Couplefight.ResTrialsInfo",function (msg)
        --TODO
        GameCenter.LoversFightSystem:ResTrialsInfo(msg)
    end)

    Network.CreatRespond("MSG_Couplefight.ResApply",function (msg)
        --TODO
        GameCenter.LoversFightSystem:ResApply(msg)
    end)

    Network.CreatRespond("MSG_Couplefight.ResApplyConfirm",function (msg)
        --TODO
        GameCenter.LoversFightSystem:ResApplyConfirm(msg)
    end)

    Network.CreatRespond("MSG_Couplefight.ResMatchStart",function (msg)
        --TODO
        GameCenter.LoversFightSystem:ResMatchStart(msg)
    end)

    Network.CreatRespond("MSG_Couplefight.ResMatchSuccess",function (msg)
        --TODO
        GameCenter.LoversFightSystem:ResMatchSuccess(msg)
    end)

    Network.CreatRespond("MSG_Couplefight.ResMatchStop",function (msg)
        --TODO
        GameCenter.LoversFightSystem:ResMatchStop(msg)
    end)

    -- Network.CreatRespond("MSG_Couplefight.ResMatchConfirm",function (msg)
    --     --TODO
    --     GameCenter.LoversFightSystem:ResMatchConfirm(msg)
    -- end)

    Network.CreatRespond("MSG_Couplefight.ResMatchConfirmNotice",function (msg)
        --TODO
        GameCenter.LoversFightSystem:ResMatchConfirmNotice(msg)
    end)

    Network.CreatRespond("MSG_Couplefight.ResTrialsInfoUpdate",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Couplefight.ResTrialsRank",function (msg)
        --TODO
        GameCenter.LoversFightSystem:ResTrialsRank(msg)
    end)

    Network.CreatRespond("MSG_Couplefight.G2PReqApply",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Couplefight.G2PReqMatchStart",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Couplefight.G2PReqMatchStop",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Couplefight.G2PReqMatchConfirm",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Couplefight.P2GResMatchSuccess",function (msg)
        --TODO
    end)

    -- Network.CreatRespond("MSG_Couplefight.P2GResMatchResult",function (msg)
    --     --TODO
    -- end)

    Network.CreatRespond("MSG_Couplefight.ResOnlieInitCoupleShop",function (msg)
        GameCenter.LoversFightSystem:ResOnlieInitCoupleShop(msg)
    end)


    Network.CreatRespond("MSG_Couplefight.ResBuyCoupleItemResult",function (msg)
        GameCenter.LoversFightSystem:ResBuyCoupleItemResult(msg)
    end)


    Network.CreatRespond("MSG_Couplefight.F2PResFightResult",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Couplefight.P2GResFightResult",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Couplefight.ResGroupInfo",function (msg)
        --TODO
        GameCenter.LoversFightSystem:ResGroupInfo(msg)
    end)


    Network.CreatRespond("MSG_Couplefight.ResGroupRank",function (msg)
        --TODO
        GameCenter.LoversFightSystem:ResGroupRank(msg)
    end)


    Network.CreatRespond("MSG_Couplefight.ResFightResult",function (msg)
        --TODO
        GameCenter.LoversFightSystem:ResFightResult(msg)
    end)


    Network.CreatRespond("MSG_Couplefight.P2GResRankAward",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Couplefight.ResGetAward",function (msg)
        --TODO
        GameCenter.LoversFightSystem:ResGetAward(msg)
    end)


    Network.CreatRespond("MSG_Couplefight.P2GResTrialsInfo",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Couplefight.G2PReqGroupPrepareMapEnter",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Couplefight.F2PReqGroupPrepareMapOut",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Couplefight.ResChampionInfo",function (msg)
        --TODO
        GameCenter.LoversFightSystem:ResChampionInfo(msg)
    end)


    Network.CreatRespond("MSG_Couplefight.ResChampionGuessInfo",function (msg)
        --TODO
        GameCenter.LoversFightSystem:ResChampionGuessInfo(msg)
    end)


    -- Network.CreatRespond("MSG_Couplefight.ResChampionGuessUpdate",function (msg)
    --     --TODO
    -- end)


    Network.CreatRespond("MSG_Couplefight.ResChampionFansRankList",function (msg)
        --TODO
        GameCenter.LoversFightSystem:ResChampionFansRankList(msg)
    end)


    Network.CreatRespond("MSG_Couplefight.ResChampionTeamList",function (msg)
        --TODO
        GameCenter.LoversFightSystem:ResChampionTeamList(msg)
    end)


    Network.CreatRespond("MSG_Couplefight.G2PReqChampionGuess",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Couplefight.P2GResChampionGuess",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Couplefight.P2FReqGoToFight",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Couplefight.G2PSendPlayerInfo",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Couplefight.P2GGetTrialsAward",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Couplefight.P2GResGuessResult",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Couplefight.ResEnterCoupleEscortResult",function (msg)
        GameCenter.HuSongSystem:ResEnterCoupleEscortResult(msg)
    end)


    Network.CreatRespond("MSG_Couplefight.ResCoupleEscortReward",function (msg)
        GameCenter.HuSongSystem:ResCoupleEscortReward(msg)
    end)


    Network.CreatRespond("MSG_Couplefight.ResEnterFightMap",function (msg)
        --TODO
        GameCenter.LoversFightSystem:ResEnterFightMap(msg)
    end)


    Network.CreatRespond("MSG_Couplefight.ResPromotionInfo",function (msg)
        --TODO
        GameCenter.LoversFightSystem:ResPromotionInfo(msg)
    end)


    Network.CreatRespond("MSG_Couplefight.P2GChangeStatus",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Couplefight.P2GPromotion",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Couplefight.P2GTrialsAward",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Couplefight.ResRedPoint",function (msg)
        --TODO
    end)

end
return MSG_Couplefight

