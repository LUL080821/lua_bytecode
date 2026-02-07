------------------------------------------------
-- author:
-- Date: 2021-03-19
-- File: UIPlayerHead.lua
-- Module: UIPlayerHead
-- Description: Player avatar
local L_Vector4 = CS.UnityEngine.Vector4
local L_Shader = CS.UnityEngine.Shader
local L_Material = CS.UnityEngine.Material

local UIPlayerHead = {
    Trans = nil,                        -- Transform
    Frame = nil,
    Icon = nil,
    HeadPicId = nil,
    IsShowHeadPic = nil,
    PlayerID = nil,
    HeadMat = nil,
    HeadTexPath = nil,
    TexLoadHander = nil,
}

local L_HeadTable = {}
local L_ShaderInst = nil

function GetMat()
    if L_ShaderInst == nil then
        L_ShaderInst = L_Shader.Find("Unlit/Transparent Colored (CircleClip)")
    end
    return L_Material(L_ShaderInst)
end

function UIPlayerHead:New(trans)
    local _cacheTable = L_HeadTable[trans]
    if _cacheTable ~= nil then
        return _cacheTable
    end
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.TexLoadHander = Utils.Handler(_m.OnHeadTexLoadFinish, _m)
    _m:FindAllComponents()
    local _texTrans = UIUtils.FindTrans(trans, "HeadTex")
    if _texTrans ~= nil then
        local _tex = UIUtils.FindTex(_texTrans)
        if _tex ~= nil then
            -- Empty the material ball to prevent the wrong material ball
            _tex.material = nil
        end
    end
    _m.IsVisible = trans.gameObject.activeInHierarchy
    if _m.IsVisible then
        _m:OnEnable()
    end
    L_HeadTable[trans] = _m
    LuaBehaviourManager:Add(trans, _m)
    return _m
end

 -- Find Components
function UIPlayerHead:FindAllComponents()
    local _myTrans = self.Trans
    self.Frame = UIUtils.RequireUIIconBase(UIUtils.FindTrans(_myTrans, "Frame"))
    self.Icon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(_myTrans, "Icon"))
    self.Frame.IconSprite.depth = self.Icon.IconSprite.depth + 1
end

local L_SetIcon = function(icon, iconData, occ)
    local _iconId = 0
    if iconData ~= nil then
        _iconId = iconData:GetModelId(occ)
        if _iconId ~= 0 then
            icon:UpdateIcon(_iconId)
        end
    end
end

function UIPlayerHead:UpdateHead(id, occ)
    local _iconData = GameCenter.NewFashionSystem:GetTotalData(id)
    if _iconData == nil then
        _iconData = GameCenter.NewFashionSystem:GetTotalData(1100000001)
    end
    L_SetIcon(self.Icon, _iconData, occ)
end

function UIPlayerHead:UpdateFrame(id, occ)
    local _frameData = GameCenter.NewFashionSystem:GetTotalData(id)
    if _frameData == nil then
        _frameData = GameCenter.NewFashionSystem:GetTotalData(1200000001)
    end
    L_SetIcon(self.Frame, _frameData, occ)
end

function UIPlayerHead:SetHead(iconFashionId, frameFashionId, occ, playerId, headPicId, isShowHeadPic)
    local _frameData = GameCenter.NewFashionSystem:GetTotalData(frameFashionId)
    if _frameData == nil then
        _frameData = GameCenter.NewFashionSystem:GetTotalData(1200000001)
    end
    local _iconData = GameCenter.NewFashionSystem:GetTotalData(iconFashionId)
    if _iconData == nil then
        _iconData = GameCenter.NewFashionSystem:GetTotalData(1100000001)
    end
    L_SetIcon(self.Frame, _frameData, occ)
    L_SetIcon(self.Icon, _iconData, occ)
    self:SetHeadPicInfo(playerId, headPicId, isShowHeadPic)
end

function UIPlayerHead:SetHeadByMsg(playerId, occ, msg)
    if msg == nil then
        msg = {}
    end
    local _frameData = GameCenter.NewFashionSystem:GetTotalData(msg.fashionFrame)
    if _frameData == nil then
        _frameData = GameCenter.NewFashionSystem:GetTotalData(1200000001)
    end
    local _iconData = GameCenter.NewFashionSystem:GetTotalData(msg.fashionHead)
    if _iconData == nil then
        _iconData = GameCenter.NewFashionSystem:GetTotalData(1100000001)
    end
    L_SetIcon(self.Frame, _frameData, occ)
    L_SetIcon(self.Icon, _iconData, occ)
    self:SetHeadPicInfo(playerId, msg.customHeadPath, msg.useCustomHead)
end

function UIPlayerHead:SetLocalPlayer()
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp ~= nil then
        local _playerOcc = _lp.IntOcc
        local _frameData = GameCenter.NewFashionSystem:GetPlayerHeadFrameData()
        if _frameData == nil then
            _frameData = GameCenter.NewFashionSystem:GetTotalData(1200000001)
        end
        local _iconData = GameCenter.NewFashionSystem:GetPlayerHeadData()
        if _iconData == nil then
            _iconData = GameCenter.NewFashionSystem:GetTotalData(1100000001)
        end
        L_SetIcon(self.Frame, _frameData, _playerOcc)
        L_SetIcon(self.Icon, _iconData, _playerOcc)
        self:SetHeadPicInfo(_lp.ID, _lp.TexHeadPicID, _lp.IsShowHeadPic)
    end
end

