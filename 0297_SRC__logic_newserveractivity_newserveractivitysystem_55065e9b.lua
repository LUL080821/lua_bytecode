local TimeUtils = CS.Thousandto.Core.Base.TimeUtils
local RedPointCustomCondition = CS.Thousandto.Code.Logic.RedPointCustomCondition

local NewServerActivitySystem = {
    NewServerAdvantageDic = nil,
    PerfectLoveDic = nil,
    NewServerAdvantageTotalReward = nil,
    PerfectLoveTotalReward = nil,
    -- All active status {[0] = {isVisible = false}, [1] = {isVisible = false}}
    AllActivityState = nil,
    -- Whether the main base plate interface is displayed (not displayed when all sub-interfaces are closed)
    IsVisibleNewServerActivityMain = nil,

    -- v4 assist information
    V4HelpInfos = nil,
    -- Is V4 assist enabled?
    V4HelpIsOpen = false,
    -- V4 investment reward list
    V4HelperAwards = nil,
    -- V4 investors reward list
    V4BeHelpAwards = nil,
    -- V4 assists in opening days
    V4HelpOpenDay = 0,
    V4CheckTimerID = nil,
    -- v4 assists shutdown time
    V4HelpCloseTickTime = 0,
    V4HelpTouZiRedPoint = false,
    V4HelpShenQingRedPoint = false,

    -- Is V4 rebate enabled?
    V4FanLiIsOpen = false,
    -- v4 rebate phase task
    V4FanLiTaskList = nil,
    -- V4 rebate on and off days
    V4FanLiStartDay = 0,
    V4FanLiEndDay = 0,
    -- V4 rebate to complete the required conditions for task
    VipFanLiNeedVipLevel = 4,
    -- v4 rebate reward
    VipFanLiRewards = nil,
    -- v4 rebate rewards for the current stage
    VipFanLiCurStage = nil,
     -- v4 rebate currently receives the prize at which stage
     VipFanLiRewardState = nil,
     V4FanLiCloseTickTime = 0,

    -- The number of days of opening and closing of the Immortal Alliance Battle
    XMZBFanLiStartDay = 0,
    XMZBFanLiEndDay = 0,
    XMZBFanLiIsOpen = false,

    -- Rebate treasure chest information
    RebateBoxInfo = nil,
    -- Save days
    RebateBoxCunRuDay = 7,
    -- Receive days
    RebateBoxGetDay = 14,
    -- Is the rebate treasure chest open?
    RebateBoxIsOpen = false,
    -- Rebate treasure chest closing time
    RebateBoxCloseTickTime = 0,
    CurOpenServerDay = 0,
}

function NewServerActivitySystem:Initialize()
    self.AllActivityState = {}
    -- 0 is the total, add 16 activities first, and after more than 16, you need to modify it here
    for i = 1, 16 do
        table.insert(self.AllActivityState, {
            -- Whether to display
            isVisible = false
        })
    end
    self.AllActivityState[0] = {
        isVisible = false
    }
    self.IsVisibleNewServerActivityMain = false

    self.V4HelperAwards = List:New()
    self.V4BeHelpAwards = List:New()
    DataConfig.DataVipHelp:Foreach(function(k, v)
        if v.HelpType == 0 then
            -- Investor Rewards
            self.V4HelperAwards:Add(v)
        elseif v.HelpType == 1 then
            -- Applicant rewards
            self.V4BeHelpAwards:Add(v)
        end
    end)
    self.V4HelpOpenDay = tonumber(DataConfig.DataGlobal[GlobalName.V4_Help_Day_Count].Params)
    self.V4HelpOnlineRedPoint = true
    local _v4FanLiDay = Utils.SplitNumber(DataConfig.DataGlobal[GlobalName.VipRebate_Day_Count].Params, '_')
    self.V4FanLiStartDay = _v4FanLiDay[1]
    self.V4FanLiEndDay = _v4FanLiDay[2]
    local _xmzbLiDay = Utils.SplitNumber(DataConfig.DataGlobal[GlobalName.XMZB_Day_Count].Params, '_')
    self.XMZBFanLiStartDay = _xmzbLiDay[1]
    self.XMZBFanLiEndDay = _xmzbLiDay[2]
    self.VipFanLiNeedVipLevel = tonumber(DataConfig.DataGlobal[GlobalName.VipRebate_NeedVipLevel].Params)
    local _v4FanLiReward = DataConfig.DataGlobal[GlobalName.VipRebate_Reward]
    if _v4FanLiReward ~= nil then
        local _list = Utils.SplitStr(_v4FanLiReward.Params, ';')
        self.VipFanLiRewards = {_list[1],  _list[2], _list[3] , _list[4]}
    end
    self.RebateBoxOnlineRedPoint = true
    -- Perform at 2 seconds every day
    self.V4CheckTimerID = GameCenter.TimerEventSystem:AddTimeStampDayEvent(2, 86400,
    true, nil, function(id, remainTime, param)
        self:CheckV4HelpState()
        self:CheckV4FanLiState()
        self:CheckRebateBoxState()
        self:CheckVipHelpBaseState()
        self:CheckXMZBState()
    end)
