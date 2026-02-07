
------------------------------------------------
-- Author:
-- Date: 2019-04-22
-- File: ModelViewSystem.lua
-- Module: ModelViewSystem
-- Description: Model display
------------------------------------------------
-- Quote
local ModelViewSystem = {
    ModelId = 0,              -- Model id
    FashionBodyId = 0,        -- Fashion model id
    FashionWeaponId = 0,      -- Fashion weapon id
    Scale = 0,                -- Scaling value
    PosY = nil,               -- Y position
    ShowType = 0,             -- Display Type
    Name = "",                -- Show name
    IsShowWear = false,       -- Whether to show wear
    WearId = 0,               -- Wear id
    IsStartTaskOnHide = false, -- Whether to execute the main line after closing
    ExtData = nil,             -- Additional data
    DelayTime = 0,             -- Delay time for opening the interface
}

-- initialization
function ModelViewSystem:Initialize()
    GameCenter.RegFixEventHandle(LogicLuaEventDefine.EID_EVENT_SHOWMODEL_VIEW, self.OnShowModelEvent, self);
end

-- De-initialization
function ModelViewSystem:UnInitialize()
    GameCenter.UnRegFixEventHandle(LogicLuaEventDefine.EID_EVENT_SHOWMODEL_VIEW, self.OnShowModelEvent, self);
end

function ModelViewSystem:Update(dt)
    if self.DelayTime > 0 then
        self.DelayTime = self.DelayTime - dt
        if self.DelayTime <= 0 then
            GameCenter.PushFixEvent(UIEventDefine.UIModelViewForm_OPEN)
        end
    end
end

-- Show the model
function ModelViewSystem:OnShowModelEvent(obj, sender)
    if obj == nil then
        return
    end
    if type(obj) == "table" then
        local type = obj[1]
        local id = obj[2]
        local scale = obj[3]
        local posY = obj[4]
        local name = ""
        if obj[5] then
            name = obj[5]
        end
        self:ShowModel(type, id, scale, posY, name)
    else
        local type = obj[0]
        local id = obj[1]
        local scale = obj[2]
        local posY = obj[3]
        local name = ""
        if obj[4] then
            name = obj[4]
        end
        self:ShowModel(type, id, scale, posY, name)
    end
end

function ModelViewSystem:ShowModel(mtype,id, scale, posY, name, isShowWear, wearId, info)
    self.IsShowWear = false
    if isShowWear then
        self.IsShowWear = true
        self.WearId = wearId
    end
    self.DelayTime = 0
    self.ExtData = nil
    if info ~= nil and type(info) == "number" then
        self.DelayTime = info
    elseif info ~= nil then
        self.ExtData = info
    end
    if mtype == ShowModelType.Mount then
        self:ShowMount(id,scale,posY, name)
    elseif mtype == ShowModelType.Wing then
        self:ShowWing(id, name)
    elseif mtype == ShowModelType.FaBao then
        self:ShowFaBao(id,scale,posY, name)
    elseif mtype == ShowModelType.Player then
        self:ShowPlayer(id,scale,posY, name)
    elseif mtype == ShowModelType.Fashion then
        self:ShowLpFashion(scale,posY, name)
    elseif mtype == ShowModelType.Pet then
        self:ShowPet(id, scale,posY, name)
    elseif mtype == ShowModelType.LpWeapon then
        self:ShowLpWeapon(id, scale, posY, name)
    elseif mtype == ShowModelType.SoulEquip then
        self:ShowSoulEquip(id, scale, posY, name)
    elseif mtype == ShowModelType.SpecialBox then
        self:ShowSpecialBox(id, scale, posY, name)
    elseif mtype == ShowModelType.Gather then
        self:ShowGather(id, scale, posY, name)
    end
end

-- Show mount model
function ModelViewSystem:ShowMount(id, scale, posY, name)
    self.ModelId = id
    self.Scale = scale
    self.PosY = posY
    self.Name = name
    self.ShowType = ShowModelType.Mount
    self.IsShowWear = false
    if self.DelayTime <= 0 then
        GameCenter.PushFixEvent(UIEventDefine.UIModelViewForm_OPEN)
    end
end

-- Show wing model
function ModelViewSystem:ShowWing(id, name)
    self.ModelId = id
    self.Name = name
    self.ShowType = ShowModelType.Wing
    if self.DelayTime <= 0 then
        GameCenter.PushFixEvent(UIEventDefine.UIModelViewForm_OPEN)
    end
end

