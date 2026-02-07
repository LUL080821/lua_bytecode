------------------------------------------------
-- Author:
-- Date: 2021-03-03
-- File: ItemContianerModel.lua
-- Module: ItemContianerModel
-- Description: Backpack container class
------------------------------------------------
local ItemContianerModel = {
    -- Backpack space quantity warning
    BAG_SPACE_COUNT_WARNNING = 10,
    AllCount = 0,
    OpenedCount = 0,
    ItemsOfUID = Dictionary:New(),
    ItemsOfIndex = Dictionary:New(),
    NowOpenIndex = 0,
    UseTime = 0,
    ContainerType = LuaContainerType.ITEM_LOCATION_BAG,
    RemainSpaceCount = 0,
    -- Is it initialized?
    IsInitializing = false,
    ItemCounts = Dictionary:New(),
}
function ItemContianerModel:SetOpenCount(count)
    self.OpenedCount = count
    self:UpdateRemainCount()
end

function ItemContianerModel:New()
    local _m = Utils.DeepCopy(self)
    _m.AllCount = 0;
    _m.OpenedCount = 0;
    _m.UseTime = 0;
    _m.NowOpenIndex = 0;
    return _m
end

-- Obtain item information based on DBID
function ItemContianerModel:GetItemByUID(uid)
    return self.ItemsOfUID[uid]
end

-- Obtain item information based on the location of the item in the container
function ItemContianerModel:GetItemByIndex(index)
    return self.ItemsOfIndex[index]
end

-- Obtain the item according to the item ID and obtain the first one of the container
function ItemContianerModel:GetItemByID(id)
    local ret = nil
    self.ItemsOfUID:ForeachCanBreak(function(k, v)
        if v and v.CfgID == id then
            ret = v
            return true
        end
    end)
    return ret
end

-- Get all items in the container with id information
function ItemContianerModel:GetItemListByCfgID(id)
    local ret = List:New()
    self.ItemsOfUID:Foreach(function(k, v)
        if v and v.CfgID == id then
            ret:Add(v)
        end
    end)
    return ret
end

-- Get item list based on item type
function ItemContianerModel:GetItemListByType(type)
    local ret = List:New()
    self.ItemsOfUID:Foreach(function(k, v)
        if (type ~= ItemType.UnDefine) then
            if v and v.Type == type then
                ret:Add(v)
            end
        else
            if v and v.Type ~= ItemType.Equip and v.Type ~= ItemType.ImmortalEquip then
                ret:Add(v)
            end
        end
    end)
    return ret;
end

-- Get all the items in the container
function ItemContianerModel:GetItemList()
    local ret = List:New()
    self.ItemsOfUID:Foreach(function(k, v)
        if v then
            ret:Add(v)
        end
    end)
    return ret
end

-- Get a list of items based on the large type of items
function ItemContianerModel:GetItemListByItemBigType(type)
    local ret = nil;
    if type == ItemBigType.UnDefine or type == ItemBigType.All then
        ret = self:GetItemList()
    elseif type == ItemBigType.Equip then
        ret = self:GetItemListByType(ItemType.Equip)
    elseif type == ItemBigType.ImmortalEquip then
        ret = self:GetItemListByType(ItemType.ImmortalEquip)
    elseif type == ItemBigType.Other then
        ret = self:GetItemListByType(ItemType.UnDefine)
    end
    self.ListSort(ret, true);
    return ret;
end

