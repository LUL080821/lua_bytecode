
------------------------------------------------
-- Author:
-- Date: 2019-07-22
-- File: ServeExChangeData.lua
-- Module: ServeExChangeData
-- Description: Service opening activity redemption data
------------------------------------------------
-- Quote
local ItemData = require "Logic.ServeCrazy.ServeCrazyItemData"
local ServeExChangeData = {
    -- Configuration table Id
    CfgId = 0,    
    -- Remaining the remaining number of exchanges today -1: Unlimited exchange
    LeftCount = 0,
    -- Consumption props
    ListCostItem = List:New(),
    -- Obtain props
    ListRewardItem = List:New(),
}
function ServeExChangeData:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

function ServeExChangeData:ParaseCfg(cfg)
    if cfg ~= nil then
        self.CfgId = cfg.Id
        -- Set consumption prop data
        local list = Utils.SplitStr(cfg.Item,';')
        if list ~= nil then
            for i = 1,#list do
                local item = ItemData:New()
                item:Parase(list[i])
                self.ListCostItem:Add(item)
            end
        end
        -- Set reward prop data
        list = Utils.SplitStr(cfg.Reward, ';')
        if list ~= nil then
            for i = 1,#list do
                local item = ItemData:New()
                item:Parase(list[i])
                self.ListRewardItem:Add(item)
            end
        end
    end
    if cfg.LimitTime == 0 or cfg.LimitTime == nil then
        self.LeftCount = -1
    end 
end

-- Resolve server messages
function ServeExChangeData:ParaseMsg(msg)
    if self.LeftCount ~= -1 then
        self.LeftCount = msg
    end
end
return ServeExChangeData