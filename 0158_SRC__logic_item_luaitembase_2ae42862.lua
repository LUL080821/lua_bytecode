------------------------------------------------
-- Author:
-- Date: 2021-03-10
-- File: LuaItemBase.lua
-- Module: LuaItemBase
-- Description: Basic item category, used to provide corresponding interfaces for item model
------------------------------------------------
local L_PetEquip = require("Logic.Item.PetEquip")
local L_HorseEquip = require("Logic.Item.HorseEquip")
local L_DevilSoulEquip = require("Logic.Item.DevilSoulEquip")
local L_SoulPearl = require("Logic.Item.SoulPearl")
local L_UnrealEquip = require("Logic.Item.UnrealEquip")
local L_CItemBase = CS.Thousandto.Code.Logic.ItemBase
local LuaItemBase = {
    EquipBaseAttDic = nil,
    EquipSpecialAttDic = nil,
}

-- Determine the item type
function LuaItemBase.GetItemTypeByModelID(cfgID)
    if (cfgID >= 2000000 and cfgID < 3000000) then
        return ItemType.Equip;
    elseif (cfgID >= 4000000 and cfgID < 5000000) then
        return ItemType.HolyEquip;
    elseif (cfgID >= 5000000 and cfgID < 6000000) then
        return ItemType.ImmortalEquip;
    elseif (cfgID >= 6000000 and cfgID < 7000000) then
        return ItemType.LingPo;
    elseif (cfgID >= 7000000 and cfgID < 7010000) then
        return ItemType.PetEquip;
    elseif (cfgID >= 7010000 and cfgID < 8000000) then
        return ItemType.SoulPearl;
    elseif (cfgID >= 8000000 and cfgID < 8010000) then
        return ItemType.HorseEquip;
    elseif (cfgID >= 9000000 and cfgID < 9010000) then
        return ItemType.DevilSoulEquip;
    elseif (cfgID >= 10000000 and cfgID < 11000000) then
        return ItemType.UnrealEquip;
    end
    local item = DataConfig.DataItem[cfgID]
    if item then
        return item.Type;
    end
    return ItemType.UnDefine;
end


-- Generate template data according to the configuration table ID
function LuaItemBase.CreateItemBase(cfgID)
    local type = LuaItemBase.GetItemTypeByModelID(cfgID);
    if (type == ItemType.PetEquip) then
        return L_PetEquip:New(cfgID)
    elseif (type == ItemType.SoulPearl) then
        return L_SoulPearl:New(cfgID)
    elseif (type == ItemType.HorseEquip) then
        return L_HorseEquip:New(cfgID)
    elseif (type == ItemType.DevilSoulEquip) then
        return L_DevilSoulEquip:New(cfgID)
    elseif (type == ItemType.UnrealEquip) then
        return L_UnrealEquip:New(cfgID)
    else
        return L_CItemBase.CreateItemBase(cfgID)
    end
end

-- Generate template data based on network messages
function LuaItemBase.CreateItemBaseByMsg(msg)
    if msg then
        local type = LuaItemBase.GetItemTypeByModelID(msg.itemModelId);
        if (type == ItemType.PetEquip) then
            return L_PetEquip:NewWithMsg(msg)
        elseif (type == ItemType.SoulPearl) then
            return L_SoulPearl:NewWithMsg(msg)
        elseif (type == ItemType.HorseEquip) then
            return L_HorseEquip:NewWithMsg(msg)
        elseif (type == ItemType.DevilSoulEquip) then
            return L_DevilSoulEquip:NewWithMsg(msg)
        elseif (type == ItemType.UnrealEquip) then
            return L_UnrealEquip:NewWithMsg(msg)
        else
            return L_CItemBase.CreateItemBaseByLuaMsg(msg)
        end
    end
    return nil;
end

