------------------------------------------------
--author:
--Date: 2021-03-01
--File: UIMainTaskPanel.lua
--Module: UIMainTaskPanel
--Description: Task paging on the left side of the main interface
------------------------------------------------

local L_UIMainSubBasePanel = require "UI.Forms.UIMainForm.UIMainSubBasePanel"
local CSInput = CS.UnityEngine.Input

local UIMainTaskPanel = {
    TaskScroll = nil,
    TaskInfoRes = nil,
    TaskInfoResList = List:New(),
    FrontUpdateTaskCount = 0,
    UpdateRecommend = false,
    RecmPanel = nil,
}
--Register events
function UIMainTaskPanel:OnRegisterEvents()
    --Task Update
    self:RegisterEvent(LogicEventDefine.EID_EVENT_TASKCHANG, self.OnUpdateTask, self)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_START_FORCEGUIDE, self.StartGuide, self)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_TASK_RECOMMEND_CHANGE, self.OnUpdateRecommendTask, self)

    -- Debug.Log("UIMainTaskPanel:RegisterEvent LogicEventDefine.EID_EVENT_CLICK_MAIN_TASK = disabled")
    self:RegisterEvent(LogicEventDefine.EID_EVENT_CLICK_MAIN_TASK,self.OnEventClickMainTask,self)
end
local L_UIMainTaskItem = nil
local L_ShowRecommendTaskIds = nil

function UIMainTaskPanel:OnFirstShow(trans, parent, rootForm)
    setmetatable(self, {__index = L_UIMainSubBasePanel.New()})
    self:BaseFirstShow(trans, parent, rootForm)

    self.TaskScroll = UIUtils.FindScrollView(trans, "Scroll")
    local _rootTrans = self.TaskScroll.transform
    self.TaskInfoRes = nil
    local _count = _rootTrans.childCount
    self.TaskInfoResList:Clear()
    for i = 1, _count do
        local _go = _rootTrans:GetChild(i - 1).gameObject
        self.TaskInfoResList:Add(L_UIMainTaskItem:New(_go, self))
        if self.TaskInfoRes == nil then
            self.TaskInfoRes = _go
        end
    end
    self.RecmPanel = require "UI.Forms.UIMainForm.UIMainTaskRecommendPanel"
    self.RecmPanel:OnFirstShow(UIUtils.FindTrans(trans, "Recommend/Panel"), self, rootForm)
    L_ShowRecommendTaskIds = {}
end

function UIMainTaskPanel:OnTryHide()
    if self.RecmPanel.IsVisible then
        self.RecmPanel:Close()
        return false
    end
    return true
end

function UIMainTaskPanel:OnShowAfter()
    self.FrontUpdateTaskCount = 0
    self:OnUpdateTask(nil)
end

--Task sorting
local function L_SortTask(left, right)
    local _valueLeft = -1
    local _valueRight = 1
    local _lType = UnityUtils.GetObjct2Int(left.Data.Type)
    local _rType = UnityUtils.GetObjct2Int(right.Data.Type)
    local _lSort = DataConfig.DataTaskSort[_lType]
    local _rSort = DataConfig.DataTaskSort[_rType]
    if _lSort ~= nil and _rSort ~= nil then
        if GameCenter.LuaTaskManager:IsEndBehavior(left.Data.Id) then
            _valueLeft = _lSort.FinishValue
        else
            _valueLeft = _lSort.NotFinishValue
        end

        if GameCenter.LuaTaskManager:IsEndBehavior(right.Data.Id) then
            _valueRight = _rSort.FinishValue
        else
            _valueRight = _rSort.NotFinishValue
        end
    end

    if _valueLeft ~= _valueRight then
        return _valueLeft < _valueRight
    else
        return left:GetSort() < right:GetSort()
    end
end

--Get the task list and sort it
function UIMainTaskPanel:GetCurTaskList()
    local _result = self:GetShowedTaskList()
    if #_result > 1 then
        _result:Sort(L_SortTask)
    end
    return _result
end

--Get the list of tasks displayed on this map
function UIMainTaskPanel:GetShowedTaskList()
    local _result = List:New()
    local _typeCount = TaskType.Not_Recieve
    for i = 1, _typeCount do
        local _outList = GameCenter.LuaTaskManager.TaskContainer:FindTaskByType(i - 1)
        if _outList ~= nil then
            local _count = #_outList
            for j = 1, _count do
                local _task = _outList[j]
                if _task.Data.IsAccess then
                    _result:Add(_task)
                end
            end
        end
    end
    return _result
