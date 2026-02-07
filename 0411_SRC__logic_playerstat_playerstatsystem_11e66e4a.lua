------------------------------------------------
-- Author:
-- Date: 2025-11-11
-- File: PlayerStatSystem.lua
-- Module: PlayerStatSystem
-- Description: Player Stat System (refactored)
------------------------------------------------
local PlayerStatEnum = require "Logic.PlayerStat.PlayerStatEnum"
local L_StatState = require "Logic.PlayerStat.PlayerStatState"

local EPlayerStat = PlayerStatEnum.Stat
local EPlayerStatReason = PlayerStatEnum.Reason

local _playerStatConfig = {
    [EPlayerStat.Strength]     = { default = 0, min = 0, max = 999 },
    [EPlayerStat.Agility]      = { default = 0, min = 0, max = 999 },
    [EPlayerStat.Vitality]     = { default = 0, min = 0, max = 999 },
    [EPlayerStat.Intelligence] = { default = 0, min = 0, max = 999 },
}

local PlayerStatSystem = {
    AvailablePoints = 0, -- Điểm có thể dùng
    Base            = nil, -- Trạng thái đã xác nhận
    Temp            = nil, -- Trạng thái tạm khi chỉnh UI
    Backup          = nil, -- Dùng khi rollback
}

------------------------------------------------------------------------------------------------------------------------
--region [Init & Config]
-- Initialization, setup, and preloading data
-- ---------------------------------------------------------------------------------------------------------------------

function PlayerStatSystem:Initialize()
    self.AvailablePoints = 0
    self.Base = L_StatState:New(_playerStatConfig)
    self.Temp = L_StatState:New(_playerStatConfig)
    self.Backup = nil
end

function PlayerStatSystem:UnInitialize()
    self.AvailablePoints = 0
    self.Base = nil
    self.Temp = nil
    self.Backup = nil
end

function PlayerStatSystem:InitDefaultByClass(classId)
    local initCfg = self:GetStatInitByClass(classId)
    if not initCfg then return false end

    for stat, value in pairs(initCfg) do
        self.Base:_ForceSet(stat, value)
        self.Temp:_ForceSet(stat, value)
    end

    self.Backup = nil
    self:NotifyUI(EPlayerStatReason.INIT)
    return true
end

--endregion [Init & Config]

------------------------------------------------------------------------------------------------------------------------
--region [Access & Data Handling]
-- Internal data management, used only inside the module
-- ---------------------------------------------------------------------------------------------------------------------

function PlayerStatSystem:GetBaseValue(stat)
    return self.Base:Get(stat)
end

function PlayerStatSystem:GetStatValue(stat)
    return self.Temp:Get(stat) -- self.Temp.Values[stat] or 0
end

function PlayerStatSystem:GetStatDiff(stat)
    if not self.Temp or not self.Base then
        return 0
    end
    local tempVal = self.Temp:Get(stat)
    local baseVal = self.Base:Get(stat)
    return tempVal - baseVal
end

function PlayerStatSystem:IsStatAtBase(stat)
    return self.Temp:IsAtBase(stat, self.Base)
    --local base = self.Base.Values[stat] or 0
    --local temp = self.Temp.Values[stat] or 0
    --return temp <= base
end

--endregion [Access & Data Handling]

------------------------------------------------------------------------------------------------------------------------
--region [Public API / Getters & Setters]
-- Methods callable from outside (other systems or UI)
-- ---------------------------------------------------------------------------------------------------------------------
-- ========= START ACTION =========
function PlayerStatSystem:AddStat(stat, amount)
    local remain = self:GetRemainingPoints()
    if remain < amount then
        return false, "Not enough points"
    end

    local ok, msg = self.Temp:Add(stat, amount)
    if ok then
        self:NotifyUI(EPlayerStatReason.POINT_CHANGE)
    end
    return ok, msg
end

