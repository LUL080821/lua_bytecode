------------------------------------------------
-- author:
-- Date: 2019-04-22
-- File: UIActivityRoot.lua
-- Module: UIActivityRoot
-- Description: Activity Root
------------------------------------------------
local UIActivityItem = require "UI.Forms.UIDailyActivityForm.Item.UIActivityItem"

local UILimitRoot = {
    -- Owner
    Owner = nil,
    -- Trans
    Trans = nil,
    Go = nil,
    -- Event item Trans
    Item = nil,
    -- Activity item parent
    ListPanel = nil,
    ListProgress = nil,
    ScrollCompTrans = nil,

    ------------------------------------------------
    IconSpr = nil,
    NameLabel = nil,
    NumLabel = nil,
    TeamDescLabel = nil,
    ActivityGiftLabel = nil,
    OpenTiemLabel = nil,
    ConditionDesLabel = nil,
    DesLabel = nil,
    ------------------------------------------------
}

local L_FuncItem = nil;

function UILimitRoot:New(owner, trans)
    local _m = Utils.DeepCopy(self)
    _m.Owner = owner
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m:FindAllComponents()
    _m:Close()
    return _m
end

function UILimitRoot:FindAllComponents()
    self.Item = UIUtils.FindTrans(self.Trans, "ListPanel/Grid/Item")
    self.TfGrid = UIUtils.FindTrans(self.Trans, "ListPanel/Grid")
    self.Grid = UIUtils.FindGrid(self.Trans, "ListPanel/Grid")
    self.ScrollCompTrans = UIUtils.FindTrans(self.Trans, "ListPanel")
    self.ItemHeight = self.Grid.cellHeight;
    self.Panel = UIUtils.FindPanel(self.Trans, "ListPanel")
    self.ScrollView = UIUtils.FindScrollView(self.Trans, "ListPanel")
    self.ScrollViewHeight = self.Panel:GetViewSize().y
    self.ListProgress = self.ScrollView.verticalScrollBar

    -- self.ItemList = List:New();
    -- for i = 0, self.TfGrid.childCount - 1 do
    --     self.ItemList:Add(UIActivityItem:New(self.TfGrid:GetChild(i)));
    -- end
    -- self.GobjUIItemBase = self.ItemList[1].Gobj;

    ------------------------------------------------
    self.CenterTrans = UIUtils.FindTrans(self.Trans, "Center")
    self.IconSpr = UIUtils.RequireUIIconBase(self.CenterTrans:Find("Info/Icon"))
    self.NameLabel = UIUtils.FindLabel(self.CenterTrans, "Info/Name")
    self.NumLabel = UIUtils.FindLabel(self.CenterTrans, "Info/ActiveCount/Num")

    self.TeamDescLabel = UIUtils.FindLabel(self.CenterTrans, "Desc/TeamDesc/Content")
    self.ActivityGiftLabel = UIUtils.FindLabel(self.CenterTrans, "Desc/ActivityGift/Content")
    self.OpenTiemLabel = UIUtils.FindLabel(self.CenterTrans, "Desc/OpenTiem/Time")
    self.ConditionDesLabel = UIUtils.FindLabel(self.CenterTrans, "Desc/ConditionDes/Content")
    self.DesLabel = UIUtils.FindLabel(self.CenterTrans, "Desc/Des/Content")

    self.ItemResList = List:New();
    -- local _itemParent = self.Grid.transform;
    -- for i = 0, _itemParent.childCount - 1 do
    --     self.ItemResList:Add(L_FuncItem:New(_itemParent:GetChild(i), self));
    -- end
    local item = nil
    for i = 0, self.TfGrid.childCount - 1 do
        item = L_FuncItem:New(self.TfGrid:GetChild(i), self);
    end
    self.GobjUIItemBase = item.Gobj;
    self.ItemResList:Add(item)
    ------------------------------------------------
end

