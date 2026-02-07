local MSG_Chat = {}
local Network = GameCenter.Network

function MSG_Chat.RegisterMsg()
    Network.CreatRespond("MSG_Chat.ChatGetContentCS",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Chat.ChatResSC",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Chat.ChatResLeaveMessageSC",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Chat.ChatGetContentSC",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Chat.PersonalNotice",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Chat.ResAddChatRooM",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Chat.ResChatRoom",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Chat.ResExitChatRoom",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Chat.PersonalChatNotice",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Chat.ResShareNotice",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Chat.ResGetShareRewardResult",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Chat.ResWorldHistoryChatInfo",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Chat.ResForbidWord",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Chat.F2GameServerNotice",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Chat.P2GameServerNotice",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Chat.F2PServerNotice",function (msg)
        --TODO
    end)

end
return MSG_Chat

