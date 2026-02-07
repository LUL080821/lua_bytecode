------------------------------------------------
-- Author:
-- Date: 2021-02-01
-- File: CrossFuDiSystem.lua
-- Module: CrossFuDiSystem
-- Description: Cross-server blessed land
------------------------------------------------
-- Quote
local L_CrossFuDi = require "Logic.CrossFuDi.CrossFuDiData"
local L_ResultData = require "Logic.CrossFuDi.CrossFuDiResultData"
local L_TimeUtils = CS.Thousandto.Core.Base.TimeUtils
local RedPointCustomCondition = CS.Thousandto.Code.Logic.RedPointCustomCondition
local RedPointItemCondition = CS.Thousandto.Code.Logic.RedPointItemCondition

local CrossFuDiSystem = {
    -- Whether to unlock
    IsUnLock = false,
    -- Current day forbidden value
    CurTianJin = 0,
    -- Maximum day forbidden value
    MaxTianJin = 0,
    -- Points for this week
    Score = 0,
    -- Cross-server world level
    CrossWorldLv = 0,
    -- Current cross-server type
    CrossType = FuDiCrossType.Cross_2,
    -- City (Resurrection Point) List
    DicFuDi = Dictionary:New(),
    -- Points Reward List
    RewardList = nil,
    -- Ranking of points {Rank, Name, ServerId, Score}
    ScoreRankList = List:New(),
    -- Kill ranking {Rank, Name, ServerId, Score}
    KillRankList = List:New(),
    -- My ranking {Rank, Name, ServerId, Score}
    MyRank = nil,
    -- Settlement data
    ResultData = nil,
    -- Currently selected city Id
    CurCityId = 0,
    -- Current city Id
    EnterCityId = 0,
    -- Transfer data across replicas
    CrossTransData = nil,
    -- Replica data synchronization message cache
    CacheCopyMsgList = List:New(),
    CacheCopyHurtMsgList = List:New(),

    -- Demon King Rift Data
    M_ShowBossList = nil,
    -- Demon King's rift activity boss data
    M_DicBossList = Dictionary:New(),
    -- Demon King Rift Group Data
    M_CopyList = nil,
    -- Demon King's rift activity time data
    M_OpenData = nil,
    -- Demon King Rift Copy Data Synchronous Message Cache
    M_CacheCopyMsgList = List:New(),
    M_CacheCopyHurtMsgList = List:New(),

    -- Whether to detect the red dots in the gap between the devil
    IsCheckOyLiKaiRedPoint = false,
    -- Whether to support the ancient demon seal
    IsHelpFengXi = false,
    WaitFastEnter = false,
}

-- initialization
function CrossFuDiSystem:Initialize()
    GameCenter.RegFixEventHandle(LogicLuaEventDefine.EID_EVENT_SLAYER_LISTUPDATE, self.SlayerUpdate, self)
    GameCenter.RegFixEventHandle(LogicLuaEventDefine.EID_EVENT_SLAYER_FOLLOW, self.SlayerUpdate, self)
    GameCenter.RegFixEventHandle(LogicLuaEventDefine.EID_EVENT_UPDATE_HOOKSITTING, self.OnUpdateWorldLevel)

    self.TimerEventId = GameCenter.TimerEventSystem:AddTimeStampHourEvent(2, 3600, true, nil,
                            function(id, remainTime, param)
            self:SetFunctionVisable()
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_CROSSFUDI_REFRESH_TIME)
        end)
end

function CrossFuDiSystem:UnInitialize()
    GameCenter.UnRegFixEventHandle(LogicLuaEventDefine.EID_EVENT_SLAYER_LISTUPDATE, self.SlayerUpdate, self)
    GameCenter.UnRegFixEventHandle(LogicLuaEventDefine.EID_EVENT_SLAYER_FOLLOW, self.SlayerUpdate, self)
    GameCenter.UnRegFixEventHandle(LogicLuaEventDefine.EID_EVENT_UPDATE_HOOKSITTING, self.OnUpdateWorldLevel)
end

-- Detect the red dots in the gap of the devil
function CrossFuDiSystem:CheckOyLieKaiRedPoint()
    -- Clear the red dots in the gaps of the devil
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.OyLieKai)

    -- Pay attention to the red dots
    local _haveCount = false
    local _copyList = GameCenter.SlayerBossSystem.FollowCopyList
    for i = 1, #_copyList do
		local _copyId = _copyList[i]
        if GameCenter.SlayerBossSystem:GetCopyCountByID(_copyId) > 0 then
            _haveCount = true
		end
    end
    if _haveCount then
        GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.OyLieKai, 1, RedPointCustomCondition(true))
        --GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.CrossFuDi, 1, RedPointCustomCondition(true))
    end

    -- Red dots of items
    local _dataList = self:GetMCopyDataList()
    if _dataList ~= nil then
        for i = 1, #_dataList do
            local _data = _dataList[i]
            -- Add red dot condition
            GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.OyLieKai, _data.Id, RedPointItemCondition(_data.Need.Id, _data.Need.Num))
            --GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.CrossFuDi, _data.Id, RedPointItemCondition(_data.Need.Id, _data.Need.Num))
        end
    end
end

function CrossFuDiSystem:IsShowLieKaiRedPoint()
    local _ret = false
    -- Pay attention to the red dots
    local _copyList = GameCenter.SlayerBossSystem.FollowCopyList
    for i = 1, #_copyList do
		local _copyId = _copyList[i]
        if GameCenter.SlayerBossSystem:GetCopyCountByID(_copyId) > 0 then
            _ret = true
            break
		end
    end

    -- Red dots of items
    local _dataList = self:GetMCopyDataList()
    if _dataList ~= nil then
        for i = 1, #_dataList do
            local _data = _dataList[i]
            local _haveNum = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(_data.Need.Id)
            if _haveNum >= _data.Need.Num then
                _ret = true
                break
            end
        end
    end
    return _ret
