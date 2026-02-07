------------------------------------------------
-- author:
-- Date: 2021-06-15
-- File: SwordGraveScene.lua
-- Module: SwordGraveScene
-- Description: UIScene
------------------------------------------------
-- Quote
local L_SceneBase = require "Logic.UIScene.Instance.UISceneBase"
local LuaFGameObjectModel = CS.Thousandto.Plugins.LuaType.LuaFGameObjectModel
local LuaFGameObjectVFX = CS.Thousandto.Plugins.LuaType.LuaFGameObjectVFX
local L_AnimationPlayer = CS.Thousandto.Core.Asset.AnimationPlayer
local AnimationPartType = CS.Thousandto.Core.Asset.AnimationPartType
local SlotUtils = CS.Thousandto.Core.Asset.SlotUtils

local SwordGraveScene = {
    CamaraAnim = nil,
    RemainTime = -1,
    HideTime = -1,
    PlaySwordAni = -1,
    SkinCamera = nil,
    SoulList = List:New()
}

function SwordGraveScene:New(type, id, manager)
    local _m = Utils.Extend(L_SceneBase:New(type, id, manager), self)
    _m:LoadScene()
    return _m
end

function SwordGraveScene:LoadScene()
    local sceneModel = LuaFGameObjectModel.Create(ModelTypeCode.UISceneModel, self.ModelId, false, true, false)
    sceneModel.OnLoadFinishedCallBack = Utils.Handler(self.LoadedCallBack, self, nil, true)
end

local L_SwordSoul = nil

function SwordGraveScene:OnLoadedCallBack(obj)
    if self.SceneObj == nil or self.SceneObj.RealTransform == nil then
        return
    end
    if self.SceneObj then
        local _rTrans = self.SceneObj.RealTransform
        local camaTrans = UIUtils.FindTrans(_rTrans, "Camera")
        if camaTrans then
            self.CamaraAnim = L_AnimationPlayer(UIUtils.RequireAnimListBaseScript(camaTrans))
            self.CamaraAnim:Play("SXJ_start")
            camaTrans.gameObject:SetActive(true)
        end
        camaTrans = UIUtils.FindTrans(_rTrans, "SkinCamera")
        self.SkinCamera = UIUtils.FindCamera(camaTrans)
        camaTrans.gameObject:SetActive(false)

        self.SoulList:Clear()
        for i = 1, 6 do
            local _childTrans =  UIUtils.FindTrans(_rTrans, tostring(i - 1))
            self.SoulList:Add(L_SwordSoul:New(_childTrans, i - 1))
            self:SetSwordAnim(i)
        end
    end
    self.RemainTime = -1
    self.HideTime = -1
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_FLYSWORDGRAVE_PLAYANI, self.PlayCameraAnim, self)
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_FLYSWORDGRAVE_PLAYHIDEANI, self.PlayCameraBackAnim, self)
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_UPDATE_FLYSWORDGRAVE, self.SowrdStateUpdate, self)
    IsLoadFinish = true
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_FLYSWORDGRAVESCENE_LOADFINISH)
end

function SwordGraveScene:OnDestory()
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_FLYSWORDGRAVE_PLAYANI, self.PlayCameraAnim, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_FLYSWORDGRAVE_PLAYHIDEANI, self.PlayCameraBackAnim, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_UPDATE_FLYSWORDGRAVE, self.SowrdStateUpdate, self)
    self.RemainTime = -1
    self.HideTime = -1
    self.PlaySwordAni = -1
    for i = 1, #self.SoulList do
        self.SoulList[i]:Destory()
    end
    self.SoulList:Clear()
end

