------------------------------------------------
-- Author: xsp
-- Date: 2019-07-31
-- File: FristChargeSystem.lua
-- Module: FristChargeSystem
-- Description: First charge system
------------------------------------------------
local FristChargeSystem = {
    -- The number of ingots that need to be recharged when starting recharge
    NeedGoldCount = 0,
    -- Recharge starting configuration id
    ReChargeStartID = 0,
    -- Recharge end configuration id
    ReChargeEndID = 0,
    -- Recharge data
    ReChargeData = nil,
    -- Level Pop-up first charge guide
    Levels = Dictionary:New(),
    -- Task Pop-up first charge boot
    Tasks = Dictionary:New(),
    -- First charge news
    MsgFristData = nil,
    -- News of the head of the hundred
    MsgHundredData = nil,
    -- Configure the number of days corresponding to the ID
    DayDic = {},
    -- The maximum number of days for the head of one hundred
    MaxDayByHundred = 0,
    -- Maximum number of days for first charge
    MaxDayByFirst = 0,
    -- The status of first charge and 100-year-old charge, k: configuration id, v: FirstChargeState
    StateDic = {},
    -- First charge id list
    FirstIds = nil,
    -- List of ids for the head of 100
    HundredIds = nil,
    StartShowTime = 5 * 60,
    NoticesParams = nil,
    StartTime = 0,
    NeedShowFirstPayForm = false,
    IsShowFirstPayForm = false,
}

-- Recharge data
local L_ChargeData = {
    -- Configuration ID
    CfgID = 0,
    -- Quantity of gold
    GoldCount = 0,
    -- Is the current configuration rewarded?
    IsReward = false,
    -- Is the function enabled?
    IsOpen = false
}

local L_Time = {}

function FristChargeSystem:Initialize()
    -- First recharge
    local _ids1 = {}
    -- Recharge
    local _ids2 = {}
    -- The head of the hundred
    local _ids3 = {}
    -- Traversal configuration table
    DataConfig.DataRechargeAward:Foreach(function(k, v)
        if v.AwardType == 0 then
            table.insert(_ids1, k)
        elseif v.AwardType == 1 then
            table.insert(_ids2, k)
        elseif v.AwardType == 2 then
            table.insert(_ids3, k)
        end
    end)
    -- Sort by small id
    table.sort(_ids1, function(a, b)
        return a < b
    end)
    table.sort(_ids2, function(a, b)
        return a < b
    end)
    table.sort(_ids3, function(a, b)
        return a < b
    end)
    self.FirstIds = _ids1;
    self.HundredIds = _ids3;
    -- Get the first day of renewal ID
    self.ReChargeStartID = _ids2[1]
    -- Get the last day ID of renewal
    self.ReChargeEndID = _ids2[#_ids2]
    -- Set the correspondence between ID and number of days
    for i = 1, #_ids1 do
        self.DayDic[_ids1[i]] = i;
        self.StateDic[_ids1[i]] = FirstChargeState.NoMoney;
    end
    for i = 1, #_ids2 do
        self.DayDic[_ids2[i]] = i;
    end
    for i = 1, #_ids3 do
        self.DayDic[_ids3[i]] = i;
        self.StateDic[_ids1[i]] = FirstChargeState.NoMoney;
    end

    -- Maximum number of days for first charge
    self.MaxDayByFirst = #_ids1;
    -- The maximum number of days for the head of one hundred
    self.MaxDayByHundred = #_ids3;
    -- Get the task ID that triggers the opening interface
    local _taskCfg = DataConfig.DataGlobal[GlobalName.RechargeAwardTaskid]
    if _taskCfg then
        local _strs = Utils.SplitStr(_taskCfg.Params, ";")
        for i = 1, #_strs do
            local _arr = Utils.SplitNumber(_strs[i], "_")
            self.Tasks:Add(_arr[1], _arr[2])
        end
    end
    -- Get the level of triggering the opening interface
    local _levelCfg = DataConfig.DataGlobal[GlobalName.RechargeAwardLevel]
    if _levelCfg then
        local _strs = Utils.SplitStr(_levelCfg.Params, ";")
        for i = 1, #_strs do
            local _arr = Utils.SplitNumber(_strs[i], "_")
            self.Levels:Add(_arr[1], _arr[2])
        end
    end
    -- The number of ingots that need to be recharged when starting recharge
    local _firstCfg = DataConfig.DataRechargeAward[1]
    if _firstCfg then
        self.NeedGoldCount = tonumber(_firstCfg.NeedRecharge)
    end

    -- Within the number of days of service opening, the first charge prompt box pops up when the cumulative online time reaches 5 minutes every day.
    self.NoticesParams = nil
    local _noticeParams = DataConfig.DataGlobal[1957].Params
    if _noticeParams ~= nil then
        self.NoticesParams = Utils.SplitNumber(_noticeParams, "_")
    end
    -- Task trigger
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_TASKFINISH, self.CheckTaskOpenTipsForm, self)
end

