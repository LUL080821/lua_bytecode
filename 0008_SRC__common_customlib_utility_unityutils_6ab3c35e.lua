------------------------------------------------
-- Author: 
-- Date: 2019-04-11
-- File: UnityUtils.lua
-- Module: UnityUtils
-- Description: Manipulate some public functions of Unity objects
------------------------------------------------
local CSUIUtility = CS.Thousandto.Plugins.Common.UIUtility
local CSUnityUtils = CS.Thousandto.Core.Base.UnityUtils;
local CSLuaUnityUtility = CS.LuaUnityUtility;
local L_SetParent = CSLuaUnityUtility.SetParent;
local L_SetParentAndReset = CSLuaUnityUtility.SetParentAndReset;
local L_ResetTransform = CSLuaUnityUtility.ResetTransform;
local L_Clone = CSUIUtility.Clone;
local L_GetObjct2Int = CSLuaUnityUtility.GetObjct2Int;
local L_GetObjct2Byte = CSLuaUnityUtility.GetObjct2Byte;
local L_RequireComponent = CSLuaUnityUtility.RequireComponent;
local L_RequireLuaBehaviour = CSLuaUnityUtility.RequireLuaBehaviour;
local L_GetComponentInChildren = CSLuaUnityUtility.GetComponentInChildren;
local L_GetComponentsInChildren = CSLuaUnityUtility.GetComponentsInChildren;

local L_SetLocalPosition = CSLuaUnityUtility.SetLocalPosition;
local L_SetLocalPositionX = CSLuaUnityUtility.SetLocalPositionX;
local L_SetLocalPositionY = CSLuaUnityUtility.SetLocalPositionY;
local L_SetLocalPositionZ = CSLuaUnityUtility.SetLocalPositionZ;
local L_SetLocalRotation = CSLuaUnityUtility.SetLocalRotation;
local L_SetLocalEulerAngles = CSLuaUnityUtility.SetLocalEulerAngles;
local L_SetLocalScale = CSLuaUnityUtility.SetLocalScale;
local L_SetPosition = CSLuaUnityUtility.SetPosition;
local L_SetRotation = CSLuaUnityUtility.SetRotation;
local L_SetAulerAngles = CSLuaUnityUtility.SetAulerAngles;
local L_SetForward = CSLuaUnityUtility.SetForward;
local L_SetUp = CSLuaUnityUtility.SetUp;
local L_SetRight = CSLuaUnityUtility.SetRight;
local L_SetTweenPositionFrom = CSLuaUnityUtility.SetTweenPositionFrom;
local L_SetTweenPositionTo = CSLuaUnityUtility.SetTweenPositionTo;
local L_SetLayer = CSLuaUnityUtility.SetLayer;
local L_WorldPosToHudPos = CSLuaUnityUtility.WorldPosToHudPos;
local L_IsUseUsePCMOdel = CSLuaUnityUtility.IsUseUsePCMOdel;
local L_UNITY_WINDOWS = CSLuaUnityUtility.UNITY_WINDOWS;

local UnityUtils = {}

local L_IsUseKeyCode = nil;

-- Set the parent object
function UnityUtils.SetParent(child, parent)
    L_SetParent(child, parent);
end

-- Set the parent object and reset Transform
function UnityUtils.SetParentAndReset(child, parent)
    L_SetParentAndReset(child, parent);
end

-- Reset Transform's local position, size and angle to 0
function UnityUtils.ResetTransform(trans)
    L_ResetTransform(trans)
end

-- Clone gameObject [,parent, isReset]
function UnityUtils.Clone(gameObject, parent, isReset)
    if parent then
        return L_Clone(gameObject, parent, not (not isReset))
    else
        return L_Clone(gameObject, not (not isReset))
    end
end

-- Whether to use the macro USE_NEW_CFG
function UnityUtils.USE_NEW_CFG()
    return CSLuaUnityUtility.USE_NEW_CFG()
end

-- C# get type
function UnityUtils.GetType(obj)
    return CSLuaUnityUtility.GetType(obj)
end

-- This function can be used to convert object types to int types.
function UnityUtils.GetObjct2Int(obj)
    if type(obj) == "number" then
        return obj
    end
    return L_GetObjct2Int(obj)
end

-- This function can be used to convert object types to byte types.
function UnityUtils.GetObjct2Byte(obj)
    return L_GetObjct2Byte(obj)
end

-- Add components according to type name (strType: space name + class name) -- Temporary blocking
-- function UnityUtils.RequireComponent(trans,strType)
--     return L_RequireComponent(trans,strType)
-- end

