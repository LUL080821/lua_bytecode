
------------------------------------------------
-- Author:
-- Date: 2019-08-13
-- File: GuardianFactionSystem.lua
-- Module: GuardianFactionSystem
-- Description: Sectarian Guardian System
------------------------------------------------

local GuardianFactionSystem = {
    -- City Lord's blood volume
    CityOwnerBlood = 1,
    -- Left Guardian's Blood
    LeftBlood = 1,
    -- Right Protector's Blood
    RigthBlood = 1,
    -- Total number of monster waves
    MaxValue = 0,
    -- The monster has been tricked
    Progress = 0,
    -- My ranking
    MyRank = 0,
    -- My harm
    MyHarm = 0,
    -- Damage ranking list
    HarmRank = List:New(),
}

function GuardianFactionSystem:Initialize()
end

function GuardianFactionSystem:UnInitialize()
    self.HarmRank:Clear()
end

-- Refresh damage rankings
function GuardianFactionSystem:RefreshHarmRank(rank)
    self.HarmRank:Clear()
    self.HarmRank = List:New(rank)
    table.sort(self.HarmRank, function(a, b)
        return a.top < b.top
    end)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GUARDIANFACTION_REFRESH)
end

-- Server -> Client Server Synchronizes Data
function GuardianFactionSystem:GS2U_ResGuardianData(msg)
    if msg then
        self.Progress = msg.progress
        self.MaxValue = msg.general
        if msg.bloods then
            for i = 1, #msg.bloods do
                if msg.bloods[i].modelId == 1 then
                    self.CityOwnerBlood = msg.bloods[i].blood
                elseif msg.bloods[i].modelId == 2 then
                    self.LeftBlood = msg.bloods[i].blood
                elseif msg.bloods[i].modelId == 2 then
                    self.RigthBlood = msg.bloods[i].blood
                end
            end
        end
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GUARDIANFACTION_REFRESH)
    end
end

return GuardianFactionSystem