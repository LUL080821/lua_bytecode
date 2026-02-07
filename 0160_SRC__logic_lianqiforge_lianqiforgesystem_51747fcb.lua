-- Author:
-- Date: 2019-04-26
-- File: LianQiForgeSystem.lua
-- Module: LianQiForgeSystem
-- Description: 1. This system is: the sub-function forging system of the refining function (currently only equipment enhancement. It may be increased in the future. Such as equipment X-ray, equipment Y-ray, etc.)
-- (There is another sub-function of refining tools, gems)
-- 2. The panel is: UILianQiForgeForm (currently only 1 paging: Equipment Enhancement)
------------------------------------------------

local RedPointItemCondition = CS.Thousandto.Code.Logic.RedPointItemCondition;
local RedPointLevelCondition = CS.Thousandto.Code.Logic.RedPointLevelCondition;
local LianQiForgeSystem = {
    StrengthPosLevelDic    = nil, -- Equipment Enhanced Dictionary, key = location, value = {level, proficiency}
    StrengthNeedItemIdList = nil, -- ID list of items that need to be consumed with equipment enhancement
    StrengthMaxLevel       = 0,

    PosAppraiseInfoDic     = nil, -- Key = pos, value = List<L_EquipAppraiseInfo>
    PosSpecialInfoDic      = nil, -- Key = pos, value = List<L_EquipSpecialInfo>

    PosWashPreviewDic      = nil, -- key = pos, value = List<L_EquipWashInfo> (preview only)
    PosWashInfoDic         = nil, -- Equipment Refining Information Dictionary, key = part, value = List<L_EquipWashInfo>
    WashItemCostDic        = nil, -- Dictionary of props required for equipment washing, key = number of locks, value = L_EquipWashItemInfo
    --WashNeedMoneyType      = { 2, 1 }, -- The money type required for equipment washing (1. Ingot 2. Bind ingot 3. Bind gold coins), same as ItemID, priority is used for binding ingot
    WashNeedItemIDList     = nil, -- List of prop IDs required for equipment refining (for red dot monitoring)
    WashScoreCulcWeight    = 10000, -- Calculate weight of equipment refining score
    isUseNewWashRule       = true, -- Flag switch rule
    WashMaxIndex           = 5, -- Equipment refining, the largest number of refining items for one piece of equipment
    WashIndexLimitDic      = Dictionary:New(), -- Refining grid opening conditions
    WashLastIndexLimit     = 0, -- Refining the conditions required to open the last grid
    VipDiscountCfgList     = List:New(),

    EquipPartByItemIdDic   = Dictionary:New() -- mảng để lưu xem item id - tương ứng với part nào
}

local INVALID_POOL_ID = 0
-- Equipment refining information (1 piece of equipment contains 5 pieces of refining information)
local L_EquipWashInfo = {
    Index   = 0, -- Entry index
    Value   = 0, -- The blessing value of this entry
    Percent = 0, -- The attribute of this entry plays a tens of percent ratio and displays a decimal number.
    PoolID  = INVALID_POOL_ID, -- Index of pool
}
-- Props and quantity information required for equipment refining
local L_EquipWashItemInfo = {
    ItemID  = 0, -- Required prop ID
    NeedNum = 0, -- Required quantity
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

function LianQiForgeSystem:Initialize()
    self.StrengthPosLevelDic = Dictionary:New()
    self.StrengthMaxLevel = 285--DataConfig.DataEquipIntenMain[#DataConfig.DataEquipIntenMain].Level
    self.StrengthNeedItemIdList = List:New()

    self.PosAppraiseInfoDic = Dictionary:New()
    self.PosSpecialInfoDic = Dictionary:New()

    self.WashMaxIndex = 5
    self.PosWashInfoDic = Dictionary:New()
    self.PosWashPreviewDic = Dictionary:New()
    self.WashItemCostDic = Dictionary:New()
    self.WashNeedItemIDList = List:New()
    self:InitVipCfg()
    --self.WashScoreCulcWeight = tonumber(DataConfig.DataGlobal[1539].Params)
    --self.WashGetBestAttrScore = tonumber(DataConfig.DataGlobal[1540].Params)
    -- Initialize the equipment and props consumption dictionary, key = number of locks, value = Utils.DeepCopy(L_EquipWashItemInfo)
    local tt = DataConfig.DataGlobal[1536].Params
    local _itemsList = Utils.SplitStrByTableS(DataConfig.DataGlobal[1536].Params)
    if _itemsList then
        for i = 1, #_itemsList do
            if _itemsList[i] then
                local _itemID = tonumber(_itemsList[i][1])
                local _lockCount = tonumber(_itemsList[i][2])
                local _itemNeedNum = tonumber(_itemsList[i][3])
                if _lockCount then
                    if not self.WashItemCostDic:ContainsKey(_lockCount) then
                        local _washItemInfo = Utils.DeepCopy(L_EquipWashItemInfo)
                        _washItemInfo.ItemID = _itemID
                        _washItemInfo.NeedNum = _itemNeedNum
                        self.WashItemCostDic:Add(_lockCount, _washItemInfo)
                    end
                end
                if _itemID then
                    if not self.WashNeedItemIDList:Contains(_itemID) then
                        self.WashNeedItemIDList:Add(_itemID)
                    end
                end
            end
        end
    end
    -- Initialize the cleaning grid opening conditions
    self.WashIndexLimitDic:Clear()
    local _cfg = DataConfig.DataGlobal[GlobalName.Equip_washing_conditions] -- 1_3;2_3;3_4;4_5;5_6
    local _cfg1 = DataConfig.DataGlobal[GlobalName.Equip_washing_conditions_Num_4] -- 1_0;2_0;3_0;4_0
    local _cfg2 = DataConfig.DataGlobal[GlobalName.Equip_washing_conditions_Num_5] -- 5_5
    if _cfg then
        self:SetUseNewWashRule(true)
        local _conArr = Utils.SplitStr(_cfg.Params, ';')
        for i = 1, #_conArr do
            local _ar = Utils.SplitNumber(_conArr[i], '_')
            self.WashIndexLimitDic:Add(_ar[1], _ar[2])
        end
    end
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_WEAREQUIPSUC, self.SetStrengthRedPoint, self);
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_UNWEAREQUIPSUC, self.SetStrengthRedPoint, self);
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_RESEQUIPPARTINFO, self.ResEquipPartInfo, self);
end