-- Obtain the name of the equipment part according to the equipment type
function LuaItemBase.GetEquipNameWithType(type)
    local ret = nil;
    if type == PetEquipType.Defalt then
        ret = DataConfig.DataMessageString.Get("C_EQUIP_ALL");
    elseif type == PetEquipType.Bell then
        ret = DataConfig.DataMessageString.Get("C_PETEQUIP_TYPENAME1");
    elseif type == PetEquipType.Necklace then
        ret = DataConfig.DataMessageString.Get("C_MONSTERSOUL_XIANGQUAN");
    elseif type == PetEquipType.ClawCover then
        ret = DataConfig.DataMessageString.Get("C_PETEQUIP_TYPENAME2");
    elseif type == PetEquipType.FuDai then
        ret = DataConfig.DataMessageString.Get("C_PETEQUIP_TYPENAME3");
    elseif type == 211 then
        ret = DataConfig.DataMessageString.Get("C_SOULPEARL_TYPENAME1");
    elseif type == 212 then
        ret = DataConfig.DataMessageString.Get("C_SOULPEARL_TYPENAME2");
    elseif type == 213 then
        ret = DataConfig.DataMessageString.Get("C_SOULPEARL_TYPENAME3");
    elseif type == 214 then
        ret = DataConfig.DataMessageString.Get("C_SOULPEARL_TYPENAME4");
    elseif type == 215 then
        ret = DataConfig.DataMessageString.Get("C_SOULPEARL_TYPENAME5");
    elseif type == 216 then
        ret = DataConfig.DataMessageString.Get("C_SOULPEARL_TYPENAME6");
    elseif type == 217 then
        ret = DataConfig.DataMessageString.Get("C_SOULPEARL_TYPENAME7");
    elseif type == 218 then
        ret = DataConfig.DataMessageString.Get("C_SOULPEARL_TYPENAME8");
    elseif type == 219 then
        ret = DataConfig.DataMessageString.Get("C_SOULPEARL_TYPENAME9");
    elseif type == 220 then
        ret = DataConfig.DataMessageString.Get("C_SOULPEARL_TYPENAME10");
    elseif type == MountEquipType.Face then
        ret = DataConfig.DataMessageString.Get("C_MOUNT_EQUIP_TYPE_PART_FACE");
    elseif type == MountEquipType.Heart then
        ret = DataConfig.DataMessageString.Get("C_MOUNT_EQUIP_TYPE_PART_HEART");
    elseif type == MountEquipType.Ring then
        ret = DataConfig.DataMessageString.Get("C_MOUNT_EQUIP_TYPE_PART_RING");
    elseif type == MountEquipType.Foot then
        ret = DataConfig.DataMessageString.Get("C_MOUNT_EQUIP_TYPE_PART_FOOT");
    elseif type == EquipmentType.Weapon then
        ret = DataConfig.DataMessageString.Get("C_EQUIP_NAME_WEAPON");
    elseif type == EquipmentType.Necklace then
        ret = DataConfig.DataMessageString.Get("C_EQUIP_NAME_NECKLACE");
    elseif type == EquipmentType.Helmet then
        ret = DataConfig.DataMessageString.Get("C_EQUIP_NAME_HELMET");
    elseif type == EquipmentType.Clothes then
        ret = DataConfig.DataMessageString.Get("C_EQUIP_NAME_CLOTHES");
    elseif type == EquipmentType.Belt then
        ret = DataConfig.DataMessageString.Get("C_EQUIP_NAME_YAODAI");
    elseif type == EquipmentType.LegGuard then
        ret = DataConfig.DataMessageString.Get("C_EQUIP_NAME_BELT");
    elseif type == EquipmentType.Shoe then
        ret = DataConfig.DataMessageString.Get("C_EQUIP_NAME_SHOE");
    elseif type == EquipmentType.FingerRing then
        ret = DataConfig.DataMessageString.Get("C_EQUIP_NAME_FINGERRING");
    elseif type == EquipmentType.Bracelet then
        ret = DataConfig.DataMessageString.Get("C_EQUIP_NAME_Bracelet");
    elseif type == EquipmentType.EarRings then
        ret = DataConfig.DataMessageString.Get("C_EQUIP_NAME_EarRings");
    elseif type == EquipmentType.Badge then
        ret = DataConfig.DataMessageString.Get("C_EQUIP_NAME_Badge");
    elseif type == UnreadEquipType.TouKui then-- Phantom helmet
        ret = DataConfig.DataMessageString.Get("C_UNREAL_EQUIP_TYPE1");
    elseif type == UnreadEquipType.ErHuan then-- Phantom earrings
        ret = DataConfig.DataMessageString.Get("C_UNREAL_EQUIP_TYPE2");
    elseif type == UnreadEquipType.XiangLian then-- Fantasy necklace
        ret = DataConfig.DataMessageString.Get("C_UNREAL_EQUIP_TYPE3");
    elseif type == UnreadEquipType.YiFu then-- Fantasy clothes
        ret = DataConfig.DataMessageString.Get("C_UNREAL_EQUIP_TYPE4");
    elseif type == UnreadEquipType.KuZi then-- Fantasy trousers
        ret = DataConfig.DataMessageString.Get("C_UNREAL_EQUIP_TYPE5");
    elseif type == UnreadEquipType.WuQi then-- Phantom Weapon
        ret = DataConfig.DataMessageString.Get("C_UNREAL_EQUIP_TYPE6");
    elseif type == UnreadEquipType.HuWan then-- Phantom wrist guard
        ret = DataConfig.DataMessageString.Get("C_UNREAL_EQUIP_TYPE7");
    elseif type == UnreadEquipType.XieZi then-- Fantasy shoes
        ret = DataConfig.DataMessageString.Get("C_UNREAL_EQUIP_TYPE8");
    elseif type == UnreadEquipType.JieZhi then-- Fantasy ring
        ret = DataConfig.DataMessageString.Get("C_UNREAL_EQUIP_TYPE9");
    elseif type == UnreadEquipType.ShouZHuo then-- Fantasy bracelet
        ret = DataConfig.DataMessageString.Get("C_UNREAL_EQUIP_TYPE10");
    end
    return ret;
