------------------------------------------------
-- Author:
-- Date: 2019-07-08
-- File: WelfareSystem.lua
-- Module: WelfareSystem
-- Description: Welfare System
------------------------------------------------
local ItemData = require("Logic.Welfare.ItemData")
local L_RoleBaseAttribute = CS.Thousandto.Code.Global.RoleBaseAttribute

local WelfareSystem = {
    -- Hongmeng enlightenment
    ExpBaseFreeCount = 0, -- Get experience for free
    LingshiBaseFreeCount = 0, -- Get Silver Ingot Free Basic Number of Times
    MaxMoneyWuDaoCount = 0, -- The maximum number of times Yuanbao realizes the truth
    MaxExpWuDaoCount = 0, -- The maximum number of experience enlightenment
    CurrCount = 0, -- The number of times of enlightenment (for the prompts when experience and silver ingot success)
    FellingMsgData = nil, -- Enlightenment server data
    -- Is there no prompt this time
    ShowWuDaoAsk = true,

    -- Sign in every day
    DailyCheck = nil,
    -- Login gift package
    LoginGift = nil,
    -- Growth Fund
    GrowthFund = nil,
    -- Peak Fund
    PeakFund = nil,
    -- Level gift pack
    LevelGift = nil,
    -- Daily gift pack
    DailyGift = nil,
    -- Benefit card
    WelfareCard = nil,

    -- 0 yuan purchase data
    MsgFreeShopDic = nil,
    -- Whether to check whether the purchase of 0 yuan expires
    IsCheckFreeShop = false,
    -- 0 yuan purchase opening end time (time stamp)
    FreeShopOpenEndTime = nil,
    -- 0 yuan purchase interface close time (timestamp)
    FreeShopOutDate = nil,
    -- Total purchase days of RMB 0
    FreeShopTotalDay = 0,
    -- Have you displayed special effects
    IsShowedEffect = false,
    -- Updated announcement and reward information to be read
    IsReadAllUpdateNoticeRewardText = false,
    MsgResUpdateNoticData = nil,
    MsgResGetUpdateNoticeAwardRet = nil,

    -- Free gift pack collection time stamp
    FreeGiftGetTime = 0,
    IsCheckFreeGiftTime = false,
}

function WelfareSystem:Initialize()
    self:AddTimer()

    -- Hongmeng enlightenment
    self.ExpBaseFreeCount = tonumber(DataConfig.DataGlobal[GlobalName.Welfare_Blessing_Times].Params);
    self.LingshiBaseFreeCount = tonumber(DataConfig.DataGlobal[GlobalName.Spirit_Stones_Pray_Free].Params);

    local times = Utils.SplitNumber(DataConfig.DataGlobal[GlobalName.Pray_Time_Limit].Params, "_");
    self.MaxMoneyWuDaoCount = times[2]
    self.MaxExpWuDaoCount = times[1]

    self.ShowWuDaoAsk = true
    -- Login gift package
    self.LoginGift = require("Logic.Welfare.LoginGift")
    -- Growth Fund
    self.GrowthFund = require("Logic.Welfare.GrowthFund")
    self.GrowthFund:Initialize()
    -- Peak Fund
    self.PeakFund = require("Logic.Welfare.PeakFund")
    self.PeakFund:Initialize()
    -- Sign in every day
    self.DailyCheck = require("Logic.Welfare.DailyCheck")
    self.DailyCheck:Initialize()
    -- Level gift pack
    self.LevelGift = require("Logic.Welfare.LevelGift")
    self.LevelGift:Initialize()
    -- Daily gift pack
    self.DailyGift = require("Logic.Welfare.DailyGift")
    self.DailyGift:Initialize()
    -- Benefit card
    self.WelfareCard = require("Logic.Welfare.WelfareCard")
    self.WelfareCard:Initialize()

    self.MsgFreeShopDic = {}
	GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_PLAYER_BASE_ATTR_CHANGED,self.OnBaseProChanged, self)
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_FIRSTENTERMAP, self.OnFirstEnterMap, self)
    GameCenter.RegFixEventHandle(LogicLuaEventDefine.EID_EVENT_OPENSERVERTIME_REFRESH, self.OpenSeverDayRefresh, self);
    self.FreeShopTotalDay = tonumber(DataConfig.DataGlobal[GlobalName.Free_Shop_End_Time].Params);
    self.FreeShopOpenEndTime = nil;
    self.IsReadAllUpdateNoticeRewardText = false;
    self.MsgResUpdateNoticData = nil;
    -- {
    --     text = "6666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666",
    --     isGet = false,
    --     items = {
    --         {itemID = 1, num = 10000000, bind = false},
    --         {itemID = 2, num = 1000000, bind = false},
    --         {itemID = 12, num = 100000, bind = true},
    --     }
    -- };
    self.MsgResGetUpdateNoticeAwardRet = nil;
