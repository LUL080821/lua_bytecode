------------------------------------------------
-- Author: 
-- Date: 2019-04-11
-- File: UIUtils.lua
-- Module: UIUtils
-- Description: Some commonly used functions for handling UI
------------------------------------------------
local UIUtils = {};
local UIUtility = CS.Thousandto.Plugins.Common.UIUtility;
local EventDelegate = CS.EventDelegate
local L_GetSize = UIUtility.GetSize;
local L_GetSizeX = UIUtility.GetSizeX;
local L_GetSizeY = UIUtility.GetSizeY;
local L_RotationToForward = UIUtility.RotationToForward;
local L_MiniMapPosToWorldPos = UIUtility.MiniMapPosToWorldPos;
local L_WorldPosToMiniMapPos = UIUtility.WorldPosToMiniMapPos;
local L_RequireUIItem = UIUtility.RequireUIItem;
local L_RequireUIListMenu = UIUtility.RequireUIListMenu;
local L_RequireUIRoleSkinCompoent = UIUtility.RequireUIRoleSkinCompoent;
local L_RequireUIPlayerSkinCompoent = UIUtility.RequireUIPlayerSkinCompoent;
local L_RequireUIVfxSkinCompoent = UIUtility.RequireUIVfxSkinCompoent;
local L_RequireUIShandowPlane = UIUtility.RequireUIShandowPlane;
local L_RequireUIIcon = UIUtility.RequireUIIcon;
local L_RequireUIIconBase = UIUtility.RequireUIIconBase;
local L_RequireSpringPanel = UIUtility.RequireSpringPanel;
local L_RequireTweenPosition = UIUtility.RequireTweenPosition;
local L_RequireLoopMoveSceneScript = UIUtility.RequireLoopMoveSceneScript;
local L_RequireUIVideoTexture = UIUtility.RequireUIVideoTexture;
local L_RequireAnimListBaseScript = UIUtility.RequireAnimListBaseScript;
local L_RequireAnimator = UIUtility.RequireAnimator;
local L_SetBtnState = UIUtility.SetBtnState;
local L_SetUISprite = UIUtility.SetUISprite;
local L_SetColor = UIUtility.SetColor;
local L_SetEffectColor = UIUtility.SetEffectColor;
local L_SetColorByQuality = UIUtility.SetColorByQuality;
local L_SetSprGenColor = UIUtility.SetSprGenColor;
local L_SetAllChildColorGray = UIUtility.SetAllChildColorGray;
local L_RequireUIPlayerHead = UIUtility.RequireUIPlayerHead;
local L_RequireUISpriteAnimation = UIUtility.RequireUISpriteAnimation;
local L_RequireUIPolygonScript = UIUtility.RequireUIPolygonScript;
local L_RequireUIPlayerBagItem = require ("UI.Components.UIPlayerBagItem")
local L_RequireNatureVfxEffect = UIUtility.RequireNatureVfxEffect;
local L_RequireUILoopScrollViewBase = UIUtility.RequireUILoopScrollViewBase
local L_RequireUISelectEquipItem = UIUtility.RequireUISelectEquipItem
local L_RequireCamera = UIUtility.RequireCamera
local L_RequireUIMoneyForm = UIUtility.RequireUIMoneyForm
local L_RequireUIFrameAnimation = UIUtility.RequireUIFrameAnimation
local L_SetTextByMessageStringID = UIUtility.SetTextByMessageStringID
local L_SetTextByStringDefinesID = UIUtility.SetTextByStringDefinesID
local L_SetTextByNumber = UIUtility.SetTextByNumber
local L_SetTextByBigNumber = UIUtility.SetTextByBigNumber
local L_SetTextByString = UIUtility.SetTextByString
local L_ClearText = UIUtility.ClearText
local L_SetTextFormat = UIUtility.SetTextFormat
local L_SetTextByProgress = UIUtility.SetTextByProgress
local L_SetTextByPercent = UIUtility.SetTextByPercent
local L_SetTextMMSS = UIUtility.SetTextMMSS
local L_SetTextHHMMSS = UIUtility.SetTextHHMMSS
local L_SetTextDDHHMMSS = UIUtility.SetTextDDHHMMSS
local L_SetTextYYMMDDHHMMSS = UIUtility.SetTextYYMMDDHHMMSS
local L_SetTextYYMMDDHHMMSSNotZone = UIUtility.SetTextYYMMDDHHMMSSNotZone
local L_GetText = UIUtility.GetText
local L_SetGameObjectNameByNumber = UIUtility.SetGameObjectNameByNumber
local L_PanelClipOffsetToZero = UIUtility.PanelClipOffsetToZero
local L_FindBtn = UIUtility.FindBtn
local L_FindPanel = UIUtility.FindPanel
local L_FindLabel = UIUtility.FindLabel
local L_FindTex = UIUtility.FindTex
local L_RequireTex = UIUtility.RequireTex
local L_FindSpr = UIUtility.FindSpr
local L_FindWid = UIUtility.FindWid
local L_FindGrid = UIUtility.FindGrid
local L_FindTable = UIUtility.FindTable
local L_FindToggle = UIUtility.FindToggle
local L_FindScrollView = UIUtility.FindScrollView
local L_FindProgressBar = UIUtility.FindProgressBar
local L_FindSlider = UIUtility.FindSlider
local L_FindInput = UIUtility.FindInput
local L_FindTweenPosition = UIUtility.FindTweenPosition
local L_FindTweenColor = UIUtility.FindTweenColor
local L_FindTweenScale = UIUtility.FindTweenScale
local L_FindTweenRotation = UIUtility.FindTweenRotation
local L_FindTweenAlpha = UIUtility.FindTweenAlpha
local L_FindCamera = UIUtility.FindCamera
local L_FindBoxCollider = UIUtility.FindBoxCollider
local L_FindScrollBar = UIUtility.FindScrollBar
local L_FindLuaForm = UIUtility.FindLuaForm
local L_FindExtendLuaForm = UIUtility.FindExtendLuaForm
local L_FindEventListener = UIUtility.FindEventListener
local L_FindTweenTransform = UIUtility.FindTweenTransform
local L_SetTextByPropName = UIUtility.SetTextByPropName
local L_SetTextByPropValue = UIUtility.SetTextByPropValue
local L_SetTextByPropNameAndValue = UIUtility.SetTextByPropNameAndValue
local L_SetTextFormatById = UIUtility.SetTextFormatById
local L_FindPlayableDirector = UIUtility.FindPlayableDirector
local L_FindSutureTex = UIUtility.FindSutureTex
local L_RequireUIBlinkCompoent = UIUtility.RequireUIBlinkCompoent
local L_RequireUISpriteSelectEffect = UIUtility.RequireUISpriteSelectEffect
local L_StripLanSymbol = UIUtility.StripLanSymbol
local L_RequireDragScrollView = UIUtility.RequireDragScrollView
local L_SearchHierarchy = UIUtility.SearchHierarchy
local L_FindFRealObjectScript = UIUtility.FindFRealObjectScript
local L_ConvertKhmerUnicodeToLegacyString = UIUtility.ConvertKhmerUnicodeToLegacyString
local L_ConvertKhmerLegacyToUnicodeString = UIUtility.ConvertKhmerLegacyToUnicodeString
local L_ParseFormatPlayerName = UIUtility.ParseFormatPlayerName