function LianQiForgeSystem:UnInitialize()
    self.StrengthPosLevelDic:Clear()
    self.StrengthNeedItemIdList:Clear()
    self.PosAppraiseInfoDic:Clear()
    self.PosSpecialInfoDic:Clear()
    self.EquipPartByItemIdDic:Clear()
    self.PosWashInfoDic:Clear()
    self.PosWashPreviewDic:Clear()
    self.WashItemCostDic:Clear()
    self.WashNeedItemIDList:Clear()
    self.VipDiscountCfgList:Clear()
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_WEAREQUIPSUC, self.SetStrengthRedPoint, self);
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_UNWEAREQUIPSUC, self.SetStrengthRedPoint, self);
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_RESEQUIPPARTINFO, self.ResEquipPartInfo, self);
end
function LianQiForgeSystem:InitVipCfg()
    self.VipDiscountCfgList:Clear()
    DataConfig.DataVIPTrueRecharge:Foreach(function(k, v)
        if v.TrueRewardPowerPra and string.len(v.TrueRewardPowerPra) > 0 then
            local _disCount = 0
            local _ar = Utils.SplitStr(v.TrueRewardPowerPra, ';')
            for i = 1, #_ar do
                local _single = Utils.SplitNumber(_ar[i], '_')
                if #_single >= 3 and _single[1] == 29 then
                    _disCount = _single[3]
                end
            end
            if _disCount > 0 then
                local data = { RechargeNum = v.RechargeLimit, DisCount = _disCount }
                self.VipDiscountCfgList:Add(data)
            end
        end
    end)
end

-- Get current VIP privilege discount
function LianQiForgeSystem:GetCurDisCount()
    local _disCount = 10
    local _cfg = DataConfig.DataVIPTrueRecharge[GameCenter.VipSystem:GetCurTrueVipCfgId()]
    if _cfg then
        if _cfg.TrueRewardPowerPra and string.len(_cfg.TrueRewardPowerPra) > 0 then
            local _ar = Utils.SplitStr(_cfg.TrueRewardPowerPra, ';')
            for i = 1, #_ar do
                local _single = Utils.SplitNumber(_ar[i], '_')
                if #_single >= 3 and _single[1] == 29 then
                    _disCount = _single[3]
                end
            end
        end
    end
    return _disCount
end
function LianQiForgeSystem:ResEquipPartInfo(obj, sender)
    --obj = msg
    local infoList = List:New(obj.infos)
    self:GS2U_ResEquipStrengthInfo(infoList)
    self:GS2U_ResEquipAppraiseInfo(infoList)
    self:GS2U_ResEquipSpecialInfo(infoList)
    self:GS2U_ResEquipWashInfo(infoList)

end

function LianQiForgeSystem:SetEquipmentForge(result)
    local type = result.type
    local itemInfo = (result.bagInfo and result.bagInfo.info) or nil
    if type == 2 then
        local part = (itemInfo and itemInfo.type) or nil
        self:SetStrengthInfoByPart(part, itemInfo)
        self:SetWashInfoByPart(part, itemInfo)
    end
end

-- ==================== Begin Forge Handle =====================
function LianQiForgeSystem:GetAutoUpPos()
    local _pos = 0
    local _level = -1
    for i = 0, EquipmentType.Count - 1 do
        local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(i)
        if _equip and self.StrengthPosLevelDic[i] then
            local _strenthInfo = self.StrengthPosLevelDic[i]
            -- The highest level of enhancement of current equipment
            local _equipIntenMaxLv = _equip.ItemInfo.LevelMax
            if _strenthInfo.level < _equipIntenMaxLv then
                if (_strenthInfo.level < _level or _level == -1) and GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.LianQiForgeStrength, i) then
                    _level = _strenthInfo.level
                    _pos = i
                end
            end
        end
    end
    return _pos
end
-- Red dot related
function LianQiForgeSystem:SetStrengthRedPoint()
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.LianQiForgeStrength);
    for i = 0, EquipmentType.Count - 1 do
        self:IsStrengthMoneyEnoughByPos(i)
    end
end

function LianQiForgeSystem:IsStrengthMoneyEnoughByPos(pos, equip)
    local _equip = nil
    if not equip then
        _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(pos)
    else
        _equip = equip
    end
    if _equip and self.StrengthPosLevelDic[pos] then
        local _strenthInfo = self.StrengthPosLevelDic[pos]
        -- The highest level of enhancement of current equipment
        local _equipIntenMaxLv = _equip.ItemInfo.LevelMax
        if _strenthInfo.level < _equipIntenMaxLv then
            local _cfgID = self:GetCfgID(pos, _strenthInfo.level)
            local _cfg = DataConfig.DataEquipIntenMain[_cfgID]
            if _cfg then
                -- Item Conditions
                local _conditions = List:New();
                local _itemArr = Utils.SplitStr(_cfg.Consume, ';')
                for i = 1, #_itemArr do
                    local _singleArr = Utils.SplitNumber(_itemArr[i], '_')
                    _conditions:Add(RedPointItemCondition(_singleArr[1], _singleArr[2]));
                end
                GameCenter.RedPointSystem:LuaAddFuncCondition(FunctionStartIdCode.LianQiForgeStrength, pos, _conditions);
            end
        end
    end
end

function LianQiForgeSystem:SetStrengthInfoByPart(part, itemInfo)
    if not (part and itemInfo) then
        return
    end

    local strengthInfo = itemInfo.strengthInfo
    if strengthInfo then
        local _part = part or itemInfo.type or strengthInfo.type
        local levelInfo = {
            type  = _part,
            level = strengthInfo.level or 0,
            exp   = strengthInfo.exp or 0,
        }

        if self.StrengthPosLevelDic:ContainsKey(part) then
            self.StrengthPosLevelDic[part] = levelInfo
        else
            self.StrengthPosLevelDic:Add(part, levelInfo)
        end
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_CHANGE_EQUIPMAXSTRENGTHLV, { _part, levelInfo.level })
    end
end

-- All parts reinforcement information will be returned and will be sent once when online. If the equipment is updated (the upper limit is enhanced), the message will also be synchronized once.
function LianQiForgeSystem:GS2U_ResEquipStrengthInfo(infos)
    local count = Utils.GetTableLens(infos)
    if infos ~= nil then
        for i = 1, count do
            if infos[i].strengthInfo then
                local _type = infos[i].strengthInfo.type or infos[i].type
                local levelInfo = { level = infos[i].strengthInfo.level or 0, exp = infos[i].strengthInfo.exp or 0 }
                if self.StrengthPosLevelDic:ContainsKey(_type) then
                    self.StrengthPosLevelDic[_type] = levelInfo
                else
                    self.StrengthPosLevelDic:Add(_type, levelInfo)
                end
                GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_CHANGE_EQUIPMAXSTRENGTHLV, { _type, levelInfo.level })
            end
        end
        if count > 0 and infos[1].strengthInfo ~= nil then
            -- If the current update is reinforcement information
            self:SetStrengthRedPoint()
        end
    end
