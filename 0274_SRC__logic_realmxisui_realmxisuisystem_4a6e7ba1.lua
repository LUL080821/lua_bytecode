--==============================--
-- Author:
-- Date: 2020-02-05
-- File: RealmXiSiSiSystem.lua
-- Module: RealmXiSuiSystem
-- Description: Marrow washing system
--==============================--
local L_RoleBaseAttribute = CS.Thousandto.Code.Global.RoleBaseAttribute
local RedPointItemCondition = CS.Thousandto.Code.Logic.RedPointItemCondition
local RedPointCustomCondition = CS.Thousandto.Code.Logic.RedPointCustomCondition

local RealmXiSuiSystem = {
    FrontLevel = -1,
    FrontStateLevel = -1,
    FuncNeedCons = nil,
    CurNeedItemId = nil,
    CurNeedItemCount = nil,
}

function RealmXiSuiSystem:Initialize()
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_PLAYER_BASE_ATTR_CHANGED, self.OnProChanged, self)
end

function RealmXiSuiSystem:UnInitialize()
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_PLAYER_BASE_ATTR_CHANGED, self.OnProChanged, self)
end

function RealmXiSuiSystem:OnProChanged(prop, sender)
    if prop.CurrentChangeBasePropType == L_RoleBaseAttribute.XiSuiLevel then
        self:CheckRedPoint(prop)
        GameCenter.ChangeJobSystem:OnXiSuiLevelChanged()
    end
end

function RealmXiSuiSystem:CheckRedPoint(prop)
    local _curLevel = prop.XiSuiLevel
    -- Detect red dots
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.RealmXiSui)
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.RealmXiSuiLv1)
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.RealmXiSuiLv2)
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.RealmXiSuiLv3)
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.RealmXiSuiLv4)
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.RealmXiSuiLv5)

    self.CurNeedItemId = 0
    local _needItemCfg = DataConfig.DataStateXisuiAcupoint[_curLevel + 1]
    if _needItemCfg ~= nil then
        local _itemParam = Utils.SplitNumber(_needItemCfg.ItemCost, '_')
        if #_itemParam >= 2 then
            self.CurNeedItemId = _itemParam[1]
            self.CurNeedItemCount = _itemParam[2]
            if _needItemCfg.Group == 1 then
                GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.RealmXiSuiLv1, _needItemCfg.Id, RedPointItemCondition(_itemParam[1], _itemParam[2]))
            elseif _needItemCfg.Group == 2 then
                GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.RealmXiSuiLv2, _needItemCfg.Id, RedPointItemCondition(_itemParam[1], _itemParam[2]))
            elseif _needItemCfg.Group == 3 then
                GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.RealmXiSuiLv3, _needItemCfg.Id, RedPointItemCondition(_itemParam[1], _itemParam[2]))
            elseif _needItemCfg.Group == 4 then
                GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.RealmXiSuiLv4, _needItemCfg.Id, RedPointItemCondition(_itemParam[1], _itemParam[2]))
            elseif _needItemCfg.Group == 5 then
                GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.RealmXiSuiLv5, _needItemCfg.Id, RedPointItemCondition(_itemParam[1], _itemParam[2]))
            end
        else
            -- Can complete marrow washing
            GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.RealmXiSui, 0, RedPointCustomCondition(true))
        end
    end
end

function RealmXiSuiSystem:GetXiSuiPrice()
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end
    local _curLevel = _lp.PropMoudle.XiSuiLevel
    local _curCfg = DataConfig.DataStateXisuiAcupoint[_curLevel]
    local _curDegree = 1
    if _curCfg ~= nil then
        _curDegree = _curCfg.Group
    end
    local _costMoney = 0
    local _idCounter = 1
    while(true) do
        local _tmpCfg = DataConfig.DataStateXisuiAcupoint[_idCounter]
        if _tmpCfg == nil then
            break
        else
            if _tmpCfg.Group == _curDegree then
                if _tmpCfg.Id > _curLevel then
                    local _contParam = Utils.SplitNumber(_tmpCfg.CoinCost, '_')
                    if #_contParam >= 2 then
                        _costMoney = _costMoney + _contParam[2]
                    end
                end
            elseif _tmpCfg.Group > _curDegree then
                break
            end
        end
        _idCounter = _idCounter + 1
    end

    return _costMoney
end

return RealmXiSuiSystem