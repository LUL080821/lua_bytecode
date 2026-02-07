------------------------------------------------
-- Author: 
-- Date: 2021-02-23
-- File: AuctionHouseSystem.lua
-- Module: AuctionHouseSystem
-- Description: Auction House System
------------------------------------------------

local L_AuctionItem = require "Logic.AuctionHouse.AuctionItem"
local L_ItemBase = CS.Thousandto.Code.Logic.ItemBase

local AuctionHouseSystem = {
    -- Containers for all items
    Items = Dictionary:New(),
    -- A cache list for searching
    FindCacheList = List:New(),

    -- Is the configuration already loaded
    IsLoadCareData = false,
    -- List of items to follow
    CareItemList = {},
    -- The item matching value of attention is used to calculate whether it belongs to the item of attention.
    CareItemMatchValues = {},
    CareItemCount = 0,

    -- Push attention interval time
    CareIntervalTime = 60,
    -- Pop up timer for attention information
    ShowCareTimer = 0,
    -- Cache displays the following interface items
    ChcheCareItems = List:New(),
    ChcheCarePoss = List:New(),
    ShowCareFormTimer = 0,
    -- Items that have been popped up with follow prompts
    NotShowCareItems = Dictionary:New(),
    -- Have data been accepted
    IsFirstResiveData = true,

    -- Whether to display real items for players to purchase
    IsShowRealItems = true,
    FakeItem = nil,

    -- Is there any red dot available for listing
    AuctionRedPoint = false,
    -- The number of items currently listed on it
    SelfAuctionCount = 0,
    -- Maximum number of configurations listed
    MaxAuctionCount = 0,

    -- Lưu level cường hóa cho mỗi item auction
    ItemStrengthLevelMap = Dictionary:New(),

    StrengthItemLevelDic   = Dictionary:New(),
    ItemWashInfoDic        = Dictionary:New(),
    ItemAppraiseInfoDic    = Dictionary:New(),
    ItemSpecialInfoDic    = Dictionary:New(),
    GemInlayInfoByItemIdDic    = Dictionary:New(),

}

-- initialization
function AuctionHouseSystem:Initialize()
    self.IsLoadCareData = false
    local _gCfg = DataConfig.DataGlobal[GlobalName.Auction_ShowCare_IntervalTime]
    if _gCfg ~= nil then
        -- Push interval time
        self.CareIntervalTime = tonumber(_gCfg.Params)
    end
    _gCfg = DataConfig.DataGlobal[GlobalName.Trade_maxrecord]
    if _gCfg ~= nil then
        -- Maximum number of listings
        self.MaxAuctionCount = tonumber(_gCfg.Params)
    end 
end
-- De-initialization
function AuctionHouseSystem:UnInitialize()
    for _, v in pairs(self.Items) do
        L_AuctionItem.Free(v, true)
    end
    self.Items:Clear()
end

---------------------------------------- Custom view auction
local INVALID_POOL_ID = 0
local L_EquipWashInfo = {
    Index   = 0, -- Entry index
    Value   = 0, -- The blessing value of this entry
    Percent = 0, -- The attribute of this entry plays a tens of percent ratio and displays a decimal number.
    PoolID  = INVALID_POOL_ID, -- Index of pool
}
local L_EquipAppraiseInfo = {
    Index   = 0, -- Entry index
    Value   = 0, -- The blessing value of this entry
    Percent = 0, -- The attribute of this entry plays a tens of percent ratio and displays a decimal number.
    PoolID  = INVALID_POOL_ID, -- Index of pool
}
local L_EquipSpecialInfo = {
    Index   = 0, -- Entry index
    Value   = 0, -- The blessing value of this entry
    Percent = 0, -- The attribute of this entry plays a tens of percent ratio and displays a decimal number.
    PoolID  = INVALID_POOL_ID, -- Index of pool
}

function AuctionHouseSystem:HandleStrengthInfos(infos)
    if not infos or Utils.GetTableLens(infos) == 0 then return end

    for i = 1, #infos do
        local item = infos[i]
        local detail = item and item.detail
        local strengthInfo = detail and detail.strengthInfo
        local itemId = item.item and item.item.itemId
        if strengthInfo then
            self.StrengthItemLevelDic[itemId] = {
                level = strengthInfo.level or 0,
                exp   = strengthInfo.exp or 0,
                type  = strengthInfo.type or detail.type
            }
        end
    end
end

function AuctionHouseSystem:HandleWashInfos(infos)
    local count = Utils.GetTableLens(infos)
    if not infos or count == 0 then
        return
    end

    for i = 1, count do
        local item = infos[i]
        local itemId = item.item and item.item.itemId
        local detail = item.detail
        -------------------------
        local washInfos = detail and detail.washInfo
        if washInfos then
            local _washInfos = List:New()
            local _rawWashInfos = List:New(washInfos, true)
            for j = 1, #_rawWashInfos do
                local _data = Utils.DeepCopy(L_EquipWashInfo)
                _data.Index = _rawWashInfos[j].index
                _data.Value = _rawWashInfos[j].value
                _data.Percent = _rawWashInfos[j].per
                _data.PoolID = _rawWashInfos[j].poolId or INVALID_POOL_ID
                _washInfos:Add(_data)
            end
            _washInfos:Sort(function(a, b)
                return a.Index < b.Index
            end)
            if #_washInfos > 0 then
                if not self.ItemWashInfoDic:ContainsKey(itemId) then
                    self.ItemWashInfoDic:Add(itemId, _washInfos)
                else
                    self.ItemWashInfoDic[itemId] = _washInfos
                end
            elseif self.ItemWashInfoDic:ContainsKey(itemId) then
                self.ItemWashInfoDic[itemId] = List:New() -- fallback clear
            end
        end
    end
