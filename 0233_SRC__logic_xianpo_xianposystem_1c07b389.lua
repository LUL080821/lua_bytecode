------------------------------------------------
-- author:
-- Date: 2019-07-18
-- File: XianPoSystem.lua
-- Module: XianPoSystem
-- Description: Fairy Soul System
------------------------------------------------
local XianPoData = require("Logic.XianPo.XianPoData")
local XianPoSyntheticData = require("Logic.XianPo.XianPoSyntheticData")
local L_JianCore = require "Logic.XianPo.JianCoreData"
local L_BattlePropTools = CS.Thousandto.Code.Logic.BattlePropTools
local RedPointItemCondition = CS.Thousandto.Code.Logic.RedPointItemCondition

local XianPoSystem = {
    EquipedXianPoDic = Dictionary:New(), -- Equipped Xianpo Dictionary, key = position, value = XianPoData
    BagXianPoDic = Dictionary:New(), -- The Xianpo Dictionary in the backpack, key = uid, value = XianPoData
    XianPoOverviewDic = Dictionary:New(), -- Xianpo Preview Dictionary, key = unlocked layer number, value = configuration table id
    XianPoExchangeDic = Dictionary:New(), -- Xianpo exchange dictionary, key = sort, value = configuration table id
    XianPoSyntheticTypeDic = Dictionary:New(), -- Xianpo Synthesis Type Dictionary, key = Large Classification Id, value = List<Synthetic Table Id>
    XianPoSyntheticDic = Dictionary:New(), -- Xianpo Synthetic Dictionary, key = Synthetic id, value = XianPoSyntheticData
    GetXianPoConditionType = 0, -- The type of the required conditions for obtaining the immortal soul (the type in the functionVariable table)
    HoleDataDic = nil, -- Mosaic hole data

    XianPoMaxInlayIndex = 10, -- The largest inlay position of the fairy soul
    MaxBagCount = 200, -- The largest backpack lattice

    -- The CfgId of the current request
    ReqCompoundCfgId = 0,

    -- Red dot index Id
    ListRedPointIds = List:New(),
    -- Passing the Sword Spirit Pavilion Levels
    JianLingGeLevel = 0,
    -- Total number of grids that each sword spirit can inlay
    HoleCount = 7,
    -- List of Sword Spirits (only names are included for the time being)
    JianLingList = List:New(),
    JianLingModelIdList = List:New(),
    -- List of mosaic holes that can be upgraded
    CanLvList = List:New(),
    -- List of Inlaid (Replaceable) Sword Spirits
    ValidJianLingList = List:New(),
    -- Total data acquisition
    ViewDic = Dictionary:New(),
    -- Whether to display synthetic red dots
    preShowSynRedPoint = false,
    IsShowSynRedPoint = false,
    -- Have the backpack spirit changed?
    IsLingPoChange = false,
    -- Update detection of red dot time
    CheckTime = 1,
    -- Total number of sword spirits
    JianLingCount = 6,

    -- Conditions for whether the sword is displayed
    DicJianCore = nil,
    -- Total number of backpack spirits
    BagSoulCount = 0,
    -- Configuration id corresponds to the number of spiritual souls in the backpack
    SoulBagDic = Dictionary:New(),
}

function XianPoSystem:Initialize()
    self.BagSoulCount = 0
    self.SoulBagDic:Clear()
    -- Message registration
    GameCenter.RegFixEventHandle(LogicLuaEventDefine.EID_EVEMT_UPDATE_SWORDMANDATE, self.SwordChange, self)
    self.MaxBagCount = DataConfig.DataGlobal[1581].Params
    DataConfig.DataImmortalSoulAttribute:Foreach(function(key, value)
        -- Non-experienced immortal soul, use immortal soul for preview
        if value.Type ~= 2 then
            if self.GetXianPoConditionType == 0 then
                if value.ExchangeConditions ~= "" then
                    local _condition = Utils.SplitNumber(value.ExchangeConditions, "_")
                    self.GetXianPoConditionType = _condition[1]
                end
            end
            if not self.XianPoOverviewDic:ContainsKey(value.OverviewConditions) then
                local _cfgIdList = List:New()
                _cfgIdList:Add(key)
                self.XianPoOverviewDic:Add(value.OverviewConditions, _cfgIdList)
            else
                local _cfgIdList = self.XianPoOverviewDic[value.OverviewConditions]
                _cfgIdList:Add(key)
            end
        end
        -- Convertible to Fairy Soul
        if value.ExchangeRanking > 0 then
            if not self.XianPoExchangeDic:ContainsKey(value.ExchangeRanking) then
                self.XianPoExchangeDic:Add(value.ExchangeRanking, key)
            end
        end
    end)
    -- Sorting of the Dictionary of the Fairy Soul
    self.XianPoExchangeDic:SortKey(function(a, b)
        return a < b
    end)

    DataConfig.DataImmortalSoulSynthesis:Foreach(function(key, value)
        if not self.XianPoSyntheticTypeDic:ContainsKey(value.Type) then
            local _idList = List:New()
            _idList:Add(key)
            self.XianPoSyntheticTypeDic:Add(value.Type, _idList)
        else
            local _idList = self.XianPoSyntheticTypeDic[value.Type]
            _idList:Add(key)
        end
        if not self.XianPoSyntheticDic:ContainsKey(key) then
            local _data = XianPoSyntheticData:New()
            _data:SetAllData(value)
            self.XianPoSyntheticDic:Add(key, _data)
        end
    end)
    GameCenter.RegFixEventHandle(LogicEventDefine.EVENT_COIN_CHANGE_UPDATE, self.CoinChange, self)

    -- Spiritual soul draws red dots
    local _huntCfg = DataConfig.DataImmortalSoulHunt[2]
    if _huntCfg ~= nil then
        local _costItems = Utils.SplitNumber(_huntCfg.BasicAttributes, '_')
        GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.LingPoLottery, 0,
            RedPointItemCondition(_costItems[1], _costItems[2]))
    end
end

function XianPoSystem:UnInitialize()
    self.BagSoulCount = 0
    self.SoulBagDic:Clear()
    self.EquipedXianPoDic:Clear()
    self.BagXianPoDic:Clear()
    GameCenter.UnRegFixEventHandle(LogicLuaEventDefine.EID_EVEMT_UPDATE_SWORDMANDATE, self.SwordChange, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EVENT_COIN_CHANGE_UPDATE, self.CoinChange, self)
end

function XianPoSystem:CoinChange(obj, sender)
    if obj == ItemTypeCode.LingPoSw then
        self:LingPoChange()
    end
end

-- The number of layers of Jiange has changed
function XianPoSystem:SwordChange(obj, sender)
    self.JianLingGeLevel = GameCenter.SwordMandateSystem.CurLevel
    self.IsShowSynRedPoint = self:SetXianPoSyntheticRedPoint()
    if self.preShowSynRedPoint ~= self.IsShowSynRedPoint then
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.XianPoSynthetic, self.IsShowSynRedPoint)
        self.preShowSynRedPoint = self.IsShowSynRedPoint
    end
end

-- Get the list of sword spirit names
function XianPoSystem:GetNameList()
    if #self.JianLingList == 0 then
        local dic = GameCenter.FlySowardSystem:GetTypeDic()
        if dic ~= nil then
            local list = dic:GetKeys()
            for i = 1, #list do
                local cfg = GameCenter.FlySowardSystem:GetActiveCfgByType(list[i])
                if cfg ~= nil then
                    self.JianLingList:Add(cfg.Name)
                end
            end
        end
    end
    return self.JianLingList
end

