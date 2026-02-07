------------------------------------------------
-- Author: 
-- Date: 2019-05-5
-- File: MarriageSystem.lua
-- Module: MarriageSystem
-- Description: Marriage System
------------------------------------------------
local L_TimeUtils = CS.Thousandto.Core.Base.TimeUtils;
local L_SpouseData = require("Logic.Marriage.SpouseData")
local L_MarriageEnum = require("Logic.Marriage.MarriageEnum")
local RedPointItemCondition = CS.Thousandto.Code.Logic.RedPointItemCondition

-- //Module definition
local MarriageSystem =
{
    -- Companion data
    SpouseData = nil,
    -- Wedding appointment data
    WeddingDataList = nil,
    -- Appointment status
    BanquetTimeDict = nil,
    -- Married wedding reception type
    BanquetTypeList = nil,
    -- List of invited guest members
    InviteMembersDict = nil,
    -- List of members who request an invitation
    DemandMembersDict = nil,
    -- Days of marriage
    MarryDay = 0,
    -- Intimacy
    Intimacy = 0,
    -- Number of wedding receptions
    WeddingNum = 0,
    -- Number of invitations purchased
    InvitedBuyNum = 0,
    -- The ID of the person who appeals for divorce [The claimant ID is 0 and can be declared. Id is already declared. Id does not mean that I confirm the negotiation of divorce]
    AppealPlayerID = 0,
    -- The current wedding reception type
    CurMarriageType = L_MarriageEnum.MarryTypeEnum.Normal,
    -- Second
    MapCopyTime = 900,
    -- Marriage Copy ID
    MarryCopyID = 3001,
    -- Id of love copy
    MarryQingYuanCopyID = 110001,
    -- Heart lock level
    HeartLockLv = 0,
    -- Heart lock experience
    HeartLockExp = 0,
    -- Fairy Box Data
    MarryBoxDataDict = nil,
    -- The data of the fairy
    MarryChildDataDict = nil,
    -- Data required for the Love Trial Interface
    QingYuanCloneData = nil,
    -- The item ID of the Xianwa activated or upgraded
    ChildActiveOrUpgradeID = nil,
    ItemChangeEvent = nil,
    -- Gameplay introduction interface status data [ID,States]
    MarryTaskStatesDict = nil,
    IsShowMarryTaskForm = false,

    -- Cache World Blessings List
    CacheWorldZhuFuList = nil,

    -- Current wedding banquet status, 0 No wedding banquet, 1 waiting to be opened, 2 has been opened
    CurHunYanState = 0,
    CurHunYanRemainTime = 0,
    CurHunYanData = nil,
}

-- //Member function definition
-- initialization
function MarriageSystem:Initialize()
    self.WeddingDataList = List:New()
    self.BanquetTimeDict = Dictionary:New()
    self.InviteMembersDict = Dictionary:New()
    self.DemandMembersDict = Dictionary:New()
    self.SpouseData = L_SpouseData:New()
    self.MarryBoxDataDict = Dictionary:New()
    self.MarryChildDataDict = Dictionary:New()
    self.ChildActiveOrUpgradeID = List:New()
    self.MarryTaskStatesDict = Dictionary:New()
    self.MapCopyTime = tonumber(DataConfig.DataCloneMap[self.MarryCopyID].ExistTime) / 1000
    self:InitChildData()
    self.ItemChangeEvent = Utils.Handler(self.OnItemUpdate, self)
    GameCenter.RegFixEventHandle(LogicEventDefine.EVENT_ITEM_CHANGE_UPDATE, self.ItemChangeEvent)
end

-- De-initialization
function MarriageSystem:UnInitialize()
    self.WeddingDataList:Clear()
    self.BanquetTimeDict:Clear()
    self.MarryBoxDataDict:Clear()
    self.InviteMembersDict:Clear()
    self.DemandMembersDict:Clear()
    self.MarryChildDataDict:Clear()
    self.ChildActiveOrUpgradeID:Clear()
    self.MarryTaskStatesDict:Clear()
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EVENT_ITEM_CHANGE_UPDATE, self.ItemChangeEvent)
end

function MarriageSystem:OnItemUpdate(itemID,sender)
    if self.ChildActiveOrUpgradeID:Contains(itemID) then
        self:SetChildRedPoint()
    end
end

-- Initialize the data of the fairy baby
function MarriageSystem:InitChildData()
    DataConfig.DataMarryChild:Foreach(
        function(_curChildId, _cfg)
            local _attrLevelDict = Dictionary:New()
            DataConfig.DataMarryChildAtt:ForeachCanBreak(
                function(_id, _attrCfg)
                    -- Get data from attribute table based on the main table
                    if _curChildId == _attrCfg.ChildId then
                        _attrLevelDict:Add(_attrCfg.Level, _attrCfg)
                    end
                end
            )
            local _childData = {
                SData = nil,
                CfgData = _cfg,
                AttrDict = _attrLevelDict
            }
            if not self.MarryChildDataDict:ContainsKey(_curChildId) then
                self.MarryChildDataDict:Add(_curChildId, _childData)
            end
        end
    )
    -- Status data introduced in the initial gameplay
    DataConfig.DataMarryShow:Foreach(
        function(_key, _cfg)
            if not self.MarryTaskStatesDict:ContainsKey(_key) then
                self.MarryTaskStatesDict:Add(_key, RewardState.None)
            else
                self.MarryTaskStatesDict[_key] = RewardState.None
            end
        end
    )