-- Recharge changes
-- MSG_Vip.ResVipRechageMoney

function FristChargeSystem:UnInitialize()
    self.Tasks:Clear()
    self.Levels:Clear()
    self.DayDic = {}
    self.StartTime = 0
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_TASKFINISH, self.CheckTaskOpenTipsForm, self)
end

-- Determine whether the task is completed and open the boot interface
function FristChargeSystem:CheckTaskOpenTipsForm(taskId, sender)
    local _isRecharge = GameCenter.VipSystem.CurRecharge <= 0;
    if _isRecharge and self.Tasks:ContainsKey(taskId) then
        if self.Tasks[taskId] == 1 then
            -- Function is enabled
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FIRST_RECHAGE_TIPS)
        elseif self.Tasks[taskId] == 2 then
            AudioPlayer.PlayUI("snd_ui_shouchongb");
            GameCenter.PushFixEvent(UIEventDefine.UIFristChargeForm_Open, true)
        end
    end
end

function FristChargeSystem:SetState(ids, MsgData)
    if not MsgData then
        return;
    end
    local _curDay = self.DayDic[MsgData.cfgID] or 0;
    local _isOpen = _curDay > 1 or _curDay == 1 and MsgData.goldCount >= DataConfig.DataRechargeAward[ids[1]].NeedRecharge;
    for i = 1, #ids do
        local _id = ids[i];
        local _day = self.DayDic[_id];
        local _cfg = DataConfig.DataRechargeAward[_id]
        if _isOpen then
            local _count = _curDay - _day;
            if _count > 0 then
                self.StateDic[_id] = FirstChargeState.Geted;
            elseif _count == 0 then
                self.StateDic[_id] = MsgData.isReward and FirstChargeState.Geted or FirstChargeState.CanGet;
            elseif _count == -1 then
                self.StateDic[_id] = FirstChargeState.NextCanGet;
            elseif _count == -2 then
                self.StateDic[_id] = FirstChargeState.NextNextCanGet;
            end
        else
            self.StateDic[_id] = FirstChargeState.NoMoney;
        end
    end
end