-- Get the texts of the Label
function UIUtils.GetText(label)
    if not label then
        return;
    end
    return L_GetText(label)
end

-- Set label text (parameters: enumeration in MessageString configuration)
function UIUtils.SetTextByEnum(label, enum, ...)
    if not label or not enum then
        return;
    end
    local _id = DataConfig.DataMessageString.GetKey(enum);
    if _id then
        L_SetTextByMessageStringID(label, _id, ...);
    else
        Debug.LogError("The Enum does not exist in MessageString =", enum)
    end
end

-- Set label text (parameters: id in MessageString configuration)
function UIUtils.SetTextByMessageStringID(label, id, ...)
    L_SetTextByMessageStringID(label, id, ...);
end

-- Set label text (parameters: id in StringDefines configuration)
function UIUtils.SetTextByStringDefinesID(label, id, ...)
    if not label or not id then
        return;
    end
    L_SetTextByStringDefinesID(label, id, ...);
end

-- Set label text (parameters: numeric type), isUseBigUnit: Whether to use large units
function UIUtils.SetTextByNumber(label, number, isUseBigUnit, validCount)
    if not label or not number then
        return;
    end
    L_SetTextByNumber(label, number, not (not isUseBigUnit), validCount or 0);
end

-- Set label text (parameters: numeric type), isUseBigUnit: Whether to use large units
function UIUtils.SetTextByBigNumber(label, number, isUseBigUnit, validCount)
    if not label or not number then
        return;
    end
    L_SetTextByBigNumber(label, number, not (not isUseBigUnit), validCount or 0);
