------------------------------------------------
-- Author:
-- Date: 2019-04-23
-- File: DailyActivitySystem.lua
-- Module: DailyActivitySystem
-- Description: Daily System
------------------------------------------------
local DailyActivityData = require "Logic.DailyActivity.DailyActivityData"
local ServerMatchInfo = require "Logic.DailyActivity.ServerMatchInfo"
local RedPointCustomCondition = CS.Thousandto.Code.Logic.RedPointCustomCondition;

local DailyActivitySystem = {
    -- Currently fetched active value The overlay of all activities
    CurrActive = 0,
    -- Maximum active value available Overlay of all activities
    MaxActive = 0,
    -- Number of active treasure chests
    GiftCount = 0,
    -- Number of active treasure chests used
    UseItemCount = 0,
    -- Increased activity
    AddActive = 0,
    -- Received treasure chest ID
    ReceiveGiftIDList = List:New(),
    -- Daily activities
    DailyActivitylist = List:New(),
    -- Limited time activities
    LimitActivityList = List:New(),
    -- Cross-server activities
    CrossServerActivityList = List:New(),
    -- All Activities
    AllActivityIdList = List:New(),
    -- Open push activity
    OpenPushActivityList = List:New(),
    -- Event preparation time
    ReadyTimeContainer = Dictionary:New(),
    -- Server class information
    ServerMatchInfoLvDic = Dictionary:New(),
    -- All Activities
    AllActivityDic = Dictionary:New(),
    -- Have you participated in Zhouchang Vip
    IsJoinWeekVip = false,
    -- Rating table of all activities for daily functions
    ActivityLevelDic = nil,

    -- Automatically enter daily id
    AutoEnterDailyId = nil,
    -- Daily parameters that automatically enter
    AutoEnterDailyParam = nil,

    -- Daily ID corresponding to the map
    MapOwnerDaily = nil,
}

function DailyActivitySystem:Initialize()
    GameCenter.RegFixEventHandle(LogicEventDefine.EVENT_COIN_CHANGE_UPDATE, self.CoinChange, self)
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_FIRSTENTERMAP, self.OnFirstEnterMap, self)
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_PLAYER_LEVEL_CHANGED, self.OnLevelChanged, self)

    self.MapOwnerDaily = Dictionary:New()
    DataConfig.DataDaily:Foreach(function(k, v)
        if v.IfOpen ~= 0 then
            if v.CloneID == nil then
                Debug.Log("---------------> Daily activity ID ="..k.." CloneID is nil")
            else
                local _cloneIds = Utils.SplitNumber(v.CloneID, '_')
                for i = 1, #_cloneIds do
                    local _dcCfg = DataConfig.DataCloneMap[_cloneIds[i]]
                    if _dcCfg ~= nil then
                        self.MapOwnerDaily[_dcCfg.Mapid] = k
                    end
                end
            end
        end
    end)
end

function DailyActivitySystem:UnInitialize()
    self.IsJoinWeekVip = false;
    self.ReceiveGiftIDList:Clear()
    self.DailyActivitylist:Clear()
    self.LimitActivityList:Clear()
    self.CrossServerActivityList:Clear()
    self.OpenPushActivityList:Clear()
    self.ReadyTimeContainer:Clear()
    self.ServerMatchInfoLvDic:Clear()
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EVENT_COIN_CHANGE_UPDATE, self.CoinChange, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_FIRSTENTERMAP, self.OnFirstEnterMap, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_PLAYER_LEVEL_CHANGED, self.OnLevelChanged, self)
end

-- Enter the scene processing
function DailyActivitySystem:OnEnterScene()
    if self.AutoEnterDailyId ~= nil then
        self:ReqJoinActivity(self.AutoEnterDailyId, self.AutoEnterDailyParam)
    end
    self.AutoEnterDailyId = nil
    self.AutoEnterDailyParam = nil
end

