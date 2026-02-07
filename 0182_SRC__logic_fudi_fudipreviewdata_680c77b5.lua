
------------------------------------------------
-- Author:
-- Date: 2019-05-13
-- File: FuDiPreviewData.lua
-- Module: FuDiPreviewData
-- Description: Preview data for Blessed Land
------------------------------------------------
-- Quote
local FuDuReMainData = require "Logic.FuDi.FuDuReMainData"
local FuDiPreviewData = {
    -- Today's Sect Points
    CurScore = 0,
    ReceivedList = List:New(),
    ReMainList = List:New(),
}

function FuDiPreviewData:New(msg)
    local _m = Utils.DeepCopy(self)
    _m.CurScore = msg.todayScore
    _m.ReceivedList:Clear()
    if msg.rewards ~= nil then
        for i = 1, #msg.rewards do
            _m.ReceivedList:Add(msg.rewards[i])
        end
    end
    if msg.remain ~= nil then
        for i = 1,#msg.remain do
            local reMain = FuDuReMainData:New(msg.remain[i])
            _m.ReMainList:Add(reMain)
        end
    end
    return _m
end

function FuDiPreviewData:SetData(msg)
    self.CurScore = msg.todayScore
    self.ReceivedList:Clear()
    if msg.rewards ~= nil then
        for i = 1,#msg.rewards do
            self.ReceivedList:Add(msg.rewards[i])
        end
    end
    self.ReMainList:Clear()
    if msg.remain then
        for i = 1,#msg.remain do
            local reMain = FuDuReMainData:New(msg.remain[i])
            self.ReMainList:Add(reMain)
            self.ReMainList[i]:SetData(msg.remain[i])
        end
    end
end

function FuDiPreviewData:UpdateReMain(msg, index)
    if index<= #self.ReMainList then
        self.ReMainList[index]:UpdateRankId(msg)
    end
end

return FuDiPreviewData