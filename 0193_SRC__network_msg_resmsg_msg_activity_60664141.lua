local MSG_Activity = {}
local Network = GameCenter.Network

function MSG_Activity.RegisterMsg()
    Network.CreatRespond("MSG_Activity.ResActivityList",function (msg)
        GameCenter.YYHDSystem:ResActivityList(msg)
    end)

    Network.CreatRespond("MSG_Activity.ResActivityChange",function (msg)
        GameCenter.YYHDSystem:ResActivityChange(msg)
    end)

    Network.CreatRespond("MSG_Activity.ResActivityDeal",function (msg)
        --TODO
        GameCenter.YYHDSystem:ResActivityDeal(msg)
    end)

    Network.CreatRespond("MSG_Activity.ResTagInfoList",function (msg)
        --TODO
        GameCenter.YYHDSystem:ResTagInfoList(msg)
    end)

end
return MSG_Activity

