
------------------------------------------------
-- Author:
-- Date: 2019-11-25
-- File: CelebritySystem.lua
-- Module: CelebritySystem
-- Description: Hall of Fame System
------------------------------------------------
-- Quote
local CelebrityData = require "Logic.Celebrity.CelebrityData"
local CelebritySystem = {
    -- My ranking
    MyRank = 0,
    -- My combat power
    MyFightPoint = 0,
    -- Current stage ID
    CurStateId = 0,
    -- Countdown to the remaining phase of the current stage
    LeftTime = 0,
    SyncTime = 0,
    -- Current comparison of player professions
    Career = 0,
    -- Hall of Fame Data
    ListData = List:New(),
}

-- initialization
function CelebritySystem:Initialize() 
    self.ListData:Clear()
     DataConfig.DataHallFame:Foreach(function(k, v)
         local data = CelebrityData:New()
         data:Parase(v)
         self.ListData:Add(data)
     end)
end

function CelebritySystem:UnInitialize()
    
end

-- Get current Hall of Fame data through stateId
function CelebritySystem:GetCurData()
    if self.CurStateId<= #self.ListData then
        return self.ListData[self.CurStateId]
    end
    return nil
end

-- Get the remaining time
function CelebritySystem:GetLeftTime()
    return self.LeftTime - (Time.GetRealtimeSinceStartup()- self.SyncTime)
end

--msg

-- Request Hall of Fame Data
function CelebritySystem:ReqHallFamePanel()
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN, DataConfig.DataMessageString.Get("RankDataLoading"));
    GameCenter.Network.Send("MSG_RankList.ReqHallFamePanel")
end

function CelebritySystem:ResHallFamePanel(result)
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
    if result == nil then
        return
    end
    self.CurStateId = result.stage
    local data = self:GetCurData()
    if data == nil then
        return
    end
    self.LeftTime = result.endTime
    self.SyncTime = Time.GetRealtimeSinceStartup()
    data:ParaseMsg(result)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_CELEBRITY_UPDATE)
end

return CelebritySystem