end


function AuctionHouseSystem:InitGemInlayInfoByBagInfos(bagInfos)
    if not bagInfos then
        return
    end

    -- 🔒 ensure dic
    self.GemInlayInfoByItemIdDic = self.GemInlayInfoByItemIdDic or Dictionary:New()

    for _, bag in ipairs(bagInfos) do
        local info    = bag.detail
        local equip   = info and info.equip
        local gemInfo = info and info.gemInfo

        if equip and equip.itemId and gemInfo then
            local _pos = info.type

            local _gemIDList  = gemInfo.gemIds  and List:New(gemInfo.gemIds)  or nil
            local _jadeIDList = gemInfo.jadeIds and List:New(gemInfo.jadeIds) or nil

            local _refineInfo = {
                Level = gemInfo.level or 0,
                Exp   = gemInfo.exp   or 0
            }

            -- ✅ SAME STRUCT AS GS2U_ResGemInfo
            self.GemInlayInfoByItemIdDic[equip.itemId] = {
                part    = _pos,
                gemIds  = _gemIDList,
                jadeIds = _jadeIDList,
                refine  = _refineInfo
            }
        end
    end

end

function AuctionHouseSystem: HandleAppraiseInfos(infos)

    -- print("==== DEBUG infos ====", Inspect(infos))

    if not infos or Utils.GetTableLens(infos) == 0 then
        return
    end

    for i = 1, #infos do
        local item = infos[i]
        if not item then goto continue end

        local itemId  = item.item and item.item.itemId
        local detail = item.detail      

        if not detail then goto continue end

        local appraisalInfos = detail.raisalInfo  

        -- Nếu không có raisalInfo = tạo list rỗng
        if not appraisalInfos or #appraisalInfos == 0 then
            self.ItemAppraiseInfoDic[itemId] = List:New()
            goto continue
        end

        -- Có raisalInfo
        local list = List:New()
        for j = 1, #appraisalInfos do
            local src = appraisalInfos[j]
            if src then
                local data = Utils.DeepCopy(L_EquipAppraiseInfo)
                data.Index   = src.index
                data.Value   = src.value
                data.Percent = src.per
                data.PoolID  = src.poolId or INVALID_POOL_ID
                list:Add(data)
            end
        end

        list:Sort(function(a, b) return a.Index < b.Index end)

        self.ItemAppraiseInfoDic[itemId] = list

        ::continue::
    end

    -- print("==== FINAL DICTIONARY ====", Inspect(self.ItemAppraiseInfoDic))
end

function AuctionHouseSystem: HandleSpecialInfos(infos)

    -- print("==== DEBUG infos ====", Inspect(infos))

    if not infos or Utils.GetTableLens(infos) == 0 then
        return
    end

    for i = 1, #infos do
        local item = infos[i]
        if not item then goto continue end

        local itemId  = item.item and item.item.itemId
        local detail = item.detail      

        if not detail then goto continue end

        local specialInfos = detail.attrSpecial  

        -- Nếu không có raisalInfo = tạo list rỗng
        if not specialInfos or #specialInfos == 0 then
            self.ItemSpecialInfoDic[itemId] = List:New()
            goto continue
        end

        -- Có raisalInfo
        local list = List:New()
        for j = 1, #specialInfos do
            local src = specialInfos[j]
            if src then
                local data = Utils.DeepCopy(L_EquipSpecialInfo)
                data.Index   = src.index
                data.Value   = src.value
                data.Percent = src.per
                data.PoolID  = src.poolId or INVALID_POOL_ID
                list:Add(data)
            end
        end

        list:Sort(function(a, b) return a.Index < b.Index end)

        self.ItemSpecialInfoDic[itemId] = list

        ::continue::
    end

    -- print("==== FINAL DICTIONARY ====", Inspect(self.ItemSpecialInfoDic))
end



function AuctionHouseSystem:GetAllStrengthAttrDicByItemId(itemId, strengthLevel)

    local _retAttrDic = Dictionary:New()
    local strengthLevels = self.StrengthItemLevelDic
    if (not itemId) or (not strengthLevels) then
        return _retAttrDic
    end

    -- itemData: Equipment.cs
    local itemData = GameCenter.ItemContianerSystem:GetItemByUIDFormBag(itemId);

    local _useLevel = 0
    if strengthLevel then
        _useLevel = strengthLevel
    elseif (strengthLevels[itemId] and strengthLevels[itemId].level) then
        _useLevel = strengthLevels[itemId].level
    end

    local _userType = nil
    if (strengthLevels[itemId] and strengthLevels[itemId].type) then
        _userType = strengthLevels[itemId].type
    elseif (itemData and itemData.Part) then
        _userType = itemData.Part
    end

    if not _userType then
        return _retAttrDic
    end

    local cfgID = self:GetCfgID(_userType, _useLevel)
    local cfg = DataConfig.DataEquipIntenMain[cfgID]
    if cfg and cfg.Value then
        local attrList = Utils.SplitStrByTableS(cfg.Value, { ';', '_' })
        for i = 1, #attrList do
            local attrId = tonumber(attrList[i][1])
            local value = tonumber(attrList[i][2])
            if not _retAttrDic:ContainsKey(attrId) then
                _retAttrDic:Add(attrId, { Value = value, Level = _useLevel })
            end
        end
    end

    return _retAttrDic
