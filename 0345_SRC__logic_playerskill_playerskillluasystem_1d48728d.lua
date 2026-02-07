------------------------------------------------
-- Author:
-- Date: 2020-10-10
-- File: PlayerSkillLuaSystem.lua
-- Module: PlayerSkillLuaSystem
-- Description: Player Skill System
------------------------------------------------

local RedPointItemCondition = CS.Thousandto.Code.Logic.RedPointItemCondition
local RedPointLevelCondition = CS.Thousandto.Code.Logic.RedPointLevelCondition
local RedPointCustomCondition = CS.Thousandto.Code.Logic.RedPointCustomCondition;

local PlayerSkillLuaSystem = {
    MeridianCheckList = nil,
}

-- initialization
function PlayerSkillLuaSystem:Initialize()
    self.MeridianCheckList = nil
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_CHECK_SKILL_REDPOINT, self.CheckRedPoint, self)
end

-- De-initialization
function PlayerSkillLuaSystem:UnInitialize()
    self.MeridianCheckList = nil
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_CHECK_SKILL_REDPOINT, self.CheckRedPoint, self)
end

-- Detect red dots
function PlayerSkillLuaSystem:CheckRedPoint(obj, sender)
    -- Detection slot red dots
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.PlayerSkillCell)
    local _cellLevel = GameCenter.PlayerSkillSystem:GetCellLevel()
    local _cfg = DataConfig.DataSkillPositionLevelup[_cellLevel]
    local _nextCfg = DataConfig.DataSkillPositionLevelup[_cellLevel + 1]
    if _cfg ~= nil and _nextCfg ~= nil then
        GameCenter.RedPointSystem:LuaAddFuncCondition(FunctionStartIdCode.PlayerSkillCell, 0, {RedPointLevelCondition(_cellLevel + 10), RedPointItemCondition(3, _cfg.Money * 10)})
    end

    -- Detect the red dot of rising stars, no normal attack
    local _notEquipList = List:New()
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.PlayerSkillStar)
    for i = 1, 20 do
        local _skillCell = GameCenter.PlayerSkillSystem:GetSkillCell(i)
        if _skillCell ~= nil then
            if not GameCenter.PlayerSkillSystem:SkillIsEquip(i) then
                _notEquipList:Add(i)
            end
            local _cfg = DataConfig.DataSkillStarLevelup[_skillCell.CfgID]
            if _cfg ~= nil and string.len(_cfg.NeedItem) > 0 then
                local _itemTable = Utils.SplitNumber(_cfg.NeedItem, '_')
                GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.PlayerSkillStar, _cfg.Id, RedPointItemCondition(_itemTable[1], _itemTable[2]))
            end
        end
    end

    -- Assembly red dots
    -- Get the number of spare grids
    local _emptyPosList = List:New()
    for i = 1, 8 do
        if GameCenter.PlayerSkillSystem:GetSkillPosCellValue(i) < 0 then
            _emptyPosList:Add(i)
        end
    end
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.PlayerSkillPos)
    if #_notEquipList > 0 and #_emptyPosList > 0 then
        for i = 1, #_notEquipList do
            GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.PlayerSkillPos, _notEquipList[i], RedPointCustomCondition(true))
        end
        for i = 1, #_emptyPosList do
            GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.PlayerSkillPos, _emptyPosList[i] * 10000, RedPointCustomCondition(true))
        end
    end
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.PlayerSkillMeridian)

    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end
    local _occ = _lp.IntOcc
    local _chanjeLevel = _lp.ChangeJobLevel
        -- Detect red dots of meridians
    if self.MeridianCheckList == nil then
        self.MeridianCheckList = {}
        local _func = function(key, value)
            if value.Occ == _occ then
                local _list = self.MeridianCheckList[value.Type]
                if _list == nil then
                    _list = List:New()
                    self.MeridianCheckList[value.Type] = _list
                end
                if not _list:Contains(value.MeridianId) then
                    _list:Add(value.MeridianId)
                end
            end
        end
        DataConfig.DataSkillMeridianNew:Foreach(_func)
    end
    local _curSelectMerId = GameCenter.PlayerSkillSystem.CurSelectMerId
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.PlayerSkillXinFa)
    if _curSelectMerId == 0 then
        -- If the meridian is not selected, the heart method will increase red dots
        GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.PlayerSkillXinFa, 0, RedPointCustomCondition(true))
    else
        -- Only after choosing the mind method is selected
        for k, v in pairs(self.MeridianCheckList) do
            local _posCfg = DataConfig.DataSkillMeridianPos[k]
            if _posCfg ~= nil then
                -- Determine whether it has been activated and belongs to the current mental method
                if _chanjeLevel >= _posCfg.ChangeJob and _posCfg.XinfaId == _curSelectMerId then
                    local _count = #v
                    for i = 1, _count do
                        local _meId = v[i]
                        local _activeId = GameCenter.PlayerSkillSystem:GetMeridianActvieID(_meId)
                        local _cfgId = 0
                        if _activeId > 0 then
                            -- Already activated
                            _cfgId = _activeId + 1
                        else
                            -- Not activated key value (profession *1000000+merid *10000+grid *1000+level)
                            _cfgId = _occ * 1000000 + k * 10000 + _meId * 100 + 1
                        end
                        local _cfg = DataConfig.DataSkillMeridianNew[_cfgId]
                        if _cfg ~= nil then
                            local _frontFinish = true
                            local _parentCfg = DataConfig.DataSkillMeridianNew[_cfg.NeedParentId]
                            if _parentCfg ~= nil then
                                -- Determine whether the pre-order is achieved
                                _activeId = GameCenter.PlayerSkillSystem:GetMeridianActvieID(_parentCfg.MeridianId)
                                if _activeId < _cfg.NeedParentId then
                                    _frontFinish = false
                                end
                            end
                            if _frontFinish then
                                local _needCfg = Utils.SplitNumber(_cfg.NeedValue, '_')
                                GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.PlayerSkillMeridian, _meId, RedPointItemCondition(_needCfg[1], _needCfg[2]))
                            end
                        end
                    end
                end
            end
        end
    end
end

function PlayerSkillLuaSystem:MeridianTypeRedPoint(type)
    local _list = self.MeridianCheckList[type]
    if _list ~= nil then
        for i = 1, #_list do
            if GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.PlayerSkillMeridian, _list[i]) then
                return true
            end
        end
    end
    return false
end

function PlayerSkillLuaSystem:GetAddSkillTable()
    local _result = {}
    local _func = function(key, value)
        if value.AddSkill > 0 then
            _result[key] = value.AddSkill
        end
    end
    DataConfig.DataSkillMeridianNew:Foreach(_func)
    return _result
end

return PlayerSkillLuaSystem