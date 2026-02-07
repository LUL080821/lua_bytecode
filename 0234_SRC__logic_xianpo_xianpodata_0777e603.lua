------------------------------------------------
-- author:
-- Date: 2019-07-19
-- File: XianPoData.lua
-- Module: XianPoData
-- Description: Xianpo data category
------------------------------------------------
local XianPoData = {
    Uid = 0,                                    -- The uid of the fairy soul
    Level = 0,                                  -- The level of the immortal soul
    Exp = 0,                                    -- The experience of the immortal soul
    Location = 0,                               -- The location of the immortal soul
    CfgId = 0,                                  -- The configuration table id of the immortal soul
    Name = "",                                  -- name
    Icon = 0,                                   -- icon
    Quality = 0,                                -- Quality grade, (1 blue, 2 purple, 3 gold, 4 red)
    MaxLevel = 0,                               -- Maximum level
    CanInlayLocationList = List:New(),          -- A lattice that can be inlaid
    BaseAttrDic = Dictionary:New(),             -- Basic attribute dictionary
    BaseAddAttrDic = Dictionary:New(),          -- Added attribute dictionary for each level
    TotalAddAttrDic = Dictionary:New(),         -- The total increase of the attributes of the immortal soul
    NextLvTotalAddAttrDic = Dictionary:New(),   -- The total increased attributes of the next level of the immortal soul
    GetConditionType = 35,                      -- Get the type of the required conditions of the immortal soul, the type in the functionVariable table
    GetConditionValue = 0,                      -- Get the required values for the Immortal Soul
    MutexIdList = List:New(),                   -- List of Immortal Idioms that are mutually exclusive to this Immortal Soul
    BaseDecompositionExp = 0,                   -- Basic decomposition experience
    Typ = 0,                                    -- Immortal Soul Type
    TypeName = "",                              -- Immortal Soul Type, 1: Attribute Immortal Soul, 2: Experience Immortal Soul
    Type2 = 0,                                  -- Differentiate between the types of immortal souls, the mutual repulsion of the user's immortal soul equipment and replacement
    SortId = 0,                                 -- Sort ID
    Star = 0,
}

function XianPoData:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

function XianPoData:SetAllData(data)
    self.Uid = data.uid
    self.Level = data.level
    self.Exp = data.exp
    self.Location = data.location
    self.CfgId = data.itemId
    local _cfg = DataConfig.DataImmortalSoulAttribute[self.CfgId]
    if _cfg then
        self.Star = _cfg.Star
        self.Name = _cfg.Name
        self.Icon = _cfg.Icon
        self.Quality = _cfg.Quality
        if _cfg.LevelMax and _cfg.LevelMax ~= "" then
            self.MaxLevel = _cfg.LevelMax
        end
        if _cfg.Grid ~= "" then
            self.CanInlayLocationList = Utils.SplitNumber(_cfg.Grid, "_")
        end
        -- Calculate basic properties
        if _cfg.LevelMax and _cfg.LevelMax ~= "" then
            local _baseAttrList = Utils.SplitStrByTableS(_cfg.DemandValue)
            local _percentList = Utils.SplitStrByTableS(_cfg.DemandValuePercent)
            if _percentList ~= nil then
                for i = 1, #_percentList do
                    table.insert( _baseAttrList, _percentList[i] )
                end
            end
            for i=1,#_baseAttrList do
                if not self.BaseAttrDic:ContainsKey(_baseAttrList[i][1]) then
                    self.BaseAttrDic:Add(_baseAttrList[i][1], _baseAttrList[i][2])
                end
                if not self.TotalAddAttrDic:ContainsKey(_baseAttrList[i][1]) then
                    self.TotalAddAttrDic:Add(_baseAttrList[i][1], _baseAttrList[i][2])
                end
            end
            -- Calculate the attributes and total attributes added at each level
            local _baseAddAttrList = Utils.SplitStrByTableS(_cfg.BasicAttributes)
            local _baseAddAttrListPercent = Utils.SplitStrByTableS(_cfg.BasicAttributesPercent)
            if _baseAddAttrListPercent ~= nil then
                for i = 1, #_baseAddAttrListPercent do
                    table.insert( _baseAddAttrList, _baseAddAttrListPercent[i] )
                end
            end
            for i=1,#_baseAddAttrList do
                if not self.BaseAddAttrDic:ContainsKey(_baseAddAttrList[i][1]) then
                    self.BaseAddAttrDic:Add(_baseAddAttrList[i][1], _baseAddAttrList[i][2])
                end
                if self.TotalAddAttrDic:ContainsKey(_baseAddAttrList[i][1]) then
                    local _value = self.TotalAddAttrDic[_baseAddAttrList[i][1]]
                    -- The fairy soul I just obtained is level 1 by default
                    self.TotalAddAttrDic[_baseAddAttrList[i][1]] = _value + _baseAddAttrList[i][2] * (self.Level - 1)
                end
            end
            -- Calculate the properties added at the next level
            self.TotalAddAttrDic:Foreach(
                function(key, value)
                    if not self.NextLvTotalAddAttrDic:ContainsKey(key) then
                        self.NextLvTotalAddAttrDic:Add(key, value)
                    end
                end
            )
            if self.Level < self.MaxLevel then
                for i=1,#_baseAddAttrList do
                    if self.NextLvTotalAddAttrDic:ContainsKey(_baseAddAttrList[i][1]) then
                        local _value = self.NextLvTotalAddAttrDic[_baseAddAttrList[i][1]]
                        self.NextLvTotalAddAttrDic[_baseAddAttrList[i][1]] = _value + _baseAddAttrList[i][2]
                    end
                end
            end
        end
        if _cfg.ExchangeConditions ~= "" then
            local _condition = Utils.SplitNumber(_cfg.ExchangeConditions, "_")
            self.GetConditionType = _condition[1]
            self.GetConditionValue = _condition[2]
        end
        if _cfg.ExclusiveID ~= "" then
            self.MutexIdList = Utils.SplitNumber(_cfg.ExclusiveID, "_")
        end
        self.BaseDecompositionExp = _cfg.Exp
        self.Typ = _cfg.Type
        if _cfg.Type == 1 then
            self.TypeName = DataConfig.DataMessageString.Get("PropertyXianPo")
        elseif _cfg.Type == 2 then
            self.TypeName = DataConfig.DataMessageString.Get("PropertyExp")
        elseif _cfg.Type == 3 then
            self.TypeName = DataConfig.DataMessageString.Get("PropertyXianPo")
        end
        self.Type2 = _cfg.ExclusiveID
    end
end

return XianPoData