function UILimitRoot:RefreshActivity(activityList, id, trans)
    local _index = 0
    -- for i = 0, self.TfGrid.childCount - 1 do
    --     self.TfGrid:GetChild(i).gameObject:SetActive(false)
    -- end
    
    self.GobjUIItemBase:SetActive(true)
    if not self.GobjUIItemTemplate then
        self.GobjUIItemTemplate = UnityUtils.Clone(self.GobjUIItemBase, self.TfGrid)
        self.GobjUIItemTemplate:SetActive(false) -- ẩn template
    end

    local _animList = nil
    if self.PlayAnim then
        _animList = List:New()
        self.Owner.AnimPlayer:Stop()
    end
    local _haveGuild = false
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp ~= nil then
        _haveGuild = _lp.GuildID > 0
    end
    local _showIndex = -1;
    local _select = nil
    for i = 1, #activityList do
        local _item = nil
        if i == 1 then
            if not self.ItemResList[1] then
                self.ItemResList[1] = L_FuncItem:New(self.GobjUIItemBase.transform, self)
            end
            _item = self.ItemResList[1]
        else
            _item = self.ItemResList[i]
            if not _item then
                local go = UnityUtils.Clone(self.GobjUIItemTemplate, self.TfGrid)
                go:SetActive(true)
                _item = L_FuncItem:New(go.transform, self)
                self.ItemResList[i] = _item
            end
        end
        _item.SelectSprGo:SetActive(false)
        -- 17 Immortal Alliance Mission 110 Immortal Alliance Battle 111 Immortal Alliance Leader
        if activityList[i].ID == 17 or activityList[i].ID == 110 or activityList[i].ID == 111 then
            if not self.Owner.AnimPlayer.Playing or not _haveGuild then
                _item.Gobj:SetActive(_haveGuild)
            end
            if _haveGuild and self.PlayAnim then
                _animList:Add(_item.Trans)
            end
        else
            local _isAdd = true
            if not self.Owner.AnimPlayer.Playing then
                _item.Gobj:SetActive(true)
            end
            if activityList[i].IsCloseShow == 0 and not activityList[i].IsOpen then
                _isAdd = false
                _item.Gobj:SetActive(false)
            end
            if self.PlayAnim and _isAdd then
                _animList:Add(_item.Trans)
            end
        end
        _item:SetInfo(activityList[i])
        _item:RefreshInfo()
        if _animList ~= nil and id and id == activityList[i].ID then
            _select = _item.JoinBtn.transform
            _showIndex = #_animList - 1;
        end
        _index = _index + 1
    end

    for i = 1, #self.ItemResList do
        if self.ItemResList[i].Trans.gameObject.activeSelf then
            self.ItemResList[i]:OnDetailBtnClick()
            break
        end
    end

    UIUtils.HideNeedless(self.ItemResList, #activityList)
    if _select and trans then
        trans.parent = _select
        UnityUtils.ResetTransform(trans)
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_DAILY_PLAYVFX)
    end
    -- UnityUtils.GridResetPosition(self.TfGrid)
    -- UnityUtils.ScrollResetPosition(self.ScrollCompTrans)
    self.Grid:Reposition()
    self.ScrollView:ResetPosition()
    -- position
    local _dingwei = false
    if _showIndex ~= -1 and _animList ~= nil then
        local _allSize = math.ceil(#_animList / 2) * 128
        local _curSize = math.floor((_showIndex - 1) / 2) * 128
        self.ProgressValue = _curSize / (_allSize - self.ScrollViewHeight)
        self.ListProgress.value = self.ProgressValue
        self.ProgressFrameCount = 3
        _dingwei = true
    end
    
    if self.PlayAnim then
        for i = 1, #_animList do
            self.Owner.CSForm:RemoveTransAnimation(_animList[i])
            if _dingwei then
                self.Owner.CSForm:AddAlphaPosAnimation(_animList[i], 0, 1, -50, 0, 0.001, false, false)
                self.Owner.AnimPlayer:AddTrans(_animList[i], 0)
            else
                self.Owner.CSForm:AddAlphaPosAnimation(_animList[i], 0, 1, -50, 0, 0.2, false, false)
                self.Owner.AnimPlayer:AddTrans(_animList[i], (i - 1) * 0.05)
            end
        end
        self.Owner.AnimPlayer:Play()
    end
    self.PlayAnim = false

    
    
end

function UILimitRoot:Update(dt)
    if self.ProgressFrameCount ~= nil and self.ProgressFrameCount > 0 then
        self.ProgressFrameCount = self.ProgressFrameCount - 1
        if self.ProgressFrameCount <= 0 then
            self.ListProgress.value = self.ProgressValue
        end
    end
end

function UILimitRoot:Show()
    self.Go:SetActive(true)
    self.PlayAnim = true
end

function UILimitRoot:Close()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_DAILY_STOPVFX)
    self.Go:SetActive(false)
