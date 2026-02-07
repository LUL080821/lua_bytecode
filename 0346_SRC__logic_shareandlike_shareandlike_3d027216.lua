------------------------------------------------
-- Author: 
-- Date: 2020-10-12
-- File: ShareAndLike.lua
-- Module: ShareAndLike
-- Description: Share Like, Rating
------------------------------------------------

local ShareAndLike = {
    IsRegHandle = false,
    isShare = false,
    isLike = false,
    MsgInfo = nil,
    openShare = false,
    openDayShare = false,
    openLike = false,
    openShopEvaluate = false,
    -- 0 = No comments
    shopEvaluate = 0, 
    -- Number of days for players to log in
    LoginDays = 0,
    UIList = {},
    PingLunEventDic = Dictionary:New()
}

function ShareAndLike:Initialize()
    self.MsgInfo = nil; --{like=0, share=0, evaluate=0};
    self.openLike = false
    self.penShare = false
    self.IsShowingUIMain = true;
    self.nextTime = 0;
    self.CSUIFormManager = nil;
    self:InitPLEventDic()
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_FUNCTION_UPDATE, self.OnFuncUpdated, self)
    -- Player level changes
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_PLAYER_LEVEL_CHANGED, self.ChangeLV, self)
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_TASKFINISH, self.OnTaskFinish, self)
    -- Have you ever popped up a rating
    if PlayerPrefs.HasKey("IsPopupEvaluate") then
        return;
    end
    self:RegHandle()
    table.insert(self.UIList, DataConfig.DataUIConfig["UINpcTalkForm"].Id);
    table.insert(self.UIList, DataConfig.DataUIConfig["UIModelViewForm"].Id);
    table.insert(self.UIList, DataConfig.DataUIConfig["UINewFunctionForm"].Id);
end

function ShareAndLike:RegHandle()
    if self.IsRegHandle then
        return
    end
    -- The first time entering the scene
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_FIRSTENTERMAP, self.OnFirstEnterMap, self)
    -- VIP level changes
    GameCenter.RegFixEventHandle(LogicLuaEventDefine.EID_EVENT_VIP_LEVELCHANGE, self.ShowPopupScore, self)
    -- Player level changes
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_PLAYER_LEVEL_CHANGED, self.ShowPopupScore, self)
    -- Login days message
    GameCenter.RegFixEventHandle(LogicLuaEventDefine.EID_EVENT_WELFARE_LOGINGIFT_REFRESH, self.ShowPopupScore, self)
    -- Changes in the number of days of service
    GameCenter.RegFixEventHandle(LogicLuaEventDefine.EID_EVENT_OPENSERVERTIME_REFRESH, self.ShowPopupScore, self)
    -- Hide the main interface
    GameCenter.RegFixEventHandle(LogicLuaEventDefine.EID_EVENT_ON_MAINUIHIDE_ANIM, self.OnHideUIMainForm, self)
    -- Show main interface
    GameCenter.RegFixEventHandle(LogicLuaEventDefine.EID_EVENT_ON_MAINUISHOW_ANIM, self.OnShowUIMainForm, self)
    -- Player status changes
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_LOCALPLAYER_STATECHANGE, self.ShowPopupScore, self)
    self.IsRegHandle = true;
end

function ShareAndLike:UnRegHandle()
    if not self.IsRegHandle then
        return
    end
    -- The first time entering the scene
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_FIRSTENTERMAP, self.OnFirstEnterMap, self)
    -- VIP level changes
    GameCenter.UnRegFixEventHandle(LogicLuaEventDefine.EID_EVENT_VIP_LEVELCHANGE, self.ShowPopupScore, self)
    -- Player level changes
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_PLAYER_LEVEL_CHANGED, self.ShowPopupScore, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_PLAYER_LEVEL_CHANGED, self.ChangeLV, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_TASKFINISH, self.OnTaskFinish, self)
    -- Login days message
    GameCenter.UnRegFixEventHandle(LogicLuaEventDefine.EID_EVENT_WELFARE_LOGINGIFT_REFRESH, self.ShowPopupScore, self)
    -- Changes in the number of days of service
    GameCenter.UnRegFixEventHandle(LogicLuaEventDefine.EID_EVENT_OPENSERVERTIME_REFRESH, self.ShowPopupScore, self)
    -- Hide the main interface
    GameCenter.UnRegFixEventHandle(LogicLuaEventDefine.EID_EVENT_ON_MAINUIHIDE_ANIM, self.OnHideUIMainForm, self)
    -- Show main interface
    GameCenter.UnRegFixEventHandle(LogicLuaEventDefine.EID_EVENT_ON_MAINUISHOW_ANIM, self.OnShowUIMainForm, self)
    -- Player status changes
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_LOCALPLAYER_STATECHANGE, self.ShowPopupScore, self)
    self.IsRegHandle = false;
end