end

function CrossFuDiSystem:SlayerUpdate(obj, sender)
    self.IsCheckOyLiKaiRedPoint = true
end

function CrossFuDiSystem:OnUpdateWorldLevel(obj, sender)
    local _openDay = Time.GetOpenSeverDay()
    local _worldLv = GameCenter.OfflineOnHookSystem.CurWorldLevel
    if self.M_ShowBossList == nil then
        self.M_ShowBossList = List:New()
    else
        self.M_ShowBossList:Clear()
    end
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end
    local _playerOcc = _lp.IntOcc
    DataConfig.DataCrossDevilBoss:Foreach(function(k, v)
        if v.Position == 0 then
            local _dayCondition = Utils.SplitNumber(v.Day, '_')
            local _lvCondition = Utils.SplitNumber(v.Level, '_')
            if _openDay <= _dayCondition[2] and _openDay >= _dayCondition[1] and _worldLv <= _lvCondition[2] and _worldLv >= _lvCondition[1] then
                local _head = v.Icon
                local _name = v.Name
                local _itemList = List:New()
                local _list = Utils.SplitStr(v.Reward, ';')
                if _list ~= nil then
                    for i = 1, #_list do
                        local _values = Utils.SplitNumber(_list[i], '_')
                        if _values ~= nil and #_values == 2 then
                            local _occ = _values[1]
                            local _itemId = _values[2]
                            if _occ == 9 or _occ == _playerOcc then
                                local _itemData = {
                                    Id = _itemId,
                                    Num = 1,
                                    IsBind = true
                                }
                                _itemList:Add(_itemData)
                            end
                        end
                    end
                end
                local _data = {
                    CfgId = k,
                    Head = _head,
                    Name = _name,
                    ItemList = _itemList
                }
                self.M_ShowBossList:Add(_data)
            end
        end
    end)
    -- Sort
    self.M_ShowBossList:Sort(function(a, b)
        return a.CfgId < b.CfgId
    end)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_HUOSHI_BOSSLIST_UPDATE, self.M_ShowBossList)
end

function CrossFuDiSystem:OnEnterScene()
    if self.CrossTransData ~= nil then
        if self.CrossTransData.Type == 1 then
            GameCenter.CrossFuDiSystem:SetCurCityId(self.CrossTransData.CityId)
            GameCenter.CrossFuDiSystem:SetEnterCityId(self.CrossTransData.CityId)
            GameCenter.CrossFuDiSystem:SetCurSelectBossId(self.CrossTransData.BossId)
            GameCenter.CrossFuDiSystem:ReqCrossFudEnter(self.CrossTransData.CityId, self.CrossTransData.Type)
        else
            -- Need to enter the corresponding copy
            GameCenter.CrossFuDiSystem:SetCurCityId(self.CrossTransData.CityId)
            GameCenter.CrossFuDiSystem:SetCurSelectBossId(self.CrossTransData.BossId)
            GameCenter.CrossFuDiSystem:ReqCrossFudEnter(self.CrossTransData.CityId, self.CrossTransData.Type)
        end
        self.CrossTransData = nil
    end
end

-- Get the current day forbidden value
function CrossFuDiSystem:GetCurTianJin()
    return self.CurTianJin
end

-- Get the maximum forbidden value
function CrossFuDiSystem:GetMaxTianJin()
    if self.MaxTianJin == 0 then
        DataConfig.DataCrossFudiMain:ForeachCanBreak(function(k, v)
            if v.MaxTianjin ~= 0 then
                self.MaxTianJin = v.MaxTianjin
                return true
            end
        end)
    end
    return self.MaxTianJin
end

-- Get cross-server type
function CrossFuDiSystem:GetCrossType()
    return self.CrossType
end

-- Obtain cross-server blessed data
function CrossFuDiSystem:GetFuDiDatas()
    return self.DicFuDi
end

-- Get the blessed land you can enter this server
function CrossFuDiSystem:GetValidFuDiDatas()
    local _ret = Dictionary:New()
    local _keys = self.DicFuDi:GetKeys()
    if _keys ~= nil then
        for i = 1, #_keys do
            local _key = _keys[i]
            local _city = self.DicFuDi[_key]
            if _city:IsLocalOwn() then
                local _list = _city:GetRelationCity()
                for m = 1, #_list do
                    local _relationKey = _list[m]
                    if _ret[_relationKey] == nil then
                        _ret[_relationKey] = self.DicFuDi[_relationKey]
                    end
                end
            end
        end
    end
    return _ret
end

-- Getting the data of the blessed land through blessed land id
function CrossFuDiSystem:GetFuDiData(id)
    local _ret = nil
    local _dic = self:GetFuDiDatas()
    if _dic ~= nil then
        _ret = _dic[id]
    end
    return _ret
end

-- Get selected city data
function CrossFuDiSystem:GetCurCityData()
    local _ret = nil
    local _cityId = self:GetCurCityId()
    _ret = self:GetFuDiData(_cityId)
    return _ret
end

-- Get incoming city data
function CrossFuDiSystem:GetEnterCityData()
    local _ret = nil
    local _cityId = self:GetEnterCityId()
    _ret = self:GetFuDiData(_cityId)
    return _ret
end

-- Get the name of the camp that specifies the occupied blessed land
function CrossFuDiSystem:GetCampName(id)
    local _ret = nil
    local _city = self:GetFuDiData(id)
    if _city ~= nil then
        -- Determine the current cross-server type
        if self.CrossType == FuDiCrossType.Cross_2 or self.CrossType == FuDiCrossType.Cross_4 or self.CrossType ==
            FuDiCrossType.Cross_8 then
            local _sdata = GameCenter.ServerListSystem:FindServer(_city:GetGetOccupierServerId())
            if _sdata ~= nil then
                _ret = UIUtils.CSFormat("S{0}_{1}", _sdata.ShowServerId, _sdata.Name)
            end
        else
        end
    end
    return _ret