function PlayerStatSystem:SubStat(stat, amount)
    local tempVal = self.Temp:Get(stat)
    local baseVal = self.Base:Get(stat)
    if tempVal - amount < baseVal then
        return false, "Cannot go below base"
    end

    local ok, msg = self.Temp:Sub(stat, amount)
    if ok then
        self:NotifyUI(EPlayerStatReason.POINT_CHANGE)
    end
    return ok, msg
end

function PlayerStatSystem:AddAllToStat(stat)
    if not stat or not self.Temp or not self.Temp:Get(stat) then
        return false, "Invalid stat"
    end

    if self:IsStatMax(stat) then
        return false, "Reached max"
    end

    local remain = self:GetRemainingPoints()
    if remain <= 0 then
        return false, "No remaining points"
    end

    local conf = self.Temp.Config[stat]
    local current = self.Temp:Get(stat)
    local canAdd = conf.max - current
    if canAdd <= 0 then
        return false, "Reached max"
    end

    local addAmount = math.min(remain, canAdd)

    -- self:AddStat(stat, addAmount)
    local ok, msg = self.Temp:Add(stat, addAmount)
    if ok then
        self:NotifyUI(EPlayerStatReason.POINT_CHANGE)
    end

    return ok, msg
end

function PlayerStatSystem:ResetTempFromBase()
    self.Temp:CopyFrom(self.Base)
end

function PlayerStatSystem:BeginEdit()
    if self.Backup then
        return false, "Already editing"
    end

    self.Backup = self.Temp:CloneValues()
    return true
end

function PlayerStatSystem:Rollback()
    if not self.Backup then
        return false, "No backup"
    end

    local restore = Dictionary:New()
    for stat, value in pairs(self.Backup) do
        restore:Add(stat, value)
    end
    self.Temp.Values = restore
    self.Backup = nil

    self:NotifyUI(EPlayerStatReason.ROLLBACK)
    return true
end

function PlayerStatSystem:AutoDistributeByClass(classId)
    local suggestCfg = self:GetStatSuggestByClass(classId)
    if not suggestCfg then
        return false, "No suggest config"
    end

    local remain = self:GetRemainingPoints()
    if remain <= 0 then
        return false, "No remaining points"
    end

    for stat, percent in pairs(suggestCfg) do
        local add = math.floor(remain * percent / 100)
        if add > 0 then
            self.Temp:Add(stat, add)
        end
    end

    self:NotifyUI(EPlayerStatReason.POINT_CHANGE)
    return true
end

function PlayerStatSystem:Confirm()
    local usedPoints = 0
    local diffs = List:New() -- List<{id, point}>

    for stat, tempVal in pairs(self.Temp.Values) do
        local base = self.Base:Get(stat)
        local diff = tempVal - base
        if diff ~= 0 then
            --self.Base:_ForceSet(stat, tempVal)
            diffs:Add({ id = stat, point = diff })

            if diff > 0 then
                usedPoints = usedPoints + diff
            end
        end
    end
    --self.Temp:CopyFrom(self.Base)
    self.Backup = nil
    --self.AvailablePoints = self:GetAvailablePoints() - usedPoints
    --self.AvailablePoints = math.max(0, (self.AvailablePoints or 0) - usedPoints)

    self:NotifyUI(EPlayerStatReason.CONFIRM)
    return true, diffs
end

function PlayerStatSystem:ResetAll(classId)
    local initCfg = self:GetStatInitByClass(classId)
    if not initCfg then
        return false, "No init config"
    end
    
    local diffs = List:New() -- List<{ id, point }>
    for stat, baseValue in pairs(self.Base.Values) do
        --local initVal = initCfg[stat] or 0
        --self.Base:_ForceSet(stat, initVal)
        diffs:Add({ id = stat, point = -1 }) -- initVal - baseValue
    end
    --self.Temp:CopyFrom(self.Base)
    self.Backup = nil
    --local availableAfter, _ = self:_CalcAvailablePointsAfterReset(classId)
    --self.AvailablePoints = availableAfter

    self:NotifyUI(EPlayerStatReason.RESET)
    return true, diffs
