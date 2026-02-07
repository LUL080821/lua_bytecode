------------------------------------------------
-- Author:
-- Date: 2021-03-03
-- File: NewItemContianerSystem.lua
-- Module: NewItemContianerSystem
-- Description: Backpack Management
------------------------------------------------
local L_ContianerModel = require("Logic.Item.ItemContianerModel")
local L_ItemBase = CS.Thousandto.Code.Logic.ItemBase
local NewItemContianerSystem = {
    CacheList = List:New(),
    ItemContianerDic = Dictionary:New(),
}

-- Obtain container information according to container type
function NewItemContianerSystem:GetBackpackModelByType(type)
    return self.ItemContianerDic[type];
end

-- Setting up containers
function NewItemContianerSystem:SetBackpackModelByType(type, model)
    if model and LuaContainerType.ITEM_LOCATION_COUNT > type then
        self.ItemContianerDic:Add(type, model);
    end
end

-- Obtain item information according to UID and container type
function NewItemContianerSystem:GetItemByUID(type, uid)
    local retItem = nil;
    local bpModel = self:GetBackpackModelByType(type)
    if bpModel then
        retItem = bpModel:GetItemByUID(uid)
    end
    return retItem;
end

function NewItemContianerSystem:GetItemListNOGC(type)
    self.CacheList:Clear()
    local bpModel = self:GetBackpackModelByType(type)
    if bpModel then
        bpModel.ItemsOfIndex:Foreach(function(k, v)
            if v then
                self.CacheList:Add(v)
            end
        end)
    end
    return self.CacheList
end

-- Update items
function NewItemContianerSystem:UpdateItemFromContainer(type, item, isNew, resonCode, pushEvent)
    if not resonCode then
        resonCode = 0
    end
    if pushEvent == nil then
        pushEvent = true
    end
    if item.cdTime and item.cdTime > 0 then
        item.cdTime = item.cdTime / 1000
    end
    local retIndex = -1;
    local bpModel = self:GetBackpackModelByType(type);
    if bpModel and item then
        local itemBase = nil;
        itemBase = LuaItemBase.CreateItemBaseByMsg(item)
        if itemBase and itemBase.Type == ItemType.ImmortalEquip and type == LuaContainerType.ITEM_LOCATION_BACKEQUIP then
            itemBase.Index = itemBase.Part;
        end
        itemBase.IsNew = isNew;

        if (isNew and type == LuaContainerType.ITEM_LOCATION_BAG) then
            -- Boot detection
            GameCenter.GuideSystem:Check(GuideTriggerType.GetItem, item.itemModelId);
        end
        if itemBase then
            itemBase.ContainerType = type;
            if (type == LuaContainerType.ITEM_LOCATION_PETEQUIP or type == LuaContainerType.ITEM_LOCATION_MOUNTEQUIP or type == LuaContainerType.ITEM_LOCATION_DEVILEQUIP or type == LuaContainerType.ITEM_LOCATION_PEREAL or type == LuaContainerType.ITEM_LOCATION_IMMORTAL) then
                itemBase.Index = bpModel:GetNewImmortalEquipIndex();
            end
            local _oldCount = 0
            local _oldItem = bpModel:GetItemByUID(itemBase.DBID);
            if _oldItem ~= nil then
                _oldCount = _oldItem.Count
            end
            local _newCount = itemBase.Count
            retIndex = bpModel:UpdateItem(itemBase);
            if(type == LuaContainerType.ITEM_LOCATION_BAG or type == LuaContainerType.ITEM_LOCATION_IMMORTAL) then
                GameCenter.GetNewItemSystem:AddShowTips(itemBase, resonCode, _newCount - _oldCount)
            end
        end
        if pushEvent then
            self:UpdateContianerItems(type, itemBase);
        end
    end
    return retIndex;
end

-- When updating items, send update information to the corresponding container
function NewItemContianerSystem:UpdateContianerItems(type, obj)
    if type == LuaContainerType.ITEM_LOCATION_BAG or type == LuaContainerType.ITEM_LOCATION_IMMORTAL then
        GameCenter.PushFixEvent(LogicEventDefine.EVENT_BACKFORM_ITEM_UPDATE, obj);
    elseif type == LuaContainerType.ITEM_LOCATION_STORAGE then
        GameCenter.PushFixEvent(LogicEventDefine.EVENT_STORAGE_ITEM_UPDATE, obj);
    elseif type == LuaContainerType.ITEM_LOCATION_EQUIP or type == LuaContainerType.ITEM_LOCATION_BACKEQUIP then
        GameCenter.PushFixEvent(LogicEventDefine.EVENT_EQUIPMENTFORM_ITEM_UPDATE, obj);
    elseif type == LuaContainerType.ITEM_LOCATION_CLEAR then
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_CLEARBAG_UPDATE, obj);
    end