end

-- Request for strengthening, pos is the location, isOneKey indicates whether to strengthen with one click
function LianQiForgeSystem:ReqEquipStrengthUpLevel(type, infos)
    local _req = ReqMsg.MSG_Equip.ReqEquipStrengthUpLevel:New()
    _req.type = type
    _req.upInfos = infos
    _req:Send()
    -- GameCenter.Network.Send("MSG_Equip.ReqEquipStrengthUpLevel", { type = pos })
end

-- Strengthen return
function LianQiForgeSystem:GS2U_ResEquipStrengthUpLevel(result)
    if self.StrengthPosLevelDic:ContainsKey(result.info.type) then
        --local oldLevel = self.StrengthPosLevelDic[result.info.type].level
        self.StrengthPosLevelDic[result.info.type].level = result.info.level
        self.StrengthPosLevelDic[result.info.type].exp = result.info.exp
    end
    self:SetStrengthRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_ALLINFO, result)
end

-- CUSTOM - thêm RQ tách CH
function LianQiForgeSystem:ReqEquipSplitLevel(pos, oneKey)
    local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(pos)
    if _equip and _equip.DBID then
        GameCenter.Network.Send("MSG_Equip.ReqEquipSplitLevel", { part = _equip:GetPart(), equipId = _equip.DBID })
    end
end
-- CUSTOM - thêm RQ tách CH

-- CUSTOM - thêm RES tách CH
function LianQiForgeSystem:GS2U_ResEquipSplitLevel(result)
    if self.StrengthPosLevelDic:ContainsKey(result.info.type) then
        result.info.level = 0
        self.StrengthPosLevelDic[result.info.type].level = result.info.level
        self.StrengthPosLevelDic[result.info.type].exp = result.info.exp
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_ALLINFO, result)
end
-- CUSTOM - thêm RES tách CH

function LianQiForgeSystem:GetAllStrengthAttrDicByPart(part, strengthLevel)
    --- Result data: {{ _attrID, { Value = _realValue, Level = 0 }}}

    local _retAttrDic = Dictionary:New()
    local strengthLevels = self.StrengthPosLevelDic
    if (not part) or (not strengthLevels) then
        return _retAttrDic
    end

    local _useLevel = 0
    if strengthLevel then
        _useLevel = strengthLevel
    elseif (strengthLevels[part] and strengthLevels[part].level) then
        _useLevel = strengthLevels[part].level
    end

    local cfgID = self:GetCfgID(part, _useLevel)
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

-- Get the DataEquipIntenMain configuration table ID through the location (0,1,2...)
function LianQiForgeSystem:GetCfgID(pos, level)
    return (pos + 100) * 1000 + level
end

-- Obtain the total reinforcement level
function LianQiForgeSystem:GetTotalStrengthLv()
    local _totalLv = 0
    for k, v in pairs(self.StrengthPosLevelDic) do
        local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(k)
        if v ~= nil and _equip ~= nil then
            _totalLv = _totalLv + v.level
        end
    end
    return _totalLv
end

-- function LianQiForgeSystem:GetStrengthLvByPos(pos)
--     if self.StrengthPosLevelDic:ContainsKey(pos) then
--         do
--             return self.StrengthPosLevelDic[pos].level
--         end
--     end
--     return 0
-- end

-- phiên bản khỏi crash
function LianQiForgeSystem:GetStrengthLvByPos(pos)
    -- bảo vệ dictionary
    local dic = self.StrengthPosLevelDic
    if not dic then
        return 0
    end

    -- bảo vệ key
    if dic:ContainsKey(pos) then
        local data = dic[pos]
        if data and data.level then
            return data.level
        end
    end

    return 0
end


function LianQiForgeSystem:SetLabelColorByStrengthLevel(label, level)
    --[[if percent >= 0 and percent < 10 then
        -- white
        UIUtils.SetColor(label, 255 / 255, 255 / 255, 255 / 255, 1)
    elseif percent >= 10 and percent < 30 then
        -- green
        UIUtils.SetColor(label, 0 / 255, 255 / 255, 0 / 255, 1)
    elseif percent >= 30 and percent < 50 then
        -- blue
        UIUtils.SetColor(label, 0 / 255, 0 / 255, 255 / 255, 1)
    elseif percent >= 50 and percent < 70 then
        -- purple
        UIUtils.SetColor(label, 171 / 255, 0 / 255, 255 / 255, 1)
    elseif percent >= 70 and percent < 90 then
        -- gold
        UIUtils.SetColor(label, 255 / 255, 230 / 255, 0 / 255, 1)
    elseif percent >= 90 and percent <= 100 then
        -- red
        UIUtils.SetColor(label, 255 / 255, 50 / 255, 50 / 255, 1)
    end]]
    local _targetColor = Utils.GetTargetColor(ColorTargetType.Strength_Level, level, "#FFFFFF")
    UIUtils.SetColorByString(label, _targetColor)
end

--- Req Chuyển Cường Hóa
---@param part number: EquipmentType
---@param infos table: List<EquipStrengthUpInfo> {{index, itemId, value}}
---@param equipId number: DBID of targetItem
function LianQiForgeSystem:ReqEquipMoveLevel(part, infos, equipId)
    local _req = ReqMsg.MSG_Equip.ReqEquipMoveLevel:New()
    _req.part = part
    _req.upInfos = infos
    _req.equipId = equipId
    _req:Send()
end

function LianQiForgeSystem:GS2U_ResEquipMoveLevel(result)
    local info = result.info
    local part = result.part or info.type

    if self.StrengthPosLevelDic:ContainsKey(part) then
        self.StrengthPosLevelDic[part].exp = info.exp
        self.StrengthPosLevelDic[part].level = info.level
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MOVE_EQUIP_STRENGTH_LV, { part, info.level })
end

-- ===================== End Forge Handle ======================

-- ==================== Begin Appraise Handle ======================


function LianQiForgeSystem:AppraiseSetting()
    -- lấy cấu hình bùa và slot setting cho loại bùa
    local _glConfig = DataConfig.DataGlobal[GlobalName.Equip_Special]
    if _glConfig then
        return (_glConfig.Params)
    end
    return nil

end

function LianQiForgeSystem:AppraiseButtonSetting()
    -- lấy cấu hình được phép hiện nút
    local _glConfig = DataConfig.DataGlobal[GlobalName.Equip_Slot_Special_Open]
    if _glConfig then
        return (_glConfig.Params)
    end
    return nil

end

