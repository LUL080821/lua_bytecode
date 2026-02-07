-- Author:
-- Date: 2025-10-21
-- File: LianQiForgeBagSystem.lua
-- Module: LianQiForgeBagSystem
-- Description: This system handles all forging-related features for equipment in the bag, including enhancement, appraisal, washing, and other refining operations.
------------------------------------------------
local LianQiForgeBagSystem = {
    StrengthItemLevelDic = nil, -- key = itemID, value = { level, proficiency }
    ItemAppraiseInfoDic  = nil, -- key = itemID, value = List<L_EquipAppraiseInfo>
    ItemSpecialInfoDic   = nil, -- key = itemID, value = List<L_EquipSpecialInfo>
    ItemWashInfoDic      = nil, -- key = itemID, value = List<L_EquipWashInfo>

    -- Lưu level cường hóa cho mỗi item auction
    ItemStrengthLevelMap = Dictionary:New()
}

-- Equipment refining information (1 piece of equipment contains 5 pieces of refining information)
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

function LianQiForgeBagSystem:Initialize()
    self.StrengthItemLevelDic = Dictionary:New()
    self.ItemAppraiseInfoDic = Dictionary:New()
    self.ItemSpecialInfoDic = Dictionary:New()
    self.ItemWashInfoDic = Dictionary:New()
    --GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_RESEQUIPPARTINFO, self.ResEquipPartInfo, self);
end

function LianQiForgeBagSystem:UnInitialize()
    self.StrengthItemLevelDic:Clear()
    self.ItemAppraiseInfoDic:Clear()
    self.ItemSpecialInfoDic:Clear()
    self.ItemWashInfoDic:Clear()
    --GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_RESEQUIPPARTINFO, self.ResEquipPartInfo, self);
end

function LianQiForgeBagSystem:GS2U_ResItemInfoBags(result)

    Debug.Log("resultresultresultresultresultresult====", Inspect(result))

    local infoList = List:New(result.bagInfos)
    self:HandleAppraiseInfos(infoList)
    self:HandleSpecialInfos(infoList)
    self:HandleStrengthInfos(infoList)
    self:HandleWashInfos(infoList)

    -- Update mảng khảm gem lúc load game
    GameCenter.LianQiGemSystem:InitGemInlayInfoByBagInfos(result.bagInfos)

end


-------------------------------------------------------------------------------------------------

local BagChangeType = {
    ADD_OR_UPDATE = 1,  -- thêm mới hoặc update item
    REMOVE        = 2,  -- remove / move khỏi bag
    -- SELL       = 3,  -- sau này có thì thêm
}


--- CUSTOM FUNCTION TO CALL TO UPDATE DATA RELATED CLASS ------------------------------------------

function LianQiForgeBagSystem:UpdateGemInfoByBagItem(bagInfo)
    if not bagInfo or not bagInfo.info then
        return
    end

    local info    = bagInfo.info
    local equip   = info.equip
    local gemInfo = info.gemInfo

    if equip and equip.itemId and gemInfo then
        GameCenter.LianQiGemSystem:UpdateGemInfoByItem(
            equip.itemId,
            gemInfo,
            nil
        )
    end
end


function LianQiForgeBagSystem:UpdatePartInfoByBagItem(bagInfo)
    if not bagInfo or not bagInfo.info then
        return
    end

    local info = bagInfo.info
    local partType = info.type

    -- Update appraise theo part
    GameCenter.LianQiForgeSystem:UpdatePartAppraiseByBagInfo(
        bagInfo,
        partType
    )

    -- Update special theo part
    GameCenter.LianQiForgeSystem:UpdatePartSpecialByBagInfo(
        bagInfo,
        partType
    )

    -- Update gem theo part
    if info.gemInfo and info.equip then
        GameCenter.LianQiGemSystem:UpdateGemInfoByPart(
            partType,
            info.gemInfo
        )
    end
end

