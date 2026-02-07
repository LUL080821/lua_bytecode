------------------------------------------------
-- Author: 
-- Date: 2019-10-17
-- File: UIStarVfxListComponent.lua
-- Module: UIStarVfxListComponent
-- Description: Star-up special effects component
------------------------------------------------
local L_VFXPlayState = CS.Thousandto.Core.Asset.VFXPlayState
local L_StarVfxCom = require("UI.Components.UIStarVfxComponent")
local UIStarVfxListComponent = {
    Trans = nil,
    Go = nil,
    VfxComList = List:New(),
    CurPlayTime = 0,
    CurDelayTime = 0,
    IsPlaying = false,
    HideWaitFrame = false,
}

-- Create a new object
function UIStarVfxListComponent:OnFirstShow(trans)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m.IsPlaying = false
    _m:FindAllComponents()
    LuaBehaviourManager:Add(_m.Trans, _m)
    return _m
end

 -- Find various controls on the UI
function UIStarVfxListComponent:FindAllComponents()
    self.VfxComList:Clear()
    for i = 0, self.Trans.childCount - 1 do
        local _com = L_StarVfxCom:OnFirstShow(self.Trans:GetChild(i))
        self.VfxComList:Add(_com)
    end
end

function UIStarVfxListComponent:Play(dataList, playTime, delayTime)
    self:ClearAllVfx()
    self.HideWaitFrame = true
    self.PlayTime = playTime
    self.CurDelayTime = delayTime or 0
    self.CurPlayIndex = 1
    self.CurPlayTime = 0
    self.IsPlaying = true

    for i = 1, #dataList do
        local _comp = nil
        if i > #self.VfxComList then
            _comp = L_StarVfxCom:OnFirstShow(UnityUtils.Clone(self.VfxComList[1].Go).transform)
            self.VfxComList:Add(_comp)
        else
            _comp = self.VfxComList[i]
        end
        if _comp then
            if dataList[i].StarGo then
                _comp.position = dataList[i].StarGo.transform.position
            else
                UnityUtils.SetPosition(_comp, 0, 0, 0)
            end
            _comp.StarGo = dataList[i].StarGo
            _comp.VfxID = dataList[i].VfxID
            if dataList[i].Layer ~= nil then
                _comp.Layer = dataList[i].Layer
            else
                _comp.Layer = LayerUtils.GetAresUILayer()
            end
            _comp:OnDestoryVfx()
        end
    end
end

-- Force all effects to play at the same time
function UIStarVfxListComponent:ForcePlayAll()
    for i = 1, #self.VfxComList do
        local _comp = self.VfxComList[i]
        if _comp ~= nil and _comp.StarGo ~= nil and not _comp.IsPlaying then
            _comp:PlayByList()
        end
    end
    self.IsPlaying = false
end

function UIStarVfxListComponent:ClearAllVfx()
    for i = 1, #self.VfxComList do
        local _comp = self.VfxComList[i]
        if _comp then
            _comp.StarGo = nil
            _comp.VfxID = nil
            _comp.Layer = nil
            _comp:OnDestoryVfx()
        end
    end
end

function UIStarVfxListComponent:CallBack(vfx)
end

function UIStarVfxListComponent:Update(dt)
    if not self.IsPlaying then
        return
    end
    if self.HideWaitFrame then
        self.HideWaitFrame = false
        for i = 1, #self.VfxComList do
            local _comp = self.VfxComList[i]
            if _comp.StarGo ~= nil then
                _comp.StarGo:SetActive(false)
            end
        end
    end

    if self.CurDelayTime > 0 then
        self.CurDelayTime = self.CurDelayTime - dt
        if self.CurDelayTime > 0 then
            return
        end
    end

    self.CurPlayTime = self.CurPlayTime - dt
    if self.CurPlayTime <= 0 then
        local _comCount = #self.VfxComList
        if _comCount >= self.CurPlayIndex and self.VfxComList[self.CurPlayIndex].StarGo ~= nil then
            self.VfxComList[self.CurPlayIndex]:PlayByList()
        else
            self.IsPlaying = false
        end
        self.CurPlayTime = self.PlayTime
        self.CurPlayIndex = self.CurPlayIndex + 1
        if _comCount < self.CurPlayIndex then
            self.IsPlaying = false
        end
    end
end
return UIStarVfxListComponent