------------------------------------------------
--author:
--Date: 2021-03-12
--File: UITargetForm.lua
--Module: UITargetForm
--Description: Target interface
------------------------------------------------
local UIListMenu = require "UI.Components.UIListMenu.UIListMenu"
local L_UIAnimDelayPlayer = require "UI.Components.UIAnimDelayPlayer"

local UITargetForm = {
    ListTopMenu = nil,
    Scroll = nil,
    Grid = nil,
    Temp = nil,
    CloseBtn = nil,
    RewardBtn = nil,
    StepTitle = nil,
    Huan = nil,
    Item = nil,
    ItemName = nil,
    RewardGrid = nil,
    RewardList = List:New(),
    TargetNum = nil,
    LeftTex = nil,
    BgTex = nil,
    TiShi = nil,
    Vfx1 = nil,
    RedPoint = nil,
    CurTabId = 0,
    RewardCount = 3,
    AnimTime = 1,
    AnimTick = 0,
    AnimStart = 0,
    AnimEnd = 0,
    IsShowAnim = false,
    Min = 0.16,
    Max = 0.84,
    HuanTick = 0,
    CmpList = List:New(),
    RewardItems = List:New(),

    LeftTrans = nil,
}

function UITargetForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UITargetForm_OPEN, self.OnOpen, self)
    self:RegisterEvent(UIEventDefine.UITargetForm_CLOSE, self.OnClose, self)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_TASKCHANG, self.OnTaskChange, self)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_TASKTARGET_UPDATE, self.OnStepChange, self)
    self:RegisterEvent(LogicEventDefine.EVENT_COIN_CHANGE_UPDATE, self.OnItemChanged, self)
end

local L_TargetItem = nil
function UITargetForm:OnFirstShow()
    local _trans = self.Trans
    self.ListTopMenu = UIListMenu:OnFirstShow(self.CSForm, UIUtils.FindTrans(_trans, "Top/UIListMenuTop"))
    self.ListTopMenu:AddIcon(TargetTaskDefine.All, DataConfig.DataMessageString.Get("C_TAGET_QUANBU"), 0)
    self.ListTopMenu:AddIcon(TargetTaskDefine.JianLing, DataConfig.DataMessageString.Get("C_JJ_JIANLING"), 0)
    self.ListTopMenu:AddIcon(TargetTaskDefine.EquipGrowth, DataConfig.DataMessageString.Get("C_ZHUANGBEI_YANGCHENG"), 0)
    self.ListTopMenu:AddIcon(TargetTaskDefine.RoleGrowth, DataConfig.DataMessageString.Get("C_JUESE_CHENGZHANG"), 0)
    self.ListTopMenu:AddIcon(TargetTaskDefine.MountAndPet, DataConfig.DataMessageString.Get("C_QICHON_ZAOHUA"), 0)
    self.ListTopMenu:AddIcon(TargetTaskDefine.Other, DataConfig.DataMessageString.Get("C_QITA"), 0)
    self.ListTopMenu:AddSelectEvent(Utils.Handler(self.OnMenuSelect, self))
    self.Scroll = UIUtils.FindScrollView(_trans, "Right/Scroll")
    self.Grid = UIUtils.FindGrid(_trans, "Right/Scroll/Grid")
    self.Temp = nil
    self.CmpList:Clear()
    local _parentTrans = self.Grid.transform
    local _childCount = _parentTrans.childCount
    for i = 1, _childCount do
        local _child = _parentTrans:GetChild(i - 1)
        self.CmpList:Add(L_TargetItem:New(_child))
        if self.Temp == nil then
            self.Temp = _child.gameObject
        end
    end
    self.CloseBtn = UIUtils.FindBtn(_trans, "CloseBtn")
    self.RewardBtn = UIUtils.FindBtn(_trans, "Left/Reward")
    self.RewardSpr = UIUtils.FindSpr(_trans, "Left/Reward")
    self.StepTitle = UIUtils.FindLabel(_trans, "Left/Title/Label")
    self.Huan = UIUtils.FindSpr(_trans, "Left/Haun")
    self.Item = UILuaItem:New(UIUtils.FindTrans(_trans, "Left/UIItem"))
    self.ItemName = UIUtils.FindLabel(_trans, "Left/ItemName")
    self.RewardGrid = UIUtils.FindGrid(_trans, "Left/Grid")
    self.RewardList:Clear()
    for i = 1, self.RewardCount do
        local _path = string.format("Left/Grid/UIItem_%d", i - 1)
        local _item = UILuaItem:New(UIUtils.FindTrans(_trans, _path))
        self.RewardList:Add(_item)
    end
    self.TargetNum = UIUtils.FindLabel(_trans, "Left/TargetNum")
    self.LeftTex = UIUtils.FindTex(_trans, "Left/LeftTex")
    self.BgTex = UIUtils.FindTex(_trans, "Center/Texture")
    self.TiShi = UIUtils.FindGo(_trans, "Center/TiShi")
    self.TiShi:SetActive(false)
    self.RedPoint = UIUtils.FindGo(_trans, "Left/Reward/RedPoint")
    self.Vfx1 = UIUtils.RequireUIVfxSkinCompoent(UIUtils.FindTrans(_trans, "Left/Vfx_1"))
    self.Huan.gameObject:SetActive(false)
    UIUtils.AddBtnEvent(self.CloseBtn, self.OnClickCloseBtn, self)
    UIUtils.AddBtnEvent(self.RewardBtn, self.OnClickRewardBtn, self)
    self.AnimPlayer = L_UIAnimDelayPlayer:New(self.CSForm.AnimModule)
    self.LeftTrans = UIUtils.FindTrans(_trans, "Left")
    self.CSForm:AddAlphaPosAnimation(self.LeftTrans, 0, 1, 0, -30, 0.3, false, false)