-- Get the list of sword spirit model IDs
function XianPoSystem:GetModelList()
    if #self.JianLingModelIdList == 0 then
        local dic = GameCenter.FlySowardSystem:GetTypeDic()
        if dic ~= nil then
            local list = dic:GetKeys()
            for i = 1, #list do
                local cfg = GameCenter.FlySowardSystem:GetActiveCfgByType(list[i])
                if cfg ~= nil then
                    self.JianLingModelIdList:Add(cfg.Id)
                end
            end
        end
    end
    return self.JianLingModelIdList
end

-- Get the maximum index of activated sword spirit
function XianPoSystem:GetActiveJianlingIndex()
    local index = 1
    local dic = GameCenter.FlySowardSystem:GetTypeDic()
    if dic ~= nil then
        local list = dic:GetKeys()
        for i = 1, #list do
            local type = list[i]
            for m = 1, self.HoleCount do
                local holeId = i * 100 + m
                if self:GetJianValid(i) then
                    local isValid = self:GetHoleIsValid(holeId)
                    if isValid then
                        index = type
                    end
                end
            end
        end
    end
    return index
end

-- Get mosaic hole data
function XianPoSystem:GetHoleDataDic()
    if self.HoleDataDic == nil then
        self.HoleDataDic = Dictionary:New()
        local nameList = self:GetNameList()
        local isActive = false
        for i = 1, #nameList do
            local index = i
            for m = 1, self.HoleCount do
                local holeId = i * 100 + m
                local data = self.HoleDataDic[holeId]
                if data == nil then
                    local cfg = DataConfig.DataImmortalSoulIattice[holeId]
                    if cfg ~= nil then
                        local list = Utils.SplitNumber(cfg.Condition, '_')
                        local level = list[2]
                        data = {
                            ActiveLv = level
                        }
                    end
                    self.HoleDataDic[holeId] = data
                end
            end
        end
    end
    return self.HoleDataDic
end

function XianPoSystem:Sort(list)
    if list ~= nil then
        list:Sort(function(a, b)
            return a.SortId < b.SortId
        end)
    end
end

-- Sort
function XianPoSystem:SortUid(uidlist)
    local list = List:New()
    local retList = List:New()
    for i = 1, #uidlist do
        local data = self:GetBagXianPoDataByUID(uidlist[i])
        if data ~= nil then
            data.SortId = self:GetSortId(data)
            list:Add(data)
        end
    end
    list:Sort(function(a, b)
        return a.SortId < b.SortId
    end)
    for i = 1, #list do
        local data = list[i]
        if data ~= nil then
            retList:Add(data.Uid)
        end
    end
    return retList
end

function XianPoSystem:SortUid2(uidlist, holeId, index)
    local list = List:New()
    local retList = List:New()
    for i = 1, #uidlist do
        local data = self:GetBagXianPoDataByUID(uidlist[i])
        if data ~= nil then
            data.SortId = self:GetSortId2(data, holeId, index)
            list:Add(data)
        end
    end
    list:Sort(function(a, b)
        return a.SortId < b.SortId
    end)
    for i = 1, #list do
        local data = list[i]
        if data ~= nil then
            retList:Add(data.Uid)
        end
    end
    return retList
end

function XianPoSystem:GetSortId(data)
    local sortId = 0
    if data.Quality == XianPoQuality.Blue then
        sortId = 1000000000000
    elseif data.Quality == XianPoQuality.Purple then
        sortId = 2000000000000
    elseif data.Quality == XianPoQuality.Gold then
        sortId = 3000000000000
    elseif data.Quality == XianPoQuality.Red then
        sortId = 4000000000000
    end
    sortId = sortId + data.CfgId - data.Level
    return sortId
end

function XianPoSystem:GetSortId2(data, holeId, index)
    local sortId = 0
    if data.Quality == XianPoQuality.Blue then
        sortId = 4000000000000
    elseif data.Quality == XianPoQuality.Purple then
        sortId = 3000000000000
    elseif data.Quality == XianPoQuality.Gold then
        sortId = 2000000000000
    elseif data.Quality == XianPoQuality.Red then
        sortId = 1000000000000
    end
    local visable, equal = self:CanEquipOrRepalce(data.Uid, holeId, index)
    if equal then
        sortId = sortId + 4000000000000
    end
    sortId = sortId + data.CfgId - data.Level * 10000000000 - data.Star * 100000000000
    return sortId
end

-- Determine whether the immortal soul with the specified ID can be replaced or embedded
function XianPoSystem:CanEquipOrRepalce(uid, holeId, index)
    local ret = false
    local haveEqualAtt = false
    local data = self.BagXianPoDic[uid]
    if data == nil then
        return false
    end
    if not self:GetHoleIsValid(holeId) then
        -- This is invalid
        return false
    end
    -- First check whether all sword spirit entries have holes that can be embedded
    ret = self:HaveFreeHole(holeId)
    if ret then
        -- Determine whether the current hole can be embedded
        ret = false
        for n = 1, self.HoleCount do
            local otherHole = index * 100 + n
            if otherHole ~= holeId then
                local otherEquiptItem = self.EquipedXianPoDic[otherHole]
                if otherEquiptItem ~= nil and otherEquiptItem.Type2 == data.Type2 then
                    -- If the properties are the same and not the same hole
                    haveEqualAtt = true
                end
            end
        end
        if not haveEqualAtt then
            -- If there are no identical properties, you can replace them
            ret = true
        end
    end
    if not ret then
        -- If you can't inlay, check if you can replace it
        local equipItem = self.EquipedXianPoDic[holeId]
        if equipItem ~= nil then
            ret, haveEqualAtt = self:CanReplace(data, equipItem, index, holeId)
        end
    end
    return ret, haveEqualAtt
end

-- Get the hole that can upgrade the spirit soul
function XianPoSystem:GetCanLvHole()
    self.CanLvList:Clear()
    local nameList = self:GetNameList()
    local isActive = false
    for i = 1, #nameList do
        local index = i
        for m = 1, self.HoleCount do
            local holeId = i * 100 + m
            local isValid = self:GetHoleIsValid(holeId)
            if isValid then
                -- Activated
                isActive = true
                break
            end
        end
        if isActive then
            for m = 1, self.HoleCount do
                local holeId = index * 100 + m
                if self:GetHoleIsValid(holeId) then
                    if self:IsIndexXianPoCanUpgrade(holeId) then
                        self.CanLvList:Add(holeId)
                    end
                end
            end
        end
    end
    return self.CanLvList
end

-- Determine whether there is a replaceable soul in the current hole
function XianPoSystem:HaveReplaceItem(index, holeId)
    local ret = false
    if self:GetHoleIsValid(holeId) then
        local equipItem = self.EquipedXianPoDic[holeId]
        -- Get a spirit soul with a higher level than the current hole level from the Never Spirit Backpack
        local bagKeys = self.BagXianPoDic:GetKeys()
        for i = 1, #bagKeys do
            local key = bagKeys[i]
            local bagItem = self.BagXianPoDic[key]
            ret = self:CanReplace(bagItem, equipItem, index, holeId)
            if ret then
                break
            end
        end
    end
    return ret
end

