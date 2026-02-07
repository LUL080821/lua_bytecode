------------------------------------------------
-- Author:
-- Date: 2021-06-15
-- File: FlySwordGraveSystem.lua
-- Module: FlySwordGraveSystem
-- Description: Sword Tomb System
------------------------------------------------
local L_RedPointVariableCondition = CS.Thousandto.Code.Logic.RedPointVariableCondition
local  FlySwordGraveSystem = {
    CfgDic = nil,
    StateDic = nil,
    CurSwordId = 1,
    CurSwordState = 0,
    NeedOpenID = 0,
}

function FlySwordGraveSystem:Initialize()
    self.StateDic = Dictionary:New()
    self.CfgDic = Dictionary:New()
    DataConfig.DataFlySwordGrave:Foreach(function(k, v)
        self.CfgDic:Add(k, v)
    end)
end
function FlySwordGraveSystem:UnInitialize()
    self.StateDic:Clear()
    self.CfgDic:Clear()
    self.NeedOpenID = 0
end

-- Get the name, passing 0 means getting the data to be activated
function FlySwordGraveSystem:GetSwordName(id)
    if (id <= 0) then
        id = self.CurSwordId;
    end
    local _cfg = nil;
    if (self.CfgDic:ContainsKey(id)) then
        _cfg = self.CfgDic[id];
    end
    if _cfg then
        return _cfg.Name;
    end
    return "";
end

-- Get the configuration table information, passing 0 means getting the data to be activated
function FlySwordGraveSystem:GetSwordCfg(id)
    if (id <= 0) then
        id = self.CurSwordId;
    end
    local _cfg = nil;
    if (self.CfgDic:ContainsKey(id)) then
        _cfg = self.CfgDic[id];
    end
    if _cfg then
        return _cfg;
    end
    return nil;
end

function FlySwordGraveSystem:GetSwordState(id)
    if (id <= 0) then
        id = self.CurSwordId;
    end
    if (self.StateDic:ContainsKey(id)) then
        return self.StateDic[id];
    end
    return 0;
end

function FlySwordGraveSystem:SetCurid()
    self.CfgDic:ForeachCanBreak(function(k, v)
        if self.StateDic:ContainsKey(k) then
            self.CurSwordId =k;
            self.CurSwordState = self.StateDic[k];
            if self.StateDic[k] ~= 2 then
                return true
            end
        else
            return true;
        end
    end)
end

function FlySwordGraveSystem:SetRed()
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.FlySwordGrave);
    self.StateDic:ForeachCanBreak(function(id, state)
        local _cfg = nil;
        if self.CfgDic:ContainsKey(id) then
            _cfg = self.CfgDic[id];
        end
        if (_cfg and state ~= 2) then
            GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.FlySwordGrave, id, L_RedPointVariableCondition(_cfg.Condition));
            return true
        end
    end)
end

-- Return information
function FlySwordGraveSystem:ResSwordTomb(msg)
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.FlySwordGrave);
    if msg.id and msg.state then
        local _isRea = false
        for i = 1, #msg.id do
            if #msg.state >= i then
                if (self.StateDic:ContainsKey(msg.id[i])) then
                    self.StateDic[msg.id[i]] = msg.state[i];
                else
                    self.StateDic:Add(msg.id[i], msg.state[i]);
                end
                local _cfg = nil;
                if (self.CfgDic:ContainsKey(msg.id[i])) then
                    _cfg = self.CfgDic[msg.id[i]];
                end
                if (_cfg and msg.state[i] ~= 2) and not _isRea then
                    GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.FlySwordGrave, msg.id[i], L_RedPointVariableCondition(_cfg.Condition));
                    _isRea = true
                end
            end
        end
    end
    self:SetCurid()
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_UPDATE_FLYSWORDGRAVE)
end
function FlySwordGraveSystem:ResSwordTombChange(id, state)
    GameCenter.RedPointSystem:RemoveFuncCondition(FunctionStartIdCode.FlySwordGrave, id);
    if (self.StateDic:ContainsKey(id)) then
        self.StateDic[id] = state;
    else
        self.StateDic:Add(id, state);
    end

    local _cfg = nil;
    if (self.CfgDic:ContainsKey(id)) then
        _cfg = self.CfgDic[id];
    end
    if (state == 1 and _cfg and _cfg.Type == 1) then
        self.NeedOpenID = id;
    end
    self:SetRed()
    self:SetCurid();
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_UPDATE_FLYSWORDGRAVE, id);
end
return FlySwordGraveSystem
