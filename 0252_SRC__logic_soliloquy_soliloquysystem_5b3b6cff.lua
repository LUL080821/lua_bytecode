------------------------------------------------
-- Author:
-- Date: 2019-09-5
-- File: SoliloquySystem.lua
-- Module: SoliloquySystem
------------------------------------------------

local SoliloquySystem =
{
    -- Configuration table data
    TalkCfg = nil,
    -- Store data in the configuration table (condition type, {TaskLittletalk.ID, param (such as level, task ID)})
    TalkDict = nil,
}

local L_FunctionEnum =
{
    -- grade
    Level = 2,
    -- Task Finish
    Task = 3,
    -- Task Deny Do Behavior
    TaskDenyDoBehavior = 5,
}

function SoliloquySystem:Initialize()
    -- Level changes
	GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_PLAYER_LEVEL_CHANGED, self.OnLevelChanded, self);
	-- Task completion
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_TASKFINISH, self.OnTaskFinished, self);
    -- Task deny do behavior
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_TASK_DENY_DO_BEHAVIOR, self.OnTaskDenyDoBehavior, self);


    -- Analyze data
    self.TalkCfg = DataConfig.DataTaskLittletalk
    self.TalkDict = Dictionary:New()
    local _levelList = List:New()
    local _taskList = List:New()
    local _taskDenyDoBehaviorList = List:New()
    DataConfig.DataTaskLittletalk:Foreach(
        function(_key, _value)
            -- It is a level condition and reaches the corresponding level
            if _value.ConditionsValue == L_FunctionEnum.Level then
                local _param = {_value.Id, _value.ConditionsValueParam}
                _levelList:Add(_param)
            -- Task completion
            elseif _value.ConditionsValue == L_FunctionEnum.Task then
                local _param = {_value.Id, _value.ConditionsValueParam}
                _taskList:Add(_param)
            -- Task refusal behavior
            elseif _value.ConditionsValue == L_FunctionEnum.TaskDenyDoBehavior then
                local _param = {_value.Id, _value.ConditionsValueParam}
                _taskDenyDoBehaviorList:Add(_param)
            end
        end
    )
    self.TalkDict:Add(L_FunctionEnum.Level, _levelList)
    self.TalkDict:Add(L_FunctionEnum.Task, _taskList)
    self.TalkDict:Add(L_FunctionEnum.TaskDenyDoBehavior, _taskDenyDoBehaviorList)
end

function SoliloquySystem:UnInitialize()
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_PLAYER_LEVEL_CHANGED, self.OnLevelChanded, self);
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_TASKFINISH, self.OnTaskFinished, self);
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_TASK_DENY_DO_BEHAVIOR, self.OnTaskDenyDoBehavior, self);
    self.TalkDict:Clear()
end

function SoliloquySystem:OnLevelChanded(obj, sender)
    if obj ~= nil then
        local _funcType = L_FunctionEnum.Level
        self:PushMsg(obj, _funcType)
	end
end

function SoliloquySystem:OnTaskFinished(obj, sender)
    if obj ~= nil then
        local _funcType = L_FunctionEnum.Task
        self:PushMsg(obj, _funcType)
	end
end

function SoliloquySystem:OnTaskDenyDoBehavior(obj, sender)
    if obj ~= nil then
        local _funcType = L_FunctionEnum.TaskDenyDoBehavior
        self:PushMsg(obj, _funcType)
    end
end

-- Open the interface according to data and type
function SoliloquySystem:PushMsg(obj, funcType)
    if obj ~= nil then
        if self.TalkDict:ContainsKey(funcType) then
            local _list = self.TalkDict[funcType]
            for i = 1, #_list do
                local _valuePram = _list[i][2]
                if tonumber(_valuePram) == tonumber(obj) then
                    local _cfgId = _list[i][1]
                    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.Soliloquy, _cfgId)
                    break
                end
            end
        end
	end
end

return SoliloquySystem