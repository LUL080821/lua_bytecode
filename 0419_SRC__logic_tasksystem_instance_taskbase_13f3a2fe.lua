------------------------------------------------
-- Author: Wang Sheng
-- Date: 2021-03-19
-- File: LuaTestTask.lua
-- Module: LuaTestTask
-- Description: Lua test task instance
------------------------------------------------
-- Quote
local L_MapPosition = CS.Thousandto.Code.Logic.MapPathInfo.Position;
local L_TaskBD_TargetType = CS.Thousandto.Code.Logic.LocalPlayerBT.TaskBD.TaskTargetType
local L_Data = require "Logic.TaskSystem.Data.TaskBaseData"
local TaskBase = {
    IsShowGuide = false, -- Whether to display boot
    Finish = false, -- Whether the task is completed
    Data = nil -- Task data
}
function TaskBase:New()
    local _m = Utils.DeepCopy(self)
    _m.Data = L_Data:New()
    return Utils.DeepCopy(_m)
end

-- Accept the task
function TaskBase:AccessTask()
    if self.OnAccessTask ~= nil then
        self:OnAccessTask()
    else
        PlayerBT.Task:TaskTalkToNpc(self.Data.AccessNpcID, self.Data.Id)
    end
end

-- Whether to display the recommended UI
function TaskBase:IsShowRecommendUI()
    local _ret = false
    if self.OnIsShowRecommendUI ~= nil then
        _ret = self:OnIsShowRecommendUI()
    end
    return _ret
end

-- Is it possible to deliver
function TaskBase:CanItemTeleport()
    if self.Data.CanItemTeleport ~= nil then
        return self.Data.CanItemTeleport
    end
    local _ret = false
    if self.Data.Type == TaskType.Guild or self.Data.Type == TaskType.Branch then
        _ret = false
    else
        local _behavior = GameCenter.LuaTaskManager:GetBehavior(self.Data.Id);
        if _behavior ~= nil then
            if self.Data.Type == TaskType.Daily then
                local _dailyTask = self;
                if _dailyTask.DailyData ~= nil then
                    if GameCenter.LuaTaskManager:CanSubmitTask(self.Data.Id) then
                        if _dailyTask.DailyData.CurStep > _dailyTask.DailyData.AllStep then
                            _ret = true;
                        else
                            _ret = false;
                        end
                    else
                        if _dailyTask.DailyData.Cfg.DailySubtype ~= 2 then
                            _ret = true;
                        end
                    end
                end
            elseif self.Data.Type == TaskType.DailyPrison then
                local _dailyPrisonTask = self;
                if _dailyPrisonTask.DailyPrisonData ~= nil then
                    if GameCenter.LuaTaskManager:CanSubmitTask(self.Data.Id) then
                        if _dailyPrisonTask.DailyPrisonData.CurStep > _dailyPrisonTask.DailyPrisonData.AllStep then
                            _ret = true;
                        else
                            _ret = false;
                        end
                    else
                        if _dailyPrisonTask.DailyPrisonData.Cfg.DailyPrisonSubtype ~= 2 then
                            _ret = true;
                        end
                    end
                end
            elseif self.Data.Type == TaskType.NewBranch then
                if _behavior.Type == TaskBeHaviorType.Kill then
                    _ret = true;
                else
                    if (GameCenter.LuaTaskManager.CanSubmitTask(Data.Id)) then
                        _ret = true;
                    else
                        _ret = false;
                    end
                end
            end
            if _behavior.Type == TaskBeHaviorType.Talk or _behavior.Type == TaskBeHaviorType.Collection or
                _behavior.Type == TaskBeHaviorType.Kill or _behavior.Type == TaskBeHaviorType.ArrivePos or
                _behavior.Type == TaskBeHaviorType.CollectItem or _behavior.Type == TaskBeHaviorType.CollectRealItem or
                _behavior.Type == TaskBeHaviorType.ArrivePosEx or _behavior.Type == TaskBeHaviorType.ArriveToAnim then

                if _behavior.Type == TaskBeHaviorType.ArrivePosEx or _behavior.Type == TaskBeHaviorType.ArriveToAnim then
                    if GameCenter.MapLogicSystem.MapCfg ~= nil and GameCenter.MapLogicSystem.MapCfg.Type ==
                        UnityUtils.GetObjct2Int(MapTypeDef.PlanCopy) then
                        _ret = false;
                    else
                        _ret = true;
                    end
                end
                _ret = true;
            elseif _behavior.Type == TaskBeHaviorType.Level or _behavior.Type == TaskBeHaviorType.PassCopy then
                if GameCenter.LuaTaskManager:CanSubmitTask(self.Data.Id) then
                    _ret = true;
                end
            end
        end
    end
    self.Data.CanItemTeleport = _ret
    return _ret
