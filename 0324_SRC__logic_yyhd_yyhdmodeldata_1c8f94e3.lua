------------------------------------------------
-- Author: 
-- Date: 2021-04-15
-- File: YYHDModelData.lua
-- Module: YYHDModelData
-- Description: Operational activity model data
------------------------------------------------

local YYHDModelData = {
    DataId = 0,
    OccModel = nil,
}

function YYHDModelData:New(json)
    if json == nil or json.modelDataList == nil then
        return nil
    end
    local _m = Utils.DeepCopy(self)
    _m:Parse(json)
    return _m
end

function YYHDModelData:Parse(json)
    self.DataId = tonumber(json.id)
    self.OccModel = {}
    for i = 1, #json.modelDataList do
        local _data = json.modelDataList[i]
        local _occ = tonumber(_data.career)
        self.OccModel[_occ] = {
            PosX = tonumber(_data.posX),
            PosY = tonumber(_data.posY),
            Occ = tonumber(_data.career),
            RotX = tonumber(_data.rotX),
            RotY = tonumber(_data.rotY),
            RotZ = tonumber(_data.rotZ),
            Scale = tonumber(_data.scale),
            ModelId = tonumber(_data.modelId),
        }
    end
end

function YYHDModelData:RefreshModel(skin, occ)
    if skin == nil then
        return false
    end
    local _data = self.OccModel[occ]
    if _data == nil then
        _data = self.OccModel[9]
    end
    if _data == nil then
        return
    end
    skin:ResetSkin()
    skin:SetPos(_data.PosX, _data.PosY)
    skin:SetEulerAngles(_data.RotX, _data.RotY, _data.RotZ)
    skin:SetLocalScale(_data.Scale)
    skin:SetEquip(FSkinPartCode.Body, _data.ModelId)
end

return YYHDModelData