local MSG_Chum = {}
local Network = GameCenter.Network

function MSG_Chum.RegisterMsg()
    Network.CreatRespond("MSG_Chum.ResChum",function (msg)
    end)

    Network.CreatRespond("MSG_Chum.ResRank",function (msg)
    end)

    Network.CreatRespond("MSG_Chum.ResFriend",function (msg)
    end)

    Network.CreatRespond("MSG_Chum.ResTarget",function (msg)
    end)

    Network.CreatRespond("MSG_Chum.ResChangeName",function (msg)
    end)

    Network.CreatRespond("MSG_Chum.ResChangeAnno",function (msg)
    end)

    Network.CreatRespond("MSG_Chum.ResKick",function (msg)
    end)

    Network.CreatRespond("MSG_Chum.ResExit",function (msg)
    end)

    Network.CreatRespond("MSG_Chum.ResCallSoul",function (msg)
    end)

end
return MSG_Chum