end

-- Update your heartbeat
function MarriageSystem:Update(dt)
    self:SetBanquetTime()

    if self.CacheWorldZhuFuList ~= nil then
        if self.WorldZhuFuUIId == nil then
            self.WorldZhuFuUIId = GameCenter.FormStateSystem:EventIDToFormID(UILuaEventDefine.UIMarryWorldZhuFuForm_OPEN)
        end
        if not GameCenter.FormStateSystem:FormIsOpen(self.WorldZhuFuUIId) then
            local _msg = self.CacheWorldZhuFuList[1]
            self.CacheWorldZhuFuList:RemoveAt(1)
            if #self.CacheWorldZhuFuList <= 0 then
                self.CacheWorldZhuFuList = nil
            end
            GameCenter.PushFixEvent(UILuaEventDefine.UIMarryWorldZhuFuForm_OPEN, _msg)
        end
    end
end

-- Refresh the time display of wedding banquet button on the main interface
function MarriageSystem:SetBanquetTime()
    if #self.WeddingDataList > 0 then
        local _firstWed = self.WeddingDataList[1]
        local _startTime = _firstWed.timeStart * 60
        local _endTime = _startTime + self.MapCopyTime
        local _serverTime = GameCenter.HeartSystem.ServerTime
        if _serverTime < _startTime and (_startTime - _serverTime) > 1800 then
            -- No display for more than 30 minutes
            self.CurHunYanState = 0
            self.CurHunYanData = nil
        elseif _serverTime < _startTime then
            -- Wait for start
            self.CurHunYanState = 1
            self.CurHunYanRemainTime = _startTime - _serverTime
            self.CurHunYanData = _firstWed
        elseif _serverTime >= _startTime and _serverTime < _endTime then
            -- Already enabled
            self.CurHunYanState = 2
            self.CurHunYanRemainTime = _endTime - _serverTime
            self.CurHunYanData = _firstWed
        else
            -- It has ended, just remove it
            self.WeddingDataList:RemoveAt(1)
            self.CurHunYanState = 0
            self.CurHunYanData = nil
        end
    else
        -- No wedding reception
        self.CurHunYanState = 0
        self.CurHunYanData = nil
    end
end

-- Return the required data online
function MarriageSystem:ResMarryOnline(msg)
    self.WeddingDataList:Clear()
    -- Appointment data
    local _weddingDataList = msg.weddingDataList
    if _weddingDataList ~= nil then
        for i = 1, #_weddingDataList do
            local _curData = _weddingDataList[i]
            self.WeddingDataList:Add(_curData)
        end
        if #self.WeddingDataList > 0 then
            -- Order by time
            self.WeddingDataList:Sort(
                function(a, b)
                    return a.timeStart < b.timeStart
                end
            )
        end
    end
    -- List of requesting invitations
    local _weddingMembersList = msg.weddingMembersList
    if _weddingMembersList ~= nil then
        for i = 1, #_weddingMembersList do
            local _curMember = _weddingMembersList[i]
            if not self.DemandMembersDict:ContainsKey(_curMember.roleId) then
                self.DemandMembersDict:Add(_curMember.roleId, _curMember.name)
            else
                self.DemandMembersDict[_curMember.roleId] = _curMember.name
            end
        end
    end
    -- Set the red dot of the heart lock
    self:SetHeartLockRedPoint()
    -- Set the red dots of the fairy baby
    self:SetChildRedPoint()

    -- Request marriage data and obtain information from the other party
    local _msg = ReqMsg.MSG_Marriage.ReqMarryData:New()
    _msg:Send()
end

-- Marriage opening notice
function MarriageSystem:ResWeddingStart(msg)
    -- Open the copy and enter the interface
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.MarryBanquet)
end

function MarriageSystem:GetBanquetTimeDict()
    -- Appointed data
    local _dict = Dictionary:New()
    local _offsetTime = GameCenter.HeartSystem.ServerZoneOffset
    for i = 1, #self.WeddingDataList do
        local _banquetTime = self.WeddingDataList[i].timeStart * 60 + _offsetTime
        _dict:Add(_banquetTime, self.WeddingDataList[i])
    end

    -- The time of the current server with time zone
    local _serverTime = math.floor(GameCenter.HeartSystem.ServerZoneTime)
    -- Calculate the time, minutes and seconds of the current time
    local _hour, _min, _sec = L_TimeUtils.GetStampTimeHHMMSSNotZone(_serverTime)
    -- The time to start today
    local _todayStartTime = _serverTime - _hour * 3600 - _min * 60 - _sec

    DataConfig.DataMarryOrder:Foreach(
        function(k, v)
            -- 1: Expired 2: Appointment 3: Appointment is available
            local _states = 0
            -- Each turn-on time
            local _cfgStartTime = math.floor(_todayStartTime + v.Time * 60)
            -- See if you have made an appointment
            if _dict:ContainsKey(_cfgStartTime) then
                _states = 2
            else
                -- Expired
                if _serverTime > _cfgStartTime then
                    _states = 1
                else
                    _states = 3
                end
            end
            if not self.BanquetTimeDict:ContainsKey(k) then
                self.BanquetTimeDict:Add(k, _states)
            else
                self.BanquetTimeDict[k] = _states
            end
        end
    )
    return self.BanquetTimeDict
