local MSG_StateStifle = {}
local Network = GameCenter.Network

function MSG_StateStifle.RegisterMsg()
    Network.CreatRespond("MSG_StateStifle.ResStateStifleBase",function (msg)
        --TODO
        GameCenter.RealmStifleSystem:ResOpenPanel(msg);
    end)


    Network.CreatRespond("MSG_StateStifle.ResSoulSpiritInfo",function (msg)
        GameCenter.RealmStifleSystem:ResSoulSpiritInfo(msg)
    end)


    Network.CreatRespond("MSG_StateStifle.ResUpLevel",function (msg)
        GameCenter.RealmStifleSystem:ResUpLevel(msg)
    end)

end
return MSG_StateStifle