function DailyActivitySystem:Update(dt)
    if self.ReadyTimeContainer:Count() > 0 then
        for k, v in pairs(self.ReadyTimeContainer) do
            if v > 0 then
                self.ReadyTimeContainer[k] = v - dt
            else
                self.ReadyTimeContainer:Remove(k)
            end
        end
    end
end

function DailyActivitySystem:GetActivityInfo(id)
    if not self.AllActivityIdList:Contains(id) then
        return nil
    end
    for i = 1, self.DailyActivitylist:Count() do
        if self.DailyActivitylist[i].ID == id then
            return self.DailyActivitylist[i]
        end
    end
    for i = 1, self.LimitActivityList:Count() do
        if self.LimitActivityList[i].ID == id then
            return self.LimitActivityList[i]
        end
    end
    return nil
end

function DailyActivitySystem:CheckDailyListContains(id)
    for i = 1, #self.DailyActivitylist do
        if self.DailyActivitylist[i].ID == id then
            return true
        end
    end
    return false
end

function DailyActivitySystem:CheckLimitListContains(id)
    for i = 1, #self.LimitActivityList do
        if self.LimitActivityList[i].ID == id then
            return true
        end
    end
    return false
end

function DailyActivitySystem:SortActivityList(noSortLimit)
    if not noSortLimit then
        table.sort(self.LimitActivityList, function(a, b)
            if a.ShowSort == b.ShowSort then
                return a.Sort < b.Sort
            else
                return a.ShowSort < b.ShowSort
            end
        end)
    end
    table.sort(self.DailyActivitylist, function(a, b)
        if a.ShowSort == b.ShowSort then
            return a.Sort < b.Sort
        else
            return a.ShowSort < b.ShowSort
        end
    end)
end

-- Find a way
function DailyActivitySystem:Navigate(npcID)
    local _p = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _p ~= nil then
        local _strs = Utils.SplitStr(npcID, ";")
        for i = 1, _strs:Count() do
            local _npcID = Utils.SplitStr(_strs[i])[3]
            if _npcID then
                GameCenter.PathSearchSystem:SearchPathToNpcTalk(_npcID)
            end
        end
    end
end

-- Get the event opening time
function DailyActivitySystem:GetActivityOpenTime(id)
    local _cfg = DataConfig.DataDaily[id]
    if not _cfg then
        return ""
    end
    -- Weekly Activities
    if tonumber(_cfg.OpenTime) ~= 0 and _cfg.SpecialOpen ~= Time.GetOpenSeverDay() then
        return _cfg.OpenTimeDes
    else
        local _timeStr = Utils.SplitStrBySeps(_cfg.Time, {';', '_'})
        local _t = Time.GetNowTable();
        local _hour = _t.hour;
        local _minute = _t.min;
        for i = 1, #_timeStr do
            local _startHour = math.floor(_timeStr[i][1] // 60)
            local _stattMinute = math.floor(_timeStr[i][1] % 60)
            if _startHour > _hour then
                return UIUtils.CSFormat(DataConfig.DataMessageString.Get("DailyActivtyOpenTips"), _startHour,
                           _stattMinute)
            elseif _startHour == _hour and _stattMinute > _minute then
                return UIUtils.CSFormat(DataConfig.DataMessageString.Get("DailyActivtyOpenTips"), _startHour,
                           _stattMinute)
            end
        end
        if id == 2 then
            return DataConfig.DataMessageString.Get("ActiveValueNotEnough")
        end
        if tonumber(_cfg.OpenTime) ~= 0 and _cfg.SpecialOpen == Time.GetOpenSeverDay() then
            return _cfg.OpenTimeDes
        else
            return DataConfig.DataMessageString.Get("TomorrowOpen")
        end
    end
end

-- Get preparation time
function DailyActivitySystem:GetActivityReadyTime(id)
    if self.ReadyTimeContainer:ContainsKey(id) then
        return self.ReadyTimeContainer[id]
    end
    return 0
end

-- Currency changes
function DailyActivitySystem:CoinChange(obj, sender)
    if obj > 0 and obj == ItemTypeCode.ActivePoint then
        for i = 1, #self.DailyActivitylist do
            if self.DailyActivitylist[i].ID == 2 then
                local _active = GameCenter.ItemContianerSystem:GetEconomyWithType(ItemTypeCode.ActivePoint)
                self.DailyActivitylist[i].IsOpen = _active > 0
                break
            end
        end
        self:SortActivityList(true)
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_REFRESH_DAILYPANEL)
    end
