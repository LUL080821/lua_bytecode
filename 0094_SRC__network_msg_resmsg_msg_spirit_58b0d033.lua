local MSG_Spirit = {}
local Network = GameCenter.Network

function MSG_Spirit.RegisterMsg()
    Network.CreatRespond("MSG_Spirit.ResSpiritInfo",function (msg)
        --TODO
        GameCenter.LingTiSystem:ResSpiritInfo(msg)
    end)

    Network.CreatRespond("MSG_Spirit.ResCollectEquip",function (msg)
        --TODO
        GameCenter.LingTiSystem:ResCollectEquip(msg)
    end)

    Network.CreatRespond("MSG_Spirit.ResActiveSpirit",function (msg)
        --TODO
        GameCenter.LingTiSystem:ResActiveSpirit(msg)
    end)


    Network.CreatRespond("MSG_Spirit.ResUpLevel",function (msg)
        GameCenter.LingTiSystem:ResUpLevel(msg)
    end)


    Network.CreatRespond("MSG_Spirit.ResUpStar",function (msg)
        GameCenter.LingTiSystem:ResUpStar(msg)
    end)


    Network.CreatRespond("MSG_Spirit.ResSyncFightPower",function (msg)
        GameCenter.LingTiSystem:ResSyncFightPower(msg)
    end)

end
return MSG_Spirit

