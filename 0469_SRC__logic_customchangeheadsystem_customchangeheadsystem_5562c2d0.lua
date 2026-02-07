
------------------------------------------------
-- Author:
-- Date: 2021-08-11
-- File: CustomChangeHeadSystem.lua
-- Module: CustomChangeHeadSystem
-- Description: Custom avatar change system class
------------------------------------------------

local CustomChangeHeadSystem = {    
    CurSelectIconId = nil,
    CurSelectFrameId = nil,

}

function CustomChangeHeadSystem:Initialize()
end

function CustomChangeHeadSystem:UnInitialize()

end

function CustomChangeHeadSystem:GetTotalActiveList()
    
end


function CustomChangeHeadSystem:ReqPlayerSettingCustomHead(path , IsUseCustomHead)
    local _msg = ReqMsg.MSG_Player.ReqPlayerSettingCustomHead:New()
    _msg.customHeadPath = path
    _msg.useCustomHead = IsUseCustomHead
    _msg:Send()
end




return CustomChangeHeadSystem
