local MSG_Horse = {}
local Network = GameCenter.Network

function MSG_Horse.RegisterMsg()
    Network.CreatRespond("MSG_Horse.ResChangeHorse",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Horse.ResChangeRideState",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Horse.ResFlyActionRes",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Horse.ResUpdateHightRes",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Horse.ResActiveHorseInfo",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Horse.ResInviteMessageDisPatcher",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Horse.ResSameRideNoticeAll",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Horse.ResSameRideDown",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Horse.ResMountChangeAssi",function (msg)
        GameCenter.MountEquipSystem:ResMountChangeAssi(msg)
    end)


    Network.CreatRespond("MSG_Horse.ResMountEquipWear",function (msg)
        GameCenter.MountEquipSystem:ResMountEquipWear(msg)
    end)


    Network.CreatRespond("MSG_Horse.ResMountEquipUnWear",function (msg)
        GameCenter.MountEquipSystem:ResMountEquipUnWear(msg)
    end)


    Network.CreatRespond("MSG_Horse.ResMountEquipStrength",function (msg)
        GameCenter.MountEquipSystem:ResMountEquipStrength(msg)
    end)


    Network.CreatRespond("MSG_Horse.ResMountEquipSoul",function (msg)
        GameCenter.MountEquipSystem:ResMountEquipSoul(msg)
    end)


    Network.CreatRespond("MSG_Horse.ResMountEquipActiveInten",function (msg)
        GameCenter.MountEquipSystem:ResMountEquipActiveInten(msg)
    end)


    Network.CreatRespond("MSG_Horse.ResMountEquipActiveSoul",function (msg)
        GameCenter.MountEquipSystem:ResMountEquipActiveSoul(msg)
    end)


    Network.CreatRespond("MSG_Horse.ResMountEquipSynthesis",function (msg)
        GameCenter.MountEquipSystem:ResMountEquipSynthesis(msg)
    end)


    Network.CreatRespond("MSG_Horse.ResMountEquipDecomposeSetting",function (msg)
        GameCenter.MountEquipSystem:ResMountEquipDecomposeSetting(msg)
    end)


    Network.CreatRespond("MSG_Horse.ResHorseEquipList",function (msg)
        GameCenter.MountEquipSystem:ResHorseEquipList(msg)
    end)

end
return MSG_Horse

