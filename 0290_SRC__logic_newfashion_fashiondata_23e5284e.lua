------------------------------------------------
-- Author:
-- Date: 2020-08-22
-- File: FashionTuJianData.lua
-- Module: FashionTuJianData
-- Description: Fashion illustration data
------------------------------------------------
local FashionData = {
    StarNum = 0,
    -- Whether to wear it
    IsWear = false,
    -- Whether to activate
    IsActive = false,
    -- Is it new?
    IsNew = false,
    CfgId = 0,
    Cfg = nil,
    IconId = -1,
    -- Model ID
    ModelId = 0,
    -- Activate prop ID
    ItemId = 0,
    -- {AttId: Attribute ID, Value: Attribute value, Add: Add attribute}
    ListAtt = List:New()
}

function FashionData:New(id, cfg)
    local _m = Utils.DeepCopy(self)
    _m.CfgId = id
    _m.Cfg = cfg
    return _m
end

-- Get the configuration ID
function FashionData:GetCfgId()
    return self.CfgId
end

-- Get configuration data
function FashionData:GetCfg()
    return self.Cfg
end

-- Get Type
function FashionData:GetType()
    return self.Cfg.Type
end

-- Get the name
function FashionData:GetName()
    return self.Cfg.Name
end

-- Get the desc
function FashionData:GetDesc()
    return self.Cfg.Desc
end

-- Get the model id
function FashionData:GetModelId(occ)
    if self.ModelId == -1 then
        if self.Cfg ~= nil then
            local list = Utils.SplitStr(self.Cfg.Res, ';')
            for i = 1,#list do
                local subList = Utils.SplitNumber(list[i], '_')
                if occ == subList[1] then
                    self.ModelId = subList[2]
                end
            end
        end
    end
    return self.ModelId
end

-- Get the illustration icon
function FashionData:GetIconId(occ)
    if self.IconId == -1 then
        if self.Cfg ~= nil then
            local list = Utils.SplitStr(self.Cfg.Icon, ';')
            for i = 1,#list do
                local subList = Utils.SplitNumber(list[i], '_')
                if occ == subList[1] then
                    self.IconId = subList[2]
                end
            end
        end
    end
    return self.IconId
end

-- Get the set attribute list
function FashionData:GetAttList()
    if #self.ListAtt == 0 then
        if self.Cfg ~= nil then
            local list = Utils.SplitStr(self.Cfg.RentAtt, ';')
            for i = 1,#list do
                local subList = Utils.SplitNumber(list[i], '_')
                local data = {AttId = subList[1], Value = subList[2], Add = subList[3]}
                self.ListAtt:Add(data)
            end
        end
    end
    return self.ListAtt
end

-- Get activation props

-- Get Fashion Stars
function FashionData:GetStarNum()
    return self.StarNum
end

-- Get the prop id
function FashionData:GetItemId(occ)
    if self.ItemId == 0 then
        if self.Cfg ~= nil then
            local list = Utils.SplitStr(self.Cfg.ActiveItem, ';')
            for i = 1,#list do
                local subList = Utils.SplitNumber(list[i], '_')
                if occ == subList[1] then
                    self.ItemId = subList[2]
                    break
                end
            end
        end
    end
    return self.ItemId
end

function FashionData:GetNeedItemNum(starNum)
    local ret = 0
    if self.Cfg ~= nil then
        local list = Utils.SplitStr(self.Cfg.StarItemnum, ';')
        for i = 1,#list do
            local subList = Utils.SplitNumber(list[i], '_')
            if starNum == subList[1] then
                ret = subList[2]
                break
            end
        end
    end
    return ret
end

-- Get Quality
function FashionData:GetQuality()
    local ret = 0
    if self.Cfg ~= nil then
        ret = self.Cfg.Quality
    end
    return ret
end

-- Get the model id
function FashionData:GetModelId(occ)
    local ret = 0
    if self.Cfg ~= nil then
        local list = Utils.SplitStr(self.Cfg.Res, ';')
        for i = 1,#list do
            local subList = Utils.SplitNumber(list[i], '_')
            if occ == subList[1] then
                ret = subList[2]
                break
            end
        end
    end
    return ret
end

-- Get the Y coordinates of the model
function FashionData:GetModelYPos()
    local ret = 0
    if self.Cfg ~= nil then
        ret = self.Cfg.ModelYPos
    end
    return ret
end

-- Get the model X coordinate
function FashionData:GetModelXPos()
    local ret = 0
    if self.Cfg ~= nil then
        ret = self.Cfg.ModelXPos
    end
    return ret
end

-- Get the Z coordinates of the model
function FashionData:GetModelZPos()
    local ret = 0
    if self.Cfg ~= nil then
        ret = self.Cfg.ModelZPos
    end
    return ret
end

-- Get the model Y-axis rotation value
function FashionData:GetModelYRot()
    local ret = 0
    if self.Cfg ~= nil then
        ret = self.Cfg.ModelYRot
    end
    return ret
end

-- Get the model Y-axis rotation value
function FashionData:GetModelZRot()
    local ret = 0
    if self.Cfg ~= nil then
        ret = self.Cfg.ModelZRot
    end
    return ret
end

-- Get the camera size
function FashionData:GetCameraSize()
    local ret = 0
    if self.Cfg ~= nil then
        ret = self.Cfg.CameraSize
    end
    return ret
end

-- Can I upgrade my star
function FashionData:CanUpStar(occ)
    if self.StarNum >= 5 then
        return false
    end
    local itemId = self:GetItemId(occ)
    local needNum = self:GetNeedItemNum(self.StarNum)
    local count = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(itemId)
    return count >= needNum
end

-- Determine whether it can be activated
function FashionData:CanActive(occ)    
    local itemId = self:GetItemId(occ)
    local needNum = self:GetNeedItemNum(0)
    local count = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(itemId)
    return count >= needNum
end

function FashionData:IsEquialWithModelId(id, occ)
   return self:GetModelId(occ) == id 
end

return FashionData