end

-- Get the end time of the current activity, and return to empty if the current activity is not opened.
function DailyActivitySystem:DailyIsShowRedPoint()
    local _showRed = false
    for i = 1, #self.DailyActivitylist do
        local _d = self.DailyActivitylist[i]
        if _d.IsOpen and _d.Open and _d.RemindCount ~= 0 then
            _showRed = true
            break
        end
    end
    return _showRed
end

-- Show whether the activity displays red dots
function DailyActivitySystem:LimitIsShowRedPoint()
    local _showRed = false
    for i = 1, #self.LimitActivityList do
        local _d = self.LimitActivityList[i]
        if _d.IsOpen and _d.Open and _d.RemindCount ~= 0 then
            _showRed = true
            break
        end
    end
    return _showRed
end

-- Get if there are red dots for a limited-time event
function DailyActivitySystem:GetLimitActiveRedByID(id)
    local _showRed = false
    for i = 1, #self.LimitActivityList do
        local _d = self.LimitActivityList[i]
        if _d.ID == id then
            if _d.IsOpen and _d.Open then
                _showRed = true
            end
            break
        end
    end
    return _showRed
end

-- Whether the active reward displays red dots
function DailyActivitySystem:ActiveIsShowRedPoint()
    local _showRed = false
    DataConfig.DataDailyReward:Foreach(function(k, v)
        if not self.ReceiveGiftIDList:Contains(k) and v.QNeedintegral <= self.CurrActive then
            _showRed = true
        end
    end)
    return _showRed
end

-- Activity red dot detection
function DailyActivitySystem:ActiveRedPointCheck()
    GameCenter.RedPointSystem:RemoveFuncCondition(FunctionStartIdCode.DailyActivity, 3)
    local _activeRed = self:ActiveIsShowRedPoint()
    if _activeRed then
        local _conditions3 = List:New()
        _conditions3:Add(RedPointCustomCondition(true))
        GameCenter.RedPointSystem:LuaAddFuncCondition(FunctionStartIdCode.DailyActivity, 3, _conditions3)
    end
end

-- Red dot detection
function DailyActivitySystem:CheckIsShowRedPoint()
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.DailyActivity, self:DailyIsShowRedPoint())
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.LimitActivity, self:LimitIsShowRedPoint())
    self:ActiveRedPointCheck()
end

