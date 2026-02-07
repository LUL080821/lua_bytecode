------------------------------------------------
-- Author:
-- Date: 2019-07-1
-- File: LayerUtils.lua
-- Module: LayerUtils
-- Description: Lua version of LayerUtils on the C# side
------------------------------------------------

local CSLayerUtils = CS.Thousandto.Core.Asset.LayerUtils;

local LayerUtils = {};

setmetatable(LayerUtils, { __index = function(t, k)
    local _layer = CSLayerUtils[k];
    if _layer then
        rawset(t, k, _layer);
    end
    return _layer;
end})

function LayerUtils.GetDefaultLayer()
    return LayerUtils.Default
end

function LayerUtils.GetTransparentFXLayer()
    return LayerUtils.TransparentFX
end

function LayerUtils.GetUILauncherLayer()
    return LayerUtils.UILauncher
end

function LayerUtils.GetUITopLauncherLayer()
    return LayerUtils.UITopLauncher
end

function LayerUtils.GetLocalPlayerLayer()
    return LayerUtils.LocalPlayer
end

function LayerUtils.GetRemotePlayerLayer()
    return LayerUtils.RemotePlayer
end

function LayerUtils.GetMonsterLayer()
    return LayerUtils.Monster
end

function LayerUtils.GetSummonObjLayer()
    return LayerUtils.SummonObj
end

function LayerUtils.GetSceneVFXLayer()
    return LayerUtils.SceneVFX
end

function LayerUtils.GetAresUILayer()
    return LayerUtils.AresUI
end

function LayerUtils.GetUITopLayer()
    return LayerUtils.UITop
end

function LayerUtils.GetGuideUILayer()
    return LayerUtils.GuideUI
end

function LayerUtils.GetUIStoryLayer()
    return LayerUtils.UIStory
end

function LayerUtils.GetUITopStoryLayer()
    return LayerUtils.UITopStory
end

function LayerUtils.GetUIARLayer()
    return LayerUtils.AR
end

function LayerUtils.GetUIStoryObjectLayer()
    return LayerUtils.UIStoryObject
end

function LayerUtils.GetTerrainLayer()
    return LayerUtils.Terrain
end

function LayerUtils.GetTerrainMeshLayer()
    return LayerUtils.TerrainMesh
end

function LayerUtils.GetTerrainObjLayer()
    return LayerUtils.TerrainObj
end

function LayerUtils.GetSceneChange1Layer()
    return LayerUtils.SceneChange1
end

function LayerUtils.GetSceneChange2Layer()
    return LayerUtils.SceneChange2
end

function LayerUtils.GetShadowMeshLayer()
    return LayerUtils.ShadowMesh
end

function LayerUtils.GetTriggerLayer()
    return LayerUtils.Trigger
end

function LayerUtils.GetSceneObject_MaskLayer()
    return LayerUtils.SceneObject_Mask
end

function LayerUtils.GetUI_MaskLayer()
    return LayerUtils.UI_Mask
end

function LayerUtils.GetNoneUI_MaskLayer()
    return LayerUtils.NoneUI_Mask
end

function LayerUtils.GetTerrain_MaskLayer()
    return LayerUtils.Terrain_Mask
end

function LayerUtils.GetTerrainPath_MaskLayer()
    return LayerUtils.TerrainPath_Mask
end

function LayerUtils.ContainLayer(layer, mask)
    return CSLayerUtils.ContainLayer(layer, mask)
end

function LayerUtils.LayerToMask(layer)
    return CSLayerUtils.LayerToMask(layer)
end

return LayerUtils