function UIPlayerHead:OnEnable()
    self.IsVisible = true
    self:RefreshTexHead()
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_DOWNLOAD_HEAD_END, self.OnDownloadFinish, self)
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_UPLOAD_HEAD_END, self.OnUploadFinish, self)
    GameCenter.RegFixEventHandle(LogicLuaEventDefine.EID_EVENT_LP_CHANGE_CUSTOMHEAD, self.OnLPCustomHeadChanged, self)
end

function UIPlayerHead:OnDisable()
    self:SetHeadTexPath(nil)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_DOWNLOAD_HEAD_END, self.OnDownloadFinish, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_UPLOAD_HEAD_END, self.OnUploadFinish, self)
    GameCenter.UnRegFixEventHandle(LogicLuaEventDefine.EID_EVENT_LP_CHANGE_CUSTOMHEAD, self.OnLPCustomHeadChanged, self)
    self.IsVisible = false
end

function UIPlayerHead:OnDestroy()
    if self.IsVisible then
        self:OnDisable()
    end
    if self.HeadTex ~= nil then
        local _mat = self.HeadTex.material
        if _mat ~= nil then
            GameObject.Destroy(_mat)
        end
    end
    L_HeadTable[self.Trans] = nil
end

function UIPlayerHead:SetHeadPicInfo(playerId, picId, showPic)
    self.PlayerID = playerId
    self.HeadPicId = picId
    self.IsShowHeadPic = showPic
    if self.IsVisible then
        self:RefreshTexHead()
    end
end

function UIPlayerHead:RefreshTexHead()
    local _headPicPath = nil
    -- if not self.IsShowHeadPic or self.PlayerID == nil or self.HeadPicId == nil or string.len(self.HeadPicId) <= 0 then
    --     _headPicPath = nil
    -- else
    --     local _state, _path = GameCenter.TexHttpSyncSystem:ReqGetHeadPic(self.PlayerID, self.HeadPicId, false)
    --     if _state == TexHttpSyncState.AlredayDownload then
    --         _headPicPath = _path
    --     else
    --         _headPicPath = nil
    --     end
    -- end
    if _headPicPath ~= nil then
        self.Icon.GameObjectInst:SetActive(false)
        if self.HeadTexGo ~= nil then
            self.HeadTexGo:SetActive(true)
        end
        self:SetHeadTexPath(_headPicPath)
    else
        self.Icon.GameObjectInst:SetActive(true)
        if self.HeadTexGo ~= nil then
            self.HeadTexGo:SetActive(false)
        end
        self:SetHeadTexPath(nil)
    end
end

function UIPlayerHead:SetHeadTexPath(texPath)
    if texPath == self.HeadTexPath then
        return
    end
    if self.HeadTexPath ~= nil then
        -- Release old picture resources
        GameCenter.TextureManager:UnLoadTexture(self.HeadTexPath, self.TexLoadHander)
    end
    if self.HeadTex ~= nil and self.HeadTex.material ~= nil then
        local _mat = self.HeadTex.material
        self.HeadTex.material = nil
        _mat:SetTexture("_MainTex", nil)
        self.HeadTex.material = _mat
    end
    self.HeadTexPath = texPath
    if self.HeadTexPath ~= nil then
        -- Start loading
        GameCenter.TextureManager:LoadTexture(self.HeadTexPath, self.TexLoadHander, true, 128, 128, ".jpg", true)
    end
end

function UIPlayerHead:OnDownloadFinish(requet, sender)
    if requet.ResultCode == 0 and requet.BigOrSmal == false and requet.PicId == self.HeadPicId then
        self:RefreshTexHead()
    end
end

function UIPlayerHead:OnUploadFinish(requet, sender)
    if requet.ResultCode == 0 and requet.UpLoadType == TexHttpSyncType.HeadPic and self.PlayerID == GameCenter.GameSceneSystem:GetLocalPlayerID() then
        -- The protagonist uploaded the avatar again
        self:SetLocalPlayer()
    end
end

-- The protagonist has changed his custom avatar
function UIPlayerHead:OnLPCustomHeadChanged(obj, sender)
    if self.PlayerID == GameCenter.GameSceneSystem:GetLocalPlayerID() then
        self:SetLocalPlayer()
    end
end

function UIPlayerHead:OnHeadTexLoadFinish(texInfo)
    if self.HeadTexGo == nil then
        local _trans = UIUtils.FindTrans(self.Trans, "HeadTex")
        if _trans == nil then
            local _go = GameObject()
            _trans = _go.transform
            _trans.parent = self.Trans
            _trans.name = "HeadTex"
            local _iconTrans = self.Icon.TransformInst
            local _frameTrans = self.Frame.TransformInst
            _trans.localScale = _iconTrans.localScale
            _trans.localPosition = _frameTrans.localPosition
            _trans.localEulerAngles = _iconTrans.localEulerAngles
        end
        self.HeadTexGo = _trans.gameObject
    end
    self.HeadTexGo:SetActive(true)

    if self.HeadTex == nil then
        self.HeadTex = UIUtils.RequireTex(self.HeadTexGo.transform)
        local _iconSpr = self.Icon.IconSprite
        local _frameSpr = self.Frame.IconSprite
        self.HeadTex.width = _frameSpr.width - 31
        self.HeadTex.height = _frameSpr.height - 31
        self.HeadTex.depth = _iconSpr.depth
    end
    local _mat = self.HeadTex.material
    if _mat == nil then
        _mat = GetMat()
    end
    self.HeadTex.material = nil
    _mat:SetTexture("_MainTex", texInfo.Texture)
    _mat:SetVector("_Circle", L_Vector4(0.5, 0.5, 0.5, 0.5))
    _mat:SetFloat("_Reverse", 0)
    self.HeadTex.material = _mat
end

return UIPlayerHead