end
--Reset task view when starting boot
function UIMainTaskPanel:StartGuide(obj, sender)
    self.TaskScroll:ResetPosition()
end
--Update recommended tasks
function UIMainTaskPanel:OnUpdateRecommendTask(obj, sender)
    self.UpdateRecommend = true
    self:OnUpdateTask(nil)
    self.UpdateRecommend = false
end

--Update the task interface
function UIMainTaskPanel:OnUpdateTask(obj, sender)
    local _taskList = self:GetCurTaskList()
    local _startY = 79
    local _showTaskCount = #_taskList
    if _showTaskCount > 6 then
        _showTaskCount = 6
    end
    for i = 1, _showTaskCount do
        local _itemUI = nil
        if i <= #self.TaskInfoResList then
            _itemUI = self.TaskInfoResList[i]
        else
            _itemUI = L_UIMainTaskItem:New(UnityUtils.Clone(self.TaskInfoRes), self)
            self.TaskInfoResList:Add(_itemUI)
        end
        _itemUI:SetInfo(_taskList[i], self.UpdateRecommend)
        UnityUtils.SetLocalPositionY(_itemUI.RootTrans, _startY)
        _startY = _startY - (_itemUI.Height + 1)
    end
    for i = _showTaskCount + 1, #self.TaskInfoResList do
        self.TaskInfoResList[i]:SetInfo(nil, self.UpdateRecommend)
    end
    if self.FrontUpdateTaskCount ~= _showTaskCount then
        self.TaskScroll:ResetPosition()
    end
    self.FrontUpdateTaskCount = _showTaskCount
end
function UIMainTaskPanel:Update(dt)
    if not self.IsVisible then
        return
    end

    if self.DtTimer == nil then
        self.DtTimer = dt
    else
        self.DtTimer = self.DtTimer + dt
    end

    if Time.GetFrameCount() % 30 == 0 then
        for i = 1, #self.TaskInfoResList do
            self.TaskInfoResList[i]:Update(self.DtTimer)
        end
    end
end

function UIMainTaskPanel:OnEventClickMainTask(obj, sender)
    for i = 1, #self.TaskInfoResList do
        if self.TaskInfoResList[i]:IsMainTask() then
            self.TaskInfoResList[i]:OnClick()
            return
        end
    end
end

--Task UI
L_UIMainTaskItem = {
    Parent = nil,
    RootGo = nil,
    RootTrans = nil,
    Btn = nil,
    Name = nil,
    Desc = nil,
    Type = nil,
    TaskInfo = nil,
    Blink = nil,
    RootWidget = nil,
    BackSpr = nil,
    Height = 0,
    FlyBtn = nil,
    HelpBtn = nil,
    GuideText = nil,
    GuideTextGo = nil,
    SpriteAnim = nil,
    SelectEffect = nil,
    HelpFrontClickTime = 0,
    MainTaskTipsTimer = 30,
    ShowAnimTips = false,
    LightGo = nil,
    LightVfx = nil,
    FinishGo = nil,
    RecommendGo = nil,
    IsRecommendTask = false,
    --uiitem
    UIItem = nil,
}