end

------------------------------------------------
function UILimitRoot:OnSelectItem(selectedItem)
    for _, item in ipairs(self.ItemResList) do
        if item == selectedItem then
            item:OnSetSelect(true)
        else
            item:OnSetSelect(false)
        end
    end

    self:UpdateCenterDetailGroup(selectedItem.Info)
end 

function UILimitRoot:UpdateCenterDetailGroup(info)
    local _cfg = DataConfig.DataDaily[info.ID]
    if not _cfg then
        Debug.LogError("DataDaily not contains key = ", info.ID)
    end
    self.ID = info.ID
    self.IconSpr:UpdateIcon(_cfg.Icon)
    UIUtils.SetTextByStringDefinesID(self.NameLabel, _cfg._Name)
    if _cfg.Times == -1 then
        UIUtils.SetTextByEnum(self.NumLabel, "Infinite")
    else
        UIUtils.SetTextByNumber(self.NumLabel, info.RemindCount)
    end
    UIUtils.SetTextByStringDefinesID(self.OpenTiemLabel, _cfg._OpenTimeDes)
    UIUtils.SetTextByStringDefinesID(self.ActivityGiftLabel, _cfg._Production)
    UIUtils.SetTextByStringDefinesID(self.TeamDescLabel, _cfg._Team)
    if _cfg.SpecialOpen > Time.GetOpenSeverDay() then
        UIUtils.SetTextByEnum(self.ConditionDesLabel, "OpenServerDay", _cfg.SpecialOpen);
    elseif _cfg.SpecialOpen == Time.GetOpenSeverDay() then
        UIUtils.SetTextByEnum(self.ConditionDesLabel, "OpenByLevel", CommonUtils.GetLevelDesc(info.Cfg.OpenLevel));
    elseif info:IsToMinOpenDay() then
        UIUtils.SetTextByEnum(self.ConditionDesLabel, "OpenByLevel", CommonUtils.GetLevelDesc(info.Cfg.OpenLevel));
    else
        UIUtils.SetTextByStringDefinesID(self.ConditionDesLabel, _cfg._Conditiondes)
    end
    UIUtils.SetTextByStringDefinesID(self.DesLabel, _cfg._Description)
    self.ActivityInfo = info

    -- TODO: COpy để dùng cho nút và quà bên listresitem
    -- if info.Open then
    --     UIUtils.SetTextByEnum(UIUtils.FindLabel(self.GoBtn.transform, "Label"), "Join")
    -- else
    --     if _cfg.Type == 1 then
    --         self.Tips = _cfg.Conditiondes
    --     elseif _cfg.Type == 2 then
    --         local _cfg2 = DataConfig.DataTask[_cfg.Task]
    --         if _cfg2 then
    --             self.Tips = UIUtils.CSFormat(DataConfig.DataMessageString.Get("OPenByCompleteTask"), _cfg2.TaskName)
    --         else
    --             self.Tips = DataConfig.DataMessageString.Get("OPenByCompleteTask2")
    --         end
    --     end
    --     UIUtils.SetTextByString(UIUtils.FindLabel(self.GoBtn.transform, "Label"), self.Tips)
    -- end
    -- local _rewards = Utils.SplitStr(_cfg.Reward, "_");
    -- for i = 1, #_rewards do
    --     local _reward = Utils.SplitStr(_rewards[i], "_");
    --     local _item = self.ItemList[i]
    --     if not _item then
    --         _item = self:CreatItem(self.GobjUIItemBase, self.TfGrid)
    --         self.ItemList:Add(_item);
    --     end
    --     _item.Gobj:SetActive(true);
    --     _item.UIItem:InItWithCfgid(_reward[1], _reward[2], false, true, false)
    -- end

    -- UIUtils.HideNeedless(self.ItemList, #_rewards)
    UnityUtils.GridResetPosition(self.TfGrid)
end
------------------------------------------------


------------------------------------------------
L_FuncItem = {
    -- Trans
    Trans = nil,
    -- Icon
    Icon = nil,
    -- Activity name
    Name = nil,
    -- Number of activities
    ActivityCount = nil,
    -- Join Button
    JoinBtn = nil,
    -- Active value
    ActiveValue = nil,
    -- Detailed buttons
    DetailBtn = nil,
    -- Completed Show
    FinishedSpr = nil,
    -- Output Description
    DesLabel = nil,
    -- Output Type
    ProductionType = nil,
    -- Increase the number of times button
    AddCountBtn = nil,

    -- Activity ID
    ID = nil,
    -- Activity information
    Info = nil,
    -- Open conditions
    OpenCondition = nil,
    -- Go to button

};

function L_FuncItem:New(trans, parent, info)
    local _m = Utils.DeepCopy(self);
    _m.Trans = trans;
    _m.Gobj = trans.gameObject;
    _m.Parent = parent;
    _m.Info = info
    if info then
        _m.ID = info.ID
    end
    _m:FindAllComponents()
    _m:RegUICallback()
    _m:Show()
    return _m
end

function L_FuncItem:FindAllComponents()
    self.Icon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(self.Trans, "Icon"))
    self.Name = UIUtils.FindLabel(self.Trans, "Name")
    self.JoinBtn = UIUtils.FindBtn(self.Trans, "JoinBtn")
    self.ActiveValue = UIUtils.FindLabel(self.Trans, "Active")
    self.ActivityCount = UIUtils.FindLabel(self.Trans, "Count/Value")
    self.DetailBtn = UIUtils.FindBtn(self.Trans)
    self.FinishedSpr = UIUtils.FindSpr(self.Trans, "Finished")
    self.OpenCondition = UIUtils.FindLabel(self.Trans, "OpenCondition")
    self.DesLabel = UIUtils.FindLabel(self.Trans, "Des")
    self.ProductionType = UIUtils.FindSpr(self.Trans, "Tag")
    self.AddCountBtn = UIUtils.FindBtn(self.Trans, "AddCount")
    self.FinishedSpr.gameObject:SetActive(false)
    self.OpenCondition.gameObject:SetActive(false)
    self.SelectSprGo = UIUtils.FindGo(self.Trans, "Select")

    self.TfGrid = UIUtils.FindTrans(self.Trans, "Reward/ListPanel")
    self.GobjUIItemBase = UIUtils.FindGo(self.Trans, "Reward/ListPanel/Item")
    self.ItemList = List:New();
    self.ItemList:Add(self:CreatItem(self.GobjUIItemBase, self.TfGrid, true))
