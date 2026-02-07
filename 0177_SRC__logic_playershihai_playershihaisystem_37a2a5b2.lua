------------------------------------------------
-- Author:
-- Date: 2019-05-06
-- File: PlayerShiHaiSystem.lua
-- Module: PlayerShiHaiSystem
-- Description: Player Sea of Knowledge System
------------------------------------------------

local RedPointItemCondition = CS.Thousandto.Code.Logic.RedPointItemCondition
local RedPointCustomCondition = CS.Thousandto.Code.Logic.RedPointCustomCondition

local PlayerShiHaiSystem = {
    -- Current level
    CurCfgID = 0,
}

function PlayerShiHaiSystem:ResShiHaiData(msg)
    self.CurCfgID = msg.cfgId
    self:RefreshRedPointData()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_PLAYER_SHIHAI)
end

function PlayerShiHaiSystem:RefreshRedPointData()
    local _curCfg = DataConfig.DataPlayerShiHai[self.CurCfgID]
    if _curCfg == nil then
        return
    end
    -- Clear all conditions
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.PlayerJingJie)
    -- If the required Wan Yaoshu level is 0, it means full level
    if _curCfg.NeedCopyLevel ~= 0 then
        local _conditions = List:New()
        -- Item Conditions
        if string.len(_curCfg.NeedItem) > 0 then
            local _curItem = Utils.SplitStrByTableS(_curCfg.NeedItem)
            for i = 1, #_curItem do
                _conditions:Add(RedPointItemCondition(_curItem[i][1], _curItem[i][2]))
            end
        end
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if _lp then
            _conditions:Add(RedPointCustomCondition(_curCfg.NeedCopyLevel < _lp.Level))
        end
        --local _towerData = GameCenter.CopyMapSystem:FindCopyDataByType(CopyMapTypeEnum.TowerCopy)
        --if _towerData ~= nil then
        --    _conditions:Add(RedPointCustomCondition(_curCfg.NeedCopyLevel < _towerData.CurLevel))
        --end

        -- Calling the Lua special conditional interface
        GameCenter.RedPointSystem:LuaAddFuncCondition(FunctionStartIdCode.PlayerJingJie, 0, _conditions)
    end
end

function PlayerShiHaiSystem:ReqShiHaiData()
    GameCenter.Network.Send("MSG_ShiHai.ReqShiHaiData", {})
end

function PlayerShiHaiSystem:ReqLevelUP()
    GameCenter.Network.Send("MSG_ShiHai.ReqUpLevel", {})
end

return PlayerShiHaiSystem