end

-- Return to the proposal information
function MarriageSystem:ResMarryPropose(msg)
    -- The name of the suitor
    local _name = msg.name
    -- Profession of a suitor
    local _career = msg.career
    -- Type of marriage proposal
    local _type = msg.type
    -- Proposal id
    local _marrayId = msg.marrayId
    -- Open the consent interface
    GameCenter.PushFixEvent(UILuaEventDefine.UIMarryPromiseForm_OPEN, {marrayId = _marrayId, name = _name})
end

-- Return to the marriage proposal result information
function MarriageSystem:ResDealMarryPropose(msg)
    -- Here you need to request marriage data, mainly the number of appointments
    local _msg = ReqMsg.MSG_Marriage.ReqMarryData:New()
    _msg:Send()
    -- Update spouse information
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    -- Compare your name first to see if it is your marriage proposal
    if _lp.Name ~= msg.marrayName then
        self.SpouseData.Name = msg.marrayName
        self.SpouseData.Career = msg.marraycareer
    else
        self.SpouseData.Name = msg.bemarrayName
        self.SpouseData.Career = msg.bemarraycareer
    end
    _lp:SetSpouseName(self.SpouseData.Name)
    self:CheckMarryCopyRedPoint()
    -- Open the interface for marriage (prepare to jump to the appointment interface)
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.MarryEngagement, 2)
end

-- Return to the appointment results
function MarriageSystem:ResSelectWedding(msg)
    -- 0 Success 1: Already made an appointment 2: I made an appointment by someone else 3: Time expired (1, 2, 3 failed)
    local _code = msg.res
    -- Appointment was successful
    if _code == 0 then
        if self.WeddingNum > 0 then
            self.WeddingNum = self.WeddingNum - 1
        end
        Utils.ShowPromptByEnum("C_MARRY_YUYUE_SUCC")
        local _cfg = DataConfig.DataMarryOrder[msg.weddingId]
        local _sHour = _cfg.Time // 60
        local _sMin = _cfg.Time % 60
        local _eHour = _cfg.EndTime // 60
        local _eMin = _cfg.EndTime % 60
        local _timeText = string.format("%0.2d:%0.2d - %0.2d:%0.2d", _sHour, _sMin, _eHour, _eMin)
        local _askText = UIUtils.CSFormat(DataConfig.DataMessageString.Get("C_MARRY_AUTO_YAOQING_ASK"), self.SpouseData.Name, _timeText)
        GameCenter.MsgPromptSystem:ShowMsgBox(_askText,
            DataConfig.DataMessageString.Get("C_MSGBOX_CANCEL"),
            DataConfig.DataMessageString.Get("C_MSGBOX_OK"),
            function (code)
                -- agree
                if (code == MsgBoxResultCode.Button2) then
                    local _msg = ReqMsg.MSG_Marriage.ReqInvit:New()
                    _msg.roleId = 0
                    _msg.type = 0
                    _msg:Send()
                    Utils.ShowPromptByEnum("C_MARRY_AUTO_YUYUE_RESULT")
                end
            end,
            false,
            false, 15, 4, 1, nil, nil, 0, true)
    -- Already made an appointment
    elseif _code == 1 then
        Utils.ShowPromptByEnum("C_MARRY_YUYUE_ALREADY")
    -- I've made an appointment by someone else
    elseif _code == 2 then
        Utils.ShowPromptByEnum("C_MARRY_YUYUE_OTHERALREADY")
    -- Time expired (1, 2, 3 failed)
    elseif _code == 3 then
        Utils.ShowPromptByEnum("C_MARRY_YUYUE_TIMEOUT")
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MARRY_WEDDING_DATA_REFRESH)
end

