------------------------------------------------
-- Author:
-- Date: 2019-09-23
-- File: BaJiJuDianData.lua
-- Module: BaJiJuDianData
-- Description: Level 8 array base data
------------------------------------------------
-- Quote
local BaJiJuDianData = {
    -- Configuration table ID
    CfgId = 0,
    -- Birth Server ID
    BornServerId = 0,
    -- Corresponding copy ID
    CopyId = 0,
    -- Occupied server ID
    OwnerServerId = 0,
    -- Server name
    Name = nil,
    -- Name of the name
    JuDianName = nil,
    -- Current location status
    JuDianState = nil,
    -- Total blood volume of bosses at the base
    TBlood = 0,
    -- Current boss's blood volume
    CurBlood = 0,
    -- bossID
    BossId = 0,
    -- Can occupy attack points list connection
    ListCanFight = List:New(),
    -- Related points
    ListRelationJuDian = List:New(),
    -- The proportion of each server
    DicPercent = Dictionary:New(),
    -- The damage ratio of each server
    DicDamagePercent = Dictionary:New(),
    -- Reward prop string
    RewardStr = nil,
    ColorId = 0
}

function BaJiJuDianData:New(cfgId)
    local _m = Utils.DeepCopy(self)
    _m.CfgId = cfgId
    return _m
end

function BaJiJuDianData:Parase(msg)
    self.CfgId = msg.cityID
    self.BornServerId = msg.birthSid
    self.CopyId = msg.modelID
    self.OwnerServerId = msg.curSid
    self.ColorId = msg.colorCamp
    local sdata = GameCenter.ServerListSystem:FindServer(msg.curSid)
    if sdata ~= nil then
        self.Name = UIUtils.CSFormat("S{0}_{1}", sdata.ShowServerId, sdata.Name)
    end
    if self.OwnerServerId == 0 then
        -- It means that the current stronghold has not been occupied
        self.JuDianState = BaJiJuDianState.NoneServer
        self.Name = DataConfig.DataMessageString.Get("Fighting")
    elseif self.OwnerServerId == GameCenter.BaJiZhenSystem.OwnServerId then
        -- It means being occupied by this server
        self.JuDianState = BaJiJuDianState.LocalServer
    else
        -- It means it is occupied by other servers
        self.JuDianState = BaJiJuDianState.OtherServer
    end
    self.CurBlood = msg.curHp
    self.TBlood = msg.maxHp
    self.BossId = msg.bossID
    for i = 1, BaJiColor.Count do
        -- Set number of people
        self.DicPercent[i] = 0
        -- Set damage
        self.DicDamagePercent[i] = 0
    end
    if msg.cityBattleInfoList ~= nil then
        for i = 1, #msg.cityBattleInfoList do
            if msg.cityBattleInfoList[i].sid == GameCenter.BaJiZhenSystem.OwnServerId then
                GameCenter.BaJiZhenSystem.DicColorServer[msg.cityBattleInfoList[i].colorCamp] =
                    DataConfig.DataMessageString.Get("MyServer")
            else
                local sdata1 = GameCenter.ServerListSystem:FindServer(msg.cityBattleInfoList[i].sid)
                if sdata1 ~= nil then
                    GameCenter.BaJiZhenSystem.DicColorServer[msg.cityBattleInfoList[i].colorCamp] =
                        UIUtils.CSFormat("S{0}_{1}", sdata1.ShowServerId, sdata1.Name)
                end
                -- GameCenter.BaJiZhenSystem.DicColorServer[msg.cityBattleInfoList[i].colorCamp] = msg.cityBattleInfoList[i].sid
            end
            GameCenter.BaJiZhenSystem.DicColorServerId[msg.cityBattleInfoList[i].colorCamp] =
                msg.cityBattleInfoList[i].sid
            -- Set number of people
            self.DicPercent[msg.cityBattleInfoList[i].colorCamp] = msg.cityBattleInfoList[i].playerNum
            -- Set damage
            self.DicDamagePercent[msg.cityBattleInfoList[i].colorCamp] = msg.cityBattleInfoList[i].bossHurt
        end
    end

    -- Initialize the connection id
    self.ListCanFight:Clear()
    local cfg = DataConfig.DataEightCity[self.CfgId]
    if cfg ~= nil then
        local list = Utils.SplitStr(cfg.CanAttackCityLine, '_')
        if list ~= nil then
            for i = 1, #list do
                self.ListCanFight:Add(tonumber(list[i]))
            end
        end
        self.JuDianName = cfg.Name
        self.RewardStr = cfg.Reward

        self.ListRelationJuDian:Clear()
        list = Utils.SplitStr(cfg.CanAttackCity, '_')
        if list ~= nil then
            for i = 1, #list do
                self.ListRelationJuDian:Add(tonumber(list[i]))
            end
        end
    end
end

function BaJiJuDianData:GetServerName()
    local name = nil
    if self.JuDianState == BaJiJuDianState.LocalServer then
        name = DataConfig.DataMessageString.Get("MyServer")
    elseif self.JuDianState == BaJiJuDianState.OtherServer then
        name = self.Name
    elseif self.JuDianState == BaJiJuDianState.NoneServer then
        -- Determine whether there are players
        local tNum = 0
        for i = 1, BaJiColor.Count do
            local num = self:GetServerRoleNumByColorId(i)
            tNum = tNum + num
        end
        if tNum > 0 then
            name = DataConfig.DataMessageString.Get("Fighting")
        else
            name = ""
        end
    end
    return name
end

function BaJiJuDianData:IsLocalServer()
    return self.JuDianState == BaJiJuDianState.LocalServer
end

function BaJiJuDianData:IsFight()
    return self.JuDianState == BaJiJuDianState.NoneServer
end

-- Get blood percentage
function BaJiJuDianData:GetBloodPercent()
    if self.TBlood == 0 then
        return 0
    end
    return self.CurBlood / self.TBlood
end

-- Get the current location status
function BaJiJuDianData:GetState()
    return self.JuDianState
end

-- Get the associated point Ids
function BaJiJuDianData:GetRelationIds()
    return self.ListCanFight
end

-- Get associated stronghold Ids
function BaJiJuDianData:GetRelationJudian()
    return self.ListRelationJuDian
end

-- The proportion of people who obtain services
function BaJiJuDianData:GetServerRoleNumByColorId(id)
    if self.DicPercent:ContainsKey(id) then
        return self.DicPercent[id]
    end
    return 0
end

-- Obtain server damage ratio
function BaJiJuDianData:GetServerDamageByColorId(id)
    if self.DicDamagePercent:ContainsKey(id) then
        return self.DicDamagePercent[id]
    end
    return 0
end

-- Get the connection Id between the current stronghold and the target stronghold id
function BaJiJuDianData:GetPathId(sourceId, destId)
    local pathId = 0
    return pathId
end

return BaJiJuDianData