function XianPoSystem:CanReplace(bagItem, equipItem, index, holeId)
    local ret = false
    local haveEqualAtt = false
    if bagItem ~= nil and bagItem.Typ ~= 2 then
        -- If it's a spirit
        if equipItem == nil or (bagItem.Level > equipItem.Level and bagItem.Quality > equipItem.Quality) then
            -- If the level of the immortal soul in the backpack is higher, determine whether there are the immortal souls with the same attributes in other grids.
            for n = 1, self.HoleCount do
                local otherHole = index * 100 + n
                if otherHole ~= holeId then
                    local otherEquiptItem = self.EquipedXianPoDic[otherHole]
                    if otherEquiptItem ~= nil and otherEquiptItem.Type2 == bagItem.Type2 then
                        -- If the properties are the same and not the same hole
                        haveEqualAtt = true
                    end
                end
            end
            if not haveEqualAtt then
                -- If there are no identical properties, you can replace them
                ret = true
            end
        end
        if equipItem == nil or bagItem.Quality > equipItem.Quality or (bagItem.Quality == equipItem.Quality and bagItem.Star > equipItem.Star) then
            -- If the fairy soul in the backpack is of higher quality, judge whether there are fairy souls with the same attributes in other grids

            for n = 1, self.HoleCount do
                local otherHole = index * 100 + n
                if otherHole ~= holeId then
                    local otherEquiptItem = self.EquipedXianPoDic[otherHole]
                    if otherEquiptItem ~= nil and otherEquiptItem.Type2 == bagItem.Type2 then
                        -- If the properties are the same and not the same hole
                        haveEqualAtt = true
                    end
                end
            end
            if not haveEqualAtt then
                -- If there are no identical properties, you can replace them
                ret = true
            end
        end
        if not haveEqualAtt then
            for n = 1, self.HoleCount do
                local otherHole = index * 100 + n
                if otherHole ~= holeId then
                    local otherEquiptItem = self.EquipedXianPoDic[otherHole]
                    if otherEquiptItem ~= nil and otherEquiptItem.Type2 == bagItem.Type2 then
                        -- If the properties are the same and not the same hole
                        haveEqualAtt = true
                        break
                    end
                end
            end
        end
    end
    return ret, haveEqualAtt
end

-- Determine whether there is a spirit that can be replaced or embedded in the sword spirit corresponding to the sword spirit index.
function XianPoSystem:GetEquiptHoleList(index)
    local holeList = List:New()
    local ret = false
    for i = 1, self.HoleCount do
        -- Grid id
        -- First determine whether there are grids or not inlays
        local haveHole = false
        local holeId = index * 100 + i
        haveHole = self:GetHoleIsValid(holeId)
        if haveHole then
            haveHole = self.EquipedXianPoDic:ContainsKey(holeId)
            if haveHole then
                -- Inlaid with Spirit Souls to determine whether there is a replacement Spirit Soul
                local equipItem = self.EquipedXianPoDic[holeId]
                -- Get a spirit soul with a higher level than the current hole level from the Never Spirit Backpack
                local bagKeys = self.BagXianPoDic:GetKeys()
                for m = 1, #bagKeys do
                    local key = bagKeys[m]
                    local item = self.BagXianPoDic[key]
                    if item ~= nil and item.Typ ~= 2 then
                        haveHole = self:CanReplace(item, equipItem, index, holeId)
                        if haveHole then
                            holeList:Add(holeId)
                        end
                    end
                end
            else
                -- No inlaid spirits Check whether the spirits in the backpack can be inlaid
                local bagKeys = self.BagXianPoDic:GetKeys()
                for k = 1, #bagKeys do
                    local key = bagKeys[k]
                    local item = self.BagXianPoDic[key]
                    if item ~= nil and item.Typ ~= 2 then
                        -- If it is an attribute spirit, determine whether there is any attribute conflict with other holes.
                        haveHole = true
                        for m = 1, self.HoleCount do
                            if i ~= m then
                                local otherEquipItem = self.EquipedXianPoDic[index * 100 + m]
                                if otherEquipItem ~= nil and otherEquipItem.Type2 == item.Type2 then
                                    haveHole = false
                                end
                            end
                        end
                        if haveHole then
                            holeList:Add(holeId)
                            break
                        end
                    end
                end
            end
        end
    end
    return holeList
end

-- Return the sword spirit serial number that can be embedded at one time
function XianPoSystem:GetValidJianLingIndexs()
    self.ValidJianLingList:Clear()
    local bagKeys = self.BagXianPoDic:GetKeys()
    -- First check whether all sword spirit entries have holes that can be embedded
    local nameList = self:GetNameList()
    local activeIndex = self:GetActiveJianlingIndex()
    for i = 1, #nameList do
        local index = i
        if activeIndex >= index then
            local ret = false
            for m = 1, self.HoleCount do
                local holeId = index * 100 + i
                ret = self:HaveFreeHole(holeId)
                if ret then
                    -- No inlaid spirits Check whether the spirits in the backpack can be inlaid
                    for k = 1, #bagKeys do
                        local key = bagKeys[k]
                        local item = self.BagXianPoDic[key]
                        if item ~= nil and item.Typ ~= 2 then
                            -- If it is an attribute spirit, determine whether there is any attribute conflict with other holes.
                            for n = 1, self.HoleCount do
                                if i ~= n then
                                    local otherEquipItem = self.EquipedXianPoDic[index * 100 + n]
                                    if otherEquipItem ~= nil and otherEquipItem.Type2 == item.Type2 then
                                        ret = false
                                    end
                                end
                            end
                            if ret then
                                self.ValidJianLingList:Add(index)
                                break
                            end
                        end
                    end
                    break
                end
            end
        end
    end

    for i = 1, #bagKeys do
        local bagKey = bagKeys[i]
        local bagItem = self.BagXianPoDic[bagKey]
        -- Compare with all sword spirit entries
        for m = 1, #nameList do
            local index = m
            if activeIndex >= index then
                local ret = false
                if not self.ValidJianLingList:Contains(m) then
                    -- If there are no holes that can be inlaid, check if it is replaceable
                    ret = self:HaveBetterItem(index, bagItem)
                    if ret then
                        self.ValidJianLingList:Add(m)
                    end
                end
            end
        end
    end
    return self.ValidJianLingList
end

function XianPoSystem:GetValidJianLingStateList()
    local bagKeys = self.BagXianPoDic:GetKeys()
    local bagCount = #bagKeys
    -- First check whether all sword spirit entries have holes that can be embedded
    local activeIndex = self:GetActiveJianlingIndex()
    for i = 1, self.JianLingCount do
        local index = i
        if activeIndex >= index then
            local ret = false
            -- Get a list of tileable holes
            local freeHoleList = self:GetFreeHoleList(index)
            if #freeHoleList > 0 then
                -- There are holes that can be embedded
                ret = true
                for k = 1, bagCount do
                    local key = bagKeys[k]
                    local item = self.BagXianPoDic[key]
                    if item ~= nil and item.Typ ~= 2 then
                        -- If it is an attribute spirit, determine whether there is any attribute conflict with other holes.
                        for m = 1, self.HoleCount do
                            local otherEquipItem = self.EquipedXianPoDic[index * 100 + m]
                            if otherEquipItem ~= nil and otherEquipItem.Type2 == item.Type2 then
                                ret = false
                                break
                            end
                        end
                        if ret then
                            return true
                        end
                    end
                end
                if not ret then
                    -- Can't inlay judge whether there is a better spirit
                    for k = 1, bagCount do
                        local bagKey = bagKeys[k]
                        local bagItem = self.BagXianPoDic[bagKey]
                        ret = self:HaveBetterItem(index, bagItem)
                        if ret then
                            return true
                        end
                    end
                end
            else
                -- No holes to be inlaid
                for k = 1, bagCount do
                    local bagKey = bagKeys[k]
                    local bagItem = self.BagXianPoDic[bagKey]
                    ret = self:HaveBetterItem(index, bagItem)
                    if ret then
                        return true
                    end
                end
            end
            -- Determine if there is any upgradeable
            for m = 1, self.HoleCount do
                local holeId = index * 100 + m
                if self:GetHoleIsValid(holeId) then
                    if self:IsIndexXianPoCanUpgrade(holeId) then
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- Get a list of tileable holes
function XianPoSystem:GetFreeHoleList(index)
    local list = List:New()
    for m = 1, self.HoleCount do
        local holeId = index * 100 + m
        local ret = self:HaveFreeHole(holeId)
        if ret then
            list:Add(holeId)
        end
    end
    return list
