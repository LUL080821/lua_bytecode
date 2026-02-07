local MSG_UnrealEquip = {}
local Network = GameCenter.Network

function MSG_UnrealEquip.RegisterMsg()
    Network.CreatRespond("MSG_UnrealEquip.ResOnlineInit",function (msg)
        --TODO
        GameCenter.UnrealEquipSystem:ResOnlineInit(msg)
    end)

    Network.CreatRespond("MSG_UnrealEquip.ResInlayUnrealReuslt",function (msg)
        --TODO
        GameCenter.UnrealEquipSystem:ResInlayUnrealReuslt(msg)
    end)

    Network.CreatRespond("MSG_UnrealEquip.ResUseUnrealSoulResult",function (msg)
        --TODO
        GameCenter.UnrealEquipSystem:ResUseUnrealSoulResult(msg)
    end)

    Network.CreatRespond("MSG_UnrealEquip.ResDeleteUnreal",function (msg)
        --TODO
        GameCenter.UnrealEquipSystem:ResDeleteUnreal(msg)
    end)

    Network.CreatRespond("MSG_UnrealEquip.ResAddUnreal",function (msg)
        --TODO
        GameCenter.UnrealEquipSystem:ResAddUnreal(msg)
    end)

    Network.CreatRespond("MSG_UnrealEquip.ResUnrealEquipFightPower",function (msg)
        --TODO
        GameCenter.UnrealEquipSystem:ResUnrealEquipFightPower(msg)
    end)

end
return MSG_UnrealEquip