end

function AuctionHouseSystem:GetCfgID(part, level)
    return (part + 100) * 1000 + level
end

function AuctionHouseSystem:GetStrengthLvByItemId(itemID)
    if self.StrengthItemLevelDic and self.StrengthItemLevelDic:ContainsKey(itemID) then
        return self.StrengthItemLevelDic[itemID].level or 0
    end
    return 0
end


function AuctionHouseSystem:GetAllAppraiseAttrDicByItemId(itemId)
    --- Result data: {{ Index, { AttrID = _attrID, Value = _realValue, Percent = 0 }}}
    local _retAttrDic = Dictionary:New()

    -- Validate input
    if not itemId then
        return _retAttrDic
    end
    if not self.ItemAppraiseInfoDic or not self.ItemAppraiseInfoDic:ContainsKey(itemId) then
        return _retAttrDic
    end

    -- Get appraise info list from dictionary
    local appraiseInfos = self.ItemAppraiseInfoDic[itemId]
    if not appraiseInfos or #appraiseInfos == 0 then
        return _retAttrDic
    end

    -- Iterate all appraise lines
    for i = 1, #appraiseInfos do
        local appraiseLine = appraiseInfos[i]
        if appraiseLine then
            local index = appraiseLine.Index or 0
            local poolId = appraiseLine.PoolID or INVALID_POOL_ID
            local percent = appraiseLine.Percent or 0

            -- Parse attribute pool info
            local _poolInfo = Utils.ParsePoolAttribute(poolId)
            if _poolInfo and _poolInfo.minVal and _poolInfo.maxVal then
                local _value = math.floor((_poolInfo.maxVal - _poolInfo.minVal) * (percent / 10000) + _poolInfo.minVal)
                local _data = {
                    AttrID  = _poolInfo.attrId,
                    Value   = _value,
                    Percent = percent,
                    SpecialType = _poolInfo.specialType
                }

                if not _retAttrDic:ContainsKey(index) then
                    _retAttrDic:Add(index, _data)
                end
            else
                -- Debug.LogError("[LDebug] [GetAllAppraiseAttrDicByItemId]", string.format("Invalid pool info for itemId=%s, poolId=%s", tostring(itemId), tostring(poolId)))
            end
        end
    end

    return _retAttrDic
end


function AuctionHouseSystem:GetAllSpecialAttrDicByItemId(itemId)
    --- Result data: {{ Index, { AttrID = _attrID, Value = _realValue, Percent = 0 }}}
    local _retAttrDic = Dictionary:New()

    -- Validate input
    if not itemId then
        return _retAttrDic
    end
    if not self.ItemSpecialInfoDic or not self.ItemSpecialInfoDic:ContainsKey(itemId) then
        return _retAttrDic
    end

    -- Get appraise info list from dictionary
    local specialInfos = self.ItemSpecialInfoDic[itemId]
    if not specialInfos or #specialInfos == 0 then
        return _retAttrDic
    end

    -- Iterate all appraise lines
    for i = 1, #specialInfos do
        local specialLine = specialInfos[i]
        if specialLine then
            local index = specialLine.Index or 0
            local poolId = specialLine.PoolID or INVALID_POOL_ID
            local percent = specialLine.Percent or 0

            -- Parse attribute pool info
            local _poolInfo = Utils.ParsePoolAttribute(poolId)
            if _poolInfo and _poolInfo.minVal and _poolInfo.maxVal then
                local _value = math.floor((_poolInfo.maxVal - _poolInfo.minVal) * (percent / 10000) + _poolInfo.minVal)
                local _data = {
                    AttrID  = _poolInfo.attrId,
                    Value   = _value,
                    Percent = percent
                }

                if not _retAttrDic:ContainsKey(index) then
                    _retAttrDic:Add(index, _data)
                end
            else
                -- Debug.LogError("[LDebug] [GetAllAppraiseAttrDicByItemId]", string.format("Invalid pool info for itemId=%s, poolId=%s", tostring(itemId), tostring(poolId)))
            end
        end
    end

    return _retAttrDic
end


function AuctionHouseSystem:GetAllWashAttrDicByItemId(itemId)
    --- Result data: {{ Index, { AttrID = _attrID, Value = _realValue, Percent = 0 }}}
    local _retAttrDic = Dictionary:New()

    -- Validate input
    if not itemId then
        return _retAttrDic
    end
    if not self.ItemWashInfoDic or not self.ItemWashInfoDic:ContainsKey(itemId) then
        return _retAttrDic
    end

    -- Get wash info list from dictionary
    local washInfos = self.ItemWashInfoDic[itemId]
    if not washInfos or #washInfos == 0 then
        return _retAttrDic
    end

    -- Iterate all wash lines
    for i = 1, #washInfos do
        local washLine = washInfos[i]
        if washLine then
            local index = washLine.Index or 0
            local poolId = washLine.PoolID or INVALID_POOL_ID
            local percent = washLine.Percent or 0

            -- Parse attribute pool info
            local _poolInfo = Utils.ParsePoolAttribute(poolId)
            if _poolInfo and _poolInfo.minVal and _poolInfo.maxVal then
                local _value = math.floor((_poolInfo.maxVal - _poolInfo.minVal) * (percent / 10000) + _poolInfo.minVal)

                local _data = {
                    AttrID  = _poolInfo.attrId,
                    Value   = _value,
                    Percent = percent
                }

                if not _retAttrDic:ContainsKey(index) then
                    _retAttrDic:Add(index, _data)
                end
            end
        end
    end

    return _retAttrDic