end

function NewServerActivitySystem:UnInitialize()
    self.NewServerAdvantageDic = nil
    self.PerfectLoveDic = nil
    self.NewServerAdvantageTotalReward = nil
    self.PerfectLoveTotalReward = nil
    self.IsInitData = false
end

-- Initialize data
function NewServerActivitySystem:InitData()
    if self.IsInitData then
        return
    end
    self.NewServerAdvantageDic = Dictionary:New()
    self.PerfectLoveDic = Dictionary:New()
    local _TotalProgressType1 = 0
    local _TotalProgressType2 = 0
    local _func = function(k, v)
        local _value = Utils.SplitNumber(v.Value, "_")
        if v.ActiveType == 1 then
            if v.Type == 1 then
                self.NewServerAdvantageDic:Add(v.Id, {
                    Cfg = v,
                    TotalProgress = _value[#_value]
                })
                _TotalProgressType1 = _TotalProgressType1 + 1
            elseif v.Type == 2 then
                self.NewServerAdvantageTotalReward = {
                    Cfg = v,
                    TotalProgress = 0
                }
            end
        elseif v.ActiveType == 2 then
            if v.Type == 1 then
                self.PerfectLoveDic:Add(v.Id, {
                    Cfg = v,
                    TotalProgress = _value[#_value]
                })
                _TotalProgressType2 = _TotalProgressType2 + 1
            elseif v.Type == 2 then
                self.PerfectLoveTotalReward = {
                    Cfg = v,
                    TotalProgress = 0
                }
            end
        end
    end
    DataConfig.DataNewActiveAdvantage:Foreach(_func)

    self.NewServerAdvantageTotalReward.TotalProgress = _TotalProgressType1
    self.PerfectLoveTotalReward.TotalProgress = _TotalProgressType2

    self.IsInitData = true
end

function NewServerActivitySystem:GetNewServerAdvantageDic()
    if not self.IsInitData then
        self:InitData()
    end
    return self.NewServerAdvantageDic
end

function NewServerActivitySystem:GetNewServerAdvantageTotalReward()
    if not self.IsInitData then
        self:InitData()
    end
    return self.NewServerAdvantageTotalReward
end

function NewServerActivitySystem:GetPerfectLoveDic()
    if not self.IsInitData then
        self:InitData()
    end
    return self.PerfectLoveDic
end

function NewServerActivitySystem:GetPerfectLoveTotalReward()
    if not self.IsInitData then
        self:InitData()
    end
    return self.PerfectLoveTotalReward
end

function NewServerActivitySystem:Update(dt)
    if self.IsCheck then
        if Time.ServerTime() >= self.NextCheckTime then
            self.IsCheck = false
            self:CheckState()
        end
    end
end

-- Detection status
function NewServerActivitySystem:CheckState()
    local _isHaveVisibleUI = false
    local _curTime = Time.ServerTime()
    local _nextCheckTime = nil
    if self.MsgNewServerActPanel then
        local _infos = self.MsgNewServerActPanel.infos
        if _infos then
            for i = 1, 16 do
                local _isVisible = false
                for j = 1, #_infos do
                    local _infoData = _infos[j]
                    if _infoData.type == i then
                        -- Cancel the closing time judgment, only the start time
                        local _allGet = true
                        for k = 1, #_infoData.items do
                            if not _infoData.items[k].isGet then
                                _allGet = false
                                break
                            end
                        end
                        _isVisible = _infoData.startTime <= _curTime and not _allGet
                        break
                    end
                end
                self.AllActivityState[i].isVisible = _isVisible
                if self:SetState(i, _isVisible) then
                    _isHaveVisibleUI = true
                end
            end
            -- Calculate the time of the next most recent state change, and only calculate the start time
            for i = 1, #_infos do
                local _startTime = _infos[i].startTime
                if _nextCheckTime == nil or _nextCheckTime > _startTime then
                    _nextCheckTime = _startTime
                end
            end
        end
    end
    self.AllActivityState[0].isVisible = _isHaveVisibleUI
    self:SetState(0, _isHaveVisibleUI)

    if _nextCheckTime == nil then
        _nextCheckTime = _curTime
    end
    -- end
    self.IsCheck = _nextCheckTime > _curTime
    self.NextCheckTime = _nextCheckTime
end

-- Set display status
function NewServerActivitySystem:SetState(typeid, isVisible)
    -- Main interface
    local _funcId = nil
    if typeid == 0 then
        _funcId = FunctionStartIdCode.NewServerActivity
        GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.NewServerActivity, isVisible)
    elseif typeid == 1 then
        _funcId = FunctionStartIdCode.NewServerAdvantage
        GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.NewServerAdvantage, isVisible)
    elseif typeid == 2 then
        _funcId = FunctionStartIdCode.PerfectLove
        GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.PerfectLove, isVisible)
    end
    if not isVisible then
        -- After receiving, close the interface
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_CLOSE_NEWSERVERACTIVITY, typeid)
    end
    if _funcId ~= nil then
        return GameCenter.MainFunctionSystem:FunctionIsVisible(_funcId)
    end
