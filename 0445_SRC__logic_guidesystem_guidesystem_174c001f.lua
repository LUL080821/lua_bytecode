------------------------------------------------
-- Author:
-- Date: 2021-04-09
-- File: GuideSystem.lua
-- Module: GuideSystem
-- Description: Boot system
------------------------------------------------
local L_GuideKey = "GuideFinishKey_%d"

local GuideSystem = {
    GuideTable = nil,
    FinishList = nil,
}

function GuideSystem:Initialize()
end

function GuideSystem:UnInitialize()
    self.GuideTable = nil
    self.FinishList = nil
end


function GuideSystem:Check(type, param)
    if type == GuideTriggerType.None then
        return false
    end
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return false
    end

    if self.FinishList == nil then
        self.FinishList = List:New()
        local _finishText = PlayerPrefs.GetString(string.format(L_GuideKey, _lp.ID), nil)
        if _finishText ~= nil and string.len(_finishText) > 0 then
            local _paramsArray = Utils.SplitNumber(_finishText, '_')
            for i = 1, #_paramsArray do
                self.FinishList:Add(_paramsArray[i])
            end
        end
    end
    if self.GuideTable == nil then
        self.GuideTable = Dictionary:New()
        local _func = function(k, cfg)
            if not self.FinishList:Contains(k) then
                local _list = self.GuideTable[cfg.TriggerType]
                if _list == nil then
                    _list = List:New()
                    self.GuideTable:Add(cfg.TriggerType,  _list)
                end
                _list:Add(cfg)
            end
        end
        DataConfig.DataGuide:Foreach(_func)
    end

    local _waitCheckList = self.GuideTable[type]
    if _waitCheckList == nil then
        return false
    end

    if #_waitCheckList <= 0 then
        self.GuideTable:Remove(type)
        return false
    end

    local _lpLevel = _lp.Level
    for i = #_waitCheckList, 1, -1 do
        local _guideItem = _waitCheckList[i]
        if (_guideItem.TriggerParam == param and
            (_guideItem.LimitLevelMin <= 0 or _lpLevel >= _guideItem.LimitLevelMin) and
            (_guideItem.LimitLevelMax <= 0 or _lpLevel <= _guideItem.LimitLevelMax)) then
            GameCenter.BlockingUpPromptSystem:AddForceGuide(_guideItem)
            if _guideItem.Type == GuideForcedType.NotForced or _guideItem.Type == GuideForcedType.SceneAnim or _guideItem.Type == GuideForcedType.TimelineAnim then
                -- Non-force boot is set directly to already booted
                self:SaveGuide(_guideItem.Id)
            end
            return true
        end
    end
    return false
end

function GuideSystem:SaveGuide(guideID)
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end
    if not self.FinishList:Contains(guideID) then
        self.FinishList:Add(guideID)
        local _text = ""
        for i = 1, #self.FinishList do
            _text = _text .. self.FinishList[i]
            if i < #self.FinishList then
                _text = _text .. "_"
            end
        end
        PlayerPrefs.SetString(string.format(L_GuideKey, _lp.ID), _text)
        PlayerPrefs.Save()
    end

    for k, v in pairs(self.GuideTable) do
        for i = #v, 1, -1  do
            if v[i].Id == guideID then
                v:RemoveAt(i)
            end
        end
    end
end

return GuideSystem