end



---------------------------------------- End custom view auction





-- Ascending according to combat power
local function L_SortByPowerUP(left, right)
    if left.EquipCfg ~= nil and right.EquipCfg ~= nil then
        return left.EquipCfg.Score < right.EquipCfg.Score
    else
        return right.CfgID < left.CfgID
    end
end
-- Descending order according to combat power
local function L_SortByPowerDown(left, right)
    if left.EquipCfg ~= nil and right.EquipCfg ~= nil then
        return right.EquipCfg.Score < left.EquipCfg.Score
    else
        return right.CfgID < left.CfgID
    end
end
-- Ascending order according to the remaining time
local function L_SortByTimeUP(left, right)
    return left:GetRemainTime() < right:GetRemainTime()
end
-- Ascending order according to the remaining time
local function L_SortByTimeDown(left, right)
    return right:GetRemainTime() < left:GetRemainTime()
end
-- Ascending order according to current bidding
local function L_SortByCurPriceUP(left, right)
    local _lPrice = left.CurPrice
    if left.HasMiMa then
        _lPrice = 0
    end
    local _rPrice = right.CurPrice
    if right.HasMiMa then
        _rPrice = 0
    end
    return _lPrice < _rPrice
end
-- Descending order based on current bidding
local function L_SortByCurPriceDown(left, right)
    local _lPrice = left.CurPrice
    if left.HasMiMa then
        _lPrice = 0
    end
    local _rPrice = right.CurPrice
    if right.HasMiMa then
        _rPrice = 0
    end
    return _rPrice < _lPrice
end
-- Ascending order according to the maximum bid
local function L_SortByMaxPriceUP(left, right)
    local _lPrice = left.MaxPrice
    if left.HasMiMa then
        _lPrice = left.CurPrice
    end
    local _rPrice = right.MaxPrice
    if right.HasMiMa then
        _rPrice = right.CurPrice
    end
    return _lPrice < _rPrice
end
-- Descending order based on maximum bidding
local function L_SortByMaxPriceDown(left, right)
    local _lPrice = left.MaxPrice
    if left.HasMiMa then
        _lPrice = left.CurPrice
    end
    local _rPrice = right.MaxPrice
    if right.HasMiMa then
        _rPrice = right.CurPrice
    end
    return _rPrice < _lPrice
end
-- Close string pattern matching, for searching
local function CloseStringMatch(searchName)
    searchName = string.gsub(searchName, "%[", "%%[")
    searchName = string.gsub(searchName, "%]", "%%]")
    return searchName
end

