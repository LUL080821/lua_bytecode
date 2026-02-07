------------------------------------------------
-- author:
-- Date: 2020-5-20
-- File: LoginGift.lua
-- Module: LoginGift
-- Description: Welfare Login Gift Pack
------------------------------------------------

local LoginGift = {
    -- The server sends data
    MsgData = nil,
    -- Maximum login days
    MaxDay = nil,
    -- Send a message
    ReqLoginGiftReward = nil,
    -- Received
    ReceiveDic = {},
    -- Is there a subtitle set
    IsSetLittleName = false,
}

function LoginGift:UnInitialize()
    self.MsgData = nil;
    self.ReceiveDic = {};
    self.IsSetLittleName = false;
end

-- Get the maximum number of login days
function LoginGift:GetMaxDay()
    if not self.MaxDay then
        local _maxCfg = DataConfig.DataSevendayLogin:GetByIndex(DataConfig.DataSevendayLogin.Count)
        if _maxCfg then
            self.MaxDay = _maxCfg.Day or 1;
        end
    end
    return self.MaxDay;
end

-- Refresh the login package opening status
function LoginGift:RefreshLoginGiftState()
    GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.WelfareLoginGift):SetIsVisible(not LoginGift:IsGetAll())
end

-- Have you received it
function LoginGift:IsGetAll()
    return self.MsgData and (#self.MsgData.receives >= self:GetMaxDay()) or false;
end

-- Detect red dots
function LoginGift:CheckLoginGiftRedPoint()
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.WelfareLoginGift, self:IsRedpoint())
end

-- Is there a little red dot
function LoginGift:IsRedpoint()
    return self.MsgData and self.MsgData.loginNum > #self.MsgData.receives or false;
end

-- Get the number of days currently logged in
function LoginGift:GetCurLoginDay()
    return self.MsgData and self.MsgData.loginNum or 1;
end

-- Get the reward to be received tomorrow
function LoginGift:GetNextDayAward()
    if self.MsgData then
        local _cfg = DataConfig.DataSevendayLogin[self:GetCurLoginDay() + 1];
        if _cfg then
            return _cfg.Award;
        end
    end
end

function LoginGift:RefreshLittleName()
    local _functionInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.WelfareLoginGift);
    if _functionInfo.IsEnable then
        local _nextReceiveId = nil;
        for i=1,self:GetMaxDay() do
            if not self.ReceiveDic[i] then
                _nextReceiveId = i;
                break;
            end
        end
        if _nextReceiveId then
            GameCenter.MainFunctionSystem:SetFunctionLittleName(FunctionStartIdCode.Welfare, DataConfig.DataSevendayLogin[_nextReceiveId].PanelWord);
            self.IsSetLittleName = true;
        elseif self.IsSetLittleName then
            GameCenter.MainFunctionSystem:SetFunctionLittleName(FunctionStartIdCode.Welfare, "");
            self.IsSetLittleName = false;
        end
    else
        if self.IsSetLittleName then
            GameCenter.MainFunctionSystem:SetFunctionLittleName(FunctionStartIdCode.Welfare, "");
            self.IsSetLittleName = false;
        end
    end
end

-- Request to receive a login gift package
function LoginGift:ReqLoginGiftRewardMsg(day)
    if not self.ReqLoginGiftReward then
        self.ReqLoginGiftReward = ReqMsg.MSG_Welfare.ReqLoginGiftReward:New();
    end
    self.ReqLoginGiftReward.day = day
    self.ReqLoginGiftReward:Send()
end

-- Login package data
function LoginGift:GS2U_ResLoginGiftData(msg)
    self.MsgData = msg;
    self.MsgData.loginNum = self.MsgData.loginNum or 1
    self.MsgData.receives = self.MsgData.receives or {};
    local _receives = self.MsgData.receives;
    for i=1,#_receives do
        self.ReceiveDic[_receives[i]] = true;
    end

    self:RefreshLittleName()
    self:RefreshLoginGiftState()
    self:CheckLoginGiftRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_WELFARE_LOGINGIFT_REFRESH)
end

return LoginGift