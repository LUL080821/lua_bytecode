local MSG_Cangbaoge = {}
local Network = GameCenter.Network

function MSG_Cangbaoge.RegisterMsg()
    Network.CreatRespond("MSG_Cangbaoge.ResOpenCangbaogePanel",function (msg)
        --TODO
        GameCenter.ZhenCangGeSystem:ResOpenCangbaogePanel(msg)
    end)

    Network.CreatRespond("MSG_Cangbaoge.ResOpenRecordPanel",function (msg)
        --TODO
        GameCenter.ZhenCangGeSystem:ResOpenRecordPanel(msg)
    end)

    Network.CreatRespond("MSG_Cangbaoge.ResCangbaogeLottery",function (msg)
        --TODO
        GameCenter.ZhenCangGeSystem:ResCangbaogeLottery(msg)
    end)

    Network.CreatRespond("MSG_Cangbaoge.ResCangbaogeReward",function (msg)
        --TODO
        GameCenter.ZhenCangGeSystem:ResCangbaogeReward(msg)
    end)

    Network.CreatRespond("MSG_Cangbaoge.ResCangbaogeExchange",function (msg)
        --TODO
        GameCenter.ZhenCangGeSystem:ResCangbaogeExchange(msg)
    end)


    Network.CreatRespond("MSG_Cangbaoge.ResOpenCangbaogeExchange",function (msg)
        GameCenter.ZhenCangGeSystem:ResOpenCangbaogeExchange(msg)
    end)


    Network.CreatRespond("MSG_Cangbaoge.ResOpenTinhChauExchange",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Cangbaoge.ResBuyTinhChauExchange",function (msg)
        --TODO
    end)

end
return MSG_Cangbaoge

