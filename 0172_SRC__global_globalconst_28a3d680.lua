------------------------------------------------
-- author:
-- Date: 2019-03-25
-- File: GlobalConst.lua
-- Module: GlobalConst
-- Description: Definition of global constants
------------------------------------------------

local GlobalConst = {
     -- Open the event ID of the URL
     OpenURLEventID = 102
}



-- The table is processed here, only reading is allowed, and settings are not allowed
local L_MetaTable = {}

L_MetaTable.__index = function(table,key)
    return GlobalConst[key];
end

L_MetaTable.__newindex = function(table,key,value)            
    Debug.LogError("Hi! Hi! Don't play fire!" .. tostring(key) .. "::" .. tostring(value));
end

local L_RetTable = setmetatable({},L_MetaTable);
return L_RetTable