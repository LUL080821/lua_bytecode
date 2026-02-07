------------------------------------------------
-- author:
-- Date: 2021-06-11
-- File: FashionScene.lua
-- Module: FashionScene
-- Description: Fashion UIScene
------------------------------------------------
-- Quote
local L_SceneBase = require "Logic.UIScene.Instance.UISceneBase"
local LuaFGameObjectModel = CS.Thousandto.Plugins.LuaType.LuaFGameObjectModel

local FashionScene = {
    IsSetDrag = false,
    Skin = nil,
    PetSkin = nil,
    FbSkin = nil,
    SoulSkin = nil,
    UiSkin = nil,
    UiPetSkin = nil,
    UiFbSkin = nil,
    UiSoulSkin = nil,
    Vfx = nil,
    RotaTrans = nil,
    RotaPetTrans = nil,
    RotaFbTrans = nil,
    RotaSoulTrans = nil,
    CacheDataDic = Dictionary:New(),
    CacheVfxList = List:New(),
    DefaultAnimCache = Dictionary:New(),
}

function FashionScene:New(type, id, manager)
    local _m = Utils.Extend(L_SceneBase:New(type, id, manager), self)
    _m:LoadScene()
    return _m
end

function FashionScene:LoadScene()
    self.IsLoadFinish = false
    local sceneModel = LuaFGameObjectModel.Create(ModelTypeCode.UISceneModel, self.ModelId, false, true, false)
    sceneModel.OnLoadFinishedCallBack = Utils.Handler(self.LoadedCallBack, self, nil, true)
end

function FashionScene:OnLoadedCallBack(obj)
    if self.SceneObj ~= nil and self.SceneObj.RealTransform ~= nil then
        self.Vfx = UIUtils.RequireUIVfxSkinCompoent(UIUtils.FindTrans(self.SceneObj.RealTransform, "UIShandowPlane/UIVfxSkinCompoent"))
        self.Skin = UIUtils.RequireUIRoleSkinCompoent(UIUtils.FindTrans(self.SceneObj.RealTransform, "UIShandowPlane/UIRoleSkinCompoent"))
        self.PetSkin = UIUtils.RequireUIRoleSkinCompoent(UIUtils.FindTrans(self.SceneObj.RealTransform, "UIShandowPlane/PetSkinCompoent"))
        self.FbSkin = UIUtils.RequireUIRoleSkinCompoent(UIUtils.FindTrans(self.SceneObj.RealTransform, "UIShandowPlane/FaBaoSkinCompoent"))
        self.SoulSkin = UIUtils.RequireUIRoleSkinCompoent(UIUtils.FindTrans(self.SceneObj.RealTransform, "UIShandowPlane/SoulSkinCompoent"))
        
        -- [Gosu] Fix Hide beijing
        self.Beijing = UIUtils.FindTrans(self.SceneObj.RealTransform, "beijing")
        if self.Beijing ~= nil then
            self.Beijing.gameObject:SetActive(false)
        end
        
        if self.Skin ~= nil then
            self.Skin:OnFirstShow(nil, FSkinTypeCode.Custom, "", 1, false, false)
            self.Skin.Layer = LayerUtils.UIStory
            self.RotaTrans = UIUtils.FindTrans(self.Skin.transform, "Box/ModelRoot")
            local box = UIUtils.FindTrans(self.Skin.transform, "Box")
            box.localPosition = Vector3.zero
            self.Skin.NormalRot = 0
        end
        if self.PetSkin ~= nil then
            self.PetSkin:OnFirstShow(nil, FSkinTypeCode.Custom, "", 1, false, false)
            self.PetSkin.Layer = LayerUtils.UIStory
            self.RotaPetTrans =  UIUtils.FindTrans(self.PetSkin.transform, "Box/ModelRoot")
            local box = UIUtils.FindTrans(self.PetSkin.transform, "Box")
            box.localPosition = Vector3.zero
            self.PetSkin.NormalRot = 0
        end
        if self.FbSkin ~= nil then
            self.FbSkin:OnFirstShow(nil, FSkinTypeCode.Custom, "", 1, false, false)
            self.FbSkin.Layer = LayerUtils.UIStory
            self.RotaFbTrans = UIUtils.FindTrans(self.FbSkin.transform, "Box/ModelRoot")
            local box = UIUtils.FindTrans(self.FbSkin.transform, "Box")
            box.localPosition = Vector3.zero
            self.FbSkin.NormalRot = 0
        end
        if self.SoulSkin ~= nil then
            self.SoulSkin:OnFirstShow(nil, FSkinTypeCode.Custom, "", 1, false, false)
            self.SoulSkin.Layer = LayerUtils.UIStory;
            self.RotaSoulTrans = UIUtils.FindTrans(self.SoulSkin.transform, "Box/ModelRoot")
            local box = UIUtils.FindTrans(self.SoulSkin.transform, "Box")
            box.localPosition = Vector3.zero
            self.SoulSkin.NormalRot = 0
        end
    end
    self.IsLoadFinish = true;
