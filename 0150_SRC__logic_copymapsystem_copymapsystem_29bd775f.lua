------------------------------------------------
-- Author: 
-- Date: 2019-04-19
-- File: CopyMapSystem.lua
-- Module: CopyMapSystem
-- Description: Replica system logic class
------------------------------------------------

local TowerCopyMapData = require("Logic.CopyMapSystem.TowerCopyMapData")
local StarCopyMapData = require("Logic.CopyMapSystem.StarCopyMapData")
local SkyDoorCopyMapData = require("Logic.CopyMapSystem.SkyDoorCopyMapData")
local ManyCopyMapData = require("Logic.CopyMapSystem.ManyCopyMapData")
local CopyMapOpenState = require("Logic.CopyMapSystem.CopyMapOpenState")
local RedPointCustomCondition = CS.Thousandto.Code.Logic.RedPointCustomCondition
local RedPointFightPowerCondition = CS.Thousandto.Code.Logic.RedPointFightPowerCondition
local RedPointLevelCondition = CS.Thousandto.Code.Logic.RedPointLevelCondition
local L_NetHandler = CS.Thousandto.Code.Logic.NetHandler

-- Constructor
local CopyMapSystem = {
    -- Copy data
    CopyData = nil,
    -- Task completion event
    TaskChangeEvent = nil,
    -- Level Change Event
    LevelChangeEvent = nil,
    -- Experience copy ID
    ExpCopyID = 6001,
    -- Demon copy ID
    XinMoCopyID = 6002,
    -- Five Elements Copy ID
    WuXingCopyID = 6003,
    -- Copy ID of the Forbidden Land
    TJZMCopyID = 5201,
    -- Da Neng's Relics Copy ID
    DNYFCopyID = 5001,

    -- Enter the copy function ID to open in the map
    EnterOpenFunc = nil,
    -- Functional parameters
    EnterOpenParam = nil,

    -- List of automatically agreed copies
    AutoAgreeCopy = nil,

    -- The copy id that automatically enters after exiting
    AutoEnterCopyId = nil,
    -- The replica level that automatically enters after exiting
    AutoEnterCopyLevel = nil,
}

-- initialization
function CopyMapSystem:Initialize()
    self.CopyData = Dictionary:New();

    -- Note that this traversal is not traversal in table order
    DataConfig.DataCloneMap:Foreach(function(k, v)
        local _copyData = self:NewData(v);
        if _copyData ~= nil then
            self.CopyData:Add(k, _copyData);
        end
    end)

    -- Register Events
    self.TaskChangeEvent = Utils.Handler(self.OnTaskChanged,self);
    self.LevelChangeEvent = Utils.Handler(self.OnLevelChanged,self);
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_TASKFINISH, self.TaskChangeEvent);
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_PLAYER_LEVEL_CHANGED, self.LevelChangeEvent);
    self.AutoAgreeCopy = {}
end

-- De-initialization
function CopyMapSystem:UnInitialize()
    self.CopyData:Clear();
    self.CopyData = nil;

    -- Anti-registration event
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_TASKFINISH, self.TaskChangeEvent);
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_PLAYER_LEVEL_CHANGED, self.LevelChangeEvent);
end

-- Set a delayed open copy
function CopyMapSystem:SetEnterSceneOpenFunc(func, param)
    self.EnterOpenFunc = func
    self.EnterOpenParam = param
end
-- Enter the scene processing
function CopyMapSystem:OnEnterScene()
    if self.EnterOpenFunc ~= nil and type(self.EnterOpenFunc) == "number" then
        GameCenter.MainFunctionSystem:DoFunctionCallBack(self.EnterOpenFunc, self.EnterOpenParam)
    end
    self.EnterOpenFunc = nil
    self.EnterOpenParam = nil

    if self.AutoEnterCopyId ~= nil and self.AutoEnterCopyLevel ~= nil then
        self:ReqEnterCopyMap(self.AutoEnterCopyId, self.AutoEnterCopyLevel)
    end
    self.AutoEnterCopyId = nil
    self.AutoEnterCopyLevel = nil
end

-- Find replica data
function CopyMapSystem:FindCopyData(id)
    return self.CopyData:Get(id);
end

-- Find replica data
function CopyMapSystem:FindCopyDatasByType(type)
    local result = nil
    for _, v in pairs(self.CopyData) do
        if v.CopyCfg.Type == type then
            if result == nil then
                result = List:New();
            end
            result:Add(v);
        end
    end
    return result;
end

-- Find replica data
function CopyMapSystem:FindCopyDataByType(type)
    local result = nil
    for _, v in pairs(self.CopyData) do
        if v.CopyCfg.Type == type then
            result = v;
            break
        end
    end
    return result;
end

-- Task change events
function CopyMapSystem:OnTaskChanged(obj, sender)
    self:CheckOpenState(true);
end

