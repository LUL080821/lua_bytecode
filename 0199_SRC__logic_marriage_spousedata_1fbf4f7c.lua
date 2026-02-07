
------------------------------------------------
-- Author: 
-- Date: 2019-05-5
-- File: SpouseData.lua
-- Module: SpouseData
-- Description: Spouse's data
------------------------------------------------
local SpouseData =
{
    -- Role ID
    PlayerID = 0,
    Name = nil,
    -- Profession
    Career = nil,
    -- Realm level
    StateLv = 0,
    Intimacy = 0,
    -- Appearance data
    VisInfo = nil,
}

function SpouseData:New()
    local _m = Utils.DeepCopy(self)
    _m:RefeshData(nil)
    return _m
end

function SpouseData:RefeshData(mateInfo)
    if mateInfo ~= nil then
        self.Name = mateInfo.name
        -- Profession
        self.Career = mateInfo.career
        -- Realm level
        self.StateLv = mateInfo.stateLv
        -- Appearance data
        self.VisInfo = PlayerVisualInfo:New()
        self.VisInfo:ParseByLua(mateInfo.facade, self.StateLv)
    end
end

-- Release data after divorce
function SpouseData:ClearData()
    self.PlayerID = nil
    self.Name = nil
    self.Career = nil
    self.StateLv = 0
    self.VisInfo = nil
end

function SpouseData:GetIntimacy()
    if self.PlayerId ~= nil and self.PlayerId > 0 then
        local _friendData = GameCenter.FriendSystem:GetFriendInfo(FriendType.Friend, self.PlayerId)
        if _friendData ~= nil then
            self.Intimacy = _friendData.intimacy
        end
    end
    return self.Intimacy
end

return SpouseData