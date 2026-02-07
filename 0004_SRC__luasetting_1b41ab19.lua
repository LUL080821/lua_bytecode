local Debug = require "Common.CustomLib.Utility.Debug"
------------------------------------------------
-- Author: 
-- Date: 2019-03-25
-- File: LuaSetting.lua
-- Module: LuaSetting
-- Description: Some settings processed by Lua, the first code to be executed
------------------------------------------------

local LuaSetting = {
    -- Use lua.bytes in the Config directory
    UseLuaBytes = 0,
}

-- Get int
function LuaSetting.GetInt(strName)
    local result =  LuaSetting[strName];
    if result then
        return result;
    end
    return -1;
end


return LuaSetting