function SwordGraveScene:OnUpdate(dt)
    if (self.SceneCamera and self.SceneCamera.gameObject.activeSelf) then
        self.CamaraAnim:Update(dt)
    end
    for i = 1, #self.SoulList do
        self.SoulList[i]:Update(dt)
    end
    if ( self.RemainTime >= 0 ) then
        self.RemainTime = self.RemainTime + dt
        if self.RemainTime >= 0.2 and self.ZhuanXiangIndex ~= nil then
            self.SoulList[self.ZhuanXiangIndex]:Play("zhuanxiang", false)
            self.SoulList[self.ZhuanXiangIndex].NormalAnim = "stand"
            self.ZhuanXiangIndex = nil
        end
        if (self.RemainTime >= 0.5) then
            self.RemainTime = -1
            GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_FLYSWORDGRAVE_PLAYANIEND)
        end
    end
    if (self.HideTime >= 0) then
        self.HideTime = self.HideTime + dt
        if (self.HideTime >= 1) then
            self.HideTime = -1
            if self.CamaraAnim then
                self.CamaraAnim:Play("SXJ_start")
            end
        end
    end
    if self.PlaySwordAni >= 0 then
        self.PlaySwordAni = self.PlaySwordAni + dt
        if (self.PlaySwordAni > 0.6) then
            self.PlaySwordAni = -1
            for i = 1, #self.SoulList do
                local _soul = self.SoulList[i]
                if _soul.SoulLevel == 0 then
                    local _soulDataId = (i - 1) * 6 + 1
                    local _state = GameCenter.FlySwordGraveSystem:GetSwordState(_soulDataId)
                    if _state == 0 then
                        -- _soul:Play("jinzhi", true)
                        if not GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.FlySwordGrave, _soulDataId) then
                            _soul:Play("jinzhi", true)
                        else
                            _soul:Play("doudong", true)
                        end
                    elseif _state == 1 then
                        _soul:Play("doudong", true)
                    elseif _state == 2 then
                        _soul:Play("stand", true)
                    end
                elseif _soul.SoulLevel == 1 then
                    _soul:Play("stand", true)
                else
                    _soul:Play("idle", true)
                end
            end
        end
    end
end
function SwordGraveScene:SetSwordAnim(index)
    local _soul = self.SoulList[index]
    local _isFind = false
    for i = 6, 2, -1 do
        local _state = GameCenter.FlySwordGraveSystem:GetSwordState((index - 1) * 6 + i)
        if _state == 2 then
            -- Awakening Sword Spirit
            _soul:SetLevel(i - 1)
            if i == 2 then
                _soul:Play("stand", true)
            else
                _soul:Play("idle", true)
            end
            _soul.StoneGo:SetActive(false)
            _soul.ActiveGo:SetActive(true)
            _isFind = true
            break
        end
    end
    if not _isFind then
        _soul:SetLevel(0)
        local _soulDataId = (index - 1) * 6 + 1
        local _state = GameCenter.FlySwordGraveSystem:GetSwordState(_soulDataId)
        if _state == 0 then
            if not GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.FlySwordGrave, _soulDataId) then
                _soul:Play("jinzhi", true)
            else
                _soul:Play("doudong", true)
            end
        elseif _state == 1 then
            _soul:Play("doudong", true)
        elseif _state == 2 then
            _soul:Play("stand", true)
        end
        _soul.FengYinGo:SetActive(_state == 0)
        _soul.StoneGo:SetActive(_state == 0)
        _soul.FuMoGo:SetActive(_state == 2)
        _soul.ActiveGo:SetActive(_state == 2)
    end
end

function SwordGraveScene:PlayCameraAnim(obj, sender)
    local _index = tonumber(obj)
    local type = _index % 6
    _index = type ~= 0 and math.floor(_index / 6) + 1 or math.floor(_index / 6)
    local _st = string.format("SXJ0%d_1", _index)
    if self.CamaraAnim then
        self.CamaraAnim:Play(_st, AnimationPartType.AllBody, WrapMode.Once)
    end
    self.ZhuanXiangIndex = nil
    local _soul = self.SoulList[_index]
    if _soul.SoulLevel ~= 0 then
        self.ZhuanXiangIndex = _index
    end
    self.RemainTime = 0
end
function SwordGraveScene:PlayCameraBackAnim(obj, sender)
    local _index = tonumber(obj)
    _index = _index % 6 ~= 0 and math.floor(_index / 6) + 1 or math.floor(_index / 6)
    local _st = string.format("SXJ0%d_2", _index)
    if self.CamaraAnim then
        self.CamaraAnim:Play(_st, AnimationPartType.AllBody, WrapMode.Once)
    end
    self.HideTime = 0
    self.PlaySwordAni = 0
end
function SwordGraveScene:SowrdStateUpdate(obj, sender)
    if obj then
        local id = tonumber(obj)
        if (id % 6 == 0) then
            id = id / 6
        else
            id = math.floor(id / 6) + 1
        end
        self:SetSwordAnim(id)
    end
end