end

function UITargetForm:OnShowAfter()
    self.AnimTick = self.AnimTime
    self.IsShowAnim = false
    self.Huan.gameObject:SetActive(false)
    self.ListTopMenu:SetSelectById(TargetTaskDefine.All)
    self.CSForm:LoadTexture(self.LeftTex, ImageTypeCode.UI, "tex_n_d_109", Utils.Handler(self.LoadTexCallBack, self))
    self.CSForm:LoadTexture(self.BgTex, ImageTypeCode.UI, "tex_n_d_1_2")
    local _cfg = DataConfig.DataTaskTargetReward[GameCenter.TargetSystem.StepCfgId]
    if _cfg == nil then
        return
    end
    local _haveNum = GameCenter.ItemContianerSystem:GetEconomyWithType(ItemTypeCode.WorldLevelScore)
    if _haveNum >= _cfg.NeedNum then
        self.Huan.fillAmount = 1
        self.RewardSpr.spriteName = "n_a_02";
    else
        self.Huan.fillAmount = self.Min + (self.Max - self.Min) * (_haveNum / _cfg.NeedNum)
        self.RewardSpr.spriteName = "n_a_01_1";
    end
    self.HuanTick = 0.5
    self:SetStep(false)
end

function UITargetForm:OnHideBefore()
    self.ListTopMenu:SetSelectByIndex(-1)
    self.Vfx1:OnDestory()
    self.Huan.gameObject:SetActive(false)
end

function UITargetForm:OnOpen(obj, sender)
    self.CSForm:Show(sender)
end

function UITargetForm:OnClose(obj, sender)
    self.CSForm:Hide()
end

function UITargetForm:OnTaskChange(obj, sender)
    --Refresh the interface task
    self:SetTaskArea(self.CurTabId, true, false)
end

function UITargetForm:OnStepChange(isLv, sender)
    self:SetStep(isLv)
end

function UITargetForm:OnItemChanged(itemId, sender)
    if itemId == ItemTypeCode.WorldLevelScore then
        self:SetStep(false)
    end
end

function UITargetForm:LoadTexCallBack(info)
    -- self.Huan.gameObject:SetActive(true) -- hoang edit, chuc nang nhiem vu ngay
    self.Huan.gameObject:SetActive(false)
end

--Click the Close button on the interface
function UITargetForm:OnClickCloseBtn()
    self:OnClose(nil, nil)
end