end

function L_FuncItem:SetInfo(info)
    self.Info = info;
    self.ID = info.ID
end

function L_FuncItem:RefreshInfo()
    local _cfg = DataConfig.DataDaily[self.ID]
    if not _cfg then
        Debug.LogError("DataDaily not contains key = ", self.ID)
        return
    end
    self.Icon:UpdateIcon(_cfg.Icon)
    self:UpdateActivityStatus(_cfg)
    UIUtils.SetTextByStringDefinesID(self.Name, _cfg._Name)
    UIUtils.SetTextByStringDefinesID(self.DesLabel, _cfg._MainProduction)
    -- if _cfg.TimesHide == 0 then
        if _cfg.Times == -1 then
            UIUtils.SetTextByEnum(self.ActivityCount, "Infinite")
        else
            UIUtils.SetTextByNumber(self.ActivityCount, self.Info.RemindCount)
        end
        self.ActivityCount.transform.parent.gameObject:SetActive(true)
    -- else
    --     self.ActivityCount.transform.parent.gameObject:SetActive(false)
    -- end
    if _cfg.ActiveValue <= 0 then
        UIUtils.FindTrans(self.Trans, "Active").gameObject:SetActive(false)
    else
        UIUtils.SetTextByEnum(self.ActiveValue, "Daily_GetPoint_Des" ,_cfg.ActiveValue)
        -- ẩn không hiện độ sôi nổi
        --UIUtils.FindTrans(self.Trans, "Active").gameObject:SetActive(true)
    end
    -- ẩn loại phần thưởng
    --self.ProductionType.gameObject:SetActive(true)
    if _cfg.TypeIcon == 1 then
        UIUtils.SetTextByEnum(UIUtils.FindLabel(self.ProductionType.transform, "Label"), "C_ITEM_NAME_EXP")
        -- UIUtils.SetColorByString(self.ProductionType, "#FFFFFF")
        self.ProductionType.spriteName = "n_d_26_1"
    elseif _cfg.TypeIcon == 2 then
        UIUtils.SetTextByEnum(UIUtils.FindLabel(self.ProductionType.transform, "Label"), "Equipment")
        -- UIUtils.SetColorByString(self.ProductionType, "#E82929")
        self.ProductionType.spriteName = "n_d_26"
    elseif _cfg.TypeIcon == 3 then
        UIUtils.SetTextByEnum(UIUtils.FindLabel(self.ProductionType.transform, "Label"), "Silver")
        -- UIUtils.SetColorByString(self.ProductionType, "#F022E2")
        self.ProductionType.spriteName = "n_d_26_2"
    else
        self.ProductionType.gameObject:SetActive(false)
    end

    if self.Info.Open then
        UIUtils.SetTextByEnum(UIUtils.FindLabel(self.JoinBtn.transform, "Name"), "Join")
    else
        if _cfg.Type == 1 then
            self.Tips = _cfg.Conditiondes
        elseif _cfg.Type == 2 then
            local _cfg2 = DataConfig.DataTask[_cfg.Task]
            if _cfg2 then
                self.Tips = UIUtils.CSFormat(DataConfig.DataMessageString.Get("OPenByCompleteTask"), _cfg2.TaskName)
            else
                self.Tips = DataConfig.DataMessageString.Get("OPenByCompleteTask2")
            end
        end
        UIUtils.SetTextByString(UIUtils.FindLabel(self.JoinBtn.transform, "Name"), "Chưa đến giờ")
    end


    local _rewards = Utils.SplitStr(_cfg.Reward, "_");
    for i = 1, #_rewards do
        local _item = self.ItemList[i]
        if not _item then
            _item = self:CreatItem(self.GobjUIItemBase, self.TfGrid)
            self.ItemList:Add(_item);
        end
        _item.Gobj:SetActive(true);
        _item.UIItem:InItWithCfgid(_rewards[i], nil, false, true, false)
    end
    

    UIUtils.HideNeedless(self.ItemList, #_rewards)
    UnityUtils.GridResetPosition(self.TfGrid)


end

function L_FuncItem:UpdateActivityStatus(cfg)
    local _roleLv = GameCenter.GameSceneSystem:GetLocalPlayer().PropMoudle.Level

    self.FinishedSpr.gameObject:SetActive(self.Info.Complete)
    -- Activity completed
    if self.Info.Complete then
        self.JoinBtn.gameObject:SetActive(false)
        self.OpenCondition.gameObject:SetActive(false)
        self.AddCountBtn.gameObject:SetActive(false)
    else
        -- Function is enabled to meet the minimum number of server opening days
        if self.Info.Open and self.Info:IsToMinOpenDay() then
            -- The event starts
            if self.Info.IsOpen then
                self.OpenCondition.gameObject:SetActive(false)
                if self.Info.RemindCount ~= -1 then
                    if self.Info.ID == 3 then
                        self.JoinBtn.gameObject:SetActive(not self.Info.Complete)
                    else
                        self.JoinBtn.gameObject:SetActive(self.Info.RemindCount > 0)
                    end
                    self.AddCountBtn.gameObject:SetActive(self.Info.RemindCount == 0 and self.Info.CanBuyCount > 0)
                else
                    self.JoinBtn.gameObject:SetActive(true)
                    self.AddCountBtn.gameObject:SetActive(false)
                end
            else
                self.JoinBtn.gameObject:SetActive(false)
                self.AddCountBtn.gameObject:SetActive(false)
                -- ẩn điều kiện mở sự kiện
                self.OpenCondition.gameObject:SetActive(true)
                if cfg.SpecialOpen > Time.GetOpenSeverDay() then
                    UIUtils.SetTextByEnum(self.OpenCondition, "OpenServerDay", cfg.SpecialOpen);
                else
                    -- UIUtils.SetTextByString(self.OpenCondition, GameCenter.DailyActivitySystem:GetActivityOpenTime(self.Info.ID))
                    UIUtils.SetTextByString(self.OpenCondition, "Chưa đến giờ")
                end
            end
        -- Function not enabled
        else
            self.JoinBtn.gameObject:SetActive(false)
            self.AddCountBtn.gameObject:SetActive(false)
            self.OpenCondition.gameObject:SetActive(true)
            if cfg.SpecialOpen > Time.GetOpenSeverDay() then
                UIUtils.SetTextByEnum(self.OpenCondition, "OpenServerDay", cfg.SpecialOpen);
            elseif cfg.SpecialOpen == Time.GetOpenSeverDay() then
                UIUtils.SetTextByEnum(self.OpenCondition, "OpenByLevel", CommonUtils.GetLevelDesc(self.Info.Cfg.OpenLevel));
            elseif self.Info:IsToMinOpenDay() then
                UIUtils.SetTextByEnum(self.OpenCondition, "OpenByLevel", CommonUtils.GetLevelDesc(self.Info.Cfg.OpenLevel));
            else
                UIUtils.SetTextByStringDefinesID(self.OpenCondition, cfg._Conditiondes)
            end
        end
    end

    local _showRed = self.JoinBtn.gameObject.activeSelf
    if cfg.Id == 18 then
        _showRed = _showRed and not GameCenter.DailyActivitySystem.IsJoinWeekVip;
    end
    if cfg.Id == 1 then
        _showRed = GameCenter.MainFunctionSystem:GetAlertFlag(FunctionStartIdCode.TowerCopyMap)
    end
    UIUtils.FindGo(self.Trans, "RedPoint"):SetActive(_showRed)
end

function L_FuncItem:RegUICallback()
    UIUtils.AddBtnEvent(self.JoinBtn, self.OnJoinBtnClick, self)
    UIUtils.AddBtnEvent(self.DetailBtn, self.OnDetailBtnClick, self)
    UIUtils.AddBtnEvent(self.AddCountBtn, self.AddCountBtnOnClick, self)
end

-- Participate in the event
function L_FuncItem:OnJoinBtnClick()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_DAILY_STOPVFX)
    if self.Info.Open and self.Info.IsOpen then
        GameCenter.DailyActivitySystem:JoinActivity(self.ID)
    end
    if self.ID == 18 then
        GameCenter.DailyActivitySystem.IsJoinWeekVip = true;
        UIUtils.FindGo(self.Trans, "RedPoint"):SetActive(false)
    end
