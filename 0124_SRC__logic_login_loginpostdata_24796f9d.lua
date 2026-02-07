
------------------------------------------------
-- Author: 
-- Date: 2021-02-26
-- File: LoginPostData.lua
-- Module: LoginPostData
-- Description: Data structure submitted to the server via HTTP
------------------------------------------------
local LoginPostData = {
    -- The unique ID assigned successfully by the server login
    userId="",
    -- Signature sent by logging into the gateway server
    sign="",
    -- The token saved after SDK login
    accessToken="",
    -- Local machine code
    machineCode="",
    -- Timestamp sent by logging into the gateway server
    time="",
    -- Enter the game server ID
    enterServerId="",
    -- Operation of the game server ID that creates the character
    addServerId="",
    -- Operation of the game server ID of the deleted character
    deleteServerId="",
    -- Platform name
    platformName="",
    -- Role ID
    roleId="",
}

-- Constructor
function LoginPostData:New(...)
    local _m = Utils.DeepCopy(self)  
    return _m
end


-- Converter string
function LoginPostData:ToString()
   local _result = "";
   for key, value in pairs(self) do
        if type(value) ~= "function" then
            _result = _result .. key .. "=" .. tostring(value) .. "&"     
        end
   end 
   if #_result > 0 then
        _result = string.sub(_result,1,#_result-1);
   end
   return _result;
end

return LoginPostData