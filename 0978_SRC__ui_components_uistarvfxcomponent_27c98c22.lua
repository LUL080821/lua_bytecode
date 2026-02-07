------------------------------------------------
-- Author: 
-- Date: 2019-10-17
-- File: UIStarVfxComponent.lua
-- Module: UIStarVfxComponent
-- Description: Star-up special effects component
------------------------------------------------
local L_VFXPlayState = CS.Thousandto.Core.Asset.VFXPlayState
local UIStarVfxComponent = {
    Trans = nil,
    Go = nil,
    VfxSkin = nil,
    IsPlaying = false,
}

-- Create a new object
function UIStarVfxComponent:OnFirstShow(trans)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m:FindAllComponents()
    LuaBehaviourManager:Add(_m.Trans, _m)
    return _m
end

 -- Find various controls on the UI
function UIStarVfxComponent:FindAllComponents()
    self.VfxSkin = UIUtils.RequireUIVfxSkinCompoent(self.Trans)
end

function UIStarVfxComponent:Play(vfxid, starGo)
    self:OnDestory()
    self.StarGo = starGo
    if self.StarGo then
        self.position = starGo.transform.position
    else
        self.position = Vector3.zero
    end
    self.VfxSkin:OnCreateVfx(ModelTypeCode.UIVFX, vfxid)
    local _layer = LayerUtils.GetAresUILayer()
    if self.Layer ~= nil then
        _layer = self.Layer
    end
    self.VfxSkin:OnSetInfo(_layer, self.position, Utils.Handler(self.CallBack, self))
    self.VfxSkin:OnPlay()
    self.IsPlaying = true
end

function UIStarVfxComponent:PlayByList()
    self:OnDestoryVfx()
    if not self.VfxID or not self.position then
        return
    end
    self.VfxSkin:OnCreateVfx(ModelTypeCode.UIVFX, self.VfxID)
    local _layer = LayerUtils.GetAresUILayer()
    if self.Layer ~= nil then
        _layer = self.Layer
    end
    self.VfxSkin:OnSetInfo(_layer, self.position, Utils.Handler(self.CallBack, self))
    self.VfxSkin:OnPlay()
    self.IsPlaying = true
end

function UIStarVfxComponent:CallBack(vfx)
end

function UIStarVfxComponent:Update(dt)
    if not self.StarGo then
        return
    end
    if self.VfxSkin and self.VfxSkin.IsPlaying then
        self.StarGo:SetActive(true)
        self.StarGo = nil
        self.IsPlaying = false
    end
end

-- End early
function UIStarVfxComponent:OnDestory()
    self:OnDestoryVfx()
    if self.StarGo then
        self.StarGo:SetActive(true)
        self.StarGo = nil
    end
end

function UIStarVfxComponent:OnDestoryVfx()
    if self.VfxSkin then
        self.VfxSkin:OnDestory()
    end
    self.IsPlaying = false
end
return UIStarVfxComponent