function LianQiForgeBagSystem:UpdateItemStrengthLevel(bagInfo)
    if not bagInfo or not bagInfo.info then
        return
    end

    local strengthInfo = bagInfo.info.strengthInfo
    local itemId = bagInfo.itemId
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
function LianQiForgeBagSystem:GetItemStrengthLevel(itemId)
    return self.ItemStrengthLevelMap[itemId]
end


-------------------END CUSTOM-------------------------------------------------------------------

function LianQiForgeBagSystem:GS2U_ResItemInfoBagChange(result)
    local type = result.type
    local itemId = result.bagInfo.itemId
    Debug.Log(
            "[GS2U_ResItemInfoBagChange] Unknown changeType ================ ",
            Inspect(result)
        )
    local itemInfo = (result.bagInfo and result.bagInfo.info) or nil
    if type == BagChangeType.ADD_OR_UPDATE then
        -- handle Add or Update Item
        self:SetStrengthInfoByItem(itemId, itemInfo)
        self:SetAppraiseInfoByItem(itemId, itemInfo)
        self:SetSpecialInfoByItem(itemId, itemInfo)
        self:SetWashInfoByItem(itemId, itemInfo)

        
        -- cập nhật lại data của mảng khảm gem theo itemid

        self:UpdateGemInfoByBagItem(result.bagInfo)


        -- sửa lại cập nhật cấp cường hóa trong túi:
        local itemBase = GameCenter.ItemContianerSystem:GetItemByUIDFormBag(itemId)
        if itemBase then
            GameCenter.PushFixEvent(LogicEventDefine.EVENT_BACKFORM_ITEM_UPDATE, itemBase)
        end

    elseif type == BagChangeType.REMOVE then
        -- handle Remove Item
        self.StrengthItemLevelDic:Remove(itemId)
        self.ItemAppraiseInfoDic:Remove(itemId)
        self.ItemSpecialInfoDic:Remove(itemId)
        self.ItemWashInfoDic:Remove(itemId)

        -- Cập nhật lại part cho đúng data của giám định

        self:UpdatePartInfoByBagItem(result.bagInfo)
    else
        Debug.Log(
            "[GS2U_ResItemInfoBagChange] Unknown changeType = ",
            type
        )
 

    end
end

-- ========================== Handle Strength =======================

---Get all strengthening info for a specific item by itemId
---@param itemId: DBID
---@return: Dictionary<_attrID, { Value = _realValue, Level = level }>
function LianQiForgeBagSystem:GetAllStrengthAttrDicByItemId(itemId, strengthLevel)
    --- Result data: {{ _attrID, { Value = _realValue, Level = level }}}

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

-- Update strength info dictionary based on server data
function LianQiForgeBagSystem:HandleStrengthInfos(infos)
    local count = Utils.GetTableLens(infos)
    if not infos or count == 0 then
        return
    end

    for i = 1, count do
        local item = infos[i]
        local itemId = item.itemId
        local detail = item.info
        -------------------------
        local strengthInfo = detail and detail.strengthInfo
        if strengthInfo then
            local _part = strengthInfo.type or detail.type
            local levelInfo = {
                type  = _part,
                level = strengthInfo.level or 0,
                exp   = strengthInfo.exp or 0,
            }
            --
            if self.StrengthItemLevelDic:ContainsKey(itemId) then
                self.StrengthItemLevelDic[itemId] = levelInfo
            else
                self.StrengthItemLevelDic:Add(itemId, levelInfo)
            end
        end
    end
end

-- Update strength info Dic by ItemId
function LianQiForgeBagSystem:SetStrengthInfoByItem(itemId, itemInfo)
    if not (itemId and itemInfo) then
        return
    end

    local strengthInfo = itemInfo.strengthInfo
    if strengthInfo then
        local _part = strengthInfo.type or itemInfo.type
        local levelInfo = {
            type  = _part,
            level = strengthInfo.level or 0,
            exp   = strengthInfo.exp or 0,
        }

        if self.StrengthItemLevelDic:ContainsKey(itemId) then
            self.StrengthItemLevelDic[itemId] = levelInfo
        else
            self.StrengthItemLevelDic:Add(itemId, levelInfo)
        end
    end
