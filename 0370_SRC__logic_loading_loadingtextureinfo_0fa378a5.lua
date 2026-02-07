
------------------------------------------------
-- Author: 
-- Date: 2020-02-20
-- File: LoadingTextureInfo.lua
-- Module: LoadingTextureInfo
-- Description: Loading double texture class for loading graph processing
-- Note: In the definition field in the class, the value cannot be assigned to nil, and it needs to be assigned to a value.
------------------------------------------------
-- Quote
local L_ParentCSType = CS.Thousandto.Plugins.LuaType.LuaUISutureTextureData;

-- In the definition field in the class, the value cannot be assigned to nil, and it needs to be assigned to a value. The default can be 0
local LoadingTextureInfo = {
    -- CS parent class object
    _SuperObj_ = 0,
    -- Callback for the image loading on the left
    OnLoadLeftFinishHander = 0,
    -- Callback for the image loading on the right
    OnLoadRightFinishHander = 0,
}

-- #region //Fixed template for class inheritance

-- Constructor
function LoadingTextureInfo:New(...)
    local _m = Utils.DeepCopy(self)
    _m._SuperObj_ = L_ParentCSType.Create(...);
    _m:_InitBindOverride_();
    _m:_InitContent_();    
    Utils.BuildInheritRel(_m);
    return _m
end

-- Methods to bind Override
function LoadingTextureInfo:_InitBindOverride_()
    -- Redefinition of overloaded functions
    self._SuperObj_.LoadDelegate = Utils.Handler(self.OnCustomLoadImp, self, nil, true);
    self._SuperObj_.UnLoadDelegate = Utils.Handler(self.OnCustomUnLoadImp, self, nil, true);
end

-- uninstall
function LoadingTextureInfo:Free()
    self._SuperObj_.LoadDelegate = nil;
    self._SuperObj_.UnLoadDelegate = nil;
    L_ParentCSType.Destroy(self._SuperObj_);
    Utils.Destory(self);
end

-- initialization
function LoadingTextureInfo:_InitContent_()
    -- Define temporary variables, user callbacks
    self.OnLoadLeftFinishHander = Utils.Handler(self.OnLoadLeftTextureFinish, self, nil, false);
    self.OnLoadRightFinishHander = Utils.Handler(self.OnLoadRightTextureFinish, self, nil, false);
end
--#endregion

-- Custom loading for overloading
function LoadingTextureInfo:OnCustomLoadImp()
    GameCenter.TextureManager:LoadTexture(AssetUtils.GetImageAssetPath(ImageTypeCode.UI, self.LeftName), self.OnLoadLeftFinishHander);
    GameCenter.TextureManager:LoadTexture(AssetUtils.GetImageAssetPath(ImageTypeCode.UI, self.RightName), self.OnLoadRightFinishHander);
end

-- Custom unloading for overloading
function LoadingTextureInfo:OnCustomUnLoadImp()
    GameCenter.TextureManager:UnLoadTexture(AssetUtils.GetImageAssetPath(ImageTypeCode.UI, self.LeftName), self.OnLoadLeftFinishHander);
    GameCenter.TextureManager:UnLoadTexture(AssetUtils.GetImageAssetPath(ImageTypeCode.UI, self.RightName), self.OnLoadRightFinishHander);
end

-- Callbacks loaded in texture
function LoadingTextureInfo:OnLoadLeftTextureFinish(tex)   
    if (tex and tex.Texture ) then
        self.Left = tex.Texture;
        self:CheckLoadFinished();
    end
end


-- Callbacks loaded in texture
function LoadingTextureInfo:OnLoadRightTextureFinish(tex)   
    if (tex and tex.Texture ) then
        self.Right = tex.Texture;
        self:CheckLoadFinished();
    end
end

return LoadingTextureInfo