end

function CrossFuDiSystem:GetLocalCampName()
    local _ret = nil
    -- Determine the current cross-server type
    if self.CrossType == FuDiCrossType.Cross_2 or self.CrossType == FuDiCrossType.Cross_4 or self.CrossType ==
        FuDiCrossType.Cross_8 then
        local _sdata = GameCenter.ServerListSystem:FindServer(
                           GameCenter.ServerListSystem:GetCurrentServer().ReallyServerId)
        if _sdata ~= nil then
            _ret = UIUtils.CSFormat("S{0}_{1}", _sdata.ShowServerId, _sdata.Name)
        end
    else
    end
    return _ret
end

-- Obtain points and award data
function CrossFuDiSystem:GetRewardList()
    if self.RewardList == nil then
        self.RewardList = List:New()
        DataConfig.DataCrossFudiScoreReward:Foreach(function(k, v)
            local _id = v.Id
            local _score = v.Need
            local _list = Utils.SplitNumber(v.Reward, '_')
            local _itemData = {
                Id = _list[1],
                Num = _list[2],
                IsBind = true
            }
            local _pay = v.IfPay
            local _data = {
                Id = _id,
                Need = _score,
                ItemData = _itemData,
                IsPay = false,
                PayNum = _pay,
                IsReward = false
            }
            self.RewardList:Add(_data)
        end)
    end
    return self.RewardList
end

function CrossFuDiSystem:GetScoreReward(id)
    local _ret = nil
    local _list = self:GetRewardList()
    if _list ~= nil then
        for i = 1, #_list do
            local _data = _list[i]
            if _data.Id == id then
                _ret = _data
            end
        end
    end
    return _ret
end

-- Whether to display lock
function CrossFuDiSystem:IsShowLock()
    local _score = 0
    local _dataList = self:GetRewardList()
    if _dataList ~= nil then
        for i = 1, #_dataList do
            local _data = _dataList[i]
            if _data.PayNum > 0 and not self.IsUnLock then
                -- _score = _data.Need
                self.IsUnLock = _data.IsPay
                break
            end
        end
        -- _ret = self.Score >= _score
    end
    return not self.IsUnLock
end

-- Set points ranking data
function CrossFuDiSystem:SetScoreRankDatas(msg)
    if msg.rankList == nil then
        return
    end
    self.ScoreRankList:Clear()
    -- {Rank, Name, ServerId, Score}
    for i = 1, #msg.rankList do
        local _rank = msg.rankList[i]
        local _playerId = _rank.playerId
        local _name = _rank.name
        local _rankId = _rank.rank
        local _score = _rank.score
        local _damage = _rank.damage
        local _occ = _rank.career
        local _visInfo = nil
        if _rank.facade ~= nil then
            _visInfo = PlayerVisualInfo:New()
            _visInfo:ParseByLua(_rank.facade, 0)
        end
        local _facade = _rank.facade
        local _campName = ""
        -- Determine the current cross-server type
        local _camp = _rank.camp
        local _crossType = self:GetCrossType()
        if _camp ~= nil then
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
            VisInfo = _visInfo,
            ServerName = _campName
        }
        self.ScoreRankList:Add(_data)
    end
end

-- Get points ranking data
function CrossFuDiSystem:GetScoreRankDatas()
    return self.ScoreRankList
end

-- Set kill ranking data
function CrossFuDiSystem:SetKillRankDatas(msg)
    if msg == nil then
        return
    end
    if msg.rankList == nil then
        return
    end
    self.KillRankList:Clear()
    -- {Rank, Name, ServerId, Score}
    for i = 1, #msg.rankList do
        local _rank = msg.rankList[i]
        local _playerId = _rank.playerId
        local _name = _rank.name
        local _rankId = _rank.rank
        local _score = _rank.kill
        local _damage = _rank.damage
        local _occ = _rank.career
        local _visInfo = nil
        if _rank.facade ~= nil then
            _visInfo = PlayerVisualInfo:New()
            _visInfo:ParseByLua(_rank.facade, 0)
        end
        local _facade = _rank.facade
        local _campName = ""
        -- Determine the current cross-server type
        local _camp = _rank.camp
        local _crossType = self:GetCrossType()
        if _camp ~= nil then
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
            VisInfo = _visInfo,
            ServerName = _campName
        }
        self.KillRankList:Add(_data)
    end
end

-- Get kill ranking data
function CrossFuDiSystem:GetKillRankDatas()
    return self.KillRankList
end

-- Set my ranking
function CrossFuDiSystem:SetMyRank(msg)
    if msg.my == nil then
        return
    end
    local _rank = msg.my
    local _playerId = _rank.playerId
    local _name = _rank.name
    local _rankId = _rank.rank
    local _score = _rank.score
    local _kill = _rank.kill
    local _damage = _rank.damage
    local _occ = _rank.career
    local _visInfo = nil
    if _rank.facade ~= nil then
        _visInfo = PlayerVisualInfo:New()
        _visInfo:ParseByLua(_rank.facade, 0)
    end
    local _facade = _rank.facade
    local _campName = ""
    -- Determine the current cross-server type
    local _camp = _rank.camp
    local _crossType = self:GetCrossType()
    if _crossType == FuDiCrossType.Cross_2 or _crossType == FuDiCrossType.Cross_4 or _crossType == FuDiCrossType.Cross_8 then
        if _camp.serverId ~= nil and #_camp.serverId > 0 then
            local _sdata = GameCenter.ServerListSystem:FindServer(_camp.serverId[1])
            if _sdata ~= nil then
                _campName = UIUtils.CSFormat("S{0}_{1}", _sdata.ShowServerId, _sdata.Name)
            end
        end
    end
    local _data = {
        PlayerId = _playerId,
        Name = _name,
        Rank = _rankId,
        Score = _score,
        Kill = _kill,
        Damage = _damage,
        Occ = _occ,
        VisInfo = _visInfo,
        ServerName = _campName
    }
    self.MyRank = _data
