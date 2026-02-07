local TopJjcSystem = {
    DataDic = Dictionary:New(),
    IsInitCfg = false,
    WinNum = 0,       -- Victory matches
    TotalNum = 0,     -- Total number of games
    DayPkCount = 0,   -- Today's participation
    DayExp = 0,       -- Experience gained today
    DayBoxIdList = List:New(), -- Received Daily Treasure Box
    Score = 0,        -- Rank points
    Level = 0,        -- Rank
    ReceiveLvAwardIdList = List:New(),   -- Received rank rewards
    LvAwardRemainCountDic = Dictionary:New(), -- The remaining number of rank rewards (some ranks are limited to only how many names can be received in the first place of the entire server)
    IsAutoMatch = true,                      -- Whether it matches automatically
    ActiveIsOpen = false,
    ShowActiveRed = true,
    DelaySendTime = -1,
}

function TopJjcSystem:Initialize()
    self.IsInitCfg = false
    self:SetLevelByScore()
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_CROSSDAY, self.OnCrossDay, self)
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_REFRESH_DAILYPANEL, self.OnFreshActiveOpen, self)
end

function TopJjcSystem:UnInitialize()
    self.DataDic:Clear()
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_CROSSDAY, self.OnCrossDay, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_REFRESH_DAILYPANEL, self.OnFreshActiveOpen, self)
end

function TopJjcSystem:InitCfg()
    self.IsInitCfg = true
end

function TopJjcSystem:Update(dt)
    if self.MatchCount and self.MatchCount > 0 then
        self.MatchCount = self.MatchCount - 1
        if self.MatchCount <= 0 then
            -- if not GameCenter.FormStateSystem:FormIsOpen("UITopJjcMatchForm") then
                if GameCenter.TeamSystem:IsTeamExist() then
                    Utils.ShowMsgBox(function(x)
                        if x == MsgBoxResultCode.Button2 then
                            local lp = GameCenter.GameSceneSystem:GetLocalPlayer()
                            if lp ~= nil then
                                GameCenter.TeamSystem:ReqTeamOpt(lp.ID, 3)
                            end
                            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_TOPJJC_MATCHSUC)
                        end
                    end, "C_MATCHTOPJJC_HAVETEAM_TIPS")
                else
                    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_TOPJJC_MATCHSUC)
                end
            -- end
        end
    end

    if self.DelaySendTime and self.DelaySendTime > 0 then
        self.DelaySendTime = self.DelaySendTime - dt
        if self.DelaySendTime <= 0 then
            GameCenter.Network.Send("MSG_Peak.ReqPeakInfo", {})
            GameCenter.Network.Send("MSG_Peak.ReqPeakStageInfo", {})
        end
    end
end

-- Set the server opening time
function TopJjcSystem:SetOpenServerTime(time)
    self.ServerOpenTime = math.floor(time / 1000)
    local _func =  GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.ArenaTop)
    if _func.IsVisible then
        local _day = Time.GetDayOffset(self.ServerOpenTime, math.floor(GameCenter.HeartSystem.ServerTime)) + 1
        local _cfgArr = Utils.SplitStr(_func.Cfg.StartVariables, ';')
        for i = 1, #_cfgArr do
            local _arr = Utils.SplitNumber(_cfgArr[i], '_')
            if _arr[1] and _arr[1] == 160 then
                local _needDay = _arr[2]
                if _day >= _needDay then
                    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.ArenaTop, true)
                else
                    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.ArenaTop, false)
                end
            end
        end
    end
end

function TopJjcSystem:GetTypeName(type)
    if type == 1 then
        return DataConfig.DataMessageString.Get("C_TOPJJC_LVNAME1")
    elseif type == 2 then
        return DataConfig.DataMessageString.Get("C_TOPJJC_LVNAME2")
    elseif type == 3 then
        return DataConfig.DataMessageString.Get("C_TOPJJC_LVNAME3")
    elseif type == 4 then
        return DataConfig.DataMessageString.Get("C_TOPJJC_LVNAME4")
    elseif type == 5 then
        return DataConfig.DataMessageString.Get("C_TOPJJC_LVNAME5")
    end
end

-- Setting the rank according to the points
function TopJjcSystem:SetLevelByScore()
    DataConfig.DataPeakBattleStage:ForeachCanBreak(function(k, v)
        if self.Score >= v.Integral then
            self.Level = v.Id
        else
            return true
        end
    end)