function LianQiForgeSystem:HasAppraiseInfoByPart(part)
    if not part or not self.PosAppraiseInfoDic then
        return false
    end
    local infos = self.PosAppraiseInfoDic[part]
    if not infos or #infos == 0 then
        return false
    end
    return true
end

-- Sends a request to perform equipment appraisal
function LianQiForgeSystem:ReqEquipAppraisal(itemId, type)
    local _req = ReqMsg.MSG_Equip.ReqEquipAppRaisal:New()
    _req.equipId = itemId
    _req.type = type
    _req:Send()
end

-- Get all the refining properties of the part through the part, return dictionary<key, value>, key = attribute configuration table id, value = {Value = value, PoolID = poolId, Percent = ten thousand percent}
function LianQiForgeSystem:GS2U_ResEquipAppraiseInfo(infos)
    local count = Utils.GetTableLens(infos)

    -- Mảng mapping itemId -> part
    if not self.EquipPartByItemIdDic then
        self.EquipPartByItemIdDic = Dictionary:New()  -- <itemId, part>
    else
        self.EquipPartByItemIdDic:Clear()
    end

    local result = {}

    if infos ~= nil then
        for i = 1, count do
            local _part = infos[i].type
            local _newAppraiseInfos = List:New()
            local _rawAppraiseInfos = List:New(infos[i].raisalInfo)

            local _equipId = 0

            if infos[i].equip and infos[i].equip.itemId then
                _equipId = infos[i].equip.itemId
                self.EquipPartByItemIdDic:Add(_equipId, _part)
            end

            -- print(" GS2U_ResEquipAppraiseInfo -> part:", _part, " itemId:", _equipId)

            if _rawAppraiseInfos then
                for j = 1, #_rawAppraiseInfos do
                    local _data = Utils.DeepCopy(L_EquipAppraiseInfo)
                    _data.Index = _rawAppraiseInfos[j].index
                    _data.Value = _rawAppraiseInfos[j].value
                    _data.Percent = _rawAppraiseInfos[j].per
                    _data.PoolID = _rawAppraiseInfos[j].poolId or INVALID_POOL_ID

                    -- print("_data==", Inspect(_data))

                    table.insert(result, {
                        itemId = _equipId,
                        index = _rawAppraiseInfos[j].index or 0,
                        value = _rawAppraiseInfos[j].value or 0,
                        per = _rawAppraiseInfos[j].per or 0,
                        poolId = _rawAppraiseInfos[j].poolId or INVALID_POOL_ID,
                    })

                    _newAppraiseInfos:Add(_data)
                end
            end
            _newAppraiseInfos:Sort(function(a, b)
                return a.Index < b.Index
            end)

            if #_newAppraiseInfos > 0 then
                if not self.PosAppraiseInfoDic:ContainsKey(_part) then
                    self.PosAppraiseInfoDic:Add(_part, _newAppraiseInfos)
                else
                    self.PosAppraiseInfoDic[_part] = _newAppraiseInfos
                end
            else
                self.PosAppraiseInfoDic[_part] = _newAppraiseInfos
            end
        end
    end

    -- thực hiện sync data
    -- if next(result) then
    --     GameCenter.LianQiForgeBagSystem:MergeAndUpdateFromResult(result)
    -- end


    -- print(" GS2U_ResEquipAppraiseInfo  PosAppraiseInfoDic -> part:==========================", Inspect(self.PosAppraiseInfoDic))
end



-- Receives the preview attributes returned from the appRaisal request.
function LianQiForgeSystem:GS2U_ResEquipAppRaisalSuccess(result)
    -- TODO(A.DUC): handle API response

    -- print("======================== ==================", Inspect(result))

    if not result or not result.equipId then return end

    local itemId = result.equipId
    local _part = self.EquipPartByItemIdDic and self.EquipPartByItemIdDic[itemId]


    local _newAppraiseInfos = List:New()
    local _rawAppraiseInfos = List:New(result.raisalInfos)

    -- GameCenter.LianQiForgeBagSystem:AddOrUpdateAppraiseInfos(itemId, result.raisalInfos)

    if not _part then
        -- print((" Không tìm thấy part tương ứng với itemId=%s trong EquipPartByItemIdDic"):format(itemId))
        GameCenter.MsgPromptSystem:ShowPrompt(GosuSDK.GetLangString("MOSAIC_SUCCESS_TEXT"))
        return
    end

    -- print((" Cập nhật Appraise cho itemId=%s thuộc part=%s"):format(itemId, _part))

    if _rawAppraiseInfos then
        for i = 1, #_rawAppraiseInfos do
            local _data = Utils.DeepCopy(L_EquipAppraiseInfo)
            _data.Index = _rawAppraiseInfos[i].index
            _data.Value = _rawAppraiseInfos[i].value
            _data.Percent = _rawAppraiseInfos[i].per
            _data.PoolID = _rawAppraiseInfos[i].poolId or INVALID_POOL_ID
            _newAppraiseInfos:Add(_data)
        end
    end

    _newAppraiseInfos:Sort(function(a, b)
        return a.Index < b.Index
    end)

    -- Cập nhật lại dictionary theo part
    self.PosAppraiseInfoDic[_part] = _newAppraiseInfos

    -- print("==========_newAppraiseInfos====_part==", Inspect(_newAppraiseInfos))

    GameCenter.MsgPromptSystem:ShowPrompt(GosuSDK.GetLangString("MOSAIC_SUCCESS_TEXT"))


end


-- -- Hàm thực hiện update data cho part
function LianQiForgeSystem:UpdatePartAppraiseByBagInfo(bagInfo, part)
    -- print("==== bagInfo", Inspect(bagInfo))
    if not bagInfo or not bagInfo.itemId then
        return
    end

    local itemId = bagInfo.itemId
    local detail = bagInfo.info
    if not detail then
         -- Mặc item mới, chưa có info => tạo list rỗng cho part
        self.PosAppraiseInfoDic[part] = List:New()
        -- print("[LianQiForgeSystem] No detail info, init empty appraise list for part =", part)
        return
    end

    -- Tạo list mới
    local newList = List:New()
    local _rawAppraiseInfos = List:New(detail.raisalInfo)
    if _rawAppraiseInfos then
        for i = 1, #_rawAppraiseInfos do
            local src = _rawAppraiseInfos[i]
            if src then
                local data = Utils.DeepCopy(L_EquipAppraiseInfo)
                data.Index   = src.index
                data.Value   = src.value
                data.Percent = src.per
                data.PoolID  = src.poolId or INVALID_POOL_ID
                newList:Add(data)
            end
        end

        -- Sort theo Index
        newList:Sort(function(a, b)
            return a.Index < b.Index
        end)
    end

    -- Cập nhật lại dictionary theo part
    self.PosAppraiseInfoDic[part] = newList

    self.EquipPartByItemIdDic[itemId] = part
    -- print("[LianQiForgeSystem] Update EquipPartByItemIdDic: itemId =", itemId, "newPart =", part)

    -- print("[LianQiForgeSystem=================] bagInfobagInfobagInfo", part, "bagInfobagInfobagInfo =", Inspect(newList))