L_SwordSoul = {
    -- Root node
    RootTrans = nil,
    -- Model parent node list, 3 states
    LevelTrans = nil,
    SwordAnimplayer = nil,
    -- Stone go
    StoneGo = nil,
    -- Activate go
    ActiveGo = nil,
    -- Special effects of sealing resources at level 0
    FengYinGo = nil,
    -- Enchantment effects of level 0 resources
    FuMoGo = nil,
    -- Unblocking effects of level 0 resources
    JiFengGo = nil,

    -- Sword Spirit Index
    SoulIndex = 0,
    -- Sword Spirit Level 0, 1, 2
    SoulLevel = nil,
    -- Model resources, FGameObjectModel object
    Model = nil,
    -- Model action player
    ModelAnimPlayer = nil,

    -- Cache playback actions
    CacheAnim = nil,
    CacheAnimLoop = nil,
    -- Default action
    NormalAnim = nil,
}

function L_SwordSoul:New(trans, index)
    local _m = Utils.DeepCopy(self)
    _m.SoulIndex = index
    _m.RootTrans = trans
    _m.LevelTrans = {}
    for i = 1, 6 do
        local _childTrans = UIUtils.FindTrans(trans, tostring(i - 1))
        _m.LevelTrans[i] = _childTrans
        if i == 1 then
            _m.SwordAnimplayer = L_AnimationPlayer(UIUtils.RequireAnimListBaseScript(_childTrans))
            -- seal
            local _tmpTrans =  UIUtils.FindTrans(_childTrans, "Bone001/fengyin")
            if _tmpTrans == nil then
                _tmpTrans = UIUtils.FindTrans(_childTrans, "Bone01/fengyin")
            end
            if _tmpTrans ~= nil then
                _m.FengYinGo = _tmpTrans.gameObject
            end
            -- Unblocking
            _tmpTrans =  UIUtils.FindTrans(_childTrans, "Bone001/jiefeng")
            if _tmpTrans == nil then
                _tmpTrans = UIUtils.FindTrans(_childTrans, "Bone01/jiefeng")
            end
            if _tmpTrans ~= nil then
                _m.JiFengGo = _tmpTrans.gameObject
            end
            -- Enchantment
            _tmpTrans =  UIUtils.FindTrans(_childTrans, "Bone001/fumo")
            if _tmpTrans == nil then
                _tmpTrans = UIUtils.FindTrans(_childTrans, "Bone01/fumo")
            end
            if _tmpTrans ~= nil then
                _m.FuMoGo = _tmpTrans.gameObject
            end
        end
    end
    _m.StoneGo = UIUtils.FindGo(trans, string.format("map044_wujian02_%d", index))
    _m.ActiveGo = UIUtils.FindGo(trans, "Active")
    _m.CacheAnim = nil
    _m.CacheAnimLoop = nil
    return _m
end

-- [Gosu] Fix hotupdate
local L_ResIds = {
    -- [0*1000 + 2] = 50411,
    -- [0*1000 + 3] = 50410,
    -- [0*1000 + 4] = 50420,
    -- [0*1000 + 5] = 50420,
    -- [1*1000 + 2] = 50341,
    -- [1*1000 + 3] = 50340,
    -- [1*1000 + 4] = 50370,
    -- [1*1000 + 5] = 50370,
    -- [2*1000 + 2] = 50311,
    -- [2*1000 + 3] = 50310,
    -- [2*1000 + 4] = 50320,
    -- [2*1000 + 5] = 50320,
    -- [3*1000 + 2] = 50401,
    -- [3*1000 + 3] = 50400,
    -- [3*1000 + 4] = 50390,
    -- [3*1000 + 5] = 50390,
    -- [4*1000 + 2] = 50381,
    -- [4*1000 + 3] = 50380,
    -- [4*1000 + 4] = 50360,
    -- [4*1000 + 5] = 50360,
    -- [5*1000 + 2] = 50441,
    -- [5*1000 + 3] = 50440,
    -- [5*1000 + 4] = 50430,
    -- [5*1000 + 5] = 50430,
}
local L_VfxIds = {
    [0*1000 + 5] = 201,
    [1*1000 + 5] = 202,
    [2*1000 + 5] = 203,
    [3*1000 + 5] = 204,
    [4*1000 + 5] = 205,
    [5*1000 + 5] = 206,
}
function L_SwordSoul:SetLevel(level)
    if level < 0 or level >= 6 then
        return
    end
    if self.SoulLevel == level then
        return
    end
    self.ModelIsLoad = false
    self.VFXIsLoad = false
    self:Destory()
    self.SoulLevel = level
    local _resId = L_ResIds[self.SoulIndex * 1000 + level]
    if _resId == nil then
        self.ModelAnimPlayer = self.SwordAnimplayer
        -- for i = 1, #self.LevelTrans do
        --     self.LevelTrans[i].gameObject:SetActive(i == level + 1)
        -- end
        -- [Gosu] Fix hotupdate
        if level == 0 then
            self.LevelTrans[1].gameObject:SetActive(true)
            self.LevelTrans[2].gameObject:SetActive(false)
        else
            self.LevelTrans[1].gameObject:SetActive(false)
            self.LevelTrans[2].gameObject:SetActive(true)
        end
    else
        local _model = LuaFGameObjectModel.Create(ModelTypeCode.Monster, _resId, false, true, false)
        _model.OnLoadFinishedCallBack = Utils.Handler(self.LoadedCallBack, self)
        _resId = L_VfxIds[self.SoulIndex * 1000 + level]
        if _resId then
            _model = LuaFGameObjectVFX.Create(ModelTypeCode.MonsterVFX, _resId, true, false)
            _model.OnLoadFinishedCallBack = Utils.Handler(self.VFXLoadedCallBack, self)
            _model:Play()
        end
    end