function ShareAndLike:UnInitialize()
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_FUNCTION_UPDATE, self.OnFuncUpdated, self)
    self:UnRegHandle()
end

function ShareAndLike:SetLoginDays(loginDays)
    self.LoginDays = loginDays;
end

function ShareAndLike:OnFirstEnterMap()
    self.TimelinePlayer = CS.Thousandto.Core.Asset.TimelinePlayer;
    self.nextTime = Time.ServerTime() + 30;
end

function ShareAndLike:OnHideUIMainForm()
    self.IsShowingUIMain = false;
    self:HidePopupScore()
end

function ShareAndLike:OnShowUIMainForm()
    self.IsShowingUIMain = true;
    self:ShowPopupScore()
end

function ShareAndLike:OnFuncUpdated(functioninfo, sender)
    if FunctionStartIdCode.ThaiShareGroup == functioninfo.ID or 
    FunctionStartIdCode.ThaiLike == functioninfo.ID or
    FunctionStartIdCode.ThaiShare == functioninfo.ID or 
    FunctionStartIdCode.DayShare == functioninfo.ID then
        self:SetState()
	end
end

-- Set function status
function ShareAndLike:SetState()
    if not self.MsgInfo then
        return;
    end
    local funcInfo1 = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.ThaiShareGroup)
    local funcInfo2 = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.ThaiLike)
    local funcInfo3 = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.ThaiShare)
    local funcInfo4 = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.DayShare)
    if funcInfo1 ~= nil then
        if funcInfo1.IsEnable then
            GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.ThaiShareGroup, 
             (funcInfo2 ~= nil and funcInfo2.IsEnable and self.openLike and self.MsgInfo.like ~= 2) or 
            (funcInfo3 ~= nil and funcInfo3.IsEnable and self.openShare and self.MsgInfo.share ~= 2) or 
            (funcInfo4 ~= nil and funcInfo4.IsEnable and self.openDayShare and self.MsgInfo.everyDayShare ~= 2))
        else
            GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.ThaiShareGroup, false)
        end
    end
    
    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.ThaiLike, funcInfo2 ~= nil and funcInfo2.IsEnable and self.openLike and self.MsgInfo.like ~= 2)
    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.ThaiShare, funcInfo3 ~= nil and funcInfo3.IsEnable and self.openShare and self.MsgInfo.share ~= 2)
    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.DayShare, funcInfo4 ~= nil and funcInfo4.IsEnable and self.openDayShare and self.MsgInfo.everyDayShare ~= 2)
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.ThaiLike, self.openLike and self.MsgInfo.like == 1);
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.ThaiShare, self.openShare and self.MsgInfo.share == 1);
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.DayShare, self.openDayShare and self.MsgInfo.everyDayShare == 1);
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.ThaiShareGroup, self.openLike and self.MsgInfo.like == 1 or self.openShare and self.MsgInfo.share == 1
    or self.openDayShare and self.MsgInfo.everyDayShare == 1);
end

-- Request an action
-- required int32 type = 1;//1 like, 2 share 3 reviews 4 daily share 5, store reviews
-- required int32 actType = 2;//Operation type 1 Complete operation 2 receive rewards
function ShareAndLike:ReqEvaluate(typeid, value)
    local _req = ReqMsg.MSG_PlatformEvaluate.ReqEvaluate:New();
    _req.type = typeid;
    _req.actType = value;
    _req:Send();
end

-- Return result
-- optional int32 like = 1;//1 Liked (successful), 2 received
-- optional int32 share = 2;//1 shared (successful), 2 received
-- optional int32 evaluate = 3;//1 evaluated (successful)
function ShareAndLike:ResEvaluateResult(msg)
    self.MsgInfo = msg;
    self:SetState()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SHAREANDLIKEREFRESH)
    -- self:CheckPopupScore()
end

-- Send evaluation information online
-- optional int32 like = 1;//0 Not liked, 1 already liked, 2 already received
-- optional int32 share = 2;//0 not shared, 1 has been shared, 2 has been collected
-- optional int32 evaluate = 3;//0 Not evaluated, 1 has been evaluated
-- optional bool openLike = 4;//Is the background open like?
-- optional bool openShare = 5;//Is the background sharing enabled?
function ShareAndLike:ResEvaluateInfo(msg)
    self.MsgInfo = msg;
    self.openLike = msg.openLike;
    self.openShare = msg.openShare;
    self.openDayShare = msg.openEveryDayShare;
    self.openShopEvaluate = msg.openShopEvaluate
    self.shopEvaluate = msg.shopEvaluate
    self:SetState()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SHAREANDLIKEREFRESH)
    -- self:CheckPopupScore()
end

-- Check pop-up ratings
function ShareAndLike:Update(dt)
    if self.IsShowPopupScore then
        if Time.ServerTime() > self.nextTime then
            self:CheckPopupScore()
            self.IsShowPopupScore = false;
        end
    end
