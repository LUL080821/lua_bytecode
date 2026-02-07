------------------------------------------------
-- Author: 
-- Date: 2019-05-07
-- File: LuaEventHander.lua
-- Module: LuaEventHander
-- Description: Event handling system
------------------------------------------------
local LuaEventHander = require("Common.CustomLib.LuaEventManager.LuaEventHander");
local CSGameCenter = CS.Thousandto.Code.Center.GameCenter;

-- Event Manager
local LuaEventManager = {
    EventList = List:New()
}

-- Register event function
function LuaEventManager.RegFixEventHandle(id, func, caller)
    local idx = LuaEventManager.FindLuaEventHander(id,func,caller);
    if idx < 0 then
        local eh = LuaEventHander:New(id,func,caller);        
        eh.EventRet = CSGameCenter.RegFixEventHandle(eh.EventID, eh.Handler);
        LuaEventManager.EventList:Add(eh);
    end
end

-- Trigger event
function LuaEventManager.PushFixEvent(id,  obj, sender)
    CSGameCenter.PushFixEvent(id, obj, sender);
end

-- Uninstall event function
function LuaEventManager.UnRegFixEventHandle(id, func, caller)
   local idx = LuaEventManager.FindLuaEventHander(id,func,caller);
   if idx > 0 then
       local eh = LuaEventManager.EventList[idx];
       if eh ~= nil then
            CSGameCenter.UnRegFixEventHandle(eh.EventID, eh.EventRet);
       end
       LuaEventManager.EventList:RemoveAt(idx);
   end
end

-- Find event functions
function LuaEventManager.FindLuaEventHander(id, func, caller)
    local es = LuaEventManager.EventList;
    for i = 1, es:Count() do
        if(es[i].EventID == id  and es[i].Func == func and es[i].Caller == caller) then
            return i;
        end
    end
    return -1;
end

-- Clean up all Lua-side event functions
function LuaEventManager.ClearAllLuaEvents()
    local es = LuaEventManager.EventList; 
    for i = 1, es:Count() do       
       CSGameCenter.UnRegFixEventHandle(es[i].EventID, es[i].EventRet);
    end
    LuaEventManager.EventList:Clear();
end

return LuaEventManager;
