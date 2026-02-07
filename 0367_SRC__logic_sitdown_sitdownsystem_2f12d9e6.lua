------------------------------------------------
-- Author: 
-- Date: 2021-02-22
-- File: SitDownSystem.lua
-- Module: SitDownSystem
-- Description: Meditation system
------------------------------------------------

local SitDownSystem = {
    -- Meditation start time
    SitDownStartTime = 0,
    -- Increased experience during meditation Total value
    TotalExp = 0,
    -- Experience addition percentage, percentage value Example 150%, value 150
    CurExpAddRate = 0,
}

-- Request to start meditation
function SitDownSystem:ReqStartSitDown()
    local _mapCfg =  GameCenter.MapLogicSystem.MapCfg
    if _mapCfg == nil then
        return
    end

    if _mapCfg.MapExp == 1 then
        Utils.ShowPromptByEnum("C_EXPCOPY_CANNOT_SITDOWN")
        return
    end

    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp ~= nil and _lp.IsOnMount then
        -- Determine whether you can meditate on a mount
        local _mountId = _lp.Skin:GetSkinPartCfgID(FSkinPartCode.Mount)
        local _cfg = DataConfig.DataHuaxingHorse[_mountId]
        local _doMountDown = true
        if _cfg ~= nill and _cfg.CanSitDown ~= 0 then
            _doMountDown = false
        end
        if _doMountDown then
            _lp:MountDown()
        end
    end
    GameCenter.Network.Send("MSG_Hook.ReqStartSitDown", {})
end

-- Request to end meditation
function SitDownSystem:ReqEndSitDown()
    GameCenter.Network.Send("MSG_Hook.ReqEndSitDown", {})
end

-- Return to the message of starting meditation
function SitDownSystem:ResStartSitDown(result)
    if result.canSitDown then
        local _player = GameCenter.GameSceneSystem:FindPlayer(result.roleId)
        if _player ~= nil then
            _player:Action_SitDown();
            -- If the character is meditating, open the panel to gain experience
            if _player:IsLocalPlayer() then
                self.SitDownStartTime = GameCenter.HeartSystem.ServerTime
                GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SITDOWN_START)
            end
        end
    end
end

-- Synchronized experience value and floating word x are synchronized once in seconds. x is controlled by the configuration table (the synchronization frequency of experience map and meditation is different, global table: 1480, 1481)
function SitDownSystem:ResSyncExpAdd(result)
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end
    self.TotalExp = self.TotalExp + result.addExp
    self.CurExpAddRate = result.rate
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SHOWEXP_UPDATE, result.addExp)
end

-- Return to the end of meditation
function SitDownSystem:ResEndSitDown(result)
    if result.success then
        local _player = GameCenter.GameSceneSystem:FindPlayer(result.roleId)
        if _player ~= nil then
            if _player.IsSitDown then
                _player:Stop_Action()
            end
            if _player:IsLocalPlayer() then
                self.SitDownStartTime = 0
                self.TotalExp = 0
                GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SITDOWN_END)
            end
        end
    end
end

return SitDownSystem