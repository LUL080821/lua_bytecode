------------------------------------------------
-- author:
-- Date: 2019-04-22
-- File: UIActivityItem.lua
-- Module: UIActivityItem
-- Description: Daily Activities Item
------------------------------------------------
local UIActivityItem = {
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
    OpenCondition = nil
}

function UIActivityItem:New(trans, info)
    local _m = Utils.DeepCopy(self)
    _m.Gobj = trans.gameObject;
    _m.Trans = trans
    _m.Info = info
    if info then
        _m.ID = info.ID
    end
    _m:FindAllComponents()
    _m:RegUICallback()
    _m:Show()
    return _m
end

function UIActivityItem:FindAllComponents()
    self.Icon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(self.Trans, "Icon"))
    self.NumLabel = UIUtils.FindLabel(self.Trans, "Icon/Num")
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
    for i = 1, self.TfGrid.childCount do
        self.ItemList:Add(self:CreatItem(self.GobjUIItemBase, self.TfGrid, true))
    end
end

function UIActivityItem:SetInfo(info)
    self.Info = info;
    self.ID = info.ID
end

-- Refresh event information
function UIActivityItem:RefreshInfo()
    local _cfg = DataConfig.DataDaily[self.ID]
    if not _cfg then
        Debug.LogError("DataDaily not contains key = ", self.ID)
        return
    end
    -- self.Icon:UpdateIcon(_cfg.Icon)
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
        -- UIUtils.SetTextByEnum(self.NumLabel, "Daily_GetPoint_Des" ,_cfg.ActiveValue)
        UIUtils.SetTextByString(self.NumLabel, _cfg.ActiveValue)
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
        UIUtils.SetTextByString(UIUtils.FindLabel(self.JoinBtn.transform, "Name"), self.Tips)
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

-- Update activity status
function UIActivityItem:UpdateActivityStatus(cfg)
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
                    UIUtils.SetTextByString(self.OpenCondition, GameCenter.DailyActivitySystem:GetActivityOpenTime(self.Info.ID))
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

function UIActivityItem:RegUICallback()
    UIUtils.AddBtnEvent(self.JoinBtn, self.OnJoinBtnClick, self)
    UIUtils.AddBtnEvent(self.DetailBtn, self.OnDetailBtnClick, self)
    UIUtils.AddBtnEvent(self.AddCountBtn, self.AddCountBtnOnClick, self)
end

-- Participate in the event
function UIActivityItem:OnJoinBtnClick()
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
function UIActivityItem:OnDetailBtnClick()
    
    GameCenter.PushFixEvent(UIEventDefine.UIActivityTipsForm_OPEN, self.Info)
end

-- Number of additions
function UIActivityItem:AddCountBtnOnClick()
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

function UIActivityItem:Clone(go, parentTrans, id)
    local obj = UnityUtils.Clone(go, parentTrans).transform
    return self:New(obj, id)
end

function UIActivityItem:Show()
    if not self.Trans.gameObject.activeSelf then
        self.Trans.gameObject:SetActive(true)
    end
end

function UIActivityItem:Close()
    self.Trans.gameObject:SetActive(false)
end

function UIActivityItem:OnSetSelect(isSelct)
    if self.SelectSprGo then
        self.IsSelect = isSelct
        self.SelectSprGo:SetActive(isSelct)
    end
end

-- Create props
function UIActivityItem:CreatItem(gobj, tfParent, isClone)
    local _gobj = isClone and gobj or UnityUtils.Clone(gobj, tfParent);
    return {
        Gobj = _gobj,
        UIItem = UILuaItem:New(_gobj.transform)
    }
end

return UIActivityItem
