local MSG_copyMap = {}
local Network = GameCenter.Network

function MSG_copyMap.RegisterMsg()

    Network.CreatRespond("MSG_copyMap.ResCopymapNeedTime",function (msg)
        --TODO
        GameCenter.MapLogicSystem:OnMsgHandle(msg);
    end)

    Network.CreatRespond("MSG_copyMap.ResChallengeInfo",function (msg)
        --TODO
        GameCenter.MapLogicSystem:OnMsgHandle(msg);
    end)

    Network.CreatRespond("MSG_copyMap.ResChallengeEnterPanel",function (msg)
        --TODO
        GameCenter.CopyMapSystem:ResChallengeEnterPanel(msg);
    end)

    Network.CreatRespond("MSG_copyMap.ResTeamCampWar",function (msg)
        --TODO
        GameCenter.MapLogicSystem:OnMsgHandle(msg);
    end)

    Network.CreatRespond("MSG_copyMap.ResTeamCampWarRank",function (msg)
        --TODO
        GameCenter.MapLogicSystem:OnMsgHandle(msg);
    end)

    Network.CreatRespond("MSG_copyMap.ResTeamCampWarEndInfo",function (msg)
        --TODO
        GameCenter.MapLogicSystem:OnMsgHandle(msg);
    end)

    Network.CreatRespond("MSG_copyMap.ResChallengeEndInfo",function (msg)
        --TODO
        GameCenter.MapLogicSystem:OnMsgHandle(msg);
    end)

    Network.CreatRespond("MSG_copyMap.ResStartCopyInfo",function (msg)
        --TODO
        GameCenter.MapLogicSystem:OnMsgHandle(msg);
    end)


    Network.CreatRespond("MSG_copyMap.ResStartCopyResult",function (msg)
        --TODO
        GameCenter.MapLogicSystem:OnMsgHandle(msg);
    end)


    Network.CreatRespond("MSG_copyMap.ResVipBuyCount",function (msg)
        --TODO
        GameCenter.CopyMapSystem:ResVipBuyCount(msg);
    end)


    Network.CreatRespond("MSG_copyMap.ResOpenFairyCopyPanel",function (msg)
        --TODO
        GameCenter.CopyMapSystem:ResOpenFairyCopyPanel(msg);
    end)


    Network.CreatRespond("MSG_copyMap.ResFairyCopyResult",function (msg)
        --TODO
        GameCenter.MapLogicSystem:OnMsgHandle(msg);
    end)


    Network.CreatRespond("MSG_copyMap.ResOpenManyCopyPanel",function (msg)
        --TODO
        GameCenter.CopyMapSystem:ResOpenManyCopyPanel(msg);
    end)


    Network.CreatRespond("MSG_copyMap.ResCopySetting",function (msg)
        --TODO
        GameCenter.CopyMapSystem:ResCopySetting(msg);
    end)


    Network.CreatRespond("MSG_copyMap.ResExpCopy",function (msg)
        --TODO
        GameCenter.MapLogicSystem:OnMsgHandle(msg);
    end)


    Network.CreatRespond("MSG_copyMap.ResSyncMonsterExp",function (msg)
        --TODO
        GameCenter.MapLogicSystem:OnMsgHandle(msg);
    end)


    Network.CreatRespond("MSG_copyMap.ResManyCopy",function (msg)
        --TODO
        GameCenter.MapLogicSystem:OnMsgHandle(msg);
    end)


    Network.CreatRespond("MSG_copyMap.ResSyncManyCopy",function (msg)
        --TODO
        GameCenter.MapLogicSystem:OnMsgHandle(msg);
    end)


    Network.CreatRespond("MSG_copyMap.ResManyCopyResult",function (msg)
        --TODO
        GameCenter.MapLogicSystem:OnMsgHandle(msg);
    end)


    Network.CreatRespond("MSG_copyMap.ResOpenBossStatePanle",function (msg)
        GameCenter.StatureBossSystem:ResOpenBossStatePanle(msg)
    end)


    Network.CreatRespond("MSG_copyMap.ResupdateBossState",function (msg)
        GameCenter.StatureBossSystem:ResupdateBossState(msg)
    end)


    Network.CreatRespond("MSG_copyMap.ResBuyBossStateCount",function (msg)
        GameCenter.StatureBossSystem:ResBuyBossStateCount(msg)
    end)


    Network.CreatRespond("MSG_copyMap.ResEnterFairyCopy",function (msg)
        --TODO
        GameCenter.MapLogicSystem:OnMsgHandle(msg);
    end)


    Network.CreatRespond("MSG_copyMap.ResCopyMapBitFinish",function (msg)
        --TODO
        GameCenter.MapLogicSystem:OnMsgHandle(msg);
    end)


    Network.CreatRespond("MSG_copyMap.ResGuildTaskCopyInfo",function (msg)
        --TODO
        GameCenter.MapLogicSystem:OnMsgHandle(msg);
    end)


    Network.CreatRespond("MSG_copyMap.ResGuildTaskCopyResult",function (msg)
        --TODO
        GameCenter.MapLogicSystem:OnMsgHandle(msg);
    end)


    Network.CreatRespond("MSG_copyMap.ResGuildTaskCopyEnter",function (msg)
        --TODO
        GameCenter.MapLogicSystem:OnMsgHandle(msg);
    end)


    Network.CreatRespond("MSG_copyMap.ResSyncMonsterNum",function (msg)
        --TODO
        GameCenter.MapLogicSystem:OnMsgHandle(msg);
    end)

end
return MSG_copyMap