-- Obtain item list according to the conditions, list type tyoe: 0 world, 1 guild; sort type sortType: 0 combat power, 1 remaining time, 2 current price, 3 maximum price
function AuctionHouseSystem:GetItemList(type, menuID, grade, star, quality, sortType, upSort, searchName)
    self.FindCacheList:Clear()
    if searchName ~= nil and string.len(searchName) > 0 then
        searchName = CloseStringMatch(searchName)
    end
    if not self.IsShowRealItems then
        if self.FakeItem == nil or self.FakeItem:GetRemainTime() <= 0 then
            local _itemId = 0
            local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
            local _gCfg = DataConfig.DataGlobal[GlobalName.Trade_First_Buy_Item]
            if _gCfg ~= nil and _lp ~= nil then
                local _occ = _lp.IntOcc
                local _occParams = Utils.SplitStrByTableS(_gCfg.Params, {';', '_'})
                for i = 1, #_occParams do
                    if _occParams[i][1] == _occ then
                        _itemId = _occParams[i][2]
                        break
                    end
                end
            end
            if self.FakeItem ~= nil then
                L_AuctionItem.Free(self.FakeItem)
            end
            self.FakeItem = L_AuctionItem.Get()
            local msgAuction = {}
            msgAuction.item = {}
            msgAuction.item.itemId = 0
            msgAuction.item.itemModelId = _itemId
            msgAuction.item.num = 1
            msgAuction.item.gridId = 0
            msgAuction.item.isbind = false
            msgAuction.item.lostTime = 0
            msgAuction.item.cdTime = 0
            msgAuction.item.suitId = 0
            msgAuction.item.strengLv = 0
            msgAuction.isPassword = false
            msgAuction.guildId = 0
            msgAuction.price = 0
            msgAuction.ownId = 0
            msgAuction.roleId = 0
            msgAuction.id = 0
            self.FakeItem:RefreshData(msgAuction)
            self.FakeItem:RefreshTempData()
        end
        if self.FakeItem ~= nil then
            self.FindCacheList:Add(self.FakeItem)
        end
        return self.FindCacheList
    end
    if type == 1 and not GameCenter.GuildSystem:HasJoinedGuild() then
        -- Getting the guild auction list is empty without joining the guild
        return self.FindCacheList;
    end
    local _findedCount = 0
    local _guildID = 0
    if GameCenter.GuildSystem:HasJoinedGuild() then
        _guildID = GameCenter.GuildSystem.GuildInfo.guildId
    end
    local _menuCfg = DataConfig.DataAuctionMenu[menuID]
    if _menuCfg ~= nil then
        local _partCount = 0
        local _partList = {}
        local _partParams = Utils.SplitNumber(_menuCfg.EquipPart, '_')
        if _partParams ~= nil and #_partParams > 0 then
            for i = 1, #_partParams do
                _partList[_partParams[i]] = true
                _partCount = _partCount + 1
            end
        end

        for _, ahItem in pairs(self.Items) do
            if type == 0 and ahItem.OwnerGuild > 0 then
                -- Items from guild stores are not displayed when choosing a world auction
            elseif type == 1 and ahItem.OwnerGuild ~= _guildID then
                -- Only display items from your own guild when choosing a guild auction
            elseif ahItem:GetRemainTime() <= 0 then
                -- Props with time less than 0 will not be displayed
            elseif (_menuCfg.EquipOrItem == 0 and ahItem.ItemInst.Type == ItemType.Equip) or
                (_menuCfg.EquipOrItem == 1 and (ahItem.ItemInst.Type ~= ItemType.Equip and ahItem.ItemInst.Type ~= ItemType.HolyEquip and ahItem.ItemInst.Type ~= ItemType.UnrealEquip)) or
                (_menuCfg.EquipOrItem == 2 and ahItem.ItemInst.Type == ItemType.HolyEquip) or
                (_menuCfg.EquipOrItem == 3 and ahItem.ItemInst.Type == ItemType.UnrealEquip) or
                _menuCfg.EquipOrItem < 0 then
                local _canAddItem = nil
                -- thing
                local _name = nil
                if ahItem.ItemCfg ~= nil and (_menuCfg.ItemTradeType < 0 or _menuCfg.ItemTradeType == ahItem.ItemCfg.TradeType) and (quality < 0 or ahItem.ItemCfg.Color >= quality) then
                    _canAddItem = ahItem
                    _name = ahItem.ItemCfg.Name
                end
                -- equipment
                if ahItem.EquipCfg ~= nil and (_menuCfg.EquipOcc < 0 or string.find(ahItem.EquipCfg.Gender, tostring(_menuCfg.EquipOcc)) ~= nil) and
                    (_partCount <= 0 or _partList[ahItem.EquipCfg.Part]) and
                    (grade < 0 or ahItem.EquipCfg.Grade >= grade) and
                    (star < 0 or ahItem.EquipCfg.DiamondNumber >= star) and
                    (quality < 0 or ahItem.EquipCfg.Quality >= quality) then
                    _canAddItem = ahItem
                    _name = ahItem.EquipCfg.Name
                end
                if _canAddItem ~= nil then
                    if searchName ~= nil and string.len(searchName) > 0 then
                        if string.find(_name, searchName) then
                            self.FindCacheList:Add(_canAddItem)
                            _findedCount = _findedCount + 1
                        end
                    else
                        self.FindCacheList:Add(_canAddItem)
                        _findedCount = _findedCount + 1
                    end
                end
            end
        end
    end

    if _findedCount > 1 then
        local _sortFunc = nil
        -- Sorting
        if sortType == 0 then
            if upSort then
                _sortFunc = L_SortByPowerUP
            else
                _sortFunc = L_SortByPowerDown
            end
        elseif sortType == 1 then
            if upSort then
                _sortFunc = L_SortByTimeUP
            else
                _sortFunc = L_SortByTimeDown
            end
        
        elseif sortType == 2 then
            if upSort then
                _sortFunc = L_SortByCurPriceUP
            else
                _sortFunc = L_SortByCurPriceDown
            end
        elseif sortType == 3 then
            if upSort then
                _sortFunc = L_SortByMaxPriceUP
            else
                _sortFunc = L_SortByMaxPriceDown
            end
        end
        if _sortFunc ~= nil then
            self.FindCacheList:Sort(_sortFunc)
        end
    end
    return self.FindCacheList
end
-- Get a list of items for your auction
function AuctionHouseSystem:GetSelBuyItemList(sortType, upSort)
    self.FindCacheList:Clear()
    local _findedCount = 0
    for _, ahItem in pairs(self.Items) do
        if ahItem.IsSefJion and ahItem:GetRemainTime() > 0 then
            self.FindCacheList:Add(ahItem)
            _findedCount = _findedCount + 1
        end
    end
    if _findedCount > 1 then
        local _sortFunc = nil
        -- Sorting
        if sortType == 0 then
            if upSort then
                _sortFunc = L_SortByPowerUP
            else
                _sortFunc = L_SortByPowerDown
            end
        elseif sortType == 1 then
            if upSort then
                _sortFunc = L_SortByTimeUP
            else
                _sortFunc = L_SortByTimeDown
            end
        
        elseif sortType == 2 then
            if upSort then
                _sortFunc = L_SortByCurPriceUP
            else
                _sortFunc = L_SortByCurPriceDown
            end
        elseif sortType == 3 then
            if upSort then
                _sortFunc = L_SortByMaxPriceUP
            else
                _sortFunc = L_SortByMaxPriceDown
            end
        end
        if _sortFunc ~= nil then
            self.FindCacheList:Sort(_sortFunc)
        end
    end
    return self.FindCacheList
end
-- Get your own props
function AuctionHouseSystem:GetSelfSellItems()
    local _lpID = GameCenter.GameSceneSystem:GetLocalPlayerID()
    self.FindCacheList:Clear()
    for _, ahItem in pairs(self.Items) do
        if ahItem.OwnerID == _lpID and ahItem:GetRemainTime() > 0 then
            self.FindCacheList:Add(ahItem)
        end
    end
    return self.FindCacheList
end