end

-- Is there any red spots in the new server's advantages?
function NewServerActivitySystem:IsRedpointByNewServerAdvantage(type)
    self:InitData()
    if type == 1 then
        local msgDatas = self.MsgNewServerActPanelTypeMap[type] or {}
        local _keys = self.NewServerAdvantageDic:GetKeys()
        local _curProgress = 0
        for i = 1, #_keys do
            local _info = self.NewServerAdvantageDic[_keys[i]]
            local _cfg = _info.Cfg
            local _msgData = msgDatas[_cfg.Id]
            if _msgData then
                local _IsComplete = not _msgData.isGet and _msgData.pro >= _info.TotalProgress
                if _IsComplete then
                    -- There is one to collect and return directly
                    return true
                end
                if _msgData.isGet then
                    _curProgress = _curProgress + 1
                end
            end
        end
        local _totalReward = self.NewServerAdvantageTotalReward
        local _msgTotal = msgDatas[_totalReward.Cfg.Id]
        if (not _msgTotal or _msgTotal and not _msgTotal.isGet) and _curProgress == _totalReward.TotalProgress then
            return true
        end
    elseif type == 2 then
        local msgDatas = self.MsgNewServerActPanelTypeMap[type] or {}
        local _keys = self.PerfectLoveDic:GetKeys()
        local _curProgress = 0
        for i = 1, #_keys do
            local _info = self.PerfectLoveDic[_keys[i]]
            local _cfg = _info.Cfg
            local _msgData = msgDatas[_cfg.Id]
            if _msgData then
                local _IsComplete = not _msgData.isGet and _msgData.pro >= _info.TotalProgress
                if _IsComplete then
                    -- There is one to collect and return directly
                    return true
                end
                if _msgData.isGet then
                    _curProgress = _curProgress + 1
                end
            end
        end
        local _totalReward = self.PerfectLoveTotalReward
        local _msgTotal = msgDatas[_totalReward.Cfg.Id]
        if (not _msgTotal or _msgTotal and not _msgTotal.isGet) and _curProgress == _totalReward.TotalProgress then
            return true
        end
    end
    return false
end
-- ==============MSG========================

-- Request interface information
function NewServerActivitySystem:ReqNewServerActPanel()
    local _req = ReqMsg.MSG_OpenServerAc.ReqNewServerActPanel:New()
    _req:Send()
