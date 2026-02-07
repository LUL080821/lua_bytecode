
------------------------------------------------
-- Author:
-- Date: 2019-10-29
-- File: LingTiData.lua
-- Module: LingTiData
-- Description: Spiritual body data
------------------------------------------------
-- Quote
local LingTiCel = require "Logic.LingTi.LingTiCel"
local LingTiData = {
    -- Configuration data
    Cfg = nil,
    -- Whether to activate
    IsActive= false,
    -- Default quality
    MinQuality = 6,
    -- Equipment grid data
    ListEquipCel = List:New(),
}

function LingTiData:New(cfg)
    local _m = Utils.DeepCopy(self)
    _m.Cfg = cfg
    _m:InitEquipCelList()
    return _m
end

-- Analyze data
function LingTiData:Parase(info)
    if info == nil then
        return
    end
    if info.equipList  == nil then
        return
    end
    for i = 1, #info.equipList do
        self:SetCel(info.equipList[i])
    end
    self.IsActive = info.isActive
end

-- Initialize the equipment grid List
function LingTiData:InitEquipCelList()
    -- A total of 8 grids
    for i = 1,8 do
        local cel = LingTiCel:New()
        self.ListEquipCel:Add(cel)
    end
    local array = Utils.SplitStr(self.Cfg.Equip,'_')
    if array ~= nil then
        local _qua = -1
        for i = 1, #array do
            local cfg = DataConfig.DataEquip[tonumber(array[i])]
            if cfg ~= nil then
                _qua = cfg.Quality
                self.MinQuality = _qua
                break
            end
        end
    end
end

-- Set up equipment grid
function LingTiData:SetCel(equipId)
    local _dic = Dictionary:New()
    if equipId ~= 0 then
        local equipCfg = DataConfig.DataEquip[equipId]
        if equipCfg then
            self.ListEquipCel[equipCfg.Part + 1].EquipId = equipId
            self.ListEquipCel[equipCfg.Part + 1].StarNum = equipCfg.DiamondNumber
            local list = Utils.SplitStr(equipCfg.Attribute1, ';')
            if list ~= nil then
                for j = 1,#list do
                    local array = Utils.SplitNumber(list[j],'_')
                    if _dic:ContainsKey(array[1]) then
                        _dic[array[1]] = _dic[array[1]] + array[2]
                    else
                        _dic:Add(array[1], array[2])
                    end
                end
            end
            if equipCfg.Attribute2 then
                list = Utils.SplitStr(equipCfg.Attribute2, ';')
                if list ~= nil then
                    for j = 1,#list do
                        local array = Utils.SplitNumber(list[j],'_')
                        if _dic:ContainsKey(array[1]) then
                            _dic[array[1]] = _dic[array[1]] + array[2]
                        else
                            _dic:Add(array[1], array[2])
                        end
                    end
                end
            end
            self.ListEquipCel[equipCfg.Part + 1].AttDic = _dic
        end
    end
end

function LingTiData:GetAllAtt()
    local _dic = Dictionary:New()
    for i = 1, #self.ListEquipCel do
        if self.ListEquipCel[i].AttDic then
            self.ListEquipCel[i].AttDic:Foreach(function(k, v)
                if _dic:ContainsKey(k) then
                    _dic[k] = _dic[k] + v
                else
                    _dic:Add(k, v)
                end
            end)
        end
    end
    return _dic
end

return LingTiData