end

-- Set label text (parameters: string type)
function UIUtils.SetTextByString(label, str)
    if not label or not str then
        return;
    end
    L_SetTextByString(label, str);
end

-- Clear label text
function UIUtils.ClearText(label)
    if not label then
        return;
    end
    return L_ClearText(label);
end

function UIUtils.SetTextFormatById(label, formatId, id)
    if not label then
        return;
    end
    return L_SetTextFormatById(label, formatId, id)
end

-- Set label text
function UIUtils.SetTextFormat(label, csFormatStr, ...)
    if not label or not csFormatStr then
        return;
    end
    L_SetTextFormat(label, csFormatStr, ...);
end

-- Set the time type Label
function UIUtils.SetTextMMSS(label, second)
    if not label or not second then
        return;
    end
    L_SetTextMMSS(label, second);
end

-- Set the time type Label
function UIUtils.SetTextHHMMSS(label, second)
    if not label or not second then
        return;
    end
    L_SetTextHHMMSS(label, second);
end

-- Set the time type Label
function UIUtils.SetTextDDHHMMSS(label, second)
    if not label or not second then
        return;
    end
    L_SetTextDDHHMMSS(label, second);
end

function UIUtils.SetTextYYMMDDHHMMSS(label, second)
    if not label or not second then
        return;
    end
    L_SetTextYYMMDDHHMMSS(label, second)
end

function UIUtils.SetTextYYMMDDHHMMSSNotZone(label, second)
    if not label or not second then
        return;
    end
    L_SetTextYYMMDDHHMMSSNotZone(label, second)
end

-- Set the progress {0}/{1} type Label, isUseBigUnit: Whether to use large units
function UIUtils.SetTextByProgress(label, num1, num2, isUseBigUnit, validCount)
    if label and num1 and num2 then
        L_SetTextByProgress(label, num1, num2, not (not isUseBigUnit), validCount or 0)
    end
end

-- Set a percentage {0}% Label
function UIUtils.SetTextByPercent(label, num)
    if label and num then
        L_SetTextByPercent(label, num)
    end
end

-- Set attribute name
function UIUtils.SetTextByPropName(label, proId, formatString)
    L_SetTextByPropName(label, proId, formatString)
end

-- Set attribute value
function UIUtils.SetTextByPropValue(label, proId, proValue, formatString)
    L_SetTextByPropValue(label, proId, proValue, formatString)
end

-- Set attribute name and value
function UIUtils.SetTextByPropNameAndValue(label, proId, proValue, formatString)
    L_SetTextByPropNameAndValue(label, proId, proValue, formatString)
end

-- Lua side calls the string.Format function of c#
function UIUtils.CSFormat(original, ...)
    return UIUtility.Format(original, ...);
end

-- Lua side calls the string.Format(String format, params object[] args) function of C#
function UIUtils.CSFormatLuaTable(original, t)
    return UIUtility.FormatLuatable(original, t);
end

-- Add button event
function UIUtils.AddBtnEvent(btn, method, caller, data)
    btn.onClick:Clear();
    EventDelegate.Add(btn.onClick, Utils.Handler(method, caller, data));
end

-- Add button double-click event
function UIUtils.AddBtnDoubleClickEvent(btn, method, caller, data)
    btn.onDoubleClick:Clear()
    EventDelegate.Add(btn.onDoubleClick, Utils.Handler(method, caller, data))
end

-- Add change event -- suitable for all UI components with onChange events
function UIUtils.AddOnChangeEvent(uiComp, method, caller, data)
    uiComp.onChange:Clear();
    EventDelegate.Add(uiComp.onChange, Utils.Handler(method, caller, data));
end

-- Add various events, eventDelegateList = List<EventDelegate>
function UIUtils.AddEventDelegate(eventDelegateList, method, caller, data)
    eventDelegateList:Clear()
    EventDelegate.Add(eventDelegateList, Utils.Handler(method, caller, data))
end

-- Get the control size
function UIUtils.GetSize(trans)
    return L_GetSize(trans);
end
-- Get the control size.x
function UIUtils.GetSizeX(trans)
    return L_GetSizeX(trans);
end
-- Get the control size.y
function UIUtils.GetSizeY(trans)
    return L_GetSizeY(trans);
end

-- Rotate to the front
function UIUtils.RotationToForward(trans, angle)
    return L_RotationToForward(trans, angle)
end

