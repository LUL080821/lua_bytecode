
------------------------------------------------
-- author:
-- Date: 2020-08-31
-- File: WeekCrazySystem.lua
-- Module: WeekCrazySystem
-- Description: Saturday Carnival System
------------------------------------------------
-- Quote
local TimeUtils = CS.Thousandto.Core.Base.TimeUtils;
local WeekCrazySystem = {
    -- Start time
    StartTime = 0,
    -- End time
    EndTime = 0,
    -- End time rub
    RealEndTime = 0,
    -- Purchase data
    -- {Id:Product Id, ListItem: Item List, Price: Price, IsBuy: Whether to buy }
    ListData = List:New()
}

function WeekCrazySystem:Initialize()    
end

-- Get the product list
function WeekCrazySystem:GetDatas()
    local occ = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
    if #self.ListData == 0 then
        DataConfig.DataHappyWeek:Foreach(function(k, v)
            local day = v.Day
            if day == 6 then
                local id = v.RechargeID
                local des = v._Des
                local isBuy = false
                local cfg = GameCenter.PaySystem.PayDataIdDict[id]
                local price = GameCenter.PaySystem:GetMoneyCountById(id)
                local itemList = List:New()
                local list = Utils.SplitStr(cfg.ServerCfgData.Reward, ';')
                for i = 1,#list do
                    local subList = Utils.SplitNumber(list[i], '_')
                    if occ == subList[4] or subList[4] == 9 then
                        itemList:Add({Id = subList[1], Num = subList[2], IsBind = subList[3] == 1}) 
                        break
                    end
                end
                local data = {Id = id, Des = des, Price = price, IsBuy = isBuy, ListItem = itemList}
                self.ListData:Add(data)
            end
        end)
    end
    return self.ListData
end

-- Get product id
function WeekCrazySystem:GetId(index)
    local dataList = self:GetDatas()
    if index <= #dataList then
        return dataList[index].Id
    end
    return 0
end

-- Get data
function WeekCrazySystem:GetData(index)
    local dataList = self:GetDatas()
    if index <= #dataList then
        return dataList[index]
    end
    return nil
end

-- Get the item list
function WeekCrazySystem:GetGoods(index)
    local data = self:GetData(index)
    if data == nil then
        return nil
    end
    return data.ListItem
end

-- Get the quantity of products
function WeekCrazySystem:GetCount()
    local dataList = self:GetDatas()
    return #dataList
end

-- Get product prices through index
function WeekCrazySystem:GetPrice(index)
    local data = self:GetData(index)
    if data == nil then
        return 0
    end
    local price = GameCenter.PaySystem:GetMoneyCountById(data.Id)
    return price
end

-- Get the description
function WeekCrazySystem:GetDes(index)
    local data = self:GetData(index)
    if data == nil then
        return nil
    end
    return data.Des
end

-- Get the remaining time
function WeekCrazySystem:GetLeftTime()
    local serveTime =  GameCenter.HeartSystem.ServerZoneTime
    local week = TimeUtils.GetStampTimeWeeklyNotZone(math.ceil(serveTime))
    local hour, min, sec = TimeUtils.GetStampTimeHHMMSSNotZone(math.floor(serveTime))
    local curSeconds = hour * 3600 + min * 60 + sec
    if week == 0 then
        week = 7
    end
    local endTime = 6 * 24 * 3600
    local curTime = (week - 1) * 24 * 3600 + curSeconds
    self.RealEndTime = endTime - curTime
    return self.RealEndTime
end

return WeekCrazySystem