-- Return to marriage information
function MarriageSystem:ResMarryData(msg)
    -- Days of marriage
    self.MarryDay = msg.marryDay
    -- Number of wedding receptions
    if msg.weddingNum > 0 then
        self.WeddingNum = msg.weddingNum
    end
    -- Married wedding reception type
    self.BanquetTypeList = List:New(msg.tList)
    if self.BanquetTypeList ~= nil and #self.BanquetTypeList > 0 then
        -- Arrange in order to get the largest type
        self.BanquetTypeList:Sort(
            function(a, b)
                return a > b
            end
        )
        self.CurMarriageType = self.BanquetTypeList[1]
    end
    -- The claimant ID Id is 0 and can be declared. Id is already declared. Id does not mean that I confirm the negotiation and divorce.
    self.AppealPlayerID = msg.divorceId
    -- Spouse's data information
    self.SpouseData:RefeshData(msg)
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp ~= nil then
        _lp:SetSpouseName(self.SpouseData.Name)
    end
    self.SpouseData.PlayerID = msg.playerId
    -- Intimacy
    if msg.intimacy ~= nil and msg.intimacy > 0 then
        self.Intimacy = msg.intimacy
    else
        if msg.playerId ~= nil and msg.playerId > 0 then
            local _friendData = GameCenter.FriendSystem:GetFriendInfo(FriendType.Friend, msg.playerId)
            if _friendData ~= nil then
                self.Intimacy = _friendData.intimacy
            end
        end
    end
    -- Number of invitations purchased
    if msg.purNum ~= nil and msg.purNum > 0 then
        self.InvitedBuyNum = msg.purNum
    end
    -- List of invited friends
    self.InviteMembersDict:Clear()
    local _weddingMembersList = msg.weddingMembersList
    if _weddingMembersList ~= nil then
        for i = 1, #_weddingMembersList do
            local _curMember = _weddingMembersList[i]
            if not self.InviteMembersDict:ContainsKey(_curMember.roleId) then
                self.InviteMembersDict:Add(_curMember.roleId, _curMember.name)
            else
                self.InviteMembersDict[_curMember.roleId] = _curMember.name
            end
        end
    end
    self:CheckMarryCopyRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MARRY_INFO_REFRESH)
    -- Refresh wedding information
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MARRY_WEDDING_DATA_REFRESH)
    -- Refresh the number of invitations
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MARRY_INVITED_FRIEND_UPDATE)
    -- Refresh title
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_TITLE_REFRESH_MARRIAGE_USE)
end

-- Update wedding reception data
function MarriageSystem:ResUpdateWedding(msg)
    local _count = #self.WeddingDataList
    local _index = 0
    if _count > 0 and msg.weddingData ~= nil then
        local _hasSameData = false
        for i = 1, _count do
            if msg.weddingData.timeStart == self.WeddingDataList[i].timeStart then
                self.WeddingDataList[i] = msg.weddingData
                _hasSameData = true
                _index = i
                break
            end
        end
        if not _hasSameData then
            self.WeddingDataList:Add(msg.weddingData)
        else
            self.WeddingDataList[_index] = msg.weddingData
        end
    else
        self.WeddingDataList:Add(msg.weddingData)
    end
    self.WeddingDataList:Sort(
        function(a, b)
            return a.timeStart < b.timeStart
        end
    )
end

-- Divorce successful
function MarriageSystem:ResDivorce(msg)
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    Utils.ShowPromptByEnum("Divorce_Success_Mail", _lp.Name, self.SpouseData.Name)
    self.SpouseData:ClearData()
    self.Intimacy = 0
    self.MarryDay = 0
    self.MarryBoxData = nil
    self:CheckMarryCopyRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MARRY_INFO_REFRESH)
end

-- Successful statement
function MarriageSystem:ResDivorceID(msg)
    -- The ID of the person who complains about the divorce
    local _lpID = GameCenter.GameSceneSystem:GetLocalPlayerID()
    -- Id has declared for himself that id does not mean that he is confirming the negotiation of divorce
    if msg.roleId ~= _lpID then
        -- Give a countdown, turn off MsgBox after countdown
        GameCenter.MsgPromptSystem:ShowMsgBox( DataConfig.DataMessageString.Get("C_MARRY_Divorce_Shensu_TIPS"),
            DataConfig.DataMessageString.Get("TEAM_REFUSE"),
            DataConfig.DataMessageString.Get("C_MSGBOX_OK"),
            function (code)
                -- Agree to divorce
                if (code == MsgBoxResultCode.Button2) then
                    local _msg = ReqMsg.MSG_Marriage.ReqAffirmDivorce:New()
                    -- 0 Reject 1 Agree
                    _msg.opt = 1
                    _msg:Send()
                -- Refuse to divorce
                else
                    local _msg = ReqMsg.MSG_Marriage.ReqAffirmDivorce:New()
                    -- 0 Reject 1 Agree
                    _msg.opt = 0
                    _msg:Send()
                end
            end,
            false,
            true,
            tonumber(DataConfig.DataGlobal[1891].Params)
        )
    else
        -- It was a divorce complaint, and the prompt said the complaint was successful
        Utils.ShowPromptByEnum("Marry_Divorce_Appl_Success")
    end
    self.AppealPlayerID = msg.roleId
end

-- Delete the request list
function MarriageSystem:ResDeleteDemandInvit(msg)
    local _playerId = msg.roleId
    if self.InviteMembersDict:ContainsKey(_playerId) then
        self.InviteMembersDict:Remove(_playerId)
    end
end

