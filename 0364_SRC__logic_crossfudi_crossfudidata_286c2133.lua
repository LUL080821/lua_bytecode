------------------------------------------------
-- Author:
-- Date: 2021-02-01
-- File: CrossFuDiData.lua
-- Module: CrossFuDiData
-- Description: Cross-server blessed location data
------------------------------------------------
-- Quote
local L_TimeUtils = CS.Thousandto.Core.Base.TimeUtils
local CrossFuDiData = {
    Id = 0,
    -- 0: Birth point 1: City
    Type = 0,
    -- 0: Not occupied 1: Temporary occupation 2: Occupation
    State = 0,
    -- Number of surviving bosses
    BossNum = 0,
    -- The remaining number of gap bosses
    DevilBossNum = 0,
    -- Number of players in this server
    OwnPlayerNum = 0,
    -- Occupied camp Id
    CampId = 0,
    -- Server list
    ServerList = List:New(),
    -- Treasure chest id
    BoxId = 0,
    -- Whether to receive the treasure chest
    IsGetBox = false,
    -- Server Points Ranking {Rank, Score, ServerId}
    ServerScoreRankList = List:New(),
    -- Personal kill ranking
    PersonKillRankList = List:New(),
    -- Personal points ranking
    PersonScoreRankList = List:New(),
    -- Damage Ranking
    DamageRankList = List:New(),
    -- boss list {Id, Name, Level, EndTime, Sort, State(0: Survival, 1: Death)}
    BossList = List:New(),
    -- Occupation Reward
    FinalItem = nil,
    -- The currently selected bossId
    CurSelectBossId = 0,
    Cfg = nil,
    -- Points for this camp
    OwnScore = 0,
    -- Faction points
    CampScore = 0,
    -- Occupy Points
    OccupierScore = 0,
    -- Leader's belonging camp data
    BossGuiShuCampData = nil
}

function CrossFuDiData:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

-- Setting up data
function CrossFuDiData:SetData(msg)
    if msg == nil then
        return
    end
    self.Id = msg.cityId
    -- Set up city occupation status
    self.State = msg.state
    -- Set up occupation rewards
    if msg.box == nil then
        self.BoxId = 0
    else
        self.BoxId = msg.box.boxId
    end
    self.IsGetBox = msg.box.isGet
    -- Set the remaining number of bosses
    self.BossNum = msg.remainBoss
    self.DevilBossNum = msg.remainDevilBoss
    -- Set the number of participants in this server
    self.OwnPlayerNum = msg.enterRole
    if msg.enterRole == nil then
        self.OwnPlayerNum = 0
    end
    -- Setting up camp data
    self:SetCamp(msg.camp)
end

function CrossFuDiData:RewardedBox()
    self.IsGetBox = true
end

-- Set up a camp
function CrossFuDiData:SetCamp(camp)
    if camp == nil then
        return
    end
    self.CampId = camp.camp
    self.ServerList:Clear()
    if camp.serverId ~= nil then
        for i = 1, #camp.serverId do
            self.ServerList:Add(camp.serverId[i])
        end
    end
    self.CampScore = camp.score
end

-- Set home camp data
function CrossFuDiData:SetBossGuiShuCamp(camp)
    if camp == nil then
        return
    end
    local _name = nil
    local _serverList = List:New()
    if camp.serverId ~= nil and #camp.serverId > 0 then
        local _serverId = camp.serverId[1]
        local _crossType = GameCenter.CrossFuDiSystem:GetCrossType()
        if _crossType == FuDiCrossType.Cross_2 or _crossType == FuDiCrossType.Cross_4 or _crossType ==
            FuDiCrossType.Cross_8 then
            local _sdata = GameCenter.ServerListSystem:FindServer(_serverId)
            if _sdata ~= nil then
                _name = UIUtils.CSFormat("S{0}_{1}", _sdata.ShowServerId, _sdata.Name)
            end
        end
    end
    self.BossGuiShuCampData = {
        Id = camp.camp,
        ServerList = _serverList,
        Score = camp.score,
        Name = _name
    }
end

-- Get the occupant server Id
function CrossFuDiData:GetGetOccupierServerId()
    local _ret = 0
    if #self.ServerList > 0 then
        _ret = self.ServerList[1]
    end
    return _ret
end