end

-- Whether it can be transmitted, subclass implementation
function TaskBase:CanItemTeleportEffect()
    local _ret = false
    if self:CanItemTeleport() then
        if self.Data.Type == TaskType.Main or self.Data.Type == TaskType.Prison then
            -- if task.MainTaskData ~= nil then
            -- end
            -- return task.MainTaskData.Cfg.IsFly == 1 ? true : false;
            _ret = self:IsFly()
        elseif self.Data.Type == TaskType.Daily then
            local _lv = GameCenter.GameSceneSystem:GetLocalPlayerLevel();
            if _lv >= 55 and _lv <= 100 then
                _ret = true;
            end
        end
    end
    return _ret;
end

function TaskBase:IsFly()
    local _ret = false
    if self.OnIsFly ~= nil then
        _ret = self:OnIsFly()
    end
    return _ret
end

-- Set the target description
function TaskBase:SetRecommendDes()
    self.Data.PreRecommendId = 0;
    self.Data.IsShowRecommend = false;
    self.Data.IsRecommendChange = false;
    if self.OnSetRecommendDes ~= nil then
        self:OnSetRecommendDes()
    end
    if self.Data.IsShowRecommend then
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_TASK_RECOMMEND_CHANGE);
    end
end

-- Update the recommended target description
function TaskBase:UpdateTargetDes()
    if self.OnUpdateTargetDes ~= nil then
        self:OnUpdateTargetDes()
    end
    -- If the target changes, push the target change message
    if self.Data.IsShowRecommend and self.Data.IsRecommendChange then
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_TASK_RECOMMEND_CHANGE)
        self.Data.IsRecommendChange = false;
    end
end

-- Perform recommendation daily
function TaskBase:JoinRecommendDaily()
    local _ret = true
    if self.OnJoinRecommendDaily ~= nil then
        _ret = self:OnJoinRecommendDaily()
    end
    return _ret;
end

function TaskBase:GetAccessNpcId(id)
    local _ret = 0
    if self.OnGetAccessNpcId ~= nil then
        _ret = self:OnGetAccessNpcId(id)
    else
        _ret = self.Data.AccessNpcID
    end
    return _ret
end

-- Obtain task targets
function TaskBase:GetTaskTarget(id)
    local _ret = ""
    if self.OnGetTaskTarget ~= nil then
        _ret = self:OnGetTaskTarget(id)
    end
    return _ret;
end

function TaskBase:GetTaskXZ(id)
    local _ret = ""
    if self.OnGetTaskXZ ~= nil then
        _ret = self:OnGetTaskXZ(id)
    end
    return _ret;
end

function TaskBase:GetTargetId()
    local _ret = 0;
    if self.OnGetTargetId then
        _ret = self:OnGetTargetId()
    end
    return _ret
end

-- Get the action clip name
function TaskBase:GetActionName()
    local _ret = ""
    if self.OnGetActionName then
        _ret = self:OnGetActionName()
    end
    return _ret;
end

-- Get the moving target point
function TaskBase:GetMovePos()
    local _ret = nil;
    if self.OnGetMovePos then
        _ret = self:OnGetMovePos()
    end
    return _ret
end

-- Get the effect parameters of the entry plane
function TaskBase:GetPlanShowEnter(id)
    local _ret = ""
    if self.OnGetPlanShowEnter then
        _ret = self:OnGetPlanShowEnter(id)
    end
    return _ret;
end

-- Get new type
function TaskBase:GetNewType()
    local _ret = 0;
    if self.OnGetNewType then
        _ret = self:OnGetNewType()
    end
    return _ret;
end

function TaskBase:GetSubmitNpcId(id)
    local _ret = 0
    if self.OnGetSubmitNpcId ~= nil then
        _ret = self:OnGetSubmitNpcId(id)
    else
        _ret = self.Data.SubmitNpcID
    end
    return _ret
end

-- Is it possible to support
function TaskBase:CanSupport()
    local _ret = false
    if self.OnCanSupport then
        _ret = self:OnCanSupport()
    end
    return _ret
end

