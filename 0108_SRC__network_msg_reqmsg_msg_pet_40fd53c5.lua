local MSG_Pet = {
    PetInfo = {
       modelId = 0,
       curStage = 0,
    },
    PetSoulInfo = {
       soulId = 0,
       soulLevel = 0,
    },
    PetAssistantInfo = {
       assistantId = 0,
       petId = nil,
       cellList = List:New(),
       strengthActiveId = nil,
       soulActiveId = nil,
       open = nil,
       score = nil,
    },
    PetAssistantCellInfo = {
       cellId = 0,
       equip = nil,
       strengthLv = nil,
       soulLv = nil,
       open = nil,
    },
    ReqPetAction = {
       actType = 0,
       modelId = 0,
    },
    ReqEatEquip = {
       itemId = 0,
    },
    ReqEatSoul = {
       soulId = 0,
    },
    ReqChangeAssiPet = {
       petModelId = 0,
       assistantId = 0,
    },
    ReqPetEquipWear = {
       equipId = 0,
       assistantId = 0,
       cellId = 0,
    },
    ReqPetEquipUnWear = {
       assistantId = 0,
       cellId = 0,
    },
    ReqPetEquipStrength = {
       assistantId = 0,
       cellId = 0,
    },
    ReqPetEquipSoul = {
       assistantId = 0,
       cellId = 0,
    },
    ReqPetEquipActiveInten = {
       assistantId = 0,
       strengthActiveId = 0,
    },
    ReqPetEquipActiveSoul = {
       assistantId = 0,
       soulActiveId = 0,
    },
    ReqPetEquipSynthesis = {
       assistantId = 0,
       cellId = 0,
       equips = List:New(),
    },
    ReqPetEquipDecompose = {
       equipId = List:New(),
    },
    ReqPetEquipDecomposeSetting = {
       set = false,
    },
    ReqActivePetEquipSlot = {
       slotId = 0,
    },
}
local L_StrDic = {
    [MSG_Pet.ReqPetAction] = "MSG_Pet.ReqPetAction",
    [MSG_Pet.ReqEatEquip] = "MSG_Pet.ReqEatEquip",
    [MSG_Pet.ReqEatSoul] = "MSG_Pet.ReqEatSoul",
    [MSG_Pet.ReqChangeAssiPet] = "MSG_Pet.ReqChangeAssiPet",
    [MSG_Pet.ReqPetEquipWear] = "MSG_Pet.ReqPetEquipWear",
    [MSG_Pet.ReqPetEquipUnWear] = "MSG_Pet.ReqPetEquipUnWear",
    [MSG_Pet.ReqPetEquipStrength] = "MSG_Pet.ReqPetEquipStrength",
    [MSG_Pet.ReqPetEquipSoul] = "MSG_Pet.ReqPetEquipSoul",
    [MSG_Pet.ReqPetEquipActiveInten] = "MSG_Pet.ReqPetEquipActiveInten",
    [MSG_Pet.ReqPetEquipActiveSoul] = "MSG_Pet.ReqPetEquipActiveSoul",
    [MSG_Pet.ReqPetEquipSynthesis] = "MSG_Pet.ReqPetEquipSynthesis",
    [MSG_Pet.ReqPetEquipDecompose] = "MSG_Pet.ReqPetEquipDecompose",
    [MSG_Pet.ReqPetEquipDecomposeSetting] = "MSG_Pet.ReqPetEquipDecomposeSetting",
    [MSG_Pet.ReqActivePetEquipSlot] = "MSG_Pet.ReqActivePetEquipSlot",
}
local L_SendDic = setmetatable({},{__mode = "k"});

local mt = {}
mt.__index = mt
function mt:New()
    local _str = L_StrDic[self]
    local _clone = Utils.DeepCopy(self)
    L_SendDic[_clone] = _str
    return _clone
end
function mt:Send()
    GameCenter.Network.Send(L_SendDic[self], self)
end

for k,v in pairs(L_StrDic) do
    setmetatable(k, mt)
end

return MSG_Pet