end

function LianQiForgeBagSystem:GetCfgID(part, level)
    return (part + 100) * 1000 + level
end

function LianQiForgeBagSystem:GetStrengthLvByItemId(itemID)
    if self.StrengthItemLevelDic and self.StrengthItemLevelDic:ContainsKey(itemID) then
        return self.StrengthItemLevelDic[itemID].level or 0
    end
    return 0
end
-- ==================================================================

-- ========================== Handle Special =======================

-- Get all special info for a specific item by itemId
-- Return: Dictionary<Index, { AttrID = attrId, Value = value, Percent = percent }>
function LianQiForgeBagSystem:GetAllSpecialAttrDicByItemId(itemId)
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

    -- Iterate all special lines
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
                Debug.LogError("[LDebug] [GetAllSpecialAttrDicByItemId]", string.format("Invalid pool info for itemId=%s, poolId=%s", tostring(itemId), tostring(poolId)))
            end
        end
    end

    return _retAttrDic
end

-- Update special info by ItemId 
function LianQiForgeBagSystem:SetSpecialInfoByItem(itemId, itemInfo)
    if not (itemId and itemInfo) then
        return
    end
    local specialInfos = itemInfo and itemInfo.attrSpecial
    if specialInfos then
        local _specialInfos = List:New()
        local _rawSpecialInfos = List:New(specialInfos, true)
        for j = 1, #_rawSpecialInfos do
            local _data = Utils.DeepCopy(L_EquipSpecialInfo)
            _data.Index = _rawSpecialInfos[j].index
            _data.Value = _rawSpecialInfos[j].value
            _data.Percent = _rawSpecialInfos[j].per
            _data.PoolID = _rawSpecialInfos[j].poolId or INVALID_POOL_ID
            _specialInfos:Add(_data)
        end
        _specialInfos:Sort(function(a, b)
            return a.Index < b.Index
        end)
        if #_specialInfos > 0 then
            if not self.ItemSpecialInfoDic:ContainsKey(itemId) then
                self.ItemSpecialInfoDic:Add(itemId, _specialInfos)
            else
                self.ItemSpecialInfoDic[itemId] = _specialInfos
            end
        else
            self.ItemSpecialInfoDic[itemId] = _specialInfos
        end
    end

end

function LianQiForgeBagSystem: HandleSpecialInfos(infos)

    -- print("==== DEBUG infos ====", Inspect(infos))

    if not infos or Utils.GetTableLens(infos) == 0 then
        return
    end

    for i = 1, #infos do
        local item = infos[i]
        if not item then goto continue end

        local itemId = item.itemId
        local detail = item.info      

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
-- ==================================================================

-- ========================== Handle Appraise =======================

-- Get all appraisal info for a specific item by itemId
-- Return: Dictionary<Index, { AttrID = attrId, Value = value, Percent = percent }>
function LianQiForgeBagSystem:GetAllAppraiseAttrDicByItemId(itemId)
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
                Debug.LogError("[LDebug] [GetAllAppraiseAttrDicByItemId]", string.format("Invalid pool info for itemId=%s, poolId=%s", tostring(itemId), tostring(poolId)))
            end
        end
    end

    return _retAttrDic
end