-- Add LuaBehaviour component
function UnityUtils.RequireLuaBehaviour(trans)
    return L_RequireLuaBehaviour(trans)
end

-- Get the first component of the child node
function UnityUtils.GetComponentInChildren(trans, strType)
    return L_GetComponentInChildren(trans, strType)
end

-- Get child node Components
function UnityUtils.GetComponentsInChildren(trans, compType, ...)
    return L_GetComponentsInChildren(trans, compType, ...)
end
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Set Transform's localPosition
function UnityUtils.SetLocalPosition(trans, x, y, z)
    L_SetLocalPosition(trans, x, y, z)
end

-- Set Transform's localPositionY
function UnityUtils.SetLocalPositionX(trans, x)
    L_SetLocalPositionX(trans, x)
end

-- Set Transform's localPositionY
function UnityUtils.SetLocalPositionY(trans, y)
    L_SetLocalPositionY(trans, y)
end

-- Set Transform's localPositionY
function UnityUtils.SetLocalPositionZ(trans, z)
    L_SetLocalPositionZ(trans, z)
end

-- Setting up Transform's Localrotation
function UnityUtils.SetLocalRotation(trans, x, y, z, w)
    L_SetLocalRotation(trans, x, y, z, w)
end
-- Setting up Transform's LocalEulerAngles
function UnityUtils.SetLocalEulerAngles(trans, x, y, z)
    L_SetLocalEulerAngles(trans, x, y, z)
end
-- Set Transform's localScale
function UnityUtils.SetLocalScale(trans, x, y, z)
    L_SetLocalScale(trans, x, y, z)
end

-- Set the position of Transform
function UnityUtils.SetPosition(trans, x, y, z)
    L_SetPosition(trans, x, y, z)
end
-- Set the rotation of Transform
function UnityUtils.SetRotation(trans, x, y, z, w)
    L_SetRotation(trans, x, y, z, w)
end
-- Setting Transform's eulerAngles
function UnityUtils.SetAulerAngles(trans, x, y, z)
    L_SetAulerAngles(trans, x, y, z)
end

-- Set Transform forward
function UnityUtils.SetForward(trans, x, y, z)
    L_SetForward(trans, x, y, z)
end
-- Set up Transform's up
function UnityUtils.SetUp(trans, x, y, z)
    L_SetUp(trans, x, y, z)
end
-- Set the Transform right
function UnityUtils.SetRight(trans, x, y, z)
    L_SetRight(trans, x, y, z)
end

-- Setting the TweenPosition from
function UnityUtils.SetTweenPositionFrom(tweenPos, x, y, z)
    L_SetTweenPositionFrom(tweenPos, x, y, z)
end

-- Setting the to
function UnityUtils.SetTweenPositionTo(tweenPos, x, y, z)
    L_SetTweenPositionTo(tweenPos, x, y, z)
end

-- Call component functions
-- Call UIScrollView.ResetPosition()
function UnityUtils.ScrollResetPosition(trans)
    CSLuaUnityUtility.ScrollResetPosition(trans)
end

-- Call UIGrid.Reposition()
function UnityUtils.GridResetPosition(trans)
    CSLuaUnityUtility.GridResetPosition(trans)
end

-- copy text to clipboard
function UnityUtils.CopyToClipboard(str)
    CSUIUtility.CopyToClipboard(str)
end

-- UNITY_EDITOR
function UnityUtils.UNITY_EDITOR()
    return CSLuaUnityUtility.UNITY_EDITOR()
end

function UnityUtils.SetLayer(trans, layer, recursive)
    L_SetLayer(trans, layer, recursive);
end

function UnityUtils.WorldPosToHudPos(mainCamera, uiCamera, worldPos)
    return L_WorldPosToHudPos(mainCamera, uiCamera, worldPos);
end

-- Whether to use the Profiler interface
function UnityUtils.IsUseKeyCode()
    if L_IsUseKeyCode == nil then
        L_IsUseKeyCode = CSLuaUnityUtility.IsUseKeyCode()
    end
    return L_IsUseKeyCode;
end

-- By name, find the GameObject of the first layer node of the current scene
function UnityUtils.FindSceneRoot(name)
    return CSUnityUtils.FindSceneRoot(name);
end

-- Whether to use pc mode
function UnityUtils.IsUseUsePCMOdel()
    return L_IsUseUsePCMOdel()
end

-- Is it a Windows version?
function UnityUtils.UNITY_WINDOWS()
    return L_UNITY_WINDOWS()
end

return UnityUtils