end

-- Get my ranking
function CrossFuDiSystem:GetMyRank()
    return self.MyRank
end

-- Get settlement data
function CrossFuDiSystem:GetResultData()
    if self.ResultData == nil then
        self.ResultData = L_ResultData:New()
    end
    return self.ResultData
end

-- Get the selected city ID
function CrossFuDiSystem:GetCurCityId()
    return self.CurCityId
end

-- Set the selected city ID
function CrossFuDiSystem:SetCurCityId(id)
    self.CurCityId = id
end

-- Get the city Id
function CrossFuDiSystem:GetEnterCityId()
    return self.EnterCityId
end

-- Set the city Id to enter
function CrossFuDiSystem:SetEnterCityId(id)
    self.EnterCityId = id
end

-- Set the bossId in the current calculation
function CrossFuDiSystem:SetCurSelectBossId(id)
    local _cityId = self:GetCurCityId()
    local _city = self:GetFuDiData(_cityId)
    if _city ~= nil then
        _city:SetCurSelectBossId(id)
    end
end

-- Get the bossId selected by the player in the city
function CrossFuDiSystem:GetCuSelectBossId()
    local _ret = 0
    local _cityId = self:GetCurCityId()
    local _city = self:GetFuDiData(_cityId)
    if _city ~= nil then
        _ret = _city:GetCurSelectBossId()
    end
    return _ret
end

function CrossFuDiSystem:SetFunctionVisable()
    local _day = Time.GetOpenSeverDay()
    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.CrossFuDi, _day >= 3)
end

function CrossFuDiSystem:GetCityLeftTime(id)
    local _ret = 0
    local _city = self:GetFuDiData(id)
    if _city ~= nil then
        _ret = _city:GetLeftTime()
    end
    return _ret
end

-- Get the Demon King Rift Boss Display Data
function CrossFuDiSystem:GetMShowBossList()
    if self.M_ShowBossList == nil then
        self.M_ShowBossList = List:New()
        local _playerOcc = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
        DataConfig.DataCrossDevilBoss:Foreach(function(k, v)
            if v.Position == 0 then
                local _head = v.Icon
                local _name = v.Name
                local _itemList = List:New()
                local _list = Utils.SplitStr(v.Reward, ';')
                if _list ~= nil then
                    for i = 1, #_list do
                        local _values = Utils.SplitNumber(_list[i], '_')
                        if _values ~= nil and #_values == 2 then
                            local _occ = _values[1]
                            local _itemId = _values[2]
                            if _occ == 9 or _occ == _playerOcc then
                                local _itemData = {
                                    Id = _itemId,
                                    Num = 1,
                                    IsBind = true
                                }
                                _itemList:Add(_itemData)
                            end
                        end
                    end
                end
                local _data = {
                    CfgId = k,
                    Head = _head,
                    Name = _name,
                    ItemList = _itemList
                }
                self.M_ShowBossList:Add(_data)
            end
        end)
        -- Sort
        self.M_ShowBossList:Sort(function(a, b)
            return a.CfgId < b.CfgId
        end)
    end
    return self.M_ShowBossList
end

-- Get the Demon King Rift Boss List Data
function CrossFuDiSystem:GetMBossList(cityId)
    local _ret = nil
    if self.M_DicBossList ~= nil then
        _ret = self.M_DicBossList[cityId]
    end
    return _ret
end

-- Get the Demon King Rift Boss Data
function CrossFuDiSystem:GetMBossData(cityId, bossId)
    local _ret = nil
    if self.M_DicBossList ~= nil then
        local _bossList = self.M_DicBossList[cityId]
        if _bossList ~= nil then
            for i = 1, #_bossList do
                local _boss = _bossList[i]
                if _boss.CfgId == bossId then
                    _ret = _boss
                    break
                end
            end
        end
    end
    return _ret
end

-- Get the first boss data of the Demon King Rift
function CrossFuDiSystem:GetMFirstBossData(cityId)
    local _ret = nil
    if self.M_DicBossList ~= nil then
        local _bossList = self.M_DicBossList[cityId]
        if _bossList ~= nil then
            for i = 1, #_bossList do
                local _boss = _bossList[i]
                _ret = _boss
                break
            end
        end
    end
    return _ret
end

-- Get the damage ranking data of the Demon King Lacey boss
function CrossFuDiSystem:GetMBossRankList(cityId, bossId)
    local _ret = nil
    if self.M_DicBossList ~= nil then
        local _bossList = self.M_DicBossList[cityId]
        if _bossList ~= nil then
            for i = 1, #_bossList do
                local _boss = _bossList[i]
                if _boss.CfgId == bossId or _boss.MonsterId == bossId then
                    _ret = _boss.RankList
                    break
                end
            end
        end
    end
    return _ret
end