end
-- Receive the award
function NewServerActivitySystem:ReqGetActReward(activeType, id)
    local _req = ReqMsg.MSG_OpenServerAc.ReqGetActReward:New()
    _req.type = activeType
    _req.cfgId = id
    _req:Send()
end

-- message actInfo
-- {
-- required int32 type = 1 //Activity type
-- required int32 startTime = 2 //Start time
-- required int32 endTime = 3 //End time
-- repeated cfgItem items = 4 //Configuration item

-- repeated actInfo infos = 1 //All new server activities, 1. New server advantages 2. Perfect love
function NewServerActivitySystem:ResNewServerActPanel(msg)
    self.MsgNewServerActPanel = msg
    -- Put all sub-objects of each type into a dictionary
    self.MsgNewServerActPanelTypeMap = {}
    if self.MsgNewServerActPanel then
        local _infos = self.MsgNewServerActPanel.infos
        if _infos then
            for i = 1, #_infos do
                local _type = _infos[i].type
                if not self.MsgNewServerActPanelTypeMap[_type] then
                    self.MsgNewServerActPanelTypeMap[_type] = {}
                end
                local _items = _infos[i].items
                if _items then
                    for j = 1, #_items do
                        self.MsgNewServerActPanelTypeMap[_type][_items[j].id] = _items[j]
                    end
                end
            end
        end
    end
    -- Check whether the current active status has changed and obtain the current latest closed time
    self:CheckState()
    -- Red dot
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.NewServerAdvantage, self:IsRedpointByNewServerAdvantage(1))
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.PerfectLove, self:IsRedpointByNewServerAdvantage(2))
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_NEWSERVERACTIVITY)
end

-- required int32 type = 1 //Activity type
-- required int32 id = 2		//id
-- required bool isGet = 3 //Whether to receive the award
function NewServerActivitySystem:ResGetActReward(msg)
    if self.MsgNewServerActPanelTypeMap[msg.type] then
        local _info = self.MsgNewServerActPanelTypeMap[msg.type][msg.id]
        if _info then
            _info.isGet = msg.isGet
        end
    end
    while(true) do
        if self.MsgNewServerActPanel == nil then
            break
        end
        local _infos = self.MsgNewServerActPanel.infos
        if _infos == nil then
            break
        end
        for i = 1, #_infos do
            if _infos[i].type == msg.type then
                local _items = _infos[i].items
                if _items then
                    for j = 1, #_items do
                        if _items[j].id == msg.id then
                            _items[j].isGet = msg.isGet
                            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_NEWSERVERACTIVITY)
                            -- Red dot
                            GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.NewServerAdvantage, self:IsRedpointByNewServerAdvantage(1))
                            GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.PerfectLove, self:IsRedpointByNewServerAdvantage(2))
                            break
                        end
                    end
                end
                break
            end
        end
        break
    end
    self:CheckState()
end