-- Update invitation list
function MarriageSystem:ResUpdateInvit(msg)
    if msg.memberList == nil then
        return
    end
    for i = 1, #msg.memberList do
        local _mem = msg.memberList[i]
        if _mem ~= nil then
            self.InviteMembersDict[_mem.roleId] = _mem.name
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MARRY_INVITED_FRIEND_UPDATE)
end

-- Return to the request result
function MarriageSystem:ResDemandInvit(msg)
    -- 0 Success 1 Wedding banquet does not exist 2 Already in the request list 3 Already in the invitation list 4 invitation limit
    local _code = msg.res
    if _code == 0 then
        Utils.ShowPromptByEnum("Marry_Ask_Invitation_Card")
    elseif _code == 1 then
        -- The wedding banquet no longer exists
        Utils.ShowPromptByEnum("Marry_DemandInvit_Dinner_NotFound")
    elseif _code == 2 then
        -- Already in the invitation list
        Utils.ShowPromptByEnum("Marry_Ask_Invitation_Card")
    elseif _code == 3 then
        -- Already in the invitation list
        Utils.ShowPromptByEnum("Marry_DemandInvit_InVited")
    elseif _code == 4 then
        -- Guest invitation limit has been reached
        Utils.ShowPromptByEnum("Marry_DemandInvit_NumMax")
    elseif _code == 5 then
        -- You can't ask for an invitation by yourself
        Utils.ShowPromptByEnum("Marry_DemandInvit_CannotBySelf")
    end
end

-- If the newlyweds notify the list of requesters online
function MarriageSystem:ResUpdateDemandInvit(msg)
    local _mem = msg.member
    -- Need to make red dots here
    if _mem ~= nil then
        if not self.DemandMembersDict:ContainsKey(_mem.roleId) then
            self.DemandMembersDict:Add(_mem.roleId, _mem.name)
        else
            self.DemandMembersDict[_mem.roleId] = _mem.name
        end
        -- The main interface displays guest buttons
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MAIN_SHOW_BINGKE)
    end
end

-- Successful purchase invitation number
function MarriageSystem:ResPurInvitNum(msg)
    self.InvitedBuyNum = self.InvitedBuyNum + 1
    -- Refresh the interface data
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MARRY_ADD_INVITE_NUM_SUCCESS)
end

-- Heart Lock Upgrade
function MarriageSystem:ResUpgradeMarryLockInfo(msg)
    if msg.level ~= nil and msg.level > 0 then
        self.HeartLockLv = msg.level
    end
    if msg.exp ~= nil and msg.exp >= 0 then
        self.HeartLockExp = msg.exp
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_REFRESH_MARRY_HEARTLOCK_FORM)
    self:SetHeartLockRedPoint()
    self:SetChildRedPoint()
end

-- My partner bought the fairy box
function MarriageSystem:ResMarryBox(msg)
    if msg ~= nil and msg.box ~= nil then
        local _boxList = msg.box
        local _lpID = GameCenter.GameSceneSystem:GetLocalPlayerID()
        for i = 1, #_boxList do
            local _boxData = _boxList[i]
            local _roleId = _boxData.role
            if not self.MarryBoxDataDict:ContainsKey(_roleId) then
                self.MarryBoxDataDict:Add(_roleId, _boxData)
            else
                self.MarryBoxDataDict[_roleId] = _boxData
            end
            if _lpID == _roleId then
                local _isReceiveToday = _boxData.reward == 1
                local _isBuyForPartner = _boxData.onceReward == 1
                local _showRedPoint = (not _isBuyForPartner and _boxData.remainTime > 0) or (not _isReceiveToday and _boxData.remainTime > 0)
                GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.MarryBox, _showRedPoint)
            end
        end
        -- Refresh the data of the fairy box interface
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MARRY_BOX_REFRESH)
    end
end

-- Friends are looking for a fairy box
function MarriageSystem:ResCallBuyMarryBox(msg)
    local _costCfg = Utils.SplitStr(DataConfig.DataGlobal[1522].Params, '_');
    local _costText = UIUtils.CSFormat("{0}{1}", tonumber(_costCfg[2]), DataConfig.DataItem[tonumber(_costCfg[1])].Name)
    Utils.ShowMsgBox(function (code)
        if (code == MsgBoxResultCode.Button2) then
            -- Buy
            local _msg = ReqMsg.MSG_Marriage.ReqBuyMarryBox:New()
            _msg:Send()
        else
            -- reject
            local _msg = ReqMsg.MSG_Marriage.ReqRefuseBuyMarryBox:New()
            _msg:Send()
        end
    end, "MARRY_BOX_BUY_DES", _costText, self.SpouseData.Name)
end