end

function L_SwordSoul:VFXLoadedCallBack(fGo)
    if fGo == nil then
        return
    end
    local _rTrans = fGo.RealTransform
    if _rTrans == nil then
        return
    end
    self.VFXIsLoad = true
    if self.ModelIsLoad then
        local _tr = SlotUtils.GetSlotTransform(self.Model.RealTransform, "slot_hit")
        if _tr then
            fGo.RootTransform.parent = _tr
            UnityUtils.ResetTransform(fGo.RootTransform)
        end
    end
    fGo:SetLayer(LayerUtils.UIStory)
    self.VfxModel = fGo
end

function L_SwordSoul:LoadedCallBack(fGo)
    if fGo == nil then
        return
    end
    local _rTrans = fGo.RealTransform
    if _rTrans == nil then
        return
    end
    self.ModelIsLoad = true
    for i = 1, #self.LevelTrans do
        if i == (self.SoulLevel + 1) then
            self.LevelTrans[i].gameObject:SetActive(true)
            fGo.RootTransform.parent = self.LevelTrans[i]
            UnityUtils.ResetTransform(fGo.RootTransform)
        else
            self.LevelTrans[i].gameObject:SetActive(false)
        end
    end
    fGo:SetLayer(LayerUtils.UIStory)
    self.Model = fGo
    self.ModelAnimPlayer = L_AnimationPlayer(UIUtils.RequireAnimListBaseScript(_rTrans))
    if self.CacheAnim ~= nil then
        self:Play(self.CacheAnim, self.CacheAnimLoop)
    end
    if self.VFXIsLoad then
        local _tr = SlotUtils.GetSlotTransform(_rTrans, "slot_hit")
        if _tr then
            self.VfxModel.RootTransform.parent = _tr
            UnityUtils.ResetTransform(self.VfxModel.RootTransform)
        end
    end
end

function L_SwordSoul:Play(anim, loop)
    if self.ModelAnimPlayer ~= nil then
        local _wrapMode = WrapMode.Once
        if loop then
            _wrapMode = WrapMode.Loop
        end
        self.ModelAnimPlayer:Play(anim, AnimationPartType.AllBody, _wrapMode)
        self.CacheAnim = nil
        self.CacheAnimLoop = nil
    else
        self.CacheAnim = anim
        self.CacheAnimLoop = loop
    end
end

function L_SwordSoul:Update(dt)
    if self.ModelAnimPlayer ~= nil then
        self.ModelAnimPlayer:Update(dt)
        if self.NormalAnim ~= nil and not self.ModelAnimPlayer.IsPlaying then
            self:Play(self.NormalAnim, true)
        end
    end
end

function L_SwordSoul:Destory()
    if self.VfxModel ~= nil then
        self.VfxModel:Destroy()
    end
    if self.Model ~= nil then
        self.Model:Destroy()
    end
    self.Model = nil
    self.ModelAnimPlayer = nil
    self.SoulLevel = nil
end

return SwordGraveScene