end

-- The first time I entered the game scene
function WelfareSystem:OnFirstEnterMap()
    self:ReqWelfareData(WelfareType.LoginGift)
    self.GrowthFund:CheckShowRedPoint();
    self.PeakFund:CheckShowRedPoint();
    self.WelfareCard:CheckWelfareCardRed();
end

-- Refresh the server opening time
function WelfareSystem:OpenSeverDayRefresh()
    -- Buy 0 yuan
    local _openDay = Time.GetOpenSeverDay();
    -- Total seconds from 0 o'clock today to now
    local _curTime = math.floor(Time.ServerTime())
    local _t = Time.GetNowTable();
    local _toCurDayZeroHourSecs = _t.hour * 3600 + _t.min * 60 + _t.sec
    self.FreeShopOutDate = Time.ServerTime() - _toCurDayZeroHourSecs + (self.FreeShopTotalDay - _openDay + 1) * 86400;
    if _curTime >= self.FreeShopOutDate then
        self:RefreshFreeShopState()
    else
        if not self.IsShowedEffect then
            GameCenter.MainFunctionSystem:SetFunctionEffect(FunctionStartIdCode.FreeShop, true)
            self.IsShowedEffect = true;
        end
        self.IsCheckFreeShop = true;
    end
end

function WelfareSystem:OnBaseProChanged(prop, sender)
	if prop.CurrentChangeBasePropType == L_RoleBaseAttribute.Level or prop.CurrentChangeBasePropType == L_RoleBaseAttribute.VipLevel then
		self.LevelGift:UpdateGiftData()
    end
end

function WelfareSystem:UnInitialize()
    -- Login gift package
    if self.LoginGift then
        self.LoginGift:UnInitialize()
        self.LoginGift = nil
        Utils.RemoveRequiredByName("Logic.Welfare.LoginGift")
    end
    -- Sign in every day
    if self.DailyCheck then
        self.DailyCheck:UnInitialize()
        self.DailyCheck = nil
        Utils.RemoveRequiredByName("Logic.Welfare.DailyCheck")
    end
    -- Growth Fund
    if self.GrowthFund then
        self.GrowthFund:UnInitialize()
        self.GrowthFund = nil
        Utils.RemoveRequiredByName("Logic.Welfare.GrowthFund")
    end
     -- Peak Fund
     if self.PeakFund then
        self.PeakFund:UnInitialize()
        self.PeakFund = nil
        Utils.RemoveRequiredByName("Logic.Welfare.PeakFund")
    end
    -- Level gift pack
    if self.LevelGift then
        self.LevelGift:UnInitialize()
        self.LevelGift = nil
        Utils.RemoveRequiredByName("Logic.Welfare.LevelGift")
    end
    -- Daily gift pack
    if self.DailyGift then
        self.DailyGift:UnInitialize()
        self.DailyGift = nil
        Utils.RemoveRequiredByName("Logic.Welfare.DailyGift")
    end
    -- Benefit card
    if self.WelfareCard then
        self.WelfareCard:UnInitialize()
        self.WelfareCard = nil
        Utils.RemoveRequiredByName("Logic.Welfare.WelfareCard")
    end

    self.IsCheckFreeShop = false;
    self.IsShowedEffect = false;
	GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_PLAYER_BASE_ATTR_CHANGED,self.OnBaseProChanged, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_FIRSTENTERMAP, self.OnFirstEnterMap, self)
    GameCenter.UnRegFixEventHandle(LogicLuaEventDefine.EID_EVENT_OPENSERVERTIME_REFRESH, self.OpenSeverDayRefresh, self);