end

-- Determine whether there are free holes
function XianPoSystem:HaveFreeHole(holeId)
    local ret = false
    -- First determine whether the hole is available
    ret = self:GetHoleIsValid(holeId)
    if ret then
        -- If this hole is valid, determine whether the spirit soul is equipped
        if self.EquipedXianPoDic:ContainsKey(holeId) then
            ret = false
        end
    end
    return ret
end

-- Determine whether there are more advanced spirits
function XianPoSystem:HaveBetterItem(index, bagItem)
    local ret = false
    for k = 1, self.HoleCount do
        local holeId = index * 100 + k
        -- Determine whether the current hole is activated
        if self:GetHoleIsValid(holeId) then
            local equipItem = self.EquipedXianPoDic[holeId]
            -- Get a spirit soul with a higher level than the current hole level from the Never Spirit Backpack
            if bagItem ~= nil and bagItem.Typ ~= 2 then
                -- If it's a spirit
                ret = self:CanReplace(bagItem, equipItem, index, holeId)
                if ret then
                    break
                end
            end
        end
    end
    return ret
end

-- Determine whether there is a better quality spirit
function XianPoSystem:HaveBetterQualityItem(index, bagItem)
    local ret = false
    for k = 1, self.HoleCount do
        local holeId = index * 100 + k
        -- Determine whether the current hole is activated
        if self:GetHoleIsValid(holeId) then
            local equipItem = self.EquipedXianPoDic[holeId]
            -- Get a spirit soul with a higher level than the current hole level from the Never Spirit Backpack
            if bagItem ~= nil and bagItem.Typ ~= 2 then
                -- If it's a spirit
                if bagItem.Quality > equipItem.Quality then
                    -- If the level of the immortal soul in the backpack is higher, determine whether there are the immortal souls with the same attributes in other grids.
                    local haveEqualAtt = false
                    local equipedKeys = self.EquipedXianPoDic:GetKeys()
                    for n = 1, self.HoleCount do
                        if n ~= k then
                            local otherEquiptItem = self.EquipedXianPoDic[equipedKeys[n]]
                            if otherEquiptItem ~= nil and otherEquiptItem.Type2 == bagItem.Type2 then
                                -- If the properties are the same and not the same hole
                                haveEqualAtt = true
                            end
                        end
                    end
                    if not haveEqualAtt then
                        -- If there are no identical properties, you can replace them
                        ret = true
                        break
                    end
                end
            end
        end
    end
    return ret
end

-- Get whether the Spirit Soul Inlay Grid is activated
function XianPoSystem:GetHoleIsValid(holeId)
    local ret = false
    local dic = self:GetHoleDataDic()
    if dic ~= nil then
        local data = dic[holeId]
        if data ~= nil then
            ret = self.JianLingGeLevel > data.ActiveLv
        end
    end
    return ret
end

-- Get total data
function XianPoSystem:GetViewData()
    if self.ViewDic:Count() == 0 then
        DataConfig.DataImmortalSoulAttribute:Foreach(function(key, value)
            if value.OverviewConditions ~= nil and value.OverviewConditions ~= "" then
                local params = Utils.SplitNumber(value.OverviewConditions, "_")
                local floor = params[1]
                local row = params[2]
                local col = params[3]
                local subDic = self.ViewDic[floor]
                if subDic ~= nil then
                    local list = subDic[row]
                    if list ~= nil then
                        list:Add(key)
                    else
                        list = List:New()
                        list:Add(key)
                        subDic:Add(row, list)
                    end
                else
                    local list = List:New()
                    list:Add(key)
                    subDic = Dictionary:New()
                    subDic:Add(row, list)
                    self.ViewDic:Add(floor, subDic)
                end
            end
        end)
    end
    return self.ViewDic
end

function XianPoSystem:GetAllItemDic()
    local index = 0
    local retDic = Dictionary:New()
    local dic = self:GetViewData()
    local keys = dic:GetKeys()
    keys:Sort(function(a, b)
        return a < b
    end)
    for i = 1, #keys do
        if self.JianLingGeLevel > keys[i] then
            local floorDic = dic[keys[i]]
            if floorDic ~= nil then
                local floorKeys = floorDic:GetKeys()
                for m = 1, #floorKeys do
                    local list = floorDic[floorKeys[m]]
                    if list ~= nil then
                        retDic:Add(index, list)
                        index = index + 1
                    end
                end
            end
        end
    end
    return retDic
end

function XianPoSystem:AddBag(uId, data)
    if data == nil then
        return
    end
    local _soul = self.BagXianPoDic[uId]
    if _soul == nil then
        self.BagXianPoDic:Add(uId, data)
        self.BagSoulCount = self.BagSoulCount + 1
    else
        self.BagXianPoDic[uId] = data
    end
    local _soulCount = self.SoulBagDic[data.CfgId]
    if _soulCount == nil then
        self.SoulBagDic[data.CfgId] = 1
    else
        self.SoulBagDic[data.CfgId] = _soulCount + 1
    end
end

function XianPoSystem:RemoveBag(uId)
    local _soul = self.BagXianPoDic[uId]
    if _soul ~= nil then
        self.BagXianPoDic:Remove(uId)
        self.BagSoulCount = self.BagSoulCount - 1
        local _soulCount = self.SoulBagDic[_soul.CfgId]
        if _soulCount ~= nil and _soulCount > 0 then
            self.SoulBagDic[_soul.CfgId] = _soulCount - 1
        end
    end
end

function XianPoSystem:GetAnalyseXianPo()
    local _list = List:New()
    if self.BagXianPoDic ~= nil then
        local _keys = self.BagXianPoDic:GetKeys()
        if _keys ~= nil then
            for i = 1, #_keys do
                local _xianPo = self.BagXianPoDic[_keys[i]]
                if _xianPo.Quality >= 4 and _xianPo.Star >= 2 then
                    _list:Add(_xianPo)
                end
            end
        end
    end
    return _list
end

function XianPoSystem:GetDecomposeXianPo()
    local _list = List:New()
    if self.BagXianPoDic ~= nil then
        local _keys = self.BagXianPoDic:GetKeys()
        if _keys ~= nil then
            for i = 1, #_keys do
                local _xianPo = self.BagXianPoDic[_keys[i]]
                if _xianPo.Quality >= 4 and _xianPo.Star >= 2 then
                else
                    _list:Add(_xianPo)
                end
            end
        end
    end
    return _list
end

-- Heartbeat
function XianPoSystem:Update(dt)
    local isShow = false
    -- Check if there is an activated sword spirit every 0.5 seconds
    if self.CheckTime > 0 then
        self.CheckTime = self.CheckTime - dt
    else
        self.CheckTime = 1
        -- Check whether there are red dots inlaid with spirit souls
        local isShow = self:GetValidJianLingStateList()
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.XianPoInlay, isShow)
    end

    if self.IsLingPoChange then
        self.IsShowSynRedPoint = self:SetXianPoSyntheticRedPoint()
        if self.preShowSynRedPoint ~= self.IsShowSynRedPoint then
            GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.XianPoSynthetic, self.IsShowSynRedPoint)
            self.preShowSynRedPoint = self.IsShowSynRedPoint
        end

        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_XIANPO_EXCHANGE)
        self:SetXianPoDecompositionRedPoint()
        local isShow = self:GetValidJianLingStateList()
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.XianPoInlay, isShow)
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LINGPO_EXCHANGE)
        self.IsLingPoChange = false
    end

    -- Check the decomposition
    -- Check the conversation
    -- Check the synthesis
end