--Click to collect
function UITargetForm:OnClickRewardBtn()
    local _cfg = DataConfig.DataTaskTargetReward[GameCenter.TargetSystem.StepCfgId]
    if _cfg == nil then
        return
    end
    local _haveNum = GameCenter.ItemContianerSystem:GetEconomyWithType(ItemTypeCode.WorldLevelScore)
    if _haveNum >= _cfg.NeedNum then
        GameCenter.TargetSystem:ReqGetTarget()
        self.RewardSpr.spriteName = "n_a_01_1";
    else
        Utils.ShowPromptByEnum("C_MUBIAODIANBUZHU")
    end
    GameCenter.BISystem:ReqClickEvent(BiIdCode.TargetSystemReceive)
end

function UITargetForm:OnMenuSelect(id, b)
    if b then
        self:OpenSubForm(id)
    else
        self:CloseSubForm(id)
    end
end

function UITargetForm:OpenSubForm(id)
    self.CurTabId = id
    self:SetTaskArea(id, true, true)
end

function UITargetForm:CloseSubForm(id)
end

function UITargetForm:SetStep(isLv)
    if isLv then
        --If the upgrade is successful
        GameCenter.PushFixEvent(UIEventDefine.UIWelfareGetItemForm_OPEN, self.RewardItems)
    end
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    local _cfg = DataConfig.DataTaskTargetReward[GameCenter.TargetSystem.StepCfgId]
    if _cfg == nil then
        return
    end
    UIUtils.SetTextByStringDefinesID(self.StepTitle, _cfg._Stage)
    --Set props
    self.RewardItems:Clear()
    local _rewardTable = Utils.SplitStrByTableS(_cfg.Reward, {';', '_'})
    local _occ = _lp.IntOcc
    local _index = 1
    for i = 1, #_rewardTable do
        local _item = _rewardTable[i]
        if _item[4] == _occ or _item[4] == 9 then
            if _index == 1 then
                self.Item:InItWithCfgid(_item[1], _item[2], _item[3] ~= 0)
                local _itemCfg = DataConfig.DataItem[_item[1]]
                if _itemCfg ~= nil then
                    UIUtils.SetTextByStringDefinesID(self.ItemName, _itemCfg._Name)
                end
            elseif (_index - 1) <= #self.RewardList then
                self.RewardList[_index - 1].RootGO:SetActive(true)
                self.RewardList[_index - 1]:InItWithCfgid(_item[1], _item[2], _item[3] ~= 0)
            end
            _index = _index + 1
            self.RewardItems:Add({Id = _item[1], Num = _item[2], IsBind = _item[3] ~= 0})
        end
    end
    for i = _index - 1, #self.RewardList do
        self.RewardList[i].RootGO:SetActive(false)
    end
    --Set the target value
    local _haveNum = GameCenter.ItemContianerSystem:GetEconomyWithType(ItemTypeCode.WorldLevelScore)
    UIUtils.SetTextByEnum(self.TargetNum, "C_MUBIAOZHI", _haveNum, _cfg.NeedNum)
    self.Huan.fillAmount = self.Min + (self.Max - self.Min) * (_haveNum / _cfg.NeedNum)--_haveNum / _cfg.NeedNum
    self.RedPoint:SetActive(_haveNum >= _cfg.NeedNum)
    if isLv then
        self.AnimTick = 0
        self.AnimStart = self.Min
        if _haveNum >= _cfg.NeedNum then
            self.AnimEnd = self.Max
        else
            self.AnimEnd = self.Min + (self.Max - self.Min) * _haveNum / _cfg.NeedNum
        end
        self.IsShowAnim = true
        self.Vfx1:OnDestory()
    else
        if _haveNum >= _cfg.NeedNum then
            self.Vfx1:OnCreateAndPlay(ModelTypeCode.UIVFX, 111, LayerUtils.AresUI)
        end
    end
    self.RewardGrid.repositionNow = true
end