end

-- Request for welfare data
function WelfareSystem:ReqWelfareData(welfareType)
    local _req = ReqMsg.MSG_Welfare.ReqWelfareData:New()
    _req.typ = welfareType
    _req:Send()
end

-- The benefits function is universal to obtain prop prompt panel messages
function WelfareSystem:ResWelfareReward(msg)
    local _itemDataList = List:New()
    for i = 1, #msg.items do
        local _item = ItemData:New()
        _item.Id = msg.items[i].itemID
        _item.Num = msg.items[i].num
        _item.IsBind = msg.items[i].bind
        _itemDataList:Add(_item)
    end
    GameCenter.PushFixEvent(UIEventDefine.UIWelfareGetItemForm_OPEN, _itemDataList)
end

-- Every day, the client actively requests welfare-related data
function WelfareSystem:AddTimer()
    GameCenter.TimerEventSystem:AddTimeStampDayEvent(1, 1, true, nil, function(id, remainTime, param)
        for i = 1, WelfareType.TypeEnd - 1 do
            self:ReqWelfareData(i)
        end
    end)
end

-- =============== Hongmeng enlightenment==============--
-- Request for experience
function WelfareSystem:ReqFeelingExp(typ, count)
    local _req = ReqMsg.MSG_Welfare.ReqFeelingExp:New()
    _req.times = count
    _req.typ = typ
    self.CurrCount = count
    _req:Send()
end

-- Return to experience information
function WelfareSystem:ResFeelingExpData(msg)
    self.FellingMsgData = msg;
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_WELFARE_WUDAO_REFRESH, self.CurrCount)
    self.CurrCount = 0
    self:RefrshWoDaoRedPoint();
end

-- Refresh the little red dots of enlightenment
function WelfareSystem:RefrshWoDaoRedPoint()
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.WelfareWuDao, self:IsHaveRedPointByExp() or self:IsHaveRedPointByLingshi());
end

-- Get experience whether there are red dots
function WelfareSystem:IsHaveRedPointByExp()
    -- Is there a free number of times
    local _isShowRedPoint = self:GetRemainFreeExpCount() > 0;
    -- If there are still experiences left
    -- if not _isShowRedPoint and self:GetRemainExpCount() > 0 then
    -- --What is the next time you get experience
    --     local _useTimes = self.FellingMsgData and self.FellingMsgData.useTimes or 0;
    --     local _index = _useTimes >= self.ExpBaseFreeCount and (self.ExpBaseFreeCount - self.ExpBaseFreeCount + 1) or 1;
    -- --Is the currency required to obtain experience the next time
    --     local _data = DataConfig.DataPrayCost[_index].PrayExpCost;
    --     local _money = Utils.SplitNumber(_data,"_");
    --     _isShowRedPoint = GameCenter.ItemContianerSystem:GetEconomyWithType(_money[2]) >= _money[1]
    -- end
    return _isShowRedPoint;
end

-- Get silver ingots with red dots
function WelfareSystem:IsHaveRedPointByLingshi()
    -- Is there a free number of times
    local _isShowRedPoint = self:GetRemainFreeLingshiCount() > 0;
    -- If there are still silver ingots left
    -- if not _isShowRedPoint and self:GetRemainLingshiCount() > 0 then
    -- --What is the next time you get silver ingots
    --     local _useTimes = self.FellingMsgData and self.FellingMsgData.useMTimes or 0;
    --     local _index = _useTimes >= self.LingshiBaseFreeCount and (_useTimes - self.LingshiBaseFreeCount + 1) or 1;
    -- --Is the currency required to obtain silver ingots the next time
    --     local _data = DataConfig.DataPrayCost[_index].PrayMoneyCost;
    --     local _money = Utils.SplitNumber(_data,"_");
    --     _isShowRedPoint = GameCenter.ItemContianerSystem:GetEconomyWithType(_money[2]) >= _money[1]
    -- end
    return _isShowRedPoint;
