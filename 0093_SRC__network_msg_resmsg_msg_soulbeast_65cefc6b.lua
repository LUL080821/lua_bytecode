local MSG_SoulBeast = {}
local Network = GameCenter.Network

function MSG_SoulBeast.RegisterMsg()

    Network.CreatRespond("MSG_SoulBeast.ResSoulBeastEquipAdd",function (msg)
        GameCenter.MonsterSoulSystem:GS2U_ResSoulBeastEquipAdd(msg);
    end)

    Network.CreatRespond("MSG_SoulBeast.ResSoulBeastItemAdd",function (msg)
        GameCenter.MonsterSoulSystem:GS2U_ResSoulBeastItemAdd(msg);
    end)

    Network.CreatRespond("MSG_SoulBeast.ResSoulBeastGridNum",function (msg)
        GameCenter.MonsterSoulSystem:GS2U_ResSoulBeastGridNum(msg);
    end)

    Network.CreatRespond("MSG_SoulBeast.ResDeleteSoulBeast",function (msg)
        GameCenter.MonsterSoulSystem:GS2U_ResDeleteSoulBeast(msg);
    end)


    Network.CreatRespond("MSG_SoulBeast.ResSoulBeastBag",function (msg)
        GameCenter.MonsterSoulSystem:GS2U_ResSoulBeastEquipList(msg);
    end)


    Network.CreatRespond("MSG_SoulBeast.ResSoulBeastList",function (msg)
        GameCenter.MonsterSoulSystem:GS2U_ResSoulBeastBaseInfo(msg);
    end)


    Network.CreatRespond("MSG_SoulBeast.ResSoulBeastInfo",function (msg)
        GameCenter.MonsterSoulSystem:GS2U_ResSoulBeastChange(msg);
    end)


    Network.CreatRespond("MSG_SoulBeast.ResSoulBeastEquipInfo",function (msg)
        GameCenter.MonsterSoulSystem:GS2U_ResSoulBeastEquipUp(msg);
    end)


    Network.CreatRespond("MSG_SoulBeast.ResSoulBeastItemUpdate",function (msg)
        GameCenter.MonsterSoulSystem:ResSoulBeastItemUpdate(msg);
    end)

end
return MSG_SoulBeast

