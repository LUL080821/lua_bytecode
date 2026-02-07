
------------------------------------------------
-- Author:
-- Date: 2019-05-13
-- File: FuDuReMainData.lua
-- Module: FuDuReMainData
-- Description: Remaining boss data in the blessed land
------------------------------------------------
-- Quote
local FuDiSurvivalData = require "Logic.FuDi.FuDiSurvivalData"
local FuDuReMainData = {
    GuildId = 0,
    GuildName = 0,
    SurvivalList = List:New()
}

function FuDuReMainData:New(msg)
    local _m = Utils.DeepCopy(self)
    _m.GuildId = msg.guildId
    _m.GuildName = msg.name
    if msg.survival ~= nil then
        for i = 1,#msg.survival do
            local sv = FuDiSurvivalData:New(msg.survival[i])
            _m.SurvivalList:Add(sv)
        end
    end
    return _m
end

function FuDuReMainData:SetData(msg)
    self.GuildId = msg.guildId
    self.GuildName = msg.name
    self.SurvivalList:Clear()
    if msg.survival ~= nil then
        for i = 1,#msg.survival do
            local sv = FuDiSurvivalData:New(msg.survival[i])
            self.SurvivalList:Add(sv)
            self.SurvivalList[i]:SetData(msg.survival[i])
        end
    end
end

function FuDuReMainData:UpdateRankId(msg)
    self.GuildId = msg.guildId
    self.GuildName = msg.name
end

return FuDuReMainData