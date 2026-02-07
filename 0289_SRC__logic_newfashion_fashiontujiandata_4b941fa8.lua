------------------------------------------------
-- Author:
-- Date: 2020-08-22
-- File: FashionTuJianData.lua
-- Module: FashionTuJianData
-- Description: Fashion illustration data
------------------------------------------------

local FashionTuJianData = {
    StarNum = 0,
    IsActive = false,
    CfgId = 0,
    Cfg = nil,
    IconId = -1,
    Name = nil,
    Type = nil,
    -- Collected fashion data
    -- {FashionId: Fashion ID, SortId: SortId, IsActive: Whether to activate, StarNum: Number of rising stars}
    ListNeedData = List:New(),
    -- Set Properties
    -- {AttId: Attribute ID, Value: Attribute value Num: Activation number}
    ListRentAtt = List:New(),
    -- Property List
    -- {AttId: Attribute ID, Value: Attribute value Add: Add value}
    ListAttr = List:New(),
}

function FashionTuJianData:New(id, cfg)
    local _m = Utils.DeepCopy(self)
    _m.Cfg = cfg
    _m.CfgId = cfg.Id
    return _m
end

function FashionTuJianData:SetData(msg)
end

-- Set up the fashion data list required for activation of the picture book
function FashionTuJianData:UpdateNeedDataList()
    local needList = self:GetNeedDataList()
    if needList == nil then
        return
    end
    for i = 1, #needList do
        local need = needList[i]
        if need ~= nil then
            local fashionData = GameCenter.NewFashionSystem:GetFashionDogiamData(need.FashionId)
            if fashionData ~= nil then
                need.IsActive = fashionData.IsActive
            end
        end
    end
end

function FashionTuJianData:SetNeedData(fashionData)
    if fashionData == nil then
        return
    end
    local needList = self:GetNeedDataList()
    if needList == nil then
        return
    end
    for i = 1, #needList do
        local need = needList[i]
        if need ~= nil then
            if need.FashionId == fashionData:GetCfgId() then
                need.IsActive = fashionData.IsActive
                break
            end
        end
    end
end

-- Get the list of fashion data required for activation of the picture book
function FashionTuJianData:GetNeedDataList()
    if #self.ListNeedData == 0 then
        if self.Cfg ~= nil then
            local list = Utils.SplitStr(self.Cfg.NeedFashionId, ';')
            for i = 1,#list do
                local subList = Utils.SplitNumber(list[i], '_')
                if #subList ~= 2 then
                    Debug.LogError("fashion_link cfg needFashionId param is error!")
                else
                    local data = {SortId = subList[1], FashionId = subList[2], IsActive = false}
                    self.ListNeedData:Add(data)
                end
            end
        end
    end
    return self.ListNeedData
end

-- Get the ID
function FashionTuJianData:GetCfgId()
    return self.CfgId
end

-- Get the name of the picture book
function FashionTuJianData:GetName()
    if self.Name == nil then
        self.Name = self.Cfg.Name
    end
    return self.Name
end

-- CUSTOM - get type
function FashionTuJianData:GetType()
    if self.Cfg ~= nil then
        local list = Utils.SplitStr(self.Cfg.NeedFashionId, ';')
        local subList = Utils.SplitNumber(list[1], '_')
        if #subList ~= 2 then
            Debug.LogError("fashion_link cfg needFashionId param is error!")
        else
            local fashionData = GameCenter.NewFashionSystem:GetFashionDogiamData(subList[2])
            self.Type = fashionData:GetType()
        end
    end
    return self.Type
end
-- CUSTOM - get type

-- Get the illustration icon
function FashionTuJianData:GetIconId(occ)
    if self.IconId == -1 then
        if self.Cfg ~= nil then
            local list = Utils.SplitStr(self.Cfg.Icon, ';')
            for i = 1,#list do
                local subList = Utils.SplitNumber(list[i], '_')
                if #subList ~= 2 then
                    Debug.LogError("fashion_link cfg icon param is error!")
                else
                    if occ == subList[1] then
                        self.IconId = subList[2]
                    end
                end
            end
        end
    end
    return self.IconId
end

-- Get the set attribute list
function FashionTuJianData:GetRentAttList()
    if #self.ListRentAtt == 0 then
        if self.Cfg ~= nil then
            local list = Utils.SplitStr(self.Cfg.RentAtt, ';')
            for i = 1,#list do
                local subList = Utils.SplitNumber(list[i], '_')
                if #subList ~= 3 then
                    Debug.LogError("fashion_link cfg rentAtt param is error!")
                else
                    local data = {AttId = subList[2], Value = subList[3], Num = subList[1]}
                    self.ListRentAtt:Add(data)
                end
            end
        end
    end
    return self.ListRentAtt
end

function FashionTuJianData:GetQuality()
    local ret = 0
    if self.Cfg ~= nil then
        ret = self.Cfg.Quality
    end
    return ret
end

-- Get the list of illustration attributes
function FashionTuJianData:GetAttList()
    if #self.ListAttr == 0 then
        -- Set basic properties
        if self.Cfg ~= nil then
            local list = Utils.SplitStr(self.Cfg.ActivationAtt, ';')
            for i = 1,#list do
                local subList = Utils.SplitNumber(list[i], '_')
                if #subList ~= 2 then
                    Debug.LogError("fashion_link cfg activationAtt param is error!")
                else
                    local data = {AttId = subList[1], Value = subList[2], Add = 0}
                    self.ListAttr:Add(data)
                end
            end
            -- Set attributes to increase value
            list = Utils.SplitStr(self.Cfg.StarAtt, ';')
            for i = 1,#list do
                local subList = Utils.SplitNumber(list[i], '_')
                if #subList ~= 2 then
                    Debug.LogError("fashion_link cfg starAtt param is error!")
                else
                    local id = subList[1]
                    local value = subList[2]
                    for m = 1, #self.ListAttr do
                        local data = self.ListAttr[m]
                        if data.AttId == id then
                            data.Add = value
                        end
                    end
                end
            end
        end
    end
    return self.ListAttr
end

return FashionTuJianData