-- Determine whether it is in the Demon King's rift activity time
function CrossFuDiSystem:OyLiKaiIsOpen()
    local _ret = false
    local _openServerDay = Time.GetOpenSeverDay()
    if _openServerDay < 11 then
        return false
    end
    if self.M_OpenData == nil then
        local _dayList = List:New()
        local _openTime = 0
        local _endTime = 0
        local _cfg = DataConfig.DataDaily[114]
        if _cfg ~= nil then
            local _list = Utils.SplitNumber(_cfg.OpenTime, '_')
            for i = 1, #_list do
                _dayList:Add(_list[i])
            end
            _list = Utils.SplitNumber(_cfg.Time, '_')
            _openTime = _list[1] * 60
            _endTime = _list[2] * 60
        end
        self.M_OpenData = {
            DayList = _dayList,
            OpenTime = _openTime,
            EndTime = _endTime
        }
    end
    local _serverTime = math.floor(GameCenter.HeartSystem.ServerZoneTime)
    -- Calculate the current week 1 - 7
    local week = L_TimeUtils.GetStampTimeWeeklyNotZone(_serverTime)
    if #self.M_OpenData.DayList == 1 and self.M_OpenData.DayList[1] == 0 then
        local _hour, _min, _sec = L_TimeUtils.GetStampTimeHHMMSSNotZone(_serverTime)
        local _curSeconds = _hour * 3600 + _min * 60 + _sec
        if _curSeconds >= self.M_OpenData.OpenTime and _curSeconds <= self.M_OpenData.EndTime then
            _ret = true
        end
    else
        if self.M_OpenData.DayList:Contains(week) then
            local _hour, _min, _sec = L_TimeUtils.GetStampTimeHHMMSSNotZone(_serverTime)
            local _curSeconds = _hour * 3600 + _min * 60 + _sec
            if _curSeconds >= self.M_OpenData.OpenTime and _curSeconds <= self.M_OpenData.EndTime then
                _ret = true
            end
        end
    end
    return _ret
end

function CrossFuDiSystem:GetLieKaiLeftTime()
    local _ret = 0
    if self.M_OpenData == nil then
        local _dayList = List:New()
        local _openTime = 0
        local _endTime = 0
        local _cfg = DataConfig.DataDaily[114]
        if _cfg ~= nil then
            local _list = Utils.SplitNumber(_cfg.OpenTime, '_')
            for i = 1, #_list do
                _dayList:Add(_list[i])
            end
            _list = Utils.SplitNumber(_cfg.Time, '_')
            _openTime = _list[1] * 60
            _endTime = _list[2] * 60
        end
        self.M_OpenData = {
            DayList = _dayList,
            OpenTime = _openTime,
            EndTime = _endTime
        }
    end
    local _serverTime = math.floor(GameCenter.HeartSystem.ServerZoneTime)
    local _hour, _min, _sec = L_TimeUtils.GetStampTimeHHMMSSNotZone(_serverTime)
    local _curSeconds = _hour * 3600 + _min * 60 + _sec
    if _curSeconds >= self.M_OpenData.OpenTime and _curSeconds <= self.M_OpenData.EndTime then
        _ret = self.M_OpenData.EndTime - _curSeconds
    end
    return _ret
end


function CrossFuDiSystem:GetLieKaiPreTime()
    local _ret = 0
    if self.M_OpenData == nil then
        local _dayList = List:New()
        local _openTime = 0
        local _endTime = 0
        local _cfg = DataConfig.DataDaily[114]
        if _cfg ~= nil then
            local _list = Utils.SplitNumber(_cfg.OpenTime, '_')
            for i = 1, #_list do
                _dayList:Add(_list[i])
            end
            _list = Utils.SplitNumber(_cfg.Time, '_')
            _openTime = _list[1] * 60
            _endTime = _list[2] * 60
        end
        self.M_OpenData = {
            DayList = _dayList,
            OpenTime = _openTime,
            EndTime = _endTime
        }
    end
    local week = L_TimeUtils.GetStampTimeWeeklyNotZone(_serverTime)
    if self.M_OpenData.DayList:Contains(week) then
        local _serverTime = math.floor(GameCenter.HeartSystem.ServerZoneTime)
        local _hour, _min, _sec = L_TimeUtils.GetStampTimeHHMMSSNotZone(_serverTime)
        local _curSeconds = _hour * 3600 + _min * 60 + _sec
        if _curSeconds > self.M_OpenData.OpenTime then
            _ret = _curSeconds - self.M_OpenData.OpenTime
        end
    end
    return _ret
end

