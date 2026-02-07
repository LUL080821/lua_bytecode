------------------------------------------------
-- Author:
-- Date: 2019-04-26
-- File: RankMenuData.lua
-- Module: RankMenuData
-- Description: Ranking menu data category
------------------------------------------------
-- Quote
local ChildMenuData = require "Logic.Rank.MenuData.RankChildMenuData"
local RankMenuData = {
    -- Large menu id
    MenuType = 0,
    -- Menu name
    MenuName = nil,
    -- Menu Dictionary
    ChildMenuDic = Dictionary:New(),
}

--New 
function RankMenuData:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

-- Add menu
function RankMenuData:AddMenu(cfg)
    local childMenu = self:GetChildMenu(cfg.Id)
    childMenu:SetCfg(cfg)
    self.MenuType = cfg.Type
    self.MenuName = cfg.TypeName
end

-- Get submenu
function RankMenuData:GetChildMenu(id)
    if self.ChildMenuDic:ContainsKey(id) then
        return self.ChildMenuDic[id]
    else
        local childMenu = ChildMenuData:New()
        self.ChildMenuDic:Add(id,childMenu)
        return childMenu
    end
end

-- Get the first submenu data
function RankMenuData:GetFirstChildMenu()
    for k,v in pairs(self.ChildMenuDic) do
        return v
    end
end

function RankMenuData:GetChildMenuData(key)
    for k,v in pairs(self.ChildMenuDic) do
        if k == key then
            return v
        end
    end
end

function RankMenuData:HaveCrossData()
    local ret = false
    self.ChildMenuDic:ForeachCanBreak(function(k, v)
        local childMenu = v
        if childMenu:HaveCrossData() then
            ret = true
        end
    end)
    return ret
end
return RankMenuData