-- Initialize all immortal souls online
function XianPoSystem:ResAllImmortalSoul(msg)
    if msg.soulEquipmentList then
        for i = 1, #msg.soulEquipmentList do
            local _xianPoInfos = msg.soulEquipmentList[i]
            local _data = XianPoData:New()
            _data:SetAllData(_xianPoInfos)
            if not self.EquipedXianPoDic:ContainsKey(_xianPoInfos.location) then
                self.EquipedXianPoDic:Add(_xianPoInfos.location, _data)
            end
        end
    end
    if msg.soulBagList then
        for i = 1, #msg.soulBagList do
            local _xianPoInfos = msg.soulBagList[i]
            local _data = XianPoData:New()
            _data:SetAllData(_xianPoInfos)
            if not self.BagXianPoDic:ContainsKey(_xianPoInfos.uid) then
                self:AddBag(_xianPoInfos.uid, _data)
            end
        end
    end
    -- self:SetXianPoDecompositionRedPoint()
    self:LingPoChange()
end

-- Request to inlay the immortal soul, location = location
function XianPoSystem:ReqInlaySoul(uid, location)
    local _req = ReqMsg.MSG_ImmortalSoul.ReqInlaySoul:New()
    _req.soulUID = uid
    _req.location = location
    _req:Send()
end

-- Feedback of the results of the inlayed immortal soul
function XianPoSystem:ResInlaySoulReuslt(msg)
    if msg.isSucceed then
        local _inlayIndex = -1
        for i = 1, #msg.soulInlayList do
            local _xianPoInfos = msg.soulInlayList[i]
            local _data = XianPoData:New()
            _data:SetAllData(_xianPoInfos)
            if _xianPoInfos.location ~= 0 then
                _inlayIndex = _xianPoInfos.location
                -- If not on the backpack (wearing on the body)
                -- Replace the immortal soul on your body first
                if self.EquipedXianPoDic:ContainsKey(_xianPoInfos.location) then
                    self.EquipedXianPoDic[_xianPoInfos.location] = _data
                else
                    self.EquipedXianPoDic:Add(_xianPoInfos.location, _data)
                end
                -- Delete the fairy soul in the backpack
                if self.BagXianPoDic:ContainsKey(_xianPoInfos.uid) then
                    self:RemoveBag(_xianPoInfos.uid)
                end
            else
                -- If it's in a backpack, add it to the backpack
                if not self.BagXianPoDic:ContainsKey(_xianPoInfos.uid) then
                    self:AddBag(_xianPoInfos.uid, _data)
                end
            end
            -- Send a message about the change of fairy soul in the backpack
            -- GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_XIANPO_BAG_ITEM_CHANGED, _xianPoInfos.CfgId)
        end
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_XIANPOINFO_REFRESH, _inlayIndex)
        Utils.ShowPromptByEnum("InlaySucced")
        -- self:SortBagXianPoDic()
        -- self:SetXianPoInlayRedPoint()
        -- self:SetXianPoDecompositionRedPoint()
        self:LingPoChange()
    end
end

-- Request to decompose the immortal soul
function XianPoSystem:ReqResolveSoul(uidList)
    local _req = ReqMsg.MSG_ImmortalSoul.ReqResolveSoul:New()
    _req.uids = uidList
    _req:Send()
end

-- Decompose the immortal soul and return
function XianPoSystem:ResResolveSoulReuslt(msg)
    if msg.isSucceed then
        for i = 1, #msg.uids do
            local _data = self.BagXianPoDic[msg.uids[i]]
            if _data ~= nil then
                local _cfgId = _data.CfgId
                self:RemoveBag(msg.uids[i])
                -- GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_XIANPO_BAG_ITEM_CHANGED, _cfgId)
            end
        end
        Utils.ShowPromptByEnum("ResolveSucceed")
        -- self:SortBagXianPoDic()
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_XIANPO_DECOMPOSITION)
        -- self:SetXianPoInlayRedPoint()
        -- self:SetXianPoDecompositionRedPoint()
        self:LingPoChange()
    end
end

-- Request for the upgrade of the fairy soul
function XianPoSystem:ReqUpSoul(location)
    local _req = ReqMsg.MSG_ImmortalSoul.ReqUpSoul:New()
    _req.location = location
    _req:Send()
end

-- Immortal Soul Upgrade Return
function XianPoSystem:ResUpSoulReuslt(msg)
    if msg.isSucceed then
        local _data = XianPoData:New()
        _data:SetAllData(msg.soul)
        if self.EquipedXianPoDic:ContainsKey(_data.Location) then
            self.EquipedXianPoDic[_data.Location] = _data
        end
        Utils.ShowPromptByEnum("LevelUpSucceed")
        -- self:SortBagXianPoDic()
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_XIANPOINFO_REFRESH, _data.Location)
        -- self:SetXianPoInlayRedPoint()
        self:LingPoChange()
    end
end

-- Request for exchange for the immortal soul
function XianPoSystem:ReqExchangeSoul(cfgId, num)
    local _req = ReqMsg.MSG_ImmortalSoul.ReqExchangeSoul:New()
    _req.itemId = cfgId
    _req.num = num
    _req:Send()
end

-- Fairy Soul Redeem Return
function XianPoSystem:ResExchangeSoulReuslt(msg)
    if msg.isSucceed then
        local _reason = msg.reason or 0
        local _data = XianPoData:New()
        _data:SetAllData(msg.soul)
        if not self.BagXianPoDic:ContainsKey(_data.Uid) then
            self:AddBag(_data.Uid, _data)
            -- Increase the effect of spiritual soul acquisition
            GameCenter.GetNewItemSystem:AddShowItem(_reason, nil, _data.CfgId, 1);
        end
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_XIANPOINFO_REFRESH, 0)
        self:LingPoChange()
    end
end

-- Request to synthesize the immortal soul
function XianPoSystem:ReqCompoundSoul(cfgId)
    self.ReqCompoundCfgId = cfgId
    local _req = ReqMsg.MSG_ImmortalSoul.ReqCompoundSoul:New()
    _req.itemId = cfgId
    _req:Send()
end

-- Synthetic immortal soul return
function XianPoSystem:ResCompoundSoulReuslt(msg)
    if msg.isSucceed then
        local _data = XianPoData:New()
        _data:SetAllData(msg.soul)
        if not self.BagXianPoDic:ContainsKey(_data.Uid) then
            self:AddBag(_data.Uid, _data)
            GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_XIANPO_BAG_ITEM_CHANGED, _data.CfgId)
        end
        for i = 1, #msg.deleteUid do
            if self.BagXianPoDic:ContainsKey(msg.deleteUid[i]) then
                local _cfgId = self.BagXianPoDic:Get(msg.deleteUid[i]).CfgId
                self:RemoveBag(msg.deleteUid[i])
                GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_XIANPO_BAG_ITEM_CHANGED, _cfgId)
            end
        end
        Utils.ShowPromptByEnum("CompoundSucceed", _data.Name)
        self:SortBagXianPoDic()
        -- self:SetXianPoDecompositionRedPoint()
        -- GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_XIANPO_SYNTHETIC, _data.CfgId)
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_XIANPO_SYNTHETIC, {
            id = _data.CfgId,
            success = true
        })
        -- self:SetXianPoInlayRedPoint()
    else
        for i = 1, #msg.deleteUid do
            if self.BagXianPoDic:ContainsKey(msg.deleteUid[i]) then
                local _cfgId = self.BagXianPoDic:Get(msg.deleteUid[i]).CfgId
                self:RemoveBag(msg.deleteUid[i])
                GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_XIANPO_BAG_ITEM_CHANGED, _cfgId)
            end
        end
        self:SortBagXianPoDic()
        -- self:SetXianPoDecompositionRedPoint()
        -- GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_XIANPO_SYNTHETIC, self.ReqCompoundCfgId)
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_XIANPO_SYNTHETIC, {
            id = self.ReqCompoundCfgId,
            success = false
        })
        -- self:SetXianPoInlayRedPoint()
    end
    self:LingPoChange()

