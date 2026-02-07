------------------------------------------------
-- Author:
-- Date: 2025-11-14
-- File: EscortData.lua
-- Module: EscortData
-- Description: Data Xe lúa
------------------------------------------------
local EscortData = {
    CfgId              = 0,
    Cfg                = nil,

    ModelID            = 0,
    Percent            = 0,
    Name               = nil,
    IcName             = nil,
    BgName             = nil,
    RewardID           = nil, -- id_num_bind_occ            -- 3_20000_0_9
    ModelPosition      = nil, -- sca_roty_posx_posy_posz    -- 100_180_-421_-290_0
    _CacheLevelRewards = Dictionary:New(),
    _CacheCfgRewards   = Dictionary:New(),
}

------------------------------------------------------------------------------------------------------------------------
--region [Init & Config]
-- Initialization, setup, and preloading data
-- ---------------------------------------------------------------------------------------------------------------------
---@class EscortData EscortData.lua
function EscortData:New(k, v)
    local _m = Utils.DeepCopy(self)
    _m.CfgId = k
    _m.Cfg = v
    _m:UpdateData(v)
    return _m
end

function EscortData:NewWithCfg(cfg)
    local _m = Utils.DeepCopy(self)
    if cfg then
        _m.CfgId = cfg.Id
        _m.Cfg = cfg
        _m:UpdateData(cfg)
    end
    return _m
end

--endregion [Init & Config]

------------------------------------------------------------------------------------------------------------------------
--region [Public API / Getters & Setters]
-- Methods callable from outside (other systems or UI)
-- ---------------------------------------------------------------------------------------------------------------------

function EscortData:UpdateData(cfg)
    if cfg then
        self.ModelID = cfg.MonsterId
        self.Percent = cfg.ShowValue
        self.Name = cfg.Name
        self.IcName = cfg.Icon
        self.BgName = cfg.ChooseBackground
        self.RewardID = cfg.RewardID
        self.ModelPosition = cfg.ModelPosition
    end
end

--endregion [Public API / Getters & Setters]

------------------------------------------------------------------------------------------------------------------------
--region [Private Helpers]
-- Internal utilities, component finding, and setup functions
-- ---------------------------------------------------------------------------------------------------------------------

--endregion [Private Helpers]

return EscortData

