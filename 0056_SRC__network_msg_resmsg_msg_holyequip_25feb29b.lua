local MSG_HolyEquip = {}
local Network = GameCenter.Network

function MSG_HolyEquip.RegisterMsg()
    Network.CreatRespond("MSG_HolyEquip.ResOnlineInit",function (msg)
        --TODO
        GameCenter.HolyEquipSystem:ResOnlineInit(msg)
    end)

    Network.CreatRespond("MSG_HolyEquip.ResInlayHolyReuslt",function (msg)
        --TODO
        GameCenter.HolyEquipSystem:ResInlayHolyReuslt(msg)
    end)

    Network.CreatRespond("MSG_HolyEquip.ResIntensifyHolyPartResult",function (msg)
        --TODO
        GameCenter.HolyEquipSystem:ResIntensifyHolyPartResult(msg)
    end)

    Network.CreatRespond("MSG_HolyEquip.ResUseHolySoulResult",function (msg)
        --TODO
        GameCenter.HolyEquipSystem:ResUseHolySoulResult(msg)
    end)

    Network.CreatRespond("MSG_HolyEquip.ResDeleteHoly",function (msg)
        --TODO
        GameCenter.HolyEquipSystem:ResDeleteHoly(msg)
    end)

    Network.CreatRespond("MSG_HolyEquip.ResAddHoly",function (msg)
        --TODO
        GameCenter.HolyEquipSystem:ResAddHoly(msg)
    end)


    Network.CreatRespond("MSG_HolyEquip.ResHolyEquipFightPower",function (msg)
        --TODO
        GameCenter.HolyEquipSystem:ResHolyEquipFightPower(msg)
    end)

end
return MSG_HolyEquip