-- Synchronize the baby information
function MarriageSystem:ResMarryChildInfo(msg)
    if msg.childs ~= nil then
        local _childsList = msg.childs
        local _childCount = self.MarryChildDataDict:Count()
        -- Is it a news of the upgrade of the fairy baby?
        local _isChildLevelUp = 0
        for i = 1, #_childsList do
            local _childSData = _childsList[i]
            local _childID = _childSData.id
            if self.MarryChildDataDict:ContainsKey(_childID) then
                if self.MarryChildDataDict[_childID].SData ~= nil then
                    _isChildLevelUp = 1
                end
                self.MarryChildDataDict[_childID].SData = _childSData
                local _cfg = self.MarryChildDataDict[_childID].CfgData
                -- Activation requires a model display interface
                if _childSData.isActive then
                    GameCenter.ModelViewSystem:ShowModel(ShowModelType.Pet, _cfg.Model, _cfg.UiScale, _cfg.UiModelHeight / _cfg.UiScale, _cfg.ChildName)
                end
            else
                Debug.LogError(UIUtils.CSFormat("MarryChild!!! Can not fild child id {0} in MarryChild.xlsx", _childID))
            end
        end
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MARRY_CHILD_REFRESH, _isChildLevelUp)
        -- Set up the fairy baby red dots
        self:SetChildRedPoint()
    end
end

-- Companion requests to purchase
function MarriageSystem:ResCallMarryCloneBuy(msg)
    local _cloneMapCfg = DataConfig.DataCloneMap[self.MarryQingYuanCopyID]
    local _needNum = tonumber(_cloneMapCfg.BuyNeedGold)
    local _itemName = DataConfig.DataItem[ItemTypeCode.Gold].Name
    local _costText = UIUtils.CSFormat("{0}{1}", _needNum,_itemName)
    Utils.ShowMsgBox(function (code)
        if (code == MsgBoxResultCode.Button2) then
            -- Buy
            local _msg = ReqMsg.MSG_Marriage.ReqMarryCloneBuy:New()
            _msg:Send()
        else
            -- reject
            local _msg = ReqMsg.MSG_Marriage.ReqRefuseMarryCloneBuy:New()
            _msg:Send()
        end
    end, "C_MARRY_COPYBUY_ASK", _costText, self.SpouseData.Name)
end

-- Return the number of copies purchased
function MarriageSystem:ResMarryClone(msg)
    if msg ~= nil and msg.clone ~= nil then
        self.QingYuanCloneData = msg.clone
        self:CheckMarryCopyRedPoint()
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MARRY_BLESS_DATA_REFRESH)
    end
end

-- Check the marriage copy red dots
function MarriageSystem:CheckMarryCopyRedPoint()
    local _showRedPoint = false
    if self:HasPartner() and self.QingYuanCloneData ~= nil then
        -- Remaining challenges and purchases
        _showRedPoint = self.QingYuanCloneData.remainTimes > 0
    end
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.MarryBless, _showRedPoint)
end

-- Immortality Mission
function MarriageSystem:ResMarryTask(msg)
    -- Completed task ID list
    local _taskIdList = msg.taskId
    -- List of IDs received
    local _overIdList = msg.overId
    local _states = RewardState.None
    if _taskIdList ~= nil then
        for i = 1, #_taskIdList do
            local _finsishedId = _taskIdList[i]
            if self.MarryTaskStatesDict:ContainsKey(_finsishedId) then
                -- Completed to receive status
                self.MarryTaskStatesDict[_finsishedId] = RewardState.CanReceive
            end
        end
    end
    if _overIdList ~= nil then
        for i = 1, #_overIdList do
            local _receivedId = _overIdList[i]
            if self.MarryTaskStatesDict:ContainsKey(_receivedId) then
                -- Received status
                self.MarryTaskStatesDict[_receivedId] = RewardState.Received
            end
        end
    end

    local _showRedPoint = false
    self.MarryTaskStatesDict:ForeachCanBreak(
        function(_key, _states)
            -- Available
            if _states == RewardState.CanReceive then
                _showRedPoint = true
                return true
            end
        end
    )
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MARRY_TASK_REFRESH, _showRedPoint)
    local _isShowingRedPoint = GameCenter.MainFunctionSystem:GetAlertFlag(FunctionStartIdCode.MarryInfo)
    local _funcInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.MarryInfo)
    if _funcInfo ~= nil then
        if _showRedPoint and not _isShowingRedPoint and _funcInfo.SelfIsVisible and _funcInfo.IsEnable then
            GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.MarryInfo, _showRedPoint)
            if not self.IsShowMarryTaskForm and GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.MarryTask) then
                GameCenter.PushFixEvent(UILuaEventDefine.UIMarryTaskForm_OPEN)
                self.IsShowMarryTaskForm = true
            end
        else
            if not _showRedPoint and _isShowingRedPoint then
                GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.MarryInfo, false)
            end
        end
    end
end

-- Is there a partner
function MarriageSystem:HasPartner()
    if self.SpouseData ~= nil then
        if self.SpouseData.Name == nil then
            return false
        end
        if self.SpouseData.Name ~= nil then
            return true
        end
    end
    return false
end

-- Have you made an appointment for a wedding
function MarriageSystem:IsApponitedWedding()
    local _isApponited = false
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    for i = 1, #self.WeddingDataList do
        local _selfName = self.WeddingDataList[i].marrayName
        local _beMarrayName = self.WeddingDataList[i].beMarrayName
        if _lp.Name ~= nil and _lp.Name == _selfName or _lp.Name == _beMarrayName then
            _isApponited = true
            break
        end
    end
    return _isApponited
