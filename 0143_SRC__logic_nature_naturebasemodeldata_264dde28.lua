------------------------------------------------
-- Author: 
-- Date: 2019-04-18
-- File: NatureModelData.lua
-- Module: NatureModelData
-- Description: Creation Panel Model Data
------------------------------------------------
-- Quote

------------------------------------------------
local NatureBaseModelData = {
    Modelid = 0, -- Configure table model id
    IsActive = false, -- Whether the model is activated
    Stage = 0, -- Several orders of model
    Name = nil, -- Model name
    CameraSize = 0, -- Model Scaling
    ModelIdList = List:New(), -- Get the model by occupation and save the list
}

NatureBaseModelData.__index = NatureBaseModelData

function NatureBaseModelData:New(natureatt,naturetype)
    local _M = Utils.DeepCopy(self)
    if type(natureatt.ModelID) == "number" then
        _M.Modelid = natureatt.ModelID
    else
        _M.ModelIdList = Utils.SplitNumber(natureatt.ModelID, '_')
    end
    _M.IsActive = false
    _M.Stage = naturetype == NatureEnum.Mount and natureatt.Steps or natureatt.Id
    _M.Name = natureatt.Name
    _M.CameraSize = natureatt.CameraSize
    return _M
end

return NatureBaseModelData