end

-- Delete props
function NewItemContianerSystem:DeleteItemFromContainer(type, uid)
    local bpModel = self:GetBackpackModelByType(type);
    if bpModel then
        local item = bpModel:GetItemByUID(uid)
        bpModel:DeleteItem(uid);

        -- After successfully deleting an item, you need to close tips
        GameCenter.ItemTipsMgr:Close()

        self:UpdateContianerItems(type, item);
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_BACKFORM_ITEM_UNSELCT);
    end
end

-- Organize your backpack, and organize it by the client\
function NewItemContianerSystem:SortBag(type)
    local bpModel = self:GetBackpackModelByType(type);
    if bpModel then
        bpModel:SortBag()
    end
end

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- New pet equipment backpack
function NewItemContianerSystem:ResPetEquipAdd(result)
    if result.itemInfo then
        self:UpdateItemFromContainer(LuaContainerType.ITEM_LOCATION_PETEQUIP, result.itemInfo, true, result.reason, true);

        -- Send new item message
        local itemBase = self:GetItemByUID(LuaContainerType.ITEM_LOCATION_PETEQUIP, result.itemInfo.itemId);
        if itemBase == nil then
            return;
        end

        -- Display item acquisition effect
        GameCenter.GetNewItemSystem:AddShowItem(result.reason, itemBase:GetCSObj(), itemBase.CfgID, itemBase.Count)
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EVENT_PETEQUIP_BAGCHANGE);
end


-- Pet equipment backpack removal
function NewItemContianerSystem:ResPetEquipDelete(result)
    self:DeleteItemFromContainer(LuaContainerType.ITEM_LOCATION_PETEQUIP, result.itemId);
    GameCenter.PushFixEvent(LogicLuaEventDefine.EVENT_PETEQUIP_BAGCHANGE);
end

-- Pet equipment backpack item information, pushed to players when it is online
function NewItemContianerSystem:ResPetEquipBagInfos(result)
    local imModel = self:GetBackpackModelByType(LuaContainerType.ITEM_LOCATION_PETEQUIP);
    if imModel == nil then
        imModel = L_ContianerModel:New()
        imModel.ContainerType = LuaContainerType.ITEM_LOCATION_PETEQUIP;
        self:SetBackpackModelByType(LuaContainerType.ITEM_LOCATION_PETEQUIP, imModel);
    end
    imModel:Clear();
    imModel.AllCount = 200;
    imModel.OpenedCount = 200;
    if result.itemInfoList then
        for i = 1, #result.itemInfoList do
            self:UpdateItemFromContainer(LuaContainerType.ITEM_LOCATION_PETEQUIP, result.itemInfoList[i], true, 0, true);
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EVENT_PETEQUIP_BAGCHANGE);
end

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- --------------------------------------------------------------------------------------------------------------------------------
-- New mount equipment backpack
function NewItemContianerSystem:ResHorseEquipAdd(result)
    if result.itemInfo then
        self:UpdateItemFromContainer(LuaContainerType.ITEM_LOCATION_MOUNTEQUIP, result.itemInfo, true, result.reason, true);

        -- Send new item message
        local itemBase = self:GetItemByUID(LuaContainerType.ITEM_LOCATION_MOUNTEQUIP, result.itemInfo.itemId);
        if itemBase == nil then
            return;
        end

        -- Display item acquisition effect
        GameCenter.GetNewItemSystem:AddShowItem(result.reason, itemBase:GetCSObj(), itemBase.CfgID, itemBase.Count)
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EVENT_MOUNTEQUIP_BAGCHANGE);
end


-- Mount equipment backpack delete
function NewItemContianerSystem:ResHorseEquipDelete(result)
    self:DeleteItemFromContainer(LuaContainerType.ITEM_LOCATION_MOUNTEQUIP, result.itemId);
    GameCenter.PushFixEvent(LogicLuaEventDefine.EVENT_MOUNTEQUIP_BAGCHANGE);
end

