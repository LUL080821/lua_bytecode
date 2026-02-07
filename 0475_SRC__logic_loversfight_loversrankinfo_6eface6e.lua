------------------------------------------------
-- Author:
-- Date: 2021-07-15
-- File: LoversRankInfo.lua
-- Module: LoversRankInfo
-- Description: Ranking of fairy couples
------------------------------------------------

local L_TeamInfo = require "Logic.LoversFight.LoversTeamInfo"

local LoversRankInfo = {
    TeamInfo = nil,
}

function LoversRankInfo:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

function LoversRankInfo:ParseMsg(msg)
    if self.TeamInfo == nil then
        self.TeamInfo = L_TeamInfo:New()
        self.TeamInfo:ParseMsgEx(msg)
    end
end

function LoversRankInfo:ParseMsgEx(msg)
    if self.TeamInfo == nil then
        self.TeamInfo = L_TeamInfo:New()
        self.TeamInfo:ParseMsgEx(msg)
    end
end

return LoversRankInfo