end

-- Get the item type name
function LuaItemBase.GetTypeNameWitType(type)
    local ret = nil;
    if type == ItemType.Equip then
        ret = DataConfig.DataMessageString.Get("C_ITEM_NAME_EQUIP")
    elseif type == ItemType.Money then
        ret = DataConfig.DataMessageString.Get("C_BACKPACKBAG_CURRENCY")
    elseif type == ItemType.Effect then
        ret = DataConfig.DataMessageString.Get("C_ITEMTYPE_EFFECTITEM");
    elseif type == ItemType.Material then
        ret = DataConfig.DataMessageString.Get("C_ITEM_NAME_MATERIAL");
    elseif type == ItemType.GemStone then
        ret = DataConfig.DataMessageString.Get("C_ITEMTYPE_DIAMAND");
    elseif type == ItemType.GiftPack then
        ret = DataConfig.DataMessageString.Get("C_ITEM_NAME_GIFT");
    elseif type == ItemType.SpecialPingZiItem then
        ret = DataConfig.DataMessageString.Get("C_ITEM_NAME_SUIPIAN");
    elseif type == ItemType.Gift then
        ret = DataConfig.DataMessageString.Get("C_ITEMTYPE_GIFT");
    elseif type == ItemType.Normal then
        ret = DataConfig.DataMessageString.Get("C_ITEM_NAME_NORMAL");
    elseif type == ItemType.Special then
        ret = DataConfig.DataMessageString.Get("C_ITEM_NAME_SPECIAL");
    elseif type == ItemType.Title then
        ret = DataConfig.DataMessageString.Get("TITLE_SYSTEM");
    elseif type == ItemType.HolyEquip then
        ret = DataConfig.DataMessageString.Get("ShenZhuang");
    elseif type == ItemType.SpecialBox then
        ret = DataConfig.DataMessageString.Get("C_ITEMTYPE_BOXS");
    elseif type == ItemType.ChangeJob then
        ret = DataConfig.DataMessageString.Get("C_ITEMTYPE_CHANGEJOB");
    elseif type == ItemType.XiShui then
        ret = DataConfig.DataMessageString.Get("C_ITEMTYPE_XISHUI");
    elseif type == ItemType.VipExp then
        ret = DataConfig.DataMessageString.Get("C_ITEMTYPE_VIPEXE");
    elseif type == ItemType.LingPo then
        ret = DataConfig.DataMessageString.Get("C_ITEMTYPE_LINGPO");
    elseif type == ItemType.ImmortalEquip then
        ret = DataConfig.DataMessageString.Get("C_XIANJIA");
    elseif type == ItemType.PetEquip then
        ret = DataConfig.DataMessageString.Get("C_ITEMTYPE_PETEQUIP");
    elseif type == ItemType.HorseEquip then
        ret = DataConfig.DataMessageString.Get("C_ITEMTYPE_HORSEEQUIP");
    elseif type == ItemType.DevilSoulEquip then
        ret = DataConfig.DataMessageString.Get("C_ITEMTYPE_DEVIL_SOUL_EQUIP");
    elseif type == ItemType.DevilSoulChip then
        ret = DataConfig.DataMessageString.Get("C_ITEMTYPE_DEVIL_SOUL_EQUIPCLIP");
    elseif type == ItemType.UnrealEquip then
        ret = DataConfig.DataMessageString.Get("C_UNREAL_EQUIP");
    elseif type == ItemType.UnrealEquipChip then
        ret = DataConfig.DataMessageString.Get("C_UNREAL_EQUIP_CHIP");
    end
    return ret;
