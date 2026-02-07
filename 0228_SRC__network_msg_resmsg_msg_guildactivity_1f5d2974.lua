local MSG_GuildActivity = {}
local Network = GameCenter.Network

function MSG_GuildActivity.RegisterMsg()
    Network.CreatRespond("MSG_GuildActivity.ResOpenRankPanel",function (msg)
        --TODO
        GameCenter.FuDiSystem:ResOpenRankPanel(msg)
    end)


    Network.CreatRespond("MSG_GuildActivity.ResOpenAllBossPanel",function (msg)
        --TODO
        GameCenter.FuDiSystem:ResOpenAllBossPanel(msg)
    end)


    Network.CreatRespond("MSG_GuildActivity.ResDayScoreReward",function (msg)
        --TODO
        GameCenter.FuDiSystem:ResDayScoreReward(msg)
    end)


    -- Network.CreatRespond("MSG_GuildActivity.ResOpenDetailBossPanel",function (msg)
    --     --TODO
    --     GameCenter.FuDiSystem:ResOpenDetailBossPanel(msg)
    -- end)


    Network.CreatRespond("MSG_GuildActivity.ResUpdateMonsterResurgenceTime",function (msg)
        --TODO
        GameCenter.FuDiSystem:ResUpdateMonsterResurgenceTime(msg)
    end)


    Network.CreatRespond("MSG_GuildActivity.ResAttentionMonster",function (msg)
        --TODO
        GameCenter.FuDiSystem:ResAttentionMonster(msg)
    end)


    Network.CreatRespond("MSG_GuildActivity.ResAttentionMonsterRefresh",function (msg)
        --TODO
        GameCenter.FuDiSystem:ResAttentionMonsterRefresh(msg)
    end)


    Network.CreatRespond("MSG_GuildActivity.ResSynAnger",function (msg)
        --TODO
        GameCenter.FuDiSystem:ResSynAnger(msg)
    end)


    Network.CreatRespond("MSG_GuildActivity.ResSynMonster",function (msg)
        --TODO
        GameCenter.FuDiSystem:ResSynMonster(msg)
    end)


    Network.CreatRespond("MSG_GuildActivity.ResSynHarmRank",function (msg)
        --TODO
        GameCenter.FuDiSystem:ResSynHarmRank(msg)
    end)


    Network.CreatRespond("MSG_GuildActivity.ResSnatchPanel",function (msg)
        --TODO
        GameCenter.FuDiSystem:ResSnatchPanel(msg)
    end)


    Network.CreatRespond("MSG_GuildActivity.ResGuardData",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_GuildActivity.ResGuildActiveBabyInfo",function (msg)
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GUILD_ACTIVEBABY_RESULT, msg)
    end)


    Network.CreatRespond("MSG_GuildActivity.ResHarmData",function (msg)
        --TODO
        GameCenter.FuDiSystem:ResHarmData(msg)
    end)


    Network.CreatRespond("MSG_GuildActivity.ResRedPointInfo",function (msg)
        --TODO
        GameCenter.FuDiSystem:ResRedPointInfo(msg)
    end)


    Network.CreatRespond("MSG_GuildActivity.ResQuitTip",function (msg)
        --TODO
        GameCenter.FuDiSystem:ResQuitTip(msg)
    end)


    Network.CreatRespond("MSG_GuildActivity.ResFudiCanHelp",function (msg)
        --TODO
        GameCenter.FuDiSystem:ResFudiCanHelp(msg)
    end)


    Network.CreatRespond("MSG_GuildActivity.ResGuildRankChange",function (msg)
        --TODO
        GameCenter.FuDiSystem:ResGuildRankChange(msg)
    end)


    Network.CreatRespond("MSG_GuildActivity.ResMyFightingBoss",function (msg)
        --TODO
        GameCenter.FuDiSystem:ResMyFightingBoss(msg)
    end)


    -- The countdown to the welfare sword begins
    Network.CreatRespond("MSG_GuildActivity.ResGuildLastBattleTimeCalc",function (msg)
        GameCenter.FuDiSystem:ResGuildLastBattleTimeCalc(msg)
    end)


    -- Blessed land sword battle report
    Network.CreatRespond("MSG_GuildActivity.ResGuildLastBattleReport",function (msg)
        GameCenter.FuDiSystem:ResGuildLastBattleReport(msg)
    end)

    -- Winning in a row
    Network.CreatRespond("MSG_GuildActivity.ResGuildLastBattleRoleKill",function (msg)
        GameCenter.FuDiSystem:ResGuildLastBattleRoleKill(msg)
    end)

    -- Broadcasting wins
    Network.CreatRespond("MSG_GuildActivity.ResGuildLastBattleKill",function (msg)
        GameCenter.FuDiSystem:ResGuildLastBattleKill(msg)
    end)

    -- Sword discussion activity settlement
    Network.CreatRespond("MSG_GuildActivity.ResGuildLastBattleGameOver",function (msg)
        GameCenter.FuDiSystem:ResGuildLastBattleGameOver(msg)
    end)

end
return MSG_GuildActivity