function L_UIMainTaskItem:New(go, parent)
    local _m = Utils.DeepCopy(self)
    _m.Parent = parent
    _m.RootGo = go
    _m.RootTrans = go.transform
    local _trans = _m.RootTrans
    _m.Btn = UIUtils.FindBtn(_trans)
    UIUtils.AddBtnEvent(_m.Btn, _m.OnClick, _m)
    _m.Name = UIUtils.FindLabel(_trans, "Name")
    _m.Desc = UIUtils.FindLabel(_trans, "Desc")
    _m.Type = UIUtils.FindLabel(_trans, "Type/Value")
    _m.Blink = UIUtils.RequireUIBlinkCompoent(UIUtils.FindTrans(_trans, "UIBlinkCompoent"))
    _m.RootWidget = UIUtils.FindWid(_trans)
    _m.BackSpr = UIUtils.FindSpr(_trans, "Back")
    _m.Blink.MoveTime = 0.5
    _m.Blink.IntervalTime = 1
    _m.BlinkGo = _m.Blink.gameObject
    _m.FlyBtn = UIUtils.FindBtn(_trans, "FlyBtn")
    UIUtils.AddBtnEvent(_m.FlyBtn, _m.OnFlyBtnClick, _m)
    _m.FlyBtnGo = _m.FlyBtn.gameObject
    _m.HelpBtn = UIUtils.FindBtn(_trans, "HelpBtn")
    UIUtils.AddBtnEvent(_m.HelpBtn, _m.OnHelpBtnClick, _m)
    _m.GuideText = UIUtils.FindLabel(_trans, "GuideText")
    _m.GuideTextGo = _m.GuideText.gameObject
    _m.GuideTextGo:SetActive(false)
    _m.SpriteAnim = UIUtils.FindGo(_trans, "SpriteAnim")
    _m.SpriteAnim:SetActive(false)
    _m.SelectEffect = UIUtils.RequireUISpriteSelectEffect(UIUtils.FindTrans(_trans, "SelectEffect"))
    _m.SelectEffect.gameObject:SetActive(false)
    _m.ShowAnimTips = false
    _m.LightGo = UIUtils.FindGo(_trans, "Back/Light")
    _m.FinishGo = UIUtils.FindGo(_trans, "Finish")
    _m.RecommendGo = UIUtils.FindGo(_trans, "Recommend")
    _m.RecommendGo:SetActive(false)
    _m.UIItem = UILuaItem:New(UIUtils.FindTrans(_trans,"UIItem"))
    return _m
end
function L_UIMainTaskItem:SetInfo(taskInfo, recommend)
    self.TaskInfo = taskInfo
    if taskInfo ~= nil then
        local _taskData = taskInfo.Data
        local _taskId = _taskData.Id
        self.RootGo:SetActive(true)
        self.LightGo:SetActive(false)
        local _canTeleport = taskInfo:CanItemTeleport()
        --self.FlyBtnGo:SetActive(_canTeleport)
        self.FlyBtnGo:SetActive(false)
        local _canHelp = taskInfo:CanSupport()
        self.HelpBtn.gameObject:SetActive(_canHelp)
        UIUtils.SetTextByString(self.Type, _taskData.TypeName)
        UIUtils.SetTextByString(self.Name, string.format("[%s]", GameCenter.LuaTaskManager:GetTaskNameEx(taskInfo)))
        UIUtils.SetTextByString(self.Desc, _taskData.TargetDes)
        local _taskBef = GameCenter.LuaTaskManager:GetBehavior(_taskId)
        self.Blink.gameObject:SetActive(_taskData.Type == TaskType.Main and taskInfo.IsShowGuide)
        self.Height = self.Desc.height + 36
        if self.Blink.RootPanel ~= nil then
            self.Blink.RootPanel.baseClipRegion = Vector4(0, (74 - self.Height) / 2, 214, self.Height)
        end
        self.BackSpr.height = self.Height
        self.RootWidget.height = self.Height
        self.LightGo:SetActive(_taskData.IsShowRecommend)
        local _posY = -self.Height / 2
        UnityUtils.SetLocalPositionY(self.FlyBtn.transform, _posY+3)
        UnityUtils.SetLocalPositionY(self.HelpBtn.transform, _posY)
        UnityUtils.SetLocalPositionY(self.FinishGo.transform, _posY)
        self.RootGo.name = tostring(_taskId)
        if recommend and _taskData.IsShowRecommend then
            if self.LightVfx == nil then
                self.LightVfx = UIUtils.RequireUIVfxSkinCompoent(UIUtils.FindTrans(self.RootTrans, "UIVfxSkinCompoent"))
            end
            self.LightVfx:OnCreateAndPlay(ModelTypeCode.UIVFX, 229, LayerUtils.AresUI)
        end
        local _finishPos = self.FinishGo.transform.localPosition
        local _isFinish = not GameCenter.LuaTaskManager:IsTalkToNpcTask(_taskId) and GameCenter.LuaTaskManager:CanSubmitTask(_taskId)
        self.FinishGo:SetActive(_isFinish)
        if _isFinish then
            UnityUtils.SetLocalPositionX(self.FlyBtn.transform, _finishPos.x + 64)
        else
            UnityUtils.SetLocalPositionX(self.FlyBtn.transform, _finishPos.x)
        end
        self.IsRecommendTask = false
        if self.TaskInfo.IsShowRecommendUI ~= nil then
            self.IsRecommendTask = self.TaskInfo:IsShowRecommendUI()
        end
        if self.IsRecommendTask then
            local _isShow = L_ShowRecommendTaskIds[_taskId]
            if _isShow == nil then
                local _lpLevel = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
                if _lpLevel >= 170 and _lpLevel <= 300 then
                    L_ShowRecommendTaskIds[_taskId] = true
                    _isShow = true
                else
                    L_ShowRecommendTaskIds[_taskId] = false
                    _isShow = false
                end
            end
            self.RecommendGo:SetActive(_isShow)
        else
            self.RecommendGo:SetActive(false)
        end
		local _rewCount = #_taskData.RewardList
            
        local _taskType = _taskData.Type
        local id = 1;
        if _taskType == TaskType.Main then
            id = 3
        elseif _taskType == TaskType.ZhuanZhi then
            -- if _rewCount > 0 nil then
            --     id = _taskData.RewardList[1].ID
            -- end
        elseif _taskType == TaskType.Guild then
            id = 3
        elseif _taskType == TaskType.Branch then
            id = 12
        elseif _taskType == TaskType.Prison then
            id = 3
        end     
        self.UIItem:InItWithCfgid(id,1) 
    else
        self.RootGo:SetActive(false)
        self.Height = 0
        self.RootGo.name = "TaskItem"
        self.IsRecommendTask = false
    end
    self:Update(0)