end

-- Is the wedding banquet expired?
function MarriageSystem:IsApponitedExpired()
    local _hasExpired = false
    local _heartTime = GameCenter.HeartSystem.ServerTime
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    for i = 1, #self.WeddingDataList do
        local _selfName = self.WeddingDataList[i].marrayName
        -- Appointed wedding reception time
        if _lp.Name ~= nil and _lp.Name == _selfName then
            local _timeStart = self.WeddingDataList[i].timeStart * 60
            if _heartTime > _timeStart then
                _hasExpired = true
                break
            end
        end
    end
    return _hasExpired
end

function MarriageSystem:CauUnObtainMarryTitle()
    local _dict = Dictionary:New()
    -- The progress of intimacy
    if self.SpouseData ~= nil and self.Intimacy < self.SpouseData:GetIntimacy() then
        self.Intimacy = self.SpouseData:GetIntimacy()
    end
    local _showRedPoint = false
    DataConfig.DataMarryTitle:Foreach(
        function(_level, _cfg)
            -- 1 is to be displayed, 0 is not displayed
            if _cfg.IsShow == 1 then
                local _intimacyPro = self.Intimacy / _cfg.NeedValue
                -- Heart lock target unlock configuration table
                local _targetLocKCfg = nil
                local _lockLv = tonumber(_cfg.Lock)
                if DataConfig.DataMarryLock:IsContainKey(_lockLv) then
                    _targetLocKCfg = DataConfig.DataMarryLock[_lockLv]
                end
                -- Heart lock current configuration table
                local _lockPro = 0
                local _activeStage = 0
                local _activeGrade = 0
                if DataConfig.DataMarryLock:IsContainKey(self.HeartLockLv) then
                    local _activeHeartLocKCfg = DataConfig.DataMarryLock[self.HeartLockLv]
                    _activeStage = _activeHeartLocKCfg.Stage
                    _activeGrade = _activeHeartLocKCfg.Grade
                end
                if self.HeartLockLv <= 0 then
                    -- Not activated
                    _lockPro = 0
                else
                    -- The orders exceed the standard will definitely meet the standard
                    if _activeStage > _targetLocKCfg.Stage then
                        _lockPro = 1.0
                    else
                        -- More than 0, the unlocking condition has not been reached, order * 10 (10 levels per order) + level
                        local _need = _targetLocKCfg.Stage * 10 + _targetLocKCfg.Grade
                        local _cur = _activeStage * 10 + _activeGrade
                        _lockPro = _cur / _need
                    end
                end
                if _lockPro > 1.0 then
                    _lockPro = 1.0
                end
                if _intimacyPro > 1.0 then _intimacyPro = 1.0 end
                -- Current progress of title
                local _curPro = (_lockPro + _intimacyPro) / 2
                -- Prevent it from rounding
                if _curPro >= 0.99 and _curPro < 1.0 then
                    _curPro = 0.991
                end
                -- Have you obtained the current title?
                local _isGet = GameCenter.RoleTitleSystem.CurrHaveTitleList:Contains(_cfg.TitleId)
                -- Keep the two decimal places
                _curPro = tonumber(string.format("%.2f", _curPro))
                -- Maximum value can only be 100%
                if _curPro >= 1.0 and not _isGet then
                    _curPro = 1.0
                    -- Set red dots
                    _showRedPoint = true
                end
                local _titleData =
                {
                    CurPro = _curPro,
                    HasGet = _isGet,
                    Cfg = _cfg,
                }
                if not _dict:ContainsKey(_cfg.Level) then
                    _dict:Add(_cfg.Level, _titleData)
                else
                    _dict[_cfg.Level] = _titleData
                end
            end
        end
    )
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.MarryInfo, _showRedPoint)
    local _hasGetAll = false
    _dict:ForeachCanBreak(
        function(_, _titleData)
            if _titleData.HasGet then
                _hasGetAll = true
            else
                _hasGetAll = false
                return true
            end
        end
    )
    -- After getting all the results, set the red dot to false
    if _hasGetAll then
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.MarryInfo, not _hasGetAll)
    end
    return _dict
end

-- Set the red dot of the heart lock
function MarriageSystem:SetHeartLockRedPoint()
    -- Set red dots
    local _lockCfg = DataConfig.DataMarryLock:GetByIndex(1)
    if DataConfig.DataMarryLock:IsContainKey(self.HeartLockLv) then
        _lockCfg = DataConfig.DataMarryLock[self.HeartLockLv]
    end
    local _cons = {}
    local _items = Utils.SplitNumber(_lockCfg.CostItem, '_')
    local _itemCount = #_items
    for i = 1, _itemCount do
        _cons[i] = RedPointItemCondition(_items[1], 1)
    end
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.MarryHeartLock)
    GameCenter.RedPointSystem:LuaAddFuncCondition(FunctionStartIdCode.MarryHeartLock, 1, _cons)
    -- The maximum level
    if _lockCfg.NextLv == 0 then
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.MarryHeartLock, false)
    end
