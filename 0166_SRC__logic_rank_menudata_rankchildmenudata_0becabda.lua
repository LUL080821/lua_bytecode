------------------------------------------------
-- Author:
-- Date: 2019-04-26
-- File: RankChildMenuData.lua
-- Module: RankChildMenuData
-- Description: Ranking submenu data class
------------------------------------------------
-- Quote
local ItemData = require "Logic.Rank.ItemData.RankItemData"
local CompareData = require "Logic.Rank.ItemData.RankCompareData"
local RankChildMenuData = {
    -- Configuration table data
    Cfg = nil,
    -- Attribute comparison Info
    CompareInfo = nil,
    ItemList = List:New(),
    CrossItemList = List:New(),
}

--New 
function RankChildMenuData:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

-- Is there any cross-server data
function RankChildMenuData:HaveCrossData()
    if self.Cfg.Id == 101 or self.Cfg.Id == 102 then
        return true
    end
end

-- Setting submenu configuration data
function RankChildMenuData:SetCfg(cfg)
    self.Cfg = cfg
    if self.CompareInfo == nil then
        self.CompareInfo = CompareData:New()
    end
end

-- Set itemList data
function RankChildMenuData:AddItemData(rankInfo, isCross)
    if rankInfo == nil then
        return
    end
    local list = nil 
    if not isCross  then
        for i = 1,#rankInfo do
            local data = nil
            if i <= #self.ItemList then
                data = self.ItemList[i]
                data:SetData(rankInfo[i])
            else
                data = ItemData:New(rankInfo[i], false, self.Cfg.Id)
                self.ItemList:Add(data)
            end

            -- Quốc Kỳ BXH
            local playerNameData = UIUtils.ParseFormatPlayerName(data.Name);
            local flag_id = nil;
            local name = nil;
            for k, v in pairs(playerNameData) do
                if k == "flag_id" then flag_id = v; end
                if k == "name" then name = v; end
            end
            data.Name = name;
            data.FlagId = flag_id;
            -- Quốc Kỳ BXH

        end
        self.ItemList:Sort(function(a,b) 
            return a.Rank<b.Rank
         end )
    else      
        for i = 1,#rankInfo do
            local data = nil
            if i <= #self.CrossItemList then
                data = self.CrossItemList[i]
                data:SetData(rankInfo[i],true)
            else
                data = ItemData:New(rankInfo[i],true, self.Cfg.Id)
                self.CrossItemList:Add(data)
            end

            -- Quốc Kỳ BXH
            local playerNameData = UIUtils.ParseFormatPlayerName(data.Name);
            local flag_id = nil;
            local name = nil;
            for k, v in pairs(playerNameData) do
                if k == "flag_id" then flag_id = v; end
                if k == "name" then name = v; end
            end
            data.Name = name;
            data.FlagId = flag_id;
            -- Quốc Kỳ BXH
            
        end
        self.CrossItemList:Sort(function(a,b) 
            return a.Rank<b.Rank
         end )  
    end
end

function RankChildMenuData:GetData(roleId)
    for i = 1,#self.ItemList do
        if self.ItemList[i].RoleId == roleId then
            return self.ItemList[i]
        end
    end
    return nil
end

function RankChildMenuData:GetCrossData(roleId)
    for i = 1,#self.CrossItemList do
        if self.CrossItemList[i].RoleId == roleId then
            return self.CrossItemList[i]
        end
    end
    return nil
end

-- Get ItemList
function RankChildMenuData:GetItemList()
    return self.ItemList
end

function RankChildMenuData:GetCrossItemList()
    return self.CrossItemList
end

function RankChildMenuData:GetCrossItemList()
    return self.CrossItemList
end

-- Get Compare data
function RankChildMenuData:GetCompareData()
    return self.CompareInfo
end

return RankChildMenuData