-- Order of items for sale
local function L_SoryItemBase(left, right)
    local _leftValue = left.CfgID
    if left.Type == ItemType.Equip or left.Type == ItemType.HolyEquip then
        if left:CheckCanEquip() then
            _leftValue = 2
        else
            _leftValue = 1
        end
    end
    local _rightValue = right.CfgID
    if right.Type == ItemType.Equip or right.Type == ItemType.HolyEquip then
        if right:CheckCanEquip() then
            _rightValue = 2
        else
            _rightValue = 1
        end
    end
    return _leftValue < _rightValue
end
-- Get props for sale in your backpack
function AuctionHouseSystem:GetCanSellItems(onlyQuick)
    self.FindCacheList:Clear()
    local _bagItemList = GameCenter.ItemContianerSystem:GetItemListByBind(ContainerType.ITEM_LOCATION_BAG, false)
    local _bagCount = _bagItemList.Count
    for i = 1, _bagCount do
        local _item = _bagItemList[i - 1]
        local _itemCfg = DataConfig.DataItem[_item.CfgID]
        if _itemCfg ~= nil and _itemCfg.AuctionMaxPrice ~= 0 then
            if onlyQuick then
                if _itemCfg.AuctionPriceType ~= 1 then
                    self.FindCacheList:Add(_item)
                end
            else
                self.FindCacheList:Add(_item)
            end
        end
        local _equipCfg = DataConfig.DataEquip[_item.CfgID]
        if _equipCfg ~= nil and _equipCfg.AuctionMaxPrice ~= 0 then
            if onlyQuick then
                if _equipCfg.AuctionPriceType ~= 1 then
                    self.FindCacheList:Add(_item)
                end
            else
                self.FindCacheList:Add(_item)
            end
        end
    end
    self.FindCacheList:Sort(L_SoryItemBase)
    return self.FindCacheList
end

-- Get props for sale in the holy suit
function AuctionHouseSystem:GetCanSellHolyEquips()
    self.FindCacheList:Clear()
    local _list = GameCenter.HolyEquipSystem.BagList
    local _count = #_list
    for i = 1, _count do
        local _holyEquip = _list[i]
        local _cfg = DataConfig.DataEquip[_holyEquip.CfgID]
        if _cfg ~= nil and not _holyEquip.IsBind and _cfg.AuctionMaxPrice ~= 0 then
            self.FindCacheList:Add(_holyEquip)
        end
    end
    self.FindCacheList:Sort(L_SoryItemBase)
    return self.FindCacheList
end

-- Get props for sale in the magic outfit
function AuctionHouseSystem:GetCanSellUnrealEquips()
    self.FindCacheList:Clear()
    local _list = GameCenter.UnrealEquipSystem.BagList
    local _count = #_list
    for i = 1, _count do
        local _unrealEquip = _list[i]
        local _cfg = DataConfig.DataEquip[_unrealEquip.CfgID]
        if _cfg ~= nil and not _unrealEquip.IsBind and _cfg.AuctionMaxPrice ~= 0 then
            self.FindCacheList:Add(_unrealEquip)
        end
    end
    self.FindCacheList:Sort(L_SoryItemBase)
    return self.FindCacheList
end

-- Get a single product based on id
function AuctionHouseSystem:GetItemByID(id)
    local _item = self.Items[id]
    if _item ~= nil and _item:GetRemainTime() > 0 then
        return _item
    end
    return nil
end

-- Items to increase attention
function AuctionHouseSystem:AddCareItem(itemID, itemOrEquip)
    if self.CareItemList[itemID] == nil then
        self.CareItemList[itemID] = true
        self:SaveCareData()
    end
end
-- Delete items you are following
function AuctionHouseSystem:RemoveCareItem(itemID)
    if self.CareItemList[itemID] ~= nil then
        self.CareItemList[itemID] = nil
        self:SaveCareData()
    end
end

-- Enter the scene
function AuctionHouseSystem:OnEnterScene()
    self:LoadCareData()
    -- Show attention after entering the scene one second
    self.ShowCareTimer = 1
    self.IsFirstResiveData = true
end
-- Follow the interface close
function AuctionHouseSystem:OnCareFormClose()
    if #self.ChcheCareItems > 0 then
        self.ShowCareFormTimer = 1
    end
end
-- renew
function AuctionHouseSystem:Update(deltaTime)
    if self.IsFirstResiveData or self.SelfAuctionCount > 0 or (self.IsLoadCareData and self.CareItemCount > 0) then
        -- Only requests are executed if there is attention to data
        if self.ShowCareTimer > 0 then
            self.ShowCareTimer = self.ShowCareTimer - deltaTime
            if self.ShowCareTimer <= 0 then
                self:ReqItemList()
                self.IsFirstResiveData = false
                self.ShowCareTimer = -1
            end
        end
    end
    local _cacheCount = #self.ChcheCareItems
    if _cacheCount > 0 then
        if self.ShowCareFormTimer > 0 then
            self.ShowCareFormTimer = self.ShowCareFormTimer - deltaTime
            if self.ShowCareFormTimer <= 0 then
                GameCenter.PushFixEvent(UIEventDefine.UIAuctionCareForm_Open, {self.ChcheCareItems[_cacheCount], self.ChcheCarePoss[_cacheCount]})
                self.ChcheCareItems:RemoveAt(_cacheCount)
                self.ChcheCarePoss:RemoveAt(_cacheCount)
                self.ShowCareFormTimer = -1
            end
        end
    end
