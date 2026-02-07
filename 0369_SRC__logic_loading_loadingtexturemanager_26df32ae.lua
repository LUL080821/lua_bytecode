------------------------------------------------
-- Author: 
-- Date: 2020-02-22
-- File: LoadingTextureManager.lua
-- Module: LoadingTextureManager
-- Description: The manager for loading the Loading texture
------------------------------------------------
local LoadingTextureInfo = require("Logic/Loading/LoadingTextureInfo");
local PathUtils = CS.UnityEngine.Gonbest.MagicCube.PathUtils
local CSLuaUnityUtility = CS.LuaUnityUtility;

local LoadingTextureManager = {
    
    -- Current texture name
    CurrTextureName = nil,
    -- List of all optional background image names
    BgNameList = nil,
    -- Current background texture
    LoadingTexture = nil,
    -- Default texture
    DefaultTexture = nil,
    -- Specially formulated textures
    SpecTexture = nil,
}

-- Define the loading graph index corresponding to the service opening time
local L_CN_OPEN_DAY_TEXTURE_IDX_ARRAY = {
    { SDay=1, EDay=3, Indexes={11,12,13,14,15} },
    { SDay=4, EDay=6, Indexes={16,17,18,19,20} },
}

-- initialization
function LoadingTextureManager:Initialize()
   self.BgNameList = List:New();
   self.LoadingTexture = LoadingTextureInfo:New(true);
   self.DefaultTexture = LoadingTextureInfo:New(false);
   self.SpecTexture = LoadingTextureInfo:New(true);
   
   -- It is too early to block here, Initialize(), because the DefaultTexture loads before the Launcher form is closed, and the Launcher form will uninstall DefaultTexture when it is closed. This results in the texture no longer exists when it is used.
   --LoadDefaultTexture();
end

function LoadingTextureManager:UnInitialize()
    if self.LoadingTexture then
        self.LoadingTexture:Free();
        self.LoadingTexture = nil;
    end   

    if self.DefaultTexture then
        self.DefaultTexture:Free();
        self.DefaultTexture = nil;
    end
    if self.SpecTexture then
        self.SpecTexture:Free();
        self.SpecTexture = nil;
    end
    self.BgNameList = nil;
end


-- Loading background image
function LoadingTextureManager:GetLoadingTexture()
    if self.SpecTexture and self.SpecTexture.IsValid then
        return self.SpecTexture;            
    end

    if self.LoadingTexture and self.LoadingTexture.IsValid then
        return self.LoadingTexture;            
    end
    return self:LoadDefaultTexture();        
end

-- Loading special textures
function LoadingTextureManager:LoadSpecTexture(index)    
    local _specTexName = self:GetTextrueName(index);
    if not self.SpecTexture.IsValid then
        self.SpecTexture:Load(_specTexName, nil);
    end    
end

-- Uninstall special textures
function LoadingTextureManager:UnLoadSpecTexture()
    if (self.SpecTexture.IsValid) then
        self.SpecTexture:UnLoad();
    end
end

-- Load the default texture
function LoadingTextureManager:LoadDefaultTexture()
    if not self.DefaultTexture.IsValid then
        self.DefaultTexture.IsFromStreamFile = true;
        self.DefaultTexture.FileExt = ".jpg";
        self.DefaultTexture:Load("Default/Texture/UI/tex_launcher", nil);
    end
    return self.DefaultTexture;
end

-- Refresh new Texture
function LoadingTextureManager:RefreshNewTexture()
    self:UnLoadSpecTexture();
    self:UnloadDefaultTexture();
    self:RefreshLoadingTexture();
end


-- Refresh the loaded background image
function LoadingTextureManager:RefreshLoadingTexture()
    local _newTexName = self:getRandTexName();    
    if (self.CurrTextureName ~= _newTexName) then
        self.CurrTextureName = _newTexName;
        self.LoadingTexture:Load(self.CurrTextureName, nil);
    end
end



-- Uninstall the default texture
function LoadingTextureManager:UnloadDefaultTexture()
    if (self.DefaultTexture.IsValid) then
        self.DefaultTexture:UnLoad();
    end