end
function L_UIMainTaskItem:Update(dt)
    if self.TaskInfo == nil then
        return
    end
    if self.BlinkGo.activeSelf ~= self.TaskInfo.IsShowGuide then
        self.BlinkGo:SetActive(self.TaskInfo.IsShowGuide)
    end
    if self.SpriteAnim.activeSelf ~= (self.TaskInfo.IsShowGuide or self.ShowAnimTips) then
        self.SpriteAnim:SetActive(self.TaskInfo.IsShowGuide or self.ShowAnimTips)
    end
    local _showItemTeleport = self.TaskInfo:CanItemTeleport()
    if self.FlyBtnGo.activeSelf ~= _showItemTeleport then
        --self.FlyBtnGo:SetActive(_showItemTeleport)
        self.FlyBtnGo:SetActive(false)
    end

    if self.TaskInfo.Data.Type == TaskType.Main then
        if not self.SpriteAnim.activeSelf then
            local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
            if _lp.Level < 120 and CSInput.touchCount <= 0 and
                not GameCenter.MandateSystem:IsRunning() and
                not _lp:IsMoving() and
                GameCenter.MapLogicSystem.MapCfg ~= nil and
                GameCenter.MapLogicSystem.MapCfg == 0 then
                self.MainTaskTipsTimer = self.MainTaskTipsTimer - dt
                if self.MainTaskTipsTimer <= 0 then
                    self.MainTaskTipsTimer = 30
                    self.ShowAnimTips = true
                end
            else
                self.MainTaskTipsTimer = 30
            end
        end
    end

    if self.IsRecommendTask then
    end
end
function L_UIMainTaskItem:OnClick()
    if self.TaskInfo ~= nil then
        if self.TaskInfo.IsShowRecommendUI ~= nil and self.TaskInfo:IsShowRecommendUI() then
            self.Parent.RecmPanel:Open()
            L_ShowRecommendTaskIds[self.TaskInfo.Data.Id] = false
            self.RecommendGo:SetActive(false)
        else
            GameCenter.TaskController:Run(self.TaskInfo.Data.Id, true)
            -- local _scene = GameCenter.GameSceneSystem.ActivedScene
            -- self.CameraControl = _scene.SceneCameraControl
            -- if self.CameraControl ~= nil then
            --     self.CameraControl.EnableRotate = true
            -- end
        end
    end
    self.ShowAnimTips = false
end
function L_UIMainTaskItem:OnFlyBtnClick()
    if self.TaskInfo ~= nil then
        self.TaskInfo:DoItemTeleport()
    end
end
function L_UIMainTaskItem:OnHelpBtnClick()
    if Time.GetRealtimeSinceStartup() - self.HelpFrontClickTime < 1 then
        Utils.ShowPromptByEnum("C_UI_CLICK_TIPS")
        return
    end
    self.HelpFrontClickTime = Time.GetRealtimeSinceStartup()
    GameCenter.Network.Send("MSG_WorldHelp.ReqGuildTaskHelp")
end

function L_UIMainTaskItem:IsMainTask()
    if self.TaskInfo ~= nil then
        return self.TaskInfo.Data.Type == TaskType.Main
    end
    return false;
end

return UIMainTaskPanel