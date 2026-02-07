
------------------------------------------------
-- Author:
-- Date: 2020-05-07
-- File: LingTiUnlockData.lua
-- Module: LingTiUnlockData
-- Description: Spiritual unblocking data
------------------------------------------------
local LingTiUnlockData = {
    -- Configuration data
    Cfg = nil,
    -- Whether to activate
    IsActive= false,
    -- Model
    ModelId = 0,
    -- property
    DicAttrData = Dictionary:New(),
}

function LingTiUnlockData:New(cfg, occ)
    local _m = Utils.DeepCopy(self)
    _m.Cfg = cfg
    _m.IsActive = false
    _m.DicAttrData:Clear()
    _m:InitAttrList(cfg.Attribute)
    if occ then
        local _id = occ * 100 + cfg.Grade
        local _modelCfg = DataConfig.DataEquipCollectionModel[_id]
        if _modelCfg then
            _m.ModelId = _modelCfg.Model
        end
    end
    return _m
end

-- Initialize the attribute List
function LingTiUnlockData:InitAttrList(attrStr)
    if attrStr then
        local _arr = Utils.SplitStr(attrStr, ';')
        for i = 1, #_arr do
            local _att = Utils.SplitNumber(_arr[i], '_')
            self.DicAttrData:Add(_att[1], _att[2])
        end
    end
end

return LingTiUnlockData