-- Update appraisal info by ItemId 
function LianQiForgeBagSystem:SetAppraiseInfoByItem(itemId, itemInfo)
    if not (itemId and itemInfo) then
        return
    end

    local appraisalInfos = itemInfo and itemInfo.raisalInfo
    if appraisalInfos then
        local _appraiseInfos = List:New()
        local _rawAppraiseInfos = List:New(appraisalInfos, true)
        for j = 1, #_rawAppraiseInfos do
            local _data = Utils.DeepCopy(L_EquipAppraiseInfo)
            _data.Index = _rawAppraiseInfos[j].index
            _data.Value = _rawAppraiseInfos[j].value
            _data.Percent = _rawAppraiseInfos[j].per
            _data.PoolID = _rawAppraiseInfos[j].poolId or INVALID_POOL_ID
            _appraiseInfos:Add(_data)
        end
        _appraiseInfos:Sort(function(a, b)
            return a.Index < b.Index
        end)
        if #_appraiseInfos > 0 then
            if not self.ItemAppraiseInfoDic:ContainsKey(itemId) then
                self.ItemAppraiseInfoDic:Add(itemId, _appraiseInfos)
            else
                self.ItemAppraiseInfoDic[itemId] = _appraiseInfos
            end
        else
            self.ItemAppraiseInfoDic[itemId] = _appraiseInfos
        end
    end

end

-- Update appraisal info dictionary based on server data


function LianQiForgeBagSystem: HandleAppraiseInfos(infos)

    -- print("==== DEBUG infos ====", Inspect(infos))

    if not infos or Utils.GetTableLens(infos) == 0 then
        return
    end

    for i = 1, #infos do
        local item = infos[i]
        if not item then goto continue end

        local itemId = item.itemId
        local detail = item.info      

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



-- Hàm mới sửa lại theo đúng cấu trúc dữ liệu của server gởi về:
-- function LianQiForgeBagSystem:HandleAppraiseInfos(raw)

--     if not raw then
--         print("HandleAppraiseInfos: raw == nil -> return")
--         return
--     end

--     local bagInfos = raw.bagInfos or raw
--     if not bagInfos or #bagInfos == 0 then
--         print("HandleAppraiseInfos: bagInfos nil or empty -> return")
--         return
--     end

--     if not self.ItemAppraiseInfoDic then
--         self.ItemAppraiseInfoDic = Dictionary:New()
--     end

--     for i = 1, #bagInfos do
--         local bagItem = bagInfos[i]
--         if not bagItem then
--             print("HandleAppraiseInfos: bagItem nil at index", i)
--             goto continue
--         end

--         local itemId = bagItem.itemId
--         if not itemId then
--             print("HandleAppraiseInfos: missing itemId", Inspect(bagItem))
--             goto continue
--         end

--         local infos = bagItem.infos
--         if not infos or #infos == 0 then
--             print("HandleAppraiseInfos: infos empty for itemId", itemId)
--             goto continue
--         end

--         local detail = infos[1]
--         if not detail then
--             print("HandleAppraiseInfos: detail nil for itemId", itemId)
--             goto continue
--         end

--         local appraisalInfos = detail.raisalInfo or detail.appraisalInfo
--         if appraisalInfos and #appraisalInfos > 0 then

--             local appraiseList = List:New()
--             for j = 1, #appraisalInfos do
--                 local src = appraisalInfos[j]
--                 if src then
--                     local dst = Utils.DeepCopy(L_EquipAppraiseInfo)
--                     dst.Index   = src.index or 0
--                     dst.Value   = src.value or 0
--                     dst.Percent = src.per or src.percent or 0
--                     dst.PoolID  = src.poolId or INVALID_POOL_ID
--                     appraiseList:Add(dst)
--                 end
--             end

--             appraiseList:Sort(function(a, b) return a.Index < b.Index end)
--             self.ItemAppraiseInfoDic[itemId] = appraiseList