-- Is it occupied by this server
function CrossFuDiData:IsLocalOwn()
    local _ret = false
    if self.State == 0 then
        return _ret
    end
    for i = 1, #self.ServerList do
        if GameCenter.ServerListSystem:GetCurrentServer().ReallyServerId == self.ServerList[i] then
            _ret = true
        end
    end
    return _ret
end

function CrossFuDiData:GetCfg()
    if self.Cfg == nil then
        self.Cfg = DataConfig.DataCrossFudiMain[self.Id]
    end
    return self.Cfg
end

-- Get the name of the base
function CrossFuDiData:GetName()
    local _ret = ""
    local _cfg = self:GetCfg()
    if _cfg ~= nil then
        _ret = _cfg.Name
    end
    return _ret
end

-- Get the base type
function CrossFuDiData:GetType()
    local _ret = 0
    local _cfg = self:GetCfg()
    if _cfg ~= nil then
        _ret = _cfg.Position
    end
    return _ret
end

-- Get cross-server type
function CrossFuDiData:GetCrossType()
    local _ret = 2
    local _cfg = self:GetCfg()
    if _cfg ~= nil then
        _ret = _cfg.CrossStage
    end
    return _ret
end

-- Get icon
function CrossFuDiData:GetIcon()
    local _ret = nil
    if self.Cfg ~= nil then
        _ret = self.Cfg.Icon
    end
    return _ret
end

-- Get my ranking
function CrossFuDiData:GetMyRank()
    local _playerId = GameCenter.GameSceneSystem:GetLocalPlayerID()
    local _rankList = self:GetPersonScoreRankDatas()
    if _rankList ~= nil then
        for i = 1, #_rankList do
            local _rank = _rankList[i]
            if _playerId == _rank.PlayerId then
                return _rank.Rank
            end
        end
    end
    return 999
end

-- Get the reward chest icon
function CrossFuDiData:GetBoxIcon()
    local _ret = nil
    local _index = 0
    local _myRank = self:GetMyRank()
    local _cfg = DataConfig.DataCrossFudiHoldReward[self.BoxId]
    if _cfg ~= nil then
        local _list = Utils.SplitStr(_cfg.Rank, ';')
        for i = 1, #_list do
            local _values = Utils.SplitNumber(_list[i], '_')
            local _min = _values[1]
            local _max = _values[2]
            if _myRank >= _min and _myRank <= _max then
                _index = i
                break
            end
        end
        local _occ = 0
        local _player = GameCenter.GameSceneSystem:GetLocalPlayer()
        if _player then
            _occ = _player.IntOcc
        end
        if _occ == 0 then
            _list = Utils.SplitStr(_cfg.Reward0, ';')
        elseif _occ == 1 then
            _list = Utils.SplitStr(_cfg.Reward1, ';')
        end
        if _list ~= nil and _index <= #_list then
            local _values = Utils.SplitNumber(_list[_index], '_')
            if _values ~= nil then
                _ret = _values[1]
            end
        end
    end
    return _ret
end

-- Set server points ranking
function CrossFuDiData:SetServerScoreRankDatas(msg)
    if msg == nil then
        return
    end
    self.ServerScoreRankList:Clear()
    if msg.campList ~= nil then
        for i = 1, #msg.campList do
            local _camp = msg.campList[i]
            local _score = _camp.score
            local _name = ""
            -- Determine the current cross-server type
            local _crossType = GameCenter.CrossFuDiSystem:GetCrossType()
            if _crossType == FuDiCrossType.Cross_2 or _crossType == FuDiCrossType.Cross_4 or _crossType ==
                FuDiCrossType.Cross_8 then
                if _camp.serverId ~= nil and #_camp.serverId > 0 then
                    local _sdata = GameCenter.ServerListSystem:FindServer(_camp.serverId[1])
                    if _sdata ~= nil then
                        _name = UIUtils.CSFormat("S{0}_{1}", _sdata.ShowServerId, _sdata.Name)
                    end
                end
            end
            local _serverList = List:New()
            if _camp ~= nil and _camp.serverId ~= nil then
                for m = 1, #_camp.serverId do
                    _serverList:Add(_camp.serverId[m])
                    local _id = _camp.serverId[m]
                    if _id == GameCenter.ServerListSystem:GetCurrentServer().ReallyServerId then
                        -- self.CampScore = _camp.score
                        break
                    end
                end
            end
            self.ServerScoreRankList:Add({
                Rank = 0,
                Score = _score,
                Name = _name,
                ServerList = _serverList
            })
        end
        self.ServerScoreRankList:Sort(function(a, b)
            return a.Score > b.Score
        end)
        for i = 1, #self.ServerScoreRankList do
            self.ServerScoreRankList[i].Rank = i
            if i == 1 then
                self.CampScore = self.ServerScoreRankList[i].Score
            end
        end
    end