-- Get the world coordinates based on the coordinates on the map UI
function UIUtils.MiniMapPosToWorldPos(camYaw, uiSizeX, uiSizeY, mapSizeX, mapSizeY, camPosX, camPosY, clickPosX, clickPosY, clickPosZ)
    return L_MiniMapPosToWorldPos(camYaw, uiSizeX, uiSizeY, mapSizeX, mapSizeY, camPosX, camPosY, clickPosX, clickPosY, clickPosZ)
end

-- Get coordinates on map UI based on world coordinates
function UIUtils.WorldPosToMiniMapPos(camYaw, uiSizeX, uiSizeY, mapSizeX, mapSizeY, camPosX, camPosY, worldPosX, worldPosY, worldPosZ)
    return L_WorldPosToMiniMapPos(camYaw, uiSizeX, uiSizeY, mapSizeX, mapSizeY, camPosX, camPosY, worldPosX, worldPosY, worldPosZ)
end

-- Find trans
function UIUtils.FindTrans(trans, path)
    if path then
        return trans:Find(path);
    else
        return trans;
    end
end

-- Find gameobject
function UIUtils.FindGo(trans, path)
    local _trans = UIUtils.FindTrans(trans, path)
    if _trans ~= nil then
        return _trans.gameObject;
    end
    return nil
end

-- Find button
function UIUtils.FindBtn(trans, path)
    return L_FindBtn(trans, path)
end

-- Find Panel
function UIUtils.FindPanel(trans, path)
    return L_FindPanel(trans, path)
end

-- Find label
function UIUtils.FindLabel(trans, path)
    return L_FindLabel(trans, path)
end

-- Find the texture
function UIUtils.FindTex(trans, path)
    return L_FindTex(trans, path)
end

function UIUtils.RequireTex(trans, path)
    return L_RequireTex(trans, path)
end

-- Find sprite
function UIUtils.FindSpr(trans, path)
    return L_FindSpr(trans, path)
end

-- Find widget
function UIUtils.FindWid(trans, path)
    return L_FindWid(trans, path)
end

-- Find grid
function UIUtils.FindGrid(trans, path)
    return L_FindGrid(trans, path)
end

-- Find table
function UIUtils.FindTable(trans, path)
    return L_FindTable(trans, path)
end

-- Find toggle
function UIUtils.FindToggle(trans, path)
    return L_FindToggle(trans, path)
end

-- Find ScrollView
function UIUtils.FindScrollView(trans, path)
    return L_FindScrollView(trans, path)
end

-- Find progress bar
function UIUtils.FindProgressBar(trans, path)
    return L_FindProgressBar(trans, path)
end

-- Find adjustable progress bars.
function UIUtils.FindSlider(trans, path)
    return L_FindSlider(trans, path)
end

-- Find Input Components
function UIUtils.FindInput(trans, path)
    return L_FindInput(trans, path)
end

-- Find TweenPosition Components
function UIUtils.FindTweenPosition(trans, path)
    return L_FindTweenPosition(trans, path)
end

-- Find TweenColor Components
function UIUtils.FindTweenColor(trans, path)
    return L_FindTweenColor(trans, path)
end

-- Find TweenScale Components
function UIUtils.FindTweenScale(trans, path)
    return L_FindTweenScale(trans, path)
end

-- Find TweenRotation Components
function UIUtils.FindTweenRotation(trans, path)
    return L_FindTweenRotation(trans, path)
end

-- Find TweenAlpha components
function UIUtils.FindTweenAlpha(trans, path)
    return L_FindTweenAlpha(trans, path)
end

-- Find TweenAlpha components
function UIUtils.FindCamera(trans, path)
    return L_FindCamera(trans, path)
end

function UIUtils.FindBoxCollider(trans, path)
    return L_FindBoxCollider(trans, path)
end

function UIUtils.FindScrollBar(trans, path)
    return L_FindScrollBar(trans, path)
end

function UIUtils.FindLuaForm(trans, path)
    return L_FindLuaForm(trans, path)
end

function UIUtils.FindExtendLuaForm(trans, path)
    return L_FindExtendLuaForm(trans, path)
end

function UIUtils.FindEventListener(trans, path)
    return L_FindEventListener(trans, path)
end

function UIUtils.FindTweenTransform(trans, path)
    return L_FindTweenTransform(trans, path)
end

function UIUtils.FindPlayableDirector(trans, path)
    return L_FindPlayableDirector(trans, path)
end
function UIUtils.FindSutureTex(trans, path)
    return L_FindSutureTex(trans, path)