end

-- Request to take off the fairy soul
function XianPoSystem:ReqGetOffSoul(location)
    local _req = ReqMsg.MSG_ImmortalSoul.ReqGetOffSoul:New()
    _req.location = location
    _req:Send()
end

-- Take off the fairy soul and return
function XianPoSystem:ResGetOffReuslt(msg)
end

-- ===================== Red dot function=============--
-- Spiritual backpack changes
function XianPoSystem:LingPoChange()
    if not self.IsLingPoChange then
        self.IsLingPoChange = true
    end
end
-- Set the red dots inlaid with fairy souls
function XianPoSystem:SetXianPoInlayRedPoint()
    local _haveRedPoint = false
    self.ListRedPointIds:Clear()
    if self:IsCanInlayXianPo() or self:IsEquipXianPoCanUpgrade() then
        _haveRedPoint = true
    end
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.XianPoInlay, _haveRedPoint)
    self:SetXianPoSyntheticRedPoint()
end

-- Set up the red dots of the fairy soul synthesis
function XianPoSystem:SetXianPoSyntheticRedPoint()
    local _haveRedPoint = false
    local _cache = Dictionary:New()
    local _synKeys = self.XianPoSyntheticDic:GetKeys()
    for m = 1, #_synKeys do
        local _value = self.XianPoSyntheticDic[_synKeys[m]]
        local _needList = _value.NeedXianPoIdCountList
        local _isShow = true
        for i = 1, #_needList do
            local _cfgId = _needList[i].Id
            local _haveCount = 0
            local _needNum = _needList[i].NeedNum
            local _cacheData = _cache[_needList[i].Id]
            if _cacheData == nil then
                _cacheData = {Id = _cfgId, Left = self:GetXianPoCountByCfgId(_cfgId)}
                _cache:Add(_cfgId, _cacheData)
            end
            _haveCount = _cacheData.Left
            if _haveCount < _needNum then
                _isShow = false
                break
            end
            _cacheData.Left = _haveCount > _needNum and _haveCount - _needNum or 0
        end
        if _isShow then
            local _itemCount = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(_value.NeedItemId)
            if _itemCount < _value.NeedItemNum then
                _isShow = false
            end
            if self.JianLingGeLevel <= _value.Limit then
                _isShow = false
            end
        end
        if _isShow then
            _haveRedPoint = true
            break
        end
    end
    return _haveRedPoint
end

function XianPoSystem:GetSyntheticRedPointList()
    local list = List:New()
    local _cache = Dictionary:New()
    local _haveRedPoint = false
    self.XianPoSyntheticDic:ForeachCanBreak(function(_, _value)
        local id = _
        local _needList = _value.NeedXianPoIdCountList
        local isShow = true
        for i = 1, #_needList do
            local _haveCount = 0
            local _cacheData = _cache[_needList[i].Id]
            if _cacheData == nil then
                _cacheData = {Id = _needList[i].Id, Left = self:GetXianPoCountByCfgId(_needList[i].Id)}
                _cache:Add(_needList[i].Id, _cacheData)
            end
            _haveCount = _cacheData.Left
            if _haveCount < _needList[i].NeedNum then
                isShow = false
            end
            _cacheData.Left = _haveCount > _needList[i].NeedNum and _haveCount - _needList[i].NeedNum or 0
        end
        local _haveCount = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(_value.NeedItemId)
        if _haveCount < _value.NeedItemNum then
            isShow = false
        end
        if self.JianLingGeLevel <= _value.Limit then
            isShow = false
        end
        if isShow then
            _haveRedPoint = true
            list:Add(id)
        end
    end)
    return list
end

-- Determine whether all positions are empty and can be embedded in the immortal soul
function XianPoSystem:IsCanInlayXianPo()
    local _ret = false
    for i = 1, self.XianPoMaxInlayIndex do
        if self:IsIndexEmptyCanInlay(i) then
            _ret = true
            break
        end
    end
    return _ret
end

-- Determine whether a position is empty and there is a corresponding fairy soul in the backpack that can be embedded
function XianPoSystem:IsIndexEmptyCanInlay(index)
    local _canInlay = false
    if self:IsIndexUnlock(index) then
        -- This location is unlocked
        if self:GetXianPoDataByIndex(index) == nil then
            -- There is no inlay of immortal soul in this location, and it traverses the immortal soul in the backpack
            self.BagXianPoDic:ForeachCanBreak(function(key, value)
                if value.CanInlayLocationList:Contains(index) then
                    -- If this immortal soul can be embedded in this grid
                    _canInlay = true
                    return true
                end
            end)
        end
    end
    return _canInlay
end

-- Determine whether the immortal souls in all positions can be upgraded
function XianPoSystem:IsEquipXianPoCanUpgrade()
    local _ret = false
    for i = 1, self.XianPoMaxInlayIndex do
        if self:IsIndexXianPoCanUpgrade(i) then
            _ret = true
            break
        end
    end
    return _ret
end

-- Determine whether the immortal soul in a position can be upgraded
function XianPoSystem:IsIndexXianPoCanUpgrade(index)
    local _canUpgrade = false
    local _data = self:GetXianPoDataByIndex(index)
    if _data then
        local _nextLvNeedExp = self:GetNextLvNeedExp(_data.Quality, _data.Level)
        local _myExp = GameCenter.ItemContianerSystem:GetEconomyWithType(ItemTypeCode.LingPoJc)
        if _myExp >= _nextLvNeedExp and _data.Level < _data.MaxLevel then
            _canUpgrade = true
            self.ListRedPointIds:Add(_data.CfgId)
        end
    end
    return _canUpgrade
end

-- Set the red dots of the decomposition of the immortal soul
function XianPoSystem:SetXianPoDecompositionRedPoint()
    local _haveRedPoint = false
    self.BagXianPoDic:ForeachCanBreak(function(key, value)
        if value.Typ == 2 then
            -- It's the fairy spirit of experience
            _haveRedPoint = true
            return true
        else
            -- It's not an experience immortal soul, judge whether it's blue
            if value.Quality == XianPoQuality.Blue then
                _haveRedPoint = true
                return true
            end
        end
    end)
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.XianPoDecomposition, _haveRedPoint)
end

-- ============================--
-- Get whether the location has been embedded with fairy souls
-- function XianPoSystem:IsHaveXianPoByIndex(index)
--     local _ret = false
--     if self.EquipedXianPoDic:ContainsKey(index) then
--         if self.EquipedXianPoDic[index].Uid > 0 then
--             _ret = true
--         end
--     end
--     return _ret
-- end

-- Determine whether the location is unlocked
function XianPoSystem:IsIndexUnlock(index)
    local _unLockCfg = DataConfig.DataImmortalSoulIattice[index]
    if _unLockCfg then
        local _variableSystem = GameCenter.VariableSystem
        local _unLockCondition = Utils.SplitNumber(_unLockCfg.Condition, "_")
        return _variableSystem.IsVariableReach(_unLockCondition[1], _unLockCondition[2])
    end
    return false
end

-- Obtain the immortal soul of the location according to the location
function XianPoSystem:GetXianPoDataByIndex(index)
    local _ret = nil
    if self.EquipedXianPoDic:ContainsKey(index) then
        _ret = self.EquipedXianPoDic[index]
    end
    return _ret
end

-- Obtain a certain immortal soul in the backpack based on uid
function XianPoSystem:GetBagXianPoDataByUID(uid)
    local _ret = nil
    if self.BagXianPoDic:ContainsKey(uid) then
        _ret = self.BagXianPoDic[uid]
    end
    return _ret
end

