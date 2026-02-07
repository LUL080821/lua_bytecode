local MSG_Escort = {}
local Network = GameCenter.Network

function MSG_Escort.RegisterMsg()
    -- Network.CreatRespond("MSG_Escort.ResNoticeEscortCanRecieve",function (msg)
    --     --TODO
    -- end)

    -- Network.CreatRespond("MSG_Escort.ResNoticeEscortModelChange",function (msg)
    --     --TODO
    -- end)

    -- Network.CreatRespond("MSG_Escort.ResEscortRewardInfo",function (msg)
    --     --TODO
    -- end)

    -- Network.CreatRespond("MSG_Escort.ResDoubleEscortRewardNotice",function (msg)
    --     --TODO
    -- end)


    Network.CreatRespond("MSG_Escort.ResEnterEscortResult",function (msg)
        GameCenter.EscortSystem:ResEnterEscortResult(msg)
    end)


    Network.CreatRespond("MSG_Escort.ResInfoEscortResult",function (msg)
        GameCenter.EscortSystem:ResInfoEscortResult(msg)
    end)


    Network.CreatRespond("MSG_Escort.ResEscortOverReward",function (msg)
        GameCenter.EscortSystem:ResEscortOverReward(msg)
    end)

end
return MSG_Escort

