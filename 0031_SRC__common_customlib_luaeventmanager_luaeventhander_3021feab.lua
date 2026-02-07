------------------------------------------------
-- Author: 
-- Date: 2019-05-07
-- File: LuaEventHander.lua
-- Module: LuaEventHander
-- Description: Definition of event handles
------------------------------------------------
-- Event handle definition
local LuaEventHander={
    -- Event ID
    EventID = nil,
    -- Delegation returned by event
    EventRet = nil,
    -- Function caller
    Caller = nil,
    -- function
    Func = nil,
    -- The event handle formed
    Handler = nil;
};

-- New Event Handler
function LuaEventHander:New(id, func, caller)
    local _m = Utils.DeepCopy(self);
    _m.EventID = id;
    _m.Caller = caller;
    _m.Func = func;
    if caller == nil then
        _m.Handler = func;
    else
        _m.Handler = Utils.Handler(func,caller);
    end
    return _m;
end

return LuaEventHander;