end

function ShareAndLike:ShowPopupScore(obj , sender)
    if not self.IsShowPopupScore then
        self.IsShowPopupScore = true;
    end
    if self.nextTime - Time.ServerTime() < 5 then
        self.nextTime = Time.ServerTime() + 5;
    end
end

function ShareAndLike:ChangeLV(obj , sender)
    if self.MsgInfo == nil then
        return
    end
    if self.openShopEvaluate == false or self.MsgInfo.shopEvaluate >= 1 then
        return
    end
    local _curLevel = tonumber(obj)
    for i = 1, #self.PingLunEventDic[2] do
        if _curLevel == tonumber(self.PingLunEventDic[2][i]) then
            GameCenter.PushFixEvent(UILuaEventDefine.UIPingLunGameForm_OPEN)
            return
        end
    end
end

function ShareAndLike:OnTaskFinish(obj , sender)
    if self.openShopEvaluate == false or self.MsgInfo.shopEvaluate >= 1 then
        return
    end
    if obj ~= nil then
        local modelId = tonumber(obj)
        for i = 1, #self.PingLunEventDic[1] do
            if modelId == tonumber(self.PingLunEventDic[1][i]) then
                GameCenter.PushFixEvent(UILuaEventDefine.UIPingLunGameForm_OPEN)
                return
            end
        end
	end
end

function ShareAndLike:HidePopupScore()
    self.IsShowPopupScore = false;
end

-- Check if the score pops up
function ShareAndLike:CheckPopupScore()
    if not self.MsgInfo then
        return
    end

	local _info = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.ThaiScore)
    if not _info.IsVisible then
        return
	end

    -- Have you ever popped up a rating
    if PlayerPrefs.HasKey("IsPopupEvaluate") then
        self:UnRegHandle()
        return;
    end

    if GameCenter.GameSceneSystem:GetActivedMapID() ~= 102599 then
        return;
    end

    if GameCenter.BlockingUpPromptSystem:IsRunning() then
        return
    end

    -- If the main interface is not displayed
    if not self.IsShowingUIMain then
        return
    end


    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer();
    if not _lp then
        return
    end

    for i=1, #self.UIList do
        if GameCenter.FormStateSystem:FormIsOpen(self.UIList[i]) then
            return
        end
    end

    if self.TimelinePlayer.CurTimelineInfo then
        return
    end

    -- If you are not wasting or meditating
    if not (_lp:IsXState(CS.Thousandto.Core.Asset.EntityStateID.Idle) or _lp:IsXState(CS.Thousandto.Core.Asset.EntityStateID.SitDown)) then
        return
    end
    local _vipLevel = _lp.VipLevel;
    local _level = _lp.Level;
    local _openSeverDay = Time.GetOpenSeverDay();
    local _loadDays = self.LoginDays;
    local _func = function(k, v)
    -- _curPopupCount & 2^(k-1) ~= 2^(k-1) and
        if  (v.Vip == 0 and _vipLevel == 0 or v.Vip ~= 0 and _vipLevel >= v.Vip) and _level >= v.Level and _openSeverDay >= v.OpenDays and _loadDays >= v.LoadDays then
            -- self:ReqEvaluate(3,_curPopupCount | 2^(k-1))
            -- self.MsgInfo.evaluate = _curPopupCount | 2^(k-1)
            -- local _url = DataConfig.DataGlobal[GlobalName.Thai_EvaluateURL].Params;
            GameCenter.SDKSystem:DoRate("https://play.google.com/store/apps/details?id=jp.naver.line.android")
            PlayerPrefs.SetInt("IsPopupEvaluate", 1)
            PlayerPrefs.Save();
            self:UnRegHandle()
        end
    end
    DataConfig.DataThaiScore:Foreach(_func)
end

function ShareAndLike:GetPingLunShowRewards()
    local rewards = List:New()
    local _arr = Utils.SplitStrByTableS(DataConfig.DataGlobal[GlobalName.TW_ShopCommentRewards].Params);
    for i = 1, #_arr do
        local tab = {}
        tab.Id = _arr[i][1]
        tab.Count = _arr[i][2]
        rewards:Add(tab)
    end
    return rewards
end

function ShareAndLike:InitPLEventDic()
    if #self.PingLunEventDic ~= 0 then
        return
    end
    local _arr = Utils.SplitStrByTableS(DataConfig.DataGlobal[GlobalName.TW_ShopCommentOpen].Params);
    for i = 1, #_arr do
        if self.PingLunEventDic:ContainsKey(_arr[i][1]) then
            self.PingLunEventDic[_arr[i][1]]:Add(_arr[i][2])
        else
            local _list = List:New()
            _list:Add(_arr[i][2])
            self.PingLunEventDic:Add(_arr[i][1],_list)
        end  
    end
end

return ShareAndLike