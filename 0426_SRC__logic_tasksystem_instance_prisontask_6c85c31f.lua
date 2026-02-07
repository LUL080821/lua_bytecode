------------------------------------------------
-- Author: Wang Sheng
-- Date: 2021-03-19
-- File: BranchTask.lua
-- Module: BranchTask
-- Description: Side Task Example
------------------------------------------------
-- Quote
local L_RecommendData = require "Logic.TaskSystem.Data.TaskRecommendData"
local L_TaskBase = require "Logic.TaskSystem.Instance.TaskBase"
local PrisonTask = {
    ChuanDaoLimitData = nil,
}

function PrisonTask:New(info)
    local _m = Utils.Extend(L_TaskBase:New(), self)
    _m:SetTask(info)
    return _m
end

function PrisonTask:SetTask(info)
    local _cfg = DataConfig.DataTaskPrison[info.modelId]
    if _cfg == nil then
        Debug.LogError("PrisonTask Id Is Error " .. tostring(info.modelId));
        return
    end
    local _isTransport = false
    if _cfg.IsTransport == 0 then
        _isTransport = true
    else
        _isTransport = false
    end
    self.Data:SetData(info.modelId, TaskType.Prison, 0, self:GetSubmitNpcId(info.modelId), true, _cfg.Type, _cfg.TaskName,
        _cfg.Taksdesc, nil, _cfg.Rewards, info.useItems.mapId, _cfg.Equip, _cfg.Show, _isTransport)
    self.Data.TypeName = _cfg.TapeName
    self.Data.IconId = _cfg.PromptIcon
    self.Data.PromptStr = _cfg.PromptText
    self.Data.Chapter_Name = _cfg.ChapterName
    self.Data.Chapter_Des = _cfg.ChapterDesc
    self.Data.OtherActionId = _cfg.Flyteleport
    self.Data.Cfg = _cfg
    self.IsShowGuide = _cfg.IsShowPrompt > 0

    GameCenter.LuaTaskManager:AddTask(self)
    local _behavior = GameCenter.LuaTaskManager:CreateBehavior(_cfg.Type, info.modelId)
    if _behavior == nil then
        Debug.LogError("Creation behavior failed");
        return
    end
    _behavior.Id = info.modelId
    GameCenter.LuaTaskManager:SetBehaviorTag(info.useItems.model, info.useItems.needNum, info.useItems.talkId,
        info.useItems.xPos, info.useItems.yPos, info.useItems.itemId, info.useItems.type, _behavior)
    _behavior.Type = _cfg.Type
    _behavior.TaskTarget.Count = info.useItems.num
    GameCenter.LuaTaskManager:AddBehavior(info.modelId, _behavior)
    _behavior:SetTargetDes()
    self.Data.TargetDes = _behavior.Des
    GameCenter.LuaTaskManager.CurSelectTaskID = info.modelId
    if self:CanAutoRun() then
        _behavior:DoBehavior()
    else
        if GameCenter.LuaTaskManager.IsAutoPrisonTask then
            GameCenter.TaskController:Pause()
        end
    end
    -- Prison tasks need to be added to the task controller in advance
    GameCenter.TaskController:SetRunTimeTask(self)
    self:SetRecommendDes()
end

function PrisonTask:OnCanAutoRun()
    local _ret = false
    local _isAuto = false
    if self.Data.Cfg.IsAuto == 0 then
        _isAuto = true
    else
        _isAuto = false
    end
    if GameCenter.LuaTaskManager.IsAutoPrisonTask and not GameCenter.BlockingUpPromptSystem:IsRunning() and _isAuto then
        if not GameCenter.LuaTaskManager.IsSuspend then
            _ret = true
        end
    end
    return _ret
end

function PrisonTask:OnGetSubmitNpcId(id)
    local _ret = 0
    local _cfg = DataConfig.DataTaskPrison[id]
    if _cfg ~= nil then
        local _list = Utils.SplitNumber(_cfg.Endpath, '_')
        if _list ~= nil and #_list == 2 then
            _ret = _list[2]
        end
    end
    return _ret
end

function PrisonTask:OnUpdateTask(behavior)
    self:UpdateTargetDes()
end

function PrisonTask:OnGetTaskTarget(id)
    local _ret = ""
    local _cfg = DataConfig.DataTaskPrison[id]
    if _cfg ~= nil then
        _ret = _cfg.Target
    end
    return _ret
end

function PrisonTask:OnGetTaskXZ(id)
    local _ret = ""
    local _cfg = DataConfig.DataTaskPrison[id]
    if _cfg ~= nil then
        _ret = _cfg.TaskXZ
    end
    return _ret
end

function PrisonTask:OnGetActionName()
    return self.Data.Cfg.Animation
end

function PrisonTask:OnGetMovePos()
    local _ret = Vector3.zero
    local _list = Utils.SplitNumber(self.Data.Cfg.Move, '_')
    if #_list >= 2 then
        local _x = _list[1]
        local _z = _list[2]
        _ret = Vector3(_x, 0, _z)
    end
    return _ret