end


-- Through the part, obtain all the refining information in the part. pos = part, return a List (Count may = 0)
function LianQiForgeSystem:GetAppraiseInfoListByPos(part)
    local _ret = List:New()
    if self.PosAppraiseInfoDic:ContainsKey(part) then
        local _appraiseInfos = self.PosAppraiseInfoDic[part]
        _ret = _appraiseInfos
    end
    return _ret
end

-- Pass pos = part, and index = entry. Get the attribute information of the current entry, no nil is returned
function LianQiForgeSystem:GetAppraiseInfoByPartAndIndex(part, targetIndex)
    local _ret = nil
    if self.PosAppraiseInfoDic:ContainsKey(part) then
        local _appraiseInfos = self.PosAppraiseInfoDic[part]
        if _appraiseInfos then
            for j = 1, #_appraiseInfos do
                if _appraiseInfos[j].Index == targetIndex then
                    _ret = _appraiseInfos[j]
                    break
                end
            end
        end
    end
    return _ret
end

-- Get all the refining properties of the part through the part, return dictionary<key, value>, key = attribute configuration table id, value = {Value = value, PoolID = poolId, Percent = ten thousand percent}
function LianQiForgeSystem:GetAllAppraiseAttrDicByPart(pos)
    --- Result data: {{ Index, { AttrID = _attrID, Value = _realValue, Percent = 0 }}, { Index, { AttrID = _attrID, Value = _realValue, Percent = 0 }}}
    local _retAttrDic = Dictionary:New()
    local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(pos)
    if _equip and _equip.ItemInfo then
        local part = _equip:GetPart()
        local partAppraiseInfo = self:GetAppraiseInfoListByPos(part)
        if not partAppraiseInfo or #partAppraiseInfo == 0 then
            return _retAttrDic
        end


        -- Chạy tất cả thuộc tính không phải từ 1, mà là 0 tránh bỏ sót so với cách cũ

        for _, appraiseLine in ipairs(partAppraiseInfo) do
            if appraiseLine then
                local index = appraiseLine.Index or 0
                local poolId = appraiseLine.PoolID or INVALID_POOL_ID
                local percent = appraiseLine.Percent or 0

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
                end
            end
        end

        -- for i = 1, #partAppraiseInfo do
        --     local appraiseLine = self:GetAppraiseInfoByPartAndIndex(part, i)
        --     if appraiseLine then
        --         local index = appraiseLine.Index or 0
        --         local poolId = appraiseLine.PoolID or INVALID_POOL_ID
        --         local percent = appraiseLine.Percent or 0
        --         --local _data = { AttrID = 99, Value = 0, Percent = 0 }
        --         local _poolInfo = Utils.ParsePoolAttribute(poolId)
        --         if _poolInfo and _poolInfo.minVal and _poolInfo.maxVal then
        --             local _value = math.floor((_poolInfo.maxVal - _poolInfo.minVal) * (percent / 10000) + _poolInfo.minVal)
        --             local _data = {
        --                 AttrID  = _poolInfo.attrId,
        --                 Value   = _value,
        --                 Percent = percent
        --             }
        --             if not _retAttrDic:ContainsKey(index) then
        --                 _retAttrDic:Add(index, _data)
        --             end
        --         end
        --     end
        -- end
    end
    return _retAttrDic
end

-- ===================== End Appraise Handle ======================

-- ===================== Start Special Handle ======================

-- Get all the refining properties of the part through the part, return dictionary<key, value>, key = attribute configuration table id, value = {Value = value, PoolID = poolId, Percent = ten thousand percent}
function LianQiForgeSystem:GetAllSpecialAttrDicByPart(pos)
    --- Result data: {{ Index, { AttrID = _attrID, Value = _realValue, Percent = 0 }}, { Index, { AttrID = _attrID, Value = _realValue, Percent = 0 }}}
    local _retAttrDic = Dictionary:New()
    local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(pos)
    if _equip and _equip.ItemInfo then
        local part = _equip:GetPart()
        local partSpecialInfo = self:GetSpecialInfoListByPos(part)
        if not partSpecialInfo or #partSpecialInfo == 0 then
            return _retAttrDic
        end


        -- Chạy tất cả thuộc tính không phải từ 1, mà là 0 tránh bỏ sót so với cách cũ

        for _, specialLine in ipairs(partSpecialInfo) do
            if specialLine then
                local index = specialLine.Index or 0
                local poolId = specialLine.PoolID or INVALID_POOL_ID
                local percent = specialLine.Percent or 0

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
    end
    return _retAttrDic
end

-- Through the part, obtain all the refining information in the part. pos = part, return a List (Count may = 0)
function LianQiForgeSystem:GetSpecialInfoListByPos(part)
    local _ret = List:New()
    if self.PosSpecialInfoDic:ContainsKey(part) then
        local _specialInfos = self.PosSpecialInfoDic[part]
        _ret = _specialInfos
    end
    return _ret
end

-- -- Hàm thực hiện update data cho part
function LianQiForgeSystem:UpdatePartSpecialByBagInfo(bagInfo, part)
    -- print("==== bagInfo", Inspect(bagInfo))
    if not bagInfo or not bagInfo.itemId then
        return
    end

    local itemId = bagInfo.itemId
    local detail = bagInfo.info
    if not detail then
         -- Mặc item mới, chưa có info => tạo list rỗng cho part
        self.PosSpecialInfoDic[part] = List:New()
        -- print("[LianQiForgeSystem] No detail info, init empty special list for part =", part)
        return
    end

    -- Tạo list mới
    local newList = List:New()
    local _rawSpecialInfos = List:New(detail.attrSpecial)
    if _rawSpecialInfos then
        for i = 1, #_rawSpecialInfos do
            local src = _rawSpecialInfos[i]
            if src then
                local data = Utils.DeepCopy(L_EquipSpecialInfo)
                data.Index   = src.index
                data.Value   = src.value
                data.Percent = src.per
                data.PoolID  = src.poolId or INVALID_POOL_ID
                newList:Add(data)
            end
        end

        -- Sort theo Index
        newList:Sort(function(a, b)
            return a.Index < b.Index
        end)
    end

    -- Cập nhật lại dictionary theo part
    self.PosSpecialInfoDic[part] = newList

    self.EquipPartByItemIdDic[itemId] = part
    -- print("[LianQiForgeSystem] Update EquipPartByItemIdDic: itemId =", itemId, "newPart =", part)

    -- print("[LianQiForgeSystem=================] bagInfobagInfobagInfo", part, "bagInfobagInfobagInfo =", Inspect(newList))