function NewServerActivitySystem:CheckV4HelpState()
    self.V4HelpIsOpen = false
    self.V4HelpTouZiRedPoint = false
    self.V4HelpShenQingRedPoint = false
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.VIPHelp)
    if self.ServerOpenTime ~= nil and self.V4HelpInfos ~= nil then
        local _serverTime = math.floor(GameCenter.HeartSystem.ServerZoneTime)
        if self.V4HelpInfos.myHelper ~= nil then
            -- Those who invest in me will determine whether all the rewards will be received
            local _helpTime = self.V4HelpInfos.myHelper.helpTime
            _helpTime = math.floor(_helpTime + GameCenter.HeartSystem.ServerZoneOffset)
            local _helpDay = TimeUtils.GetDayOffsetNotZone(_helpTime, _serverTime) + 1

            local _awardState = {}
            local _awardList = self.V4HelpInfos.myHelper.awardState
            if _awardList ~= nil then
                for i = 1, #_awardList do
                    _awardState[_awardList[i]] = true
                end
            end
            local _allGet = true
            for i = 1, #self.V4BeHelpAwards do
                local _cfg = self.V4BeHelpAwards[i]
                if _awardState[_cfg.Id] == nil then
                    _allGet = false
                    if _helpDay >= _cfg.Day then
                        GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.VIPHelp, _cfg.Id, RedPointCustomCondition(true))
                        self.V4HelpShenQingRedPoint = true
                    end
                end
            end
            if not _allGet then
                self.V4HelpIsOpen = true
            end
        end
        if self.V4HelpInfos.helpOther ~= nil then
            -- Those who I invest in will determine whether all the rewards will be received.
            local _helpTime = self.V4HelpInfos.helpOther.helpTime
            _helpTime = math.floor(_helpTime + GameCenter.HeartSystem.ServerZoneOffset)
            local _helpDay = TimeUtils.GetDayOffsetNotZone(_helpTime, _serverTime) + 1

            local _awardState = {}
            local _awardList = self.V4HelpInfos.helpOther.awardState
            if _awardList ~= nil then
                for i = 1, #_awardList do
                    _awardState[_awardList[i]] = true
                end
            end
            local _allGet = true
            for i = 1, #self.V4HelperAwards do
                local _cfg = self.V4HelperAwards[i]
                if _awardState[_cfg.Id] == nil then
                    _allGet = false
                    if _helpDay >= _cfg.Day then
                        GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.VIPHelp, _cfg.Id, RedPointCustomCondition(true))
                        self.V4HelpTouZiRedPoint = true
                    end
                end
            end
            if not _allGet then
                self.V4HelpIsOpen = true
            end
        end
        if not self.V4HelpIsOpen then
            -- Judge time
            local _serverTime = math.floor(GameCenter.HeartSystem.ServerZoneTime)
            local _openDay = TimeUtils.GetDayOffsetNotZone(self.ServerOpenTime, _serverTime) + 1
            self.V4HelpIsOpen = _openDay <= self.V4HelpOpenDay
        end
    end
    if self.V4HelpOnlineRedPoint then
        GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.VIPHelp, 0, RedPointCustomCondition(true))
    end
    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.VIPHelp, self.V4HelpIsOpen)
end

function NewServerActivitySystem:SetOpenServerTime(time)
    -- Check the opening status
    self.ServerOpenTime = math.floor(math.floor(time / 1000) + GameCenter.HeartSystem.ServerZoneOffset)
    local _h, _m, _s = TimeUtils.GetStampTimeHHMMSSNotZone(self.ServerOpenTime)
    local _openDayStart = self.ServerOpenTime - _h * 3600 - _m * 60 - _s
    self.V4HelpCloseTickTime = _openDayStart + self.V4HelpOpenDay * 86400
    self.RebateBoxCloseTickTime = _openDayStart + self.RebateBoxGetDay * 86400
    self.V4FanLiCloseTickTime = _openDayStart + self.V4FanLiEndDay * 86400
    self:CheckV4HelpState()
    self:CheckV4FanLiState()
    self:CheckRebateBoxState()
    self:CheckVipHelpBaseState()
    self:CheckXMZBState()
end

function NewServerActivitySystem:ResV4HelpInfos(msg)
    self.V4HelpInfos = msg
    self:CheckV4HelpState()
    self:CheckVipHelpBaseState()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_V4HELP_REFRESH)
end

function NewServerActivitySystem:ReqV4HelpInfo()
    GameCenter.Network.Send("MSG_OpenServerAc.ReqV4HelpInfo", {})
end

function NewServerActivitySystem:RemoveVIPHelpOnlineRedPoint()
    if self.V4HelpOnlineRedPoint then
        GameCenter.RedPointSystem:RemoveFuncCondition(FunctionStartIdCode.VIPHelp, 0)
    end
    self.V4HelpOnlineRedPoint = false
end

function NewServerActivitySystem:CheckVipHelpBaseState()
    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.V4HelpBase, self.V4FanLiIsOpen or self.V4HelpIsOpen or self.RebateBoxIsOpen)
