------------------------------------------------
-- Author:
-- Date: 2021-07-15
-- File: LoverInfo.lua
-- Module: LoverInfo
-- Description: Immortal Couple Information
------------------------------------------------
local LoverInfo = {
    --id
    Id = 0,
    -- grade
    Lv = 0,
    -- name
    Name = "",
    -- Profession
    Caree = 0,
    -- Fighting power
    Power = 0,
    -- Appearance
    VsInfo = nil,
    -- Prepare or not
    IsReady = false,
    -- Whether to refuse
    IsJuJue = false,
    -- Avatar Id
    HeadId = 0,
    -- Avatar frame Id
    FrameHeadId = 0,
    -- Custom avatar path
    HeadPicPath = "",
    -- Whether to use a custom avatar
    IsShowHeadPic = false,
}

function LoverInfo:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

function LoverInfo:ParseMsg(msg)
    if msg == nil then
        return
    end
    self.Id = msg.id
    self.Name = msg.name
    self.Caree = msg.occupation
    self.Power = msg.power
    self.Lv = msg.level
    if msg.facade ~= nil then
        self.VsInfo = PlayerVisualInfo:New()
        self.VsInfo:ParseByLua(msg.facade, 0)
    end
    -- Analyze avatar data
    if msg.head ~= nil then
        self.HeadId = msg.head.fashionHead
        self.FrameHeadId = msg.head.fashionFrame
        self.HeadPicPath = msg.head.customHeadPath
        self.IsShowHeadPic = msg.head.useCustomHead
        self.IsReady = false
    end
end

return LoverInfo