------------------------------------------------
-- Author:
-- Date: 2019-04-11
-- File: List.lua
-- Module: List
-- Description: List
------------------------------------------------
local List = {}
List.__index = List

-- Create a new list. obj can nil, isNotCopy default deep copy
function List:New(obj, isNotCopy)
    local _list = nil
    if obj ~= nil then
        if type(obj) =="table" then
            _list = isNotCopy and obj or Utils.DeepCopy(obj)
        else
            _list = {}
            for i = 0, obj.Count - 1 do
                table.insert(_list, obj[i])
            end
        end
    else
        _list = {}
    end
    setmetatable(_list, List)
    return _list
end


-- Add an item
function List:Add(item, index)
    if index then
        table.insert(self, index, item)
    else
        table.insert(self, item)
    end
end
-- To the end of..., add an array
function List:AddRange(tb)
    for i=1, #tb do
        table.insert(self, tb[i])
    end
end
-- Clear all
function List:Clear()
    local _count = self:Count()
    for i=_count, 1, -1 do
        table.remove(self)
    end
end
-- Whether to include the item
function List:Contains(item)
    local _count = self:Count()
    for i=1, _count do
        if self[i] == item then
            return true
        end
    end
    return false
end
-- Number of items
function List:Count()
    return #self
end
-- Follow the predicate(item) function to find the item that meets the requirements
function List:Find(predicate)
    if (predicate == nil or type(predicate) ~= "function") then
        Debug.LogError('predicate is invalid!')
        return
    end
    local _count = self:Count()
    for i=1,_count do
        if predicate(self[i]) then
            return self[i]
        end
    end
    return nil
end

-- Returns the index of the item that appears for the first time in the list, starting from 1, if not, return 0
function List:IndexOf(item)
    local _count = self:Count()
    for i=1,_count do
        if self[i] == item then
            return i
        end
    end
    return 0
end
-- Returns the index of the last item in the list, starting from 1, if not, returns 0
function List:LastIndexOf(item)
    local _count = self:Count()
    for i=_count,1,-1 do
        if self[i] == item then
            return i
        end
    end
    return 0
end
-- Insert item into the position of the list index index, and arrange the following ones backwards in turn.
function List:Insert(item, index)
    table.insert(self, index, item)
end
-- Delete elements from the list (the same item will be deleted)
function List:Remove(item)
    local _idx = self:LastIndexOf(item)
    if (_idx > 0) then
        table.remove(self, _idx)
        self:Remove(item)
    end
end
-- Delete and return the element of the specified index in the list, and the subsequent elements will be moved forward. If the key parameter is omitted, it will be deleted from the last element.
function List:RemoveAt(index)
    return table.remove(self, index)
end
-- Sort by comparison(a,b) function, if comparison is nil, sort the given table in ascending order.
function List:Sort(comparison)
    if comparison == nil then
        table.sort(self)
        return
    end
    if  type(comparison) ~= "function" then
        Debug.LogError('comparison is invalid')
        return
    end
    table.sort(self, comparison)
end

-- Determine whether two arrays are equal
function List:Equal(targetList)
    if targetList ~= nil then
        for i = 1, #targetList do
            if not self:Contains(targetList[i]) then
                return false
            end
        end
    end
    return #targetList == #self
end

-- eg: UIUtils.CSFormat("{0}{1}",_list:Unpack())
function List:Unpack()
    return table.unpack(self);
end

return List