end
-- Requested Product List
function AuctionHouseSystem:ReqItemList()
    GameCenter.Network.Send("MSG_Auction.ReqAuctionInfoList", {})
end
-- Item List
function AuctionHouseSystem:ResAuctionInfoList(result)

    for _, v in pairs(self.Items) do
        L_AuctionItem.Free(v)
    end
    self.Items:Clear()
    local _lpID = GameCenter.GameSceneSystem:GetLocalPlayerID()
    local _careItem = nil
    self.SelfAuctionCount = 0
    local _msgCount = 0
    if result.auctionInfoList ~= nil then
        _msgCount = #result.auctionInfoList
    end

    self:HandleAppraiseInfos(result.auctionInfoList)
    self:HandleSpecialInfos(result.auctionInfoList)
    self:HandleStrengthInfos(result.auctionInfoList)
    self:HandleWashInfos(result.auctionInfoList)
    self:InitGemInlayInfoByBagInfos(result.auctionInfoList)

    for i = 1, _msgCount do

        --------------------------------------------
        -- Chỉnh sửa để lưu mảng level cường hóa
        local _auctionInfo = result.auctionInfoList[i]

        -- cập nhật level cường hóa
        self:UpdateItemStrengthLevel(_auctionInfo)
        ------------------------------------------

        local _item = L_AuctionItem.Get()
        _item:RefreshData(result.auctionInfoList[i])
        self.Items:Add(_item.ID, _item)
        -- You cannot pay attention to your own items and those that have been popped up
        if _lpID ~= _item.OwnerID and self.NotShowCareItems[_item.ID] == nil then
            if _careItem == nil and self:IsCareItem(_item) then
                _careItem = _item
            end
        end
        if _lpID == _item.OwnerID then
            self.SelfAuctionCount = self.SelfAuctionCount + 1
        end
    end
    if self.ShowCareTimer <= 0 then
        if self.CareItemCount > 0 then
            if self.NotShowCareItems:Count() >= 200 then
                self.NotShowCareItems:Clear()
            end
            self.ShowCareTimer = self.CareIntervalTime
            self.ChcheCareItems:Clear()
            self.ChcheCarePoss:Clear()
            if _careItem ~= nil then
                self.NotShowCareItems:Add(_careItem.ID, true)
                self.ChcheCareItems:Add(_careItem.ItemInst)
                if _careItem.OwnerGuild > 0 then
                    self.ChcheCarePoss:Add(1)
                else
                    self.ChcheCarePoss:Add(0)
                end
            end
            if #self.ChcheCareItems > 0 then
                self.ShowCareFormTimer = 1
            end
        end
    end
    -- Testing red dots
    self.AuctionRedPoint = false
    if self.SelfAuctionCount < self.MaxAuctionCount then
        local _bagItemList = GameCenter.ItemContianerSystem:GetItemListByBind(ContainerType.ITEM_LOCATION_BAG, false)
        local _bagCount = _bagItemList.Count
        for i = 1, _bagCount do
            local _item = _bagItemList[i - 1]
            if _item:CanAuction() then
                -- Can be put on the shelves
                self.AuctionRedPoint = true
                break
            end
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_AUCTION_UPDATELIST)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_AUCTION_REDPOINT_UPDATED)
end

----- [Gosu] chỉnh sửa auction -------------------------------------------------------------------------------------------


-- Hàm cập nhật mảng level cường hóa của auction

-- function AuctionHouseSystem:UpdateItemStrengthLevel(auctionInfo)
--     if not auctionInfo or not auctionInfo.detail then
--         return
--     end

--     local _strengthInfo = auctionInfo.detail.strengthInfo
--     if not _strengthInfo then
--         return
--     end

--     local _itemId = auctionInfo.item and auctionInfo.item.itemId
--     if not _itemId then
--         return
--     end

--     local _level = _strengthInfo.level or 0
--     self.ItemStrengthLevelMap[_itemId] = _level
-- end

function AuctionHouseSystem:UpdateItemStrengthLevel(auctionInfo)
    if not auctionInfo or not auctionInfo.detail then
        return
    end

    local strengthInfo = auctionInfo.detail.strengthInfo
    local itemId = auctionInfo.item and auctionInfo.item.itemId
    if not strengthInfo or not itemId then
        return
    end

    GosuSDK.UpdateItemStrengthLevel(
        self.ItemStrengthLevelMap,
        itemId,
        strengthInfo
    )
end





-- Hàm trả về level cường hóa của item auction
function AuctionHouseSystem:GetItemStrengthLevel(itemId)
    return self.ItemStrengthLevelMap[itemId]
end


--- End ------------------------------------------------------------------------------------------------------------------


-- Successfully launched, updated items
function AuctionHouseSystem:ResAuctionInfoPutSuccess(result)
    self.SelfAuctionCount = self.SelfAuctionCount + 1
    self:UpdateData(result.auctionInfo)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_AUCTION_UP_SUCC)
