------------------------------------------------
-- Author: 
-- Date: 2021-03-18
-- File: UIRoleSkinManager.lua
-- Module: UIRoleSkinManager
-- Description: UIRoleSkin's Manager
------------------------------------------------
local UIRoleSkinCompoentWrap = require("Common.CustomLib.UIRoleSkinManager.UIRoleSkinCompoentWrap")
local UIRoleSkinManager = {    
    UIRoleSkinWrapDict = Dictionary:New(),
}

function UIRoleSkinManager:GetWrap(csUISkinScripts)
   if csUISkinScripts then
        if self.UIRoleSkinWrapDict:ContainsKey(csUISkinScripts) then
            return self.UIRoleSkinWrapDict[csUISkinScripts];
        end
        return UIRoleSkinCompoentWrap:New(csUISkinScripts);
   end
   return nil;   
end

function UIRoleSkinManager:Remove(csUISkinScripts)
    if csUISkinScripts then
        self.UIRoleSkinWrapDict:Remove(csUISkinScripts);
   end
   
end

return UIRoleSkinManager