-- Participate in the event
function DailyActivitySystem:JoinActivity(id)
    local _cfg = DataConfig.DataDaily[id]
    if not _cfg then
        return
    end

    -- Chỉnh sửa để event boss dã ngoại --- tạm thời check id, sau này nếu cần thêm cột mới vào file excel để check mở form
    if id == 213 then
        GameCenter.PushFixEvent(UIEventDefine.UICampMapForm_OPEN)
        return
    end

    if id == 18 then
        self.IsJoinWeekVip = true;
    end
    -- BI burial point
    if id == 1 then
        GameCenter.BISystem:ReqClickEvent(BiIdCode.WYJDailyEnter);
    elseif id == 2 then
        GameCenter.BISystem:ReqClickEvent(BiIdCode.ZMCDDailyEnter);
    elseif id == 4 then
        GameCenter.BISystem:ReqClickEvent(BiIdCode.WJXYDailyEnter);
    elseif id == 5 then
        GameCenter.BISystem:ReqClickEvent(BiIdCode.ArenaDailyEnter);
    elseif id == 6 then
        GameCenter.BISystem:ReqClickEvent(BiIdCode.TJZMDailyEnter);
    elseif id == 7 then
        -- GameCenter.BISystem:ReqClickEvent(BiIdCode.DNYFDailyEnter);
    elseif id == 8 then
        GameCenter.BISystem:ReqClickEvent(BiIdCode.LYYTDailyEnter);
    elseif id == 9 then
        GameCenter.BISystem:ReqClickEvent(BiIdCode.XMHJDailyEnter);
    elseif id == 10 then
        GameCenter.BISystem:ReqClickEvent(BiIdCode.SLTDailyEnter);
    elseif id == 17 then
        GameCenter.BISystem:ReqClickEvent(BiIdCode.XMTaskDailyEnter);
    elseif id == 207 then
        GameCenter.BISystem:ReqClickEvent(BiIdCode.FDBossDailyEnter);
    elseif id == 11 then
        GameCenter.BISystem:ReqClickEvent(BiIdCode.JJSYDailyEnter);
    elseif id == 14 then
        GameCenter.BISystem:ReqClickEvent(BiIdCode.NSFYDailyEnter);
    elseif id == 109 then
        GameCenter.BISystem:ReqClickEvent(BiIdCode.HDMJDailyEnter);
    elseif id == 102 then
        GameCenter.BISystem:ReqClickEvent(BiIdCode.TMGCEnter);
    elseif id == 103 then
        GameCenter.BISystem:ReqClickEvent(BiIdCode.TDMJEnter);
    end

    if _cfg.OpenType == 1 then
        local _uiCfg = Utils.SplitStr(_cfg.OpenUI, "_")
        if #_uiCfg == 1 then
            GameCenter.MainFunctionSystem:DoFunctionCallBack(tonumber(_uiCfg[1]), id)
        elseif #_uiCfg == 2 then
            GameCenter.MainFunctionSystem:DoFunctionCallBack(tonumber(_uiCfg[1]), tonumber(_uiCfg[2]))
        end
    elseif _cfg.OpenType == 2 then
        if _cfg.NpcID then
            self:Navigate(_cfg.NpcID)
        end
    elseif _cfg.OpenType == 3 then
        self:ReqJoinActivity(_cfg.Id)
    elseif _cfg.OpenType == 4 then
        GameCenter.BossSystem:EnterSuitBossCopy();
    elseif _cfg.OpenType == 5 then
        local _task = GameCenter.LuaTaskManager:GetDailyTask()
        if _task == nil then
            GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.TaskDaily)
        else
            if _task.Data.IsAccess then
                GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.TaskDaily)
            else
                local _uiCfg = Utils.SplitNumber(_cfg.OpenUI, "_")
                GameCenter.TaskController:RunDaiyTask(_uiCfg[1], false, true);
                GameCenter.PushFixEvent(UIEventDefine.UIDailyActivityForm_CLOSE)
            end
        end
    end
end

-- Update activity information
function DailyActivitySystem:UpdateActivityInfo(list, info)
    for i = 1, #list do
        if list[i].ID == info.activeId then
            list[i]:UpdateInfo(info)
        end
    end
end

-- Request to open the daily interface
function DailyActivitySystem:ReqActivePanel()
    GameCenter.Network.Send("MSG_Dailyactive.ReqDailyActivePanel", {})
end

-- Receive active treasure chest
function DailyActivitySystem:ReqGetActiveReward(giftID)
    local _req = {}
    _req.id = giftID
    GameCenter.Network.Send("MSG_Dailyactive.ReqGetActiveReward", _req)
end

-- Requesting to open push activity
function DailyActivitySystem:ReqDailyPushIds(idList)
    local _req = {}
    local _temp = {}
    if idList ~= nil and idList:Count() > 1 then
        for i = 1, idList:Count() do
            table.insert(_temp, idList[i])
        end
    end
    _req.activeIdList = _temp
    GameCenter.Network.Send("MSG_Dailyactive.ReqDailyPushIds", _req)
end

