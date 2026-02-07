local MSG_GuildBattle = {}
local Network = GameCenter.Network

function MSG_GuildBattle.RegisterMsg()
    Network.CreatRespond("MSG_GuildBattle.ResGuildBattleRateList",function (msg)
        GameCenter.XmFightSystem:GS2U_ResGuildBattleRateList(msg)
    end)

    Network.CreatRespond("MSG_GuildBattle.ResGuildBattleRecordList",function (msg)
        GameCenter.XmFightSystem:GS2U_ResGuildBattleRecordList(msg)
    end)

    Network.CreatRespond("MSG_GuildBattle.ResGuildBattleWin",function (msg)        
        GameCenter.XmFightSystem:GS2U_ResGuildBattleWin(msg)
    end)


    Network.CreatRespond("MSG_GuildBattle.ResGuildBattleRecordReward",function (msg)        
        GameCenter.XmFightSystem:GS2U_ResGuildBattleRecordReward(msg)
    end)


    Network.CreatRespond("MSG_GuildBattle.ResGuildBattlePanel",function (msg)        
        GameCenter.XmFightSystem:GS2U_ResGuildBattlePanel(msg)
        GameCenter.MapLogicSystem:OnMsgHandle(msg)
    end)


    Network.CreatRespond("MSG_GuildBattle.ResGuildBattleTranCamp",function (msg)
        
        GameCenter.XmFightSystem:GS2U_ResGuildBattleTranCamp(msg)
    end)


    Network.CreatRespond("MSG_GuildBattle.ResGuildBattleLike",function (msg)        
        GameCenter.XmFightSystem:GS2U_ResGuildBattleLike(msg)
    end)


    Network.CreatRespond("MSG_GuildBattle.ResGuildBattleEnd",function (msg)        
        GameCenter.XmFightSystem:GS2U_ResGuildBattleEnd(msg)
    end)


    Network.CreatRespond("MSG_GuildBattle.ResGuildBattleResult",function (msg)        
        GameCenter.XmFightSystem:GS2U_ResGuildBattleResult(msg)
    end)


    -- Red dot
    Network.CreatRespond("MSG_GuildBattle.ResGuildBattleRedPoint",function (msg)
        --TODO
        GameCenter.XmFightSystem:ResGuildBattleRedPoint(msg)
    end)


    Network.CreatRespond("MSG_GuildBattle.ResGuildBattleKillNum",function (msg)
        --TODO
        GameCenter.XmFightSystem:ResGuildBattleKillNum(msg)
    end)


    Network.CreatRespond("MSG_GuildBattle.ResGuildBattleCall",function (msg)
        --TODO
        GameCenter.XmFightSystem:ResGuildBattleCall(msg)
    end)


    Network.CreatRespond("MSG_GuildBattle.ResGuildBattleGatherUpdate",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_GuildBattle.ResGuildBattleExp",function (msg)
        --TODO
        GameCenter.XmFightSystem:ResGuildBattleExp(msg)
    end)


    Network.CreatRespond("MSG_GuildBattle.ResSendBulletScreen",function (msg)
        --TODO
        GameCenter.XmFightSystem:ResSendBulletScreen(msg)
    end)

end
return MSG_GuildBattle