end

function PrisonTask:OnGetPlanShowEnter(id)
    local _ret = ""
    local _cfg = DataConfig.DataTaskPrison[id]
    if _cfg ~= nil then
        _ret = _cfg.PlanesShowEnter
    end
    return _ret
end

function PrisonTask:OnGetNewType()
    return self.Data.Cfg.TargetType
end

function PrisonTask:OnGetUIDes(count, tCount)
    local _ret = ""
    if self:GetVariable() == 1 then
        _ret = UIUtils.CSFormat(self.Data.Cfg.ConditionsDescribe, CommonUtils.GetLevelDesc(count), CommonUtils.GetLevelDesc(tCount))
    else
        _ret = UIUtils.CSFormat(self.Data.Cfg.ConditionsDescribe, count, tCount)
    end
    return _ret
end

function PrisonTask:OnSubMitTaskOpenPanel()
    return self.Data.Cfg.OverTaskFunction
end

function PrisonTask:GetChuanDaoLimitData()
    if self.ChuanDaoLimitData == nil then
        local _gCfg = DataConfig.DataGlobal[GlobalName.task_chuandao_recommend_tips]
        local _list = Utils.SplitNumber(_gCfg.Params, '_')
        self.ChuanDaoLimitData = {Lv = _list[1], Point = _list[2]}
    end
    return self.ChuanDaoLimitData
end

function PrisonTask:OnSetRecommendDes()
    self.Data.RecommendList:Clear()
    if self.Data ~= nil then
        if self.Data.Cfg.RecommendTips ~= nil and self.Data.Cfg.RecommendTips ~= "" then
            -- Determine whether a task can be submitted
            if not GameCenter.LuaTaskManager:CanSubmitTask(self.Data.Id) then
                local _lpLevel = 0
                local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
                if _lp ~= nil then
                    _lpLevel = _lp.Level
                end
                local _activePoint = GameCenter.ItemContianerSystem:GetEconomyWithType(ItemTypeCode.ActivePoint)
                local _cdLimitData = self:GetChuanDaoLimitData()
                local _recommendIdList = List:New()
                local _strs = Utils.SplitNumber(self.Data.Cfg.RecommendTips, '_')
                local _isFind = false
                -- Priority preaching
                for i = 1, #_strs do
                    local _id = _strs[i]
                    local _cfg = DataConfig.DataTaskPrisonRecommendTips[_id]
                    if _cfg ~= nil then
                        local _data = L_RecommendData:New()
                        _data.Id = _id
                        _data.DailyId = _cfg.DailyId
                        _data.Des = _cfg.RecommendDes
                        self.Data.RecommendList:Add(_data)
                        if _data.DailyId == 2 and not _isFind and GameCenter.DailyActivitySystem:CanJoinDaily(_cfg.DailyId) then
                            if _lpLevel >= _cdLimitData.Lv and _activePoint >= _cdLimitData.Point then
                                _isFind = true
                                self.Data.PreRecommendId = _cfg.DailyId
                                self.Data.TargetDes = UIUtils.CSFormat("{0}\n{1}", self.Data.TargetDes, _cfg.RecommendDes)
                            end
                        end
                    end
                end
                if not _isFind then
                    for i = 1, #_strs do
                        local _id = _strs[i]
                        local _cfg = DataConfig.DataTaskPrisonRecommendTips[_id]
                        if _cfg ~= nil then
                            if not _isFind and GameCenter.DailyActivitySystem:CanJoinDaily(_cfg.DailyId) then
                                _isFind = true
                                self.Data.PreRecommendId = _cfg.DailyId
                                self.Data.TargetDes = UIUtils.CSFormat("{0}\n{1}", self.Data.TargetDes, _cfg.RecommendDes)
                            end
                        end
                    end
                end
                if not _isFind then
                    self.Data.PreRecommendId = 0
                    self.Data.IsRecommendChange = true
                    self.Data.TargetDes = DataConfig.DataMessageString.Get("TASK_RECOMMEND_OVER")
                end
                self.Data.IsShowRecommend = true
            else
                local _behavior = GameCenter.LuaTaskManager:GetBehavior(self.Data.Id)
                if _behavior ~= nil then
                    _behavior:SetTargetDes()
                    self.Data.TargetDes = _behavior.Des
                end
            end
        else
            self.Data.IsShowRecommend = false
        end
    end
end

