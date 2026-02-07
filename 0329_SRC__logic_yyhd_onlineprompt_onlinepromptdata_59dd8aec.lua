------------------------------------------------
-- Author: 
-- Date: 2021-06-07
-- File: OnlinePromptData.lua
-- Module: OnlinePromptData
-- Description: Online prompts
------------------------------------------------
local BaseData = require("Logic.YYHD.YYHDBaseData")

local OnlinePromptData = {
    BackTexs = nil,
    OpenHDID = nil,
    FormOpenEventID = 0,
    FormCloseEventID = 0,
}

function OnlinePromptData:New(typeId)
    local _n = Utils.DeepCopy(self)
    local _mn = setmetatable(_n, {__index = BaseData:New(typeId)})
    -- Not displayed to the event list
    _mn.IsShowInList = false
    local _cfg = DataConfig.DataActivityYunying[typeId]
    _mn.FormOpenEventID =_cfg.UseUiId * 10 + EventConstDefine.EVENT_UI_BASE_ID
    _mn.FormCloseEventID =_cfg.UseUiId * 10 + 9 + EventConstDefine.EVENT_UI_BASE_ID
    return _mn
end

-- Parse activity configuration data
function OnlinePromptData:ParseSelfCfgData(jsonTable)
    self.BackTexs = {}
    for k,v in pairs(jsonTable) do
        local _occ = tonumber(k)
        if _occ ~= nil then
            self.BackTexs[_occ] = v
        end
    end
    self.OpenHDID = jsonTable.toFunction
end

-- Analyze the data of active players
function OnlinePromptData:ParsePlayerData(jsonTable)
end

-- Refresh data
function OnlinePromptData:RefreshData()
    self.FrontActive = nil
end

function OnlinePromptData:UpdateActive()
    local _active = self:IsActive()
    if self.FrontActive ~= _active and _active then
        -- Pop-up interface
        GameCenter.PushFixEvent(self.FormOpenEventID, self.TypeId)
    end
    self.FrontActive = _active
end

return OnlinePromptData
