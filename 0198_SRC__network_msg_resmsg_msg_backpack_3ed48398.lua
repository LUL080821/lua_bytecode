local MSG_backpack = {}
local Network = GameCenter.Network

function MSG_backpack.RegisterMsg()
    Network.CreatRespond("MSG_backpack.ResItemInfos",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_backpack.ResItemAdd",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_backpack.ResItemChange",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_backpack.ResItemDelete",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_backpack.ResCoinInfos",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_backpack.ResCoinChange",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_backpack.ResOpenBagCellSuccess",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_backpack.ResOpenBagCellFailed",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_backpack.ResCompoundResult",function (msg)
        -- Synthesis results
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_ITEMSYNTH_RESULT, msg)
    end)

    Network.CreatRespond("MSG_backpack.ResOpenGiftEffects",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_backpack.ResItemNotEnough",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_backpack.ResExpChange",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_backpack.ResUseItemMakeBuff",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_backpack.ResItemListDelete",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_backpack.ResAutoUseItem",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_backpack.ResPetEquipAdd",function (msg)
        GameCenter.NewItemContianerSystem:ResPetEquipAdd(msg)
    end)


    Network.CreatRespond("MSG_backpack.ResPetEquipDelete",function (msg)
        GameCenter.NewItemContianerSystem:ResPetEquipDelete(msg)
    end)


    Network.CreatRespond("MSG_backpack.ResPetEquipBagInfos",function (msg)
        GameCenter.NewItemContianerSystem:ResPetEquipBagInfos(msg)
    end)

    
    Network.CreatRespond("MSG_backpack.ResHorseEquipAdd",function (msg)
        GameCenter.NewItemContianerSystem:ResHorseEquipAdd(msg)
    end)


    Network.CreatRespond("MSG_backpack.ResHorseEquipDelete",function (msg)
        GameCenter.NewItemContianerSystem:ResHorseEquipDelete(msg)
    end)


    Network.CreatRespond("MSG_backpack.ResHorseEquipBagInfos",function (msg)
        GameCenter.NewItemContianerSystem:ResHorseEquipBagInfos(msg)
    end)

end
return MSG_backpack

