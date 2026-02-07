local MSG_ImmortalSoul = {}
local Network = GameCenter.Network

function MSG_ImmortalSoul.RegisterMsg()
    Network.CreatRespond("MSG_ImmortalSoul.ResAllImmortalSoul",function (msg)
        GameCenter.XianPoSystem:ResAllImmortalSoul(msg)
    end)

    Network.CreatRespond("MSG_ImmortalSoul.ResInlaySoulReuslt",function (msg)
        GameCenter.XianPoSystem:ResInlaySoulReuslt(msg)
    end)

    Network.CreatRespond("MSG_ImmortalSoul.ResResolveSoulReuslt",function (msg)
        GameCenter.XianPoSystem:ResResolveSoulReuslt(msg)
    end)

    Network.CreatRespond("MSG_ImmortalSoul.ResUpSoulReuslt",function (msg)
        GameCenter.XianPoSystem:ResUpSoulReuslt(msg)
    end)

    Network.CreatRespond("MSG_ImmortalSoul.ResExchangeSoulReuslt",function (msg)
        GameCenter.XianPoSystem:ResExchangeSoulReuslt(msg)
    end)

    Network.CreatRespond("MSG_ImmortalSoul.ResCompoundSoulReuslt",function (msg)
        GameCenter.XianPoSystem:ResCompoundSoulReuslt(msg)
    end)

    Network.CreatRespond("MSG_ImmortalSoul.ResGetOffReuslt",function (msg)
        GameCenter.XianPoSystem:ResGetOffReuslt(msg)
    end)


    Network.CreatRespond("MSG_ImmortalSoul.ResSoulCore",function (msg)
        --TODO
        GameCenter.XianPoSystem:ResSoulCore(msg)
    end)


    Network.CreatRespond("MSG_ImmortalSoul.ResSoulCoreUpdate",function (msg)
        --TODO
        GameCenter.XianPoSystem:ResSoulCoreUpdate(msg)
    end)


    Network.CreatRespond("MSG_ImmortalSoul.ResDismountingSoulReuslt",function (msg)
        --TODO
        GameCenter.XianPoSystem:ResDismountingSoulReuslt(msg)
    end)

end
return MSG_ImmortalSoul

