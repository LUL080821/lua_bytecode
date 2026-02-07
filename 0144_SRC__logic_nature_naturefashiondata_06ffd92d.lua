-- Author: 
-- Date: 2019-04-24
-- File: NatureFashionData.lua
-- Module: NatureFashionData
-- Description: Universal data for creation and transformation
------------------------------------------------
local BaseAttrData = require "Logic.Nature.NatureBaseAttrData"
local FightUtils = require "Logic.Base.FightUtils.FightUtils"

local NatureFashionData = {
    ModelId = 0,-- The model ID is also the configuration table ID
    Name = nil, -- name
    Item = 0, -- Activate and upgrade required model ID
    AttrList = nil, -- NatureBaseAttrData for attribute storage
    Level = nil, -- grade
    NeedItemNum = 0,-- Number of props required to activate or upgrade the star
    Icon = 0, -- The icon displayed in the list
    IsActive = false, -- Whether to activate
    MaxLevel = 0,-- Maximum level
    Fight = 0, -- Combat power
    IsRed = false, -- Is there a red dot
    NeedItemList = nil, -- The prop list is used to set the required props after upgrading
    IsServerActive = false, -- Whether the server is activated
    SortNum = 0,              -- Sort sequence number
    Cfg = nil,         -- Configuration table
}
NatureFashionData.__index = NatureFashionData

function NatureFashionData:New(info)
    local _M = Utils.DeepCopy(self)
    _M.Cfg = info
    _M.ModelId = info.Id
    if info.Occ then
        _M.Occ = info.Occ
    else
        _M.Occ = nil
    end
    _M.Name = info.Name
    _M.Item = info.ActiveItem
    _M.Level = 0
    _M.NeedItemNum = 0
    _M.Icon = info.Icon
    _M.AttrList = List:New()
    _M.IsActive = false
    _M.MaxLevel = 0
    _M.Fight = 0
    _M.IsRed = false
    if info.ActiveCondition and info.ActiveCondition == 1 then
        _M.IsServerActive = true
    else
        _M.IsServerActive = false
    end
    if info.Order then
        _M.SortNum = info.Order
    end
    local _cs = {';','_'}
    _M.NeedItemList = Utils.SplitStrByTableS(info.StarItemnum,_cs)
    _M:UpDateAttrData(info)
    _M:GetActiveFight()
    return _M
end

-- Set properties
function NatureFashionData:UpDateAttrData(info)
    self.Cfg = info
    self.MaxLevel = #self.NeedItemList
    local _cs = {';','_'}
    local _attr = Utils.SplitStrByTableS(info.RentAtt,_cs)
    self.AttrList:Clear()
    local _dic = Dictionary:New()
    for i=1,#_attr do
        local _ismax = self.Level >= self.MaxLevel
        local _addattr = _ismax and 0 or _attr[i][3]
        local _attrvalue = _attr[i][2]
        local _pir = self.Level
        if _addattr then
            local _data = BaseAttrData:New(_attr[i][1],_attrvalue + _pir * _attr[i][3],_addattr)
            self.AttrList:Add(_data)
            self:UpDateNeedItem()
            _dic:Add(tonumber(_attr[i][1]), tonumber(_attr[i][2]) + tonumber(_attr[i][3]) * self.Level)
        end
    end
    self.Fight = FightUtils.GetPropetryPower(_dic)
end

-- Update required props
function NatureFashionData:UpDateNeedItem()
    if self.IsActive then
        for i=1,#self.NeedItemList do
            if self.NeedItemList[i][1] == self.Level then
                self.NeedItemNum = self.NeedItemList[i][2]
                break
            end
        end
    else
        self.NeedItemNum = self.NeedItemList[1][2]
    end
end

function NatureFashionData:GetRed()
    self.IsRed = false
    local _ismax = self.Level >= self.MaxLevel
    self:UpDateNeedItem()
    if GameCenter.ItemContianerSystem:GetItemCountFromCfgId(self.Item) >= self.NeedItemNum
        and not _ismax and ((self.IsActive and self.IsServerActive) or not self.IsServerActive) then
        self.IsRed = true
    end
    return self.IsRed
end

function NatureFashionData:GetActiveFight()
    if self.Cfg then
        local _cs = {';','_'}
        local _attr = Utils.SplitStrByTableS(self.Cfg.RentAtt,_cs)
        local _dic = Dictionary:New()
        for i=1,#_attr do
            _dic:Add(tonumber(_attr[i][1]), tonumber(_attr[i][2]))
        end
        self.Fight = FightUtils.GetPropetryPower(_dic)
    end
end

function NatureFashionData:SetFight()
    if self.Cfg then
        local _cs = {';','_'}
        local _attr = Utils.SplitStrByTableS(self.Cfg.RentAtt,_cs)
        local _dic = Dictionary:New()
        for i=1,#_attr do
            _dic:Add(tonumber(_attr[i][1]), tonumber(_attr[i][2]) + tonumber(_attr[i][3]) * self.Level)
        end
        self.Fight = FightUtils.GetPropetryPower(_dic)
    end
end
return NatureFashionData