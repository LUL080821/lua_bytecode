------------------------------------------------
-- author:
-- Date: 2021-06-29
-- File: JianCoreData.lua
-- Module: JianCoreData
-- Description: Sword Core Data
------------------------------------------------
local JianCoreData = {
    -- Sword Spirit Serial Number
    JianId = 0, 
    -- Core ID
    CoreId = 0,
    -- Activation level
    JianActiveLv = 0,
    Name = nil,
}

function JianCoreData:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

function JianCoreData:GetName()
    if self.Name == nil then
        local _cfg = DataConfig.DataImmortalSoulCore[self.JianId]
        if _cfg ~= nil then
            self.Name = _cfg.Name
        end
    end
    return self.Name
end

function JianCoreData:GetCoreLv()
    local _ret = 0
    if self.CoreId ~= 0 then
        local _cfg = DataConfig.DataImmortalSoulCoreAtt[self.CoreId]
        if _cfg ~= nil then
            _ret = _cfg.Level
        end
    end
    return _ret
end

function JianCoreData:GetCoreActive()
    local _ret = false
    if self.CoreId ~= 0 then
        _ret = true
    end
    return _ret
end

-- Get the sword spirit activated
function JianCoreData:GetJianValid()
    local _ret = false
    local _preJianId = 0
    local _cfg = DataConfig.DataGlobal[GlobalName.immortal_soul_core_limit]
    if _cfg  ~= nil then
        local _list = Utils.SplitStr(_cfg.Params, ';')
        if _list ~= nil then
            for i = 1, #_list do
                local _values = Utils.SplitNumber(_list[i], '_')
                if _values ~= nil then
                    if _values[1] == self.JianId then
                        self.JianActiveLv = _values[2]
                        if _preJianId == 0 then
                            _preJianId = _values[1]
                        end
                        local _preData = GameCenter.XianPoSystem:GetJianCoreData(_preJianId)
                        local _preLv = _preData:GetCoreLv()
                        if _preLv >= _values[2] then
                            _ret = true
                            break
                        end
                    end
                    _preJianId = _values[1]
                end
            end
        end
    end
    return _ret
end

-- Get the core icon
function JianCoreData:GetCoreIcon()
    local _ret = 0
    local _cfg = DataConfig.DataImmortalSoulCore[self.JianId]
    if _cfg ~= nil then
        _ret = _cfg.Icon
    end
    return _ret
end

-- Get a description without activation
function JianCoreData:GetDisActiveDes() 
    local _ret = ""
    local _cfg = DataConfig.DataImmortalSoulCore[self.JianId]
    if _cfg ~= nil then
        _ret = _cfg.NoactiveDes
    end
    return _ret
end

-- Get the activation condition description
function JianCoreData:GetActiveCondition()
    local _ret = ""
    local _cfg = DataConfig.DataImmortalSoulCore[self.JianId]
    if _cfg ~= nil then
        _ret = _cfg.ActiveCondition
    end
    return _ret
end

-- Get core attributes
function JianCoreData:GetAttList()
    local _ret = List:New()
    if self.CoreId ~= 0 then
        local _cfg = DataConfig.DataImmortalSoulCoreAtt[self.CoreId]
        if _cfg ~= nil then
            local _list = Utils.SplitStr(_cfg.AddAtt, ';')
            if _list ~= nil then
                for i  =1, #_list do
                    local _values = Utils.SplitNumber(_list[i], '_')
                    local _attr = {AttId = _values[1], Value = _values[2]}
                    _ret:Add(_attr)
                end
            end
        end
    end
    return _ret
end

-- Get the description of the next sword spirit opening
function JianCoreData:GetNextJianDes()
    local _ret = ""
    local _isFind = false
    local _cfg = DataConfig.DataGlobal[GlobalName.immortal_soul_core_limit]
    if _cfg  ~= nil then
        local _list = Utils.SplitStr(_cfg.Params, ';')
        if _list ~= nil then
            for i = 1, #_list do
                local _values = Utils.SplitNumber(_list[i], '_')
                if _values ~= nil then
                    if self.JianId < _values[1] then
                        _isFind = true
                        break
                    end
                end
            end
        end
    end
    if _isFind then
        local _nextData = GameCenter.XianPoSystem:GetJianCoreData(self.JianId + 1)
        if _nextData ~= nil then
            local _isValid = _nextData:GetJianValid()
            if not _isValid then
                local _name = GameCenter.XianPoSystem:GetJianName(_nextData.JianId)
                _ret = UIUtils.CSFormat(DataConfig.DataMessageString.Get("LING_PO_CORE_NEXT_DES1"), _nextData.JianActiveLv, _name)
            end
        end
    else
        _ret = ""
    end
    return _ret
end

-- Obtain the total level of spiritual soul required for the next sword spirit
function JianCoreData:GetNextJianLingPoLvDes()
    local _ret = ""
    local _curLv = GameCenter.XianPoSystem:GetAllEquipLv(self.JianId)
    local _cfg = DataConfig.DataImmortalSoulCoreAtt[self.CoreId]
        if _cfg ~= nil then
            if _cfg.NextLevel ~= 0 then
                _ret = UIUtils.CSFormat(DataConfig.DataMessageString.Get("LING_PO_CORE_NEXT_DES2"), _curLv, _cfg.NextLevel)
            end
        end
    return _ret
end

return JianCoreData