end

-- Get experience consumption, number of purchases, current purchase id
function WelfareSystem:GetExpCost(times)
    local _remainFreeCount = self:GetRemainFreeExpCount();
    if _remainFreeCount - times >= 0 then
        return 0, times;
    else
        local _costTimes = times - _remainFreeCount;
        local _useTimes = self.FellingMsgData and self.FellingMsgData.useTimes or 0;
        local _maxIndexByVIPExp = (GameCenter.VipSystem:GetCurVipPowerParam(25) or 0)
        if _useTimes >= self.MaxExpWuDaoCount + _maxIndexByVIPExp then
            return 0, _remainFreeCount;
        else
            local _startIndex = _useTimes + 1;
            local _endIndex = _startIndex - 1 + _costTimes;
            -- _endIndex = _endIndex > self.MaxExpWuDaoCount and self.MaxExpWuDaoCount or _endIndex;

            local _totalCost = 0;
            local _id = 0;
            local _maxIndexByPrayCost = DataConfig.DataPrayCost.Count

            for i = _startIndex, _endIndex do
                if i <= self.MaxExpWuDaoCount then
                    local _data = DataConfig.DataPrayCost[i].PrayExpCost;
                    local _money = Utils.SplitNumber(_data, "_");
                    _totalCost = _totalCost + _money[1];
                    _id = tonumber(_money[2]);
                elseif i <= self.MaxExpWuDaoCount + _maxIndexByVIPExp then
                    local _money = self:GetVIPExpList()[i - self.MaxExpWuDaoCount];
                    _totalCost = _totalCost + _money;
                    _id = 1
                end
            end
            return _totalCost, (_remainFreeCount + _endIndex - _startIndex + 1), _id;
        end
    end
end

-- Get Silver Ingot consumption, the number of purchases this time, the id that can be purchased currently
function WelfareSystem:GetLingshiCost(times)
    local _remainFreeCount = self:GetRemainFreeLingshiCount();
    if _remainFreeCount - times >= 0 then
        return 0, times;
    else
        local _costTimes = times - _remainFreeCount;
        local _useTimes = self.FellingMsgData and self.FellingMsgData.useMTimes or 0;
        local _maxIndexByVIPLingshi = (GameCenter.VipSystem:GetCurVipPowerParam(24) or 0)
        if _useTimes >= self.MaxMoneyWuDaoCount + _maxIndexByVIPLingshi then
            return 0, _remainFreeCount;
        else
            local _startIndex = _useTimes + 1;
            local _endIndex = _startIndex - 1 + _costTimes;
            -- _endIndex = _endIndex > self.MaxMoneyWuDaoCount and self.MaxMoneyWuDaoCount or _endIndex;

            local _totalCost = 0;
            local _id = 0;
            local _maxIndexByPrayCost = DataConfig.DataPrayCost.Count

            for i = _startIndex, _endIndex do
                if i <= self.MaxExpWuDaoCount then
                    local _data = DataConfig.DataPrayCost[i].PrayMoneyCost;
                    local _moneyArr = Utils.SplitNumber(_data, "_");
                    _totalCost = _totalCost + _moneyArr[1];
                    _id = tonumber(_moneyArr[2]);
                elseif i <= self.MaxExpWuDaoCount + _maxIndexByVIPLingshi then
                    local _money = self:GetVIPLingshiList()[i - self.MaxExpWuDaoCount];
                    _totalCost = _totalCost + _money;
                    _id = 1
                end
            end
            return _totalCost, (_remainFreeCount + _endIndex - _startIndex + 1), _id;
        end
    end
end

function WelfareSystem:GetVIPExpList()
    if not self.VIPExpList then
        local vipPowerCfg = DataConfig.DataVipPower[25]
        self.VIPExpList = Utils.SplitNumber(vipPowerCfg.VipPowerPrice, '_')
    end
    return self.VIPExpList
