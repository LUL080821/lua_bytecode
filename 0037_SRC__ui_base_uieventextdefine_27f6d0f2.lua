------------------------------------------------
-- Author:
-- Date: 2019-03-25
-- File: UIEventExtDefine.lua
-- Module: UIEventExtDefine
-- Description: UI event definition is used to extend the event defined in UIEventDefine in C#
------------------------------------------------
local L_BASE_ID = EventConstDefine.EVENT_UI_BASE_ID

-- Module definition
local UIEventExtDefine = {    
    -- --------------------------------------------------------------------------------------------------------------------------------
    -- Wait for locking
    UI_WAITING_LOCK_OPEN = 141 + L_BASE_ID,
}

-- Here, flip the Key and Value in Event and save it to _temp.
local _temp = {}
for k, v in pairs(UIEventExtDefine) do
    _temp[v] = k
end

-- Determine if there is an event
function UIEventExtDefine.HasEvent(eID)
    return not (not _temp[eID])
end

return UIEventExtDefine