end

-- Get server points ranking
function CrossFuDiData:GetServerScoreRankDatas()
    return self.ServerScoreRankList
end

-- Rank first in points
function CrossFuDiData:GetNumberOneCampName()
    local _ret = nil
    if self.ServerScoreRankList ~= nil and #self.ServerScoreRankList > 0 then
        _ret = self.ServerScoreRankList[1].Name
    end
    return _ret
end

-- Get server points
function CrossFuDiData:GetServerScore(id)
    local _ret = 0
    local _rankList = self:GetServerScoreRankDatas()
    if _rankList ~= nil then
        for i = 1, #_rankList do
            local _data = _rankList[i]
            for m = 1, #_data.ServerList do
                if _data.ServerList[m] == id then
                    _ret = _data.Score
                    break
                end
            end
        end
    end
    return _ret
end

-- Obtain points from this server in this city
function CrossFuDiData:GetOwnSreverScore()
    local _ret = 0
    local _ownServerId = GameCenter.ServerListSystem:GetCurrentServer().ReallyServerId
    _ret = self:GetServerScore(_ownServerId)
    return _ret
end

-- Obtain points for the city occupier
function CrossFuDiData:GetOccupierServerScore()
    local _ret = 0
    _ret = self.CampScore -- self:GetServerScore(self:GetGetOccupierServerId())
    
    return _ret
end

-- Set up individual kill rankings
function CrossFuDiData:SetPersonKillRankDatas(rankList)
    if rankList == nil then
        return
    end
    self.PersonKillRankList:Clear()
    -- {Rank, Name, ServerId, Score}
    for i = 1, #rankList do
        local _rank = rankList[i]
        local _playerId = _rank.playerId
        local _name = _rank.name
        local _rankId = _rank.rank
        local _score = _rank.kill
        local _damage = _rank.damage
        local _occ = _rank.career
        local _campName = ""
        -- Determine the current cross-server type
        local _camp = _rank.camp
        if _camp ~= nil then
            local _crossType = self:GetCrossType()
            if _crossType == FuDiCrossType.Cross_2 or _crossType == FuDiCrossType.Cross_4 or _crossType ==
                FuDiCrossType.Cross_8 then
                if _camp.serverId ~= nil and #_camp.serverId > 0 then
                    local _sdata = GameCenter.ServerListSystem:FindServer(_camp.serverId[1])
                    if _sdata ~= nil then
                        _campName = UIUtils.CSFormat("S{0}_{1}", _sdata.ShowServerId, _sdata.Name)
                    end
                end
            end
        end
        local _data = {
            PlayerId = _playerId,
            Name = _name,
            Rank = _rankId,
            Score = _score,
            Damage = _damage,
            Occ = _occ,
            ServerName = _campName
        }
        self.PersonKillRankList:Add(_data)
    end
end

-- Get personal kill rankings
function CrossFuDiData:GetPersonKillRankDatas()
    return self.PersonKillRankList
end

-- Set up personal points rankings
function CrossFuDiData:SetPersonScoreRankDatas(rankList)
    if rankList == nil then
        return
    end
    self.PersonScoreRankList:Clear()
    -- {Rank, Name, ServerId, Score}
    for i = 1, #rankList do
        local _rank = rankList[i]
        local _playerId = _rank.playerId
        local _name = _rank.name
        local _rankId = _rank.rank
        local _score = _rank.score
        local _damage = _rank.damage
        local _occ = _rank.career
        local _campName = ""
        -- Determine the current cross-server type
        local _camp = _rank.camp
        if _camp ~= nil then
            local _crossType = self:GetCrossType()
            if _crossType == FuDiCrossType.Cross_2 or _crossType == FuDiCrossType.Cross_4 or _crossType ==
                FuDiCrossType.Cross_8 then
                if _camp.serverId ~= nil and #_camp.serverId > 0 then
                    local _sdata = GameCenter.ServerListSystem:FindServer(_camp.serverId[1])
                    if _sdata ~= nil then
                        _campName = UIUtils.CSFormat("S{0}_{1}", _sdata.ShowServerId, _sdata.Name)
                    end
                end
            end
        end
        local _data = {
            PlayerId = _playerId,
            Name = _name,
            Rank = _rankId,
            Score = _score,
            Damage = _damage,
            Occ = _occ,
            ServerName = _campName
        }
        self.PersonScoreRankList:Add(_data)
    end