end

function WelfareSystem:GetVIPLingshiList()
    if not self.VIPLingshiList then
        local vipPowerCfg = DataConfig.DataVipPower[24]
        self.VIPLingshiList = Utils.SplitNumber(vipPowerCfg.VipPowerPrice, '_')
    end
    return self.VIPLingshiList
end

-- Total number of experiences obtained
function WelfareSystem:GetExpTotalCount()
    local _vipFreeCount = (GameCenter.VipSystem:GetCurVipPowerParam(10) or 0);
    local _vipCostCount = (GameCenter.VipSystem:GetCurVipPowerParam(25) or 0);
    return self.ExpBaseFreeCount + self.MaxExpWuDaoCount + _vipFreeCount + _vipCostCount
end

-- Total number of silver ingots obtained
function WelfareSystem:GetLingshiTotalCount()
    local _vipFreeCount = (GameCenter.VipSystem:GetCurVipPowerParam(10) or 0);
    local _vipCostCount = (GameCenter.VipSystem:GetCurVipPowerParam(24) or 0);
    return self.LingshiBaseFreeCount + self.MaxMoneyWuDaoCount + _vipFreeCount + _vipCostCount
end

-- Get the remaining experience
function WelfareSystem:GetRemainExpCount()
    return self:GetExpTotalCount() - (self.FellingMsgData and self.FellingMsgData.useTimes or 0) - (self.FellingMsgData and self.FellingMsgData.freeExpTimes or 0)
end

-- Get the remaining silver ingots
function WelfareSystem:GetRemainLingshiCount()
    return self:GetLingshiTotalCount() - (self.FellingMsgData and self.FellingMsgData.useMTimes or 0) - (self.FellingMsgData and self.FellingMsgData.freeCoinTimes or 0)
end

-- Get the remaining free experience
function WelfareSystem:GetRemainFreeExpCount()
    local _count = self.ExpBaseFreeCount + (GameCenter.VipSystem:GetCurVipPowerParam(10) or 0) - (self.FellingMsgData and self.FellingMsgData.freeExpTimes or 0);
    return _count > 0 and _count or 0;
end

-- Get the remaining free silver ingots
function WelfareSystem:GetRemainFreeLingshiCount()
    local _count = self.LingshiBaseFreeCount + (GameCenter.VipSystem:GetCurVipPowerParam(10) or 0) - (self.FellingMsgData and self.FellingMsgData.freeCoinTimes or 0);
    return _count > 0 and _count or 0;
end
-- ================================--

-- ============================--
-- Request for redemption of gift packs
function WelfareSystem:ReqExchangeGift(cdKey)
    local _req = ReqMsg.MSG_Welfare.ReqExchangeGift:New()
    _req.id = cdKey
    _req:Send()
end

-- Return to redemption package
function WelfareSystem:ResExchangeGift(msg)
    -- Success and failure reason code
    -- 0 Success
    -- 1 card number does not exist
    -- No. 2 has been used
    -- 3 card number expires
    -- No. 4 cannot be used across servers
    -- 5 card numbers cannot be used across regions
    -- 6 This type of card number has been used
    -- 7. This universal card has been used
    -- 8 Failed to use
    if msg.errorNo == 0 then
        Utils.ShowPromptByEnum("ExchangeSuccedTips")
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_WELFARE_EXCHANGEGIFT_SUCCESS)
    elseif msg.errorNo == 1 then
        Utils.ShowPromptByEnum("C_ACTIVECODE_ERRORCODE")
    elseif msg.errorNo == 2 then
        Utils.ShowPromptByEnum("C_ACTIVECODE_USED")
    elseif msg.errorNo == 3 then
        Utils.ShowPromptByEnum("C_ACTIVECODE_TIMEOUT")
    elseif msg.errorNo == 4 then
        Utils.ShowPromptByEnum("C_ACTIVECODE_SERVER")
    elseif msg.errorNo == 5 then
        Utils.ShowPromptByEnum("C_ACTIVECODE_AREA")
    elseif msg.errorNo == 6 then
        Utils.ShowPromptByEnum("C_ACTIVECODE_ERRORTYPE")
    elseif msg.errorNo == 7 then
        Utils.ShowPromptByEnum("C_ACTIVECODE_SELFUSED")
    elseif msg.errorNo == 8 then
        Utils.ShowPromptByEnum("C_ACTIVECODE_FAILED")
    end
