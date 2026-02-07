------------------------------------------------
-- Author: 
-- Date: 2020-10-16
-- File: JieRiTeHuiData.lua
-- Module: JieRiTeHuiData
-- Description: Thai holiday special offer (direct purchase gift package) data
------------------------------------------------
local TimeUtils = CS.Thousandto.Core.Base.TimeUtils
local BaseData = require("Logic.YYHD.YYHDBaseData")
local ItemData = require("Logic.YYHD.YYHDItemData")

local JieRiTeHuiData = {
    -- Product List
    ItemList = nil,
    -- Purchased item
    BuyTable = nil,
    -- iconid displayed on the main interface
    MainIconID = nil,
    -- Displayed product information
    ShowItem = nil,
    FrontActive = nil,

    FormOpenEventID = 0,
    FormCloseEventID = 0,
    -- Current end time
    CurEndTime = nil,
}

function JieRiTeHuiData:New(typeId)
    local _n = Utils.DeepCopy(self)
    local _mn = setmetatable(_n, {__index = BaseData:New(typeId)})
    local _cfg = DataConfig.DataActivityYunying[typeId]
    _mn.FormOpenEventID =_cfg.UseUiId * 10 + EventConstDefine.EVENT_UI_BASE_ID
    _mn.FormCloseEventID =_cfg.UseUiId * 10 + 9 + EventConstDefine.EVENT_UI_BASE_ID
    _mn.IsShowInList = false
    return _mn
end

-- Parse activity configuration data
function JieRiTeHuiData:ParseSelfCfgData(jsonTable)
    self.ItemList = List:New()
    for k, v in pairs(jsonTable) do
        local _itemList = List:New()
        for i = 1, #v do
            _itemList:Add(ItemData:New(v[i]))
        end
        self.ItemList:Add({Id = tonumber(k), Items = _itemList})
    end
    self.ItemList:Sort(function(x,y)
        return x.Id < y.Id
    end)
end

-- Analyze the data of active players
function JieRiTeHuiData:ParsePlayerData(jsonTable)
    self.BuyTable = {}
    for i = 1, #jsonTable.buyGoodsId do
        self.BuyTable[tonumber(jsonTable.buyGoodsId[i])] = true
    end
end

-- Refresh data
function JieRiTeHuiData:RefreshData()
    self.FrontActive = nil
end

-- Activities not displayed on the list need to be updated
function JieRiTeHuiData:UpdateActive()
    local _serverTime = math.floor(GameCenter.HeartSystem.ServerZoneTime)
    local _active = self:IsActive()
    if self.FrontActive ~= _active or (self.CurEndTime ~= nil and self.CurEndTime < _serverTime) then
        if self.MainIconID ~= nil then
            GameCenter.MainLimitIconSystem:RemoveIcon(self.MainIconID)
        end
        -- Close the interface when refreshing data
        GameCenter.PushFixEvent(self.FormCloseEventID)
        if _active then
            local _showId = nil
            self.ShowItem = nil
            for i = 1, #self.ItemList do
                if self.BuyTable[self.ItemList[i].Id] == nil then
                    _showId = self.ItemList[i].Id
                    self.ShowItem = self.ItemList[i]
                    break
                end
            end
            if _showId ~= nil then
                -- There are still no purchases
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
                end, _showId, 0)
            end
        end
        self.FrontActive = _active
    end
end

-- Processing operational activities return
function JieRiTeHuiData:ResActivityDeal(jsonTable)
end

-- Purchase gift bag
function JieRiTeHuiData:ReqBuy()
    if self.ShowItem ~= nil then
        -- Open Recharge
        GameCenter.PaySystem:PayByCfgId(self.ShowItem.Id)
    end
end

function JieRiTeHuiData:OpenUI()
    if self.MainIconID ~= nil then
        GameCenter.PushFixEvent(self.FormOpenEventID, self.TypeId)
    end
end

return JieRiTeHuiData