end

-- Get all the refining properties of the part through the part, return dictionary<key, value>, key = attribute configuration table id, value = {Value = value, PoolID = poolId, Percent = ten thousand percent}
function LianQiForgeSystem:GS2U_ResEquipSpecialInfo(infos)
    local count = Utils.GetTableLens(infos)

    -- Mảng mapping itemId -> part
    if not self.EquipPartByItemIdDic then
        self.EquipPartByItemIdDic = Dictionary:New()  -- <itemId, part>
    else
        self.EquipPartByItemIdDic:Clear()
    end

    local result = {}

    if infos ~= nil then
        for i = 1, count do
            local _part = infos[i].type
            local _newSpecialInfos = List:New()
            local _rawSpecialInfos = List:New(infos[i].attrSpecial)

            local _equipId = 0

            if infos[i].equip and infos[i].equip.itemId then
                _equipId = infos[i].equip.itemId
                self.EquipPartByItemIdDic:Add(_equipId, _part)
            end

            -- print(" GS2U_ResEquipSpecialInfo -> part:", _part, " itemId:", _equipId)

            if _rawSpecialInfos then
                for j = 1, #_rawSpecialInfos do
                    local _data = Utils.DeepCopy(L_EquipSpecialInfo)
                    _data.Index = _rawSpecialInfos[j].index
                    _data.Value = _rawSpecialInfos[j].value
                    _data.Percent = _rawSpecialInfos[j].per
                    _data.PoolID = _rawSpecialInfos[j].poolId or INVALID_POOL_ID

                    -- print("_data==", Inspect(_data))

                    table.insert(result, {
                        itemId = _equipId,
                        index = _rawSpecialInfos[j].index or 0,
                        value = _rawSpecialInfos[j].value or 0,
                        per = _rawSpecialInfos[j].per or 0,
                        poolId = _rawSpecialInfos[j].poolId or INVALID_POOL_ID,
                    })

                    _newSpecialInfos:Add(_data)
                end
            end
            _newSpecialInfos:Sort(function(a, b)
                return a.Index < b.Index
            end)

            if #_newSpecialInfos > 0 then
                if not self.PosSpecialInfoDic:ContainsKey(_part) then
                    self.PosSpecialInfoDic:Add(_part, _newSpecialInfos)
                else
                    self.PosSpecialInfoDic[_part] = _newSpecialInfos
                end
            else
                self.PosSpecialInfoDic[_part] = _newSpecialInfos
            end
        end
    end

    -- thực hiện sync data
    -- if next(result) then
    --     GameCenter.LianQiForgeBagSystem:MergeAndUpdateFromResult(result)
    -- end


    -- print(" GS2U_ResEquipAppraiseInfo  PosSpecialInfoDic -> part:==========================", Inspect(self.PosSpecialInfoDic))
end

-- ===================== End Special Handle ========================

-- ==================== Begin Wash Handle ======================
function LianQiForgeSystem:SetUseNewWashRule(isNew)
    self.isUseNewWashRule = isNew
end

function LianQiForgeSystem:IsUseNewWashRule()
    return self.isUseNewWashRule
end

function LianQiForgeSystem:SetWashRedPoint()
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.LianQiForgeWash);
    for i = 0, EquipmentType.Count - 1 do
        local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(i)
        if _equip then
            if self:IsWashIndex(_equip) then
                -- Item Conditions
                local _conditions = List:New();
                if self.WashItemCostDic:ContainsKey(0) then
                    local _itemID = self.WashItemCostDic[0].ItemID
                    local _needNum = self.WashItemCostDic[0].NeedNum
                    _conditions:Add(RedPointItemCondition(_itemID, _needNum));
                    local _bestAttrCfg = DataConfig.DataWashBest[self:GetBestAttrCfgID(i)]
                    if _bestAttrCfg and _bestAttrCfg.LevelLimit then
                        _conditions:Add(RedPointLevelCondition(_bestAttrCfg.LevelLimit))
                    end
                end
                GameCenter.RedPointSystem:LuaAddFuncCondition(FunctionStartIdCode.LianQiForgeWash, i, _conditions);
            end
        end
    end
end

function LianQiForgeSystem:IsWashHaveRedPointByPos(pos)
    return GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.LianQiForgeWash, pos)
end

function LianQiForgeSystem:IsWashPartOpen(pos)
    local _bestAttrCfg = DataConfig.DataWashBest[self:GetBestAttrCfgID(pos)]
    if _bestAttrCfg and _bestAttrCfg.LevelLimit then
        if _bestAttrCfg.LevelLimit <= GameCenter.GameSceneSystem:GetLocalPlayerLevel() then
            return true
        end
    end
    return false
end

function LianQiForgeSystem:IsWashItemEnough()
    if self.WashItemCostDic:ContainsKey(0) then
        local _itemID = self.WashItemCostDic[0].ItemID
        local _needNum = self.WashItemCostDic[0].NeedNum
        local _haveNum = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(_itemID)
        if _haveNum >= _needNum then
            return true
        end
    end
    return false
end

function LianQiForgeSystem:IsWashIndex(equip)
    local _state = false
    if self:IsUseNewWashRule() then
        local quality = equip:GetQuality()
        -- 1_3;2_3;3_4;4_5;5_6
        self.WashIndexLimitDic:ForeachCanBreak(function(k, v)
            if quality >= v and k <= self.WashMaxIndex then
                _state = true
                return true
            end
        end)
    end
    return _state
end

-- The refining information of all parts will be returned and will be sent once when it is online. If the equipment is updated (the upper limit is enhanced), the message will also be synchronized once.
function LianQiForgeSystem:GS2U_ResEquipWashInfo(infos)
    local count = Utils.GetTableLens(infos)
    local _hasWashInfo = false
    if infos ~= nil then
        for i = 1, count do
            local _part = infos[i].type
            local _newWashInfos = List:New()
            local _rawWashInfos = List:New(infos[i].washInfo)
            if _rawWashInfos then
                for j = 1, #_rawWashInfos do
                    local _data = Utils.DeepCopy(L_EquipWashInfo)
                    _data.Index = _rawWashInfos[j].index
                    _data.Value = _rawWashInfos[j].value
                    _data.Percent = _rawWashInfos[j].per
                    _data.PoolID = _rawWashInfos[j].poolId or INVALID_POOL_ID
                    _newWashInfos:Add(_data)
                end
            end
            _newWashInfos:Sort(function(a, b)
                return a.Index < b.Index
            end)
            if #_newWashInfos > 0 then
                _hasWashInfo = true
                
                if not self.PosWashInfoDic:ContainsKey(_part) then
                    self.PosWashInfoDic:Add(_part, _newWashInfos)
                else
                    self.PosWashInfoDic[_part] = _newWashInfos
                end
            else
                self.PosWashInfoDic[_part] = List:New() -- reset
            end
        end
        if _hasWashInfo then
            self:SetWashRedPoint()
        end
        --if count > 0 and infos[1].washInfo ~= nil then
        --    self:SetWashRedPoint()
        --end
    end