end

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function NewServerActivitySystem:GetV4RebateData()
    if self.V4FanLiTaskList == nil then
        self.V4FanLiTaskList = Dictionary:New()
        self.TaskNeedCompleteCount = Dictionary:New()
        DataConfig.DataVipRebate:Foreach(function(k, v)
            if v.StageType == 1 then
                if self.V4FanLiTaskList:ContainsKey(1) == false then
                    local _list = List:New()
                    _list:Add(v)
                    self.V4FanLiTaskList:Add(1 , _list)
                else
                    self.V4FanLiTaskList[1]:Add(v)
                end
            elseif v.StageType == 2 then
                if self.V4FanLiTaskList:ContainsKey(2) == false then
                    local _list = List:New()
                    _list:Add(v)
                    self.V4FanLiTaskList:Add(2 , _list)
                else
                    self.V4FanLiTaskList[2]:Add(v)
                end
            elseif v.StageType == 3 then
                if self.V4FanLiTaskList:ContainsKey(3) == false then
                    local _list = List:New()
                    _list:Add(v)
                    self.V4FanLiTaskList:Add(3 , _list)
                else
                    self.V4FanLiTaskList[3]:Add(v)
                end
            elseif v.StageType == 4 then
                if self.V4FanLiTaskList:ContainsKey(4) == false then
                    local _list = List:New()
                    _list:Add(v)
                    self.V4FanLiTaskList:Add(4 , _list)
                else
                    self.V4FanLiTaskList[4]:Add(v)
                end
            end
            local _strs = Utils.SplitNumber(v.VariableId, '_')
            self.TaskNeedCompleteCount:Add(v.Id , _strs[#_strs])
        end)
        return self.V4FanLiTaskList
    else
        return self.V4FanLiTaskList
    end
end


function NewServerActivitySystem:CheckV4FanLiState()
    self.V4FanLiIsOpen = false
    -- Judge time
    local _serverTime = math.floor(GameCenter.HeartSystem.ServerZoneTime)
    local _openDay = TimeUtils.GetDayOffsetNotZone(self.ServerOpenTime, _serverTime) + 1
    self.V4FanLiIsOpen = _openDay >= self.V4FanLiStartDay and _openDay <= self.V4FanLiEndDay
    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.V4Rebate, self.V4FanLiIsOpen)
end

function NewServerActivitySystem:CheckXMZBState()
    self.XMZBFanLiIsOpen = false
    -- Judge time
    local _serverTime = math.floor(GameCenter.HeartSystem.ServerZoneTime)
    local _openDay = TimeUtils.GetDayOffsetNotZone(self.ServerOpenTime, _serverTime) + 1
    self.XMZBFanLiIsOpen = _openDay >= self.XMZBFanLiStartDay and _openDay <= self.XMZBFanLiEndDay
    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.XMZhengBa, self.XMZBFanLiIsOpen)
end


function NewServerActivitySystem:ReqV4RebateCompleteTask(id)
    GameCenter.Network.Send("MSG_OpenServerAc.ReqV4RebateCompleteTask", { id = id })
end

function NewServerActivitySystem:ReqV4RebateReward(StateId)
    GameCenter.Network.Send("MSG_OpenServerAc.ReqV4RebateReward", { rewardState = StateId })
end

function NewServerActivitySystem:ResV4RebateInfo(msg)
    if self.V4rebates == nil then
        self.V4rebates = Dictionary:New()
    end

    local _isShowRedPoint = false
    local _dic = self:GetV4RebateData()
    self.VipFanLiCurStage = msg.curState
    self.VipFanLiRewardState = msg.rewardState
    self.CompleteTaskList = List:New()
    if  msg.v4rebates then
        for i = 1, #msg.v4rebates do
            self.V4rebates:Add(msg.v4rebates[i].id , msg.v4rebates[i])
            -- Judge the red dot
            if msg.v4rebates[i].progress >= self.TaskNeedCompleteCount[msg.v4rebates[i].id]  and msg.v4rebates[i].isComplete == false then
                _isShowRedPoint = true
            end

            if msg.v4rebates[i].progress >= self.TaskNeedCompleteCount[msg.v4rebates[i].id] then
                if self.CompleteTaskList:Contains(msg.v4rebates[i].id) == false then
                    self.CompleteTaskList:Add(msg.v4rebates[i].id)
                end
            else
                if self.CompleteTaskList:Contains(msg.v4rebates[i].id) then
                    self.CompleteTaskList:Remove(msg.v4rebates[i].id)
                end
            end
        end
    end
    if GameCenter.VipSystem:GetVipLevel() >= 4 then
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.V4Rebate, _isShowRedPoint)
    end
end