-- Can you jump to each other in daily life
function DailyActivitySystem:CanEnterEachOther(dailyId)
    if dailyId == 4 then -- Wuji Ruins
        return true
    elseif dailyId == 20 then -- Infinite layers
        return true
    elseif dailyId == 12 then -- Crystal Armor and Domain
        return true
    elseif dailyId == 19 then -- Elite hunting
        return true
    elseif dailyId == 20 then -- Infinite Chief
        return true
    elseif dailyId == 207 then -- The Immortal Alliance Blessed Land
        return true
    elseif dailyId == 101 then -- VIP leader
        return true
    end
    return false
end

-- Can you jump to each other in different daily life
function DailyActivitySystem:CanEnterOtherDaily(curDailyId, dailyId)
    if curDailyId == 101 and dailyId == 20 then
        return false
    end
    if (curDailyId == 4 or curDailyId == 101 or curDailyId == 20) and
        (dailyId == 4 or dailyId == 101 or dailyId == 20) then
        return true
    end
    return false
end

-- Participate in the event (currently only for copy)
function DailyActivitySystem:ReqJoinActivity(id, param)
    local _mapCfg = GameCenter.MapLogicSystem.MapCfg
    if _mapCfg == nil then
        return
    end
    local _dailyCfg = DataConfig.DataDaily[id]
    if _dailyCfg == nil then
        return
    end
    local _curMapId = _mapCfg.MapId
    local _cloneCfg = DataConfig.DataCloneMap[param]
    if _cloneCfg ~= nil and _curMapId == _cloneCfg.Mapid then
        -- In the current copy map
        Utils.ShowPromptByEnum("C_ALREADY_COPYMAP", _dailyCfg.Name)
        return
    else
        local _inSameDaily = false
        local _cloneIds = Utils.SplitNumber(_dailyCfg.CloneID, '_')
        for i = 1, #_cloneIds do
            local _dcCfg = DataConfig.DataCloneMap[_cloneIds[i]]
            if _dcCfg ~= nil then
                if _dcCfg.Mapid == _curMapId then
                    -- In the current copy map
                    _inSameDaily = true
                    break
                end
            else
                Debug.LogError("Current copy ID =".._cloneIds[i].."Does not exist")
            end
        end
        if _inSameDaily then
            if self:CanEnterEachOther(id) then
                -- Send an incoming message
                local _req = {}
                _req.dailyId = id
                _req.param = param
                GameCenter.Network.Send("MSG_Dailyactive.ReqJoinDaily", _req)
                return
            end
        else
            local _curDailyId = self.MapOwnerDaily[_curMapId]
            if self:CanEnterOtherDaily(_curDailyId, id) then
                -- Send an incoming message
                local _req = {}
                _req.dailyId = id
                _req.param = param
                GameCenter.Network.Send("MSG_Dailyactive.ReqJoinDaily", _req)
                return
            end
        end
    end
    if _mapCfg.ReceiveType == 0 then
        Utils.ShowPromptByEnum("C_PLEASE_LEAVE_CURCOPY")
        return
    end
    if _mapCfg.ReceiveType == 1 then
        -- Pop-up exit copy prompt
        Utils.ShowMsgBox(function(code)
            if code == MsgBoxResultCode.Button2 then
                self.AutoEnterDailyId = id
                self.AutoEnterDailyParam = param
                GameCenter.MapLogicSystem:SendLeaveMapMsg(false)
            end
        end, "C_AUTOENTER_EXIT_ASK", _dailyCfg.Name)
        return
    end

    -- Send an incoming message
    local _req = {}
    _req.dailyId = id
    _req.param = param
    GameCenter.Network.Send("MSG_Dailyactive.ReqJoinDaily", _req)
end

-- Game server Request public server Server grouping data
function DailyActivitySystem:ReqCrossServerMatch()
    GameCenter.Network.Send("MSG_Dailyactive.ReqCrossServerMatch", {})
end

