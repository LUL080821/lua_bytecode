------------------------------------------------
-- Author:
-- Date: 2021-08-31
-- File: ZeroBuySystem.lua
-- Module: ZeroBuySystem
-- Description: Zero Yuan Purchase System
------------------------------------------------
local RedPointCustomCondition = CS.Thousandto.Code.Logic.RedPointCustomCondition
local TimeUtils = CS.Thousandto.Core.Base.TimeUtils

local ZeroBuySystem = {
    BuyState = nil,
    OpenState = nil,
    CfgList = nil,
    -- Server service opening time
    ServerOpenTime = nil,
    -- Current service days
    CurOpenServerDay = 0,
}

function ZeroBuySystem:Initialize()
    self.CfgList = List:New()
    DataConfig.DataFreeNewshop:Foreach(function(k, cfg)
        self.CfgList:Add(cfg)
    end)
    self.BuyState = nil
    self.ServerOpenTime = nil

    -- Perform at 10 seconds every day
    self.TimerID = GameCenter.TimerEventSystem:AddTimeStampDayEvent(10, 86400,
    true, nil, function(id, remainTime, param)
        self:CheckOpenState(true)
    end)
end

function ZeroBuySystem:UnInitialize()
end

-- Detect the on state
function ZeroBuySystem:CheckOpenState(addBuyRP)
    if self.ServerOpenTime == nil then
        return
    end
    if self.BuyState == nil then
        self.BuyState = {}
    end
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.FreeShop2)
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.FreeShopVIP)
    self.OpenState = {}
    self.CurOpenServerDay = TimeUtils.GetDayOffsetNotZone(self.ServerOpenTime, math.floor(GameCenter.HeartSystem.ServerZoneTime)) + 1
    local _funcIsOpen = false
    local _vipIsOpen = false
    local _haveNotBuy = false
    local _vipNotBuy = false
    for i = 1, #self.CfgList do
        local _cfg = self.CfgList[i]
        local _isOpen = false
        if self.CurOpenServerDay >= _cfg.OpenTime then
            _isOpen = true
        end
        local _isClose = true
        local _buyData = self.BuyState[_cfg.Id]
        if _buyData == nil or not _buyData.IsGet then
            _isClose = false
        end
        if _isOpen and not _isClose then
            if _cfg.Id == 1 then
                _vipIsOpen = true
            end
            _funcIsOpen = true
            -- Open status
            self.OpenState[_cfg.Id] = true
            if _buyData == nil or _buyData.BuyTime <= 0 then
                _haveNotBuy = true
                if _cfg.Id == 1 then
                    _vipNotBuy = true
                end
                if addBuyRP then
                    if _cfg.Id == 1 then
                        GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.FreeShopVIP, _cfg.Id * 10000, RedPointCustomCondition(true))
                    end
                    -- Haven't purchased yet, add red dots to purchase
                    GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.FreeShop2, _cfg.Id * 10000, RedPointCustomCondition(true))
                end
            else
                -- Have purchased it, determine whether it has arrived for days
                if self.CurOpenServerDay >= _cfg.Time then
                    if _cfg.Id == 1 then
                        GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.FreeShopVIP, _cfg.Id * 10000 + 1, RedPointCustomCondition(true))
                    end
                    -- Increase red dots
                    GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.FreeShop2, _cfg.Id * 10000 + 1, RedPointCustomCondition(true))
                end
            end
        end
    end
    if addBuyRP and _haveNotBuy then
        if _vipNotBuy then
            GameCenter.MainFunctionSystem:SetFunctionEffect(FunctionStartIdCode.FreeShopVIP, true)
        end
        GameCenter.MainFunctionSystem:SetFunctionEffect(FunctionStartIdCode.FreeShop2, true)
    end
    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.FreeShop2, _funcIsOpen)
    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.FreeShopVIP, _vipIsOpen)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_ZEROBUY_FORM)
end

-- Set the server opening time
function ZeroBuySystem:SetOpenServerTime(time)
    -- Check the opening status
    self.ServerOpenTime = math.floor(time / 1000) + GameCenter.HeartSystem.ServerZoneOffset
    self:CheckOpenState(true)
end

-- Initialization online
function ZeroBuySystem:SyncOnlineInitNewFreeShop(msg)
    self.BuyState = {}
    if msg.zeroBuyList ~= nil then
        for i = 1, #msg.zeroBuyList do
            local _msgData = msg.zeroBuyList[i]
            self.BuyState[_msgData.id] = {IsGet = _msgData.isGet, BuyTime = _msgData.buyTime}
        end
    end
    self:CheckOpenState(true)
end

-- Buy or collect back
function ZeroBuySystem:SyncBuyNewFreeShopResult(msg)
    if self.BuyState == nil then
        self.BuyState = {}
    end
    self.BuyState[msg.buyData.id] = {IsGet = msg.buyData.isGet, BuyTime = msg.buyData.buyTime}
    if msg.type == 1 then
        -- 1 means purchase
    elseif msg.type == 2 then
        -- 2 Representatives receive the award
    end
    self:CheckOpenState(false)
end

return ZeroBuySystem 