-- Level Change Event
function CopyMapSystem:OnLevelChanged(obj, sender)
    self:CheckOpenState(true);
end

-- Check the copy open status
function CopyMapSystem:CheckOpenState(showOpen)
    local _playerLevel = GameCenter.GameSceneSystem:GetLocalPlayerLevel();
    for _, v in pairs(self.CopyData) do
        if v.CopyCfg.NeedTaskId ~= 0 and GameCenter.LuaTaskManager:IsMainTaskOver(v.CopyCfg.NeedTaskId) == false then
            v.TaskFinish = false;
        else
            v.TaskFinish = true;
        end

        if (v.CopyCfg.MinLv ~= 0 and v.CopyCfg.MinLv > _playerLevel) or (v.CopyCfg.MaxLv ~= 0 and v.CopyCfg.MaxLv < _playerLevel) then
            v.LevelFinish = false;
        else
            v.LevelFinish = true;
        end

        local _isOpen = false;
        if v.LevelFinish and v.TaskFinish then
            _isOpen = true;
        end
    end
end

-- Create a copy of data
function CopyMapSystem:NewData(cfgData)
    if cfgData == nil then
        return nil;
    end

    if cfgData.Type == CopyMapTypeEnum.PlaneCopy then
        return nil;
    elseif cfgData.Type == CopyMapTypeEnum.TowerCopy then
        return TowerCopyMapData:New(cfgData);
    elseif cfgData.Type == CopyMapTypeEnum.StarCopy then
        return StarCopyMapData:New(cfgData);
    elseif cfgData.Type == CopyMapTypeEnum.SkyDoor then
        return SkyDoorCopyMapData:New(cfgData);
    elseif cfgData.Type == CopyMapTypeEnum.ManyPeopleCopy then
        return ManyCopyMapData:New(cfgData);
    end
end

-- Set automatic consent status
function CopyMapSystem:SetAutoAgreeState(copyId, b)
    self.AutoAgreeCopy[copyId] = b
end

-- Whether to agree automatically
function CopyMapSystem:GetAutoAgreeState(copyId)
    local _result = self.AutoAgreeCopy[copyId]
    if _result == nil or _result == false then
        return false
    end
    return true
end
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Request to enter the copy
function CopyMapSystem:ReqEnterCopyMap(copyId, level)
    level = level or 0
    local _mapCfg = GameCenter.MapLogicSystem.MapCfg
    if _mapCfg == nil then
        return
    end
    local _cloneCfg = DataConfig.DataCloneMap[copyId]
    if _mapCfg.MapId == _cloneCfg.Mapid then
        -- In the current copy map
        Utils.ShowPromptByEnum("C_ALREADY_COPYMAP", _cloneCfg.DuplicateName)
        return
    end
    if _mapCfg.ReceiveType == 0 then
        Utils.ShowPromptByEnum("C_PLEASE_LEAVE_CURCOPY")
        return
    end
    if _mapCfg.ReceiveType == 1 then
        -- Pop-up exit copy prompt
        Utils.ShowMsgBox(function(code)
            if code == MsgBoxResultCode.Button2 then
                self.AutoEnterCopyId = copyId
                self.AutoEnterCopyLevel = level
                GameCenter.MapLogicSystem:SendLeaveMapMsg(false)
            end
        end, "C_AUTOENTER_EXIT_ASK", _cloneCfg.DuplicateName)
        return
    end
    -- GameCenter.Network.Send("MSG_zone.ReqEnterZone", {modelId = copyId, param = level})
    L_NetHandler.SendMessage_EnterCopyMap(copyId, level)
end

-- Request a copy sweep
function CopyMapSystem:ReqSweepCopyMap(copyId, level)
    level = level or 0;
    GameCenter.Network.Send("MSG_zone.ReqSweepZone", {modelId = copyId, param = level});
end

-- Number of times you request to purchase a copy
function CopyMapSystem:ReqVipBuyCount(copyID)
    GameCenter.Network.Send("MSG_copyMap.ReqVipBuyCount", {copyId = copyID});
end

-- Returns the number of purchases
function CopyMapSystem:ResVipBuyCount(msg)
    local _copyData = self:FindCopyData(msg.copyId);
    if _copyData ~= nil then
        _copyData:ParseCountData(msg)
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_COPY_VIPBUYCOUNT);
    end
end
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- --------------------------------------------------------------------------------------------------------------------------------
-- Requesting to challenge copy interface data
function CopyMapSystem:ReqOpenChallengePanel()
    GameCenter.Network.Send("MSG_copyMap.ReqOpenChallengePanel", {});
end
-- Request to continue challenging the "challenge copy"
function CopyMapSystem:ReqGoOnChallenge()
    GameCenter.Network.Send("MSG_copyMap.ReqGoOnChallenge", {});