end

function FashionScene:OnDestory()
    if self.Skin ~= nil then
        self.Skin.Skin:RemoveAllSkinPart()
        self.Skin.Skin:SetActive(false)
        self.Skin.Skin:Destroy()
    end
    if self.PetSkin ~= nil then
        self.PetSkin.Skin:RemoveAllSkinPart()
        self.PetSkin.Skin:SetActive(false)
        self.PetSkin.Skin:Destroy()
    end
    if self.FbSkin ~= nil then
        self.FbSkin.Skin:RemoveAllSkinPart()
        self.FbSkin.Skin:SetActive(false)
        self.FbSkin.Skin:Destroy()
    end
    if self.SoulSkin ~= nil then
        self.SoulSkin.Skin:RemoveAllSkinPart()
        self.SoulSkin.Skin:SetActive(false)
        self.SoulSkin.Skin:Destroy()
    end
    self.RotaTrans = nil
    self.RotaPetTrans = nil
    self.RotaFbTrans = nil
    self.RotaSoulTrans = nil
    self.IsSetDrag = false
end

function FashionScene:OnUpdate(dt)
    if self.IsLoadFinish then
        self:UpdateDefaultAnim()
        self:UpdateEquip()
        self:UpdateBodyVfx()
        if not self.IsSetDrag and self.UiSkin ~= nil then
            if self.UiSkin ~= nil then
                self.UiSkin:SetUIModelDrag(self.RotaTrans)
            end
            if self.UiPetSkin ~= nil then
                self.UiPetSkin:SetUIModelDrag(self.RotaPetTrans)
            end
            if self.UiFbSkin ~= nil then
                self.UiFbSkin:SetUIModelDrag(self.RotaFbTrans)
            end
            if self.UiSoulSkin ~= nil then
                self.UiSoulSkin:SetUIModelDrag(self.RotaSoulTrans)
            end
            self.IsSetDrag = true
        end
    end
end

function FashionScene:SetEquip(type, id, sType, slot, animList, func)
    local data = {SkinType = sType, Part = type, Id = id, Slot = slot, AnimList = animList, Func = func}
    local isFind = false
    local dataList = self.CacheDataDic[sType]
    if dataList ~= nil then
        for i = 1, #dataList do
            if dataList[i].Part == type then
                dataList[i].Id = id
                isFind = true
            end
        end
        if not isFind then
            dataList:Add(data)
        end
    else
        dataList = List:New()
        dataList:Add(data)
        self.CacheDataDic:Add(sType, dataList)
    end
end

function FashionScene:SetCameraSize(size)
    if self.UiSkin ~= nil then
        self.UiSkin:SetCameraSize(size)
    end
end

function FashionScene:UpdateEquip()
    local data = self:GetCacheData()
    if data ~= nil then
        self:SetEquipData(data)
    end
end

function FashionScene:UpdateDefaultAnim()
    for k, v in pairs(self.DefaultAnimCache) do
        local skin = self:GetSkinByType(k)
        if skin ~= nil then
            skin:SetDefaultAnim(v[1], v[2])
        end
    end
    self.DefaultAnimCache:Clear()
end

function FashionScene:SetBodyVfx(id)
    self.CacheVfxList:Add(id)
