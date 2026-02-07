local MSG_Nature = {}
local Network = GameCenter.Network

function MSG_Nature.RegisterMsg()
    Network.CreatRespond("MSG_Nature.ResNatureInfo",function (msg)
        GameCenter.NatureSystem:ResNatureInfo(msg)
    end)

    Network.CreatRespond("MSG_Nature.ResNatureUpLevel",function (msg)
        GameCenter.NatureSystem:ResNatureUpLevel(msg)
    end)

    Network.CreatRespond("MSG_Nature.ResNatureDrug",function (msg)
        GameCenter.NatureSystem:ResNatureDrug(msg)
    end)

    Network.CreatRespond("MSG_Nature.ResNatureModelSet",function (msg)
        GameCenter.NatureSystem:ResNatureModelSet(msg)
    end)


    Network.CreatRespond("MSG_Nature.ResNatureFashionUpLevel",function (msg)
        GameCenter.NatureSystem:ResNatureFashionUpLevel(msg)
    end)

    Network.CreatRespond("MSG_Nature.ResNatureModelIdChange",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Nature.ResPowerChange",function (msg)
        GameCenter.NatureSystem:ResPowerChange(msg)
    end)


    Network.CreatRespond("MSG_Nature.ResNatureTaskModelSet",function (msg)
        --TODO
    end)

end
return MSG_Nature

