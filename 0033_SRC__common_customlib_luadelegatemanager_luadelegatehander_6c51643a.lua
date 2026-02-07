------------------------------------------------
-- Author:
-- Date: 2019-05-29
-- File: LuaDelegateHander.lua
-- Module: LuaDelegateHander
-- Description: Definition of a delegate handle
------------------------------------------------
-- Delegate handle definition
local LuaDelegateHander={
    -- Quote count
    Ref = 0,
    -- Function caller
    Caller = nil,
    -- function
    Func = nil,
    -- The event handle formed
    Handler = nil;
};

-- New Event Handler
function LuaDelegateHander:New(func, caller)
    local _m = Utils.DeepCopy(self);
    _m.Caller = caller;
    _m.Func = func;
    _m.Ref = 1;
    if caller == nil then
        _m.Handler = func;
    else
        _m.Handler = Utils.Handler(func,caller);
    end
    return _m;
end

-- --Reference count plus one
function LuaDelegateHander:IncRef()
    self.Ref = self.Ref + 1
end

-- Reference count is reduced by one
function LuaDelegateHander:DecRef()
    self.Ref = self.Ref - 1
end

return LuaDelegateHander;