end

function FashionScene:SetRotaTrans(skin, skinType)
    if skinType == SkinType.Player then
        if skin ~= nil then
            self.UiSkin = skin
            self.UiSkin:SetUIModelDrag(self.RotaTrans)
        end
    elseif skinType == SkinType.Pet then
        if skin ~= nil then
            self.UiPetSkin = skin
            self.UiPetSkin:SetUIModelDrag(self.RotaPetTrans)
        end
    elseif skinType == SkinType.FaBao then
        self.UiFbSkin = skin
        self.UiFbSkin:SetUIModelDrag(self.RotaFbTrans)
    elseif skinType == SkinType.Soul then
        self.UiSoulSkin = skin
        self.UiSoulSkin:SetUIModelDrag(self.RotaSoulTrans)
    end
end

function FashionScene:SetScale(skinType, scale)
    local skin = nil
    local uiSkin = nil
    if skinType == SkinType.Player then
        skin = self.Skin
        uiSkin = self.UiSkin
    elseif skinType == SkinType.Pet then
        skin = self.PetSkin
        uiSkin = self.UiPetSkin
    elseif skinType == SkinType.FaBao then
        skin = self.FbSkin
        uiSkin = self.UiFbSkin
    elseif skinType == SkinType.Soul then
        skin = self.SoulSkin
        uiSkin = self.UiSoulSkin
    end
    if skin ~= nil then
        skin:SetLocalScale(0)
    end
    if uiSkin ~= nil then
        uiSkin:SetLocalScale(0)
    end
end

function FashionScene:ResetSkin(skinType)
    if skinType == SkinType.Player then
        if self.Skin ~= nil then
            self.Skin:ResetRot()
            self.Skin:ResetSkin()
            self.Skin:SetLocalScale(0)
        end
        if self.UiSkin ~= nil then
            self.UiSkin:ResetRot()
            self.UiSkin:ResetSkin()
            self.UiSkin:SetLocalScale(0)
        end
        if self.Vfx ~= nil then
            self.Vfx:OnDestory()
        end
    elseif skinType == SkinType.Pet then
        if self.PetSkin ~= nil then
            self.PetSkin:ResetRot()
            self.PetSkin:ResetSkin()
            self.PetSkin:SetLocalScale(0)
        end
        if self.UiPetSkin ~= nil then
            self.UiPetSkin:ResetRot()
            self.UiPetSkin:ResetSkin()
            self.UiPetSkin:SetLocalScale(0)
        end
    elseif skinType == SkinType.FaBao then
        if self.FbSkin ~= nil then
            self.FbSkin:ResetRot()
            self.FbSkin:ResetSkin()
            self.FbSkin:SetLocalScale(0)
        end
        if self.UiFbSkin ~= nil then
            self.UiFbSkin:ResetRot()
            self.UiFbSkin:ResetSkin()
            self.UiFbSkin:SetLocalScale(0)
        end
    elseif skinType == SkinType.Soul then
        if self.SoulSkin ~= nil then
            self.SoulSkin:ResetRot()
            self.SoulSkin:ResetSkin()
            self.SoulSkin:SetLocalScale(0)
        end
        if self.UiSoulSkin ~= nil then
            self.UiSoulSkin:ResetRot()
            self.UiSoulSkin:ResetSkin()
            self.UiSoulSkin:SetLocalScale(0)
        end
    end
end

-- Set the main model zoom
function FashionScene:SetMainSkinScale(size, skinType)
    local skin = self:GetSkinByType(skinType)
    if skin ~= nil then
        skin:SetLocalScale(size)
    end
end

-- Set the main model Y coordinate
function FashionScene:SetMainSkinPos(x, y, z, skinType)
    local skin = self:GetSkinByType(skinType)
    if skin ~= nil then
        skin:SetPos(x, y, z)
    end
end

-- Set the main model rotation
function FashionScene:SetMainSkinRot(vec, skinType)
    local skin = self:GetSkinByType(skinType)
    if skin ~= nil then
        skin:SetSkinRot(vec)
    end
end

