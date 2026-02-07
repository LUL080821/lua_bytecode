------------------------------------------------
-- Author:
-- Date: 2019-07-02
-- File: StateMachine.lua
-- Module: StateMachine
-- Description: State machine class
------------------------------------------------

local StateMachine = {
    -- State Machine Owner
    Owner = nil,
    -- Configuration information
    Config = nil,
    -- Previous status
    PreState = nil,
    -- Current status
    CurState = nil,
    -- Parameters of the previous state
    PreParam = nil,
    -- Current parameters
    CurParam = nil,
    -- Method name cache
    FuncNameCache = nil,
    -- Configuration id
    ConfigId = nil,
    -- Current status update function (can be nil)
    StateUpdateFunc = nil,
}

function StateMachine:New(owner, configId)
    local _t = Utils.DeepCopy(self);
    _t:SetOwner(owner);
    if configId then
        _t:SetConfig(configId);
    end

    return _t;
end

function StateMachine:SetOwner(owner)
    self.Owner = owner;
end

function StateMachine:SetConfig(configId)
    self:Clear();
    if not self.Owner or not configId or configId == -1 then
        return;
    end
    self.ConfigId = configId;
    self.ID = self.Owner.ID;
    local _cfgPath = string.format("Config.AI.%s",configId);
    -- Removal is for easy debugging
    Utils.RemoveRequiredByName(_cfgPath);
    local _cfg = require(_cfgPath);
    self.Config = Utils.DeepCopy(_cfg);
    self.Config.Owner = self.Owner;
    self.Config.ChangeState = function(cfg, cfgState, cfgParam)
        self:ChangeState(cfgState, cfgParam);
    end

    self.Config:Init();
end

function StateMachine:GetFunc(state, funcName)
    if not self.FuncNameCache[state] then
        self.FuncNameCache[state] = {};
    end
    if not self.FuncNameCache[state][funcName] then
        self.FuncNameCache[state][funcName] = string.format("On_%s_%s", state, funcName);
    end
    return self.Config[self.FuncNameCache[state][funcName]];
end

function StateMachine:GetCurState()
    return self.CurState;
end

function StateMachine:GetOwner()
    return self.Owner;
end

-- Change the state
function StateMachine:ChangeState(State, param)
    if self.CurState == State then
        return
    end
    local _checkFunc = self:GetFunc(State,"Check");
    if State and (not _checkFunc or _checkFunc and _checkFunc(self.Config, self.PreState, self.PreParam)) then
        self.PreState = self.CurState;
        self.PreParam = self.CurParam;
        if self.PreState then
            local _exitFunc = self:GetFunc(self.PreState,"Exit");
            if _exitFunc then
                _exitFunc(self.Config);
            end
        end
        self.CurState = State;
        self.CurParam = param;
        self.Config.CurState = State;
        self.Config.CurParam = param;

        local _enterFunc = self:GetFunc(State,"Enter");
        if _enterFunc then
            _enterFunc(self.Config);
        end
        self.StateUpdateFunc = self:GetFunc(State, "Update");
        return true;
    end
    return false;
end

-- Restore the previous state
function StateMachine:RevertState()
    if self.PreState then
        self:ChangeState(self.PreState, self.PreParam);
    end
end

-- Determine the current status
function StateMachine:IsState(State)
    return self.CurState == State;
end

-- renew
function StateMachine:Update()
    if not self.Config then
        return;
    end
    if self.CurState then
        if self.StateUpdateFunc  then
            self.StateUpdateFunc (self.Config);
        end
    end

    self.Config:Update();
end

-- Processing messages
function StateMachine:PushEvent(args)
    if self.Config then
        self.Config:Event(args);
    end
end

-- Clean up status
function StateMachine:Clear()
    self.CurState = nil;
    self.PreState = nil;
    self.PreParam = nil;
    self.CurParam = nil;
    self.ConfigId = nil;
    self.Config = nil;
    self.StateUpdateFunc = nil;
    self.FuncNameCache = {};
end

return StateMachine;