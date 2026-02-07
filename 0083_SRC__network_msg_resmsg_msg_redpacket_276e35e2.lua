local MSG_redpacket = {}
local Network = GameCenter.Network

function MSG_redpacket.RegisterMsg()
    Network.CreatRespond("MSG_redpacket.ResRedpacketList",function (msg)
        GameCenter.GuildSystem:ResRedpacketList(msg)
    end)

    Network.CreatRespond("MSG_redpacket.ResGetRedPacketInfo",function (msg)
        GameCenter.GuildSystem:ResGetRedPacketInfo(msg)
    end)

    Network.CreatRespond("MSG_redpacket.ResClickRedpacket",function (msg)
        GameCenter.GuildSystem:ResClickRedpacket(msg)
    end)

    Network.CreatRespond("MSG_redpacket.ResSendRedPacket",function (msg)
        GameCenter.GuildSystem:ResSendRedPacket(msg)
    end)

    Network.CreatRespond("MSG_redpacket.ResNewRedPacket",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_redpacket.ResMineHaveRedpacket",function (msg)
        --TODO
        GameCenter.GuildSystem:ResMineHaveRedpacket(msg)
    end)

    Network.CreatRespond("MSG_redpacket.ResSendMineRechargeRedpacket",function (msg)
        --TODO
    end)

end
return MSG_redpacket