function PrisonTask:OnUpdateTargetDes()
    if self.Data.Cfg.RecommendTips ~= nil and self.Data.Cfg.RecommendTips ~= "" then
        if not GameCenter.LuaTaskManager:CanSubmitTask(self.Data.Id) then
            local _isFind = false;
            -- If the task is not completed
            -- Priority to finding preachers
            local _lpLevel = 0
            local _cdLimitData = self:GetChuanDaoLimitData()
            local _activePoint = GameCenter.ItemContianerSystem:GetEconomyWithType(ItemTypeCode.ActivePoint)
            local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
            if _lp ~= nil then
                _lpLevel = _lp.Level
            end
            for i = 1, #self.Data.RecommendList do
                local _data = self.Data.RecommendList[i]
                if _data ~= nil and _data.DailyId == 2 and GameCenter.DailyActivitySystem:CanJoinDaily(_data.DailyId) then
                    if _lpLevel >= _cdLimitData.Lv and _activePoint >= _cdLimitData.Point then
                        _isFind = true;
                        if self.Data.PreRecommendId ~= _data.DailyId then
                            self.Data.IsRecommendChange = true
                        end
                        local _behavior = GameCenter.LuaTaskManager:GetBehavior(self.Data.Id)
                        if _behavior ~= nil then
                            _behavior:SetTargetDes()
                            self.Data.TargetDes = _behavior.Des
                        end
                        self.Data.TargetDes = UIUtils.CSFormat("{0}\n{1}", self.Data.TargetDes, _data.Des)
                        self.Data.PreRecommendId = _data.DailyId
                        break
                    end
                end
            end
            if not _isFind then
                for i = 1, #self.Data.RecommendList do  
                    local _data = self.Data.RecommendList[i]
                    if _data ~= nil and GameCenter.DailyActivitySystem:CanJoinDaily(_data.DailyId) then
                        _isFind = true;
                        if self.Data.PreRecommendId ~= _data.DailyId then
                            self.Data.IsRecommendChange = true
                        end
                        local _behavior = GameCenter.LuaTaskManager:GetBehavior(self.Data.Id)
                        if _behavior ~= nil then
                            _behavior:SetTargetDes()
                            self.Data.TargetDes = _behavior.Des
                        end
                        self.Data.TargetDes = UIUtils.CSFormat("{0}\n{1}", self.Data.TargetDes, _data.Des)
                        self.Data.PreRecommendId = _data.DailyId
                        break
                    end
                end
            end
            if not _isFind then
                self.Data.PreRecommendId = 0
                self.Data.IsRecommendChange = true
                self.Data.TargetDes = DataConfig.DataMessageString.Get("TASK_RECOMMEND_OVER")
            end
        else
            -- If the task is completed, it is in a submission state
            local _behavior = GameCenter.LuaTaskManager:GetBehavior(self.Data.Id)
            if _behavior ~= nil then
                _behavior:SetTargetDes()
                self.Data.TargetDes = _behavior.Des
            end
            self.Data.IsShowRecommend = false
        end
    else
        local _behavior = GameCenter.LuaTaskManager:GetBehavior(self.Data.Id)
        if _behavior ~= nil then
            _behavior:SetTargetDes()
            self.Data.TargetDes = _behavior.Des
        end
        self.Data.IsShowRecommend = false
    end
end

-- Participate in the recommended daily routine
function PrisonTask:OnJoinRecommendDaily()
    local _ret = false
    -- If the task is not completed
    if not GameCenter.LuaTaskManager:CanSubmitTask(self.Data.Id) then
        for i = 1, #self.Data.RecommendList do
            local _data = self.Data.RecommendList[i]
            if _data ~= nil and GameCenter.DailyActivitySystem:CanJoinDaily(_data.DailyId) then
                _ret = true;
                GameCenter.DailyActivitySystem:JoinActivity(_data.DailyId)
                break
            end
        end
    end
    return _ret
end

function PrisonTask:OnIsAuto()
    return self.Data.Cfg.IsAuto == 0
end

function PrisonTask:OnGetJinDuDes(count, tCount)
    local _ret = ""
    if self:GetVariable() == 1 then
        _ret = UIUtils.CSFormat(self.Data.Cfg.ConditionsDescribe, CommonUtils.GetLevelDesc(count), CommonUtils.GetLevelDesc(tCount))
    else
        _ret = UIUtils.CSFormat(self.Data.Cfg.ConditionsDescribe, count, tCount)
    end
    return _ret
end

function PrisonTask:OnIsShowRecommendUI()
    local _ret = false
    if self.Data ~= nil then
        if self.Data.Behavior == TaskBeHaviorType.OpenUI and not GameCenter.LuaTaskManager:CanSubmitTask(self.Data.Id) then
            local _list = Utils.SplitNumber(self.Data.Cfg.Target, '_')
            if _list ~= nil and #_list > 1 and _list[1] == 1 then
                _ret = true
            end
        end
    end
    return _ret
end

function PrisonTask:OnGetVariable()
    local _ret = 0
    if self.Data.Cfg ~= nil then
        local _list = Utils.SplitNumber(self.Data.Cfg.Target, '_')
        if _list ~= nil and #_list > 0 then
            _ret = _list[1]
        end
    end
    return _ret
end

function PrisonTask:OnGetFollowModel()
    local _ret = ""
    if self.Data.Cfg ~= nil then
        local _follow_model = self.Data.Cfg.FollowModel
        if _follow_model ~= nil and _follow_model ~= "" then
            _ret = _follow_model
        end
    end
    return _ret
end

return PrisonTask