-- Play default action
function FashionScene:SetDefaultAnim(skinType, name, type)
    self.DefaultAnimCache[skinType] = {name, type}
end

-- Play specified action
function FashionScene:Play(skinType, name, type, model, speed, isFashionAnim)
    local skin = self:GetSkinByType(skinType)
    if skin ~= nil then
        local body = skin.Skin:GetSkinPart(FSkinPartCode.Body)
        skin:Play(name, type, model, speed)
        if isFashionAnim then
            if body ~= nil then
                body.BrightWeapon = true
            end
        else
            if body ~= nil then
                body.BrightWeapon = false
            end
        end
    end
end

function FashionScene:GetSkinByType(skinType)
    local skin = nil
    if skinType == SkinType.Player then
        skin = self.Skin
    elseif skinType == SkinType.Pet then
        skin = self.PetSkin
    elseif skinType == SkinType.FaBao then
        skin = self.FbSkin
    elseif skinType == SkinType.Soul then
        skin = self.SoulSkin
    end
    return skin
end

function FashionScene:SetEquipData(data)
    if data ~= nil then
        local skin = self:GetSkinByType(data.SkinType)
        if data.Part == FSkinPartCode.Body then
            self:SetBodyEquip(data.Id, skin, data.Slot, data.AnimList, data.Func)
        elseif data.Part == FSkinPartCode.Wing then
            self:SetWingEquip(data.Id, skin, data.Slot)
        elseif data.Part == FSkinPartCode.Mount then
            self:SetMountEquip(data.Id, skin, data.Slot)
        elseif data.Part == FSkinPartCode.GodWeaponHead then
            self:SetWeaponEquip(data.Id, skin, data.Slot)
        elseif data.Part == FSkinPartCode.XianjiaHuan then 
            self:SetXianJiaHuanEquip(data.Id, skin, data.Slot)
        end
    end
end

function FashionScene:UpdateBodyVfx()
    --int id = GetVfxId();
    --if (id ~= -1)
    --{
    --    if (self.Vfx ~= nil)
    --    {
    --        self.Vfx.OnCreateAndPlay(ModelTypeCode.BodyVFX, id, LayerUtils.UIStory);
    --    }
    --}
end

function FashionScene:SetBodyEquip(id, skin, slot, animList, func)
    if skin ~= nil then
        skin:SetEquip(FSkinPartCode.Body, id, animList, slot)
        skin:SetOnSkinPartChangedHandler(func)
    end
end

function FashionScene:SetWeaponEquip(id, skin, slot)
    if skin ~= nil then
        skin:SetEquip(FSkinPartCode.GodWeaponHead, id, nil, slot)
    end
end

function FashionScene:SetWingEquip(id, skin, slot)
    if skin ~= nil then
        skin:SetEquip(FSkinPartCode.Wing, id, nil, slot)
    end
end

function FashionScene:SetXianJiaHuanEquip(id, skin, slot)
    if skin ~= nil then
        skin:SetEquip(FSkinPartCode.XianjiaHuan, id, nil, slot)
    end
end

function FashionScene:SetMountEquip(id, skin, slot)
    if skin ~= nil then
        skin:SetEquip(FSkinPartCode.Mount, id, nil, slot)
    end
end

function FashionScene:SetSoulEquip(id, skin, slot)
    if skin ~= nil then
        skin:SetEquip(FSkinPartCode.Reserved_1, id, nil, slot)
    end
end

function FashionScene:GetCacheData()
    local ret = nil
    local keys = self.CacheDataDic:GetKeys()
    if keys == nil then
        return ret
    end
    for i = 1, #keys do
        local key = keys[i]
        local dataList = self.CacheDataDic[key]
        if dataList ~= nil then
            if #dataList == 0 then
                dataList = nil;
            end
            if dataList ~= nil and #dataList > 0 then
                ret = dataList[1]
                dataList:RemoveAt(1)
                break
            end
        end
    end
    return ret
end

function FashionScene:GetVfxId()
    local id = -1
    if #self.CacheVfxList > 0 then
        id = self.CacheVfxList[1]
        self.CacheVfxList:RemoveAt(1)
    end
    return id
end

return FashionScene