end
function UIUtils.FindFRealObjectScript(trans, path)
    return L_FindFRealObjectScript(trans, path)
end
function UIUtils.SearchHierarchy(trans, name, ignoreCase)
    if not ignoreCase then
        ignoreCase = false
    end
    return L_SearchHierarchy(trans, name, ignoreCase)
end
-- Add UIListMenu component
function UIUtils.RequireUIListMenu(trans)
    return L_RequireUIListMenu(trans);
end

-- Add UIRoleSkinCompoent component
function UIUtils.RequireUIRoleSkinCompoent(trans)
    return UIRoleSkinManager:GetWrap(L_RequireUIRoleSkinCompoent(trans)); 
end

-- Add UIPlayerSkinCompoent component
function UIUtils.RequireUIPlayerSkinCompoent(trans)
    return UIRoleSkinManager:GetWrap(L_RequireUIPlayerSkinCompoent(trans));
end

-- Add UIVfxSkinCompoent
function UIUtils.RequireUIVfxSkinCompoent(trans)
    return L_RequireUIVfxSkinCompoent(trans);
end

-- Add ui shadow component
function UIUtils.RequireUIShandowPlane(trans)
    return L_RequireUIShandowPlane(trans);
end

-- Add UIIcon components
function UIUtils.RequireUIIcon(trans)
    return L_RequireUIIcon(trans);
end

-- Add UIIconBase component
function UIUtils.RequireUIIconBase(trans)
    return L_RequireUIIconBase(trans);
end

-- Add SpringPanel components
function UIUtils.RequireSpringPanel(trans)
    return L_RequireSpringPanel(trans);
end

-- Add TweenPosition component
function UIUtils.RequireTweenPosition(trans)
    return L_RequireTweenPosition(trans);
end

-- Adding LoopMoveSceneScript component
function UIUtils.RequireLoopMoveSceneScript(trans)
    return L_RequireLoopMoveSceneScript(trans);
end

-- Add UIVideoTexture component
function UIUtils.RequireUIVideoTexture(trans)
    return L_RequireUIVideoTexture(trans);
end
-- Register animated script
function UIUtils.RequireAnimListBaseScript(trans)
    return L_RequireAnimListBaseScript(trans);
end
-- Register animated script
function UIUtils.RequireUISpriteAnimation(trans)
    return L_RequireUISpriteAnimation(trans)
end
-- Register a career script
function UIUtils.RequireUIPolygonScript(trans)
    return L_RequireUIPolygonScript(trans)
end
-- Register a backpack script
function UIUtils.RequireUIPlayerBagItem(trans)
    return L_RequireUIPlayerBagItem:New(trans)
end
-- Register a creation special effect script
function UIUtils.RequireNatureVfxEffect(trans)
    return L_RequireNatureVfxEffect(trans)
end
-- Register a loop swipe script
function UIUtils.RequireUILoopScrollViewBase(trans)
    return L_RequireUILoopScrollViewBase(trans)
end

-- Register and select equipment script
function UIUtils.RequireUISelectEquipItem(trans)
    return L_RequireUISelectEquipItem(trans)
end
-- Register gold coin form
function UIUtils.RequireUIMoneyForm(trans)
    return L_RequireUIMoneyForm(trans)
end

-- Register frame animation script
function UIUtils.RequireUIFrameAnimation(trans)
    return L_RequireUIFrameAnimation(trans)
end

-- Script to register a camera
function UIUtils.RequireCamera(trans)
    return L_RequireCamera(trans)
end

-- Add UIPlayerHead component
function UIUtils.RequireUIPlayerHead(trans)
    return L_RequireUIPlayerHead(trans);
end
-- Register animator script
function UIUtils.RequireAnimator(trans)
    return L_RequireAnimator(trans);
end
function UIUtils.RequireUIBlinkCompoent(trans)
    return L_RequireUIBlinkCompoent(trans)
end
function UIUtils.RequireUISpriteSelectEffect(trans)
    return L_RequireUISpriteSelectEffect(trans)
end

function UIUtils.RequireDragScrollView(trans)
    return L_RequireDragScrollView(trans)
end

function UIUtils.SetBtnState(trans, isEnabled)
    return L_SetBtnState(trans, isEnabled)
end

function UIUtils.SetUISprite(trans, name)
    return L_SetUISprite(trans, name)
end

-- Set color (UILable, UITexture, UISprite)
function UIUtils.SetColor(obj, r, g, b, a)
    L_SetColor(obj, r, g, b, a);
