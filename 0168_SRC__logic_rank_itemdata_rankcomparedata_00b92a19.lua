------------------------------------------------
-- Author:
-- Date: 2019-04-30
-- File: RankCompareData.lua
-- Module: RankCompareData
-- Description: Ranking attribute comparison data script
------------------------------------------------
-- Quote
local AttrData = require "Logic.Rank.ItemData.RankAttrData"
local RankCompareData = {
    -- name
    Name = nil,
    -- Combat power
    Power = 0,
    -- grade
    Level = 0,
    -- Profession
    Career = 0,
    AttrList = List:New(),
    RoleID = 0,
    Head = nil,
}

function RankCompareData:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

-- set up
function RankCompareData:SetData(msg)
    self.Name = msg.name
    self.Power = msg.power
    self.Level = msg.level
    self.Career = msg.career
    self.RoleID = msg.roleID
    self.Head = msg.head
    self.AttrList:Clear()
    for i = 1, #msg.attrs do
        local attr = AttrData:New()
        attr:SetData(msg.attrs[i])
        self.AttrList:Add(attr)
    end
    self.AttrList:Sort(function(a,b) 
        return a.Sort<b.Sort
     end )
end
return RankCompareData