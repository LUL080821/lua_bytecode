------------------------------------------------
-- Author: 
-- Date: 2020-10-16
-- File: XianShiLiBaoData.lua
-- Module: XianShiLiBaoData
-- Description: Thailand Limited Time Gift Pack (Limited Time Special Offer Small Yuanbao Consumption) Data
------------------------------------------------
local TimeUtils = CS.Thousandto.Core.Base.TimeUtils
local BaseData = require("Logic.YYHD.YYHDBaseData")
local ItemData = require("Logic.YYHD.YYHDItemData")

local XianShiLiBaoData = {
    -- Item List
    ItemList = nil,
    -- Current days
    CurDay = nil,
    -- Current purchases
    CurBuyCount = nil,
    -- Main interface iconid
    MainIconID = nil,
    --
    FrontActive = nil,
    -- Current end time
    CurEndTime = nil,
}

function XianShiLiBaoData:New(typeId)
    local _n = Utils.DeepCopy(self)
    local _mn = setmetatable(_n, {__index = BaseData:New(typeId)})
    local _cfg = DataConfig.DataActivityYunying[typeId]
    _mn.FormOpenEventID =_cfg.UseUiId * 10 + EventConstDefine.EVENT_UI_BASE_ID
    _mn.FormCloseEventID =_cfg.UseUiId * 10 + 9 + EventConstDefine.EVENT_UI_BASE_ID
    _mn.IsShowInList = false
    return _mn
end

-- Parse activity configuration data
function XianShiLiBaoData:ParseSelfCfgData(jsonTable)
    self.ItemList = {}
    for k, v in pairs(jsonTable) do
        local _items = List:New()
        for i = 1, #v.reward do
            _items:Add(ItemData:New(v.reward[i]))
        end
        self.ItemList[tonumber(k)] = {
            Day = tonumber(v.day),
            LimitCount = tonumber(v.limitTimes),
            Price = tonumber(v.price),
            CostItem = tonumber(v.currencyType),
            Items = _items,
        }
    end
end

-- Analyze the data of active players
function XianShiLiBaoData:ParsePlayerData(jsonTable)
    self.CurDay = tonumber(jsonTable.day)
    self.CurBuyCount = tonumber(jsonTable.alreadyBuy)
end

-- Refresh data
function XianShiLiBaoData:RefreshData()
    self.FrontActive = nil
end

-- Activities not displayed on the list need to be updated
function XianShiLiBaoData:UpdateActive()
    local _serverTime = math.floor(GameCenter.HeartSystem.ServerZoneTime)
    local _active = self:IsActive()
    if self.FrontActive ~= _active or (self.CurEndTime ~= nil and self.CurEndTime < _serverTime) then
        if self.MainIconID ~= nil then
            GameCenter.MainLimitIconSystem:RemoveIcon(self.MainIconID)
        end
        -- Close the interface when refreshing data
        GameCenter.PushFixEvent(self.FormCloseEventID)
        if _active then
            local _curDayData = self.ItemList[self.CurDay]
            if _curDayData ~= nil and _curDayData.LimitCount > self.CurBuyCount then
  
                -- Get the current number of seconds
                local _h, _m, _s = TimeUtils.GetStampTimeHHMMSSNotZone(_serverTime)
                local _curSec = _h * 3600 + _m * 60 + _s
                -- Positioned to 24 o'clock today
                local _endTime = _serverTime - _curSec + 86400
                local _zoneTime = GameCenter.HeartSystem.ServerZoneOffset
                local _hdEndTime = self.EndTime + _zoneTime
                -- Determine whether the event end time has exceeded
                if _endTime > _hdEndTime then
                    _endTime = _hdEndTime
                end
                self.CurEndTime = _endTime
                self.MainIconID = GameCenter.MainLimitIconSystem:AddIcon(self.Name, "n_chongzhi", _endTime,
                function(id)
                    GameCenter.PushFixEvent(self.FormOpenEventID, self.TypeId)
                end, nil, 1)
            end
        end
        self.FrontActive = _active
    end
end

-- Processing operational activities return
function XianShiLiBaoData:ResActivityDeal(jsonTable)
end

-- Request a purchase
function XianShiLiBaoData:ReqBuy()
    local _curDayData = self.ItemList[self.CurDay]
    if _curDayData ~= nil and _curDayData.LimitCount > self.CurBuyCount then
        local _haveNum = GameCenter.ItemContianerSystem:GetEconomyWithType(_curDayData.CostItem)
        if _haveNum < _curDayData.Price then
            local _costCfg = DataConfig.DataItem[_curDayData.CostItem]
            if _costCfg ~= nil then
                Utils.ShowPromptByEnum("C_TUANGOU_COIN_NOTENOUGH", _costCfg.Name)
            end
            return
        end
        GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {type = self.TypeId})
    end
end

function XianShiLiBaoData:OpenUI()
    if self.MainIconID ~= nil then
        GameCenter.PushFixEvent(self.FormOpenEventID, self.TypeId)
    end
end

return XianShiLiBaoData
