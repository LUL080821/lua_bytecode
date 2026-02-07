local MSG_Equip = {}
local Network = GameCenter.Network

function MSG_Equip.RegisterMsg()

    Network.CreatRespond("MSG_Equip.ResEquipStrength",function (msg)
        --GameCenter.LianQiForgeSystem:GS2U_ResEquipPartInfo(msg)
    end)


    Network.CreatRespond("MSG_Equip.ResEquipStrengthUpLevel",function (msg)
        GameCenter.LianQiForgeSystem:GS2U_ResEquipStrengthUpLevel(msg)
    end)


    Network.CreatRespond("MSG_Equip.ResEquipMinStar",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Equip.ResEquipWearSuccess",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Equip.ResEquipWearFailed",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Equip.ResEquipUnWearSuccess",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Equip.ResEquipUnWearFailed",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Equip.ResEquipSell",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Equip.ResEquipChange",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Equip.ResEquipResolveSet",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Equip.ResEquipGodTried",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Equip.ResOpenGodTried",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Equip.ResEquipSyn",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Equip.ResEquipSuit",function (msg)
        --TODO
        GameCenter.EquipmentSuitSystem:ResEquipSuit(msg);
    end)


    Network.CreatRespond("MSG_Equip.ResEquipSuitStoneSyn",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Equip.ResEquipSynSplit",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Equip.ResSoulBeastEquipSyn",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Equip.ResActivateCast",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Equip.ResEquipCast",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Equip.ResSyncEquipCast",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Equip.ResEquipWash",function (msg)
        GameCenter.LianQiForgeSystem:GS2U_ResEquipWash(msg)
    end)


    Network.CreatRespond("MSG_Equip.ResEquipPartInfo",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Equip.ResQuickRefineGem",function (msg)
        GameCenter.LianQiGemSystem:GS2U_ResQuickRefineGem(msg)
    end)


    Network.CreatRespond("MSG_Equip.ResAutoRefineGem",function (msg)
        GameCenter.LianQiGemSystem:GS2U_ResAutoRefineGem(msg)
    end)


    Network.CreatRespond("MSG_Equip.ResUpdateGemDatas",function (msg)
        GameCenter.LianQiGemSystem:GS2U_ResUpdateGemDatas(msg)
    end)


    Network.CreatRespond("MSG_Equip.ResShenpinEquipUp",function (msg)
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GODEQUIP_RESULT, msg)
    end)

    -- Tay luyen
    Network.CreatRespond("MSG_Equip.ResEquipWashSuccess",function (msg)
        GameCenter.LianQiForgeSystem:GS2U_ResEquipWashSuccess(msg)
    end)

    -- Giam dnh
    Network.CreatRespond("MSG_Equip.ResEquipAppRaisalSuccess",function (msg)
        GameCenter.LianQiForgeSystem:GS2U_ResEquipAppRaisalSuccess(msg)
    end)

    Network.CreatRespond("MSG_Equip.ResItemInfoBags",function (msg)
        GameCenter.LianQiForgeBagSystem:GS2U_ResItemInfoBags(msg)
    end)


    Network.CreatRespond("MSG_Equip.ResEquipMoveLevel",function (msg)
        GameCenter.LianQiForgeSystem:GS2U_ResEquipMoveLevel(msg)
    end)


    Network.CreatRespond("MSG_Equip.ResEquipSplitLevel",function (msg)
        -- CUSTOM - thêm RES tách CH
        GameCenter.LianQiForgeSystem:GS2U_ResEquipSplitLevel(msg)
        -- CUSTOM - thêm RES tách CH
    end)


    Network.CreatRespond("MSG_Equip.ResQuickRemoveGem",function (msg)
        --TODO
        GameCenter.LianQiGemSystem:GS2U_ResUpdateQuickRemoveGem(msg)
    end)


    Network.CreatRespond("MSG_Equip.ResItemInfoBagChange",function (msg)
        GameCenter.LianQiForgeSystem:SetEquipmentForge(msg)
        GameCenter.LianQiForgeBagSystem:GS2U_ResItemInfoBagChange(msg)
    end)

end
return MSG_Equip