end
-- ========= END ACTION =========

------------------------------------------------------------------------------------------------------------------------

function PlayerStatSystem:GetAvailablePoints()
    return self.AvailablePoints or 0
end

function PlayerStatSystem:GetAllocatedPoints(classId)
    local initCfg = self:GetStatInitByClass(classId)
    if not initCfg then
        return 0, "No init config"
    end

    local sum = 0
    for stat, baseVal in pairs(self.Base.Values) do
        local initVal = initCfg[stat] or 0
        if baseVal > initVal then
            sum = sum + (baseVal - initVal) --sum = sum + math.max(0, baseVal - initVal)
        end
    end

    return sum
end

function PlayerStatSystem:GetUsedPoints()
    local used = 0
    for stat, value in pairs(self.Temp.Values) do
        local base = self.Base:Get(stat) -- self.Base.Values[stat] or 0
        used = used + math.max(0, value - base)
    end
    return used
end

function PlayerStatSystem:GetRemainingPoints()
    return self:GetAvailablePoints() - self:GetUsedPoints()
end

function PlayerStatSystem:GetTotalPoints(classId)
    return self:GetAllocatedPoints(classId) + self:GetAvailablePoints()
end

function PlayerStatSystem:IsStatMax(stat)
    if not self.Temp then
        return false
    end
    return self.Temp:IsMax(stat)
end

function PlayerStatSystem:GetStatInfo(stat)
    local baseVal = self.Base:Get(stat)
    local tempVal = self.Temp:Get(stat)
    local diff = tempVal - baseVal
    return baseVal, tempVal, diff
end

function PlayerStatSystem:CanAddStat(stat)
    if self:IsStatMax(stat) then
        return false, "Reached max"
    end
    if self:GetRemainingPoints() <= 0 then
        return false, "No remaining points"
    end
    return true
end

function PlayerStatSystem:CanSubStat(stat)
    if self:IsStatAtBase(stat) then
        return false, "Already at base"
    end
    return true
end

function PlayerStatSystem:CanResetAll(classId)
    if self:GetAllocatedPoints(classId) <= 0 then
        return false, "Nothing to reset"
    end
    return true
end

function PlayerStatSystem:HasPendingChanges()
    for stat, _ in pairs(self.Temp.Values) do
        if self:GetStatDiff(stat) ~= 0 then
            return true
        end
    end
    return false
end

function PlayerStatSystem:GetResetAllResultPreview(classId)
    local availableAfter, refundedPoints = self:_CalcAvailablePointsAfterReset(classId)

    return true, {
        refundedPoints      = refundedPoints,
        availableAfterReset = availableAfter,
    }
end

function PlayerStatSystem:GetResetAllCondition()
    local raw = self:_GetGlobalParams(GlobalName.Point_Tiem_Nang_Reset) -- 29_1063_1
    local seg = Utils.SplitNumber(raw, '_')
    if not seg or #seg < 3 then
        return false, "Invalid reset config"
    end

    return true, {
        minLevel = tonumber(seg[1]) or 0,
        itemId   = tonumber(seg[2]) or 0,
        quantity = tonumber(seg[3]) or 0,
    }
end

function PlayerStatSystem:_CalcAvailablePointsAfterReset(classId)
    local refunded = self:GetAllocatedPoints(classId)
    local before = self:GetAvailablePoints()
    local cost = 0

    return before + refunded - cost, refunded
end

--endregion [Public API / Getters & Setters]

------------------------------------------------------------------------------------------------------------------------
--region [Network Requests & Responses]
-- Handle server requests and responses
-- --------------------------------------------------------------------------------------------------------------------
function PlayerStatSystem:OnLevelUp(newAvailablePoints)
    self.AvailablePoints = newAvailablePoints
    self:ResetTempFromBase()

    self:NotifyUI(EPlayerStatReason.SERVER_SYNC)