-- Mount equipment backpack item information, push to players when it is online
function NewItemContianerSystem:ResHorseEquipBagInfos(result)
    local imModel = self:GetBackpackModelByType(LuaContainerType.ITEM_LOCATION_MOUNTEQUIP);
    if imModel == nil then
        imModel = L_ContianerModel:New()
        imModel.ContainerType = LuaContainerType.ITEM_LOCATION_MOUNTEQUIP;
        self:SetBackpackModelByType(LuaContainerType.ITEM_LOCATION_MOUNTEQUIP, imModel);
    end
    imModel:Clear();
    imModel.AllCount = 200;
    imModel.OpenedCount = 200;
    if result.itemInfoList then
        for i = 1, #result.itemInfoList do
            self:UpdateItemFromContainer(LuaContainerType.ITEM_LOCATION_MOUNTEQUIP, result.itemInfoList[i], true, 0, true);
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EVENT_MOUNTEQUIP_BAGCHANGE);
end
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Demon Soul Equipment Backpack Added
function NewItemContianerSystem:ResDevilEquipAdd(result)
    if result.itemInfo then
        self:UpdateItemFromContainer(LuaContainerType.ITEM_LOCATION_DEVILEQUIP, result.itemInfo, true, result.reason, true);

        -- Send new item message
        local itemBase = self:GetItemByUID(LuaContainerType.ITEM_LOCATION_DEVILEQUIP, result.itemInfo.itemId);
        if itemBase == nil then
            return;
        end

        -- Display item acquisition effect
        GameCenter.GetNewItemSystem:AddShowItem(result.reason, itemBase:GetCSObj(), itemBase.CfgID, itemBase.Count)
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_DEVILEQUIP_BAGCHANGE);
end


-- Delete the magic soul equipment backpack
function NewItemContianerSystem:ResDevilEquipDelete(result)
    self:DeleteItemFromContainer(LuaContainerType.ITEM_LOCATION_DEVILEQUIP, result.itemId);
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_DEVILEQUIP_BAGCHANGE);
end

-- Demon Soul Equipment Backpack Item Information, Push it to players when it is online
function NewItemContianerSystem:ResDevilEquipBagInfos(result)
    local imModel = self:GetBackpackModelByType(LuaContainerType.ITEM_LOCATION_DEVILEQUIP);
    if imModel == nil then
        imModel = L_ContianerModel:New()
        imModel.ContainerType = LuaContainerType.ITEM_LOCATION_DEVILEQUIP;
        self:SetBackpackModelByType(LuaContainerType.ITEM_LOCATION_DEVILEQUIP, imModel);
    end
    imModel:Clear();
    imModel.AllCount = 200;
    imModel.OpenedCount = 200;
    if result.itemInfoList then
        for i = 1, #result.itemInfoList do
            self:UpdateItemFromContainer(LuaContainerType.ITEM_LOCATION_DEVILEQUIP, result.itemInfoList[i], true, 0, true);
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_DEVILEQUIP_BAGCHANGE);
end
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- New backpack
function NewItemContianerSystem:ResAddSoulArmorBall(result)
    if result.balls then
        for i = 1, #result.balls do
            self:UpdateItemFromContainer(LuaContainerType.ITEM_LOCATION_PEREAL, result.balls[i], true, result.reason, true);
            -- Send new item message
            local itemBase = self:GetItemByUID(LuaContainerType.ITEM_LOCATION_PEREAL, result.balls[i].itemId);
            if itemBase == nil then
                return;
            end
            -- Display item acquisition effect
            GameCenter.GetNewItemSystem:AddShowItem(result.reason, itemBase:GetCSObj(), itemBase.CfgID, itemBase.Count)
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EVENT_SOULEQUIPPERAL_BAGCHANGE);
end

-- Backpack removal
function NewItemContianerSystem:ResDelSoulArmorBall(result)
    if result.ids then
        for i = 1, #result.ids do
            self:DeleteItemFromContainer(LuaContainerType.ITEM_LOCATION_PEREAL, result.ids[i]);
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EVENT_SOULEQUIPPERAL_BAGCHANGE);
end

-- Backpack item information, push to players when it is online
function NewItemContianerSystem:ResSoulArmorBag(result)
    local imModel = self:GetBackpackModelByType(LuaContainerType.ITEM_LOCATION_PEREAL);
    if imModel == nil then
        imModel = L_ContianerModel:New();
        imModel.ContainerType = LuaContainerType.ITEM_LOCATION_PEREAL
        self:SetBackpackModelByType(LuaContainerType.ITEM_LOCATION_PEREAL, imModel);
    end
    imModel:Clear();
    local gCfg = DataConfig.DataGlobal[GlobalName.Born_Bag_Num]
    if gCfg then
        local ar = Utils.SplitStr(gCfg.Params, '_')
        if #ar >= 2 then
            local AllNum = tonumber(ar[2]);
            imModel.AllCount = AllNum;
            imModel.OpenedCount = AllNum;
        end
    end
    if result.balls then
        for i = 1, #result.balls do
            self:UpdateItemFromContainer(LuaContainerType.ITEM_LOCATION_PEREAL, result.balls[i], true, 0, true);
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EVENT_SOULEQUIPPERAL_BAGCHANGE);
end
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
return NewItemContianerSystem