end
-- Challenge copy interface information data
function CopyMapSystem:ResChallengeEnterPanel(msg)
    local _towerData = GameCenter.CopyMapSystem:FindCopyDataByType(CopyMapTypeEnum.TowerCopy);
    if _towerData ~= nil then
        _towerData:ParseMsg(msg);
        GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.TowerCopyMap)
        local _cfg = DataConfig.DataChallengeReward[_towerData.CurLevel]
        if _cfg ~= nil then
            GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.TowerCopyMap, 0, RedPointLevelCondition(_cfg.NeedLevel), RedPointFightPowerCondition(_cfg.NeedFightPower))
        end
    end
    -- Refresh the challenge copy interface
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_TIAOZHANFUBEN);
end
-- --------------------------------------------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Request star copy data
function CopyMapSystem:ReqOpenStarPanel()
    self:ReqOpenManyCopyPanel(self.DNYFCopyID)
end
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Request to open the interface
function CopyMapSystem:ReqOpenTJZMPanel()
    local _copyData = self:FindCopyDataByType(CopyMapTypeEnum.SkyDoor);
    if _copyData == nil then
        return;
    end
    GameCenter.Network.Send("MSG_copyMap.ReqOpenFairyCopyPanel", {copyId = _copyData.CopyID});
end

-- Open the interface and return
function CopyMapSystem:ResOpenFairyCopyPanel(msg)
    local _copyData = self:FindCopyDataByType(CopyMapTypeEnum.SkyDoor);
    if _copyData == nil then
        return;
    end
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.TJZMCopyMap);
    _copyData:ParseMsg(msg);
    if (_copyData.FreeCount + _copyData.VIPCount) > 0 then
        -- There are still times left
        GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.TJZMCopyMap, 0, RedPointCustomCondition(true));
    end
    if _copyData.CanBuyCount > 0 then
        -- Also available for purchase
        GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.TJZMCopyMap, 1, RedPointCustomCondition(true));
    end
end
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Get automatic encouragement
function CopyMapSystem:IsAutoInspire()
    if PlayerPrefs.HasKey("ExpCopyAutoInspire") then
        return true;
    else
        return false;
    end
end
-- Set whether to automatically encourage
function CopyMapSystem:SetIsAutoInspire(b)
    if b then
        PlayerPrefs.SetInt("ExpCopyAutoInspire", 1);
    else
        PlayerPrefs.DeleteKey("ExpCopyAutoInspire");
    end
    PlayerPrefs.Save();
end
-- Request for gold coins to inspire
function CopyMapSystem:ReqMoneyInspire()
    GameCenter.Network.Send("MSG_copyMap.ReqUpMorale", {type = 0});
end
-- Request for Yuanbao to cheer
function CopyMapSystem:ReqGoldInspire()
    GameCenter.Network.Send("MSG_copyMap.ReqUpMorale", {type = 1});
end
-- Request to open the interface
function CopyMapSystem:ReqOpenManyCopyPanel(copyID)
    GameCenter.Network.Send("MSG_copyMap.ReqOpenManyCopyPanel", {copyId = copyID});
end
-- Request to set the number of merges
function CopyMapSystem:ReqSetMegreCount(copyID, count)
    GameCenter.Network.Send("MSG_copyMap.ReqCopySetting", {copyId = copyID, mergeCount = count})
end

-- Open the interface and return
function CopyMapSystem:ResOpenManyCopyPanel(msg)
    local _copyData = self:FindCopyData(msg.copyId);
    if _copyData ~= nil then
        _copyData:ParseMsg(msg);

        local _funcID = nil;
        if _copyData.CopyID == self.ExpCopyID then
            _funcID = FunctionStartIdCode.ExpCopyMap;
        elseif _copyData.CopyID == self.XinMoCopyID then
            _funcID = FunctionStartIdCode.XinMoCopyMap;
        elseif _copyData.CopyID == self.WuXingCopyID then
            _funcID = FunctionStartIdCode.WuXingCopyMap;
        elseif _copyData.CopyID == self.DNYFCopyID then
            _funcID = FunctionStartIdCode.StarCopyMap;
        end

        if _funcID ~= nil then
            GameCenter.RedPointSystem:CleraFuncCondition(_funcID);
            if (_copyData.FreeCount + _copyData.VIPCount) > 0 then
                -- There are still times left
                GameCenter.RedPointSystem:AddFuncCondition(_funcID, 0, RedPointCustomCondition(true));
            end
            if _copyData.CanBuyCount > 0 then
                -- Also available for purchase
                GameCenter.RedPointSystem:AddFuncCondition(_funcID, 1, RedPointCustomCondition(true));
            end
        end
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_MANYCOPYMAP);
    end
end
-- Setting back
function CopyMapSystem:ResCopySetting(msg)
    local _copyData = self:FindCopyData(msg.copyId);
    if _copyData ~= nil then
        _copyData.CurMergeCount = msg.mergeCount
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_MANYCOPYMAP);
    end
end
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
return CopyMapSystem