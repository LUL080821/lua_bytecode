------------------------------------------------
-- Author: 
-- Date: 2020-12-08
-- File: FullLevelTipsSystem.lua
-- Module: FullLevelTipsSystem
-- Description: Full-level prompt system
------------------------------------------------

local FullLevelTipsSystem = {
    -- Current full-level level
    FullLevelValue = 0,
    -- Is it prompted
    ShowTips = true,
    -- The last level
    FrontLevel = -1,
}

function FullLevelTipsSystem:Initialize()
    local _gCfg = DataConfig.DataGlobal[GlobalName.PlayerMaxLevel]
    if _gCfg ~= nil then
        self.FullLevelValue = tonumber(_gCfg.Params)
    end
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_PLAYER_LEVEL_CHANGED, self.OnLevelChanged, self)
    GameCenter.RegFixEventHandle(LogicLuaEventDefine.EID_EVENT_SITDOWN_START, self.OnSitDownStart, self)
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_CHUANDAO_SITDOWN_START, self.OnSitDownStart, self)
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_USEEXP_ITEM, self.OnExpItemUse, self)
end

function FullLevelTipsSystem:UnInitialize()
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_PLAYER_LEVEL_CHANGED, self.OnLevelChanged, self)
    GameCenter.UnRegFixEventHandle(LogicLuaEventDefine.EID_EVENT_SITDOWN_START, self.OnSitDownStart, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_CHUANDAO_SITDOWN_START, self.OnSitDownStart, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_USEEXP_ITEM, self.OnExpItemUse, self)
end

-- Level Change Event
function FullLevelTipsSystem:OnLevelChanged(obj, sender)
    local _curLevel = tonumber(obj)
    if self.FrontLevel > 0 then
        self:CheckShowTips()
    end
    self.FrontLevel = _curLevel
end

-- Meditation events
function FullLevelTipsSystem:OnSitDownStart(obj, sender)
    self:CheckShowTips()
end

-- Experience Dan usage events
function FullLevelTipsSystem:OnExpItemUse(obj, sender)
    self:CheckShowTips()
end

-- Show Tips
function FullLevelTipsSystem:CheckShowTips()
    local _curLevel = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
    if _curLevel >= self.FullLevelValue and self.ShowTips then
        GameCenter.MsgPromptSystem:ShowSelectMsgBox(
            UIUtils.CSFormat( DataConfig.DataMessageString.Get("C_SERVER_MAX_LEVELASK"), CommonUtils.GetLevelDesc(self.FullLevelValue)),
            nil,
            DataConfig.DataMessageString.Get("C_MSGBOX_OK"),
            nil,
            function (select)
                self.ShowTips = (select ~= MsgBoxIsSelect.Selected)
            end,
            DataConfig.DataMessageString.Get("MASTER_BENCILOGINNOTNOTICE")
        )
    end
end

return FullLevelTipsSystem