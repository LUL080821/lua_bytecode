local MSG_Guild = {}
local Network = GameCenter.Network

function MSG_Guild.RegisterMsg()
    Network.CreatRespond("MSG_Guild.ResCreateGuild",function (msg)
        GameCenter.GuildSystem:GS2U_ResCreateGuild(msg);
    end)

    Network.CreatRespond("MSG_Guild.ResJoinGuild",function (msg)
        GameCenter.GuildSystem:GS2U_ResJoinGuild(msg);
    end)

    Network.CreatRespond("MSG_Guild.ResImpeach",function (msg)
        GameCenter.GuildSystem:ResImpeach(msg);
    end)

    Network.CreatRespond("MSG_Guild.ResQuitGuild",function (msg)
        GameCenter.GuildSystem:ResQuitGuild(msg);
    end)

    Network.CreatRespond("MSG_Guild.ResRecommendGuild",function (msg)
        GameCenter.GuildSystem:ResRecommendGuild(msg);
    end)

    Network.CreatRespond("MSG_Guild.ResGuildLogList",function (msg)
        GameCenter.GuildSystem:ResGuildLogList(msg);
    end)

    Network.CreatRespond("MSG_Guild.ResPlayerGuildRankChange",function (msg)
        GameCenter.GuildSystem:ResPlayerGuildRankChange(msg);
    end)

    Network.CreatRespond("MSG_Guild.ResUpBuildingSucces",function (msg)
        GameCenter.GuildSystem:ResUpBuildingSucces(msg);
    end)

    Network.CreatRespond("MSG_Guild.ResGuildMemeberList",function (msg)
        GameCenter.GuildSystem:ResGuildMemeberList(msg);
    end)

    Network.CreatRespond("MSG_Guild.ResReceiveItem",function (msg)
        GameCenter.GuildSystem:GS2U_ResReceiveItem(msg);
    end)

    Network.CreatRespond("MSG_Guild.ResDealApplyInfo",function (msg)
        GameCenter.GuildSystem:ResDealApplyInfo(msg);
    end)


    Network.CreatRespond("MSG_Guild.ResChangeGuildName",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Guild.ResChangeGuildSetting",function (msg)
        GameCenter.GuildSystem:ResChangeGuildSetting(msg);
    end)


    Network.CreatRespond("MSG_Guild.ResGuildInfo",function (msg)
        GameCenter.GuildSystem:ResGuildInfo(msg);
    end)


    Network.CreatRespond("MSG_Guild.ResGuildJoinPlayer",function (msg)
        GameCenter.GuildSystem:ResGuildJoinPlayer(msg);
    end)


    Network.CreatRespond("MSG_Guild.ResGuildApplyPlayer",function (msg)
        GameCenter.GuildSystem:ResApplyAdd(msg);
    end)


    Network.CreatRespond("MSG_Guild.ResGuildGiftList",function (msg)
        GameCenter.GuildSystem:ResGuildGiftList(msg);
    end)


    Network.CreatRespond("MSG_Guild.ResGuildGiftUpdate",function (msg)
        GameCenter.GuildSystem:ResGuildGiftUpdate(msg);
    end)


    Network.CreatRespond("MSG_Guild.ResGuildGiftDelete",function (msg)
        GameCenter.GuildSystem:ResGuildGiftDelete(msg);
    end)


    Network.CreatRespond("MSG_Guild.ResGuildGiftHistory",function (msg)
        GameCenter.GuildSystem:ResGuildGiftHistory(msg);
    end)

end
return MSG_Guild