function TaskBase:GetUIDes(count, tCount)
    local _ret = ""
    if self.OnGetUIDes then
        _ret = self:OnGetUIDes(count, tCount)
    end
    return _ret
end

function TaskBase:IsAuto()
    local _ret = false
    if self.OnIsAuto then
        _ret = self:OnIsAuto()
    end
    return _ret
end

-- Obtain combat power limit
function TaskBase:GetLimitPower()
    local _ret = 0
    if self.OnGetLimitPower then
        _ret = self:OnGetLimitPower()
    end
    return _ret
end

function TaskBase:SetIgnoLimit(b)
    self.Data.IsIgnoLimit = b
end

function TaskBase:GetIgnoLimit()
    return self.Data.IsIgnoLimit
end

-- Get a progress description
function TaskBase:GetJinDuDes()
    local _ret = "";
    local _taskBehavior = GameCenter.LuaTaskManager:GetBehavior(self.Data.Id);
    if _taskBehavior ~= nil then
        if self.OnGetJinDuDes then
            _ret = self:OnGetJinDuDes(_taskBehavior.TaskTarget.Count, _taskBehavior.TaskTarget.TCount);
        end
    end
    return _ret;
end

-- Get sorted values
function TaskBase:GetSort()
    local _ret = 0
    if self.OnGetSort then
        _ret = self:OnGetSort()
    end
    return _ret
end

-- Is it possible to execute automatically
function TaskBase:CanAutoRun()
    local _ret = false
    if self.OnCanAutoRun then
        _ret = self:OnCanAutoRun()
    end
    return _ret
end

-- Update task data
function TaskBase:UpdateTask(behaivor)
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_TASKBASE_UPDATED, self.Data.Id);
    if behaivor ~= nil and behaivor.Type == TaskBeHaviorType.Collection then
        local lp = GameCenter.GameSceneSystem:GetLocalPlayer();
        if lp ~= nil then
            PlayerBT.Collect.Count = behaivor.TaskTarget.Count;
        end
    end
    if self.OnUpdateTask ~= nil then
        self:OnUpdateTask(behaivor)
    end
end

-- The interface id that can be opened after submitting the task
function TaskBase:SubMitTaskOpenPanel()
    local _ret = 0;
    if self.OnSubMitTaskOpenPanel then
        _ret = self:OnSubMitTaskOpenPanel()
    end
    return _ret;
end

function TaskBase:GetVariable()
    local _ret = 0
    if self.OnGetVariable then
        _ret = self:OnGetVariable()
    end
    return _ret
end

function TaskBase:GetFollowModel()
    local _ret = ""
    if self.OnGetFollowModel then
        _ret = self:OnGetFollowModel()
    end
    return _ret
end

