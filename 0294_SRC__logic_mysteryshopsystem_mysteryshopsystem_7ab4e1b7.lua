
------------------------------------------------
-- Author:
-- Date: 2020-01-06
-- File: ResBackSystem.lua
-- Module: ResBackSystem
-- Description: Mysterious Store System
------------------------------------------------
-- Quote
local MysteryShopSystem = {
    ListData = List:New(),
    LimitIconIdList = List:New()
}

-- Initialization ranking Cfg
function MysteryShopSystem:Initialize()
    DataConfig.DataLimitMysteryShop:Foreach(function(k, v)
        local data = {Cfg = v, EndTime = 0, IsBuy = false, IsOver = false}
        self.ListData:Add(data)
    end)
    self.LimitIconIdList:Clear()
end

-- De-initialization
function MysteryShopSystem:UnInitialize()
    self.LimitIconIdList:Clear()
end

-- Get data according to configuration id
function MysteryShopSystem:GetData(cfgId)
    for i = 1,#self.ListData do
        if self.ListData[i].Cfg.Id == cfgId then
            return self.ListData[i]
        end
    end
    return nil
end

-- Get the remaining time according to the configuration
function MysteryShopSystem:GetLeftTimeByCfgId(cfgId)
    local time = 0
    for i = 1,#self.ListData do
        if self.ListData[i].Cfg.Id == cfgId then
            if not self.ListData[i].IsOver then
                time = self.ListData[i].EndTime - GameCenter.HeartSystem.ServerTime
                if time <=0 then
                    self.ListData[i].IsOver = true
                    time = 0
                else
                    if self.ListData[i].IsBuy then
                        time = 0
                    end
                end
            end
        end
    end
    return time
end

function MysteryShopSystem:GetItemList(cfgId)
    local list = nil
    local data = self:GetData(cfgId)
    if data ~= nil then
        list = List:New()
        local strs = Utils.SplitStr(data.Cfg.Reward,';')
        for i = 1, #strs do
            local params = Utils.SplitStr(strs[i],'_')            
            local id = tonumber(params[1])
            local num = tonumber(params[2])
            local bind = tonumber(params[3]) == 1
            local occ = tonumber(params[4])
            local player = GameCenter.GameSceneSystem:GetLocalPlayer()
            if player then
                local playerOcc = player.IntOcc
                if occ == 9 or occ == playerOcc then
                    local item = {Id = id, Num = num, IsBind = bind}
                    list:Add(item)
                end
            end
        end
    end
    return list
end

function MysteryShopSystem:ReqMysteryShopBuy(cfgId)
    GameCenter.Network.Send("MSG_Shop.ReqMysteryShopBuy", {id = cfgId})
end

function MysteryShopSystem:SyncMysteryShop(msg)
    if msg == nil then
        return
    end
    if msg.shops ~= nil then
        for i = 1,#msg.shops do
            for m = 1,#self.ListData do
                local data = self.ListData[m]
                if data.Cfg.Id == msg.shops[i].id then
                    data.EndTime = msg.shops[i].endTime / 1000
                    data.IsOver = msg.shops[i].isOverTime
                end
            end
        end
    end
    if msg.buyIds ~= nil then
        for i = 1,#msg.buyIds do
            for m = 1,#self.ListData do
                local data = self.ListData[m]
                if data.Cfg.Id == msg.buyIds[i] then
                    data.IsBuy = true
                end
            end
        end
    end
    if msg.succID ~= 0 then
        -- The purchase was successful
        GameCenter.PushFixEvent(UIEventDefine.UIMysteryShopForm_CLOSE)
        -- Open the reward display interface
        local itemList = self:GetItemList(msg.succID)
        GameCenter.PushFixEvent(UIEventDefine.UIWelfareGetItemForm_OPEN, itemList)
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MYSTERYSHOP_UPDATE)
    self:OnMainRequest()
end

-- Process the main interface request
function MysteryShopSystem:OnMainRequest(obj, sender)
    for i = 1, #self.LimitIconIdList do
        GameCenter.MainLimitIconSystem:RemoveIcon(self.LimitIconIdList[i])
    end
    local _helpTable = {}
    for i = 1, #self.ListData do
        local _data = self.ListData[i]
        if _data.IsOver ~= true and _data.IsBuy ~= true and _data.EndTime ~= 0 and _helpTable[_data.Cfg.Group] == nil then
            local _endTime = _data.EndTime + GameCenter.HeartSystem.ServerZoneOffset
            local _iconId = GameCenter.MainLimitIconSystem:AddIcon(DataConfig.DataMessageString.Get("LIMIT_MYSTERY_SHOP_REWARD_MAIL"), "n_icon_zjm_shenmishangdian", _endTime,
                function(id)
                    GameCenter.PushFixEvent(UIEventDefine.UIMysteryShopForm_OPEN, id)
                end, _data.Cfg.Id, 100 + _data.Cfg.Id)
            self.LimitIconIdList:Add(_iconId)
            _helpTable[_data.Cfg.Group] = 1
        end
    end
end

return MysteryShopSystem