end

-- Open the activity details interface UIActivityTipsForm
function L_FuncItem:OnDetailBtnClick()
    self.Parent:OnSelectItem(self)
    -- GameCenter.PushFixEvent(UIEventDefine.UIActivityTipsForm_OPEN, self.Info)
end

-- Number of additions
function L_FuncItem:AddCountBtnOnClick()
    local _cfg = DataConfig.DataDaily[self.ID]
    if _cfg then
        local _uiCfg = Utils.SplitStr(_cfg.OpenUI, "_")
        if #_uiCfg == 1 then
            GameCenter.MainFunctionSystem:DoFunctionCallBack(tonumber(_uiCfg[1]), self.ID)
        elseif #_uiCfg == 2 then
            GameCenter.MainFunctionSystem:DoFunctionCallBack(tonumber(_uiCfg[1]), tonumber(_uiCfg[2]))
        end
    end
end

function L_FuncItem:Clone(go, parentTrans, id)
    local obj = UnityUtils.Clone(go, parentTrans).transform
    return self:New(obj, id)
end

function L_FuncItem:Show()
    if not self.Trans.gameObject.activeSelf then
        self.Trans.gameObject:SetActive(true)
    end
end

function L_FuncItem:Close()
    self.Trans.gameObject:SetActive(false)
end

function L_FuncItem:OnSetSelect(isSelct)
    if self.SelectSprGo then
        self.IsSelect = isSelct
        self.SelectSprGo:SetActive(isSelct)
    end
end

-- Create props
function L_FuncItem:CreatItem(gobj, tfParent, isClone)
    local _gobj = isClone and gobj or UnityUtils.Clone(gobj, tfParent);
    return {
        Gobj = _gobj,
        UIItem = UILuaItem:New(_gobj.transform)
    }
end
------------------------------------------------

return UILimitRoot