-- According to the configuration table id, get how many immortal souls there are in the backpack with this id
function XianPoSystem:GetXianPoCountByCfgId(cfgId)
    local _count = self.SoulBagDic[cfgId]
    if _count == nil then
        _count = 0
    end
    return _count
end

-- According to the configuration table id, determine whether the current body has the same attributes.
-- prams:cfgId Xianpo configuration table ID in the backpack
function XianPoSystem:IsHaveSameAttrXianPo(cfgId, selectIndex)
    if selectIndex == nil then
        return false
    end
    local _have = false
    -- According to the configuration table Type2, it is used to determine whether the mutual exclusion of immortal souls is equal. If type2 is equal, it is the same type of immortal soul and cannot be worn.
    local _cfg = DataConfig.DataImmortalSoulAttribute
    -- Experience fairy soul
    local _curType1 = 1
    -- Props Immortal Soul
    local _curType2 = 0
    if _cfg:IsContainKey(cfgId) then
        _curType1 = _cfg[cfgId].Type
        _curType2 = _cfg[cfgId].Type2
    end
    local _selectedData = self:GetXianPoDataByIndex(selectIndex)
    -- Equipped fairy soul
    self.EquipedXianPoDic:ForeachCanBreak(function(key, value)
        -- 1. Has a mutually exclusive ID, cannot be equipped
        if value.MutexIdList:Contains(cfgId) then
            _have = true
            return true
        end
        -- 3. Clicks without plaids, handle two special positions separately. Those not 9 and 10 cannot be clicked as long as there is no inside the backpack.
        if _selectedData == nil then
            if selectIndex == 9 and _curType2 ~= 9 then
                _have = true
                return true
            elseif selectIndex == 10 and _curType2 ~= 10 then
                _have = true
                return true
            end
            -- When inlaying, determine whether it is a special immortal soul
            if selectIndex < 9 and _curType2 >= 9 then
                _have = true
                return true
            end
            if value.Type2 == _curType2 then
                _have = true
                return true
            end
        else
            -- 4. Comparison of the selected one that needs to be replaced with the backpack
            if _selectedData.Type2 == _curType2 then
                -- No higher attributes
                if not self:CheckChangeBtnRedPoint(cfgId) then
                    _have = true
                    return true
                end
                -- 5. The two special types in the middle are judged separately
            elseif _selectedData.Type2 == 9 or _selectedData.Type2 == 10 and value.Type2 < _selectedData.Type2 then
                _have = true
                return true
                -- 6. When replacing, determine whether it is a special immortal soul.
            elseif selectIndex < 9 and _curType2 >= 9 then
                _have = true
                return true
                -- This one that has been equipped has the same type of fairy soul as in the backpack
            elseif value.Type2 == _curType2 then
                _have = true
                return true
            end
        end
    end)
    -- 7. Experience immortal soul cannot be equipped
    if _curType1 > 1 then
        _have = true
    end
    -- 8. Nothing is equipped yet, judge the specific one
    if _selectedData == nil then
        if selectIndex == 9 and _curType2 ~= 9 then
            _have = true
        elseif selectIndex == 10 and _curType2 ~= 10 then
            _have = true
        end
        -- When inlaying, determine whether it is a special immortal soul
        if selectIndex < 9 and _curType2 >= 9 then
            _have = true
            return true
        end
    end
    return _have
end

-- Replace the red dot of the button
function XianPoSystem:CheckChangeBtnRedPoint(cfgId)
    local _cfg = DataConfig.DataImmortalSoulAttribute
    local _curCfg = nil
    if _cfg:IsContainKey(cfgId) then
        _curCfg = _cfg[cfgId]
    end
    local _haveRedPoint = false
    local _totalAttr = 0
    local _curTotalAttr = 0
    self.BagXianPoDic:ForeachCanBreak(function(key, _bagValue)
        -- Comparison attributes of the same type of immortal soul can be seen if they can be replaced
        if _bagValue.Type2 == _curCfg.Type2 then
            _bagValue.TotalAddAttrDic:Foreach(function(_id, _attr)
                _totalAttr = _totalAttr + _attr
            end)
            local _cfgId = _curCfg.Id
            self.EquipedXianPoDic:ForeachCanBreak(function(key, _equipedValue)
                if _equipedValue.CfgId == _curCfg.Id then
                    _equipedValue.TotalAddAttrDic:ForeachCanBreak(
                        function(_id, _attr)
                            _curTotalAttr = _curTotalAttr + _attr
                            -- return true
                        end)
                    return true
                end
            end)
            if _totalAttr > _curTotalAttr then
                _haveRedPoint = true
                return true
            end
        end
    end)
    return _haveRedPoint
end

-- Uninstalled card slot red dot processing
function XianPoSystem:CheckUnEquipXianPoRedPoint()
    local _count = 0
    -- Equipped fairy soul
    local _equipDict = GameCenter.XianPoSystem.EquipedXianPoDic
    -- The fairy soul inside the backpack
    local _bagDict = GameCenter.XianPoSystem.BagXianPoDic
    local _typeList = List:New()
    -- All types of equipment immortal soul
    _equipDict:Foreach(function(_key, _value)
        if not _typeList:Contains(_value.Type2) then
            _typeList:Add(_value.Type2)
        end
    end)
    _bagDict:ForeachCanBreak(function(_key, _value)
        -- Immortal Soul is not equipped and not experienced
        if not _typeList:Contains(_value.Type2) and _value.Typ ~= 2 then
            _count = _count + 1
        end
    end)
    return _count
end

-- Get the preview interface's condition name
function XianPoSystem:GetOverviewFormConditionName(value)
    if value == 0 then
        return DataConfig.DataMessageString.Get("UnlockDefault")
    else
        local _text = GameCenter.VariableSystem.GetVariableShowText(self.GetXianPoConditionType, value)
        return UIUtils.CSFormat(DataConfig.DataMessageString.Get("UnlockByThroughPass"), _text)
    end
end

-- Obtain the experience required to advance to the next level based on quality and level
function XianPoSystem:GetNextLvNeedExp(quality, level)
    local _ret = 0
    local _cfg = DataConfig.DataImmortalSoulExp[level]
    if _cfg then
        if quality == XianPoQuality.Blue then
            -- blue
            local _exp = Utils.SplitNumber(_cfg.BlueExp, "_")
            _ret = _exp[1]
        elseif quality == XianPoQuality.Purple then
            -- Purple
            local _exp = Utils.SplitNumber(_cfg.VioletExp, "_")
            _ret = _exp[1]
        elseif quality == XianPoQuality.Gold then
            -- gold
            local _exp = Utils.SplitNumber(_cfg.GoldenExp, "_")
            _ret = _exp[1]
        elseif quality == XianPoQuality.Red then
            -- red
            local _exp = Utils.SplitNumber(_cfg.GulesExp, "_")
            _ret = _exp[1]
        end
    end
    return _ret
end

-- Obtain the total experience of the current level based on quality and level
function XianPoSystem:GetCurLvTotalExp(quality, level)
    local _ret = 0
    local _cfg = DataConfig.DataImmortalSoulExp[level]
    if _cfg then
        if quality == XianPoQuality.Blue then
            -- blue
            local _exp = Utils.SplitNumber(_cfg.BlueExp, "_")
            _ret = _exp[2]
        elseif quality == XianPoQuality.Purple then
            -- Purple
            local _exp = Utils.SplitNumber(_cfg.VioletExp, "_")
            _ret = _exp[2]
        elseif quality == XianPoQuality.Gold then
            -- gold
            local _exp = Utils.SplitNumber(_cfg.GoldenExp, "_")
            _ret = _exp[2]
        elseif quality == XianPoQuality.Red then
            -- red
            local _exp = Utils.SplitNumber(_cfg.GulesExp, "_")
            _ret = _exp[2]
        end
    end
    return _ret
