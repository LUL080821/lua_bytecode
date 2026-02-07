local SlayerBossSystem = {
    CopyInfoDic = Dictionary:New(),        -- The replica dictionary that has been enabled, key = configuration table id, value = {BossCfg, RefreshTime, IsFollow}
    FollowCopyList = List:New(),           -- List of copies of followers
    IconIdList = List:New(),
}
function SlayerBossSystem:Initialize()
end

function SlayerBossSystem:UnInitialize()
    self.CopyInfoDic:Clear()
    self.FollowCopyList:Clear()
    self.StartCountDown = false
end

-- Get the number of copies
function SlayerBossSystem:GetCopyCountByID(copyId)
    if self.CopyInfoDic[copyId] then
        return #self.CopyInfoDic[copyId]
    end
    return 0
end

-- renew
function SlayerBossSystem:Update(dt)
    if self.StartCountDown then
        local _haveaLineBoss = false
        local _haveDelBoss = false
        local _keys = self.CopyInfoDic:GetKeys()
        for i=1,#_keys do
            if self.CopyInfoDic[_keys[i]] then
                local list = self.CopyInfoDic[_keys[i]]
                for j = 1, #list do
                    local v = list[j]
                    if v.RemainTime then
                        if v.RemainTime > 0 then
                            v.RemainTime = v.RemainTime - dt
                            _haveaLineBoss = true
                        elseif v.RemainTime <= 0 then
                            v.RemainTime = 0
                            _haveDelBoss = true
                        end
                    end
                end
            end
        end
        if not _haveaLineBoss then
            self.StartCountDown = false
        end
        if _haveDelBoss then
            self:ReqOpenDeviBossPanel()
        end
    end
    if self.NeedUpdateIcon then
        self:SetAlertFunc()
        self.NeedUpdateIcon = false
    end
end

-- Set the main interface reminder button
function SlayerBossSystem:SetAlertFunc()
    for i = 1, #self.IconIdList do
        GameCenter.MainLimitIconSystem:RemoveIcon(self.IconIdList[i])
    end
    self.IconIdList:Clear()
    self.CopyInfoDic:Foreach(function(k, v)
        if self.FollowCopyList:Contains(k) and v and #v > 0 then
            local _endTime = 0
            for i = 1, #v do
                if i == 1 then
                    _endTime = v[i].EndTime
                end
                if v[i].EndTime and v[i].EndTime > 0 and v[i].EndTime < _endTime then
                    _endTime = v[i].EndTime
                end
            end
            if _endTime > 0 then
                _endTime = _endTime + GameCenter.HeartSystem.ServerZoneOffset
                local _cfg = DataConfig.DataCrossDevilGroupCopy[k]
                local _name = _cfg ~= nil and _cfg.Name or ""
                local _iconId = GameCenter.MainLimitIconSystem:AddIcon(_name, "n_icon_zjm_shenmishangdian", _endTime,
                    function(id)
                        GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.SlayerJoin, id)
                    end, k, 999 + k)
                self.IconIdList:Add(_iconId)
            end
        end
    end)
end

-- Request information
function SlayerBossSystem:ReqOpenDeviBossPanel()
    local _req = ReqMsg.MSG_DevilSeries.ReqOpenDeviBossPanel:New()
    _req:Send()
end

-- Request to follow the BOSS
function SlayerBossSystem:ReqFollowDeviBoss(copyId, isFollowed)
    local _req = ReqMsg.MSG_DevilSeries.ReqFollowDeviBoss:New()
    _req.cloneId = copyId
    _req.followValue = isFollowed
    _req:Send()
end

-- Request to open the Demon Removal Group
function SlayerBossSystem:ReqCreateDeviBossMap(copyId)
    local _cloneCfg = DataConfig.DataCloneMap[copyId]
    if _cloneCfg then
        if _cloneCfg.Mapid == GameCenter.MapLogicSystem.MapCfg.MapId then
            Utils.ShowPromptByEnum("XMFIGHT_SYSTEM_TISHI_15")
        else
            local _req = ReqMsg.MSG_DevilSeries.ReqCreateDeviBossMap:New()
            _req.cloneId = copyId
            _req:Send()
        end
    end