-- Get the next time to turn on
function CrossFuDiSystem:GetOyLiKaiNextTime()
    local _ret1 = 0
    local _ret2 = 0
    if self.M_OpenData == nil then
        local _dayList = List:New()
        local _openTime = 0
        local _endTime = 0
        local _cfg = DataConfig.DataDaily[114]
        if _cfg ~= nil then
            local _list = Utils.SplitNumber(_cfg.OpenTime, '_')
            for i = 1, #_list do
                _dayList:Add(_list[i])
            end
            _list = Utils.SplitNumber(_cfg.Time, '_')
            _openTime = _list[1] * 60
            _endTime = _list[2] * 60
        end
        self.M_OpenData = {
            DayList = _dayList,
            OpenTime = _openTime,
            EndTime = _endTime
        }
    end
    local _serverTime = math.floor(GameCenter.HeartSystem.ServerZoneTime)
    -- Calculate the current week 1 - 7
    local week = L_TimeUtils.GetStampTimeWeeklyNotZone(_serverTime)
    if #self.M_OpenData.DayList == 1 and self.M_OpenData.DayList[1] == 0 then
        local _hour, _min, _sec = L_TimeUtils.GetStampTimeHHMMSSNotZone(_serverTime)
        local _curSeconds = _hour * 3600 + _min * 60 + _sec
        if _curSeconds > self.M_OpenData.OpenTime then
            _ret1 = 3600 * 24 - _curSeconds + self.M_OpenData.OpenTime
            _ret2 = week
        else
            _ret1 = self.M_OpenData.OpenTime - _curSeconds
            _ret2 = week + 1
        end
        if _ret2 > 7 then
            _ret2 = 1
        end
    else
        local _hour, _min, _sec = L_TimeUtils.GetStampTimeHHMMSSNotZone(_serverTime)
        local _curSeconds = _hour * 3600 + _min * 60 + _sec
        local _preDay = 0
        local _nextDay = 0
        local _disDay = 0
        for i = 1, #self.M_OpenData.DayList do
            _preDay = self.M_OpenData.DayList[i]
            if week == 1 then
                _nextDay = self.M_OpenData.DayList[#self.M_OpenData.DayList]
                break
            else
                if self.M_OpenData.DayList[i] >= week then
                    if self.M_OpenData.DayList[i] == week then
                        if _curSeconds < self.M_OpenData.EndTime then
                            _nextDay = self.M_OpenData.DayList[i]
                        end
                    else
                        _nextDay = self.M_OpenData.DayList[i]
                    end
                    break
                end
            end
        end
        if _nextDay == 0 then
            _nextDay = self.M_OpenData.DayList[1]
            _disDay = 7 - week + _nextDay - 1
        else
            _disDay = _nextDay - week - 1
        end
        if week == _preDay and self.M_OpenData.OpenTime > _curSeconds then
            _ret1 = self.M_OpenData.OpenTime - _curSeconds
            _ret2 = _preDay
        else
            _ret1 = 3600 * 24 - _curSeconds + _disDay * 3600 * 24 + self.M_OpenData.OpenTime
            _ret2 =  _nextDay
        end
    end
    return _ret1, _ret2
end

function CrossFuDiSystem:GetMCopyDataList()
    if self.M_CopyList == nil then
        self.M_CopyList = List:New()
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if _lp == nil then
            return
        end
        local _playerOcc = _lp.IntOcc
        DataConfig.DataCrossDevilGroupCopy:Foreach(function(k, v)
            local _id = v.Id
            local _name = v.Name
            local _list = Utils.SplitNumber(v.OpenItem, '_')
            local _needItem = {
                Id = _list[1],
                Num = _list[2],
                IsBind = false
            }
            local _sprName = v.Icon
            -- CapReward = 5,
            -- MemberReward = 6,
            local _leaderItemList = List:New()
            _list = Utils.SplitStr(v.CapReward, ';')
            if _list ~= nil then
                for i = 1, #_list do
                    local _values = Utils.SplitNumber(_list[i], '_')
                    local _occ = _values[4]
                    if _occ == 9 or _occ == _playerOcc then
                        local _leaderItem = {
                            Id = _values[1],
                            Num = _values[2],
                            IsBind = _values[3] == 1
                        }
                        _leaderItemList:Add(_leaderItem)
                    end
                end
            end

            local _memberItemList = List:New()
            _list = Utils.SplitStr(v.MemberReward, ';')
            if _list ~= nil then
                for i = 1, #_list do
                    local _values = Utils.SplitNumber(_list[i], '_')
                    local _occ = _values[4]
                    if _occ == 9 or _occ == _playerOcc then
                        local _memberItem = {
                            Id = _values[1],
                            Num = _values[2],
                            IsBind = _values[3] == 1
                        }
                        _memberItemList:Add(_memberItem)
                    end
                end
            end
            local _copyData = {
                Id = _id,
                Name = _name,
                SprName = _sprName,
                Need = _needItem,
                LeaderItemList = _leaderItemList,
                MemberItemList = _memberItemList
            }
            self.M_CopyList:Add(_copyData)
        end)
    end
    return self.M_CopyList
end

-- Heartbeat
function CrossFuDiSystem:Update(dt)
    if self.IsCheckOyLiKaiRedPoint then
        self:CheckOyLieKaiRedPoint()
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LIEXI_REDPOINT)
        self.IsCheckOyLiKaiRedPoint = false
    end
    -- if self.CacheCopyMsgList ~= nil and #self.CacheCopyMsgList > 0 then
    -- -- Synchronize data
    --     GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_CROSSFUDI_COPY_DATAUPDATE)
    -- end
    -- -- CacheCopyHurtMsgList
    -- if self.CacheCopyHurtMsgList ~= nil and #self.CacheCopyHurtMsgList > 0 then
    -- -- Synchronize data
    -- end
end

-- ======================================================================================================================================================================

-- Request cross-server blessed data
function CrossFuDiSystem:ReqAllCrossFudInfo()
    GameCenter.Network.Send("MSG_GuildCrossFud.ReqAllCrossFudInfo")
end

-- Request to unlock the points treasure chest
function CrossFuDiSystem:ReqCrossFudUnLockScoreBox(id)
    GameCenter.Network.Send("MSG_GuildCrossFud.ReqCrossFudUnLockScoreBox", {
        boxId = id
    })
end

-- Request to receive the points treasure chest
function CrossFuDiSystem:ReqCrossFudScoreBoxOpen(id)
    GameCenter.Network.Send("MSG_GuildCrossFud.ReqCrossFudScoreBoxOpen", {
        boxId = id
    })
end

-- Receive the treasure chest of blessing land
function CrossFuDiSystem:ReqCrossFudBoxOpen(id)
    GameCenter.Network.Send("MSG_GuildCrossFud.ReqCrossFudBoxOpen", {
        cityId = id
    })
end

-- Get the details of the blessed land
function CrossFuDiSystem:ReqCrossFudCityInfo(id, t)
    GameCenter.Network.Send("MSG_GuildCrossFud.ReqCrossFudCityInfo", {
        city = id,
        type = t
    })
end

-- Get personal rankings
function CrossFuDiSystem:ReqCrossFudRank(t)
    GameCenter.Network.Send("MSG_GuildCrossFud.ReqCrossFudRank", {
        type = t
    })
end

-- Request attention
function CrossFuDiSystem:ReqCrossFudCareBoss(t, cId, bId)
    GameCenter.Network.Send("MSG_GuildCrossFud.ReqCrossFudCareBoss", {
        type = t,
        cityId = cId,
        bossId = bId
    })
