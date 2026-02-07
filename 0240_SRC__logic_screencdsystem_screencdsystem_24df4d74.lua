------------------------------------------------
-- Author:
-- Date: 2019-07-24
-- File: ScreenCDSystem.lua
-- Module: ScreenCDSystem
-- Description: Screen CD effect system
------------------------------------------------

local ScreenCDSystem = {

};

-- Implement C# end functions and display CD effects
function ScreenCDSystem:ShowCDEffect(time, timeText)
    GameCenter.PushFixEvent(UIEventDefine.UICountDownForm_OPEN, {time, timeText})
end

return ScreenCDSystem