--             -- print(("HandleAppraiseInfos: saved %d appraise entries for itemId=%s"):format(#appraiseList, tostring(itemId)))
--         else
--             print("HandleAppraiseInfos: no appraise data for itemId", itemId)
--         end

--         ::continue::
--     end

--     print("==== HandleAppraiseInfos END ====")
--     print("ItemAppraiseInfoDic:", Inspect(self.ItemAppraiseInfoDic))
-- end


-- Hàm mới chỉnh sửa để update mảng giá trị lúc khảm thành công:
-- ============================================================
-- Update hoặc thêm mới appraisal info cho 1 itemId
-- Gọi hàm này từ LianQiForgeSystem khi khảm thành công
-- ============================================================
function LianQiForgeBagSystem:AddOrUpdateAppraiseInfos(itemId, rawAppraiseInfos)
    if not itemId then
        -- print("[AddOrUpdateAppraiseInfos] itemId nil -> return")
        return
    end

    if not rawAppraiseInfos or #rawAppraiseInfos == 0 then
        -- print("[AddOrUpdateAppraiseInfos] rawAppraiseInfos empty for itemId", itemId)
        return
    end

    -- Khởi tạo dictionary nếu chưa có
    if not self.ItemAppraiseInfoDic then
        self.ItemAppraiseInfoDic = Dictionary:New()
    end

    -- Tạo list mới
    local newList = List:New()

    for i = 1, #rawAppraiseInfos do
        local src = rawAppraiseInfos[i]
        if src then
            local dst = Utils.DeepCopy(L_EquipAppraiseInfo)
            dst.Index   = src.index or 0
            dst.Value   = src.value or 0
            dst.Percent = src.per or src.percent or 0
            dst.PoolID  = src.poolId or INVALID_POOL_ID
            newList:Add(dst)
        end
    end

    newList:Sort(function(a, b) return a.Index < b.Index end)

    -- Update Dic
    self.ItemAppraiseInfoDic[itemId] = newList

    -- print(("[AddOrUpdateAppraiseInfos====================] Updated %d entries for itemId=%s") :format(#newList, tostring(itemId)))
end


function LianQiForgeBagSystem:MergeAndUpdateFromResult(result)
    if not result or #result == 0 then
        -- print("[MergeAndUpdateFromResult] result empty -> return")
        return
    end

    -- Init dictionary nếu chưa có
    if not self.ItemAppraiseInfoDic then
        self.ItemAppraiseInfoDic = Dictionary:New()
    end

    -- Gom nhóm theo itemId
    local groups = {} -- groups[itemId] = { entries }

    for _, entry in ipairs(result) do
        local itemId = entry.itemId
        if itemId then
            if not groups[itemId] then
                groups[itemId] = {}
            end
            table.insert(groups[itemId], entry)
        end
    end

    -- Với mỗi itemId → convert & update Dic
    for itemId, entries in pairs(groups) do
        local newList = List:New()

        for _, src in ipairs(entries) do
            local dst = Utils.DeepCopy(L_EquipAppraiseInfo)
            dst.Index   = src.index or 0
            dst.Value   = src.value or 0
            dst.Percent = src.per or src.percent or 0
            dst.PoolID  = src.poolId or INVALID_POOL_ID
            newList:Add(dst)
        end

        -- Sort
        newList:Sort(function(a, b)
            return a.Index < b.Index
        end)

        -- Update dictionary
        self.ItemAppraiseInfoDic[itemId] = newList

        -- print(string.format(
        --     "[MergeAndUpdateFromResult] Updated %d entries for itemId=%s",
        --     #newList, tostring(itemId)
        -- ))
    end
end






-- ==================================================================

-- ========================== Handle Wash ===========================

-- Get all washing attributes of an item by itemId
-- Return: Dictionary<Index, { AttrID = attrId, Value = value, Percent = percent }>
function LianQiForgeBagSystem:GetAllWashAttrDicByItemId(itemId)
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

-- Update wash info dictionary based on server data
function LianQiForgeBagSystem:HandleWashInfos(infos)
    local count = Utils.GetTableLens(infos)
    if not infos or count == 0 then
        return
    end

    for i = 1, count do
        local item = infos[i]
        local itemId = item.itemId
        local detail = item.info
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

-- Update wash info by ItemId
function LianQiForgeBagSystem:SetWashInfoByItem(itemId, itemInfo)
    if not (itemId and itemInfo) then
        return
    end

    local _washInfos = List:New()
    local _rawWashInfos = List:New(itemInfo.washInfo, true)
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

-- ==================================================================

return LianQiForgeBagSystem