end

-- Obtain the type name of the immortal soul of this type according to the type, 1: Attribute immortal soul, 2: Experience immortal soul
function XianPoSystem:GetXianPoTypeName(typ)
    if typ == 1 then
        return "PropertyXianPo"
    elseif typ == 2 then
        return "PropertyExp"
    else
        return "PropertyXianPo"
    end
end

-- =================== Functional function==============--
-- Sorting the fairy spirits in the backpack
function XianPoSystem:SortBagXianPoDic()
    self.BagXianPoDic:SortValue(function(a, b)
        if a.Quality == b.Quality then
            if a.Level == b.Level then
                return a.CfgId < b.CfgId
            else
                return a.Level > b.Level
            end
        else
            return a.Quality > b.Quality
        end
    end)
end

-- Set Immortal Icons
function XianPoSystem:SetXianPoIcons(trans, cfgId)
    -- Background quality boxes may be added later
    local _cfg = DataConfig.DataImmortalSoulAttribute[cfgId]
    local _uiIcon = UIUtils.RequireUIIconBase(trans)
    local _qualitySpr = UIUtils.FindSpr(trans, "Quality")
    if _uiIcon and _cfg then
        _uiIcon:UpdateIcon(_cfg.Icon)
        _qualitySpr.spriteName = Utils.GetQualitySpriteName(tonumber(_cfg.Quality))
    end
end

-- Set the tips of the immortal soul
function XianPoSystem:SetXianPoTips(trans, cfgId)
    local _tipsRoot = UIUtils.FindTrans(trans, "Tips")
    local _iconTrs = UIUtils.FindTrans(_tipsRoot, "Icon")
    self:SetXianPoIcons(_iconTrs, cfgId)
    local _cfg = DataConfig.DataImmortalSoulAttribute[cfgId]
    if _cfg then
        -- name
        local _nameLab = UIUtils.FindLabel(_tipsRoot, "Name")
        UIUtils.SetTextByStringDefinesID(_nameLab, _cfg._Name)
        -- grade
        -- local _levelLab = UIUtils.FindLabel(_tipsRoot, "Level")
        -- type
        local _typeLab = UIUtils.FindLabel(_tipsRoot, "Type")
        UIUtils.SetTextByEnum(_typeLab, self:GetXianPoTypeName(_cfg.Type))
        -- property
        local _attrCloneGo = UIUtils.FindGo(_tipsRoot, "AttrClone")
        local _attrCloneRoot = UIUtils.FindTrans(_tipsRoot, "AttrCloneGrid")
        local _attrCloneRootGrid = UIUtils.FindGrid(_tipsRoot, "AttrCloneGrid")
        -- Hide all attributes first
        for i = 0, _attrCloneRoot.childCount - 1 do
            _attrCloneRoot:GetChild(i).gameObject:SetActive(false)
        end
        if _cfg.DemandValue and _cfg.DemandValue ~= "" then
            local _attrList = Utils.SplitStrByTableS(_cfg.DemandValue)
            for i = 1, #_attrList do
                local _go
                if i - 1 < _attrCloneRoot.childCount then
                    _go = _attrCloneRoot:GetChild(i - 1).gameObject
                else
                    _go = UnityUtils.Clone(_attrCloneGo, _attrCloneRoot)
                end
                local _label = UIUtils.FindLabel(_go.transform)
                UIUtils.SetTextByPropNameAndValue(_label, _attrList[i][1], _attrList[i][2])
                _go:SetActive(true)
            end
        end
        _attrCloneRootGrid.repositionNow = true
        -- How to get it
        local _getMethodLab = UIUtils.FindLabel(_tipsRoot, "GetMethod")
        UIUtils.SetTextByString(_getMethodLab, self:GetOverviewFormConditionName(_cfg.OverviewConditions))
    end
end

function XianPoSystem:GetCoreDic()
    if self.DicJianCore == nil then
        self.DicJianCore = Dictionary:New()
        DataConfig.DataImmortalSoulCore:Foreach(function(k, v)
            local _data = L_JianCore:New()
            _data.JianId = k
            self.DicJianCore:Add(k,_data)
        end)
    end
    return self.DicJianCore
end

function XianPoSystem:GetJianCoreData(index)
    local _ret = nil
    local _dic = self:GetCoreDic()
    if _dic ~= nil then
        _ret = _dic[index]
    end
    return _ret
end

function XianPoSystem:GetJianValid(index)
    local _ret = false
    local _jianCore = nil
    local _dic = self:GetCoreDic()
    if _dic ~= nil then
        _jianCore = _dic[index]
        if _jianCore ~= nil then
            _ret = _jianCore:GetJianValid()
        end
    end
    return _ret
end

function XianPoSystem:GetJianName(index)
    local _ret = ""
    for i = 1, #self.JianLingList do
        if index == i then
            _ret = self.JianLingList[i]
            break
        end
    end
    return _ret
end

-- Obtain the level of all equipment immortal souls
function XianPoSystem:GetAllEquipLv(index)
    local _ret = 0
    local _keys = self.EquipedXianPoDic:GetKeys()
    for i = 1, #_keys do
        local _key = _keys[i]
        if math.floor( _key / 100 ) == index then
            local _data = self.EquipedXianPoDic[_key]
            if _data ~= nil then
                _ret = _ret + _data.Level
            end
        end
    end
    return _ret
end

-- Get activation conditions
function XianPoSystem:GetJianActiveDes(index)
    local _ret = ""
    local _lv = 0
    local _jianName = ""
    local _preJianName = ""
    local _coreName = ""
    local _cfg = DataConfig.DataGlobal[GlobalName.immortal_soul_core_limit]
    if _cfg  ~= nil then
        local _list = Utils.SplitStr(_cfg.Params, ';')
        if _list ~= nil then
            for i = 1, #_list do
                local _values = Utils.SplitNumber(_list[i], '_')
                if _values ~= nil then
                    if _values[1] == index then
                        _lv = _values[2]
                        break
                    end
                end
            end
        end
    end
    local _nameList = self:GetNameList()
    if _nameList ~= nil then
        if index <= #_nameList then
            _jianName = _nameList[index]
        end
        if index - 1 > 0 and index - 1 <= #_nameList then
            _preJianName = _nameList[index - 1]
        end
    end
    local _preCfg = DataConfig.DataImmortalSoulCore[index - 1]
    if _preCfg ~= nil then
        _coreName = _preCfg.Name
    end
    _ret = UIUtils.CSFormat(DataConfig.DataMessageString.Get("LING_PO_CORE_open_next"), _coreName, _lv, _jianName)
    return _ret
end

function XianPoSystem:ResSoulCore(msg)
    if msg == nil then
        return
    end
    local _dic = self:GetCoreDic()
    if _dic ~= nil then
        if msg.info ~= nil then
            for i = 1, #msg.info do
                local _data = _dic[i]
                _data.JianId = i
                _data.CoreId = msg.info[i].core
            end
        end
    end
end

function XianPoSystem:ResSoulCoreUpdate(msg)
    if msg == nil then
        return
    end
    local _dic = self:GetCoreDic()
    if _dic == nil then
        return
    end
    local _data = _dic[msg.info.type]
    if _data ~= nil then
        _data.CoreId = msg.info.core
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LINGPO_CORE_LV_RESULT)
end

function XianPoSystem:ReqDismountingSoul(id)
    GameCenter.Network.Send("MSG_ImmortalSoul.ReqDismountingSoul", {
        uid = id
    })
end

function XianPoSystem:ResDismountingSoulReuslt(msg)
    if msg == nil then
        return
    end
    if msg.isSucceed then
        self:RemoveBag(msg.uid)
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_XIANPO_DECOMPOSITION)
end

return XianPoSystem