-- First charge information returns
function FristChargeSystem:ResFCChargeData(msg)
    local _rechargeOpen = false
    -- First recharge
    self.MsgFristData = msg.firstData;
    if msg.firstData then
        -- Rewards for the first day of first charge are completed. Enable the recharge function
        local _curDay = self.DayDic[msg.firstData.cfgID] or 0;
        if _curDay > self.MaxDayByFirst or (msg.firstData.goldCount >= self.NeedGoldCount) then
            _rechargeOpen = true
            GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.ReCharge, _rechargeOpen)
        end

        self:SetState(self.FirstIds, self.MsgFristData)
    end
    -- Recharge
    if msg.nextData then
        if not self.ReChargeData then
            self.ReChargeData = Utils.DeepCopy(L_ChargeData)
            self.ReChargeData.IsOpen = true
        end
        self.ReChargeData.CfgID = msg.nextData.cfgID
        self.ReChargeData.GoldCount = msg.nextData.goldCount
        self.ReChargeData.IsReward = msg.nextData.isReward
        if msg.nextData.cfgID == self.ReChargeEndID and msg.nextData.isReward then
            _rechargeOpen = false
            GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.ReCharge, _rechargeOpen)
        end

        local _cfg = DataConfig.DataRechargeAward[msg.nextData.cfgID]
        if _cfg then
            local _redPoint = (not msg.nextData.isReward) and (msg.nextData.goldCount >= _cfg.NeedRecharge)
            if _cfg.AwardType == 1 then
                GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.ReCharge, _redPoint)
            end
        end
    end

    if _rechargeOpen and (not self.ReChargeData) then
        self.ReChargeData = Utils.DeepCopy(L_ChargeData)
        self.ReChargeData.IsOpen = true
    end
    -- The head of the hundred
    self.MsgHundredData = msg.hundredData;
    self:SetState(self.HundredIds, self.MsgHundredData)

    self:RefreshState();
    self.StartTime = Time.GetRealtimeSinceStartup()
    local _openDay = Time.GetOpenSeverDay()
    if self.NoticesParams ~= nil then
        self.NeedShowFirstPayForm = self.NoticesParams[1] <= _openDay and _openDay <= self.NoticesParams[2]
        self.StartShowTime = self.NoticesParams[3] * 60
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FIRST_CHARGE_REFRESH)
    else
        Debug.Log("FristChargeSystem:ResFCChargeData - NoticesParams is nil, please check the configuration of DataGlobal[1957].Params")
    end
end

-- Refresh status
function FristChargeSystem:RefreshState()
    local _firstComplete = self.MsgFristData and (self.DayDic[self.MsgFristData.cfgID] == self.MaxDayByFirst and self.MsgFristData.isReward) or false;
    local _hundredComplete = self.MsgHundredData and (self.DayDic[self.MsgHundredData.cfgID] == self.MaxDayByHundred and self.MsgHundredData.isReward) or false;
    -- The first charge reward is completed. The first charge function is turned off.
    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.FirstCharge, not (_firstComplete and _hundredComplete))
    if not (_firstComplete and _hundredComplete) then
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.FirstCharge, self:IsRedpoint())
    end
end

-- Is there a small red dot for the first charge and the top 100 charge?
function FristChargeSystem:IsRedpoint()
    return self:IsRedpointByFirst() or self:IsRedpointByHundred()
end

-- Is there a small red dot in the first charge?
function FristChargeSystem:IsRedpointByFirst()
    local _cfg = DataConfig.DataRechargeAward[self.MsgFristData.cfgID]
    if _cfg then
        return (not self.MsgFristData.isReward) and (self.MsgFristData.goldCount >= _cfg.NeedRecharge)
    end
    return false
end

-- Is there a small red dot for the 100th head?
function FristChargeSystem:IsRedpointByHundred()
    local _cfg = DataConfig.DataRechargeAward[self.MsgHundredData.cfgID]
    if _cfg then
        return (not self.MsgHundredData.isReward) and (self.MsgHundredData.goldCount >= _cfg.NeedRecharge)
    end
    return false
end

-- Request for first recharge and renewal data
function FristChargeSystem:ReqFCChargeData()
    local _req = {}
    _req.typ = 2
    GameCenter.Network.Send("MSG_Commercialize.ReqCommercialize", _req)
end

-- Request a reward
function FristChargeSystem:ReqFCChargeReward(id)
    if Utils.IsLockTime(self, self.ReqFCChargeReward) then
        return;
    end
    local _msg = {}
    _msg.cfgID = id
    GameCenter.Network.Send("MSG_Commercialize.ReqFCChargeReward", _msg)
end

-- renew
function FristChargeSystem:Update(deltaTime)
    if (self.NeedShowFirstPayForm and not self.IsShowFirstPayForm and GameCenter.VipSystem.CurRecharge <= 0) then
        if self.StartTime > 0 and Time.GetRealtimeSinceStartup() - self.StartTime >= self.StartShowTime then
            -- Pop up the first charge Tips interface
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FIRST_RECHAGE_TIPS)
            self.IsShowFirstPayForm = true
        end
    end
end

return FristChargeSystem