end

-- ================================--

-- ==============================--
-- Refresh the 0 yuan purchase opening status
function WelfareSystem:OpenSeverDayRefresh()
    -- Buy 0 yuan
    local _openDay = Time.GetOpenSeverDay();
    if _openDay <= self.FreeShopTotalDay and not self.IsShowedEffect then
        GameCenter.MainFunctionSystem:SetFunctionEffect(FunctionStartIdCode.FreeShop, true)
        self.IsShowedEffect = true;
    end
    local _curTime = math.floor(Time.ServerTime())
    local _t = Time.GetNowTable();
    -- Total seconds from 0 o'clock today to now
    local _toCurDayZeroHourSecs = _t.hour * 3600 + _t.min * 60 + _t.sec
    -- Configuration open deadline
    self.FreeShopOpenEndTime = _curTime - _toCurDayZeroHourSecs + (self.FreeShopTotalDay - _openDay + 1) * 86400;
    self:SetOutDateTime();
end

-- Set expiration time
function WelfareSystem:SetOutDateTime()
    self.FreeShopOutDate = self.FreeShopOpenEndTime;
    if self.FreeShopOpenEndTime and self.MsgFreeShopDic then
        for k, v in pairs(self.MsgFreeShopDic) do
            local _cfg = DataConfig.DataFreeShop[v.id];
            local _t = os.date("*t", math.floor(v.buyTime / 1000) + Time.GetZoneOffset())
            -- The number of seconds passed by that day
            local _toCurDayZeroHourSecs = _t.hour * 3600 + _t.min * 60 + _t.sec
            v.OutDate = math.floor(v.buyTime / 1000) - _toCurDayZeroHourSecs + (_cfg.Time + 1) * 86400
            self.FreeShopOutDate = self.FreeShopOutDate > v.OutDate and self.FreeShopOutDate or v.OutDate;
        end
        if self.FreeShopOutDate > Time.ServerTime() then
            self.IsCheckFreeShop = true;
        end
    end
    self:RefreshFreeShopState()
end

-- Refresh the 0 yuan purchase opening status
function WelfareSystem:RefreshFreeShopState()
    local _isVisible = self.FreeShopOutDate and (self.FreeShopOutDate > Time.ServerTime()) or false;
    -- Entrance
    GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.FreeShop):SetIsVisible(_isVisible)
    -- If it has expired and no items are purchased, close the interface
    if not _isVisible and Utils.GetTableLens(self.MsgFreeShopDic) <= 0 then
        GameCenter.PushFixEvent(UILuaEventDefine.UIFreeGiftForm_CLOSE)
    end
end

-- Refresh 0 yuan to buy small red dots
function WelfareSystem:RefrshFreeShopRedDot()
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.FreeShop, self:IsRedDotByFreeShop());
end

-- Get 0 yuan to buy it and do you have any small red dots
function WelfareSystem:IsRedDotByFreeShop()
    if Utils.GetTableLens(self.MsgFreeShopDic) > 0 then
        for k, v in pairs(self.MsgFreeShopDic) do
            if not v.isGet then
                return true;
            end
        end
    end
    return false;
end

-- Request a purchase
function WelfareSystem:ReqBuyGoodsAtFreeShop(id)
    local _req = ReqMsg.MSG_Shop.ReqFreeShop:New()
    _req.id = id
    _req.type = 1
    _req:Send()
end

-- Request to collect
function WelfareSystem:ReqGetRewardAtFreeShop(id)
    local _req = ReqMsg.MSG_Shop.ReqFreeShop:New()
    _req.id = id
    _req.type = 2
    _req:Send()
end