end

function PlayerStatSystem:LoadFromServer(data)
    Debug.Log("[PlayerStatSystem] LoadFromServer", Inspect(data))
    if not data or data.point == nil or not data.pools then
        return false, "Invalid data"
    end

    -- Reset Base/Temp để tránh residues (đảm bảo chỉ _ForceSet các key trong _playerStatConfig)
    self.Base = L_StatState:New(_playerStatConfig)
    self.Temp = L_StatState:New(_playerStatConfig)

    self.AvailablePoints = tonumber(data.point) or 0
    for _, stat in ipairs(data.pools) do
        local statType = stat.id
        local value = stat.point or 0
        if _playerStatConfig[statType] then
            self.Base:_ForceSet(statType, value)
        end
    end
    self.Temp:CopyFrom(self.Base)
    self:BeginEdit()

    self:NotifyUI(EPlayerStatReason.SERVER_SYNC)
    return true
end

function PlayerStatSystem:SendStatToServer(diffs)
    local _lpId = GameCenter.GameSceneSystem:GetLocalPlayerID()
    if _lpId <= 0 or diffs:Count() == 0 then
        return
    end

    local _req = ReqMsg.MSG_Player.ReqActiveMainType:New();
    _req.roleId = _lpId
    _req.pools = diffs
    _req:Send()
end
--endregion [Network Requests & Responses]

------------------------------------------------------------------------------------------------------------------------
--region [Private Helpers]
-- Internal utilities, component finding, and setup functions
-- ---------------------------------------------------------------------------------------------------------------------
function PlayerStatSystem:NotifyUI(reason)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_PLAYERSTAT_UPDATE, reason)
end

function PlayerStatSystem:GetStatInitByClass(classId)
    local _classId = classId or self:_GetCurrentClassId()
    -- 2_8_6_16_10;0_14_14_8_4;3_6_10_8_16;1_4_8_8_20
    local initStr = self:_GetGlobalParams(GlobalName.Player_Initial_TiemNang)
    local dic = self:_ParseStatString(initStr)

    return dic:Get(_classId)
end

function PlayerStatSystem:GetStatSuggestByClass(classId)
    local cid = classId or self:_GetCurrentClassId()
    -- 2_20_15_40_25;0_35_35_20_10;3_15_25_20_40;1_10_20_20_50
    local percentStr = self:_GetGlobalParams(GlobalName.Player_Percent_Suggest)
    local dic = self:_ParseStatString(percentStr)

    return dic:Get(cid)
end

function PlayerStatSystem:_GetCurrentClassId()
    return GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
end

function PlayerStatSystem:_GetGlobalParams(globalKey)
    local cfg = DataConfig.DataGlobal[globalKey]
    return (cfg and cfg.Params) or ""
end

---Parse a stat config string into a Dictionary.
---Format: "OccID_Str_Agi_Vit_Int;..." 
---Example: "2_8_6_16_10;0_14_14_8_4"
---@param dataStr string Config string from DataGlobal
---@return table Dictionary<number, table> result Mapping: OccID → {stat = value}
function PlayerStatSystem:_ParseStatString(dataStr)
    local result = Dictionary:New()
    if not dataStr or dataStr == "" then return result end
    local _strTable = Utils.SplitStr(dataStr, ';')
    for i = 1, #_strTable do
        local seg = Utils.SplitNumber(_strTable[i], '_')
        if seg and #seg >= 5 then
            local occID = tonumber(seg[1])
            result:Add(occID, {
                [EPlayerStat.Strength]     = seg[2] or 0,
                [EPlayerStat.Agility]      = seg[3] or 0,
                [EPlayerStat.Vitality]     = seg[4] or 0,
                [EPlayerStat.Intelligence] = seg[5] or 0,
            })
        end
    end
    return result
end

--endregion [Private Helpers]

return PlayerStatSystem