function NewServerActivitySystem:ResV4RebateUpDate(msg)
    local _isShowRedPoint = false
    self.VipFanLiCurStage = msg.curState      
    if msg.v4rebates and self.V4rebates then
        for i = 1, #msg.v4rebates do
            -- Update the latest data
            if self.V4rebates:ContainsKey(msg.v4rebates[i].id) then
                self.V4rebates[msg.v4rebates[i].id] = msg.v4rebates[i]
            else
                self.V4rebates:Add(msg.v4rebates[i].id , msg.v4rebates[i])
            end
            if msg.v4rebates[i].progress >= self.TaskNeedCompleteCount[msg.v4rebates[i].id] then
                if self.CompleteTaskList:Contains(msg.v4rebates[i].id) == false then
                    self.CompleteTaskList:Add(msg.v4rebates[i].id)
                end
            else
                if self.CompleteTaskList:Contains(msg.v4rebates[i].id) then
                    self.CompleteTaskList:Remove(msg.v4rebates[i].id)
                end
            end
        end

        local keys = self.V4rebates:GetKeys()  
        for i = 1 , self.V4rebates:Count() do
            -- Judge the red dot
            if self.V4rebates[keys[i]].progress >= self.TaskNeedCompleteCount[self.V4rebates[keys[i]].id]  and self.V4rebates[keys[i]].isComplete == false then
                _isShowRedPoint = true
            end
        end
        
        if GameCenter.VipSystem:GetVipLevel() >= 4 then
            GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.V4Rebate, _isShowRedPoint)
        end
    elseif msg.curState > self.VipFanLiCurStage then
        self.CompleteTaskList:Clear()
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REBATE_REFRESH)
end

function NewServerActivitySystem:ResV4RebateRewardResult(msg)
    self.VipFanLiRewardState = msg.rewardState
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REBATE_REFRESH)
end

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function NewServerActivitySystem:RemoveGetRebateBoxRedPoint()
    if self.RebateBoxOnlineRedPoint then
        GameCenter.RedPointSystem:RemoveFuncCondition(FunctionStartIdCode.RebateBox, 0)
    end
    self.RebateBoxOnlineRedPoint = false
end

function NewServerActivitySystem:ReqGetRebateBox(id)
    GameCenter.Network.Send("MSG_OpenServerAc.ReqGetRebateBox", {day = id})
end

function NewServerActivitySystem:CheckRebateBoxState()
    -- Judge time
    local _serverTime = math.floor(GameCenter.HeartSystem.ServerZoneTime)
    local _openDay = TimeUtils.GetDayOffsetNotZone(self.ServerOpenTime, _serverTime) + 1
    self.RebateBoxIsOpen = _openDay <= self.RebateBoxGetDay
    self.CurOpenServerDay = _openDay
    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.RebateBox, self.RebateBoxIsOpen)
    self:CheckRebateBoxRedPoint()
end

function NewServerActivitySystem:CheckRebateBoxRedPoint()
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.RebateBox)
    local _msg = self.RebateBoxInfo
    if _msg ~= nil then
        local _serverTime = math.floor(GameCenter.HeartSystem.ServerZoneTime)
        local _openDay = TimeUtils.GetDayOffsetNotZone(self.ServerOpenTime, _serverTime) + 1
        if _openDay > self.RebateBoxCunRuDay and _openDay <= self.RebateBoxGetDay then
            local _getTable = {}
            if _msg.day ~= nil then
                for i = 1, #_msg.day do
                    _getTable[_msg.day[i]] = true
                end
            end
            local _canGet = false
            if _msg.num ~= nil then
                for i = 1, #_msg.num do
                    local _canGetDay = i + self.RebateBoxCunRuDay
                    if _msg.num[i] > 0 and not _getTable[i] and _openDay >= _canGetDay then
                        _canGet = true
                        break
                    end
                end
            end
            if _canGet then
                GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.RebateBox, 1, RedPointCustomCondition(true))
            end
        end
    end
    if self.RebateBoxOnlineRedPoint then
        GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.RebateBox, 0, RedPointCustomCondition(true))
    end
end

function NewServerActivitySystem:ResRebateBoxList(msg)
    self.RebateBoxInfo = msg
    self:CheckRebateBoxRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REBATEBOX_REFRESH)
end
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

return NewServerActivitySystem
