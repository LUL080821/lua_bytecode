------------------------------------------------
-- Author:
-- Date: 2019-04-26
-- File: RankData.lua
-- Module: RankData
-- Description: Ranking data category
------------------------------------------------
-- Quote
local MenuData = require "Logic.Rank.MenuData.RankMenuData"
local RankData = {
    -- My ranking
    MyRank = 0,
    -- My combat power
    MyPower = 0,
    -- Menu List
    MenuList = List:New(),
}

--New 
function RankData:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

-- Parse configuration table data
function RankData:ParseCfg(cfg)
    if cfg == nil then
        return
    end
    local menu = self:GetMenu(cfg.Type)
    menu:AddMenu(cfg)
end

-- Get Menu
function RankData:GetMenu(type)
    local isExist = false
    for i = 1 , #self.MenuList do
        if self.MenuList[i].MenuType == type then
            isExist = true
            return self.MenuList[i]
        end
    end
    if isExist == false then
        -- Create a Menu
        local menu = MenuData:New()
        menu.MenuType = type
        self.MenuList:Add(menu)
        return menu
    end
end
--
function RankData:GetItemList(rankId)
    for i = 1, #self.MenuList do
        local childMenuData = self.MenuList[i]:GetChildMenuData(rankId)
        if childMenuData ~= nil then
            return childMenuData:GetItemList()
        end
    end
end

function RankData:GetCrossItemList(rankId)
    for i = 1, #self.MenuList do
        local childMenuData = self.MenuList[i]:GetChildMenuData(rankId)
        if childMenuData ~= nil then
            return childMenuData:GetCrossItemList()
        end
    end
end

-- Add Item data
function RankData:AddItemInfo(rankKind, info, isCross)
    for i = 1, #self.MenuList do
        local childMenuData = self.MenuList[i]:GetChildMenuData(rankKind)
        if childMenuData ~= nil then
            return childMenuData:AddItemData(info,isCross)
        end
    end
    local lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if lp ~= nil then
        self.MyPower = lp.FightPower
    end
end

-- Get Compare data by RankId
function RankData:GetCompareDataByRankId(rankId)
    for i = 1, #self.MenuList do
        local childMenuData = self.MenuList[i]:GetChildMenuData(rankId)
        if childMenuData ~= nil then
            return childMenuData:GetCompareData()
        end
    end
end
return RankData