end

-- Request to enter the cross-server blessed land
function CrossFuDiSystem:ReqCrossFudEnter(id, t)
    self:SetCurCityId(id)
    GameCenter.Network.Send("MSG_GuildCrossFud.ReqCrossFudEnter", {
        cityId = id,
        type = t
    })
end

-- Request Demon King's gap boss list
function CrossFuDiSystem:ReqDevilBossList()
    GameCenter.Network.Send("MSG_GuildCrossFud.ReqDevilBossList")
end

-- Return to the Demon King's gap boss display list
function CrossFuDiSystem:ResDevilBossList(msg)
    
end

-- Return cross-server blessed land data
function CrossFuDiSystem:ResAllCrossFudInfo(msg)
    if msg == nil then
        return
    end
    -- Set up personal points
    self.Score = msg.score
    -- Set the world level
    self.CrossWorldLv = msg.worldLevel
    -- Set the current day prohibition value
    self.CurTianJin = msg.tValue
    -- Set up city data
    if msg.cityList ~= nil then
        for i = 1, #msg.cityList do
            local _city = self.DicFuDi[msg.cityList[i].cityId]
            if _city == nil then
                _city = L_CrossFuDi:New()
                self.DicFuDi[msg.cityList[i].cityId] = _city
            end
            _city:SetData(msg.cityList[i])
            _city:SetFinalItem(msg.cityList[i].box)
            if i == 1 then
                -- Set cross-server type
                self.CrossType = _city:GetCrossType()
            end
        end
        local _keys = self.DicFuDi:GetKeys()
        if _keys ~= nil then
            for i = 1, #_keys do
                local _key = _keys[1]
                if math.floor(_key / 100) ~= self.CrossType then
                    self.DicFuDi:Remove(_key)
                end
            end
        end
    end
    -- Set up personal points treasure chest
    local _rewardList = self:GetRewardList()
    if msg.boxList ~= nil then
        for i = 1, #msg.boxList do
            local _box = msg.boxList[i]
            local _data = self:GetScoreReward(_box.boxId)
            if _data ~= nil then
                _data.IsPay = not _box.isLock
                _data.IsReward = _box.isGet
            end
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_CROSSFUDI_DATA_RESULT)
end

-- Receive the treasure chest of blessing land and return
function CrossFuDiSystem:ResUpdateCrossFudBox(msg)
    if msg == nil then
        return
    end
    local _city = self:GetFuDiData(msg.cityId)
    if _city ~= nil then
        _city:RewardedBox()
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_CROSSFUDI_BOX_REWARDED, msg)
end

-- Unlock the points treasure chest
function CrossFuDiSystem:ResUpdateCrossFudScoreBox(msg)
    if msg == nil then
        return
    end
    if msg.boxList == nil then
        return
    end
    for i = 1, #msg.boxList do
        local _box = msg.boxList[i]
        local _data = self:GetScoreReward(_box.boxId)
        if _data ~= nil then
            _data.IsPay = not _box.isLock
            _data.IsReward = _box.isGet
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_CROSSFUDI_DATA_RESULT)
end

-- Return to the Blessed Land Details
function CrossFuDiSystem:ResCrossFudCityInfo(msg)
    if msg == nil then
        return
    end
    local _playerOcc = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
    if msg.type == 0 then
        local _city = self:GetFuDiData(msg.cityId)
        if _city == nil then
            return
        end
        -- Set server (camp) ranking
        _city:SetServerScoreRankDatas(msg)
        -- Set the boss list
        _city:SetBossDatas(msg.bossList)
        _city.OwnPlayerNum = msg.enterRole
    else
        local _bossList = List:New()
        if msg.bossList ~= nil then
            for i = 1, #msg.bossList do
                local _bossMsg = msg.bossList[i]
                local _cfgId = _bossMsg.bossId
                local _bossState = 0
                if _bossMsg.time == nil then
                    _bossMsg.time = 0
                end
                if _bossMsg.isDie and _bossMsg.time <= 0 then
                    _bossState = 1
                end
                local _leftTime = _bossMsg.time / 1000
                local _cfg = DataConfig.DataCrossDevilBoss[_bossMsg.bossId]
                local _itemList = List:New()
                local _list = Utils.SplitStr(_cfg.Reward, ';')
                if _list ~= nil then
                    for i = 1, #_list do
                        local _values = Utils.SplitNumber(_list[i], '_')
                        if _values ~= nil and #_values == 2 then
                            local _occ = _values[1]
                            local _itemId = _values[2]
                            if _occ == 9 or _occ == _playerOcc then
                                local _itemData = {
                                    Id = _itemId,
                                    Num = 1,
                                    IsBind = true
                                }
                                _itemList:Add(_itemData)
                            end
                        end
                    end
                end
                local _head = _cfg.Icon
                local _name = _cfg.Name
                local _monsterCfg = DataConfig.DataMonster[_cfg.MonsterId]
                local _level = _monsterCfg.Level
                local _boss = {
                    CfgId = _cfgId,
                    MonsterId = _cfg.MonsterId,
                    BossState = _bossState,
                    LeftTime = _leftTime,
                    Head = _head,
                    Name = _name,
                    Level = _level,
                    ItemList = _itemList,
                    RankList = List:New()
                }
                _bossList:Add(_boss)
            end
        end
        self.M_DicBossList[msg.cityId] = _bossList
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_CROSSFUDI_CITY_DETAIL, msg.cityId)
end

-- Return to the ranking of the blessed land
function CrossFuDiSystem:ResCrossFudRankInfo(msg)
    if msg == nil then
        return
    end
    if msg.type == 0 then
        -- Set points ranking
        self:SetScoreRankDatas(msg)
    elseif msg.type == 1 then
        -- Set kill ranking
        self:SetKillRankDatas(msg)
    end
    -- Set my ranking
    self:SetMyRank(msg)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_CROSSFUDI_RANK_RESULT)
