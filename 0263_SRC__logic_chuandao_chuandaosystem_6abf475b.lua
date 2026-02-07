
------------------------------------------------
-- Author:
-- Date: 2019-11-8
-- File: ChuanDaoSystem.lua
-- Module: ChuanDaoSystem
-- Description: Missionary System
------------------------------------------------
-- Quote
local ChuanDaoSystem = {
    -- Current Available Activeness
    ActivePoint = 0,
    -- Pre-calculated target player level
    PreCalTarLevel = 0,
    -- Precalculated target player level percentage
    PreCalTarLevelPer = 0,
    -- Increase experience
    PreCalAddExp = 0,
    -- Precalculated level waiting frame count
    PreCalWaitFrame = 0,
    -- The last precalculated activity level
    PreCallActivePoint = nil,
}

-- initialization
function ChuanDaoSystem:Initialize()
    GameCenter.RegFixEventHandle(LogicEventDefine.EVENT_COIN_CHANGE_UPDATE, self.CoinChange, self)
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_PLAYER_LEVEL_CHANGED, self.OnPlayerLevelChanged, self)
end

function ChuanDaoSystem:UnInitialize()
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EVENT_COIN_CHANGE_UPDATE, self.CoinChange, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_PLAYER_LEVEL_CHANGED, self.OnPlayerLevelChanged, self)
end

function ChuanDaoSystem:CoinChange(obj, sender)
    if obj == ItemTypeCode.ActivePoint then
        self.PreCalWaitFrame = 2
    end
end

function ChuanDaoSystem:OnPlayerLevelChanged(obj, sender)
    self.PreCalWaitFrame = 2
end

-- Pre-calculate the level that players can achieve
function ChuanDaoSystem:PreCalculateLevel()
    local _point = GameCenter.ItemContianerSystem:GetEconomyWithType(ItemTypeCode.ActivePoint)
    if self.PreCallActivePoint == _point and _point <= 0 then
        return
    end
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end
    -- VIP Experience Bonus
    local _expRate = 1
    if GameCenter.VipSystem:BaoZhuIsOpen() then
        _expRate = _expRate + GameCenter.VipSystem:GetCurVipPowerParam(39) / 100
    end
    if GameCenter.MainFunctionSystem:FunctionIsEnabled(FunctionStartIdCode.CrazySat) then
        -- Saturday Carnival Experience Bonus
        _expRate = _expRate + 1
    end
    local _startLevel = _lp.Level
    local _startExp = _lp.PropMoudle.Exp
    local _levelCfg = DataConfig.DataCharacters[_startLevel]
    self.PreCalAddExp = 0
    if _startExp >= _levelCfg.Exp then
        -- Card level status
        self.PreCalTarLevel = _startLevel
        -- May exceed the long limit
        --self.PreCalTarLevelPer = (_point * _levelCfg.LeaderPreachAward + _startExp) / _levelCfg.Exp
        self.PreCalAddExp = _point * _levelCfg.LeaderPreachAward * _expRate
        -- Prevent overcaps
        self.PreCalTarLevelPer = _levelCfg.LeaderPreachAward / _levelCfg.Exp * _point + _startExp / _levelCfg.Exp
    else
        local _fullLevel = false
        for i = 1, _point do
            local _addExp = _levelCfg.LeaderPreachAward * _expRate
            _startExp = _startExp + _addExp
            self.PreCalAddExp = self.PreCalAddExp + _addExp
            if _startExp >= _levelCfg.Exp then
                -- upgrade
                _startLevel = _startLevel + 1
                _startExp = _startExp - _levelCfg.Exp
                _levelCfg = DataConfig.DataCharacters[_startLevel]
                if _levelCfg == nil then
                    -- Full level
                    _fullLevel = true
                    break
                end
            end
        end
        if _fullLevel then
            self.PreCalTarLevel = _startLevel - 1
            self.PreCalTarLevelPer = 1
        else
            self.PreCalTarLevel = _startLevel
            self.PreCalTarLevelPer = _startExp / _levelCfg.Exp
        end
    end
    self.PreCallActivePoint = _point
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_CHUANDAOTIPS)
end

-- Players enter the preaching
function ChuanDaoSystem:EnterTeach(mapId, pos, type)
    local lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if lp  ~= nil then
        lp:Action_FindPos(mapId,pos,type)
    end
end

-- Players exit the preaching
function ChuanDaoSystem:LeaveTeach()
    -- Send messages leaving the ministry
	GameCenter.Network.Send("MSG_Dailyactive.ReqLeaveLeaderPreach")
end

function ChuanDaoSystem:Update(dt)
    if self.PreCalWaitFrame > 0 then
        self.PreCalWaitFrame = self.PreCalWaitFrame - 1
        if self.PreCalWaitFrame <= 0 then
            self:PreCalculateLevel()
            self.PreCalWaitFrame = 60
        end
    end
end

--=====================================msg=====================================
-- Preaching settlement
function ChuanDaoSystem:ResLeaderReward(msg)
    if msg == nil then
        return
    end
    local data = {Exp = msg.addExp, Level = msg.changeLevel, Point = msg.decActivePoint}
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_CHUANDAO_RESULT,data)
end

return ChuanDaoSystem