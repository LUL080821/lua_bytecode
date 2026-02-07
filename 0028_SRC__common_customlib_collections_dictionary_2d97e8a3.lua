------------------------------------------------
-- Author:
-- Date: 2019-04-11
-- File: Dictionary.lua
-- Module: Dictionary
-- Description: Dictionary
------------------------------------------------
local Dictionary = {};
Dictionary.__index = Dictionary;
local L_Keys = setmetatable({},{__mode = "k"});

Dictionary.__newindex = function(t, k, v)
    L_Keys[t]:Add(k);
    rawset(t, k, v);
end

-- Create a new Dictionary. tb can nil, isNotCopy default deep copy
function Dictionary:New(tb, isNotCopy)
    local _dict = nil;
    local _isDict = false;
    if tb ~= nil and type(tb) =="table" then
        if isNotCopy then
            _dict = tb;
        else
            _dict = Utils.DeepCopy(tb);
            if getmetatable(_dict) == Dictionary then
                _isDict = true;
            end
        end
    else
        _dict = {};
    end

    if not _isDict then
        setmetatable(_dict, Dictionary);
        _dict:_OnCopyAfter_()
    end
    return _dict;
end

-- Processed after copying
function Dictionary:_OnCopyAfter_()
    L_Keys[self] = List:New();
    for k,_ in pairs(self) do
        L_Keys[self]:Add(k)
    end
    if #L_Keys[self] > 0 then
        local _type = type(L_Keys[self][1]);
        if _type == "string" or _type == "number" then
            table.sort(L_Keys[self])
        end
    end
end

-- Whether to include a key
function Dictionary:ContainsKey(key)
    return self[key] ~= nil;
end
-- Whether to include value
function Dictionary:ContainsValue(value)
    for _, v in pairs(self) do
        if v == value then
            return true
        end
    end
    return false
end
-- Get all keys
function Dictionary:GetKeys()
    -- local _keys = {}
    -- for k, _ in pairs(self) do
    --     table.insert(_keys,k)
    -- end
    -- return _keys
    return L_Keys[self];
end
-- Item quantity
function Dictionary:Count()
    -- return Utils.GetTableLens(self)
    return #L_Keys[self];
end
-- Add a key - value
function Dictionary:Add(key, value)
    if self:ContainsKey(key) then
        Debug.LogError("The key is already in the dictionary! key:", key)
        return
    end
    self[key] = value
end
-- Remove a key - value
function Dictionary:Remove(key)
    if self:ContainsKey(key) then
        self[key] = nil
        L_Keys[self]:Remove(key);
    end
end
-- Clear all
function Dictionary:Clear()
    for k, _ in pairs(self) do
        self[k] = nil;
    end
    L_Keys[self]:Clear();
end

-- Add a dictionary
function Dictionary:AddRange(tb)
    if (tb == nil or type(tb) ~= "table") then
        Debug.LogError('table is invalid!')
        return
    end
    for k, v in pairs(tb) do
        self:Add(k, v)
    end
end

-- Press key to traverse smoothly [cannot interrupt]
function Dictionary:Foreach(func)
    local _keys = L_Keys[self];
    for i=1,#_keys do
        func(_keys[i],self[_keys[i]]);
    end
end

-- Press key to smoothly traverse [interrupt traversal return true]
function Dictionary:ForeachCanBreak(func)
    local _keys = L_Keys[self];
    for i=1,#_keys do
        if func(_keys[i],self[_keys[i]]) then
            break;
        end
    end
end

-- Press key to reverse traversal [cannot interrupt]
function Dictionary:ForeachReverse(func)
    local _keys = L_Keys[self];
    for i=#_keys, 1, -1 do
        func(_keys[i],self[_keys[i]]);
    end
end

-- traverse by key [interrupt traversal return "break"]
function Dictionary:ForeachReverseCanBreak(func)
    local _keys = L_Keys[self];
    for i=#_keys, 1, -1 do
        if func(_keys[i],self[_keys[i]]) == "break" then
            break;
        end
    end
end

-- Sort [Sort by value]
function Dictionary:SortValue(func)
    local _keys = L_Keys[self];
    table.sort(_keys,function(a, b)
        return func(self[a], self[b]);
    end)
end

-- Sort [Sort by key]
function Dictionary:SortKey(func)
    local _keys = L_Keys[self];
    table.sort(_keys,function(a, b)
        return func(a, b);
    end)
end

-- Find
function Dictionary:Get(key)
    return self[key]
end

return Dictionary