local MSG_SoulArmor = {}
local Network = GameCenter.Network

function MSG_SoulArmor.RegisterMsg()
    Network.CreatRespond("MSG_SoulArmor.ResSoulArmor",function (msg)
        GameCenter.SoulEquipSystem:ResSoulArmor(msg)
    end)

    Network.CreatRespond("MSG_SoulArmor.ResSoulArmorBag",function (msg)
        GameCenter.NewItemContianerSystem:ResSoulArmorBag(msg)
    end)

    Network.CreatRespond("MSG_SoulArmor.ResAddSoulArmorBall",function (msg)
        GameCenter.NewItemContianerSystem:ResAddSoulArmorBall(msg)
    end)

    Network.CreatRespond("MSG_SoulArmor.ResDelSoulArmorBall",function (msg)
        GameCenter.NewItemContianerSystem:ResDelSoulArmorBall(msg)
    end)

    Network.CreatRespond("MSG_SoulArmor.ResUpdateSoulArmorBallSlot",function (msg)
        GameCenter.SoulEquipSystem:ResUpdateSoulArmorBallSlot(msg)
    end)

    Network.CreatRespond("MSG_SoulArmor.ResUpdateSoulArmorLevel",function (msg)
        GameCenter.SoulEquipSystem:ResUpdateSoulArmorLevel(msg)
    end)

    Network.CreatRespond("MSG_SoulArmor.ResSoulArmorQualityLevel",function (msg)
        GameCenter.SoulEquipSystem:ResSoulArmorQualityLevel(msg)
    end)

    Network.CreatRespond("MSG_SoulArmor.ResUpSoulArmorSkillLevel",function (msg)
        GameCenter.SoulEquipSystem:ResUpSoulArmorSkillLevel(msg)
    end)

    Network.CreatRespond("MSG_SoulArmor.ResSoulArmorLottery",function (msg)
        GameCenter.SoulEquipSystem:ResSoulArmorLottery(msg)
    end)


    Network.CreatRespond("MSG_SoulArmor.ResChangeSoulArmorSkill",function (msg)
        GameCenter.SoulEquipSystem:ResChangeSoulArmorSkill(msg)
    end)


    Network.CreatRespond("MSG_SoulArmor.ResSoulArmorMerge",function (msg)
        GameCenter.SoulEquipSystem:ResSoulArmorMerge(msg)
    end)

end
return MSG_SoulArmor