end

-- Sends a request to perform equipment washing, pos = location; lockIndexList is the list of locked entries; useMaterial = true means using material, = false means using Yuanbao
function LianQiForgeSystem:ReqEquipWash(pos, lockIndexList, useMaterial)
    local _req = ReqMsg.MSG_Equip.ReqEquipWash:New()
    _req.id = pos
    _req.indexs = lockIndexList
    _req.type = useMaterial
    _req:Send()
end

-- Receives the preview attributes returned from the wash request.
function LianQiForgeSystem:GS2U_ResEquipWash(result)
    if self:IsUseNewWashRule() then
        self:UpdateWashInfoPreview(result)
    end
end

function LianQiForgeSystem:UpdateWashInfoPreview(result)
    local _equipPart = result.id  -- Equipment part type (used as key in PosWashInfoDic)
    local _rawWashInfos = List:New(result.washInfos)
    local _previewWashInfosList = List:New()
    -- Clone result data into preview list
    for i = 1, _rawWashInfos:Count() do
        local data = Utils.DeepCopy(L_EquipWashInfo)
        data.Index = _rawWashInfos[i].index
        data.Value = _rawWashInfos[i].value
        data.Percent = _rawWashInfos[i].per
        data.PoolID = _rawWashInfos[i].poolId or INVALID_POOL_ID
        _previewWashInfosList:Add(data)
    end
    -- Keep locked lines (that are not in the new preview list)
    if self.PosWashInfoDic:ContainsKey(_equipPart) then
        local _oldWashInfos = self.PosWashInfoDic[_equipPart]
        for _, oldData in ipairs(_oldWashInfos) do
            -- If old data does not exist in the new preview (locked line), re-add it
            local found = _previewWashInfosList:Find(function(item)
                return item.Index == oldData.Index
            end)
            if not found then
                _previewWashInfosList:Add(Utils.DeepCopy(oldData))
            end
        end
    end
    -- Sort final preview list by Index
    _previewWashInfosList:Sort(function(a, b)
        return a.Index < b.Index
    end)
    -- Save to preview dictionary
    if self.PosWashPreviewDic:ContainsKey(_equipPart) then
        self.PosWashPreviewDic[_equipPart] = _previewWashInfosList
    else
        self.PosWashPreviewDic:Add(_equipPart, _previewWashInfosList)
    end
    -- Refresh UI
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_REFRESH_EQUIPFORGE, _equipPart)
end

-- Sends a request to confirm and apply the washed attributes.
function LianQiForgeSystem:ReqEquipWashReceive(equipId, part)
    local _req = ReqMsg.MSG_Equip.ReqEquipWashReceive:New()
    _req.equipId = equipId
    _req.type = part
    _req:Send()
end

function LianQiForgeSystem:SetWashInfoByPart(part, itemInfo)
    if not (part and itemInfo) then
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
        if not self.PosWashInfoDic:ContainsKey(part) then
            self.PosWashInfoDic:Add(part, _washInfos)
        else
            self.PosWashInfoDic[part] = _washInfos
        end
    elseif self.PosWashInfoDic:ContainsKey(part) then
        self.PosWashInfoDic[part] = List:New()
    end
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_REFRESH_EQUIPFORGE, _equipPart)
end

-- Receives the final forged equipment data after successful washing.
function LianQiForgeSystem:GS2U_ResEquipWashSuccess(result)
    local _equipPart = result.id
    if not _equipPart then
        return
    end
    local _rawWashInfos = List:New(result.washInfos)
    local _newWashInfos = List:New()
    -- Clone result data into newWashInfo list
    for i = 1, _rawWashInfos:Count() do
        local data = Utils.DeepCopy(L_EquipWashInfo)
        data.Index = _rawWashInfos[i].index
        data.Value = _rawWashInfos[i].value
        data.Percent = _rawWashInfos[i].per
        data.PoolID = _rawWashInfos[i].poolId or INVALID_POOL_ID
        _newWashInfos:Add(data)
    end

    -- Keep locked lines (that are not in the newWashInfo list)
    if self.PosWashInfoDic:ContainsKey(_equipPart) then
        local oldWashInfos = self.PosWashInfoDic[_equipPart]
        for _, oldData in ipairs(oldWashInfos) do
            local found = _newWashInfos:Find(function(item)
                return item.Index == oldData.Index
            end)
            if not found then
                _newWashInfos:Add(Utils.DeepCopy(oldData))
            end
        end
    end

    -- Sắp xếp theo Index
    _newWashInfos:Sort(function(a, b)
        return a.Index < b.Index
    end)

    -- Sort final preview list by Index
    if self.PosWashInfoDic:ContainsKey(_equipPart) then
        self.PosWashInfoDic[_equipPart] = _newWashInfos
    else
        self.PosWashInfoDic:Add(_equipPart, _newWashInfos)
    end

    -- Clear the preview dictionary entry for the corresponding equipment part
    if self.PosWashPreviewDic:ContainsKey(_equipPart) then
        self.PosWashPreviewDic:Remove(_equipPart)
    end

    -- Refresh UI
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_REFRESH_EQUIPFORGE, _equipPart)
end

-- NOTE(TL): No longer in use
function LianQiForgeSystem:ApplyWashResult(result)
    local _equipPart = result.id
    if not _equipPart then
        return
    end
    local _previewList = self.PosWashPreviewDic[_equipPart]
    if not _previewList or #_previewList == 0 then
        return
    end
    local _applyList = Utils.DeepCopy(_previewList)
    self.PosWashInfoDic[_equipPart] = _applyList
    self.PosWashPreviewDic:Remove(_equipPart)

    -- Notify UI refresh
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_REFRESH_EQUIPFORGE, _equipPart)
end