-- Open the daily interface and return
function DailyActivitySystem:GS2U_ResDailyActivePenel(msg)


    Debug.Log("GS2U_ResDailyActivePenelGS2U_ResDailyActivePenelGS2U_ResDailyActivePenel======", Inspect(msg))

    if not msg.dailyInfoList then
        return
    end
    self.CurrActive = msg.value
    self.MaxActive = msg.activeMax
    self.AddActive = msg.activeAdded
    self.UseItemCount = msg.useItemCount
    self.ReceiveGiftIDList:Clear()
    if msg.drawList then
        for i = 1, #msg.drawList do
            self.ReceiveGiftIDList:Add(msg.drawList[i])
        end
    end
    self.AllActivityIdList:Clear()
    self.DailyActivitylist:Clear()
    self.LimitActivityList:Clear()
    self.AllActivityDic:Clear()
    self.CrossServerActivityList:Clear()
    for i = 1, #msg.dailyInfoList do
        if msg.dailyInfoList[i].activeId == 207 then
            GameCenter.FuDiSystem:CheckFunction(msg.dailyInfoList[i].open)
        end
        local _id = msg.dailyInfoList[i].activeId
        local _cfg = DataConfig.DataDaily[_id]
        if not _cfg then
            return
        end
        if _cfg.Canshow == 1 then
            local _activityType = _cfg.Fbtype
            local _data = DailyActivityData:New(msg.dailyInfoList[i], _cfg);
            if _activityType == ActivityTypeEnum.Daily then
                self.DailyActivitylist:Add(_data)
            elseif _activityType == ActivityTypeEnum.Limit then
                self.LimitActivityList:Add(_data)
            end
            self.AllActivityDic:Add(_id, _data)
            -- Cross-server activities
            if _cfg.Ifcross == 1 then
                self.CrossServerActivityList:Add(_id)
            end
            self.AllActivityIdList:Add(_id)
        end
    end
    self:SortActivityList()
    self:CheckIsShowRedPoint()
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_REFRESH_DAILYPANEL)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_CHUANDAOTIPS)
end

-- Changes in daily activities
function DailyActivitySystem:GS2U_ResUpdateDailyActiveInfo(msg)
    self.CurrActive = msg.value
    self.MaxActive = msg.activeMax
    self.AddActive = msg.activeAdded
    self.UseItemCount = msg.useItemCount
    if msg.info then
        local _cfg = DataConfig.DataDaily[msg.info.activeId]
        if not _cfg then
            return
        end
        if _cfg.Canshow == 1 then
            if _cfg.Fbtype == ActivityTypeEnum.Daily then
                self:UpdateActivityInfo(self.DailyActivitylist, msg.info)
            elseif _cfg.Fbtype == ActivityTypeEnum.Limit then
                self:UpdateActivityInfo(self.LimitActivityList, msg.info)
            end
        end
    end
    self:SortActivityList()
    self:CheckIsShowRedPoint()
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_REFRESH_DAILYPANEL)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_ACTIVEPANEL)
end

-- Request to receive active return
function DailyActivitySystem:GS2U_ResGetActiveReward(msg)
    if msg.result == 0 then
        GameCenter.DailyActivitySystem.ReceiveGiftIDList:Clear()
        for i = 1, #msg.drawIdList do
            GameCenter.DailyActivitySystem.ReceiveGiftIDList:Add(msg.drawIdList[i])
        end
    end
    self:ActiveRedPointCheck()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_ACTIVEPANEL)
end

-- Daily push returns
function DailyActivitySystem:GS2U_ResDailyPushResult(msg)
    if msg.activeIdList ~= nil then
        self.OpenPushActivityList:Clear()
        for i = 1, #msg.activeIdList do
            self.OpenPushActivityList:Add(msg.activeIdList[i])
        end
    end
end