function UITargetForm:SetTaskArea(type, isForceReset, playAnim)
    if isForceReset == nil then
        isForceReset = false
    end
    --Get pagination data
    local _list = GameCenter.TargetSystem:GetTargets(type);
    if _list == nil then
        return
    end
    local _animList = nil
    if playAnim then
        _animList = List:New()
        self.AnimPlayer:Stop()
    end
    --Set tasks
    local _index = 1
    local _listCount = #_list
    for i = 1, _listCount do
        local _taskData = _list[i]
        local _item = nil
        if _index <= #self.CmpList then
            _item = self.CmpList[_index]
        else
            local _go = UnityUtils.Clone(self.Temp)
            _item = L_TargetItem:New(_go.transform, self)
            self.CmpList:Add(_item)
        end
        if not self.AnimPlayer.Playing then
            _item.Go:SetActive(true)
        end
        _item:SetCmp(_taskData, isForceReset)
        _index = _index + 1
        if playAnim then
            _animList:Add(_item.Trans)
        end
    end
    for i = _index, #self.CmpList do
        self.CmpList[i].Go:SetActive(false)
    end
    self.Grid:Reposition()
    if isForceReset then
        -- Force refresh scroll and grid
        self.Scroll:ResetPosition()
    end
    if playAnim then
        for i = 1, #_animList do
            self.CSForm:RemoveTransAnimation(_animList[i])
            self.CSForm:AddAlphaPosAnimation(_animList[i], 0, 1, 0, 50, 0.2, false, false)
            self.AnimPlayer:AddTrans(_animList[i], (i - 1) * 0.1)
        end
        --self.AnimPlayer:AddTrans(self.LeftTrans, 0)
        self.AnimPlayer:Play()
    end

    self.TiShi:SetActive(_index <= 1)
    --Set red dots
    local _redPointArray = GameCenter.TargetSystem:GetRedPointArray()
    self.ListTopMenu:SetRedPoint(TargetTaskDefine.All, _redPointArray[TargetTaskDefine.All] == true)
    self.ListTopMenu:SetRedPoint(TargetTaskDefine.JianLing, _redPointArray[TargetTaskDefine.JianLing] == true)
    self.ListTopMenu:SetRedPoint(TargetTaskDefine.EquipGrowth, _redPointArray[TargetTaskDefine.EquipGrowth] == true)
    self.ListTopMenu:SetRedPoint(TargetTaskDefine.RoleGrowth, _redPointArray[TargetTaskDefine.RoleGrowth] == true)
    self.ListTopMenu:SetRedPoint(TargetTaskDefine.MountAndPet, _redPointArray[TargetTaskDefine.MountAndPet] == true)
    self.ListTopMenu:SetRedPoint(TargetTaskDefine.Other, _redPointArray[TargetTaskDefine.Other] == true)
end

function UITargetForm:Update(dt)
    self.AnimPlayer:Update(dt)
    if self.IsShowAnim then
        if self.AnimTick < self.AnimTime then
            self.Huan.fillAmount = math.Lerp(self.AnimStart, self.AnimEnd, self.AnimTick / self.AnimTime)
            self.AnimTick = self.AnimTick + dt
        else
            self.Huan.fillAmount = self.AnimEnd
            if self.AnimEnd == self.Max then
                self.Vfx1:OnCreateAndPlay(ModelTypeCode.UIVFX, 111, LayerUtils.AresUI)
            end
            self.AnimTick = self.AnimTime
            self.AnimStart = 0
            self.AnimEnd = 0
            self.IsShowAnim = false
        end
    end
    -- if self.HuanTick > 0 then
    --     self.HuanTick = self.HuanTick - dt
    --     if self.HuanTick <= 0 then
    --         self.HuanTick = 0
    --         self.Huan.gameObject:SetActive(true)
    --     end
    -- end
end

local L_BtnSpr1 = "n_a_03"
local L_BtnSpr2 = "n_a_04"
L_TargetItem = {
    TaskID = 0,
    ItemList = List:New(),
    Parent = nil,
    Trans = nil,
    Go = nil,
    Des = nil,
    Scroll = nil,
    Grid = nil,
    Temp = nil,
    Btn = nil,
    BtnSpr = nil,
    BtnName = nil,
    RedPoint = nil,
}