end

-- The situation of the attack on the blessed land
function CrossFuDiSystem:ResCrossFudReport(msg)
    if msg == nil then
        return
    end
    if msg.type == 0 then
        self:SetCurCityId(msg.cityId)
        local _cityData = self:GetFuDiData(msg.cityId)
        if _cityData == nil then
            return
        end
        _cityData:SetBossDatas(msg.boss)
        self.CacheCopyMsgList:Add(1)
    else
        local _bossList = List:New()
        if msg.boss ~= nil then
            for i = 1, #msg.boss do
                local _bossMsg = msg.boss[i]
                local _cfgId = _bossMsg.bossId
                local _bossState = 0
                if _bossMsg.isDie and _bossMsg.time <= 0 then
                    _bossState = 1
                end
                local _leftTime = _bossMsg.time / 1000
                local _cfg = DataConfig.DataCrossDevilBoss[_bossMsg.bossId]
                local _head = _cfg.Icon
                local _name = _cfg.Name
                local _monsterCfg = DataConfig.DataMonster[_cfg.MonsterId]
                local _level = _monsterCfg.Level
                local _boss = {
                    CfgId = _cfgId,
                    MonsterId = _cfg.MonsterId,
                    BossState = _bossState,
                    LeftTime = _leftTime,
                    Head = _head,
                    Name = _name,
                    Level = _level,
                    RankList = List:New()
                }
                _bossList:Add(_boss)
            end
        end
        self.M_DicBossList[msg.cityId] = _bossList
        self.M_CacheCopyMsgList:Add(1)
    end
end

-- Blessed damage statistics
function CrossFuDiSystem:ResCrossFudBossReport(msg)
    if msg == nil then
        return
    end
    if msg.type == 0 then
        local _cityData = self:GetEnterCityData()
        if _cityData ~= nil then
            _cityData:SetBossGuiShuCamp(msg.camp)
            _cityData:SetDamageRankList(msg.rankList, msg.boss.bossId)
        end
    else
        local _bossMsg = msg.boss
        local _cfgId = _bossMsg.bossId
        local _bossState = 0
        if _bossMsg.isDie then
            _bossState = 1
        end
        local _leftTime = _bossMsg.time / 1000
        local _cfg = DataConfig.DataCrossDevilBoss[_bossMsg.bossId]
        local _head = _cfg.Icon
        local _name = _cfg.Name
        local _monsterCfg = DataConfig.DataMonster[_cfg.MonsterId]
        local _level = _monsterCfg.Level
        local _boss = self:GetMBossData(self:GetEnterCityId(), _bossMsg.bossId)
        _boss.CfgId = _cfgId
        _boss.BossState = _bossState
        _boss.Head = _head
        _boss.Name = _name
        _boss.Level = _level
        _boss.RankList:Clear()
        if msg.rankList ~= nil then
            for i = 1, #msg.rankList do
                local _rank = msg.rankList[i]
                _boss.RankList:Add({
                    Rank = _rank.rank,
                    Name = _rank.name,
                    Damage = _rank.damage
                })
            end
            _boss.RankList:Sort(function(a, b)
                return a.Damage > b.Damage
            end)
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_CROSSFUDI_HURTRANK_UPDATE)
end

-- Blessed land settlement
function CrossFuDiSystem:ResCrossFudOwnerNotice(msg)
    if msg == nil then
        return
    end
    local _data = self:GetResultData()
    _data:SetFirstData(msg)
    -- Set up city data
    local _cityData = self:GetFuDiData(msg.city.cityId)
    if _cityData == nil then
        -- It is possible that the interface has not been opened and the city data has not been obtained.
        _cityData = L_CrossFuDi:New()
        self.DicFuDi[msg.city.cityId] = _cityData
    end
    if _cityData ~= nil then
        _cityData:SetData(msg.city)
        -- Set kill ranking
        _cityData:SetPersonKillRankDatas(msg.killRank)
        -- Set points ranking
        _cityData:SetPersonScoreRankDatas(msg.scoreRank)
    end
    _data:SetFinalItemData(msg.city.box.boxId)
    GameCenter.PushFixEvent(UILuaEventDefine.UICrossFuDiResultForm_OPEN, msg.city.cityId)
end

-- Return to the attention data
function CrossFuDiSystem:ResCrossFudCareBoss(msg)
    if msg == nil then
        return
    end
    local _cityData = self:GetFuDiData(msg.cityId)
    if _cityData == nil then
        return
    end
    local _bossData = _cityData:GetBossData(msg.boss.bossId)
    if _bossData == nil then
        return
    end
    _bossData.IsCare = msg.boss.care
    -- local _cfg = DataConfig.DataCrossFudiMain[msg.cityId]
    -- if _cfg ~= nil then
    --     GameCenter.PushFixEvent(UIEventDefine.UIBossInfoTips_OPEN, {_cfg.Id, _cfg.CloneId, msg.boss.bossId, 13})
    -- end
end

function CrossFuDiSystem:ResCrossFudCareBossRefresh(msg)
    if msg == nil then
        return
    end
    local _cfg = DataConfig.DataCrossFudiMain[msg.cityId]
    if _cfg ~= nil then
        GameCenter.PushFixEvent(UIEventDefine.UIBossInfoTips_OPEN, {_cfg.Id, _cfg.CloneId, msg.bossId, 13})
    end
end

function CrossFuDiSystem:ResUpdateTJValue(msg)
    if msg == nil then
        return
    end
    self.CurTianJin = msg.tValue
end

-- ======================================================================================================================================================================

return CrossFuDiSystem