end

-- Set red dots for gift packages
function TopJjcSystem:SetLvAwardRed()
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.ArenaTopLvAward, false)
    DataConfig.DataPeakBattleStage:ForeachCanBreak(function(k, v)
        if self.Level < v.Id then
            return true
        else
            if not self.ReceiveLvAwardIdList:Contains(v.Id) and (not self.LvAwardRemainCountDic:ContainsKey(v.Id) or (self.LvAwardRemainCountDic:ContainsKey(v.Id) and self.LvAwardRemainCountDic[v.Id] > 0)) then
                GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.ArenaTopLvAward, true)
                return true
            end
        end
    end)
end

function TopJjcSystem:SetBoxRed()
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.ArenaTopDailyBox, false)
	local _globalCfg = DataConfig.DataGlobal[GlobalName.PeakBattle_ThreeBox]
	if _globalCfg then
		local _ar = Utils.SplitStr(_globalCfg.Params, ';')
		if #_ar == 3 then
			for i = 1, 3 do
                local _single = Utils.SplitNumber(_ar[i], '_')
                if _single[1] and _single[1] <= self.DayPkCount and not self.DayBoxIdList:Contains(_single[1]) then
                    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.ArenaTopDailyBox, true)
                    break
                end
			end
		end
	end
end

-- Return to the peak competitive data
function TopJjcSystem:ResPeakInfo(msg)
    self.WinNum = msg.win
    self.TotalNum = msg.all
    self.DayPkCount = msg.dayPkCount
    self.DayExp = msg.dayExp
    self.DayBoxIdList:Clear()
    if msg.dayBoxIds then
        for i = 1, #msg.dayBoxIds do
            self.DayBoxIdList:Add(msg.dayBoxIds[i])
        end
    end
    self:SetBoxRed()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_TOPJJC_MAININFO_UPDATE)
end

-- Return to the peak competitive rank data
function TopJjcSystem:ResPeakStageInfo(msg)
    self.Score = msg.score
    self:SetLevelByScore()
    self.ReceiveLvAwardIdList:Clear()
    self.LvAwardRemainCountDic:Clear()
    if msg.stageList then
        for i = 1, #msg.stageList do
            self.ReceiveLvAwardIdList:Add(msg.stageList[i])
        end
    end
    if msg.remainReward then
        for i = 1, #msg.remainReward do
            if msg.remainReward[i].count >= 0 then
                self.LvAwardRemainCountDic:Add(msg.remainReward[i].stateId, msg.remainReward[i].count)
            end
        end
    end
    self:SetLvAwardRed()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_TOPJJC_LVAWARDINFO_UPDATE)
end

-- Return to the peak rankings
function TopJjcSystem:ResPeakRankList(msg)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_TOPJJCRANK_UPDATE, msg)
end

-- Receive the daily treasure chest and return
function TopJjcSystem:ResPeakTimesResult(msg)
    if not self.DayBoxIdList:Contains(msg.times) then
        self.DayBoxIdList:Add(msg.times)
    end
    self:SetBoxRed()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_TOPJJC_MAININFO_UPDATE)
end

-- Return to receive the reward of rank
function TopJjcSystem:ResPeakStageResult(msg)
    if msg.state then
        if not self.ReceiveLvAwardIdList:Contains(msg.stageId) then
            self.ReceiveLvAwardIdList:Add(msg.stageId)
        end
    end
    if self.LvAwardRemainCountDic:ContainsKey(msg.stageId) and msg.remain then
        self.LvAwardRemainCountDic[msg.stageId] = msg.remain
    end
    self:SetLvAwardRed()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_TOPJJC_LVAWARDINFO_UPDATE)
end

function TopJjcSystem:ResPeakMatchRes(msg)
    self.MatchCount = 3
end

-- Request data again when crossing the day
function TopJjcSystem:OnCrossDay(obj, sender)
    self.DelaySendTime = 60
end

-- Refresh daily activities, need to do activities to turn on red dots
function TopJjcSystem:OnFreshActiveOpen(obj, sender)
    self.ActiveIsOpen = GameCenter.DailyActivitySystem:GetLimitActiveRedByID(21)
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.ArenaTopActive, self.ActiveIsOpen and self.ShowActiveRed)
end
return TopJjcSystem
