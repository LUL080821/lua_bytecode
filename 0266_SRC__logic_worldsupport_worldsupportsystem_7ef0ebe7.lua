
------------------------------------------------
-- author:
-- Date: 2019-11-25
-- File: WorldSupportSystem.lua
-- Module: WorldSupportSystem
-- Description: The world seeks help
------------------------------------------------
-- Quote
local L_SupportInfo = require("Logic.WorldSupport.WorldSupportInfo")
local WorldSupportSystem = {
    -- Today's cumulative reputation value
    CurReputation = 0,
    -- Top of reputation
    MaxReputation = 0,
    -- Help list
    SupportInfoList = List:New(),
    -- Current supported data
    CurSupportPlayer = nil,
    -- Thanks for the prop ID
    TanksItemID = 0,
    -- Red dot
    RedPoint = false,
    -- Death request data
    ReqSupportData = nil,
    NeedSearchPath = false,
    NeedEnterCopyMap = false,
}

function WorldSupportSystem:Initialize()
    self.IsSupporting = false
    self.RedPoint = false
    local _lv = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
    DataConfig.DataWorldSupport:ForeachCanBreak(function(k, v)
        if v.STitleRank then
            local _item = Utils.SplitNumber(v.STitleRank, '_')
            self.TanksItemID = _item[1]
        end
        local _ar = Utils.SplitNumber(v.PicRes, '_')    
        local _ar1 = Utils.SplitNumber(v.LevelRank, '_')
        if _lv >= _ar1[1] and _lv <= _ar1[2] then
            if _ar[3] then
                self.MaxReputation = _ar[3]
                return true
            end
        end
    end)
end

function WorldSupportSystem:UnInitialize()
    self.SupportInfoList:Clear()
end

function WorldSupportSystem:SetMaxReputation()
    local _lv = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
    DataConfig.DataWorldSupport:ForeachCanBreak(function(k, v)
        local _ar = Utils.SplitNumber(v.PicRes, '_')
        local _ar1 = Utils.SplitNumber(v.LevelRank, '_')
        if _lv >= _ar1[1] and _lv <= _ar1[2] then
            if _ar[3] then
                self.MaxReputation = _ar[3]
                return true
            end
        end
    end)
end

-- Set the help list data
function WorldSupportSystem:SetSupportInfoList(info)
    for i = 1, #info do
        local _temp = L_SupportInfo:NewWithData(info[i])
        self.SupportInfoList:Add(_temp)
    end
end

-- Set red dots
function WorldSupportSystem:SetXmSupportRedState(isRed)
    self.RedPoint = isRed
end

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- World Support Request Message
function WorldSupportSystem:ReqWorldSupport(bossId)
    local _msg = ReqMsg.MSG_WorldHelp.ReqWorldHelp:New()
    _msg.bossCode = bossId
    _msg:Send()
end

-- Request to open the World Support Panel
function WorldSupportSystem:ReqOpenWorldSupportPannel()
    local _msg = ReqMsg.MSG_WorldHelp.ReqWorldHelpList:New()
    _msg:Send()
end

-- Go to the support request message
function WorldSupportSystem:ReqToWorldSupport(supportId)
    local _msg = ReqMsg.MSG_WorldHelp.ReqJoinHelp:New()
    _msg.id = supportId
    _msg:Send()
end

-- Cancel support request message
function WorldSupportSystem:ReqCancelSupport()
    local _msg = ReqMsg.MSG_WorldHelp.ReqCancelHelp:New()
    _msg:Send()
end

-- Thanks to the player for requesting the message
function WorldSupportSystem:ReqThankSupport(supportId, messageStr)
    local _msg = ReqMsg.MSG_WorldHelp.ReqThkHelp:New()
    _msg.id = supportId
    _msg.words = messageStr
    _msg:Send()
end

-- Get the last supported information
function WorldSupportSystem:ReqAtLastHelp()
    local _msg = ReqMsg.MSG_WorldHelp.ReqAtLastHelp:New()
    _msg:Send()
end
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- World Support Broadcast Return Message
function WorldSupportSystem:ResNewWorldSupportInfo(result)
    self.RedPoint = true
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_WORLDSUPPORT_ALERT)
end

-- World Support Panel Return Message
function WorldSupportSystem:ResOpenWorldSupportPannel(result)
    if result then
        self.SupportInfoList:Clear()
        if result.helps then
            self:SetSupportInfoList(result.helps)
        end
        if result.taskHelps then
            self:SetSupportInfoList(result.taskHelps)
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVTNT_WORLDSUPPORT_LISTUPDATE)
end

-- Synchronize today's reputation
function WorldSupportSystem:SyncPrestige(result)
    self.CurReputation = result.prestige
end

-- Synchronize supported targets
function WorldSupportSystem:ResWorldSupporting(result)
    if result.bossID > 0 then
        self.IsSupporting = true
        GameCenter.PushFixEvent(UIEventDefine.UIWorldSupportingForm_Open, result)
    else
        self.IsSupporting = false
        GameCenter.MapLogicSwitch:DoPlayerExitPrepare()
        GameCenter.PushFixEvent(UIEventDefine.UIWorldSupportingForm_Close)
    end
end

-- Request Thanks to Players Panel Return Messages
function WorldSupportSystem:ResToThankSupport(result)
    GameCenter.PushFixEvent(UIEventDefine.UIWorldSupportThankForm_Open, result)
end

-- Thanks for returning the message
function WorldSupportSystem:ResThankMessageInfo(result)
    GameCenter.PushFixEvent(UIEventDefine.UIWorldSupportResultForm_Open, result)
end

-- Return to the last supported information
function WorldSupportSystem:ResAtLastHelp(result)
    if result.id and result.id > 0 then
        GameCenter.PushFixEvent(UIEventDefine.UIWorldSupportThankForm_Open, result)
    else
        Utils.ShowPromptByEnum("WoodsCannotBeUsed")
    end
end

-- Broadcast Death Support
function WorldSupportSystem:ResDieCallHelp(result)
    self.ReqSupportData = result
    if result.player ~= nil then
        -- Death seeking help from Tongxian League members pop-up type
        -- 0: Not accepted
        -- 1: Receive the exit copy and enter the activity prompt
        -- 2: You can go directly
        if GameCenter.MapLogicSystem.MapCfg.GuildeHelpType ~= 0 then
            GameCenter.PushFixEvent(UILuaEventDefine.UIReqSupportForm_OPEN, result)
        end
    end
end

-- Enter the copy
function WorldSupportSystem:OnEnterScene()
    -- Switch the map and find the way
    if self.ReqSupportData ~= nil and self.NeedSearchPath then
        -- Help location
        local _pos = Vector2(tonumber(self.ReqSupportData.x), tonumber(self.ReqSupportData.y))
        GameCenter.PathSearchSystem:SearchPathToPos(GameCenter.MapLogicSystem.MapCfg.MapId, _pos)
        self.ReqSupportData = nil
        self.NeedSearchPath = false
    else
        -- After exiting the copy, request to enter the copy
        if self.NeedEnterCopyMap then
            -- Enter the copy
            GameCenter.DailyActivitySystem:ReqJoinActivity(_dailyId, _cloneMapId)
            self.NeedEnterCopyMap = false
            self.NeedSearchPath = true
        end
    end
end

return WorldSupportSystem
