------------------------------------------------
-- Author:
-- Date: 2019-07-1
-- File: AssetUtils.lua
-- Module: AssetUtils
-- Description: Lua version of AssetUtils on the C# side
------------------------------------------------

local CSLuaAssetUtils = CS.LuaAssetUtils

local L_GetPlayerBoneIndex = CSLuaAssetUtils.GetPlayerBoneIndex
local L_GetAssetFullPath = CSLuaAssetUtils.GetAssetFullPath
local L_GetAudioFilePath = CSLuaAssetUtils.GetAudioFilePath
local L_GetVideoFilePath = CSLuaAssetUtils.GetVideoFilePath
local L_GetAnimationPath = CSLuaAssetUtils.GetAnimationPath
local L_IsUIRes = CSLuaAssetUtils.IsUIRes
local L_GetModelTypeOutIndex = CSLuaAssetUtils.GetModelTypeOutIndex
local L_GetModelType = CSLuaAssetUtils.GetModelType
local L_GetModelAssetPath = CSLuaAssetUtils.GetModelAssetPath
local L_GetPlaceHolderModelAssetPath = CSLuaAssetUtils.GetPlaceHolderModelAssetPath
local L_GetImageAssetPath = CSLuaAssetUtils.GetImageAssetPath
local L_GetImageTypeCode = CSLuaAssetUtils.GetImageTypeCode
local L_IsVFXImagePath = CSLuaAssetUtils.IsVFXImagePath
local L_ProcessPath = CSLuaAssetUtils.ProcessPath
local L_GetPathWithOutExt = CSLuaAssetUtils.GetPathWithOutExt
local L_GetFileNameWithOutExt = CSLuaAssetUtils.GetFileNameWithOutExt
local L_MakeFileNameToLower = CSLuaAssetUtils.MakeFileNameToLower

local AssetUtils = {}

-- Get the player's bone information
function AssetUtils.GetPlayerBoneIndex(modelID)
    return L_GetPlayerBoneIndex(modelID)
end

-- Get the full path to the resource
function AssetUtils.GetAssetFullPath(relatePath, extension)
    return L_GetAssetFullPath(relatePath, extension)
end

-- Get the sound file path
function AssetUtils.GetAudioFilePath(name, code)
    return L_GetAudioFilePath(name, code)
end

-- Get the sound file path
function AssetUtils.GetVideoFilePath(name)
    return L_GetVideoFilePath(name)
end


-- Get the action path
function AssetUtils.GetAnimationPath(ownerTypr, boneIndex, animClipName)
    return L_GetAnimationPath(ownerTypr, boneIndex, animClipName)
end

-- Determine whether the current path of the file is UI
function AssetUtils.IsUIRes(filePath)
    return L_IsUIRes(filePath)
end

-- Get the model type, with out idx, there are 2 return values of the function, the first one is the return value of the function itself, and the second one is the value of the out
function AssetUtils.GetModelTypeOutIndex(modelName)
    return L_GetModelTypeOutIndex(modelName)
end

-- Get the model type without out idx
function AssetUtils.GetModelType(modelName)
    return L_GetModelType(modelName)
end

-- Get the model resource path, the third parameter isShow is not passed, default is false
function AssetUtils.GetModelAssetPath(type, code, isShow)
    return L_GetModelAssetPath(type, code, isShow)
end

-- Get the default resource path for the model
function AssetUtils.GetPlaceHolderModelAssetPath(type, param)
    return L_GetPlaceHolderModelAssetPath(type, param)
end

-- Get the resource path to the image
function AssetUtils.GetImageAssetPath(code, name)
    return L_GetImageAssetPath(code, name)
end

-- Get the image type code
function AssetUtils.GetImageTypeCode(texPath)
    return L_GetImageTypeCode(texPath)
end

-- Is it a path to the special effect image
function AssetUtils.IsVFXImagePath(texPath)
    return L_IsVFXImagePath(texPath)
end

-- Processing path splitter
function AssetUtils.ProcessPath(path)
    return L_ProcessPath(path)
end

-- Get Path without extension
function AssetUtils.GetPathWithOutExt(path)
    return L_GetPathWithOutExt(path)
end

-- Get FileName without extension
function AssetUtils.GetFileNameWithOutExt(path)
    return L_GetFileNameWithOutExt(path)
end

-- Operation to lowercase the file name of a certain path
function AssetUtils.MakeFileNameToLower(path)
    return L_MakeFileNameToLower(path)
end

return AssetUtils