end

-- Get personal points ranking
function CrossFuDiData:GetPersonScoreRankDatas()
    return self.PersonScoreRankList
end

-- Set damage rankings
function CrossFuDiData:SetDamageRankList(rankList, bossId)
    if rankList == nil then
        return
    end
    self.DamageRankList:Clear()
    for i = 1, #rankList do
        local _rank = rankList[i]
        self.DamageRankList:Add({
            Rank = _rank.rank,
            Name = _rank.name,
            Damage = _rank.damage,
            BossId = bossId
        })
    end
end

-- Get damage rankings
function CrossFuDiData:GetDamageRankList()
    return self.DamageRankList
end

-- Set the boss list
function CrossFuDiData:SetBossDatas(bList)
    if bList == nil then
        Debug.LogError("The boss list synchronized by the server is empty")
        return
    end
    self.BossList:Clear()
    for i = 1, #bList do
        local _boss = bList[i]
        -- {Id, Name, Level, EndTime, Sort, State(0: Survival, 1: Death)}
        local _id = _boss.bossId
        local _blood = _boss.hp
        local _state = _boss.isDie and 1 or 0
        local _isCare = _boss.care
        local _cfg = DataConfig.DataCrossFudiBoss[_id]
        if _cfg ~= nil then
            local _name = _cfg.Name
            local _level = 0
            local _monsterCfg = DataConfig.DataMonster[_id]
            if _monsterCfg ~= nil then
                _level = _monsterCfg.Level
            end
            local _sort = _cfg.Sort
            local _icon = _cfg.Icon
            local _data = {
                Id = _id,
                Name = _name,
                Level = _level,
                BossState = _state,
                IsCare = _isCare,
                Sort = _sort,
                Head = _icon,
                Blood = _blood,
                Score = _cfg.Score,
                MonsterType = _cfg.Type
            }
            self.BossList:Add(_data)
        end
    end
end

-- Get the boss list
function CrossFuDiData:GetBossDatas()
    self.BossList:Sort(function(a, b)
        return a.Sort < b.Sort
    end)
    return self.BossList
end

-- Get boss data
function CrossFuDiData:GetBossData(id)
    local _ret = nil
    for i = 1, #self.BossList do
        local _boss = self.BossList[i]
        if _boss.Id == id then
            _ret = _boss
        end
    end
    return _ret
end

-- Get boss data through serial number
function CrossFuDiData:GetBossDataByIndex(index)
    local _ret = 0
    for i = 1, #self.BossList do
        local _boss = self.BossList[i]
        if i == index then
            _ret = _boss
        end
    end
    return _ret
end

-- Get boss serial number
function CrossFuDiData:GetBossIndex(id)
    local _ret = 0
    for i = 1, #self.BossList do
        local _boss = self.BossList[i]
        if _boss.Id == id then
            _ret = i
        end
    end
    return _ret
end

-- Get the total number of bosses
function CrossFuDiData:GetBossCount()
    return #self.BossList
end

-- Get drop display
function CrossFuDiData:GetDropDatas()
    local _ret = List:New()
    local _occ = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
    local _bossList = self:GetBossDatas()
    if _bossList ~= nil and #_bossList > 0 then
        local _data = _bossList[1]
        local _cfg = DataConfig.DataCrossFudiBoss[_data.Id]
        if _cfg ~= nil then
            local _list = Utils.SplitStr(_cfg.Reward, ';')
            if _list ~= nil then
                for i = 1, #_list do
                    local _values = Utils.SplitNumber(_list[i], '_')
                    if _occ == _values[1] or _values[1] == 9 then
                        local _itemData = {
                            Id = _values[2]
                        }
                        _ret:Add(_itemData)
                    end
                end
            end
        end
    end
    return _ret
end

function CrossFuDiData:GetDropData(bossId)
    local _ret = List:New()
    local _occ = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
    local _cfg = DataConfig.DataCrossFudiBoss[bossId]
    if _cfg ~= nil then
        local _list = Utils.SplitStr(_cfg.Reward, ';')
        if _list ~= nil then
            for i = 1, #_list do
                local _values = Utils.SplitNumber(_list[i], '_')
                if _occ == _values[1] or _values[1] == 9 then
                    local _itemData = {
                        Id = _values[2]
                    }
                    _ret:Add(_itemData)
                end
            end
        end
    end
    return _ret
