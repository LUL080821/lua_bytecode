------------------------------------------------
-- author:
-- Date: 2019-03-25
-- File: Global.lua
-- Module: Global
-- Description: Some other public module storage places in Lua.
------------------------------------------------
-- //Define global variables
-- ==Utility==--
-- Mathematical functions
require("Common.CustomLib.Utility.Math");
-- Vector2
Vector2 = require("Common.CustomLib.Utility.Vector2")
-- Vector3
Vector3 = require("Common.CustomLib.Utility.Vector3")
-- Vector4
Vector4 = require("Common.CustomLib.Utility.Vector4")
-- Quaternion
Quaternion = require("Common.CustomLib.Utility.Quaternion")
-- Color
Color = require("Common.CustomLib.Utility.Color")
-- Function module for Unity object operation
UnityUtils = require("Common.CustomLib.Utility.UnityUtils");
-- Operation function module of UI object
UIUtils = require("Common.CustomLib.Utility.UIUtils");
-- Function function module
Utils = require("Common.CustomLib.Utility.Utils");
-- AssetUtils
AssetUtils = require("Common.CustomLib.Utility.AssetUtils")
-- LayerUtils
LayerUtils = require("Common.CustomLib.Utility.LayerUtils")
-- Commonly used tool classes - here are some common logical methods.
CommonUtils = require("Logic.Base.CommonUtils.CommonUtils")

-- Json
Json = require("Common/Json");
-- Inspect
Inspect = require("Common/inspect")

-- ==Collections==--
-- List
List = require("Common.CustomLib.Collections.List");
-- dictionary
Dictionary = require("Common.CustomLib.Collections.Dictionary");
-- queue
Queue = require("Common.CustomLib.Collections.Queue");

-- ==LuaEventManager==--
-- Event Manager
LuaEventManager = require("Common.CustomLib.LuaEventManager.LuaEventManager");

-- Entrusted Management
LuaDelegateManager = require("Common.CustomLib.LuaDelegateManager.LuaDelegateManager")

-- ==KeyCodeSystem==--
-- Keyboard shortcut monitoring system
KeyCodeSystem = require("Common.CustomLib.KeyCodeSystem");

-- ==LuaBehaviourManager==--
-- LuaBehaviour Management Class
LuaBehaviourManager = require("Common.CustomLib.LuaBehaviourManager.LuaBehaviourManager")

-- ==Other global definitions==--
-- Enumeration definition (UIEventDefine to be retrieved before loading the script)
UILuaEventDefine = require("UI.Base.UILuaEventDefine");
UIEventExtDefine = require("UI.Base.UIEventExtDefine");
LogicLuaEventDefine = require("Global.LogicLuaEventDefine");
-- Configuration module
AppConfig = require("Config.AppConfig");
-- Configuration data
DataConfig = require("Config.DataConfig");
-- Enumeration configuration
FunctionStartIdCode = require("Config.Data.FunctionStartIdCode")
FunctionVariableIdCode = require("Config.Data.FunctionVariableIdCode")
RankBaseTypeCode = require("Config.Data.RankBaseTypeCode")
GlobalName = require("Config.Data.GlobalName")

-- Game Center
GameCenter = require("Global.GameCenter");

-- All request messages
ReqMsg = require("Network.ReqMsgCMD");

-- State Machine
StateMachine = require("Common/ExternalLib/AI/FSM/StateMachine");
-- Lua's item lattice common components
UILuaItem = require("UI.Components.UIItem");
-- Record
Record = require("Common.CustomLib.Record")
-- BI interface click event
BiIdCode = require("Config.Data.BiIdCode")

-- A small linear [0,1] interpolation animation gets the component
AnimValue01 = require("Common.CustomLib.Utility.AnimValue01")
-- Item Reason Code
ItemChangeReasonName = require("Config.Data.ItemChangeReasonName")

-- Model part code
FSkinPartCode = require("Logic.FGameObject.FSkinPartCode");

-- The tool class for model display--C#'s same name class as content synchronization
RoleVEquipTool = require("Logic.FGameObject.RoleVEquipTool");

-- Role display information
PlayerVisualInfo = require("Logic.Entity.Character.Player.PlayerVisualInfo");
-- SkinModel processing
FSkinModelWrap = require("Logic.FGameObject.FSkinModelWrap");
-- Item model processing
LuaItemBase = require("Logic.Item.LuaItemBase")
-- Manage UIRoleSkinWrap
UIRoleSkinManager = require("Common.CustomLib.UIRoleSkinManager.UIRoleSkinManager")
-- Action definition
AnimClipNameDefine = require("Config.Data.AnimClipNameDefine")

-- Some processing of Shader in FGameObject system
FGameObjectShaderUtils = require("Logic.FGameObject.FGameObjectShaderUtils")

LoginMapStateCode = require("Logic.LoginMapLogic.LoginMapStateCode");
-- Player avatar
PlayerHead = require("UI.Components.UIPlayerHead")

-- Player level
PlayerLevel = require "UI.Components.UIPlayerLevelLabel"

-- Global constant definition
GlobalConst = require "Global.GlobalConst"
GosuSDK = require "GosuSDK"

-- Main.lua (hoặc init.lua)

-- patch luôn ở đây: ẩn dấu cộng và không cho nhấp trên thanh tiền
-- local _RequireUIMoneyForm = UIUtils.RequireUIMoneyForm
-- UIUtils.RequireUIMoneyForm = function(trans, ...)
--     local form = _RequireUIMoneyForm(trans, ...)
--     if form and form.TransformInst then
--         for i = 1, 4 do
--             local path = string.format("RightTop/Item%d/Add", i)
--             local addGo = UIUtils.FindGo(form.TransformInst, path)
--             if addGo then
--                 addGo:SetActive(false)
--             end
--             local pathItem = string.format("RightTop/Item%d", i)
--             local addItemGo = UIUtils.FindGo(form.TransformInst, pathItem)
--             if addItemGo then
--                 local col = addItemGo.gameObject:GetComponent(typeof(CS.UnityEngine.Collider))
--                 if col  ~= nil then
--                  col.enabled = false
--                 end
--             end
--         end
--     end
--     return form
--end