function L_TargetItem:New(trans, parent)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m.Parent = parent
    _m.Des = UIUtils.FindLabel(trans, "Des")
    _m.Scroll = UIUtils.FindScrollView(trans, "ItemScroll")
    _m.Grid = UIUtils.FindGrid(trans, "ItemScroll/ItemGrid")
    _m.Temp = nil
    _m.ItemList:Clear()
    local _parentTrans = _m.Grid.transform
    local _childCount = _parentTrans.childCount
    for i = 1, _childCount do
        local _child = _parentTrans:GetChild(i - 1)
        if _m.Temp == nil then
            _m.Temp = _child.gameObject
        end
        _m.ItemList:Add(UILuaItem:New(_child))
    end
    _m.Btn = UIUtils.FindBtn(trans, "Btn")
    _m.BtnSpr = UIUtils.FindSpr(trans, "Btn/Sprite")
    _m.BtnName = UIUtils.FindLabel(trans, "Btn/Name")
    _m.RedPoint = UIUtils.FindGo(trans, "Btn/RedPoint")
    UIUtils.AddBtnEvent(_m.Btn, _m.OnClickBtn, _m)
    _m.Go:SetActive(false)
    return _m
end

--Set components
function L_TargetItem:SetCmp(taskData, isForceReset)
    if isForceReset == nil then
        isForceReset = false
    end
    self.TaskID = taskData.Id
    --Set the target description
    local _behaviour = GameCenter.LuaTaskManager:GetBehavior(self.TaskID)
    if _behaviour ~= nil then
        UIUtils.SetTextByString(self.Des, _behaviour.Des)
    end
    --Set the target reward props
    local _index = 1
    local _reward = taskData.RewardList
    local _rewardCount = #_reward
    for i = 1, _rewardCount do
        local _rewardData = _reward[i]
        local _item = nil
        if i <= #self.ItemList then
            _item = self.ItemList[i]
        else
            local _go = UnityUtils.Clone(self.Temp)
            _item = UILuaItem:New(_go.transform)
            self.ItemList:Add(_item)
        end
        _item:InItWithCfgid(_rewardData.ID, _rewardData.Num, _rewardData.IsBind)
        _item.RootGO:SetActive(true)
        _index = _index + 1
    end
    for i = _index, #self.ItemList do
        self.ItemList[i].RootGO:SetActive(false)
    end
    self.RedPoint.gameObject:SetActive(false)
    --Set the function button name
    self.BtnSpr.spriteName = L_BtnSpr1

    -- hoang custom, chuc nang nhiem vu ngay, neu dung tag liên quan thi open lai
    -- if GameCenter.LuaTaskManager:CanSubmitTask(self.TaskID) then
    --     if _behaviour.Type ~= TaskBeHaviorType.Talk then
    --         UIUtils.SetTextByEnum(self.BtnName, "C_TARGET_LINGQU")
    --         UIUtils.SetColor(self.BtnName, 162 /255, 105 / 255, 53 / 255, 1)
    --         self.BtnSpr.spriteName = L_BtnSpr2
    --         self.RedPoint.gameObject:SetActive(true)
    --     else
    --         UIUtils.SetTextByEnum(self.BtnName, "C_TARGET_QIANWANG")
    --         UIUtils.SetColor(self.BtnName, 39 /255, 76 / 255, 137 / 255, 1)
    --     end
    -- else
    --     UIUtils.SetTextByEnum(self.BtnName, "C_TARGET_QIANWANG")
    --     UIUtils.SetColor(self.BtnName, 39 /255, 76 / 255, 137 / 255, 1)
    -- end
    self.Grid:Reposition()
    if isForceReset then
        self.Scroll:ResetPosition()
    end
end

--Function button click
function L_TargetItem:OnClickBtn()
    if GameCenter.LuaTaskManager:CanSubmitTask(self.TaskID) then
        local _behaviour = GameCenter.LuaTaskManager:GetBehavior(self.TaskID)
        if _behaviour ~= nil then
            if _behaviour.Type == TaskBeHaviorType.Talk then
                GameCenter.TaskController:Run(self.TaskID, true)
                GameCenter.PushFixEvent(UIEventDefine.UIDailyActivityForm_CLOSE)
            else
                --Submit task
                GameCenter.LuaTaskManager:SubMitTask(self.TaskID)
                self.Parent.RewardSpr.spriteName = "n_a_02";
            end
        end
    else
        GameCenter.TaskController:Run(self.TaskID, true)
        GameCenter.PushFixEvent(UIEventDefine.UIDailyActivityForm_CLOSE)
    end

end

return UITargetForm