-- Get all the refining properties of the part through the part, return dictionary<key, value>, key = attribute configuration table id, value = {Value = value, PoolID = poolId, Percent = ten thousand percent}
function LianQiForgeSystem:GetAllWashAttrDicByPart(pos)
    --- Old result data: {{ _attrID, { Value = _realValue, Percent = 0 }}, { _attrID, { Value = _realValue, Percent = 0 }}}
    --- New result data: {{ Index, { AttrID = _attrID, Value = _realValue, Percent = 0 }}, { Index, { AttrID = _attrID, Value = _realValue, Percent = 0 }}}
    local _retAttrDic = Dictionary:New()
    local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(pos)
    if _equip and _equip.ItemInfo then
        local part = _equip:GetPart()
        local quality = _equip:GetQuality()
        local partWashInfo = self:GetWashInfoListByPos(part)
        if not partWashInfo then
            return _retAttrDic
        end
        --1_3;2_3;3_4;4_5;5_6
        self.WashIndexLimitDic:Foreach(function(k, v)
            if quality >= v and k <= self.WashMaxIndex then
                local washLine = self:GetWashInfoByPartAndIndex(part, k)
                if not washLine then
                    return
                end
                local index = washLine.Index or 0
                local poolId = washLine.PoolID or INVALID_POOL_ID
                local percent = washLine.Percent or 0
                --local _data = { AttrID = 99, Value = 0, Percent = 0 }
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
        end)
    end
    return _retAttrDic
end

-- Get the default cleansing attribute of a piece of equipment, return dictionary<key, value>, key = attribute configuration table id, value = {Value = value, Percent = ten thousand ratio}
function LianQiForgeSystem:GetEquipDefaultWashAttrs(equipCfg)
    --- Old result data: {{ _attrID, { Value = _realValue, Percent = 0 }}, { _attrID, { Value = _realValue, Percent = 0 }}}
    --- New result data: {{ Index, { AttrID = _attrID, Value = _realValue, Percent = 0 }}, { Index, { AttrID = _attrID, Value = _realValue, Percent = 0 }}}
    local _retAttrDic = Dictionary:New()
    if equipCfg then
        local quality = equipCfg.Quality
        --- {idx_poolId_percent;idx_poolId_percent;idx_poolId_percent;idx_poolId_percent;idx_poolId_percent}
        local _washAttrs = Utils.SplitStr(equipCfg.RecommendedTips, ';')
        --1_3;2_3;3_4;4_5;5_6
        self.WashIndexLimitDic:Foreach(function(k, v)
            if quality >= v and k <= self.WashMaxIndex then
                local _attrs = Utils.SplitStr(_washAttrs[k], '_')
                local index = tonumber(_attrs[1]) or 0
                local poolId = tonumber(_attrs[2]) or INVALID_POOL_ID
                local percent = tonumber(_attrs[3]) or 0
                local _poolInfo = Utils.ParsePoolAttribute(poolId)
                local _data = { AttrID = 99, Value = 0, Percent = 0 }
                if _poolInfo then
                    local _value = math.floor((_poolInfo.maxVal - _poolInfo.minVal) * (percent / 10000) + _poolInfo.minVal)

                    _data.Value = _value
                    _data.Percent = percent
                    _data.AttrID = _poolInfo.attrId
                    if not _retAttrDic:ContainsKey(index) then
                        _retAttrDic:Add(index, _data)
                    end
                end
            end
        end)
    end
    return _retAttrDic
end

-- Through the part, obtain all the refining information in the part. pos = part, return a List (Count may = 0)
function LianQiForgeSystem:GetWashInfoListByPos(part)
    local _ret = List:New()
    if self.PosWashInfoDic:ContainsKey(part) then
        local _washInfos = self.PosWashInfoDic[part]
        _ret = _washInfos
    end
    return _ret
end

-- Pass pos = part, and index = entry. Get the attribute information of the current entry, no nil is returned
function LianQiForgeSystem:GetWashInfoByPartAndIndex(part, targetIndex)
    local _ret = nil
    if self.PosWashInfoDic:ContainsKey(part) then
        local _washInfos = self.PosWashInfoDic[part]
        if _washInfos then
            for j = 1, #_washInfos do
                if _washInfos[j].Index == targetIndex then
                    _ret = _washInfos[j]
                    break
                end
            end
        end
    end
    return _ret
end

-- By pos = part, get the refining score of the part
function LianQiForgeSystem:GetWashScoreByPos(part)
    local _totalScore = 0
    if self.PosWashInfoDic:ContainsKey(part) then
        local _washInfos = self.PosWashInfoDic[part]
        if _washInfos then
            for j = 1, #_washInfos do
                local _score = (_washInfos[j].Percent / 10000) * self.WashScoreCulcWeight
                _totalScore = _totalScore + _score
            end
        end
    end
    return math.floor(_totalScore)
end

function LianQiForgeSystem:HasPreviewWashInfos(part)
    local list = self.PosWashPreviewDic and self.PosWashPreviewDic[part]
    return list ~= nil and #list > 0
end

function LianQiForgeSystem:GetPreviewWashInfoByPartAndIndex(part, targetIndex)
    local list = self.PosWashPreviewDic and self.PosWashPreviewDic[part]
    if not list or #list == 0 then return nil end

    for _, info in ipairs(list) do
        if info.Index == targetIndex then
            return info
        end
    end
    return nil
end

function LianQiForgeSystem:SetLabelColorByPercent(label, percent)
    local _targetColor = Utils.GetTargetColor(ColorTargetType.Wash_Attribute, percent, "#FFFFFF")
    UIUtils.SetColorByString(label, _targetColor)
end

function LianQiForgeSystem:SetAppraiseLabelColorByPercent(label, percent, type)

    local _targetColor = Utils.GetTargetColor(ColorTargetType.Appraise_Attribute, percent, "#787878")

    if type ~= nil then
        if type > 1 then
            _targetColor = Utils.GetTargetColor(ColorTargetType.Appraise_Plus_Attribute, percent, "#787878")
        else
            _targetColor = Utils.GetTargetColor(ColorTargetType.Appraise_Attribute, percent, "#787878")
        end
    end

    UIUtils.SetColorByString(label, _targetColor)
end

function LianQiForgeSystem:SetSpecialLabelColorByPercent(label, percent)
    local _targetColor = Utils.GetTargetColor(ColorTargetType.Special_Attribute, percent, "#FFFFFF")
    UIUtils.SetColorByString(label, _targetColor)
end

-- Get the id of the washing configuration table
function LianQiForgeSystem:GetWashCfgID(pos, index)
    return (pos + 1) * 10 + index
end

-- Get the id of the best attribute configuration table
function LianQiForgeSystem:GetBestAttrCfgID(pos)
    return 1000 + pos
end
-- ====================== End Wash Handle =====================

return LianQiForgeSystem