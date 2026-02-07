------------------------------------------------
-- Author: 
-- Date: 2021-02-26
-- File: LoadingSystem.lua
-- Module: LoadingSystem
-- Description: System that loads the interface
------------------------------------------------
local LoadingSystem = {    
    -- Triggered after the form is opened to avoid some interfaces being closed in advance
    OnLoadingFormOpened = nil,
    -- Determines that the form open message has been sent
    IsOpen = false,
    -- Is it currently being displayed - this is mainly to prevent OnLoadingFormOpened from triggering multiple times.
    IsFormShowing = false,
}

-- Open loadingForm
function LoadingSystem:Open(formOpendCallback)    
    if self.IsFormShowing == true and self.IsOpen == true then
        formOpendCallback();
    else
        self.OnLoadingFormOpened = formOpendCallback;
        GameCenter.PushFixEvent(UIEventDefine.UILOADINGFORM_OPEN);
        self.IsOpen = true;
    end
    
end

-- closure
function LoadingSystem:Close()
    self.OnLoadingFormOpened = nil
    GameCenter.PushFixEvent(UIEventDefine.UILOADINGFORM_CLOSE);
    self.IsOpen = false;
end

-- Set the progress text of the Loading form
function LoadingSystem:SetProgressText(text)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UILOADINGFORM_SHOW_PROGRESS_TEXT, text);
end

-- Set the progress of the form
function LoadingSystem:SetProgress(progress)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UILOADINGFORM_SHOW_PROGRESS, progress);
end

-- Setting up Tips
function LoadingSystem:SetTips(text)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UILOADINGFORM_SHOW_TIPS, text);
end

-- Set whether it is being displayed, this method is called when ShowAfter and HideAfter.
function LoadingSystem:SetShowing(value)
    if self.IsFormShowing ~= value then
        self.IsFormShowing = value;
        if self.IsFormShowing then
            if self.OnLoadingFormOpened then
                self.OnLoadingFormOpened();
                self.OnLoadingFormOpened = nil;
            end            
        end
    end
end

return LoadingSystem