end

-- Set the red dots of the fairy baby
function MarriageSystem:SetChildRedPoint()
    local _showRedPoint = false
    -- 0 Activate 1 Upgrade
    local _isLvUp = 0
    self.MarryChildDataDict:ForeachCanBreak(
        function(_childId, _data)
            if _showRedPoint then
               return true
            end
            if _data.SData ~= nil then
                -- The activated fairy baby
                local _childLv = _data.SData.level
                local _upLvItems = Utils.SplitStrByTableS(_data.AttrDict[_childLv].Consume, {';','_'})
                local _itemCount = #_upLvItems
                local _attrCfg = _data.AttrDict[_childLv]
                local _isMaxLv = tonumber(_attrCfg.BlessingValue) <= 0
                if not _isMaxLv then
                    for i = 1, _itemCount do
                        local _itemId = tonumber(_upLvItems[i][1])
                        if not self.ChildActiveOrUpgradeID:Contains(_itemId) then
                            self.ChildActiveOrUpgradeID:Add(_itemId)
                        end
                        local _haveCount = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(_itemId)
                        if _haveCount >= 1 then
                            _showRedPoint = true
                            _isLvUp = 1
                            break
                        end
                    end
                end
            else
                -- Unactivated fairy baby
                local _cfgData = _data.CfgData
                local _conds = Utils.SplitNumber(_cfgData.ItemCondition, '_')
                local _haveCount = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(_conds[1])
                local _needNum = _conds[2]
                -- Comparison of whether the heart lock level meets the conditions
                local _lvCond = self.HeartLockLv >= tonumber(_cfgData.Condition)
                -- 1 or 2 and
                if tonumber(_cfgData.Activation) == 1 then
                    _showRedPoint = _lvCond or _haveCount >= _needNum
                    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.MarryChild)
                    GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.MarryChild, 1, RedPointItemCondition(_conds[1], _needNum))
                    if not self.ChildActiveOrUpgradeID:Contains(_conds[1]) then
                        self.ChildActiveOrUpgradeID:Add(_conds[1])
                    end
                else
                    _showRedPoint = _lvCond and _haveCount >= _needNum
                end
                _isLvUp = 1
            end
        end
    )
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.MarryChild, _showRedPoint)
    -- If there is a red dot, refresh the data
    if _showRedPoint then
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MARRY_CHILD_REFRESH, _isLvUp)
    end
end

-- Request to get married
function MarriageSystem:ReqGetMarried(beMarrayId, isBroadcast, notice)
    self.SpouseData.PlayerID = beMarrayId
    local _msg = ReqMsg.MSG_Marriage.ReqGetMarried:New()
    -- Types of marriage proposals
    _msg.type = tonumber(self.CurMarriageType)
    -- ID of the suitor
    _msg.beMarrayId = beMarrayId
    _msg.isNotice = isBroadcast
    _msg.notice = notice
    _msg:Send()
end

-- Display automatic appointment
function MarriageSystem:ShowAutoYuYue()
    if self.WeddingNum <= 0 then
        return
    end
    local _askText = UIUtils.CSFormat(DataConfig.DataMessageString.Get("C_MARRY_AUTO_YUYUE_ASK"), self.SpouseData.Name)
    GameCenter.MsgPromptSystem:ShowMsgBox(_askText,
        DataConfig.DataMessageString.Get("C_MSGBOX_CANCEL"),
        DataConfig.DataMessageString.Get("C_MSGBOX_OK"),
        function (code)
            -- agree
            if (code == MsgBoxResultCode.Button2) then
                local _msg = ReqMsg.MSG_Marriage.ReqSelectWedding:New()
                _msg.timeStart = 0 -- The parameter is set to 0, and the server needs to automatically book a time for the client to have the latest wedding
                _msg:Send()
            end
            GameCenter.PushFixEvent(UIEventDefine.UIMarryEngagementForm_CLOSE)
        end,
        false,
        false, 15, 4, 1, nil, nil, 0, true)
end

-- Received world blessing message
function MarriageSystem:ResMarryPosterShow(msg)
    if self.WorldZhuFuUIId == nil then
        self.WorldZhuFuUIId = GameCenter.FormStateSystem:EventIDToFormID(UILuaEventDefine.UIMarryWorldZhuFuForm_OPEN)
    end
    if GameCenter.FormStateSystem:FormIsOpen(self.WorldZhuFuUIId) then
        -- The interface has been opened and the message is cached
        if self.CacheWorldZhuFuList == nil then
            self.CacheWorldZhuFuList = List:New()
        end
        self.CacheWorldZhuFuList:Add(msg)
    else
        -- The interface is not opened, just open the interface
        GameCenter.PushFixEvent(UILuaEventDefine.UIMarryWorldZhuFuForm_OPEN, msg)
    end
end

return MarriageSystem