end

function UIUtils.SetEffectColor(label, r, g, b, a)
    L_SetEffectColor(label, r, g, b, a)
end

function UIUtils.SetColorByQuality(label, quality)
    L_SetColorByQuality(label, quality)
end

-- Set color (UILable, UITexture, UISprite)
function UIUtils.SetColorByString(obj, str)
    L_SetColor(obj, str);
end

-- Set color
function UIUtils.SetColorByType(obj, colorType)
    if colorType == ColorType.White then
        L_SetColor(obj, 1, 1, 1, 1);
    elseif colorType == ColorType.Black then
        L_SetColor(obj, 0, 0, 0, 1);
    elseif colorType == ColorType.Red then
        L_SetColor(obj, 1, 0, 0, 1);
    elseif colorType == ColorType.Orange then--#FF4E00
        L_SetColor(obj,1.0, 0.306, 0.0, 1.0);
    elseif colorType == ColorType.Blue then
        L_SetColor(obj, 0, 0, 1, 1);
    elseif colorType == ColorType.Green then
        L_SetColor(obj, 0, 1, 0, 1);
    elseif colorType == ColorType.Yellow then
        L_SetColor(obj, 1, 0.92, 0.016, 1);
    elseif colorType == ColorType.Gray then
        L_SetColor(obj, 0.5, 0.5, 0.5, 1);
    elseif colorType == ColorType.Clear then
        L_SetColor(obj, 0, 0, 0, 0);
    end
end

-- Set white
function UIUtils.SetWhite(obj)
    L_SetColor(obj, 1, 1, 1, 1);
end

-- Set gray
function UIUtils.SetGray(obj)
    L_SetColor(obj, 0.5, 0.5, 0.5, 1);
end

-- Set red
function UIUtils.SetRed(obj)
    L_SetColor(obj, 1, 0, 0, 1);
end
--#FF4E00
function UIUtils.SetOrange(obj)
    L_SetColor(obj,1.0, 0.306, 0.0, 1.0);
end
-- Set green
function UIUtils.SetGreen(obj)
    L_SetColor(obj, 0.0, 0.522, 0.380, 1.0);
end

-- Set blue
function UIUtils.SetBlue(obj)
    L_SetColor(obj, 0, 0, 1, 1);
end

-- Set yellow
function UIUtils.SetYellow(obj)
    L_SetColor(obj, 1, 0.92, 0.016, 1);
end

-- Set the image gradient color
function UIUtils.SetSprGenColor(spr, quality)
    L_SetSprGenColor(spr, quality)
end

-- Set all sub-objects to be gray and cannot be clicked
function UIUtils.SetAllChildColorGray(trs, isGray)
    L_SetAllChildColorGray(trs, isGray)
end

-- Set the name of the gameobject
function UIUtils.SetGameObjectNameByNumber(go, number)
    L_SetGameObjectNameByNumber(go, number)
end

-- Set Panel's ClipOffset to 0
function UIUtils.PanelClipOffsetToZero(panel)
    L_PanelClipOffsetToZero(panel)
end

-- Hide excess (elements must have Gobj)
function UIUtils.HideNeedless(list, showCnt)
    local _listCnt = list:Count()
    local _needHideCnt = _listCnt - showCnt
    for i = _listCnt, _listCnt - _needHideCnt + 1, -1 do
        if list[i].Gobj then
            list[i].Gobj:SetActive(false)
        end
    end
end

-- Get language symbols
function UIUtils.StripLanSymbol(text,lan)
    return L_StripLanSymbol(text,lan);
end

-- [gosu] 2025/03/19
function UIUtils.ConvertKhmerUnicodeToLegacyString(text)
    -- return L_ConvertKhmerUnicodeToLegacyString(text);
    -- [Gosu global fix]
    if (FLanguage.Default ~= FLanguage.VIE) then
        return text
    else
        return L_ConvertKhmerUnicodeToLegacyString(text);
    end
end
function UIUtils.ConvertKhmerLegacyToUnicodeString(text)
    -- [Gosu global fix]
    -- return L_ConvertKhmerLegacyToUnicodeString(text);

    if (FLanguage.Default ~= FLanguage.VIE) then
        return text
    else
        return L_ConvertKhmerLegacyToUnicodeString(text);
    end
end

-- [gosu] 2025/06/04
function UIUtils.ParseFormatPlayerName(text)
    return L_ParseFormatPlayerName(text);
end


return UIUtils;
