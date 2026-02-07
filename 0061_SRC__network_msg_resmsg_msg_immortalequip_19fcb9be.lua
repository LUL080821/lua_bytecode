local MSG_ImmortalEquip = {}
local Network = GameCenter.Network

function MSG_ImmortalEquip.RegisterMsg()
    Network.CreatRespond("MSG_ImmortalEquip.ResOnlineInitImmortalEquip",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_ImmortalEquip.ResInlayImmortalReuslt",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_ImmortalEquip.ResCompoundImmortalReuslt",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_ImmortalEquip.ResSynImmortalEquipInfo",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_ImmortalEquip.ResAddImmortalEquip",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_ImmortalEquip.ResDeleteImmortalEquip",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_ImmortalEquip.ResSyncImmEquipFightPower",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_ImmortalEquip.ResSyncImmEquipBaguaFightPower",function (msg)
        --TODO
    end)

end
return MSG_ImmortalEquip

