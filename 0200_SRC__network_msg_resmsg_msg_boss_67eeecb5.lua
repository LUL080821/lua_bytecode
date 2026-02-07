local MSG_Boss = {}
local Network = GameCenter.Network

function MSG_Boss.RegisterMsg()
    Network.CreatRespond("MSG_Boss.ResOpenDreamBoss",function (msg)
        GameCenter.BossSystem:ResOpenDreamBoss(msg)
    end)

    Network.CreatRespond("MSG_Boss.ResBossKilledInfo",function (msg)
        GameCenter.BossSystem:ResBossKilledInfo(msg)
    end)

    Network.CreatRespond("MSG_Boss.ResFollowBoss",function (msg)
        GameCenter.BossSystem:ResFollowBoss(msg)
    end)

    Network.CreatRespond("MSG_Boss.ResBossRefreshInfo",function (msg)
        GameCenter.BossSystem:ResBossRefreshInfo(msg)
        GameCenter.MapLogicSystem:OnMsgHandle(msg)
    end)

    Network.CreatRespond("MSG_Boss.ResBossRefreshTip",function (msg)
        GameCenter.BossSystem:ResBossRefreshTip(msg)
    end)

    Network.CreatRespond("MSG_Boss.ResMySelfBossRemainTime",function (msg)
        GameCenter.BossSystem:ResMySelfBossRemainTime(msg)
    end)

    Network.CreatRespond("MSG_Boss.ResMySelfBossCopyInfo",function (msg)
        GameCenter.MapLogicSystem:OnMsgHandle(msg)
    end)


    Network.CreatRespond("MSG_Boss.ResMySelfBossStage",function (msg)
        GameCenter.MapLogicSystem:OnMsgHandle(msg)
    end)


    Network.CreatRespond("MSG_Boss.ResSynHarmRank",function (msg)
        GameCenter.BossSystem:ResSynHarmRank(msg)
    end)


    Network.CreatRespond("MSG_Boss.ResMySelfBossItemInfo",function (msg)
        GameCenter.MapLogicSystem:OnMsgHandle(msg)
    end)


    Network.CreatRespond("MSG_Boss.ResAddWorldBossRankCount",function (msg)
        GameCenter.BossSystem:ResAddWorldBossRankCount(msg)
    end)


    Network.CreatRespond("MSG_Boss.ResUpDateWorldBossReMainRankCount",function (msg)
        GameCenter.BossSystem:ResUpDateWorldBossReMainRankCount(msg)
    end)


    Network.CreatRespond("MSG_Boss.ResRankCountTips",function (msg)
        GameCenter.BossSystem:ResRankCountTips(msg)
    end)


    Network.CreatRespond("MSG_Boss.ResSuitGemBossPanel",function (msg)
        GameCenter.BossSystem:ResSuitGemBossPanel(msg)
    end)


    Network.CreatRespond("MSG_Boss.ResSuitGemBossEndTime",function (msg)
        GameCenter.MapLogicSystem:OnMsgHandle(msg)
    end)


    Network.CreatRespond("MSG_Boss.ResSuitGemBossScourge",function (msg)
        GameCenter.BossSystem:ResSuitGemBossScourge(msg)
    end)


    Network.CreatRespond("MSG_Boss.ResWuXianBossOCTime",function (msg)
        GameCenter.BossSystem:ResWuXianBossOCTime(msg)
    end)


    Network.CreatRespond("MSG_Boss.ResNoobBossPannel",function (msg)
        GameCenter.BossSystem:ResNoobBossPannel(msg)
    end)

end
return MSG_Boss