-- Perform fly shoes delivery
function TaskBase:DoItemTeleport()
    if self.IsShowGuide then
        self.IsShowGuide = false;
    end
    local lp = GameCenter.GameSceneSystem:GetLocalPlayer();
    if lp == nil then
        return;
    end
    if not lp:CanItemTeleport() then
        GameCenter.MsgPromptSystem:ShowPrompt(DataConfig.DataMessageString.Get("C_TASK_CANNOTTELEPORT"));
        return;
    end
    local _flyItemNum = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(GameCenter.LuaTaskManager.FlyItemId);
    if _flyItemNum < 1 then
        if lp.VipLevel < GameCenter.LuaTaskManager.FlyVip then
            Utils.ShowPromptByEnum("C_XIAOFEIXIE_FREE_OPEN", GameCenter.LuaTaskManager.FlyVip)
            return
        end
        if not GameCenter.VipSystem:BaoZhuIsOpen() then
            Utils.ShowPromptByEnum("C_WANLIXUE_NEED_SXL")
            return
        end
    end
    local _behavior = GameCenter.LuaTaskManager:GetBehavior(self.Data.Id)
    if _behavior == nil then
        return
    end
    local _pos = nil;
    local _type = L_TaskBD_TargetType.Undefine;
    if not GameCenter.LuaTaskManager:CanSubmitTask(self.Data.Id) then
        if _behavior.Type == TaskBeHaviorType.Talk or _behavior.Type == TaskBeHaviorType.PassCopy then
            _type = L_TaskBD_TargetType.TalkToNpc;
        elseif _behavior.Type == TaskBeHaviorType.CollectItem or _behavior.Type == TaskBeHaviorType.CollectRealItem or
            _behavior.Type == TaskBeHaviorType.Kill then
            _type = L_TaskBD_TargetType.HitMonster;
        elseif _behavior.Type == TaskBeHaviorType.Collection then
            _type = L_TaskBD_TargetType.Collect;
        elseif _behavior.Type == TaskBeHaviorType.ArrivePos then
            _type = L_TaskBD_TargetType.ArrivePos;
        elseif _behavior.Type == TaskBeHaviorType.ArrivePosEx then
            _type = L_TaskBD_TargetType.ArrivePosEx;
        elseif _behavior.Type == TaskBeHaviorType.ArriveToAnim then
            _type = L_TaskBD_TargetType.ArriveToAnim;
        end
        if _type == L_TaskBD_TargetType.ArrivePos then
            _pos = {
                MapId = self.Data.MapId,
                X = _behavior.TaskTarget.PosX,
                Z = _behavior.TaskTarget.PosY
            };
        elseif _type == L_TaskBD_TargetType.ArrivePosEx or _type == L_TaskBD_TargetType.ArriveToAnim then
            _pos = {
                MapId = self.Data.MapId,
                X = _behavior.TaskTarget.PosX,
                Z = _behavior.TaskTarget.PosY
            };
        else
            if _type == L_TaskBD_TargetType.TalkToNpc then
                if self.Data.Type == TaskType.DailyTask then
                    local _paramList = LogicAdaptor.GetTaskMapPosParams(UnityUtils.GetObjct2Int(_type), self:GetTargetId())
                    if _paramList ~= nil then
                        _pos = {
                            MapId = math.floor( _paramList[0] ),
                            X = _paramList[1],
                            Z = _paramList[2]
                        };
                    end
                else
                    local _paramList = LogicAdaptor.GetTaskMapPosParams(UnityUtils.GetObjct2Int(_type), _behavior.TaskTarget.TagId)
                    if _paramList ~= nil then
                        _pos = {
                            MapId = math.floor( _paramList[0] ),
                            X = _paramList[1],
                            Z = _paramList[2]
                        };
                    end
                end
            elseif _type == L_TaskBD_TargetType.HitMonster then
                if _behavior.Type == TaskBeHaviorType.CollectItem or _behavior.Type == TaskBeHaviorType.CollectRealItem then
                    local _paramList = LogicAdaptor.GetTaskMapPosParams(UnityUtils.GetObjct2Int(_type), _behavior.TaskTarget.Param)
                    if _paramList ~= nil then
                        _pos = {
                            MapId = math.floor( _paramList[0] ),
                            X = _paramList[1],
                            Z = _paramList[2]
                        };
                    end
                else
                    local _paramList = LogicAdaptor.GetTaskMapPosParams(UnityUtils.GetObjct2Int(_type), _behavior.TaskTarget.TagId)
                    if _paramList ~= nil then
                        _pos = {
                            MapId = math.floor( _paramList[0] ),
                            X = _paramList[1],
                            Z = _paramList[2]
                        };
                    end
                end
            else
                local _paramList = LogicAdaptor.GetTaskMapPosParams(UnityUtils.GetObjct2Int(_type), _behavior.TaskTarget.TagId)
                if _paramList ~= nil then
                    _pos = {
                        MapId = math.floor( _paramList[0] ),
                        X = _paramList[1],
                        Z = _paramList[2]
                    };
                end
            end
        end
    else
        local _paramList = LogicAdaptor.GetTaskMapPosParams(UnityUtils.GetObjct2Int(L_TaskBD_TargetType.TalkToNpc), self.Data.SubmitNpcID)
        if _paramList ~= nil then
            _pos = {
                MapId = math.floor( _paramList[0] ),
                X = _paramList[1],
                Z = _paramList[2]
            };
        end
    end

    if _pos == nil then
        return;
    end
    -- Let the protagonist get off the horse first
    lp:MountDown();
    -- Send a delivery message
    GameCenter.Network.Send("MSG_Map.ReqTransportControl", {
        type = 2,
        x = _pos.X,
        y = _pos.Z,
        mapID = _pos.MapId,
        param = 0
    })
    GameCenter.LuaTaskManager.CurSelectTaskID = self.Data.Id;
    GameCenter.LuaTaskManager.IsAutoTaskForTransPort = true;
    if _pos.MapId ~= GameCenter.GameSceneSystem:GetActivedMapID() then
        -- Use small flying shoes across maps
        GameCenter.LuaTaskManager.IsLocalUserTeleport = false;
    else
        GameCenter.LuaTaskManager.IsLocalUserTeleport = true;
    end
end

return TaskBase
