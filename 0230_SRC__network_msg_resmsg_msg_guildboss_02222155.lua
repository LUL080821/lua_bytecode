local MSG_GuildBoss = {}
local Network = GameCenter.Network

function MSG_GuildBoss.RegisterMsg()
    Network.CreatRespond("MSG_GuildBoss.ResGuildBossPannel",function (msg)
        GameCenter.XMBossSystem:ResGuildBossPannel(msg);
    end)

    Network.CreatRespond("MSG_GuildBoss.ResSyncGuildBossDamage",function (msg)
        GameCenter.XMBossSystem:ResSyncGuildBossDamage(msg);
    end)

    Network.CreatRespond("MSG_GuildBoss.ResGuildBossInspire",function (msg)
        GameCenter.XMBossSystem:ResGuildBossInspire(msg);
    end)

    Network.CreatRespond("MSG_GuildBoss.ResGuildBossOCTime",function (msg)
        GameCenter.XMBossSystem:ResGuildBossOCTime(msg);
    end)

    Network.CreatRespond("MSG_GuildBoss.ResGuildBossResult",function (msg)
        GameCenter.XMBossSystem:ResGuildBossResult(msg);
    end)

end
return MSG_GuildBoss