end


-- Get random texture names
function LoadingTextureManager:getRandTexName()
    
    if (self.BgNameList:Count() == 0) then
        self:InitImageNameList();
    end

    local _randomIndex = math.random(1, self.BgNameList:Count());    
    --Debug.LogError("getRandTexName:" .. tostring(_randomIndex) .."::".. tostring(self.BgNameList:Count()));
    return self.BgNameList[_randomIndex];
end


-- Initialize the image name list
function LoadingTextureManager:InitImageNameList()

    self.BgNameList:Clear();
    local _defaultBack = "tex_logininback";
    _defaultBack = self:FixTextureDir(_defaultBack);
    self.BgNameList:Add(_defaultBack);
    -- Maximum 10 backgrounds
    for i = 1,10 do
        local _texName = self:GetTextrueName(i)
        if _texName then
            --Debug.LogError("BgNameList:Add:" .. _texName);
            self.BgNameList:Add(_texName);        
        end       
    end
    -- Add background image according to the service opening time
    local _openDay = Time.GetOpenSeverDay();    
    for _, value in ipairs(L_CN_OPEN_DAY_TEXTURE_IDX_ARRAY) do
        if (value.SDay <= _openDay and value.EDay >=_openDay) then
            for _, texIdx in ipairs(value.Indexes) do
                local _texName = self:GetTextrueName(texIdx)
                if _texName then
                    --Debug.LogError("BgNameList:Add:" .. _texName);
                    self.BgNameList:Add(_texName);        
                end    
            end    
            break;
        end
    end
end

-- Get the texture name
function LoadingTextureManager:GetTextrueName(index)

    local _texName = nil;
    local _texPath = nil;
    local _relativePath = nil;    
    local _texPathLeft = nil;
    local _texPathRight = nil;
    local _relativePathLeft = nil;
    local _relativePathRight = nil;
    local _texName_main = string.format("tex_logininback_%d",index); 
    local _texName_l = string.format("tex_logininback_%d_l",index); 
    local _texName_r = string.format("tex_logininback_%d_r",index); 

    if (PathUtils.IsStreaming())then
        _texName =_texName_main ..".unity3d";
    else        
        _texName =_texName_main ..".jpg";
    end

    _texName = self:FixTextureDir(_texName);
    -- When reading paths in android, use them
    _relativePath = "Assets/GameAssets/Resources/" .. AssetUtils.GetImageAssetPath(ImageTypeCode.UI, _texName);
    _texPath = PathUtils.GetResourcePath(AssetUtils.GetImageAssetPath(ImageTypeCode.UI, _texName));

    _texPathLeft = Utils.ReplaceString(_texPath,_texName_main, _texName_l);
    _texPathRight = Utils.ReplaceString(_texPath,_texName_main, _texName_r);
    _relativePathLeft = Utils.ReplaceString(_relativePath,_texName_main, _texName_l);
    _relativePathRight = Utils.ReplaceString(_relativePath,_texName_main, _texName_r);      

    if ( (File.Exists(_texPathLeft) and File.Exists(_texPathRight))
        or
        (GameCenter.UpdateSystem:IsExistInApp(_relativePathLeft) and GameCenter.UpdateSystem:IsExistInApp(_relativePathRight))
        or 
        (File.Exists(_relativePathLeft) and File.Exists(_relativePathRight)))
    then        
        return Utils.ReplaceString(Utils.ReplaceString(_texName,".jpg", ""),".unity3d", "");        
    else
        -- Debug.LogError("Text not found:" .. _relativePathLeft);
        return nil;
    end
end

-- Correct texture directory
function LoadingTextureManager:FixTextureDir(path)
    if CSLuaUnityUtility.UNITY_EDITOR() and (not CSLuaUnityUtility.UNITY_LAUNCHER()) then       
        if CSLuaUnityUtility.UNITY_ANDROID() then
            return "Android/" .. path;        
        elseif CSLuaUnityUtility.UNITY_IOS() then        
            return "IOS/".. path;
        else
            -- Read the texture below Android by default
            return "Android/" .. path;        
        end
    end
    return path;
end

return LoadingTextureManager