end

-- Request to enter the copy
function SlayerBossSystem:ReqEnterDeviBossMap(mapIntensId)
    local _req = ReqMsg.MSG_DevilSeries.ReqEnterDeviBossMap:New()
    _req.mapId = mapIntensId
    _req:Send()
end

-- - Information issuance
function SlayerBossSystem:ResOpenDeviBossPanel(msg)
    self.CopyInfoDic:Clear()
    self.FollowCopyList:Clear()
    self.StartCountDown = false
    if msg.deviBossList then
        for i = 1, #msg.deviBossList do
            local _list = List:New()
            local _cloneList = msg.deviBossList[i].followDataList
            if _cloneList then
                for j = 1, #_cloneList do
                    local _tmp = {}
                    _tmp.headName = _cloneList[j].headName
                    _tmp.career = _cloneList[j].career
                    _tmp.roleId = _cloneList[j].roleId
                    _tmp.head = _cloneList[j].head
                    _tmp.EndTime = _cloneList[j].endTime / 1000
                    _tmp.RemainTime = _cloneList[j].endTime / 1000 - GameCenter.HeartSystem.ServerTime
                    _tmp.mapIntensId = _cloneList[j].mapId
                    _list:Add(_tmp)
                    if _cloneList[j].endTime > 0 then
                        self.StartCountDown = true
                    end
                end
            end
            self.CopyInfoDic:Add(msg.deviBossList[i].cloneId, _list)
            if msg.deviBossList[i].followValue then
                self.FollowCopyList:Add(msg.deviBossList[i].cloneId)
            end
        end
    end
    self.NeedUpdateIcon = true
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SLAYER_LISTUPDATE)
end

-- A new magic-removing group is opened
function SlayerBossSystem:ResCreateDeviBossMapResult(msg)
    if msg.deviBoss then
        local _list = List:New()
        local _cloneList = msg.deviBoss.followDataList
        if _cloneList then
            for j = 1, #_cloneList do
                local _tmp = {}
                _tmp.headName = _cloneList[j].headName
                _tmp.career = _cloneList[j].career
                _tmp.roleId = _cloneList[j].roleId
                _tmp.head = _cloneList[j].head
                _tmp.EndTime = _cloneList[j].endTime / 1000
                _tmp.RemainTime = _cloneList[j].endTime / 1000 - GameCenter.HeartSystem.ServerTime
                _tmp.mapIntensId = _cloneList[j].mapId
                if _tmp.RemainTime < 0 then
                    _tmp.RemainTime = 0
                end
                _list:Add(_tmp)
                if _cloneList[j].endTime > 0 then
                    self.StartCountDown = true
                end
            end
        end
        if self.CopyInfoDic:ContainsKey(msg.deviBoss.cloneId) then
            self.CopyInfoDic[msg.deviBoss.cloneId] = _list
        else
            self.CopyInfoDic:Add(msg.deviBoss.cloneId, _list)
        end
        if self.FollowCopyList:Contains(msg.deviBoss.cloneId) then
            if not msg.deviBoss.followValue then
                self.FollowCopyList:Remove(msg.deviBoss.cloneId)
            end
        else
            if msg.deviBoss.followValue then
                self.FollowCopyList:Add(msg.deviBoss.cloneId)
            end
        end
    end
    self.NeedUpdateIcon = true
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SLAYER_LISTUPDATE)
end

-- BOSS follow the results
function SlayerBossSystem:ResFollowDeviBoss(msg)
    if self.FollowCopyList:Contains(msg.cloneId) then
        if not msg.followValue then
            self.FollowCopyList:Remove(msg.cloneId)
        end
    else
        if msg.followValue then
            self.FollowCopyList:Add(msg.cloneId)
        end
    end
    self.NeedUpdateIcon = true
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SLAYER_FOLLOW)
end
return SlayerBossSystem