end

-- Get ICON of equipment and items
function LuaItemBase.GetItemIcon(id)
    local retString = 0;
    if (id >= 1000000) then
        local item = DataConfig.DataEquip[id];
        if item then
            retString = item.Icon;
        end
    else
        local item = DataConfig.DataItem[id];
        if item then
            retString = item.Icon;
        end
    end

    return retString;
end
-- Get the name of the equipment and items
function LuaItemBase.GetItemName(id)
    local retString = "";
    if (id >= 1000000) then
        local item = DataConfig.DataEquip[id];
        if item then
            retString = item.Name;
        end
    else
        local item = DataConfig.DataItem[id];
        if item then
            retString = item.Name;
        end
    end

    return retString;
end

function LuaItemBase.GetQualityStr(quality)
    if quality == QualityCode.Green then
        return DataConfig.DataMessageString.Get("C_GUILD_SORT_QUALITY_GREEN")
    elseif quality == QualityCode.Blue then
        return DataConfig.DataMessageString.Get("C_GUILD_SORT_QUALITY_BLUE")
    elseif quality == QualityCode.Violet then
        return DataConfig.DataMessageString.Get("C_GUILD_SORT_QUALITY_PURPLE")
    elseif quality == QualityCode.Orange then
        return DataConfig.DataMessageString.Get("C_GUILD_SORT_QUALITY_ORANGE")
    elseif quality == QualityCode.Golden then
        return DataConfig.DataMessageString.Get("C_GUILD_SORT_QUALITY_GOLD")
    elseif quality == QualityCode.Red then
        return DataConfig.DataMessageString.Get("C_GUILD_SORT_QUALITY_RED")
    elseif quality == QualityCode.Pink then
        return DataConfig.DataMessageString.Get("Pink_Color")
    elseif quality == QualityCode.DarkGolden then
        return DataConfig.DataMessageString.Get("C_COLOR_DARKGOLD")
    elseif quality == QualityCode.Colorful then
        return DataConfig.DataMessageString.Get("C_COLOR_HUANCAI")
    end
    return "";
end
return LuaItemBase