function DailyActivitySystem:GS2U_ResDailyActivityOpenStatus(msg)
    -- Special treatment blessed land
    if msg.dailyId == 207 then
        GameCenter.FuDiSystem:CheckFunction(msg.open)
    end
    local _cfg = DataConfig.DataDaily[msg.dailyId]
    if not _cfg then
        return
    end
    if _cfg.Fbtype == ActivityTypeEnum.Limit then
        for i = 1, self.LimitActivityList:Count() do
            if self.LimitActivityList[i].ID == msg.dailyId then
                self.LimitActivityList[i]:SetActivityOpen(msg.open)
            end
        end
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_REFRESH_ACTIVITYLIST, ActivityTypeEnum.Limit, nil)
    end
end

-- Server information matching at each stage
function DailyActivitySystem:GS2U_ResCrossServerMatch(msg)
    if msg then
        if msg.serverMatch_2 and #msg.serverMatch_2 > 0 then
            self.ServerMatchInfoLvDic[2] = ServerMatchInfo:New(msg.serverMatch_2)
        end
        if msg.serverMatch_4 and #msg.serverMatch_4 > 0 then
            self.ServerMatchInfoLvDic[4] = ServerMatchInfo:New(msg.serverMatch_4)
        end
        if msg.serverMatch_8 and #msg.serverMatch_8 > 0 then
            self.ServerMatchInfoLvDic[8] = ServerMatchInfo:New(msg.serverMatch_8)
        end
        if msg.serverMatch_16 and #msg.serverMatch_16 > 0 then
            self.ServerMatchInfoLvDic[16] = ServerMatchInfo:New(msg.serverMatch_16)
        end
        if msg.serverMatch_32 and #msg.serverMatch_32 > 0 then
            self.ServerMatchInfoLvDic[32] = ServerMatchInfo:New(msg.serverMatch_32)
        end
        GameCenter.BaJiZhenSystem:SetJinDuData(msg)
    end
end

function DailyActivitySystem:OnFirstEnterMap()
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.Calendar, true)
    -- -- Functional preview
    -- local _funcInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.ActivityNotice);
    -- if _funcInfo.IsVisible then
    --     local _id = GameCenter.GameSceneSystem:GetLocalPlayerID();
    --     local _t = Time.GetNowTable();
    --     local _curTime = _t.year * 10000 + _t.month * 100 + _t.day;
    --     local _key = string.format("ActiveNotice_%s", _id);
    --     if PlayerPrefs.HasKey(_key) then
    --         if PlayerPrefs.GetInt(_key) ~= _curTime then
    --             GameCenter.PushFixEvent(UILuaEventDefine.UIActivityNoticeForm_OPEN)
    --             PlayerPrefs.SetInt(_key, _curTime);
    --         end
    --     else
    --         GameCenter.PushFixEvent(UILuaEventDefine.UIActivityNoticeForm_OPEN)
    --         PlayerPrefs.SetInt(_key, _curTime);
    --     end
    -- end
    -- Add a pop-up window to the online anti-addiction Ding Huaqiang 2020-08-04
    if GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.Certification) then
        GameCenter.PushFixEvent(UILuaEventDefine.UIFcmForm_OPEN)
    end
end

-- Get the activity status
function DailyActivitySystem:GetActiveityState(id)
    local _data = self.AllActivityDic[id];
    if _data then
        return _data:GetState()
    end
end

-- Can you participate
function DailyActivitySystem:CanJoinDaily(id)
    if id == 17 or id == 110 or id == 111 then
        local _haveGuild = false
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if _lp ~= nil then
            _haveGuild = _lp.GuildID > 0
        end
        if not _haveGuild then
            return false;
        end
    end
    return self:GetActiveityState(id) == ActivityState.CanJoin
end

-- Get the activity status
function DailyActivitySystem:OnLevelChanged()
    local _curLevel = GameCenter.GameSceneSystem:GetLocalPlayerLevel();
    if not self.ActivityLevelDic then
        self.ActivityLevelDic = {}
        DataConfig.DataDaily:Foreach(function(k, v)
            self.ActivityLevelDic[v.OpenLevel] = true
        end);
    end
    if self.ActivityLevelDic[_curLevel] then
        self:ReqActivePanel();
    end
end

return DailyActivitySystem