-- Obtain items at a certain location according to the large type of items
function ItemContianerModel:GetItemByBigTypeAndIndex(type, index)
    if (index <= 0 or index > #self.ItemsOfUID) then
        return nil;
    end
    local ret = nil
    local indexCounter = 0
    self.ItemsOfUID:ForeachCanBreak(function(k, v)
        if type == ItemBigType.All then
            indexCounter = indexCounter + 1
        elseif type == ItemBigType.Equip then
            if v.Type == ItemType.Equip then
                indexCounter = indexCounter + 1
            end
        elseif type == ItemBigType.ImmortalEquip then
            if v.Type == ItemType.ImmortalEquip then
                indexCounter = indexCounter + 1
            end
        elseif type == ItemBigType.Other then
            if v.Type ~= ItemType.Equip and v.Type ~= ItemType.ImmortalEquip then
                indexCounter = indexCounter + 1
            end
        end
        if indexCounter == index then
            ret = v
            return true
        end
    end)
    return ret;
end

-- Update item information. If the item does not exist, a new one will be created. If it exists, the original value will be modified. Since there is no multi-threading consideration, there will be no problem.
function ItemContianerModel:UpdateItem(item)
    local oldItem = self.ItemsOfIndex[item.Index]
    if oldItem then
        local dbId = oldItem.DBID;
        self.ItemsOfIndex:Remove(item.Index);
        self.ItemsOfUID:Remove(dbId);
        self:ChangeCount(oldItem.CfgID, -oldItem.Count);
    end
    self.ItemsOfIndex:Add(item.Index, item);
    self.ItemsOfUID:Add(item.DBID, item);
    self:ChangeCount(item.CfgID, item.Count);
    return item.Index;
end

-- Delete items
function ItemContianerModel:DeleteItem(uid)
    if (self.ItemsOfUID:ContainsKey(uid)) then
        local item = self.ItemsOfUID[uid];
        self:ChangeCount(item .CfgID, -item.Count);
        self.ItemsOfIndex:Remove(item.Index);
        self.ItemsOfUID:Remove(uid);
    end
end

-- Clear data
function ItemContianerModel:Clear()
    self.ItemsOfIndex:Clear();
    self.ItemsOfUID:Clear();
    self.ItemCounts:Clear();
end

function ItemContianerModel:GetNewImmortalEquipIndex()
    local index = 1;
    for i = 1, self.AllCount do
        if not self.ItemsOfIndex:ContainsKey(i) then
            index = i;
            break;
        end
    end
    return index;
end

function ItemContianerModel:SortBag()
    local list = List:New()
    self.ItemsOfIndex:Foreach(function(k, v)
        list:Add(v);
    end)
    if (self.ContainerType == LuaContainerType.ITEM_LOCATION_PETEQUIP or self.ContainerType == LuaContainerType.ITEM_LOCATION_MOUNTEQUIP or self.ContainerType == LuaContainerType.ITEM_LOCATION_PEREAL or self.ContainerType == LuaContainerType.ITEM_LOCATION_DEVILEQUIP) then
        list:Sort(function(a, b)
            if (a.Power ~= b.Power) then
                return a.Power > b.Power;
            else
                if (a.Quality ~= b.Quality) then
                    return a.Quality > b.Quality;
                else
                    if (a.StarNum ~= b.StarNum) then
                        return a.StarNum > b.StarNum;
                    else
                        if (a.Part ~= b.Part) then
                            return a.Part < b.Part;
                        else
                            return a.CfgID < b.CfgID;
                        end
                    end
                end
            end
        end);
    end
    self.ItemsOfIndex:Clear();
    for i = 1, #list do
        list[i].Index = i;
        self.ItemsOfIndex:Add(i, list[i]);
    end
end

-- Get the number according to the configuration id
function ItemContianerModel:GetCountByCfgId(id)
    local ret = self.ItemCounts[id]
    if ret and ret > 0 then
        return ret
    end
    return 0;
end

-- Update remaining quantity
function ItemContianerModel:UpdateRemainCount()
    local newCnt = self.OpenedCount - #self.ItemsOfIndex;
    if self.RemainSpaceCount ~= newCnt then
        -- Updated for backpacks only
        if self.ContainerType == LuaContainerType.ITEM_LOCATION_BAG then
            if (self.RemainSpaceCount < newCnt) then
                self.RemainSpaceCount = newCnt;
                -- Spaces increase
                GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_WARINGBACKPACKCHANGE, false);

            else
                if not self.IsInitializing then
                    self.RemainSpaceCount = newCnt;
                    -- Space reduction
                    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_WARINGBACKPACKCHANGE, true);
                else
                    if (newCnt < self.BAG_SPACE_COUNT_WARNNING) then
                        self.RemainSpaceCount = newCnt;
                        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_WARINGBACKPACKCHANGE, true);
                    end
                end
            end
        end
        self.RemainSpaceCount = newCnt;
    end
end

function SortAsc(left, right)
    return left.Index < right.Index
end

-- Change the quantity counter
function ItemContianerModel:ChangeCount(cfgId, count)
    local curCount = 0;
    if self.ItemCounts[cfgId] then
        curCount = self.ItemCounts[cfgId]
    end
    curCount = curCount + count;
    if(curCount < 0) then
        curCount = 0;
    end
    self.ItemCounts[cfgId] = curCount;
end
function SortDesc(left, right)
    return right.Index > left.Index
end

-- Sort the list
function ItemContianerModel.ListSort(list, isAsc)
    if list then
        if (isAsc) then
            list:Sort(SortAsc);
        else
            list:Sort(SortDesc);
        end
    end
end
return ItemContianerModel