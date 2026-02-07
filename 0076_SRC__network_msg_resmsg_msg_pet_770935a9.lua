local MSG_Pet = {}
local Network = GameCenter.Network

function MSG_Pet.RegisterMsg()
    Network.CreatRespond("MSG_Pet.ResSyncPet",function (msg)
        --TODO
        GameCenter.PetSystem:ResSyncPet(msg);
    end)

    Network.CreatRespond("MSG_Pet.ResBattlePet",function (msg)
        --TODO
        GameCenter.PetSystem:ResBattlePet(msg);
    end)

    Network.CreatRespond("MSG_Pet.ResPetList",function (msg)
        --TODO
        GameCenter.PetSystem:ResPetList(msg);
    end)

    Network.CreatRespond("MSG_Pet.ResEatEquip",function (msg)
        --TODO
        GameCenter.PetSystem:ResEatEquip(msg);
    end)

    Network.CreatRespond("MSG_Pet.ResEatSoul",function (msg)
        --TODO
        GameCenter.PetSystem:ResEatSoul(msg);
    end)

    Network.CreatRespond("MSG_Pet.ResAddPetSkill",function (msg)
        --TODO
        GameCenter.PetSystem:ResAddPetSkill(msg);
    end)


    Network.CreatRespond("MSG_Pet.ResChangeAssiPet",function (msg)
        GameCenter.PetEquipSystem:ResChangeAssiPet(msg)
    end)


    Network.CreatRespond("MSG_Pet.ResPetEquipWear",function (msg)
        GameCenter.PetEquipSystem:ResEquipWear(msg)
    end)


    Network.CreatRespond("MSG_Pet.ResPetEquipUnWear",function (msg)
        GameCenter.PetEquipSystem:ResPetEquipUnWear(msg)
    end)


    Network.CreatRespond("MSG_Pet.ResPetEquipStrength",function (msg)
        GameCenter.PetEquipSystem:ResPetEquipStrength(msg)
    end)


    Network.CreatRespond("MSG_Pet.ResPetEquipSoul",function (msg)
        GameCenter.PetEquipSystem:ResPetEquipSoul(msg)
    end)


    Network.CreatRespond("MSG_Pet.ResPetEquipActiveInten",function (msg)
        GameCenter.PetEquipSystem:ResPetEquipActiveInten(msg)
    end)


    Network.CreatRespond("MSG_Pet.ResPetEquipActiveSoul",function (msg)
        GameCenter.PetEquipSystem:ResPetEquipActiveSoul(msg)
    end)


    Network.CreatRespond("MSG_Pet.ResPetEquipSynthesis",function (msg)
        GameCenter.PetEquipSystem:ResPetEquipSynthesis(msg)
    end)


    Network.CreatRespond("MSG_Pet.ResPetEquipDecomposeSetting",function (msg)
        GameCenter.PetEquipSystem:ResPetEquipDecomposeSetting(msg)
    end)


    Network.CreatRespond("MSG_Pet.ResPetAssistantScoreUpdate",function (msg)
        GameCenter.PetEquipSystem:ResPetAssistantScoreUpdate(msg)
    end)

end
return MSG_Pet