end
-- Return to remove the shelves 0: The object is successfully deleted 1: The object is updated failed prompts the player is already in the bidding 2: The object is deleted prompts the item does not exist
function AuctionHouseSystem:ResAuctionInfoOut(result)
    if result.res == 0 then
        -- Successfully delete the object
        self:RemoveData(result.auctionInfo.id)
        Utils.ShowPromptByEnum("C_AUCTION_DOWN_SUCC")
        self.SelfAuctionCount = self.SelfAuctionCount - 1
        if self.SelfAuctionCount < 0 then
            self.SelfAuctionCount = 0
        end
    elseif result.res == 1 then
        -- Failed to update the object
        self:UpdateData(result.auctionInfo)
        Utils.ShowPromptByEnum("C_AUCTION_DOWNFIAL_JINGPAI")
    elseif result.res == 2 then
        self:UpdateData(result.auctionInfo)
        Utils.ShowPromptByEnum("C_AUCTION_DOWNFAIL_NOITEM")
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_AUCTION_DOWN_RESULT)
end
-- Return to purchase at a fixed price //0: Success 1: The object does not exist
function AuctionHouseSystem:ResAuctionInfoPur(result)
    if result.res == 0 then
        Utils.ShowPromptByEnum("C_AUCTION_BUY_SUCC")
    elseif result.res == 1 then
        Utils.ShowPromptByEnum("C_AUCTION_BUYFAIL_NOITEM")
    end
    -- Delete an object
    self:RemoveData(result.auctionId)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_AUCTION_BUY_RESULT, result.auctionId)
end
-- Bidding returns 0: The object is updated successfully 1: The object is updated failed prompts that the price has changed 2: Delete the object. The item is no longer there, 3: The bid has been the highest and cannot continue to bid.
function AuctionHouseSystem:ResAuctionInfo(result)
    if result.res == 0 then
        Utils.ShowPromptByEnum("C_AUCTION_JINGJIA_SUCC")
        self:UpdateData(result.auctionInfo)
    elseif result.res == 1 then
        Utils.ShowPromptByEnum("C_AUCTION_JINGJIAFAIL_GENGGAO")
        self:UpdateData(result.auctionInfo)
    elseif result.res == 2 then
        Utils.ShowPromptByEnum("C_AUCTION_JINGJIAFAIL_NOITEM")
        self:RemoveData(result.auctionInfo.id)
    elseif result.res == 3 then
        Utils.ShowPromptByEnum("C_AUCTION_JINGJIAFAIL_ZUIGAO")
        self:UpdateData(result.auctionInfo)
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_AUCTION_JINGJIA_RESULT, result.auctionInfo.id)
end
-- Whether to use a fake auction house
function AuctionHouseSystem:ResAuctionPur(result)
    self.IsShowRealItems = result.isPur
end
-- Refresh data
function AuctionHouseSystem:ResAuctionUpdate(result)
    self:UpdateData(result.auctionInfo);
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_AUCTION_JINGJIA_RESULT, result.auctionInfo.id)
end
-- Delete items
function AuctionHouseSystem:ResAuctionDelete(result)
    self:RemoveData(result.id)
    if result.ownId == GameCenter.GameSceneSystem:GetLocalPlayerID() then
        self.SelfAuctionCount = self.SelfAuctionCount - 1
        if self.SelfAuctionCount < 0 then
            self.SelfAuctionCount = 0
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_AUCTION_BUY_RESULT, result.id)
end
 
-- Update Objects
function AuctionHouseSystem:UpdateData(info)
    local _item = self.Items[info.id]
    if _item ~= nil then
        _item:RefreshData(info)
    else
        _item = L_AuctionItem.Get()
        _item:RefreshData(info)
        self.Items:Add(info.id, _item)
    end
end
-- Delete an object
function AuctionHouseSystem:RemoveData(id)
    local _item = self.Items[id]
    if _item ~= nil then
        L_AuctionItem.Free(_item)
        self.Items:Remove(id)
    end
end

local function CovertCareMatchId(itemId)
    local _eqCfg = DataConfig.DataEquip[itemId]
    if _eqCfg ~= nil then
        local _occ = Utils.SplitNumber(_eqCfg.Gender, '_')[1]
        local _grade = _eqCfg.Grade
        local _part = _eqCfg.Part
        local _quality = _eqCfg.Quality
        return _occ * 1000000000 + _grade * 100000000 + _quality * 1000000 + _part * 10000
    end
    return itemId
end

-- Is it the material of concern?
function AuctionHouseSystem:IsCareItem(item)
    if item.OwnerGuild > 0 then
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if _lp == nil then
            return false
        end
        if _lp.GuildID ~= item.OwnerGuild then
            return false
        end
    end
    return self.CareItemMatchValues[CovertCareMatchId(item.CfgID)] ~= nil
end

-- Read the following configuration
function AuctionHouseSystem:LoadCareData()
    if self.IsLoadCareData then
        return
    end
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end
    self.IsLoadCareData = true
    local _param = PlayerPrefs.GetString(string.format("NewAuctionCareData2_%d", _lp.ID), "")
    if _param == nil or string.len(_param) <= 0 then
        return
    end
    local _numberTable = Utils.SplitNumber(_param, ';')
    self.CareItemList = {}
    self.CareItemMatchValues = {}
    for i = 1, #_numberTable do
        local _itemId = _numberTable[i]
        self.CareItemList[_itemId] = true
        self.CareItemMatchValues[CovertCareMatchId(_itemId)] = true
    end
    self.CareItemCount = #_numberTable
end

-- Save the following configuration
function AuctionHouseSystem:SaveCareData()
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end
    self.CareItemMatchValues = {}
    local _saveText = ""
    local _count = 0
    for k, _ in pairs(self.CareItemList) do
        _saveText = _saveText .. k ..';'
        _count = _count + 1
        self.CareItemMatchValues[CovertCareMatchId(k)] = true
    end
    self.CareItemCount = _count
    PlayerPrefs.SetString(string.format("NewAuctionCareData2_%d", _lp.ID), _saveText)
end

return AuctionHouseSystem