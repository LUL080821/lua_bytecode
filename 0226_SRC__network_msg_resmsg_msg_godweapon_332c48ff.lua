local MSG_GodWeapon = {}
local Network = GameCenter.Network

function MSG_GodWeapon.RegisterMsg()
    Network.CreatRespond("MSG_GodWeapon.ResGodWeaponInit",function (msg)

    end)

    Network.CreatRespond("MSG_GodWeapon.ResGodWeaponLevelUp",function (msg)

    end)

    Network.CreatRespond("MSG_GodWeapon.ResGodWeaponQualityUp",function (msg)

    end)

    Network.CreatRespond("MSG_GodWeapon.ResGodWeaponEquipPartOrActive",function (msg)

    end)


    Network.CreatRespond("MSG_GodWeapon.ResSceneGodWeaponEquipPart",function (msg)
        --TODO
    end)

end
return MSG_GodWeapon