-- message FreeShopData
-- required int32 id = 1; // Product ID
-- required bool isGet = 2; //It is to collect
-- required int64 buyTime = 3; //Purchase time

-- required FreeShopData buyData = 1;//
-- required int32 type = 2; //1 means purchase, 2 means receiving the prize
-- Buy or collect back
function WelfareSystem:SyncFreeShopResult(msg)
    if msg.type == 1 then
        Utils.ShowPromptByEnum("C_BUY_SUCC")
    elseif msg.type == 2 then
        Utils.ShowPromptByEnum("C_LINGQU_SUCC")
    end
    if not msg.buyData then
        return;
    end
    self.MsgFreeShopDic[msg.buyData.id] = msg.buyData;
    self:SetOutDateTime();
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FREESHOP_REFRESH);
    self:RefrshFreeShopRedDot()
end

-- repeated FreeShopData zeroBuyList = 1;
-- Initialized zero-yuan purchase online
function WelfareSystem:SyncOnlineInitFreeShop(msg)
    self.MsgFreeShopDic = {};
    local _openDay = Time.GetOpenSeverDay();
    local _zeroBuyList = msg.zeroBuyList;
    if _zeroBuyList then
        for i = 1, #_zeroBuyList do
            self.MsgFreeShopDic[_zeroBuyList[i].id] = _zeroBuyList[i];
        end
    end
    self:SetOutDateTime();
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FREESHOP_REFRESH);
    self:RefrshFreeShopRedDot()
end

function WelfareSystem:Update()
    if self.IsCheckFreeShop then
        if Time.ServerTime() >= self.FreeShopOpenEndTime then
            self:RefreshFreeShopState();
            self.IsCheckFreeShop = false;
        end
    end

    if self.IsCheckFreeGiftTime then
        if Time.ServerTime() >= self.FreeGiftGetTime then
            self:RefreshFreeGiftState()
            self.IsCheckFreeGiftTime = false
        end
    end
end

-- ================================--

-- =================[Update announcement and award recognition interface]================--
-- Request for a prize
function WelfareSystem:ReqGetUpdateNoticeAward(msg)
    local _req = ReqMsg.MSG_Welfare.ReqGetUpdateNoticeAward:New();
    _req:Send();
end
-- Update announcement data
function WelfareSystem:ResUpdateNoticData(msg)
    GameCenter.WelfareSystem.IsReadAllUpdateNoticeRewardText = false;
    self.MsgResUpdateNoticData = msg;
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.UpdateNoticReward, not msg.isGet);
    local _funcInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.UpdateNoticReward);
    _funcInfo:SetIsVisible(true);
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_UPDATENOTICREWARD);
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_WELFARE_REFRESH_BASE_PANEL, WelfareType.UpdateNoticReward)
end
-- Result of award
function WelfareSystem:ResGetUpdateNoticeAwardRet(msg)
    self.MsgResGetUpdateNoticeAwardRet = msg;
    if msg.retCode == 1 then
        self.MsgResUpdateNoticData.isGet = true;
        Utils.ShowPromptByEnum("C_LINGQU_SUCC")
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.UpdateNoticReward, false);
    else
        Utils.ShowPromptByEnum("C_LINGQU_FAILED")
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_UPDATENOTICREWARD);
end
-- ================================--

-- Free welfare gift package
function WelfareSystem:ResWelfareFreeGiftInfo(msg)
    -- Receive the time stamp
    local _gCfg = DataConfig.DataGlobal[GlobalName.recharge_total_function_time_limit]
    self.FreeGiftGetTime = msg.getTime // 1000 + (tonumber(_gCfg.Params) * 60)
    self:RefreshFreeGiftState()
end

function WelfareSystem:RefreshFreeGiftState()
    local _serverTime = Time.ServerTime()
    if _serverTime >= self.FreeGiftGetTime then
        self.IsCheckFreeGiftTime = false
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.ChaoZhi, true)
    else
        self.IsCheckFreeGiftTime = true
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.ChaoZhi, false)
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_WEFREEGIFT)
end

return WelfareSystem