end

function CrossFuDiData:SetFinalItem(data)
    local _occ
    local _reward = nil
    local _cfg = DataConfig.DataCrossFudiHoldReward[data.boxId]
    if _cfg == nil then
        return
    end
    local _player = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _player then
        _occ = _player.IntOcc
    end
    if _occ == 0 then
        _reward = _cfg.Reward0
    else
        _reward = _cfg.Reward1
    end
    local _list = Utils.SplitStr(_reward, ';')
    if _list == nil or #_list == 0 then
        return
    end
    local _value = Utils.SplitNumber(_list[#_list], '_')
    self.FinalItem = {
        Id = _value[1],
        Num = _value[2],
        IsBind = true
    }
end

function CrossFuDiData:GetFinalItem()
    return self.FinalItem
end

-- Get associated cities
function CrossFuDiData:GetRelationCity()
    local _ret = List:New()
    local _cfg = self:GetCfg()
    if _cfg ~= nil then
        local _list = Utils.SplitNumber(_cfg.EnterPosition, '_')
        if _list ~= nil then
            for i = 1, #_list do
                local _id = _list[i]
                _ret:Add(_id)
            end
        end
    end
    return _ret
end

-- Get related connections
function CrossFuDiData:GetRelationLine()
    local _ret = List:New()
    local _cfg = self:GetCfg()
    if _cfg ~= nil then
        local _list = Utils.SplitNumber(_cfg.Line, '_')
        if _list ~= nil then
            for i = 1, #_list do
                local _id = _list[i]
                _ret:Add(_id)
            end
        end
    end
    return _ret
end

-- Get the name of Fucheng
function CrossFuDiData:GetCityName()
    local _ret = nil
    local _cfg = self:GetCfg()
    if _cfg ~= nil then
        _ret = _cfg.Name
    end
    return _ret
end

-- Get the next refresh time
function CrossFuDiData:GetNextRefreshTime()
    local _ret = 0
    local _cfg = self:GetCfg()
    if _cfg ~= nil then
        local _list = Utils.SplitNumber(_cfg.RefreshTime, '_')
        local _hour, _min, _sec = L_TimeUtils.GetStampTimeHHMMSSNotZone(math.floor(GameCenter.HeartSystem.ServerZoneTime))
        local _time = _hour * 60 + _min
        if _list ~= nil and #_list > 0 then
            local _isFind = false
            for i = 1, #_list do
                if _time < _list[i] then
                    _ret = _list[i]
                    _isFind = true
                    break
                end
            end
            if not _isFind and #_list > 0 then
                _ret = _list[1]
            end
        end
    end
    return _ret
end

-- Get the countdown to next refresh
function CrossFuDiData:GetLeftTime()
    local _ret = 0
    local _nextTime = self:GetNextRefreshTime() * 60
    local _hour, _min, _sec = L_TimeUtils.GetStampTimeHHMMSSNotZone(math.floor(GameCenter.HeartSystem.ServerZoneTime))
    local _time = _hour * 3600 + _min * 60 + _sec
    if _time > _nextTime then
        -- Cross the sky
        _ret = 24 * 3600 - _time + _nextTime
    else
        _ret = _nextTime - _time
    end
    return _ret
end

-- Set the currently selected bossId
function CrossFuDiData:SetCurSelectBossId(id)
    self.CurSelectBossId = id
end

-- Get the currently selected bossId
function CrossFuDiData:GetCurSelectBossId()
    return self.CurSelectBossId
end

-- Get the type of the specified boss
function CrossFuDiData:GetBossType(id)
    local _ret = 1
    local _bossData = self:GetBossData(id)
    if _bossData ~= nil then
        _ret = _bossData.MonsterType
    end
    return _ret
end

-- Get a list of bosses with players in this server
function CrossFuDiData:GetOwnJoinBossList()
    for i = 1, #self.BossList do
        local _boss = self.BossList[i]

    end
end

-- Get the copy id
function CrossFuDiData:GetMapId()
    local _ret = 0
    local _cfg = self:GetCfg()
    if _cfg ~= nil then
        local _cloneCfg = DataConfig.DataCloneMap[_cfg.CloneId]
        if _cloneCfg ~= nil then
            _ret = _cloneCfg.Mapid
        end
    end
    return _ret
end

return CrossFuDiData
