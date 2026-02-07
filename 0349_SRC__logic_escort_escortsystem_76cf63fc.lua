------------------------------------------------
-- Author:
-- Date: 2025-11-14
-- File: EscortSystem.lua
-- Module: EscortSystem
-- Description: Vận lúa
------------------------------------------------
local L_EscortData = require("Logic.Escort.EscortData")
local EscortSystem = {
    _IsEscortLoaded = false,
    EscortDataDic   = Dictionary:New(), -- Dic<{Id , L_EscortData}>
    CurrType        = nil, -- number
    IsReady         = false, -- boolean
}

------------------------------------------------------------------------------------------------------------------------
--region [Init & Config]
-- Initialization, setup, and preloading data
-- ---------------------------------------------------------------------------------------------------------------------

---Load / Init
function EscortSystem:Initialize()
    self.EscortDataDic = Dictionary:New()
    self:EnsureEscortDataLoaded()
end

---Unload / Clear
function EscortSystem:UnInitialize()
    self.EscortDataDic:Clear()
end

--endregion [Init & Config]

------------------------------------------------------------------------------------------------------------------------
--region [Access & Data Handling]
-- Internal data management, used only inside the module
-- ---------------------------------------------------------------------------------------------------------------------

---Ensure Escort data is loaded
function EscortSystem:EnsureEscortDataLoaded()
    --if self.EscortDataDic:Count() == 0 then
    if not self._IsEscortLoaded then
        DataConfig.DataEscort:Foreach(function(cfgId, cfg)
            local data = L_EscortData:NewWithCfg(cfg)  -- Note: cfgId is actually cfg.ID
            if not self.EscortDataDic:ContainsKey(cfgId) then
                self.EscortDataDic:Add(cfgId, data)
            end
        end)
        self._IsEscortLoaded = true
    end
    return self.EscortDataDic
end

--endregion [Access & Data Handling]  

------------------------------------------------------------------------------------------------------------------------
--region [Public API / Getters & Setters]
-- Methods callable from outside (other systems or UI)
-- ---------------------------------------------------------------------------------------------------------------------

---@return {cfgId: number, value: EscortData}[]
function EscortSystem:GetAllEscorts()
    --self:EnsureEscortDataLoaded()
    return self.EscortDataDic -- or Dictionary:New()
end

---@return EscortData
function EscortSystem:GetEscortDataById(cfgId)
    --self:EnsureEscortDataLoaded()
    return self.EscortDataDic[cfgId] or nil
end

---@return number current escort type
function EscortSystem:GetCurrEscortType()
    return self.CurrType or nil
end


function EscortSystem:CheckIsReady()
    return self.IsReady or false
end

--endregion [Public API / Getters & Setters]

------------------------------------------------------------------------------------------------------------------------
--region [Network Requests & Responses]
-- Handle server requests and responses
-- ---------------------------------------------------------------------------------------------------------------------

---Request InfoEscort: lấy data khi OpenUI
function EscortSystem:ReqInfoEscort()
    local _req = ReqMsg.MSG_Escort.ReqInfoEscort:New();
    _req:Send()
end

---Handles server response: InfoEscort data
---@param result { type: number }
function EscortSystem:ResInfoEscortResult(result)
    --self:EnsureEscortDataLoaded()

    self.CurrType = result.type
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_ESCORT_DATA_UPDATE, self.CurrType, false)
end

-- ---------------------------------------------------------------------------------------------------------------------

---Request: EnterEscort - Yêu cầu vận lúa (start)
---@param type number EscortType selected (1,2,3)
function EscortSystem:ReqEnterEscort(type)
    local _req = ReqMsg.MSG_Escort.ReqEnterEscort:New();
    _req.type = type or self.CurrType
    _req:Send()
end

---Handles server response: EnterEscort data from server
---@param result {result : number, type: number}
function EscortSystem:ResEnterEscortResult(result)
    GameCenter.PushFixEvent(UILuaEventDefine.UIEscortNotiForm_CLOSE)

    if result.result == 1 then
        self.CurrType = result.type
        self.IsReady = true
        GameCenter.PushFixEvent(UILuaEventDefine.UIEscortForm_CLOSE)
    end
end

-- ---------------------------------------------------------------------------------------------------------------------

---Request: EscortOver - Kết toán vận lúa
---@param type number EscortType selected (1,2,3)
function EscortSystem:ReqEscortOver(type)
    local _req = ReqMsg.MSG_Escort.ReqEscortOver:New();
    _req.type = type or self.CurrType
    _req:Send()
end

---Handles server response: EscortOver data from server
---@param result {rewards: {id:number, num:number}[]}
function EscortSystem:ResEscortOverReward(result)
    GameCenter.PushFixEvent(UILuaEventDefine.UIEscortNotiForm_CLOSE)

    local rewards = result and result.rewards
    if rewards and #rewards > 0 then
        --GameCenter.PushFixEvent(UILuaEventDefine.UIEscortForm_CLOSE)
        GameCenter.PushFixEvent(UILuaEventDefine.UIEscortSuccessForm_OPEN, rewards)
    else
        --GameCenter.PushFixEvent(UILuaEventDefine.UIEscortForm_CLOSE)
        GameCenter.PushFixEvent(UILuaEventDefine.UIEscortFailForm_OPEN, nil)
    end
    -- Reset current escort type
    self.CurrType = nil
    self.IsReady = false
end

--endregion [Network Requests & Responses]

function EscortSystem:OnLeaveScene()
    self.CurrType = nil
    self.IsReady = false
end

return EscortSystem