-- Show magic weapon model
function ModelViewSystem:ShowFaBao(id, scale, posY, name)
    self.ModelId = id
    self.Scale = scale
    self.PosY = posY
    self.Name = name
    self.IsShowWear = false
    self.ShowType = ShowModelType.FaBao
    if self.DelayTime <= 0 then
        GameCenter.PushFixEvent(UIEventDefine.UIModelViewForm_OPEN)
    end
end

-- Showcase treasure chest model
function ModelViewSystem:ShowSpecialBox(id, scale, posY, name)
    self.ModelId = id
    self.Scale = scale
    self.PosY = posY
    self.Name = name
    self.ShowType = ShowModelType.SpecialBox
    if self.DelayTime <= 0 then
        GameCenter.PushFixEvent(UIEventDefine.UIModelViewForm_OPEN)
    end
end

-- Show soul armor model
function ModelViewSystem:ShowSoulEquip(id, scale, posY, name)
    self.ModelId = id
    self.Scale = scale
    self.PosY = posY
    self.Name = name
    self.ShowType = ShowModelType.SoulEquip
    if self.DelayTime <= 0 then
        GameCenter.PushFixEvent(UIEventDefine.UIModelViewForm_OPEN)
    end
end

-- Show role models
function ModelViewSystem:ShowPlayer(id, scale, posY, name)
    self.ModelId = id
    self.Scale = scale
    self.PosY = posY
    self.Name = name
    self.ShowType = ShowModelType.Player
    if self.DelayTime <= 0 then
        GameCenter.PushFixEvent(UIEventDefine.UIModelViewForm_OPEN)
    end
end

-- Show weapon models
function ModelViewSystem:ShowLpWeapon(id, scale, posY, name)
    --LpWeapon
    self.ModelId = id
    self.Scale = scale
    self.PosY = posY
    self.Name = name
    self.ShowType = ShowModelType.LpWeapon
    if self.DelayTime <= 0 then
        GameCenter.PushFixEvent(UIEventDefine.UIModelViewForm_OPEN)
    end
end

-- Show fashion
function ModelViewSystem:ShowLpFashion(scale, posY, name)
    self.Scale = scale
    self.PosY = posY
    self.Name = name
    local wearList = GameCenter.NewFashionSystem.WearList
    if wearList == nil then
        return
    end
    local occ = 0
    local player = GameCenter.GameSceneSystem:GetLocalPlayer()
    if player then
        occ = player.IntOcc
    end
    for i = 1,#wearList do
        if wearList[i].Type == NewFashionType.Body then
            -- Get the Fashion Model ID
            self.FashionBodyId = RoleVEquipTool.GetFashionBodyModelID(occ, wearList[i].Id)
        elseif wearList[i].Type == NewFashionType.Weapon then
            -- Get the Weapon ID
            self.FashionWeaponId = RoleVEquipTool.GetFashionWeaponModelID(occ, wearList[i].Id)
        end
    end
    self.ShowType = ShowModelType.Fashion
    if self.DelayTime <= 0 then
        GameCenter.PushFixEvent(UIEventDefine.UIModelViewForm_OPEN)
    end
end

-- Show fashion
function ModelViewSystem:ShowFashion(data,scale, posY, name)
    self.Scale = scale
    self.PosY = posY
    self.Name = name
    local occ = 0
    local player = GameCenter.GameSceneSystem:GetLocalPlayer()
    if player then
        occ = player.IntOcc
    end
    local type = data:GetType()
    if type == NewFashionType.Body then
        self.FashionBodyId = data:GetModelId(occ)
    elseif type == NewFashionType.Weapon then
        self.FashionWeaponId = data:GetModelId(occ)
    end
    self.ShowType = ShowModelType.Fashion
    if self.DelayTime <= 0 then
        GameCenter.PushFixEvent(UIEventDefine.UIModelViewForm_OPEN)
    end
end

-- Show magic weapon model
function ModelViewSystem:ShowPet(id, scale, posY, name)
    self.ModelId = id
    self.Scale = scale
    self.PosY = posY
    self.Name = name
    self.IsShowWear = false
    self.ShowType = ShowModelType.Pet
    if self.DelayTime <= 0 then
        GameCenter.PushFixEvent(UIEventDefine.UIModelViewForm_OPEN)
    end
end

-- Show gather model
function ModelViewSystem:ShowGather(id, scale, posY, name)
    self.ModelId = id
    self.Scale = scale
    self.PosY = posY
    self.Name = name
    self.IsShowWear = false
    self.ShowType = ShowModelType.Gather
    if self.DelayTime <= 0 then
        GameCenter.PushFixEvent(UIEventDefine.UIModelViewForm_OPEN)
    end
end

return ModelViewSystem
